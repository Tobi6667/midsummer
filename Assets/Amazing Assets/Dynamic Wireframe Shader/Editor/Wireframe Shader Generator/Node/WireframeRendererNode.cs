// Dynamic Wireframe Shader <https://u3d.as/3WyY>
// Copyright (c) Amazing Assets <https://amazingassets.world>

using System;
using System.IO;
using System.Linq;
using System.Reflection;

using UnityEngine;
using UnityEditor;
using UnityEditor.Graphing;
using UnityEditor.ShaderGraph;
using UnityEditor.ShaderGraph.Internal;


namespace AmazingAssets.DynamicWireframeShaderGenerator.Editor
{
    [Title("Amazing Assets", "Dynamic Wireframe Shader", "Wireframe Renderer")]
    class WireframeRendererNode : AbstractMaterialNode, IGeneratesBodyCode, IGeneratesFunction, IMayRequireMeshUV
    {
        public override string documentationURL => About.documentationURL;


        const int InputSlotThicknessID = 0;
        const int InputSlotAntiAliasingID = 1;
        const int OutputSlotWireframeID = 3;
        const int OutputSlotBarucentricUVID = 4;

        const string InputSlotThicknessName = "Thickness";
        const string InputSlotAntiAliasingName = "Anti-aliasing";
        const string OutputSlotWireframeName = "Wireframe";
        const string OutputSlotBarucentricUVName = "Barycentric UV";

        [SerializeField] float m_Thickness = 0.01f;
        [SerializeField] float m_AntiAliasing = 0.2f;


        [ButtonControl(false, "GenerateButtonCallback")]
        int m_ButtonGenerate { get; set; }
        public UnityEngine.UIElements.Button buttonGenerate;

        
        private Shader m_WireframeNodeTargetShader;
        [ObjectControl(false, "InitTargetShader", "")]
        public Shader WireframeNodeTargetShader
        {
            get { return m_WireframeNodeTargetShader; }
            set
            {
                if (m_WireframeNodeTargetShader == value)
                    return;

                m_WireframeNodeTargetShader = value;
            }
        }
        UnityEditor.UIElements.ObjectField targetShaderObjectField;


        static string[] functionBody = File.ReadAllLines(Path.Combine(EditorUtilities.GetThisAssetProjectPath(), "Editor", "Wireframe Shader Generator", "Templates", "FunctionBody.txt"));


        public WireframeRendererNode()
        {
            name = "Wireframe Renderer";

            UpdateNodeAfterDeserialization();
        }
        public override void ValidateNode()
        {
            base.ValidateNode();
        }
        public sealed override void UpdateNodeAfterDeserialization()
        {
            AddSlot(new Vector1MaterialSlot(InputSlotThicknessID, InputSlotThicknessName, InputSlotThicknessName, SlotType.Input, m_Thickness));
            AddSlot(new Vector1MaterialSlot(InputSlotAntiAliasingID, InputSlotAntiAliasingName, InputSlotAntiAliasingName, SlotType.Input, m_AntiAliasing));
            AddSlot(new Vector1MaterialSlot(OutputSlotWireframeID, OutputSlotWireframeName, OutputSlotWireframeName, SlotType.Output, 0, ShaderStageCapability.Fragment));
            AddSlot(new Vector2MaterialSlot(OutputSlotBarucentricUVID, OutputSlotBarucentricUVName, OutputSlotBarucentricUVName, SlotType.Output, Vector2.zero, ShaderStageCapability.Fragment));

            RemoveSlotsNameNotMatching(new[] { InputSlotThicknessID, InputSlotAntiAliasingID, OutputSlotWireframeID, OutputSlotBarucentricUVID });
        }
        string GetFunctionName()
        {
            return $"{ShaderGenerator.methodName}_float";
        }
        public void GenerateNodeCode(ShaderStringBuilder sb, GenerationMode generationMode)
        {
            var readFromChannelValue = GetReadFromChannelValue();
            var thicknessValue = GetSlotValue(InputSlotThicknessID, generationMode);
            var antiAliasingValue = GetSlotValue(InputSlotAntiAliasingID, generationMode);

            var outputWireframeName = GetVariableNameForSlot(OutputSlotWireframeID);
            var outputBarycentricUVName = GetVariableNameForSlot(OutputSlotBarucentricUVID);

            sb.AppendLine(string.Format("float {0};", outputWireframeName));
            sb.AppendLine(string.Format("float2 {0};", outputBarycentricUVName));

            sb.AppendLine("{0}({1}, max(0, {2}), max(0, {3}), {4}, {5}, {6});", GetFunctionName(), readFromChannelValue, thicknessValue, antiAliasingValue, 0, outputWireframeName, outputBarycentricUVName);
        }
        public void GenerateNodeFunction(FunctionRegistry registry, GenerationMode generationMode)
        {
            registry.ProvideFunction(GetFunctionName(), s =>
            {
                s.AppendLine($"void {GetFunctionName()}(float3 barycentric, float3 thickness, float antiAliasing, float renderInScreenSpace, out float OutWireframe, out float2 OutBarycentricUV)");

                using (s.BlockScope())
                {
                    foreach (var line in functionBody)
                    {
                        s.AddLine(line);
                    }
                }
            });
        }
        string GetReadFromChannelValue()
        {
            return $"IN.uv3.xyz";
        }
        public bool RequiresMeshUV(UVChannel channel, ShaderStageCapability stageCapability)
        {
            return true;
        }

        public void InitTargetShader(UnityEditor.UIElements.ObjectField m_PropertyInfo)
        {
            targetShaderObjectField = m_PropertyInfo;
            targetShaderObjectField.SetEnabled(false);

            TargetShaderUpdate();
        }
        void TargetShaderUpdate()
        {
            string targetShaderAssetPath = ShaderGenerator.GetGeneratedShaderPath(GetThisShaderGraphAssetPath());
            if (File.Exists(targetShaderAssetPath) == false)
                WireframeNodeTargetShader = null;
            else
                WireframeNodeTargetShader = AssetDatabase.LoadAssetAtPath<Shader>(targetShaderAssetPath);

            targetShaderObjectField.value = WireframeNodeTargetShader;
            targetShaderObjectField.tooltip = WireframeNodeTargetShader == null ? string.Empty : Path.GetFileNameWithoutExtension(targetShaderAssetPath);

            targetShaderObjectField.MarkDirtyRepaint();


            this.Dirty(ModificationScope.Node);
        }

        public void GenerateButtonCallback()
        {
            if (owner.isSubGraph)
                EditorUtility.DisplayDialog("Error", "Wireframe shader cannot be generated from the sub-graph.", "Ok");
            else
            {
                //Make sure correct target shader is selected
                TargetShaderUpdate();

                //Save graph before generating 
                SaveCurrentGraph(this.owner.assetGuid);

                //Generate
                ShaderGenerator.Generate(GetThisShaderGraphAssetPath(), WireframeNodeTargetShader, false);

                //Update target shader
                TargetShaderUpdate();
            }
        }

        public void SaveCurrentGraph(string targetGuid)
        {
            var assemblies = AppDomain.CurrentDomain.GetAssemblies();

            var windowType = assemblies
                .Select(a => a.GetType("UnityEditor.ShaderGraph.Drawing.MaterialGraphEditWindow"))
                .FirstOrDefault(t => t != null);

            if (windowType != null)
            {
                var windows = Resources.FindObjectsOfTypeAll(windowType);

                foreach (var window in windows)
                {
                    var guidField = windowType.GetField("m_Selected", BindingFlags.Instance | BindingFlags.NonPublic | BindingFlags.Public);
                    if (guidField == null)
                        continue;

                    var guidValue = guidField.GetValue(window) as string;
                    if (string.IsNullOrEmpty(guidValue))
                        continue;

                    if (guidValue == targetGuid)
                    {
                        var method = windowType.GetMethod("SaveAsset", BindingFlags.Instance | BindingFlags.NonPublic | BindingFlags.Public);
                        if (method != null)
                        {
                            method.Invoke(window, null);
                            return;
                        }
                    }
                }
            }

            Debug.LogWarning("Shader Graph is not saved.");
        }
        string GetThisShaderGraphAssetPath()
        {
            return AssetDatabase.GUIDToAssetPath(this.owner.assetGuid);
        }
    }
}
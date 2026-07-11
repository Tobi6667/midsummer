// Dynamic Wireframe Shader <https://u3d.as/3WyY>
// Copyright (c) Amazing Assets <https://amazingassets.world>

using System;
using System.IO;
using System.Linq;
using System.Text;
using System.Globalization;
using System.Collections.Generic;
using System.Text.RegularExpressions;

using UnityEngine;
using UnityEditor;
using UnityEditor.Graphing;
using UnityEditor.ShaderGraph;
using UnityEditor.ShaderGraph.Serialization;


namespace AmazingAssets.DynamicWireframeShaderGenerator.Editor
{
    static internal class ShaderGenerator
    {
        enum Pass
        {
            Unknown,
            BuiltInForward, BuiltInForwardAdd, BuiltInDeferred, BuiltInUnlitPass, BuiltInDepth, BuiltInShadowCaster, BuiltInMeta,
            UniversalForward, UniversalForwardOnly, UniversalGBuffer, UniversalPass, UniversalDepthOnly, UniversalDepthNormals, UniversalDepthNormalsOnly, UniversalMotionVectors, UniversalShadowCaster, UniversalMeta, Universal2D, UniversalXRMotionVectors,
            HighDefinitionForward, HighDefinitionForwardOnly, HighDefinitionGBuffer, HighDefinitionTransparentDepthPrepass, HighDefinitionTransparentBackface, HighDefinitionTransparentDepthPostpass, HighDefinitionDepthOnly, HighDefinitionDepthForwardOnly, HighDefinitionMotionVectors, HighDefinitionDistortionVectors, HighDefinitionShadowCaster, HighDefinitionMETA, HighDefinitionFullScreenDebug,
            HighDefinitionForwardDXR, HighDefinitionGBufferDXR, HighDefinitionRayTracingPrepass, HighDefinitionIndirectDXR, HighDefinitionVisibilityDXR, HighDefinitionPathTracingDXR, HighDefinitionDebugDXR, HighDefinitionSubSurfaceDXR,
            SceneSelectionPass, ScenePickingPass
        }

        public enum ConversionState { Success, Skip, Failed };


        internal const string nameSuffix = " (Dynamic Wireframe)";
        internal const string methodName = "WireframeRenderer";


        [MenuItem("Hidden/Assets/Amazing Assets/Dynamic Wireframe Shader/Recompile Example Scene Shaders", false, 3101)]
        static public void RecompileShaderExampleSceneShaders()
        {
            string examplesFolder = Path.Combine(EditorUtilities.GetThisAssetProjectPath(), "Example Scenes");
            if (Directory.Exists(examplesFolder) == false)
                return;

            List<string> paths = new List<string>();

            string[] guids = AssetDatabase.FindAssets("t:shader", new string[] { examplesFolder });
            for (int i = 0; i < guids.Length; i++)
            {
                string path = AssetDatabase.GUIDToAssetPath(guids[i]);

                if (Path.GetExtension(path).ToLowerInvariant() == ".shader")
                    paths.Add(path);
            }

            RecompileShaders(paths);
        }

        [MenuItem("Assets/Amazing Assets/Dynamic Wireframe Shader/Recompile", false, 3102)]
        static public void RecompileShaderMenu()
        {
            List<string> paths = new List<string>();
            if (Selection.objects != null && Selection.objects.Length > 0)
            {
                foreach (var item in Selection.objects)
                {
                    string filePath = AssetDatabase.GetAssetPath(item);
                    if (Path.GetExtension(filePath).ToLowerInvariant() == ".shader")
                        paths.Add(filePath);
                }
            }


            //Check folders
            if (Selection.assetGUIDs != null && Selection.assetGUIDs.Length > 0)
            {
                foreach (var item in Selection.assetGUIDs)
                {
                    string folderPath = AssetDatabase.GUIDToAssetPath(item);
                    if (Directory.Exists(folderPath))
                    {
                        paths.AddRange(Directory.GetFiles(folderPath, "*.shader", SearchOption.AllDirectories));
                    }
                }
            }

            RecompileShaders(paths);

        }
        [MenuItem("Assets/Amazing Assets/Dynamic Wireframe Shader/Recompile", true, 3102)]
        static public bool Validate_RecompileShaderMenu()
        {
            if (Selection.objects != null && Selection.objects.Length > 0)
            {
                foreach (var item in Selection.objects)
                {
                    string path = AssetDatabase.GetAssetPath(item);
                    if (File.Exists(path) && Path.GetExtension(path).ToLowerInvariant() == ".shader")
                        return true;
                }
            }

            //Check selected folder
            if (Selection.assetGUIDs != null && Selection.assetGUIDs.Length > 0)
            {
                foreach (var item in Selection.assetGUIDs)
                {
                    string path = AssetDatabase.GUIDToAssetPath(item);
                    if (Directory.Exists(path))
                        return true;
                }
            }


            return false;
        }

        [MenuItem("Assets/Amazing Assets/Dynamic Wireframe Shader/Restore Shader Graph", false, 3103)]
        static public void CopyShaderGraphMenu()
        {
            if (Selection.objects == null || Selection.objects.Length != 1)
                return;

            string shaderAssetPath = AssetDatabase.GetAssetPath(Selection.objects[0]);
            if (File.Exists(shaderAssetPath) == false || Path.GetExtension(shaderAssetPath).ToLowerInvariant() != ".shader")
                return;

            if (ReadSourceShaderGraph(shaderAssetPath, out string body) == false)
            {
                Log.Message(LogType.Warning, $"Cannot copy shader graph from the '{Path.GetFileNameWithoutExtension(shaderAssetPath)}'.");
                return;
            }
            else
            {
                string fileName = Path.GetFileNameWithoutExtension(shaderAssetPath);
                if (fileName.Contains(nameSuffix.Trim()))
                    fileName = fileName.Replace(nameSuffix.Trim(), string.Empty).Trim();


                var path = EditorUtility.SaveFilePanel("Restore Shader Graph", Path.GetDirectoryName(shaderAssetPath), fileName + ".shadergraph", "shadergraph");
                if (path.Length != 0)
                {
                    if (Path.GetExtension(path).ToLowerInvariant() != ".shadergraph")
                        path = Path.Combine(Path.GetDirectoryName(path), Path.GetFileNameWithoutExtension(path) + ".shadergraph");

                    File.WriteAllText(path, body);

                    if (EditorUtilities.IsPathProjectRelative(path))
                    {
                        AssetDatabase.Refresh();

                        EditorUtilities.PingObject(path);
                    }
                }
            }
        }
        [MenuItem("Assets/Amazing Assets/Dynamic Wireframe Shader/Restore Shader Graph", true, 3103)]
        static public bool Validate_CopyShaderGraphMenu()
        {
            if (Selection.objects != null && Selection.objects.Length == 1)
            {
                string path = AssetDatabase.GetAssetPath(Selection.objects[0]);
                if (File.Exists(path) && Path.GetExtension(path).ToLowerInvariant() == ".shader")
                    return true;
            }

            return false;
        }

        static void RecompileShaders(List<string> paths)
        {
            if (paths == null || paths.Count == 0)
                return;

            paths = paths.Where(s => !string.IsNullOrWhiteSpace(s)).Select(s => s.Replace('\\', '/')).Distinct().OrderBy(s => s).ToList();
            if (paths.Count == 0)
                return;


            List<string> statisticsSuccess = new List<string>();
            List<string> statisticsSkipped = new List<string>();
            List<string> statisticsFailure = new List<string>();

            for (int i = 0; i < paths.Count; i++)
            {
                string shaderPath = paths[i];

                EditorUtility.DisplayProgressBar("Hold On", paths[i], (float)i / paths.Count);

                switch (Recompile(shaderPath))
                {
                    case ConversionState.Success: statisticsSuccess.Add(shaderPath); break;
                    case ConversionState.Skip: statisticsSkipped.Add(shaderPath); break;
                    case ConversionState.Failed: statisticsFailure.Add(shaderPath); break;

                    default:
                        break;
                }
            }

            EditorUtilities.DeleteTempDirectory();

            EditorUtility.ClearProgressBar();
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();


            #region Statistics     
            string str = $"Updated: {statisticsSuccess.Count}\n";
            str += $"Failed: {statisticsFailure.Count}\n";
            str += $"Skipped: {statisticsSkipped.Count}\n\n";


            if (statisticsSuccess.Count > 0)
            {
                str += "Successfully Updated:\n";
                foreach (var item in statisticsSuccess)
                {
                    str += item + "\n";
                }
                str += "\n";
            }
            if (statisticsFailure.Count > 0)
            {
                str += "Failed:\n";
                foreach (var item in statisticsFailure)
                {
                    str += item + "\n";
                }
                str += "\n";
            }
            if (statisticsSkipped.Count > 0)
            {
                str += "Skipped:\n";
                foreach (var item in statisticsSkipped)
                {
                    str += item + "\n";
                }
            }

            Log.Message(statisticsFailure.Count > 0 ? LogType.Error : (statisticsSuccess.Count == 0 ? LogType.Warning : LogType.Log), str);
            #endregion

        }
        static ConversionState Recompile(string shaderAssetPath)
        {
            if (File.Exists(shaderAssetPath) == false || Path.GetExtension(shaderAssetPath).ToLowerInvariant() != ".shader")
                return ConversionState.Skip;


            //Get source Shader Graph
            string shaderGraphBody;

            string shaderAssetName = Path.GetFileNameWithoutExtension(shaderAssetPath);
            int lastIndexOfPrefix = shaderAssetName.LastIndexOf(nameSuffix);
            if (lastIndexOfPrefix > 0)
            {
                string sourceShaderGraphAssetName = shaderAssetName.Substring(0, lastIndexOfPrefix);
                string sourceShaderGraphAssetPath = Path.Combine(Path.GetDirectoryName(shaderAssetPath), sourceShaderGraphAssetName + ".shadergraph");

                if (File.Exists(sourceShaderGraphAssetPath))
                {
                    //Recompile target shader
                    Generate(sourceShaderGraphAssetPath, null, false);

                    return ConversionState.Success;
                }
            }
            
            
            //If source Shader Graph doesn't exist, read it from compiled shader
            if (ReadSourceShaderGraph(shaderAssetPath, out shaderGraphBody) == false)
                return ConversionState.Skip;


            //Set target shader
            Shader shader = (Shader)AssetDatabase.LoadAssetAtPath(shaderAssetPath, typeof(Shader));

            string shaderName = GetShaderName(shader);
            if (string.IsNullOrEmpty(shaderName))
                return ConversionState.Failed;

            //Update m_Path field inside Shader Graph asset
            string m_Path = EditorUtilities.NormalizePath(Path.GetDirectoryName(shaderName));
            shaderGraphBody = Regex.Replace(shaderGraphBody, @"""m_Path"":\s*""[^""]*""", _ => $@"""m_Path"": ""{m_Path}""");


            //Generate .shadergraph file
            string tempFolder = EditorUtilities.GetAssetTempFolder();
            if (Directory.Exists(tempFolder) == false)
                Directory.CreateDirectory(tempFolder);

            string shaderGraphFilePath = Path.Combine(tempFolder, "Temp.shadergraph");
            File.WriteAllText(shaderGraphFilePath, shaderGraphBody);

            AssetDatabase.Refresh();

            Shader shaderGraph = (Shader)AssetDatabase.LoadAssetAtPath(shaderGraphFilePath, typeof(Shader));
            if (shaderGraph == null || ShaderUtil.ShaderHasError(shaderGraph))
                return ConversionState.Failed;


            //Recompile target shader
            Generate(shaderGraphFilePath, shader, true);


            return ConversionState.Success;
        }
        static internal string Generate(string shaderGraphAssetPath, Shader targetShader, bool keepShaderName)
        {
            string shaderGraphHLSLCode = GetShaderGraphHLSLCode(shaderGraphAssetPath);
            if (string.IsNullOrEmpty(shaderGraphHLSLCode))
            {
                Log.Message(LogType.Error, "Cannot generate wireframe shader. HLSL code is empty.");
                return string.Empty;
            }


            List<string> newShaderFile = shaderGraphHLSLCode.Split(new[] { "\n" }, StringSplitOptions.None).ToList();
            if (IsShaderGraphSuitable(newShaderFile) == false)
                return string.Empty;

            if (ChangeShaderName(newShaderFile, keepShaderName ? targetShader : null) == false)
            {
                Log.Message(LogType.Error, "Cannot generate wireframe shader. Problem with shader renaming.\n", null);
                return string.Empty;
            }

            //Add marker
            newShaderFile.InsertRange(0, new string[] { $"// {About.name} <{About.storeURL}>",
                                                        "// Copyright (c) Amazing Assets <https://amazingassets.world>",
                                                        ""});


            newShaderFile = IntegrateDynamicWireframeRenderer(newShaderFile);

            newShaderFile.Add(SaveSourceShaderGraph(shaderGraphAssetPath));

            //Save shader            
            return CreateShaderAssetFile(newShaderFile, shaderGraphAssetPath, targetShader);
        }

        static public List<string> IntegrateDynamicWireframeRenderer(List<string> hlslCode)
        {
            List<string> newShaderFile = new List<string>(hlslCode);

            AddProperties(ref newShaderFile);


            Pass[] usesPass = GetPassesUsingWireframe(newShaderFile);


            switch (EditorUtilities.GetCurrentRenderPipeline())
            {
                case EditorUtilities.RenderPipeline.BuiltIn: UpdateShaderBuiltIn(ref newShaderFile, usesPass); break;
                case EditorUtilities.RenderPipeline.Universal: UpdateShaderUniversal(ref newShaderFile, usesPass); break;
                case EditorUtilities.RenderPipeline.HighDefinition: UpdateShaderHighDefinition(ref newShaderFile, usesPass); break;

                default:
                    Log.Message(LogType.Error, "Cannot generate wireframe shader. Unknown render pipeline.");
                    break;
            }

            return newShaderFile;
        }

        static bool ChangeShaderName(List<string> newShaderFile, Shader targetShader)
        {
            //Shader "name"         <-- find this line and set new shader name
            //{
            //      Properties
            //      {
            //  ...
            //  ...
            //  ...
            //      } 


            string targetShaderName = targetShader == null ? string.Empty : targetShader.name;

            for (int i = 0; i < newShaderFile.Count; i++)
            {
                if (newShaderFile[i].Trim().StartsWith("Shader"))
                {
                    if (string.IsNullOrEmpty(targetShaderName))
                        newShaderFile[i] = newShaderFile[i].Insert(newShaderFile[i].LastIndexOf("\""), nameSuffix);
                    else
                        newShaderFile[i] = $"Shader \"{targetShaderName}\"";

                    return true;
                }
            }

            return false;
        }
        static string GetShaderName(Shader shader)
        {
            if (shader == null)
                return string.Empty;

            if (ShaderUtil.ShaderHasError(shader))
            {
                string shaderAssetPath = AssetDatabase.GetAssetPath(shader);

                string[] lines = File.ReadAllLines(shaderAssetPath);
                for (int i = 0; i < lines.Length; i++)
                {
                    if (lines[i].TrimStart().StartsWith("Shader"))
                    {
                        int first = lines[i].IndexOf('"');
                        int last = lines[i].LastIndexOf('"');

                        return lines[i].Substring(first + 1, last - first - 1);
                    }
                }

                return string.Empty;
            }
            else
            {
                return shader.name;
            }
        }
        static void AddProperties(ref List<string> newShaderFile)
        {
            List<string> properties = new List<string>();
            properties.Add("[KeywordEnum(Triangle, Quad)] _Wireframe_Shader_Shape(\"Wireframe Shape\", int) = 0");
            properties.Add("[KeywordEnum(Default, Normalized, Screen Space)] _Wireframe_Shader_Style(\"Wireframe Style\", int) = 0");


            if (properties.Count > 0)
            {
                properties.Add(string.Empty);

                for (int i = 0; i < newShaderFile.Count; i++)
                {
                    if (newShaderFile[i].Trim() == "Properties")
                    {
                        while (newShaderFile[i].Trim() != "{")
                            i++;

                        newShaderFile.InsertRange(i + 1, properties);

                        break;
                    }
                }
            }
        }
        static void UpdateShaderBuiltIn(ref List<string> newShaderFile, Pass[] usedPass)
        {
            string[] hullAndDomain = GetHullAndDomainMethods();
            string[] defines = GetDefines();

            Pass pass = Pass.Unknown;
            for (int i = 0; i < newShaderFile.Count; i++)
            {
                if (newShaderFile[i].Trim().StartsWith("//"))
                    continue;


                //Detect current shader pass
                if (newShaderFile[i].Contains("Name") == true)
                {
                    if (GetShaderPass(newShaderFile[i], out string passName))
                    {
                        switch (passName)
                        {
                            case "BuiltInForward": pass = Pass.BuiltInForward; break;
                            case "BuiltInForwardAdd": pass = Pass.BuiltInForwardAdd; break;
                            case "BuiltInDeferred": pass = Pass.BuiltInDeferred; break;
                            case "Pass": pass = Pass.BuiltInUnlitPass; break;
                            case "DepthOnly": pass = Pass.BuiltInDepth; break;
                            case "ShadowCaster": pass = Pass.BuiltInShadowCaster; break;
                            case "Meta": pass = Pass.BuiltInMeta; break;
                            case "SceneSelectionPass": pass = Pass.SceneSelectionPass; break;
                            case "ScenePickingPass": pass = Pass.ScenePickingPass; break;

                            case "": break;

                            default:
                                {
                                    pass = Pass.Unknown;
                                    Log.Message(LogType.Error, $"Unsupported shader pass '{passName}'.");
                                }
                                break;
                        }
                    }
                }

                if (usedPass.Contains(pass))
                {
                    if (newShaderFile[i].Contains("#pragma") && newShaderFile[i].Contains("target"))
                    {
                        string pragmaTarget = newShaderFile[i].Replace("#pragma ", string.Empty).Replace("target ", string.Empty).Trim();
                        float target;
                        if (float.TryParse(pragmaTarget, out target) == false)
                            target = 5.0f;

                        target = Mathf.Max(target, 5.0f);

                        newShaderFile[i] = "#pragma target " + target.ToString("0.0#");
                    }

                    //Declar hull and domain
                    if (newShaderFile[i].Contains("#pragma ") && newShaderFile[i].Contains(" vertex ") && newShaderFile[i].ToLowerInvariant().Contains(" vert"))
                    {
                        newShaderFile[i] = string.Empty;
                        newShaderFile.InsertRange(i, defines);

                        i += defines.Length;
                    }

                    if (newShaderFile[i].Contains("struct Varyings"))
                    {
                        while (newShaderFile[i].Trim() != "};")
                            i++;

                        newShaderFile.Insert(i, "float3 barycentric;");
                    }

                    if (newShaderFile[i].Contains("struct SurfaceDescriptionInputs"))
                    {
                        while (newShaderFile[i].Trim() != "};")
                            i++;

                        newShaderFile.Insert(i, "float3 barycentric;");
                    }

                    if (newShaderFile[i].Contains("struct PackedVaryings"))
                    {
                        int saveIndex = i;
                        int usedINTERP = -1;
                        while (newShaderFile[i].Trim() != "};")
                        {
                            if (newShaderFile[i].Contains(":") && newShaderFile[i].Contains("INTERP") && newShaderFile[i].Contains(";"))
                            {
                                int index = newShaderFile[i].IndexOf("INTERP");
                                if (index != -1)
                                {
                                    string result = newShaderFile[i].Substring(index).Replace("INTERP", string.Empty).Replace(";", string.Empty).Trim();
                                    int.TryParse(result, out usedINTERP);
                                }
                            }

                            i++;
                        }


                        //Insert here   - - - - - - - - - - - - - - -
                        //                                          |
                        //struct PackedVaryings                     |   i
                        //{                                         |   i + 1
                        //  float3 barycentric : INTERP8;     ← - - -   i + 2
                        //  float4 positionCS : SV_POSITION;

                        newShaderFile.Insert(saveIndex + 2, $"float3 barycentric : INTERP{usedINTERP + 1};");
                    }

                    if (newShaderFile[i].Contains("PackedVaryings PackVaryings (Varyings input)"))
                    {
                        while (newShaderFile[i].Trim().StartsWith("return ") == false)
                            i++;

                        newShaderFile.Insert(i, "output.barycentric = input.barycentric;");
                    }

                    if (newShaderFile[i].Contains("Varyings UnpackVaryings (PackedVaryings input)"))
                    {
                        while (newShaderFile[i].Trim().StartsWith("return ") == false)
                            i++;

                        newShaderFile.Insert(i, "output.barycentric = input.barycentric;");
                    }

                    if (newShaderFile[i].Contains("SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)"))
                    {
                        while (newShaderFile[i].Trim().StartsWith("return ") == false)
                            i++;

                        newShaderFile.Insert(i, "output.barycentric = input.barycentric;");
                    }

                    if (newShaderFile[i].Trim().StartsWith(methodName))
                    {
                        newShaderFile[i] = ReplaceInput(newShaderFile[i]);
                    }

                    if (newShaderFile[i].Contains("ENDHLSL"))
                    {
                        newShaderFile.InsertRange(i, hullAndDomain);

                        i += hullAndDomain.Length;
                    }
                }
            }
        }
        static void UpdateShaderUniversal(ref List<string> newShaderFile, Pass[] usedPass)
        {
            string[] hullAndDomain = GetHullAndDomainMethods();
            string[] defines = GetDefines();

            Pass pass = Pass.Unknown;
            for (int i = 0; i < newShaderFile.Count; i++)
            {
                if (newShaderFile[i].Trim().StartsWith("//"))
                    continue;


                //Detect current shader pass
                if (newShaderFile[i].Contains("Name") == true)
                {
                    if (GetShaderPass(newShaderFile[i], out string passName))
                    {
                        switch (passName)
                        {
                            case "UniversalForward": pass = Pass.UniversalForward; break;
                            case "UniversalForwardOnly": pass = Pass.UniversalForwardOnly; break;
                            case "GBuffer": pass = Pass.UniversalGBuffer; break;
                            case "Pass": pass = Pass.UniversalPass; break;
                            case "DepthOnly": pass = Pass.UniversalDepthOnly; break;
                            case "DepthNormals": pass = Pass.UniversalDepthNormals; break;
                            case "DepthNormalsOnly": pass = Pass.UniversalDepthNormalsOnly; break;
                            case "MotionVectors": pass = Pass.UniversalMotionVectors; break;
                            case "ShadowCaster": pass = Pass.UniversalShadowCaster; break;
                            case "Meta": pass = Pass.UniversalMeta; break;
                            case "Universal2D": pass = Pass.Universal2D; break;
                            case "XRMotionVectors": pass = Pass.UniversalXRMotionVectors; break;
                            case "SceneSelectionPass": pass = Pass.SceneSelectionPass; break;
                            case "ScenePickingPass": pass = Pass.ScenePickingPass; break;

                            case "": break;

                            default:
                                {
                                    pass = Pass.Unknown;
                                    Log.Message(LogType.Error, $"Unsupported shader pass '{passName}'.");
                                }
                                break;
                        }
                    }
                }

                if (usedPass.Contains(pass))
                {
                    //Unsuported
                    if (pass == Pass.UniversalMotionVectors)
                    {

                    }
                    else
                    {
                        if (newShaderFile[i].Contains("#pragma") && newShaderFile[i].Contains("target"))
                        {
                            string pragmaTarget = newShaderFile[i].Replace("#pragma ", string.Empty).Replace("target ", string.Empty).Trim();
                            float target;
                            if (float.TryParse(pragmaTarget, out target) == false)
                                target = 5.0f;

                            target = Mathf.Max(target, 5.0f);

                            newShaderFile[i] = "#pragma target " + target.ToString("0.0#");
                        }

                        //Declar hull and domain
                        if (newShaderFile[i].Contains("#pragma ") && newShaderFile[i].Contains(" vertex ") && newShaderFile[i].ToLowerInvariant().Contains(" vert"))
                        {
                            newShaderFile[i] = string.Empty;
                            newShaderFile.InsertRange(i, defines);

                            i += defines.Length;
                        }

                        if (newShaderFile[i].Contains("struct Varyings"))
                        {
                            while (newShaderFile[i].Trim() != "};")
                                i++;

                            newShaderFile.Insert(i, "float3 barycentric;");
                        }

                        if (newShaderFile[i].Contains("struct SurfaceDescriptionInputs"))
                        {
                            while (newShaderFile[i].Trim() != "};")
                                i++;

                            newShaderFile.Insert(i, "float3 barycentric;");
                        }

                        if (newShaderFile[i].Contains("struct PackedVaryings"))
                        {
                            int saveIndex = i;
                            int usedINTERP = -1;
                            while (newShaderFile[i].Trim() != "};")
                            {
                                if (newShaderFile[i].Contains(":") && newShaderFile[i].Contains("INTERP") && newShaderFile[i].Contains(";"))
                                {
                                    int index = newShaderFile[i].IndexOf("INTERP");
                                    if (index != -1)
                                    {
                                        string result = newShaderFile[i].Substring(index).Replace("INTERP", string.Empty).Replace(";", string.Empty).Trim();
                                        int.TryParse(result, out usedINTERP);
                                    }
                                }

                                i++;
                            }


                            //Insert here   - - - - - - - - - - - - - - -
                            //                                          |
                            //struct PackedVaryings                     |   i
                            //{                                         |   i + 1
                            //  float3 barycentric : INTERP8;     ← - - -   i + 2
                            //  float4 positionCS : SV_POSITION;

                            newShaderFile.Insert(saveIndex + 2, $"float3 barycentric : INTERP{usedINTERP + 1};");
                        }

                        if (newShaderFile[i].Contains("PackedVaryings PackVaryings (Varyings input)"))
                        {
                            while (newShaderFile[i].Trim().StartsWith("return ") == false)
                                i++;

                            newShaderFile.Insert(i, "output.barycentric = input.barycentric;");
                        }

                        if (newShaderFile[i].Contains("Varyings UnpackVaryings (PackedVaryings input)"))
                        {
                            while (newShaderFile[i].Trim().StartsWith("return ") == false)
                                i++;

                            newShaderFile.Insert(i, "output.barycentric = input.barycentric;");
                        }

                        if (newShaderFile[i].Contains("SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)"))
                        {
                            while (newShaderFile[i].Trim().StartsWith("return ") == false)
                                i++;

                            newShaderFile.Insert(i, "output.barycentric = input.barycentric;");
                        }

                        if (newShaderFile[i].Trim().StartsWith(methodName))
                        {
                            newShaderFile[i] = ReplaceInput(newShaderFile[i]);
                        }

                        if (newShaderFile[i].Contains("ENDHLSL"))
                        {
                            newShaderFile.InsertRange(i, hullAndDomain);

                            i += hullAndDomain.Length;
                        }
                    }
                }
            }
        }
        static void UpdateShaderHighDefinition(ref List<string> newShaderFile, Pass[] usedPass)
        {
            string[] hullAndDomain = GetHullAndDomainMethods();
            string[] defines = GetDefines();
            string[] fragInputs = GetFragInputs();


            Pass pass = Pass.Unknown;
            for (int i = 0; i < newShaderFile.Count; i++)
            {
                if (newShaderFile[i].Trim().StartsWith("//"))
                    continue;


                //Detect current shader pass
                if (newShaderFile[i].Contains("Name") == true)
                {
                    if (GetShaderPass(newShaderFile[i], out string passName))
                    {
                        switch (passName)
                        {
                            case "Forward": pass = Pass.HighDefinitionForward; break;
                            case "ForwardOnly": pass = Pass.HighDefinitionForwardOnly; break;
                            case "GBuffer": pass = Pass.HighDefinitionGBuffer; break;
                            case "TransparentDepthPrepass": pass = Pass.HighDefinitionTransparentDepthPrepass; break;
                            case "DepthOnly": pass = Pass.HighDefinitionDepthOnly; break;
                            case "DepthForwardOnly": pass = Pass.HighDefinitionDepthForwardOnly; break;
                            case "TransparentBackface": pass = Pass.HighDefinitionTransparentBackface; break;
                            case "TransparentDepthPostpass": pass = Pass.HighDefinitionTransparentDepthPostpass; break;
                            case "MotionVectors": pass = Pass.HighDefinitionMotionVectors; break;
                            case "DistortionVectors": pass = Pass.HighDefinitionDistortionVectors; break;
                            case "ShadowCaster": pass = Pass.HighDefinitionShadowCaster; break;
                            case "META": pass = Pass.HighDefinitionMETA; break;
                            case "FullScreenDebug": pass = Pass.HighDefinitionFullScreenDebug; break;

                            //Unsuported
                            case "ForwardDXR": pass = Pass.HighDefinitionForwardDXR; break;
                            case "GBufferDXR": pass = Pass.HighDefinitionGBufferDXR; break;
                            case "RayTracingPrepass": pass = Pass.HighDefinitionRayTracingPrepass; break;
                            case "IndirectDXR": pass = Pass.HighDefinitionIndirectDXR; break;
                            case "VisibilityDXR": pass = Pass.HighDefinitionVisibilityDXR; break;
                            case "PathTracingDXR": pass = Pass.HighDefinitionPathTracingDXR; break;
                            case "DebugDXR": pass = Pass.HighDefinitionDebugDXR; break;
                            case "SubSurfaceDXR": pass = Pass.HighDefinitionSubSurfaceDXR; break;

                            case "SceneSelectionPass": pass = Pass.SceneSelectionPass; break;
                            case "ScenePickingPass": pass = Pass.ScenePickingPass; break;

                            case "": break;

                            default:
                                {
                                    pass = Pass.Unknown;
                                    Log.Message(LogType.Error, $"Unsupported shader pass '{passName}'.");
                                }
                                break;
                        }
                    }
                }

                if (usedPass.Contains(pass))
                {
                    //Unsuported
                    if (pass == Pass.HighDefinitionForwardDXR ||
                        pass == Pass.HighDefinitionGBufferDXR ||
                        pass == Pass.HighDefinitionRayTracingPrepass ||
                        pass == Pass.HighDefinitionIndirectDXR ||
                        pass == Pass.HighDefinitionVisibilityDXR ||
                        pass == Pass.HighDefinitionPathTracingDXR ||
                        pass == Pass.HighDefinitionDebugDXR ||
                        pass == Pass.HighDefinitionSubSurfaceDXR)
                    {
                        //Disable 'fwidth' not supported by raytraycing
                        if (newShaderFile[i].TrimStart().StartsWith("void ") && newShaderFile[i].Contains(methodName))
                        {
                            while (newShaderFile[i].Contains("fwidth") == false)
                                i++;

                            newShaderFile[i] = newShaderFile[i].Replace("fwidth", string.Empty);
                        }
                    }
                    else
                    {
                        if (newShaderFile[i].Contains("#pragma ") && newShaderFile[i].Contains("target "))
                        {
                            string pragmaTarget = newShaderFile[i].Replace("#pragma ", string.Empty).Replace("target ", string.Empty).Trim();
                            float target;
                            if (float.TryParse(pragmaTarget, out target) == false)
                                target = 5.0f;

                            target = Mathf.Max(target, 5.0f);

                            newShaderFile[i] = "#pragma target " + target.ToString("0.0#");
                        }

                        if (newShaderFile[i].Contains("Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"))
                        {
                            newShaderFile[i] = string.Empty;

                            newShaderFile.InsertRange(i, fragInputs);

                            i += fragInputs.Length;
                        }

                        //Declar hull and domain
                        if (newShaderFile[i].Contains("#pragma ") && newShaderFile[i].Contains(" vertex ") && newShaderFile[i].ToLowerInvariant().Contains(" vert"))
                        {
                            newShaderFile[i] = string.Empty;
                            newShaderFile.InsertRange(i, defines);

                            i += defines.Length;
                        }

                        if (newShaderFile[i].Contains("struct VaryingsMeshToPS"))
                        {
                            while (newShaderFile[i].Trim() != "};")
                                i++;

                            newShaderFile.Insert(i, "float3 barycentric;");
                        }

                        if (newShaderFile[i].Contains("struct SurfaceDescriptionInputs"))
                        {
                            while (newShaderFile[i].Trim() != "};")
                                i++;

                            newShaderFile.Insert(i, "float3 barycentric;");
                        }

                        if (newShaderFile[i].Contains("struct PackedVaryingsMeshToPS"))
                        {
                            int saveIndex = i;
                            int usedINTERP = -1;
                            while (newShaderFile[i].Trim() != "};")
                            {
                                if (newShaderFile[i].Contains(":") && newShaderFile[i].Contains("INTERP") && newShaderFile[i].Contains(";"))
                                {
                                    int index = newShaderFile[i].IndexOf("INTERP");
                                    if (index != -1)
                                    {
                                        string result = newShaderFile[i].Substring(index).Replace("INTERP", string.Empty).Replace(";", string.Empty).Trim();
                                        int.TryParse(result, out usedINTERP);
                                    }
                                }

                                i++;
                            }


                            //Insert here   - - - - - - - - - - - - - - -
                            //                                          |
                            //struct PackedVaryings                     |   i
                            //{                                         |   i + 1
                            //  float3 barycentric : INTERP8;     ← - - -   i + 2
                            //  float4 positionCS : SV_POSITION;

                            newShaderFile.Insert(saveIndex + 2, $"float3 barycentric : INTERP{usedINTERP + 1};");
                        }

                        if (newShaderFile[i].Contains("PackedVaryingsMeshToPS PackVaryingsMeshToPS (VaryingsMeshToPS input)"))
                        {
                            while (newShaderFile[i].Trim().StartsWith("return ") == false)
                                i++;

                            newShaderFile.Insert(i, "output.barycentric = input.barycentric;");
                        }

                        if (newShaderFile[i].Contains("VaryingsMeshToPS UnpackVaryingsMeshToPS (PackedVaryingsMeshToPS input)"))
                        {
                            while (newShaderFile[i].Trim().StartsWith("return ") == false)
                                i++;

                            newShaderFile.Insert(i, "output.barycentric = input.barycentric;");
                        }

                        if (newShaderFile[i].Contains("FragInputs BuildFragInputs(VaryingsMeshToPS input)"))
                        {
                            while (newShaderFile[i].Trim().StartsWith("return ") == false)
                                i++;

                            newShaderFile.Insert(i, "output.barycentric = input.barycentric;");
                        }

                        if (newShaderFile[i].Contains("SurfaceDescriptionInputs FragInputsToSurfaceDescriptionInputs(FragInputs input, float3 viewWS)"))
                        {
                            while (newShaderFile[i].Trim().StartsWith("return ") == false)
                                i++;

                            newShaderFile.Insert(i, "output.barycentric = input.barycentric;");
                        }

                        if (newShaderFile[i].Trim().StartsWith(methodName))
                        {
                            newShaderFile[i] = ReplaceInput(newShaderFile[i]);
                        }

                        if (newShaderFile[i].Contains("ENDHLSL"))
                        {
                            newShaderFile.InsertRange(i, hullAndDomain);

                            i += hullAndDomain.Length;
                        }
                    }
                }
            }
        }

        static Pass[] GetPassesUsingWireframe(List<string> newShaderFile)
        {
            List<Pass> listPasses = new List<Pass>();

            EditorUtilities.RenderPipeline renderPipeline = EditorUtilities.GetCurrentRenderPipeline();

            Pass pass = Pass.Unknown;
            for (int i = 0; i < newShaderFile.Count; i++)
            {
                if (newShaderFile[i].Trim().StartsWith("//"))
                    continue;


                //Detect current shader pass
                if (newShaderFile[i].Contains("Name") == true)
                {
                    if (GetShaderPass(newShaderFile[i], out string passName))
                    {
                        switch (renderPipeline)
                        {
                            case EditorUtilities.RenderPipeline.BuiltIn:
                                {
                                    switch (passName)
                                    {
                                        case "BuiltInForward": pass = Pass.BuiltInForward; break;
                                        case "BuiltInForwardAdd": pass = Pass.BuiltInForwardAdd; break;
                                        case "BuiltInDeferred": pass = Pass.BuiltInDeferred; break;
                                        case "Pass": pass = Pass.BuiltInUnlitPass; break;
                                        case "DepthOnly": pass = Pass.BuiltInDepth; break;
                                        case "ShadowCaster": pass = Pass.BuiltInShadowCaster; break;
                                        case "Meta": pass = Pass.BuiltInMeta; break;
                                        case "SceneSelectionPass": pass = Pass.SceneSelectionPass; break;
                                        case "ScenePickingPass": pass = Pass.ScenePickingPass; break;


                                        case "": break;

                                        default:
                                            {
                                                pass = Pass.Unknown;
                                                Log.Message(LogType.Error, $"Unsupported shader pass '{passName}'.");
                                            }
                                            break;
                                    }
                                }
                                break;

                            case EditorUtilities.RenderPipeline.Universal:
                                {
                                    switch (passName)
                                    {
                                        case "UniversalForward": pass = Pass.UniversalForward; break;
                                        case "UniversalForwardOnly": pass = Pass.UniversalForwardOnly; break;
                                        case "GBuffer": pass = Pass.UniversalGBuffer; break;
                                        case "Pass": pass = Pass.UniversalPass; break;
                                        case "DepthOnly": pass = Pass.UniversalDepthOnly; break;
                                        case "DepthNormals": pass = Pass.UniversalDepthNormals; break;
                                        case "DepthNormalsOnly": pass = Pass.UniversalDepthNormalsOnly; break;
                                        case "MotionVectors": pass = Pass.UniversalMotionVectors; break;
                                        case "ShadowCaster": pass = Pass.UniversalShadowCaster; break;
                                        case "Meta": pass = Pass.UniversalMeta; break;
                                        case "Universal2D": pass = Pass.Universal2D; break;
                                        case "XRMotionVectors": pass = Pass.UniversalXRMotionVectors; break;
                                        case "SceneSelectionPass": pass = Pass.SceneSelectionPass; break;
                                        case "ScenePickingPass": pass = Pass.ScenePickingPass; break;


                                        case "": break;

                                        default:
                                            {
                                                pass = Pass.Unknown;
                                                Log.Message(LogType.Error, $"Unsupported shader pass '{passName}'.");
                                            }
                                            break;
                                    }
                                }
                                break;

                            case EditorUtilities.RenderPipeline.HighDefinition:
                                {
                                    switch (passName)
                                    {
                                        case "Forward": pass = Pass.HighDefinitionForward; break;
                                        case "ForwardOnly": pass = Pass.HighDefinitionForwardOnly; break;
                                        case "GBuffer": pass = Pass.HighDefinitionGBuffer; break;
                                        case "TransparentDepthPrepass": pass = Pass.HighDefinitionTransparentDepthPrepass; break;
                                        case "DepthOnly": pass = Pass.HighDefinitionDepthOnly; break;
                                        case "DepthForwardOnly": pass = Pass.HighDefinitionDepthForwardOnly; break;
                                        case "TransparentBackface": pass = Pass.HighDefinitionTransparentBackface; break;
                                        case "TransparentDepthPostpass": pass = Pass.HighDefinitionTransparentDepthPostpass; break;
                                        case "MotionVectors": pass = Pass.HighDefinitionMotionVectors; break;
                                        case "DistortionVectors": pass = Pass.HighDefinitionDistortionVectors; break;
                                        case "ShadowCaster": pass = Pass.HighDefinitionShadowCaster; break;
                                        case "META": pass = Pass.HighDefinitionMETA; break;
                                        case "FullScreenDebug": pass = Pass.HighDefinitionFullScreenDebug; break;
                                        case "ForwardDXR": pass = Pass.HighDefinitionForwardDXR; break;
                                        case "GBufferDXR": pass = Pass.HighDefinitionGBufferDXR; break;
                                        case "RayTracingPrepass": pass = Pass.HighDefinitionRayTracingPrepass; break;
                                        case "IndirectDXR": pass = Pass.HighDefinitionIndirectDXR; break;
                                        case "VisibilityDXR": pass = Pass.HighDefinitionVisibilityDXR; break;
                                        case "PathTracingDXR": pass = Pass.HighDefinitionPathTracingDXR; break;
                                        case "DebugDXR": pass = Pass.HighDefinitionDebugDXR; break;
                                        case "SubSurfaceDXR": pass = Pass.HighDefinitionSubSurfaceDXR; break;

                                        case "SceneSelectionPass": pass = Pass.SceneSelectionPass; break;
                                        case "ScenePickingPass": pass = Pass.ScenePickingPass; break;


                                        case "": break;

                                        default:
                                            {
                                                pass = Pass.Unknown;
                                                Log.Message(LogType.Error, $"Unsupported shader pass '{passName}'.");
                                            }
                                            break;
                                    }
                                }
                                break;

                            default:
                                break;
                        }

                    }
                }

                if (pass != Pass.Unknown)
                {
                    while (newShaderFile[i].Trim() != "ENDHLSL")
                    {
                        if (newShaderFile[i].Contains(methodName))
                        {
                            if (listPasses.Contains(pass) == false)
                                listPasses.Add(pass);

                            break;
                        }

                        if (i++ >= newShaderFile.Count - 1)
                            break;
                    }

                    pass = Pass.Unknown;
                }
            }


            return listPasses.ToArray();
        }
        static string ReplaceInput(string line)
        {
            //Replacing uv3 -------------
            //                      |   |
            //                      |   |
            //                      ↓   ↓
            //RenderWireframe_float(IN.uv3.xyz, _Property_6393ad3b4c074883a763e9b3461e9aea_Out_0_Float.xxx, 

            int firstDot = line.IndexOf('.');
            int secondDot = line.IndexOf('.', firstDot + 1);

            string result = line.Substring(0, firstDot + 1) +
                            "barycentric" +
                            line.Substring(secondDot);

            return result;
        }
        static bool IsShaderGraphSuitable(List<string> newShaderFile)
        {
            if (newShaderFile == null || newShaderFile.Count < 10)
                return false;


            GUIContent[] unsupportedShaderGraphTargets = new GUIContent[]
            {
                new GUIContent("BuiltInCanvasSubTarget", "Canvas"),

                new GUIContent("UniversalSpriteUnlitSubTarget", "Sprite"),
                new GUIContent("UniversalSpriteLitSubTarget", "Sprite"),
                new GUIContent("UniversalSpriteCustomLitSubTarget", "Sprite"),
                new GUIContent("UniversalDecalSubTarget", "Decal"),
                new GUIContent("UniversalFullscreenSubTarget", "Fullscreen"),
                new GUIContent("UniversalSixWaySubTarget", "Six-way Smoke Lit"),
                new GUIContent("UniversalCanvasSubTarget", "Canvas"),

                new GUIContent("HDSixWaySubTarget", "Six-way Smoke Lit"),
                new GUIContent("DecalSubTarget", "Decal"),
                new GUIContent("FogVolumeSubTarget", "Fog Volume"),
                new GUIContent("HDFullscreenSubTarget", "Fullscreen"),
                new GUIContent("HDCanvasSubTarget", "Canvas"),
                new GUIContent("WaterSubTarget", "Water"),
                new GUIContent("WaterDecalSubTarget", "Water Decal")
            };

            GUIContent[] unsupportedShaderPass = new GUIContent[]
            {
                new GUIContent("Default", "UI"),

                new GUIContent("SpriteLit", "Sprite"),
                new GUIContent("SpriteUnlit", "Sprite"),
                new GUIContent("SpriteNormal", "Sprite"),
                new GUIContent("SpriteForward", "Sprite"),
                new GUIContent("DBufferProjector", "Decal"),
                new GUIContent("DecalScreenSpaceProjector", "Decal"),
                new GUIContent("DecalGBufferProjector", "Decal"),
                new GUIContent("DBufferMesh", "Decal"),
                new GUIContent("DecalScreenSpaceMesh", "Decal"),
                new GUIContent("DecalGBufferMesh", "Decal"),

                new GUIContent("PBRSkycubemap", "Physically Based Sky"),
                new GUIContent("PBRSky", "Physically Based Sky")
            };


            foreach (var line in newShaderFile)
            {
                if (line.Trim().StartsWith("//"))
                    continue;


                if (GetShaderGraphTargetId(line, out string shaderGraphTargetId))
                {
                    for (int i = 0; i < unsupportedShaderGraphTargets.Length; i++)
                    {
                        if (shaderGraphTargetId == unsupportedShaderGraphTargets[i].text)
                        {
                            Log.Message(LogType.Error, $"{unsupportedShaderGraphTargets[i].tooltip} shader is not support.");
                            return false;
                        }
                    }
                }

                if (GetShaderPass(line, out string shaderPass))
                {
                    for (int i = 0; i < unsupportedShaderPass.Length; i++)
                    {
                        if (shaderPass == unsupportedShaderPass[i].text)
                        {
                            Log.Message(LogType.Error, $"{unsupportedShaderPass[i].tooltip} shader is not support.");
                            return false;
                        }
                    }
                }

                if (line.Contains("#pragma ") && line.Contains("hull "))
                {
                    Log.Message(LogType.Error, "Tessellation shader is not support.");
                    return false;
                }
            }

            return true;
        }
        static bool GetShaderPass(string line, out string passName)
        {
            //Name "ShadowCaster"

            line = line.Trim();
            if (line.StartsWith("Name") && line.EndsWith("\""))
            {
                line = line.Replace("Name", string.Empty).Replace("\"", string.Empty).Replace(" ", string.Empty).Trim();
                if (string.IsNullOrEmpty(line) == false)
                {
                    passName = line;
                    return true;
                }
            }

            passName = string.Empty;
            return false;
        }
        static bool GetShaderGraphTargetId(string line, out string shaderGraphTarget)
        {
            //"ShaderGraphTargetId"="HDSixWaySubTarget"

            line = line.Trim();
            if (line.StartsWith("\"") && line.Contains("ShaderGraphTargetId") && line.Contains("="))
            {
                line = line.Replace("ShaderGraphTargetId", string.Empty).Replace("=", string.Empty).Replace("\"", string.Empty).Trim();
                if (string.IsNullOrEmpty(line) == false)
                {
                    shaderGraphTarget = line;
                    return true;
                }
            }

            shaderGraphTarget = string.Empty;
            return false;
        }
        static string[] GetHullAndDomainMethods()
        {
            string hullAndDomainFilePath = Path.Combine(EditorUtilities.GetThisAssetProjectPath(), "Editor", "Wireframe Shader Generator", "Templates", "HullAndDomain.txt");
            string[] hullAndDomain = File.ReadAllLines(hullAndDomainFilePath);


            switch (EditorUtilities.GetCurrentRenderPipeline())
            {
                case EditorUtilities.RenderPipeline.BuiltIn:
                    for (int i = 0; i < hullAndDomain.Length; i++)
                    {
                        hullAndDomain[i] = hullAndDomain[i].Replace("##Attributes##", "Attributes");
                        hullAndDomain[i] = hullAndDomain[i].Replace("##PackedVaryings##", "PackedVaryings");
                        hullAndDomain[i] = hullAndDomain[i].Replace("##vert##", "vert");
                        hullAndDomain[i] = hullAndDomain[i].Replace("##pv.barycentric##", "pv.barycentric");
                    }
                    break;

                case EditorUtilities.RenderPipeline.Universal:
                    {
                        for (int i = 0; i < hullAndDomain.Length; i++)
                        {
                            hullAndDomain[i] = hullAndDomain[i].Replace("##Attributes##", "Attributes");
                            hullAndDomain[i] = hullAndDomain[i].Replace("##PackedVaryings##", "PackedVaryings");
                            hullAndDomain[i] = hullAndDomain[i].Replace("##vert##", "vert");
                            hullAndDomain[i] = hullAndDomain[i].Replace("##pv.barycentric##", "pv.barycentric");
                        }
                    }
                    break;

                case EditorUtilities.RenderPipeline.HighDefinition:
                    {
                        for (int i = 0; i < hullAndDomain.Length; i++)
                        {
                            hullAndDomain[i] = hullAndDomain[i].Replace("##Attributes##", "AttributesMesh");
                            hullAndDomain[i] = hullAndDomain[i].Replace("##PackedVaryings##", "PackedVaryingsType");
                            hullAndDomain[i] = hullAndDomain[i].Replace("##vert##", "Vert");
                            hullAndDomain[i] = hullAndDomain[i].Replace("##pv.barycentric##", "pv.vmesh.barycentric");
                        }
                    }
                    break;

                default:
                    break;
            }

            return hullAndDomain;
        }
        static string[] GetDefines()
        {
            List<string> defines = new List<string>();

            defines.Add("#pragma require tessellation");
            defines.Add("#pragma vertex Vertex");
            defines.Add("#pragma hull Hull");
            defines.Add("#pragma domain Domain");

            defines.Add("#define _WIREFRAME_IS_DYNAMIC");
            defines.Add("#pragma shader_feature_local _ _WIREFRAME_SHADER_SHAPE_QUAD");
            defines.Add("#pragma shader_feature_local _ _WIREFRAME_SHADER_STYLE_NORMALIZED _WIREFRAME_SHADER_STYLE_SCREEN_SPACE");

            switch (EditorUtilities.GetCurrentRenderPipeline())
            {
                case EditorUtilities.RenderPipeline.BuiltIn: defines.Add("#define RENDER_PIPELINE_BUILTIN"); break;
                case EditorUtilities.RenderPipeline.Universal: defines.Add("#define RENDER_PIPELINE_UNIVERSAL"); break;
                case EditorUtilities.RenderPipeline.HighDefinition: defines.Add("#define RENDER_PIPELINE_HIGH_DEFINITION"); break;

                default:
                    break;
            }


            return defines.ToArray();
        }
        static string[] GetFragInputs()
        {
            string fragInputsFilePath = Path.Combine(EditorUtilities.GetThisAssetProjectPath(), "Editor", "Wireframe Shader Generator", "Templates", "FragInputs.txt");
            string[] fragInputs = File.ReadAllLines(fragInputsFilePath);

            return fragInputs;
        }

        static string GetShaderGraphHLSLCode(string shaderGraphAssetPath)
        {
            AssetImporter importer = AssetImporter.GetAtPath(shaderGraphAssetPath);
            string assetName = Path.GetFileNameWithoutExtension(importer.assetPath);


            var textGraph = File.ReadAllText(importer.assetPath, Encoding.UTF8);
            var graphObject = ScriptableObject.CreateInstance<GraphObject>();
            graphObject.hideFlags = HideFlags.HideAndDontSave;
            bool isSubGraph;
            var extension = Path.GetExtension(importer.assetPath).Replace(".", "");
            switch (extension)
            {
                case ShaderGraphImporter.Extension:
                    isSubGraph = false;
                    break;
                case ShaderGraphImporter.LegacyExtension:
                    isSubGraph = false;
                    break;
                case ShaderSubGraphImporter.Extension:
                    isSubGraph = true;
                    break;
                default:
                    throw new Exception($"Invalid file extension {extension}");
            }
            var assetGuid = AssetDatabase.AssetPathToGUID(importer.assetPath);
            graphObject.graph = new GraphData
            {
                assetGuid = assetGuid,
                isSubGraph = isSubGraph,
                messageManager = null
            };
            MultiJson.Deserialize(graphObject.graph, textGraph);
            graphObject.graph.OnEnable();
            graphObject.graph.ValidateGraph();

            var generator = new Generator(graphObject.graph, null, GenerationMode.ForReals, assetName, null);

            return generator.generatedShader;
        }
        static string CreateShaderAssetFile(List<string> newShaderFile, string shaderGraphAssetPath, Shader targetShader)
        {
            string savePath = targetShader == null ? GetGeneratedShaderPath(shaderGraphAssetPath) : AssetDatabase.GetAssetPath(targetShader);

            string[] normalized = newShaderFile.Select(s => s.Replace("\r\n", "\n").Replace("\r", "\n").Replace("\n", Environment.NewLine)).ToArray();

            File.WriteAllLines(savePath, normalized);

            AssetDatabase.Refresh(ImportAssetOptions.ForceUpdate);

            UnityEditor.EditorGUIUtility.PingObject(AssetDatabase.LoadAssetAtPath(savePath, typeof(Shader)));


            return savePath;
        }
        static internal string GetGeneratedShaderPath(string shaderGraphAssetPath)
        {
            return Path.Combine(Path.GetDirectoryName(shaderGraphAssetPath), Path.GetFileNameWithoutExtension(shaderGraphAssetPath) + $"{nameSuffix}.shader");
        }
        static string SaveSourceShaderGraph(string shaderGraphAssetPath)
        {
            string body = Environment.NewLine;
            body += "/*ShaderGraphBody_Begin";
            body += Environment.NewLine;
            body += File.ReadAllText(shaderGraphAssetPath);
            body += Environment.NewLine;
            body += "ShaderGraphBody_End*/";

            return body;
        }
        static bool ReadSourceShaderGraph(string shaderAssetPath, out string body)
        {
            body = string.Empty;

            string text = File.ReadAllText(shaderAssetPath);

            Match match = Regex.Match(
                text,
                @"ShaderGraphBody_Begin\s*(\{.*?\})\s*ShaderGraphBody_End",
                RegexOptions.Singleline);

            if (match.Success)
            {
                body = match.Groups[1].Value;

                return string.IsNullOrEmpty(body) ? false : true;
            }


            return false;
        }
    }
}
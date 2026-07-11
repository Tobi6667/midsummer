// Dynamic Wireframe Shader <https://u3d.as/3WyY>
// Copyright (c) Amazing Assets <https://amazingassets.world>

using System;
using System.IO;
using System.Reflection;

using UnityEngine;
using UnityEditor;


namespace AmazingAssets.DynamicWireframeShaderGenerator.Editor
{
    static internal class EditorUtilities
    {
        public enum RenderPipeline { BuiltIn = 0, Universal = 1, HighDefinition = 2, Undefined }

        static string thisAssetPath = string.Empty;


        static public RenderPipeline GetCurrentRenderPipeline()
        {
#if UNITY_6000_0_OR_NEWER
            if (UnityEngine.Rendering.GraphicsSettings.defaultRenderPipeline == null && UnityEngine.QualitySettings.renderPipeline == null)
                return RenderPipeline.BuiltIn;
            else
            {
                string currentType = UnityEngine.Rendering.GraphicsSettings.defaultRenderPipeline == null ? UnityEngine.QualitySettings.renderPipeline.GetType().ToString() :
                                                                                                      UnityEngine.Rendering.GraphicsSettings.defaultRenderPipeline.GetType().ToString();

                string parentType = UnityEngine.Rendering.GraphicsSettings.defaultRenderPipeline == null ? UnityEngine.QualitySettings.renderPipeline.GetType().GetTypeInfo().BaseType.ToString() :
                                                                                                           UnityEngine.Rendering.GraphicsSettings.defaultRenderPipeline.GetType().GetTypeInfo().BaseType.ToString();
#else
            if (UnityEngine.Rendering.GraphicsSettings.renderPipelineAsset == null && UnityEngine.QualitySettings.renderPipeline == null)
                return RenderPipeline.BuiltIn;
            else
            {
                string currentType = UnityEngine.Rendering.GraphicsSettings.renderPipelineAsset == null ? UnityEngine.QualitySettings.renderPipeline.GetType().ToString() :
                                                                                                    UnityEngine.Rendering.GraphicsSettings.renderPipelineAsset.GetType().ToString();

                string parentType = UnityEngine.Rendering.GraphicsSettings.renderPipelineAsset == null ? UnityEngine.QualitySettings.renderPipeline.GetType().GetTypeInfo().BaseType.ToString() :
                                                                                                         UnityEngine.Rendering.GraphicsSettings.renderPipelineAsset.GetType().GetTypeInfo().BaseType.ToString();
#endif

                if (currentType.Contains("UnityEngine.Rendering.Universal.") || parentType.Contains("UnityEngine.Rendering.Universal."))
                    return RenderPipeline.Universal;

                else if (currentType.Contains("UnityEngine.Rendering.HighDefinition.") || parentType.Contains("UnityEngine.Rendering.HighDefinition."))
                    return RenderPipeline.HighDefinition;


                Log.Message(LogType.Error, "Undefined Render Pipeline '" + currentType + "'");
                return RenderPipeline.Undefined;
            }
        }


        static internal string GetThisAssetProjectPath()
        {
            if (string.IsNullOrEmpty(thisAssetPath))
            {
                string fileName = $"AmazingAssets.{About.name.RemoveWhiteSpace()}.Editor";

                string[] assets = AssetDatabase.FindAssets(fileName, null);
                if (assets != null && assets.Length > 0)
                {
                    string currentFilePath = AssetDatabase.GUIDToAssetPath(assets[0]);
                    thisAssetPath = Path.GetDirectoryName(Path.GetDirectoryName(currentFilePath));
                }
                else
                {
                    Log.Message(LogType.Error, $"Cannot detect '{About.name}' editor path.");
                }
            }
            return thisAssetPath;
        }
        static internal string GetAssetTempFolder()
        {
            return Path.Combine("Assets", $"_{About.name}_TEMP_");
        }
        static internal void DeleteTempDirectory()
        {
            string tempFolder = GetAssetTempFolder();

            if (Directory.Exists(tempFolder))
                FileUtil.DeleteFileOrDirectory(tempFolder);

            string metaFile = tempFolder + ".meta";
            if (File.Exists(metaFile))
                File.Delete(metaFile);
        }
        static string RemoveWhiteSpace(this string str)
        {
            return string.Join("", str.Split(default(string[]), StringSplitOptions.RemoveEmptyEntries));
        }

        static public string ConvertPathToProjectRelative(string path)
        {
            //Before using this method, make sure path 'is' project relative
            if (path.IndexOf("Assets") == 0)
                return NormalizePath(path);
            else
                return NormalizePath("Assets" + path.Substring(Application.dataPath.Length));
        }
        static public bool IsPathProjectRelative(string path)
        {
            if (string.IsNullOrWhiteSpace(path))
                return false;


            if (path.IndexOf("Assets") == 0)
                return true;


            if (File.Exists(path) == false && Directory.Exists(path) == false)
                return false;


            return NormalizePath(path).Contains(NormalizePath(Application.dataPath));
        }
        static public string NormalizePath(string path)
        {
            if (string.IsNullOrWhiteSpace(path))
                return path;
            else
                return path.Replace("//", "/").Replace("\\\\", "/").Replace("\\", "/");
        }
        static public bool IsPathWithinStreamingAssetsFolder(string path)
        {
            if (string.IsNullOrWhiteSpace(path) || string.IsNullOrWhiteSpace(Application.streamingAssetsPath))
                return false;

            if (IsPathProjectRelative(path) &&
               IsPathProjectRelative(Application.streamingAssetsPath) &&
               ConvertPathToProjectRelative(path).Contains(ConvertPathToProjectRelative(Application.streamingAssetsPath)))
            {
                return true;
            }

            return false;
        }


        static public void PingObject(string assetPath)
        {
            assetPath = ConvertPathToProjectRelative(assetPath);


            // Load object
            UnityEngine.Object obj = AssetDatabase.LoadAssetAtPath(assetPath, typeof(UnityEngine.Object));


            if (obj == null)
            {
                assetPath = Path.GetDirectoryName(assetPath);
                obj = AssetDatabase.LoadAssetAtPath(assetPath, typeof(UnityEngine.Object));
            }


            if (obj != null)
                PingObject(obj);
        }
        static public void PingObject(UnityEngine.Object obj)
        {
            if (obj != null)
            {
                // Select the object in the project folder
                Selection.activeObject = obj;

                // Also flash the folder yellow to highlight it
                UnityEditor.EditorGUIUtility.PingObject(obj);
            }
        }

    }
}

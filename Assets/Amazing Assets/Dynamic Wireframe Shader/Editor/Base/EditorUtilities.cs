// Dynamic Wireframe Shader <https://u3d.as/3WyY>
// Copyright (c) Amazing Assets <https://amazingassets.world>

using System;
using System.IO;
using System.Linq;
using System.Text;
using System.Reflection;
using System.Diagnostics;
using System.Collections.Generic;
using System.Text.RegularExpressions;

using UnityEngine;
using UnityEditor;
using UnityEditor.PackageManager;
using UnityEditor.PackageManager.Requests;


namespace AmazingAssets.DynamicWireframeShader.Editor
{
    static internal class EditorUtilities
    {
        public class Enum
        {
            public enum RenderPipeline { BuiltIn = 0, Universal = 1, HighDefinition = 2, Undefined }
        }

        static string thisAssetPath = string.Empty;
        static public char[] invalidFileNameCharachters = Path.GetInvalidFileNameChars();


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
                    Log.Message(LogType.Error, "Cannot detect 'This Asset' path.");
                }
            }
            return thisAssetPath;
        }
        static internal string GetAssetTempFolder()
        {
            return Path.Combine("Assets", $"_{About.name}_TEMP_");
        }
        static public Enum.RenderPipeline GetCurrentRenderPipeline()
        {
#if UNITY_6000_0_OR_NEWER
            if (UnityEngine.Rendering.GraphicsSettings.defaultRenderPipeline == null && UnityEngine.QualitySettings.renderPipeline == null)
                return Enum.RenderPipeline.BuiltIn;
            else
            {
                string currentType = UnityEngine.Rendering.GraphicsSettings.defaultRenderPipeline == null ? UnityEngine.QualitySettings.renderPipeline.GetType().ToString() :
                                                                                                      UnityEngine.Rendering.GraphicsSettings.defaultRenderPipeline.GetType().ToString();

                string parentType = UnityEngine.Rendering.GraphicsSettings.defaultRenderPipeline == null ? UnityEngine.QualitySettings.renderPipeline.GetType().GetTypeInfo().BaseType.ToString() :
                                                                                                           UnityEngine.Rendering.GraphicsSettings.defaultRenderPipeline.GetType().GetTypeInfo().BaseType.ToString();
#else
            if (UnityEngine.Rendering.GraphicsSettings.renderPipelineAsset == null && UnityEngine.QualitySettings.renderPipeline == null)
                return Enum.RenderPipeline.BuiltIn;
            else
            {
                string currentType = UnityEngine.Rendering.GraphicsSettings.renderPipelineAsset == null ? UnityEngine.QualitySettings.renderPipeline.GetType().ToString() :
                                                                                                    UnityEngine.Rendering.GraphicsSettings.renderPipelineAsset.GetType().ToString();

                string parentType = UnityEngine.Rendering.GraphicsSettings.renderPipelineAsset == null ? UnityEngine.QualitySettings.renderPipeline.GetType().GetTypeInfo().BaseType.ToString() :
                                                                                                         UnityEngine.Rendering.GraphicsSettings.renderPipelineAsset.GetType().GetTypeInfo().BaseType.ToString();
#endif

                if (currentType.Contains("UnityEngine.Rendering.Universal.") || parentType.Contains("UnityEngine.Rendering.Universal."))
                    return Enum.RenderPipeline.Universal;

                else if (currentType.Contains("UnityEngine.Rendering.HighDefinition.") || parentType.Contains("UnityEngine.Rendering.HighDefinition."))
                    return Enum.RenderPipeline.HighDefinition;


                Log.Message(LogType.Error, "Undefined Render Pipeline '" + currentType + "'");
                return Enum.RenderPipeline.Undefined;
            }
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


            if (Directory.Exists(path) == false)
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


        static public void SelectFile(string filePath)
        {
            if (System.IO.Path.IsPathRooted(filePath))
            {
                filePath = filePath.Replace("/", Path.DirectorySeparatorChar.ToString()).Replace("\\", Path.DirectorySeparatorChar.ToString());


                if (File.Exists(filePath))
                {
                    string args = string.Format("/e, /select, \"{0}\"", filePath);

                    System.Diagnostics.ProcessStartInfo info = new System.Diagnostics.ProcessStartInfo();
                    info.FileName = "explorer";
                    info.Arguments = args;
                    System.Diagnostics.Process.Start(info);
                }
            }
            else
            {
                PingObject(filePath);
            }
        }
        static public void OpenFolder(string folderPath)
        {
            if (string.IsNullOrEmpty(folderPath) == false && Directory.Exists(folderPath))
            {
                if (folderPath.StartsWith("Assets"))
                    folderPath = Path.Combine(Application.dataPath.Substring(0, Application.dataPath.LastIndexOf("Assets")), folderPath);

                Process.Start(folderPath);
            }
        }

        static public void PingObject(string assetPath)
        {
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


        public static bool IsFileInProject(string fileName, string extension)
        {
            return AssetDatabase.FindAssets(fileName, null).Select(c => AssetDatabase.GUIDToAssetPath(c)).Where(c => Path.GetExtension(c) == extension).Count() > 0;
        }
        public static bool IsPackageInstalled(string packageId)
        {
            if (!File.Exists("Packages/manifest.json"))
                return false;

            string jsonText = File.ReadAllText("Packages/manifest.json");
            return jsonText.Contains(packageId);
        }
        public static void InstallPackageFromPackageManager(string packageName)
        {
            AddRequest request = Client.Add(packageName);
            while (!request.IsCompleted)
            {
                // Optionally add some UI feedback here while waiting for the installation
            }

            if (request.Status == StatusCode.Success)
            {
                Log.Message(LogType.Log, $"{packageName} installed successfully!");
            }
            else
            {
                Log.Message(LogType.Error, $"Failed to install {packageName}: {request.Error.message}");
            }
        }
        public static bool IsAssetInProject(string fileName, string extension)
        {
            return AssetDatabase.FindAssets(fileName, null).Select(c => AssetDatabase.GUIDToAssetPath(c)).Where(c => Path.GetExtension(c) == extension).Count() > 0;
        }
        public static void ImportExampleScenesPackage(Enum.RenderPipeline renderPipeline)
        {
            string packagePath = string.Empty;
            switch (renderPipeline)
            {
                case Enum.RenderPipeline.BuiltIn: packagePath = Path.Combine(EditorUtilities.GetThisAssetProjectPath(), "Packages", "Example Scenes (Built-In).unitypackage"); break;
                case Enum.RenderPipeline.Universal: packagePath = Path.Combine(EditorUtilities.GetThisAssetProjectPath(), "Packages", "Example Scenes (Universal).unitypackage"); break;
                case Enum.RenderPipeline.HighDefinition: packagePath = Path.Combine(EditorUtilities.GetThisAssetProjectPath(), "Packages", "Example Scenes (High Definition).unitypackage"); break;

                default:
                    break;
            }

            if (File.Exists(packagePath))
            {
                string packagePostProcessing = "com.unity.postprocessing";
                bool packagePostProcessingIsInstalled = EditorUtilities.IsPackageInstalled(packagePostProcessing);

                if (GetCurrentRenderPipeline() == Enum.RenderPipeline.Universal ||
                    GetCurrentRenderPipeline() == Enum.RenderPipeline.HighDefinition)
                    packagePostProcessingIsInstalled = true;


                if (packagePostProcessingIsInstalled)
                {
                    AssetDatabase.ImportPackage(packagePath, true);
                }
                else
                {
                    string message = "This Asset Package has Unity Package Manager dependencies:\n\n";
                    if (packagePostProcessingIsInstalled == false) message += $"{packagePostProcessing}\n";

                    int state = EditorUtility.DisplayDialogComplex("Warning", message, "Install/Upgrade", "Skip", "Cancel");
                    switch (state)
                    {
                        case 0:
                            {
                                if (packagePostProcessingIsInstalled == false)
                                    EditorUtilities.InstallPackageFromPackageManager(packagePostProcessing);


                                AssetDatabase.ImportPackage(packagePath, true);
                            }
                            break;

                        case 1:
                            {
                                AssetDatabase.ImportPackage(packagePath, true);
                            }
                            break;

                        default:
                            break;
                    }
                }

                AssetDatabase.Refresh();
            }
            else
                Log.Message(LogType.Error, $"'{Path.GetFileNameWithoutExtension(packagePath)}' package is missing.");
        }
        public static void ImportShadersPackage(Enum.RenderPipeline renderPipeline)
        {
            string packagePath = string.Empty;
            switch (renderPipeline)
            {
                case Enum.RenderPipeline.BuiltIn: packagePath = Path.Combine(EditorUtilities.GetThisAssetProjectPath(), "Packages", "Shaders (Built-In).unitypackage"); break;
                case Enum.RenderPipeline.Universal: packagePath = Path.Combine(EditorUtilities.GetThisAssetProjectPath(), "Packages", "Shaders (Universal).unitypackage"); break;
                case Enum.RenderPipeline.HighDefinition: packagePath = Path.Combine(EditorUtilities.GetThisAssetProjectPath(), "Packages", "Shaders (High Definition).unitypackage"); break;

                default:
                    break;
            }

            if (File.Exists(packagePath))
            {
                string packageShadergraph = "com.unity.shadergraph";
                bool packageShadergraphIsInstalled = EditorUtilities.IsPackageInstalled(packageShadergraph);
                if (GetCurrentRenderPipeline() == Enum.RenderPipeline.Universal || GetCurrentRenderPipeline() == Enum.RenderPipeline.HighDefinition)
                    packageShadergraphIsInstalled = true;


                if (packageShadergraphIsInstalled)
                {
                    AssetDatabase.ImportPackage(packagePath, true);
                }
                else
                {
                    string message = "Required packages are missing:\n\n";
                    if (packageShadergraphIsInstalled == false) message += $"{packageShadergraph}\n";

                    int state = EditorUtility.DisplayDialogComplex("Import Shaders", message, "Import packages and shader", "Import only shaders", "Cancel");
                    switch (state)
                    {
                        case 0:
                            {
                                if (packageShadergraphIsInstalled == false)
                                    EditorUtilities.InstallPackageFromPackageManager(packageShadergraph);


                                AssetDatabase.ImportPackage(packagePath, true);
                            }
                            break;

                        case 1:
                            {
                                AssetDatabase.ImportPackage(packagePath, true);
                            }
                            break;

                        default:
                            break;
                    }
                }

                AssetDatabase.Refresh();
            }
            else
                Log.Message(LogType.Error, "Shaders package is missing.");
        }


        static public List<Shader> GetAllSceneShaders()
        {
            List<Shader> allShaders = new List<Shader>();
            foreach (var rootGameObject in UnityEngine.SceneManagement.SceneManager.GetActiveScene().GetRootGameObjects())
            {
                List<Material> gameObjectMaterials = GetGameObjectMaterials(rootGameObject, null, allShaders);
                foreach (var material in gameObjectMaterials)
                {
                    if (material != null && material.shader != null && allShaders.Contains(material.shader) == false)
                        allShaders.Add(material.shader);
                }
            }

            return allShaders;
        }
        static public List<Material> GetAllSceneMaterials(List<Material> exceptMaterials = null, List<Shader> exceptShaders = null)
        {
            List<Material> allMaterials = new List<Material>();
            foreach (var rootGameObject in UnityEngine.SceneManagement.SceneManager.GetActiveScene().GetRootGameObjects())
            {
                List<Material> gameObjectMaterials = GetGameObjectMaterials(rootGameObject, allMaterials, exceptShaders);
                if (gameObjectMaterials.Count > 0)
                    allMaterials.AddRange(gameObjectMaterials);
            }

            if (exceptMaterials != null)
                return allMaterials.Except(exceptMaterials).ToList();
            else
                return allMaterials;
        }
        static List<Material> GetGameObjectMaterials(GameObject gameObject, List<Material> exceptMaterials = null, List<Shader> exceptShaders = null)
        {
            List<Material> materials = new List<Material>();

            if (gameObject != null)
            {
                foreach (var renderer in gameObject.GetComponentsInChildren<Renderer>(true))
                {
                    if (renderer != null && renderer.sharedMaterials != null && renderer.sharedMaterials.Length > 0)
                    {
                        foreach (var material in renderer.sharedMaterials)
                        {
                            if (material != null && material.shader != null && materials.Contains(material) == false &&
                                (exceptMaterials == null || exceptMaterials.Contains(material) == false) &&
                                (exceptShaders == null || exceptShaders.Contains(material.shader) == false))
                            {
                                materials.Add(material);
                            }
                        }
                    }
                }
            }

            return materials;
        }
        static public List<Material> GetObjectMaterials(UnityEngine.Object obj, List<Material> exceptMaterials = null, List<Shader> exceptShaders = null)
        {
            List<Material> materials = new List<Material>();

            if (obj != null)
            {
                if (obj is Material)
                {
                    Material material = (Material)obj;
                    if (material != null &&
                        material.shader != null &&
                        (exceptMaterials == null || exceptMaterials.Contains(material) == false) &&
                        (exceptShaders == null || exceptShaders.Contains(material.shader) == false))
                    {
                        materials.Add(material);
                    }
                }
                else if (obj is GameObject)
                {
                    List<Material> gameObjectMaterial = GetGameObjectMaterials(obj as GameObject, exceptMaterials, exceptShaders);
                    if (gameObjectMaterial.Count > 0)
                        materials.AddRange(gameObjectMaterial);
                }
                else
                {
                    //May be it is a folder ?

                    string dropPath = AssetDatabase.GetAssetPath(obj);
                    if (string.IsNullOrEmpty(dropPath) == false && string.IsNullOrEmpty(Path.GetExtension(dropPath)))
                    {
                        string[] guids = AssetDatabase.FindAssets("t:Material", new string[] { dropPath });
                        for (int i = 0; i < guids.Length; i++)
                        {
                            string path = AssetDatabase.GUIDToAssetPath(guids[i]);

                            if (guids.Length > 20)
                                EditorUtility.DisplayProgressBar("Loading materials", path, (float)i / guids.Length);

                            Material mat = AssetDatabase.LoadAssetAtPath<Material>(path);
                            if (mat != null)
                                materials.Add(mat);
                        }

                        EditorUtility.ClearProgressBar();
                    }
                }
            }

            return materials;
        }
        static public List<Material> GetSelectionMaterials()
        {
            if (Selection.objects == null || Selection.objects.Length == 0)
                return null;

            List<Material> materials = new List<Material>();

            foreach (var obj in Selection.objects)
            {
                materials.AddRange(GetObjectMaterials(obj));
            }

            materials = materials.Distinct().ToList();

            return materials;
        }
    }
}
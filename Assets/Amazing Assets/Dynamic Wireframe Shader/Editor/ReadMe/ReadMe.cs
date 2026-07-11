// Dynamic Wireframe Shader <https://u3d.as/3WyY>
// Copyright (c) Amazing Assets <https://amazingassets.world>

using System.IO;

using UnityEditor;
using UnityEngine;


namespace AmazingAssets.DynamicWireframeShader.Editor
{
    //[CreateAssetMenuAttribute(fileName = "ReadMe", menuName = "Amazing Assets/Dynamic Wireframe Shader/ReadMe")]
    public class ReadMe : ScriptableObject
    {

    }

    class ReadMePostprocessor : AssetPostprocessor
    {
        // Increment the version number, when the AssetPostProcessors code/behavior is changed
        static readonly uint k_Version = 0;
        public override uint GetVersion() { return k_Version; }

        static void OnPostprocessAllAssets(string[] importedAssets, string[] deletedAssets, string[] movedAssets, string[] movedFromAssetPaths, bool didDomainReload)
        {
            foreach (string str in importedAssets)
            {
                if (str.Contains($"AmazingAssets.{About.name.Replace(" ", string.Empty)}.Editor"))
                {
                    EditorApplication.delayCall += () =>
                    {
                        EditorUtilities.PingObject(Path.Combine(EditorUtilities.GetThisAssetProjectPath(), "ReadMe.asset"));
                    };
                }
            }
        }
    }
}


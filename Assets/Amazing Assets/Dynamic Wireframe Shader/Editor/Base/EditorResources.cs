// Dynamic Wireframe Shader <https://u3d.as/3WyY>
// Copyright (c) Amazing Assets <https://amazingassets.world>

using UnityEngine;
using UnityEditor;


namespace AmazingAssets.DynamicWireframeShader.Editor
{
    static public class EditorResources
    {
        const int fontSize = 11;

        #region Textures
        static Texture iconGear;
        static public Texture IconGear => iconGear ??= UnityEditor.EditorGUIUtility.IconContent("_Popup@2x").image;
        static Texture2D iconPlus;
        static internal Texture2D IconPlus => iconPlus ??= (Texture2D)UnityEditor.EditorGUIUtility.IconContent("ol_plus").image;        
        #endregion

        #region GUIStyles       
        static GUIStyle guiStyleFoldoutBold;
        static internal GUIStyle GUIStyleFoldoutBold
        {
            get
            {
                if (guiStyleFoldoutBold == null)
                {
                    guiStyleFoldoutBold = new GUIStyle(EditorStyles.foldout);
                    guiStyleFoldoutBold.fontStyle = FontStyle.Bold;
                }

                return guiStyleFoldoutBold;
            }
        }      
        static GUIStyle guiStyleRLHeader;
        static internal GUIStyle GUIStyleRLHeader
        {
            get
            {
                if (guiStyleRLHeader == null)
                    guiStyleRLHeader = new GUIStyle("RL Header");

                return guiStyleRLHeader;
            }
        }
        #endregion
    }
}

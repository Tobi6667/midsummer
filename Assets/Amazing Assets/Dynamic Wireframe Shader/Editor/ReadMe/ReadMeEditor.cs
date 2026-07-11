// Dynamic Wireframe Shader <https://u3d.as/3WyY>
// Copyright (c) Amazing Assets <https://amazingassets.world>

using System.IO;
using System.Collections.Generic;

using UnityEngine;
using UnityEditor;


namespace AmazingAssets.DynamicWireframeShader.Editor
{
    [HelpURL(About.documentationURL)]
    [CustomEditor(typeof(ReadMe))]
    [InitializeOnLoad]
    public class ReadMeEditor : UnityEditor.Editor
    {
        const float k_Space = 16f;


        static GUIStyle guiStyleTitle;
        GUIStyle GUIStyleTitle
        {
            get
            {
                if (guiStyleTitle == null)
                {
                    guiStyleTitle = new GUIStyle(EditorStyles.boldLabel);
                    guiStyleTitle.alignment = TextAnchor.MiddleCenter;
                    guiStyleTitle.wordWrap = true;
                    guiStyleTitle.fontSize = 18;
                    guiStyleTitle.normal.textColor = EditorGUIUtility.isProSkin ? Color.white : Color.black;
                }

                return guiStyleTitle;
            }
        }

        static GUIStyle guiStyleHeading;
        GUIStyle GUIStyleHeading
        {
            get
            {
                if (guiStyleHeading == null)
                {
                    guiStyleHeading = new GUIStyle(EditorStyles.boldLabel);
                    guiStyleHeading.fontSize = 16;
                    guiStyleHeading.wordWrap = true;
                    guiStyleHeading.normal.textColor = EditorGUIUtility.isProSkin ? Color.white : Color.black;
                    guiStyleHeading.hover.textColor = EditorGUIUtility.isProSkin ? Color.white : Color.black;
                }

                return guiStyleHeading;
            }
        }
        static GUIStyle guiStyleLink;
        static GUIStyle GUIStyleLink
        {
            get
            {
                if (guiStyleLink == null)
                {
                    guiStyleLink = new GUIStyle(EditorStyles.label);
                    guiStyleLink.richText = true;
                    guiStyleLink.fontSize = 13;


                    guiStyleLink.normal.textColor = new Color(0x00 / 255f, 0x78 / 255f, 0xDA / 255f, 1f);
                    guiStyleLink.stretchWidth = false;
                }

                return guiStyleLink;
            }
        }

        static GUIStyle guiStyleLabelWrappedRichText;
        GUIStyle GUIStyleLabelWrappedRichText
        {
            get
            {
                if (guiStyleLabelWrappedRichText == null)
                {
                    guiStyleLabelWrappedRichText = new GUIStyle(EditorStyles.wordWrappedLabel);
                    guiStyleLabelWrappedRichText.richText = true;
                    guiStyleLabelWrappedRichText.normal.textColor = EditorGUIUtility.isProSkin ? Color.white : Color.black;
                }

                return guiStyleLabelWrappedRichText;
            }
        }

        static GUIStyle guiStyleImport;
        GUIStyle GUIStyleImport
        {
            get
            {
                if (guiStyleImport == null)
                    guiStyleImport = new GUIStyle("IN BigTitle");

                return guiStyleImport;
            }
        }

        Texture2D m_logo;
        Texture2D Logo
        {
            get
            {
                if (m_logo == null)
                {
                    string iconPath = Path.Combine(EditorUtilities.GetThisAssetProjectPath(), "Editor", "ReadMe", "Logo");

                    byte[] bytes = File.ReadAllBytes(iconPath);
                    m_logo = new Texture2D(2, 2);
                    m_logo.LoadImage(bytes);
                }
                return m_logo;
            }
        }

        int renderPipeline;


        private void OnEnable()
        {
            switch (EditorUtilities.GetCurrentRenderPipeline())
            {
                case EditorUtilities.Enum.RenderPipeline.Universal: renderPipeline = 1; break;
                case EditorUtilities.Enum.RenderPipeline.HighDefinition: renderPipeline = 2; break;

                default: renderPipeline = 0; break;
            }
        }
        protected override void OnHeaderGUI()
        {

        }
        public override void OnInspectorGUI()
        {
            var iconWidth = Mathf.Min(UnityEditor.EditorGUIUtility.currentViewWidth / 3f - 20f, 128f);

            GUILayout.Space(k_Space);
            using (new EditorGUIHelper.EditorGUILayoutBeginHorizontal())
            {
                Rect logoRect = EditorGUILayout.GetControlRect(GUILayout.Width(iconWidth), GUILayout.Height(iconWidth));
                if (GUI.Button(logoRect, Logo))
                    EditorUtilities.PingObject(target);

                UnityEditor.EditorGUIUtility.AddCursorRect(logoRect, MouseCursor.Link);

                GUILayout.Space(k_Space);
                using (new EditorGUIHelper.EditorGUILayoutBeginVertical())
                {
                    GUILayout.FlexibleSpace();
                    EditorGUILayout.LabelField(About.name, GUIStyleTitle);
                    EditorGUILayout.LabelField("Version " + About.version, EditorStyles.centeredGreyMiniLabel);
                    GUILayout.FlexibleSpace();
                }
                GUILayout.FlexibleSpace();
            }

            Rect rc = GUILayoutUtility.GetLastRect();
            rc.yMin = rc.yMax + 15;
            rc.height = 1;
            rc.xMin -= 50;
            rc.xMax += 50;
            EditorGUI.DrawRect(rc, Color.gray);


            GUILayout.Space(k_Space * 0.5f);
            //Thank you
            {
                Rect reviewRect = EditorGUILayout.GetControlRect();
                GUILayout.Label($"Thank you for using <b>{About.name}</b>.\nIf you find this asset useful and enjoy it, please consider leaving a review and rating. Your feedback encourages us to continue supporting, updating, and improving it.", GUIStyleLabelWrappedRichText);
                if (LinkLabel(new GUIContent("Leave review and rating")))
                    Application.OpenURL(About.storeURL);
            }

            GUILayout.Space(k_Space * 1.5f);
            //Example Scenes
            {
                DrawPackages();
            }

            GUILayout.Space(k_Space);
            //Documentation
            {
                GUILayout.Label("Documentation", GUIStyleHeading);

                if (LinkLabel(new GUIContent("Open online documentation")))
                    Application.OpenURL(About.documentationURL);
            }

            GUILayout.Space(k_Space);
            //Forum
            {
                GUILayout.Label("Forum", GUIStyleHeading);

                if (LinkLabel(new GUIContent("Get answers")))
                    Application.OpenURL(About.forumURL);
            }

            GUILayout.Space(k_Space);
            //Support
            {
                GUILayout.Label("Support and bug report", GUIStyleHeading);

                if (LinkLabel(new GUIContent("Submit a report")))
                    Application.OpenURL("mailto:" + About.supportMail);
            }

            GUILayout.Space(k_Space);
            //Support
            {
                GUILayout.Label("More Assets", GUIStyleHeading);

                if (LinkLabel(new GUIContent("Open publisher page")))
                    Application.OpenURL(About.publisherPage);
            }
        }

        static public bool LinkLabel(GUIContent label, params GUILayoutOption[] options)
        {
            var position = GUILayoutUtility.GetRect(label, GUIStyleLink, options);

            Handles.BeginGUI();
            Handles.color = GUIStyleLink.normal.textColor;
            Handles.DrawLine(new Vector3(position.xMin, position.yMax), new Vector3(position.xMax, position.yMax));
            Handles.color = Color.white;
            Handles.EndGUI();

            UnityEditor.EditorGUIUtility.AddCursorRect(position, MouseCursor.Link);

            return GUI.Button(position, label, GUIStyleLink);
        }


        void DrawPackages()
        {
            EditorGUILayout.LabelField("Packages", GUIStyleHeading);
            GUILayout.Space(2);

            int labelWidth = 110;
            int buttonWidth = 110;

            using (new EditorGUIHelper.EditorGUILayoutBeginVertical(GUIStyleImport))
            {
                using (new EditorGUIHelper.EditorGUILayoutBeginHorizontal())
                {
                    EditorGUILayout.LabelField("Render Pipeline", GUILayout.Width(labelWidth));

                    using (new EditorGUIHelper.GUIBackgroundColor((int)EditorUtilities.GetCurrentRenderPipeline() == renderPipeline ? Color.green : Color.red))
                    {
                        renderPipeline = EditorGUILayout.IntPopup(renderPipeline, new string[] { "Built-In", "Universal", "High Definition" }, new int[] { 0, 1, 2 }, GUILayout.Width(buttonWidth));
                    }

                    GUILayout.FlexibleSpace();
                }

                using (new EditorGUIHelper.EditorGUILayoutBeginHorizontal())
                {
                    EditorGUILayout.LabelField("Example Scenes", GUILayout.Width(labelWidth));

                    if (GUILayout.Button("Import", GUILayout.Width(buttonWidth)))
                    {
                        EditorUtilities.ImportExampleScenesPackage((EditorUtilities.Enum.RenderPipeline)renderPipeline);
                    }

                    string examplesFolder = Path.Combine(EditorUtilities.GetThisAssetProjectPath(), "Example Scenes");
                    using (new EditorGUIHelper.GUIEnabled(Directory.Exists(examplesFolder)))
                    {
                        if (GUILayout.Button(new GUIContent("Recompile", "Recompile example shaders"), GUILayout.Width(buttonWidth)))
                        {
                            EditorApplication.ExecuteMenuItem("Hidden/Assets/Amazing Assets/Dynamic Wireframe Shader/Recompile Example Scene Shaders");
                        }
                    }

                    GUILayout.FlexibleSpace();
                }               
            }
        }
    }
}
// Dynamic Wireframe Shader <https://u3d.as/3WyY>
// Copyright (c) Amazing Assets <https://amazingassets.world>

using System.Linq;
using System.Collections.Generic;

using UnityEngine;
using UnityEditor;
using UnityEditorInternal;


namespace AmazingAssets.DynamicWireframeShader.Editor
{
    [CustomEditor(typeof(DynamicMaskController))]
    public class DynamicMaskControllerEditor : UnityEditor.Editor
    {
        SerializedProperty maskType;

        SerializedProperty maskPlaneTransform;
        SerializedProperty maskPlanePosition;
        SerializedProperty maskPlaneNormal;

        SerializedProperty maskSphereTransform;
        SerializedProperty maskSpherePosition;
        SerializedProperty maskSphereRadius;
        SerializedProperty maskSphereUsePointLight;
        SerializedProperty maskSpherePointLight;

        SerializedProperty maskCubeTransform;
        SerializedProperty maskCubePosition;
        SerializedProperty maskCubeRotation;
        SerializedProperty maskCubeScale;

        SerializedProperty maskCapsuleStartTransform;
        SerializedProperty maskCapsuleEndTransform;
        SerializedProperty maskCapsuleStartPosition;
        SerializedProperty maskCapsuleEndPosition;
        SerializedProperty maskCapsuleRadius;

        SerializedProperty maskConeStartTransform;
        SerializedProperty maskConeEndTransform;
        SerializedProperty maskConeStartPosition;
        SerializedProperty maskConeEndPosition;
        SerializedProperty maskConeRadius;
        SerializedProperty maskConeUseSpotLight;
        SerializedProperty maskConeSpotLight;

        SerializedProperty edgeFalloff;

        SerializedProperty shaderVariableReferenceName;
        SerializedProperty shaderVariableScope;

        SerializedProperty updateMode;
        SerializedProperty drawGizmos;


        ReorderableList listMaterials;
        bool listMaterialsFoldout;

        DynamicMaskController targetController;



        private void OnEnable()
        {
            targetController = (DynamicMaskController)target;


            maskType = serializedObject.FindProperty("maskType");            

            maskPlaneTransform = serializedObject.FindProperty("maskPlaneTransform");
            maskPlanePosition = serializedObject.FindProperty("maskPlanePosition");
            maskPlaneNormal = serializedObject.FindProperty("maskPlaneNormal");

            maskSphereTransform = serializedObject.FindProperty("maskSphereTransform");
            maskSpherePosition = serializedObject.FindProperty("maskSpherePosition");
            maskSphereRadius = serializedObject.FindProperty("maskSphereRadius");
            maskSphereUsePointLight = serializedObject.FindProperty("maskSphereUsePointLight");
            maskSpherePointLight = serializedObject.FindProperty("maskSpherePointLight");

            maskCubeTransform = serializedObject.FindProperty("maskCubeTransform");
            maskCubePosition = serializedObject.FindProperty("maskCubePosition");
            maskCubeRotation = serializedObject.FindProperty("maskCubeRotation");
            maskCubeScale = serializedObject.FindProperty("maskCubeScale");

            maskCapsuleStartTransform = serializedObject.FindProperty("maskCapsuleStartTransform");
            maskCapsuleEndTransform = serializedObject.FindProperty("maskCapsuleEndTransform");
            maskCapsuleStartPosition = serializedObject.FindProperty("maskCapsuleStartPosition");
            maskCapsuleEndPosition = serializedObject.FindProperty("maskCapsuleEndPosition");
            maskCapsuleRadius = serializedObject.FindProperty("maskCapsuleRadius");

            maskConeStartTransform = serializedObject.FindProperty("maskConeStartTransform");
            maskConeEndTransform = serializedObject.FindProperty("maskConeEndTransform");
            maskConeStartPosition = serializedObject.FindProperty("maskConeStartPosition");
            maskConeEndPosition = serializedObject.FindProperty("maskConeEndPosition");
            maskConeRadius = serializedObject.FindProperty("maskConeRadius");
            maskConeUseSpotLight = serializedObject.FindProperty("maskConeUseSpotLight");
            maskConeSpotLight = serializedObject.FindProperty("maskConeSpotLight");

            edgeFalloff = serializedObject.FindProperty("edgeFalloff");

            shaderVariableReferenceName = serializedObject.FindProperty("shaderVariableReferenceName");
            shaderVariableScope = serializedObject.FindProperty("shaderVariableScope");

            updateMode = serializedObject.FindProperty("updateMode");
            drawGizmos = serializedObject.FindProperty("drawGizmos");

            listMaterials = new ReorderableList(serializedObject, serializedObject.FindProperty("listMaterials"), draggable: true, displayHeader: false, displayAddButton: true, displayRemoveButton: true);
            listMaterials.elementHeight = 16;
            listMaterials.drawElementCallback = (Rect rect, int index, bool isActive, bool isFocused) =>
            {
                var element = listMaterials.serializedProperty.GetArrayElementAtIndex(index);
                EditorGUI.PropertyField(rect, element, GUIContent.none);
            };
            listMaterials.onAddCallback = (ReorderableList list) =>
            {
                var size = list.serializedProperty.arraySize;
                list.serializedProperty.InsertArrayElementAtIndex(size);
                list.serializedProperty.GetArrayElementAtIndex(size).objectReferenceValue = null;
            };
            listMaterials.drawElementCallback = DrawMaterialBackground;
            listMaterialsFoldout = serializedObject.FindProperty("listMaterials").isExpanded;
        }
        public override void OnInspectorGUI()
        {
            serializedObject.Update();

            EditorGUILayout.PropertyField(maskType);

            GUILayout.Space(10);
            DrawObjectProperties();

            DrawShaderProperty();

            DrawMaterialProperties();


            GUILayout.Space(10);
            EditorGUILayout.PropertyField(updateMode);
            EditorGUILayout.PropertyField(drawGizmos);

            serializedObject.ApplyModifiedProperties();
        }

        void DrawObjectProperties()
        {
            EditorGUILayout.LabelField(string.Empty, string.Empty, EditorResources.GUIStyleRLHeader);
            Rect drawRect = GUILayoutUtility.GetLastRect();
            drawRect.x += 2;
            drawRect.width -= 120;
            EditorGUI.LabelField(drawRect, " Mask Object Properties", EditorStyles.boldLabel);

            GUILayout.Space(-1);
            using (new EditorGUIHelper.EditorGUILayoutBeginVertical(EditorStyles.helpBox))
            {
                switch ((Enum.DynamicMaskType)maskType.enumValueIndex)
                {
                    case Enum.DynamicMaskType.Plane:
                        {
                            Rect objectRect = EditorGUILayout.GetControlRect();
                            Rect nullRect = new Rect(objectRect.xMin, objectRect.yMin, objectRect.width - 60, objectRect.height);
                            Rect selfRect = new Rect(nullRect.xMax + 2, nullRect.yMin, 58, nullRect.height);

                            if (maskPlaneTransform.objectReferenceValue == null)
                            {
                                EditorGUI.PropertyField(nullRect, maskPlaneTransform, new GUIContent("Plane Object"));

                                if (GUI.Button(selfRect, new GUIContent("Self", "Select this transform")))
                                {
                                    Undo.RecordObject(target, "Self");
                                    maskPlaneTransform.objectReferenceValue = targetController.transform;
                                }

                            }
                            else
                            {
                                EditorGUI.PropertyField(objectRect, maskPlaneTransform, new GUIContent("Plane Object"));
                            }

                            using (new EditorGUIHelper.EditorGUIIndentLevel(1))
                            {
                                if (maskPlaneTransform.objectReferenceValue == null)
                                {
                                    DrawVector(maskPlanePosition, "Position");
                                    DrawVector(maskPlaneNormal, "Normal");
                                }
                            }
                        }
                        break;

                    case Enum.DynamicMaskType.Sphere:
                        {
                            EditorGUILayout.PropertyField(maskSphereUsePointLight, new GUIContent("Use Point Light"));
                            if (maskSphereUsePointLight.boolValue)
                            {
                                using (new EditorGUIHelper.GUIBackgroundColor(maskSpherePointLight.objectReferenceValue == null ? Color.red : Color.white))
                                {
                                    EditorGUILayout.PropertyField(maskSpherePointLight, new GUIContent("Point Light"));
                                }
                            }
                            else
                            {
                                Rect objectRect = EditorGUILayout.GetControlRect();
                                Rect nullRect = new Rect(objectRect.xMin, objectRect.yMin, objectRect.width - 60, objectRect.height);
                                Rect selfRect = new Rect(nullRect.xMax + 2, nullRect.yMin, 58, nullRect.height);

                                if (maskSphereTransform.objectReferenceValue == null)
                                {
                                    EditorGUI.PropertyField(nullRect, maskSphereTransform, new GUIContent("Sphere Object"));

                                    if (GUI.Button(selfRect, new GUIContent("Self", "Select this transform")))
                                    {
                                        Undo.RecordObject(target, "Self");
                                        maskSphereTransform.objectReferenceValue = targetController.transform;
                                    }

                                }
                                else
                                {
                                    EditorGUI.PropertyField(objectRect, maskSphereTransform, new GUIContent("Sphere Object"));
                                }

                                using (new EditorGUIHelper.EditorGUIIndentLevel(1))
                                {
                                    if (maskSphereTransform.objectReferenceValue == null)
                                        DrawVector(maskSpherePosition, "Position");
                                }

                                EditorGUILayout.PropertyField(maskSphereRadius, new GUIContent("Radius"));
                            }
                        }
                        break;

                    case Enum.DynamicMaskType.Cube:
                        {
                            Rect objectRect = EditorGUILayout.GetControlRect();
                            Rect nullRect = new Rect(objectRect.xMin, objectRect.yMin, objectRect.width - 60, objectRect.height);
                            Rect selfRect = new Rect(nullRect.xMax + 2, nullRect.yMin, 58, nullRect.height);

                            if (maskCubeTransform.objectReferenceValue == null)
                            {
                                EditorGUI.PropertyField(nullRect, maskCubeTransform, new GUIContent("Cube Object"));

                                if (GUI.Button(selfRect, new GUIContent("Self", "Select this transform")))
                                {
                                    Undo.RecordObject(target, "Self");
                                    maskCubeTransform.objectReferenceValue = targetController.transform;
                                }

                            }
                            else
                            {
                                EditorGUI.PropertyField(objectRect, maskCubeTransform, new GUIContent("Cube Object"));
                            }
                            
                            using (new EditorGUIHelper.EditorGUIIndentLevel(1))
                            {
                                if (maskCubeTransform.objectReferenceValue == null)
                                {
                                    DrawVector(maskCubePosition, "Position");
                                    DrawVector(maskCubeRotation, "Rotation");
                                    DrawVector(maskCubeScale, "Scale");
                                }
                            }
                        }
                        break;

                    case Enum.DynamicMaskType.Capsule:
                        {
                            bool transformsAreSame = (maskCapsuleStartTransform.objectReferenceValue != null && maskCapsuleEndTransform.objectReferenceValue != null && maskCapsuleStartTransform.objectReferenceValue == maskCapsuleEndTransform.objectReferenceValue);

                            Rect objectRect = EditorGUILayout.GetControlRect();
                            Rect nullRect = new Rect(objectRect.xMin, objectRect.yMin, objectRect.width - 60, objectRect.height);
                            Rect selfRect = new Rect(nullRect.xMax + 2, nullRect.yMin, 58, nullRect.height);

                            using (new EditorGUIHelper.GUIBackgroundColor(transformsAreSame ? Color.red : Color.white))
                            {
                                if (maskCapsuleStartTransform.objectReferenceValue == null)
                                {
                                    EditorGUI.PropertyField(nullRect, maskCapsuleStartTransform, new GUIContent("Capsule Start Object"));

                                    if (GUI.Button(selfRect, new GUIContent("Self", "Select this transform")))
                                    {
                                        Undo.RecordObject(target, "Self");
                                        maskCapsuleStartTransform.objectReferenceValue = targetController.transform;
                                    }

                                }
                                else
                                {
                                    EditorGUI.PropertyField(objectRect, maskCapsuleStartTransform, new GUIContent("Capsule Start Object"));
                                }

                                if (maskCapsuleStartTransform.objectReferenceValue == null)
                                {
                                    using (new EditorGUIHelper.EditorGUIIndentLevel(1))
                                    {
                                        DrawVector(maskCapsuleStartPosition, "Position");
                                    }
                                }
                            }

                            objectRect = EditorGUILayout.GetControlRect();
                            nullRect = new Rect(objectRect.xMin, objectRect.yMin, objectRect.width - 60, objectRect.height);
                            selfRect = new Rect(nullRect.xMax + 2, nullRect.yMin, 58, nullRect.height);

                            using (new EditorGUIHelper.GUIBackgroundColor(transformsAreSame ? Color.red : Color.white))
                            {
                                if (maskCapsuleEndTransform.objectReferenceValue == null)
                                {
                                    EditorGUI.PropertyField(nullRect, maskCapsuleEndTransform, new GUIContent("Capsule End Object"));

                                    if (GUI.Button(selfRect, new GUIContent("Self", "Select this transform")))
                                    {
                                        Undo.RecordObject(target, "Self");
                                        maskCapsuleEndTransform.objectReferenceValue = targetController.transform;
                                    }

                                }
                                else
                                {
                                    EditorGUI.PropertyField(objectRect, maskCapsuleEndTransform, new GUIContent("Capsule End Object"));
                                }

                                if (maskCapsuleEndTransform.objectReferenceValue == null)
                                {
                                    using (new EditorGUIHelper.EditorGUIIndentLevel(1))
                                    {
                                        DrawVector(maskCapsuleEndPosition, "Position");
                                    }
                                }
                            }

                            EditorGUILayout.PropertyField(maskCapsuleRadius, new GUIContent("Radius"));
                        }
                        break;

                    case Enum.DynamicMaskType.Cone:
                        {
                            EditorGUILayout.PropertyField(maskConeUseSpotLight, new GUIContent("Use Spot Light"));
                            if (maskConeUseSpotLight.boolValue)
                            {
                                using (new EditorGUIHelper.GUIBackgroundColor(maskConeSpotLight.objectReferenceValue == null ? Color.red : Color.white))
                                {
                                    EditorGUILayout.PropertyField(maskConeSpotLight, new GUIContent("Spot Light"));
                                }
                            }
                            else
                            {
                                bool transformsAreSame = (maskConeStartTransform.objectReferenceValue != null && maskConeEndTransform.objectReferenceValue != null && maskConeStartTransform.objectReferenceValue == maskConeEndTransform.objectReferenceValue);

                                Rect objectRect = EditorGUILayout.GetControlRect();
                                Rect nullRect = new Rect(objectRect.xMin, objectRect.yMin, objectRect.width - 60, objectRect.height);
                                Rect selfRect = new Rect(nullRect.xMax + 2, nullRect.yMin, 58, nullRect.height);

                                using (new EditorGUIHelper.GUIBackgroundColor(transformsAreSame ? Color.red : Color.white))
                                {
                                    if (maskConeStartTransform.objectReferenceValue == null)
                                    {
                                        EditorGUI.PropertyField(nullRect, maskConeStartTransform, new GUIContent("Cone Start Object"));

                                        if (GUI.Button(selfRect, new GUIContent("Self", "Select this transform")))
                                        {
                                            Undo.RecordObject(target, "Self");
                                            maskConeStartTransform.objectReferenceValue = targetController.transform;
                                        }

                                    }
                                    else
                                    {
                                        EditorGUI.PropertyField(objectRect, maskConeStartTransform, new GUIContent("Cone Start Object"));
                                    }
                                }
                                
                                if (maskConeStartTransform.objectReferenceValue == null)
                                {
                                    using (new EditorGUIHelper.EditorGUIIndentLevel(1))
                                    {
                                        DrawVector(maskConeStartPosition, "Position");
                                    }
                                }

                                objectRect = EditorGUILayout.GetControlRect();
                                nullRect = new Rect(objectRect.xMin, objectRect.yMin, objectRect.width - 60, objectRect.height);
                                selfRect = new Rect(nullRect.xMax + 2, nullRect.yMin, 58, nullRect.height);

                                using (new EditorGUIHelper.GUIBackgroundColor(transformsAreSame ? Color.red : Color.white))
                                {
                                    if (maskConeEndTransform.objectReferenceValue == null)
                                    {
                                        EditorGUI.PropertyField(nullRect, maskConeEndTransform, new GUIContent("Cone End Object"));

                                        if (GUI.Button(selfRect, new GUIContent("Self", "Select this transform")))
                                        {
                                            Undo.RecordObject(target, "Self");
                                            maskConeEndTransform.objectReferenceValue = targetController.transform;
                                        }

                                    }
                                    else
                                    {
                                        EditorGUI.PropertyField(objectRect, maskConeEndTransform, new GUIContent("Cone End Object"));
                                    }
                                }
                                
                                if (maskConeEndTransform.objectReferenceValue == null)
                                {
                                    using (new EditorGUIHelper.EditorGUIIndentLevel(1))
                                    {
                                        DrawVector(maskConeEndPosition, "Position");
                                    }
                                }

                                EditorGUILayout.PropertyField(maskConeRadius, new GUIContent("Radius"));
                            }
                        }
                        break;

                    default:
                        break;
                }

                EditorGUILayout.PropertyField(edgeFalloff);                
            }
        }
        void DrawShaderProperty()
        {
            GUILayout.Space(1);
            EditorGUILayout.LabelField(string.Empty, string.Empty, EditorResources.GUIStyleRLHeader);
            Rect drawRect = GUILayoutUtility.GetLastRect();
            drawRect.x += 2;
            drawRect.width -= 120;
            EditorGUI.LabelField(drawRect, " Shader Variable", EditorStyles.boldLabel);

            GUILayout.Space(-1);
            using (new EditorGUIHelper.EditorGUILayoutBeginVertical(EditorStyles.helpBox))
            {
                GUILayout.Space(2);                
                {
                    drawRect = EditorGUILayout.GetControlRect();
                    drawRect.width -= 60;
                    using (new EditorGUIHelper.GUIBackgroundColor(string.IsNullOrWhiteSpace(shaderVariableReferenceName.stringValue) ? Color.red : Color.white))
                    {
                        EditorGUI.PropertyField(drawRect, shaderVariableReferenceName, new GUIContent("Reference Name"));
                    }

                    if (string.IsNullOrWhiteSpace(shaderVariableReferenceName.stringValue))
                    {
                        if (GUI.Button(new Rect(drawRect.xMin + EditorGUIUtility.labelWidth - 20, drawRect.yMin, drawRect.height, drawRect.height), new GUIContent(EditorResources.IconPlus, "Use default name"), EditorStyles.iconButton))
                        {
                            shaderVariableReferenceName.stringValue = "_WireframeShaderMaskData";

                            serializedObject.ApplyModifiedProperties();
                        }
                    }

                    drawRect.xMin = drawRect.xMax + 2;
                    drawRect.width = 58;
                    EditorGUI.LabelField(drawRect, new GUIContent("Matrix4x4", "Property type inside shader must be 'Matrix4x4', 'Matrix4' or 'float4x4'"), EditorStyles.helpBox);
                }

                EditorGUILayout.PropertyField(shaderVariableScope, new GUIContent("Scope"));
            }
        }
        void DrawMaterialProperties()
        {
            if (shaderVariableScope.enumValueIndex == (int)Enum.ShaderPropertyScope.Local)
            {
                GUILayout.Space(1);
                EditorGUILayout.LabelField(string.Empty, string.Empty, EditorResources.GUIStyleRLHeader);
                Rect drawRect = GUILayoutUtility.GetLastRect();
                drawRect.x += 16;
                drawRect.width -= 40;
                EditorGUI.BeginChangeCheck();
                listMaterialsFoldout = EditorGUI.Foldout(drawRect, listMaterialsFoldout, $"Materials [{listMaterials.count}]", true, EditorResources.GUIStyleFoldoutBold);
                if (EditorGUI.EndChangeCheck())
                    serializedObject.FindProperty("listMaterials").isExpanded = listMaterialsFoldout;


                CatchDragAndDropMaterials(drawRect);


                drawRect.xMin = drawRect.xMax + 4;
                drawRect.width = 20;
                drawRect.y += 2;
                if (GUI.Button(drawRect, EditorResources.IconGear, EditorStyles.iconButton))
                {
                    GenericMenu menu = new GenericMenu();

                    menu.AddItem(new GUIContent("Add Scene Materials (All)"), false, AddSceneMaterials);
                    menu.AddItem(new GUIContent("Add From Selection"), false, AddMaterialsFromSelection);

                    menu.AddSeparator(string.Empty);
                    if (MaterialsListIsValid(targetController))
                    {
                        menu.AddItem(new GUIContent("Select"), false, SelectTargetMaterials);

                        menu.AddSeparator(string.Empty);
                        menu.AddItem(new GUIContent("Remove Invalid Materials", "Remove Null, Empty, Duplicates and Invalid Materials"), false, RemoveUnsuitableMaterials);
                        menu.AddItem(new GUIContent("Remove (All)"), false, RemoveAllMaterials);
                    }
                    else
                    {
                        menu.AddDisabledItem(new GUIContent("Select"));

                        menu.AddSeparator(string.Empty);
                        menu.AddDisabledItem(new GUIContent("Remove Invalid Materials", "Remove Null, Empty, Duplicates and Invalid Materials"));
                        menu.AddDisabledItem(new GUIContent("Remove (All)"));
                    }


                    menu.ShowAsContext();
                }

                if (listMaterialsFoldout)
                {
                    GUILayout.Space(-2);
                    listMaterials.DoLayoutList();
                }
            }

        }
        void GetLabelAndFieldRects(out Rect labelRect, out Rect fieldRect)
        {
            Rect drawRect = EditorGUILayout.GetControlRect();
            labelRect = new Rect(drawRect.xMin, drawRect.yMin, EditorGUIUtility.labelWidth, drawRect.height);
            fieldRect = new Rect(drawRect.xMin + EditorGUIUtility.labelWidth, drawRect.yMin, drawRect.width - EditorGUIUtility.labelWidth, drawRect.height);
        }


        void DrawVector(SerializedProperty property, string label)
        {
            GetLabelAndFieldRects(out Rect labelRect, out Rect fieldRect);

            EditorGUI.LabelField(labelRect, label);

            fieldRect.xMin -= 12;
            EditorGUI.PropertyField(fieldRect, property, GUIContent.none);
        }
        void DrawMaterialBackground(Rect rect, int index, bool isActive, bool isFocused)
        {
            // Get the element at the current index
            var element = listMaterials.serializedProperty.GetArrayElementAtIndex(index);

            DynamicMaskController duplicateController = MaterialExistsInControllerDuplicate((Material)element.objectReferenceValue);

            using (new EditorGUIHelper.GUIBackgroundColor(duplicateController != null ? Color.red : Color.white))
            {
                if (duplicateController != null)
                    rect.width -= 55;

                EditorGUI.PropertyField(rect, element, GUIContent.none);

                if (duplicateController != null)
                {
                    rect.xMin = rect.xMax + 2;
                    rect.width = 53;
                    if (GUI.Button(rect, new GUIContent("Find", "Detected Duplicate DRMController Updating This Material")))
                    {
                        EditorUtilities.PingObject(duplicateController);
                    }
                }

            }
        }
        DynamicMaskController MaterialExistsInControllerDuplicate(Material material)
        {
            if (material != null && DynamicMaskController.allControllers != null)
            {
                foreach (var controller in DynamicMaskController.allControllers)
                {
                    if (controller != null &&
                        controller != targetController &&
                        controller.maskType == targetController.maskType &&
                        MaterialsListIsValid(controller) &&
                        controller.listMaterials.Contains(material))
                    {
                        return controller;
                    }
                }
            }

            return null;
        }
        bool MaterialsListIsValid(DynamicMaskController controller)
        {
            return controller.listMaterials != null && controller.listMaterials.Count > 0;
        }

        void AddSceneMaterials()
        {
            if (targetController.listMaterials == null)
                targetController.listMaterials = new List<Material>();

            List<Material> newMaterials = new List<Material>();
            List<Material> sceneMaterials = EditorUtilities.GetAllSceneMaterials(targetController.listMaterials);
            foreach (var material in sceneMaterials)
            {
                newMaterials.Add(material);
            }


            if (newMaterials.Count > 0)
            {
                Undo.RecordObject(target, "Add materials");
                targetController.listMaterials.AddRange(newMaterials);
            }

            serializedObject.ApplyModifiedProperties();

            targetController.UpdateShaderData();
        }       
        void AddMaterialsFromSelection()
        {
            List<Material> materials = EditorUtilities.GetSelectionMaterials();

            if (targetController.listMaterials.Equals(materials) == false)
            {
                Undo.RecordObject(target, "Add materials");
                targetController.listMaterials = materials;
            }
        }
        void SelectTargetMaterials()
        {
            if (MaterialsListIsValid(targetController))
            {
                Selection.objects = targetController.listMaterials.Where(c => c != null).ToArray();
                EditorUtility.FocusProjectWindow();
            }
        }
        void RemoveUnsuitableMaterials()
        {
            if (MaterialsListIsValid(targetController))
            {
                List<Material> materials = targetController.listMaterials.Where(c => c != null).Distinct().ToList();

                if (targetController.listMaterials.Equals(materials) == false)
                {
                    Undo.RecordObject(target, "Remove materials");
                    targetController.listMaterials = materials;
                }
            }
        }
        void RemoveAllMaterials()
        {
            if (MaterialsListIsValid(targetController))
            {
                Undo.RecordObject(target, "Remove materials");

                serializedObject.FindProperty("listMaterials").ClearArray();

                serializedObject.ApplyModifiedProperties();
            }
        }

        void CatchDragAndDropMaterials(Rect dropRect)
        {
            if (targetController.shaderVariableScope == Enum.ShaderPropertyScope.Local &&
                dropRect.Contains(Event.current.mousePosition))
            {
                if (DragAndDrop.objectReferences.Length > 0)
                    DragAndDrop.visualMode = DragAndDropVisualMode.Copy;

                if (Event.current.type == EventType.DragPerform)
                {
                    DragAndDrop.AcceptDrag();
                    if (DragAndDrop.objectReferences.Length > 0)
                    {
                        if (targetController.listMaterials == null)
                            targetController.listMaterials = new List<Material>();

                        List<Material> newMaterials = new List<Material>();
                        foreach (var draggedObject in DragAndDrop.objectReferences)
                        {
                            newMaterials.AddRange(EditorUtilities.GetObjectMaterials(draggedObject, newMaterials));
                        }

                        newMaterials = newMaterials.Except(targetController.listMaterials).ToList();

                        if (newMaterials.Count > 0)
                        {
                            newMaterials = newMaterials.Distinct().ToList();

                            Undo.RecordObject(target, "Add materials");
                            targetController.listMaterials.AddRange(newMaterials);
                        }

                        targetController.UpdateShaderData();
                    }
                    Event.current.Use();
                }
            }
        }
    }
}

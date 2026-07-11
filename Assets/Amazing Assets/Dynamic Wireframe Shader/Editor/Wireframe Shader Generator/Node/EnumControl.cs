// Dynamic Wireframe Shader <https://u3d.as/3WyY>
// Copyright (c) Amazing Assets <https://amazingassets.world>

using System;
using System.Reflection;

using UnityEditor;
using UnityEngine;
using UnityEngine.UIElements;
using UnityEditor.ShaderGraph;
using UnityEditor.ShaderGraph.Drawing.Controls;


namespace AmazingAssets.DynamicWireframeShaderGenerator.Editor
{
    [AttributeUsage(AttributeTargets.Property)]
    class EnumControlAttribute : Attribute, IControlAttribute
    {
        bool m_validInSubGraph;
        string m_Label;

        public EnumControlAttribute(bool validInSubGraph, string label = null)
        {
            m_validInSubGraph = validInSubGraph;
            m_Label = label;
        }

        public VisualElement InstantiateControl(AbstractMaterialNode node, PropertyInfo propertyInfo)
        {
            return new EnumControlView(m_Label, node, m_validInSubGraph, propertyInfo);
        }
    }

    class EnumControlView : VisualElement
    {
        AbstractMaterialNode m_Node;
        PropertyInfo m_PropertyInfo;

        public EnumControlView(string label, AbstractMaterialNode node, bool validInSubGraph, PropertyInfo propertyInfo)
        {
            if (validInSubGraph == false && node.owner.isSubGraph)
            {
                //Do not draw in sub-graph
            }
            else
            {
                styleSheets.Add(Resources.Load<StyleSheet>("Styles/Controls/EnumControlView"));
                m_Node = node;
                m_PropertyInfo = propertyInfo;
                if (!propertyInfo.PropertyType.IsEnum)
                    throw new ArgumentException("Property must be an enum.", "propertyInfo");

                Add(new Label(label ?? ObjectNames.NicifyVariableName(propertyInfo.Name)));
                var enumField = new EnumField((Enum)m_PropertyInfo.GetValue(m_Node, null));
                enumField.style.width = new StyleLength(160);
                enumField.RegisterValueChangedCallback(OnValueChanged);
                Add(enumField);
            }
        }

        void OnValueChanged(ChangeEvent<Enum> evt)
        {
            var value = (Enum)m_PropertyInfo.GetValue(m_Node, null);
            if (!evt.newValue.Equals(value))
            {
                m_Node.owner.owner.RegisterCompleteObjectUndo("Change " + m_Node.name);
                m_PropertyInfo.SetValue(m_Node, evt.newValue, null);
            }
        }
    }
}

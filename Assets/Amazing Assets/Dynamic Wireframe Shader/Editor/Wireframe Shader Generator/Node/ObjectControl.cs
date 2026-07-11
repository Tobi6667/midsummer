// Dynamic Wireframe Shader <https://u3d.as/3WyY>
// Copyright (c) Amazing Assets <https://amazingassets.world>

using System;
using System.Reflection;

using UnityEngine.UIElements;
using UnityEditor.UIElements;
using UnityEditor.ShaderGraph;
using UnityEditor.ShaderGraph.Drawing.Controls;


namespace AmazingAssets.DynamicWireframeShaderGenerator.Editor
{
    class ObjectControlAttribute : Attribute, IControlAttribute
    {
        bool m_validInSubGraph;
        string m_initMethod;
        string m_Label;

        public ObjectControlAttribute(bool validInSubGraph, string initMethod, string label = null)
        {
            m_validInSubGraph = validInSubGraph;
            m_initMethod = initMethod;
            m_Label = label;
        }

        public VisualElement InstantiateControl(AbstractMaterialNode node, PropertyInfo propertyInfo)
        {
            return new ObjectControlView(m_Label, node, m_validInSubGraph, m_initMethod, propertyInfo);
        } 
    }

    class ObjectControlView : VisualElement
    {
        AbstractMaterialNode m_Node;
        PropertyInfo m_PropertyInfo;

        public ObjectControlView(string label, AbstractMaterialNode node, bool validInSubGraph, string initMethod, PropertyInfo propertyInfo)
        {
            if (validInSubGraph == false && node.owner.isSubGraph)
            {
                //Do not draw in sub-graph
            }
            else
            {
                if (!typeof(UnityEngine.Object).IsAssignableFrom(propertyInfo.PropertyType))
                    throw new ArgumentException("Property must be assignable to UnityEngine.Object.");
                m_Node = node;
                m_PropertyInfo = propertyInfo;
                label = label ?? propertyInfo.Name;

                if (!string.IsNullOrEmpty(label))
                    Add(new Label { text = label });

                var value = (UnityEngine.Object)m_PropertyInfo.GetValue(m_Node, null);
                var objectField = new ObjectField { objectType = propertyInfo.PropertyType, value = value };
                objectField.style.width = new StyleLength(225);


                objectField.RegisterValueChangedCallback(OnValueChanged);
                Add(objectField);

                m_Node.GetType().GetMethod(initMethod).Invoke(m_Node, new object[] { objectField });
            }
        }

        void OnValueChanged(ChangeEvent<UnityEngine.Object> evt)
        {
            var value = (UnityEngine.Object)m_PropertyInfo.GetValue(m_Node, null);
            if (evt.newValue != value)
            {
                m_Node.owner.owner.RegisterCompleteObjectUndo("Change + " + m_Node.name);
                m_PropertyInfo.SetValue(m_Node, evt.newValue, null);
            }
        }
    }
}

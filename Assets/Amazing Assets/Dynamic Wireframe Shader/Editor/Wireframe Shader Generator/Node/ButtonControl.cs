// Dynamic Wireframe Shader <https://u3d.as/3WyY>
// Copyright (c) Amazing Assets <https://amazingassets.world>

using System;
using System.Reflection;

using UnityEngine;
using UnityEngine.UIElements; 
using UnityEditor.ShaderGraph;
using UnityEditor.ShaderGraph.Drawing.Controls;


namespace AmazingAssets.DynamicWireframeShaderGenerator.Editor
{
    class ButtonControlAttribute : Attribute, IControlAttribute
    {
        bool m_validInSubGraph;
        string m_callbackAction; 

        public ButtonControlAttribute(bool validInSubGraph, string callbackAction)
        {
            m_validInSubGraph = validInSubGraph;
            m_callbackAction = callbackAction;
        }

        VisualElement IControlAttribute.InstantiateControl(AbstractMaterialNode node, PropertyInfo propertyInfo)
        {
            if (!(node is WireframeRendererNode))
                throw new ArgumentException($"Property must be a '{About.name}' Node.", "node");

            return new ButtonControlView(node, m_validInSubGraph, m_callbackAction);
        }
    }

    class ButtonControlView : VisualElement
    {
        AbstractMaterialNode m_Node;
        string m_callbackAction;
        UnityEngine.UIElements.Button m_Button;

        public ButtonControlView(AbstractMaterialNode node, bool validInSubGraph, string callbackAction)
        {
            if (validInSubGraph == false && node.owner.isSubGraph)
            {
                //Do not draw in sub-graph
            }
            else
            {
                m_Node = node;
                m_callbackAction = callbackAction;

                m_Button = new Button(Callback);
                m_Button.text = "Generate Dynamic Wireframe Shader";
                m_Button.style.width = new StyleLength(300);
                m_Button.style.height = new StyleLength(30);
                m_Button.style.color = Color.black;
                m_Button.style.backgroundImage = Resources.Load<Texture2D>("WireframeNodeBackground");
                Add(m_Button);
            }
        }


        void Callback()
        {
            m_Node.GetType().GetMethod(m_callbackAction).Invoke(m_Node, null);
        }
    }
}

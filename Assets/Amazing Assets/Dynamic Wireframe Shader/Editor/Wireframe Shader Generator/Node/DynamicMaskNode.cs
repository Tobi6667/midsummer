// Dynamic Wireframe Shader <https://u3d.as/3WyY>
// Copyright (c) Amazing Assets <https://amazingassets.world>

using System.Reflection;

using UnityEngine;
using UnityEditor.Graphing;
using UnityEditor.ShaderGraph;


namespace AmazingAssets.DynamicWireframeShaderGenerator.Editor
{
    [Title("Amazing Assets", "Dynamic Wireframe Shader", "Dynamic Mask")]
    class DynamicMaskNode : CodeFunctionNode
    {
        public enum MaskType { Plane, Sphere, Cube, Capsule, Cone };

        public override string documentationURL => About.documentationURL;


        public DynamicMaskNode()
        {
            name = "Dynamic Mask";
            m_PreviewMode = PreviewMode.Inherit;
        }

        [SerializeField]
        private MaskType m_MaskType = MaskType.Plane;

        [EnumControl(true, "Type")]
        public MaskType maskType
        {
            get { return m_MaskType; }
            set
            {
                if (m_MaskType == value)
                    return;

                m_MaskType = value;
                Dirty(ModificationScope.Graph);
            }
        }        

        protected override MethodInfo GetFunctionToConvert()
        {
            switch (m_MaskType)
            {
                case MaskType.Sphere: return GetType().GetMethod("WireframeShaderDynamicMaskSphere", BindingFlags.Static | BindingFlags.NonPublic);
                case MaskType.Cube: return GetType().GetMethod("WireframeShaderDynamicMaskCube", BindingFlags.Static | BindingFlags.NonPublic);
                case MaskType.Capsule: return GetType().GetMethod("WireframeShaderDynamicMaskCapsule", BindingFlags.Static | BindingFlags.NonPublic);
                case MaskType.Cone: return GetType().GetMethod("WireframeShaderDynamicMaskCone", BindingFlags.Static | BindingFlags.NonPublic);

                default:    //Plane
                    return GetType().GetMethod("WireframeShaderDynamicMaskPlane", BindingFlags.Static | BindingFlags.NonPublic);
            }
        }

        static string WireframeShaderDynamicMaskPlane(
            [Slot(0, Binding.WorldSpacePosition, true, ShaderStageCapability.All)] Vector3 vertexPositionWS,
            [Slot(1, Binding.None)] Matrix4x4 ShaderData,
            [Slot(2, Binding.None)] Vector1 Noise,
            [Slot(3, Binding.None)] out Vector1 Out)
        {
            return
        @"
        {
            $precision3 planePosition = ShaderData[0].xyz;
        	$precision3 planeNormal   = ShaderData[1].xyz;
        	$precision fallOff        = ShaderData[3].x;
        	$precision intensity      = ShaderData[3].y;


            vertexPositionWS = GetAbsolutePositionWS(vertexPositionWS);
        	$precision mask = dot(planeNormal, (vertexPositionWS - planePosition)) - Noise;

            Out = saturate(mask / fallOff) * intensity;
        }";
        }

        static string WireframeShaderDynamicMaskSphere(
            [Slot(0, Binding.WorldSpacePosition, true)] Vector3 vertexPositionWS,
            [Slot(1, Binding.None)] Matrix4x4 ShaderData,
            [Slot(2, Binding.None)] Vector1 Noise,
            [Slot(3, Binding.None)] out Vector1 Out)
        {
            return
        @"
        {
            $precision3 spherePosition = ShaderData[0].xyz;
        	$precision sphereRadius    = ShaderData[0].w;
        	$precision fallOff         = ShaderData[3].x;
        	$precision intensity       = ShaderData[3].y;


            vertexPositionWS = GetAbsolutePositionWS(vertexPositionWS);
        	$precision d = distance(vertexPositionWS, spherePosition);

            $precision mask = 1 - saturate(max(0, d - Noise - sphereRadius + fallOff) / fallOff);

            Out = mask * intensity;
        }
        ";
        }

        static string WireframeShaderDynamicMaskCube(
            [Slot(0, Binding.WorldSpacePosition, true)] Vector3 vertexPositionWS,
            [Slot(1, Binding.None)] Matrix4x4 ShaderData,
            [Slot(2, Binding.None)] Vector1 Noise,
            [Slot(3, Binding.None)] out Vector1 Out)
        {
            return
        @"
        {
            $precision3 cubePosition = ShaderData[0].xyz;
        	$precision4 cubeRotation = ShaderData[1].xyzw;
        	$precision3 cubeScale    = ShaderData[2].xyz;
        	$precision fallOff       = ShaderData[3].x;
        	$precision intensity     = ShaderData[3].y;
            

            vertexPositionWS = GetAbsolutePositionWS(vertexPositionWS);
        	$precision3 v = vertexPositionWS - cubePosition;
        	$precision3 u = cubeRotation.xyz;
            $precision w = -cubeRotation.w;
            $precision3 position =  2.0f * dot(u, v) * u + (w * w - dot(u, u)) * v +  2.0f * w * cross(u, v);

        	$precision3 boundsMax = cubeScale * 0.5 + Noise;
        	$precision3 boundsMin = -boundsMax;  

        	$precision3 s = smoothstep(boundsMin, boundsMin + fallOff, position) - 
        	           smoothstep(boundsMax - fallOff, boundsMax, position);

        	$precision mask = saturate(s.x * s.y * s.z);

        	Out = mask * intensity;
        }
        ";
        }

        static string WireframeShaderDynamicMaskCapsule(
            [Slot(0, Binding.WorldSpacePosition, true)] Vector3 vertexPositionWS,
            [Slot(1, Binding.None)] Matrix4x4 ShaderData,
            [Slot(2, Binding.None)] Vector1 Noise,
            [Slot(3, Binding.None)] out Vector1 Out)
        {
            return
        @"
        {
            $precision3 capsulePosition = ShaderData[0].xyz;
        	$precision capsuleHeight    = ShaderData[0].w;
        	$precision3 capsuleNormal   = ShaderData[1].xyz;	
        	$precision capsuleRadius    = ShaderData[1].w;
        	$precision fallOff          = ShaderData[3].x;
        	$precision intensity        = ShaderData[3].y;


            vertexPositionWS = GetAbsolutePositionWS(vertexPositionWS);
        	$precision t = saturate(dot(vertexPositionWS - capsulePosition, capsuleNormal) / capsuleHeight);       
        	$precision3 projection = capsulePosition + t * capsuleNormal * capsuleHeight;

        	$precision d = distance(vertexPositionWS, projection);

        	$precision mask = 1 - saturate(max(0, d - Noise - capsuleRadius + fallOff) / fallOff);

            Out = mask * intensity;
        }
        ";
        }

        static string WireframeShaderDynamicMaskCone(
            [Slot(0, Binding.WorldSpacePosition, true)] Vector3 vertexPositionWS,
            [Slot(1, Binding.None)] Matrix4x4 ShaderData,
            [Slot(2, Binding.None)] Vector1 Noise,
            [Slot(3, Binding.None)] out Vector1 Out)
        {
            return
        @"
        {
            $precision3 conePosition = ShaderData[0].xyz;
        	$precision coneHeight    = ShaderData[0].w;
        	$precision3 coneNormal   = ShaderData[1].xyz;	
        	$precision coneRadius    = ShaderData[1].w;
        	$precision fallOff       = ShaderData[3].x;
        	$precision intensity     = ShaderData[3].y;


            vertexPositionWS = GetAbsolutePositionWS(vertexPositionWS);
        	$precision t = saturate(dot(vertexPositionWS - conePosition, coneNormal) / coneHeight);    
        	$precision3 projectPosition = conePosition + t * coneNormal * coneHeight;

        	$precision d = distance(vertexPositionWS, projectPosition);

        	$precision radius = lerp(0, coneRadius, t);

        	$precision mask = 1 - saturate(max(0, d - Noise - radius + fallOff) / fallOff);

            Out = mask * intensity;
        }
        ";
        }

    }
}
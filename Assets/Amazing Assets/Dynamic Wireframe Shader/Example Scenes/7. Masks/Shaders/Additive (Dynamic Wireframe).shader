// Dynamic Wireframe Shader <https://u3d.as/3WyY>
// Copyright (c) Amazing Assets <https://amazingassets.world>

Shader "Amazing Assets/Dynamic Wireframe Shader/Examples/Masks/Additive (Dynamic Wireframe)"
{
Properties
{
[KeywordEnum(Triangle, Quad)] _Wireframe_Shader_Shape("Wireframe Shape", int) = 0
[KeywordEnum(Default, Normalized, Screen Space)] _Wireframe_Shader_Style("Wireframe Style", int) = 0

_Wireframe_Thickness("Wireframe Thickness", Range(0, 1)) = 0.01
_Wireframe_Anti_aliasing("Wireframe Anti-aliasing", Range(0, 1)) = 0.2
[HDR]_Wireframe_Color("Wireframe Color", Color) = (1, 1, 1, 1)
[HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
[HideInInspector]_QueueControl("_QueueControl", Float) = -1
[HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
[HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
[HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
}
SubShader
{
Tags
{
"RenderPipeline"="UniversalPipeline"
"RenderType"="Transparent"
"UniversalMaterialType" = "Unlit"
"Queue"="Transparent"
"DisableBatching"="False"
"ShaderGraphShader"="true"
"ShaderGraphTargetId"="UniversalUnlitSubTarget"
}
Pass
{
    Name "Unlit"
    Tags
    {
        // LightMode: <None>
    }

// Render State
Cull Off
Blend SrcAlpha One, One One
ZTest LEqual
ZWrite Off

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM

// Pragmas
#pragma target 2.0
#pragma multi_compile_instancing
#pragma instancing_options renderinglayer
#pragma vertex vert
#pragma fragment frag

// Keywords
#pragma multi_compile _ LIGHTMAP_ON
#pragma multi_compile _ DIRLIGHTMAP_COMBINED
#pragma multi_compile _ USE_LEGACY_LIGHTMAPS
#pragma multi_compile _ LIGHTMAP_BICUBIC_SAMPLING
#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
#pragma multi_compile_fragment _ DEBUG_DISPLAY
#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
// GraphKeywords: <None>

// Defines

#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define ATTRIBUTES_NEED_TEXCOORD0
#define ATTRIBUTES_NEED_TEXCOORD1
#define ATTRIBUTES_NEED_TEXCOORD2
#define ATTRIBUTES_NEED_TEXCOORD3
#define ATTRIBUTES_NEED_TEXCOORD4
#define ATTRIBUTES_NEED_TEXCOORD5
#define ATTRIBUTES_NEED_TEXCOORD6
#define ATTRIBUTES_NEED_TEXCOORD7
#define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
#define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define VARYINGS_NEED_TEXCOORD0
#define VARYINGS_NEED_TEXCOORD1
#define VARYINGS_NEED_TEXCOORD2
#define VARYINGS_NEED_TEXCOORD3
#define VARYINGS_NEED_TEXCOORD4
#define VARYINGS_NEED_TEXCOORD5
#define VARYINGS_NEED_TEXCOORD6
#define VARYINGS_NEED_TEXCOORD7
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_UNLIT
#define _FOG_FRAGMENT 1
#define _SURFACE_TYPE_TRANSPARENT 1
#define UNLIT_DEFAULT_DECAL_BLENDING 1
#define UNLIT_DEFAULT_SSAO 1


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Fog.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

// --------------------------------------------------
// Structs and Packing

// custom interpolators pre packing
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

struct Attributes
{
 float3 positionOS : POSITION;
 float3 normalOS : NORMAL;
 float4 tangentOS : TANGENT;
 float4 uv0 : TEXCOORD0;
 float4 uv1 : TEXCOORD1;
 float4 uv2 : TEXCOORD2;
 float4 uv3 : TEXCOORD3;
 float4 uv4 : TEXCOORD4;
 float4 uv5 : TEXCOORD5;
 float4 uv6 : TEXCOORD6;
 float4 uv7 : TEXCOORD7;
#if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
 float3 positionWS;
 float3 normalWS;
 float4 texCoord0;
 float4 texCoord1;
 float4 texCoord2;
 float4 texCoord3;
 float4 texCoord4;
 float4 texCoord5;
 float4 texCoord6;
 float4 texCoord7;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};
struct SurfaceDescriptionInputs
{
 float3 WorldSpacePosition;
 float4 uv0;
 float4 uv1;
 float4 uv2;
 float4 uv3;
 float4 uv4;
 float4 uv5;
 float4 uv6;
 float4 uv7;
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
 float4 texCoord0 : INTERP0;
 float4 texCoord1 : INTERP1;
 float4 texCoord2 : INTERP2;
 float4 texCoord3 : INTERP3;
 float4 texCoord4 : INTERP4;
 float4 texCoord5 : INTERP5;
 float4 texCoord6 : INTERP6;
 float4 texCoord7 : INTERP7;
 float3 positionWS : INTERP8;
 float3 normalWS : INTERP9;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings (Varyings input)
{
PackedVaryings output;
ZERO_INITIALIZE(PackedVaryings, output);
output.positionCS = input.positionCS;
output.texCoord0.xyzw = input.texCoord0;
output.texCoord1.xyzw = input.texCoord1;
output.texCoord2.xyzw = input.texCoord2;
output.texCoord3.xyzw = input.texCoord3;
output.texCoord4.xyzw = input.texCoord4;
output.texCoord5.xyzw = input.texCoord5;
output.texCoord6.xyzw = input.texCoord6;
output.texCoord7.xyzw = input.texCoord7;
output.positionWS.xyz = input.positionWS;
output.normalWS.xyz = input.normalWS;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}

Varyings UnpackVaryings (PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
output.texCoord0 = input.texCoord0.xyzw;
output.texCoord1 = input.texCoord1.xyzw;
output.texCoord2 = input.texCoord2.xyzw;
output.texCoord3 = input.texCoord3.xyzw;
output.texCoord4 = input.texCoord4.xyzw;
output.texCoord5 = input.texCoord5.xyzw;
output.texCoord6 = input.texCoord6.xyzw;
output.texCoord7 = input.texCoord7.xyzw;
output.positionWS = input.positionWS.xyz;
output.normalWS = input.normalWS.xyz;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)
float _Wireframe_Thickness;
float _Wireframe_Anti_aliasing;
float4 _Wireframe_Color;
UNITY_TEXTURE_STREAMING_DEBUG_VARS;
CBUFFER_END


// Object and Global properties
float4x4 _WireframeShaderMaskData1;
float4x4 _WireframeShaderMaskData2;

// Graph Includes
// GraphIncludes: <None>

// -- Property used by ScenePickingPass
#ifdef SCENEPICKINGPASS
float4 _SelectionID;
#endif

// -- Properties used by SceneSelectionPass
#ifdef SCENESELECTIONPASS
int _ObjectId;
int _PassValue;
#endif

// Graph Functions

void WireframeRenderer_float(float3 barycentric, float3 thickness, float antiAliasing, float renderInScreenSpace, out float OutWireframe, out float2 OutBarycentricUV)
{
    #if defined(_WIREFRAME_IS_DYNAMIC)
        float3 fw = fwidth(barycentric);

        float3 t = thickness.xxx;

        #if defined(_WIREFRAME_IS_DYNAMIC)
            #if defined(_WIREFRAME_SHADER_STYLE_SCREEN_SPACE)
                t *= fw * 5;
            #endif
        #else
            t *= lerp(1, fw * 5, saturate(renderInScreenSpace));
        #endif                    

        float3 df = barycentric - t;
        df /= fw * antiAliasing * 10 + 1e-6;
        float e = min(df.x, min(df.y, df.z));

        OutWireframe = 1 - smoothstep(0.0, 1.0, e + 0.5);

        df = barycentric / t;
        float u = min(df.x, min(df.y, df.z));
        OutBarycentricUV = float2(saturate(u), 0.5);
    #else
        OutWireframe = 0;
        OutBarycentricUV = float2(0, 0);
    #endif
}

void WireframeShaderDynamicMaskCube_float(float3 vertexPositionWS, float4x4 ShaderData, float Noise, out float Out)
{
            float3 cubePosition = ShaderData[0].xyz;
        	float4 cubeRotation = ShaderData[1].xyzw;
        	float3 cubeScale    = ShaderData[2].xyz;
        	float fallOff       = ShaderData[3].x;
        	float intensity     = ShaderData[3].y;
            

            vertexPositionWS = GetAbsolutePositionWS(vertexPositionWS);
        	float3 v = vertexPositionWS - cubePosition;
        	float3 u = cubeRotation.xyz;
            float w = -cubeRotation.w;
            float3 position =  2.0f * dot(u, v) * u + (w * w - dot(u, u)) * v +  2.0f * w * cross(u, v);

        	float3 boundsMax = cubeScale * 0.5 + Noise;
        	float3 boundsMin = -boundsMax;  

        	float3 s = smoothstep(boundsMin, boundsMin + fallOff, position) - 
        	           smoothstep(boundsMax - fallOff, boundsMax, position);

        	float mask = saturate(s.x * s.y * s.z);

        	Out = mask * intensity;
        }

void WireframeShaderDynamicMaskSphere_float(float3 vertexPositionWS, float4x4 ShaderData, float Noise, out float Out)
{
            float3 spherePosition = ShaderData[0].xyz;
        	float sphereRadius    = ShaderData[0].w;
        	float fallOff         = ShaderData[3].x;
        	float intensity       = ShaderData[3].y;


            vertexPositionWS = GetAbsolutePositionWS(vertexPositionWS);
        	float d = distance(vertexPositionWS, spherePosition);

            float mask = 1 - saturate(max(0, d - Noise - sphereRadius + fallOff) / fallOff);

            Out = mask * intensity;
        }

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Saturate_float(float In, out float Out)
{
    Out = saturate(In);
}

void Unity_Multiply_float_float(float A, float B, out float Out)
{
Out = A * B;
}

void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
{
Out = A * B;
}

// Custom interpolators pre vertex
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
description.Position = IN.ObjectSpacePosition;
description.Normal = IN.ObjectSpaceNormal;
description.Tangent = IN.ObjectSpaceTangent;
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float3 BaseColor;
float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
float4 _Property_c74b42315a444fa6aab2c9ce9a824d6f_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Wireframe_Color) : _Wireframe_Color;
float _Property_1dc4788b9eca4069baa399efa4413298_Out_0_Float = _Wireframe_Thickness;
float _Property_8b57c7d9cbef4037966ba71e85a6a06c_Out_0_Float = _Wireframe_Anti_aliasing;
float _WireframeRenderer_ece5db6e8dfb4e9fad05ff1bb6cc2309_Wireframe_3_Float;
float2 _WireframeRenderer_ece5db6e8dfb4e9fad05ff1bb6cc2309_BarycentricUV_4_Vector2;
WireframeRenderer_float(IN.uv3.xyz, max(0, _Property_1dc4788b9eca4069baa399efa4413298_Out_0_Float), max(0, _Property_8b57c7d9cbef4037966ba71e85a6a06c_Out_0_Float), 0, _WireframeRenderer_ece5db6e8dfb4e9fad05ff1bb6cc2309_Wireframe_3_Float, _WireframeRenderer_ece5db6e8dfb4e9fad05ff1bb6cc2309_BarycentricUV_4_Vector2);
float4x4 _Property_c3b4c128ba554fe098057745845e9910_Out_0_Matrix4 = _WireframeShaderMaskData1;
float _DynamicMask_8913d339bdd94f139301daaca928d45e_Out_3_Float;
WireframeShaderDynamicMaskCube_float(IN.WorldSpacePosition, _Property_c3b4c128ba554fe098057745845e9910_Out_0_Matrix4, float(0), _DynamicMask_8913d339bdd94f139301daaca928d45e_Out_3_Float);
float4x4 _Property_4558ada8dab04741a34bdee6a310d029_Out_0_Matrix4 = _WireframeShaderMaskData2;
float _DynamicMask_2272a71ebb0c41c996cacac6ba5af67c_Out_3_Float;
WireframeShaderDynamicMaskSphere_float(IN.WorldSpacePosition, _Property_4558ada8dab04741a34bdee6a310d029_Out_0_Matrix4, float(0), _DynamicMask_2272a71ebb0c41c996cacac6ba5af67c_Out_3_Float);
float _Add_93d29f50c0a044ee9e64325292f7e58d_Out_2_Float;
Unity_Add_float(_DynamicMask_8913d339bdd94f139301daaca928d45e_Out_3_Float, _DynamicMask_2272a71ebb0c41c996cacac6ba5af67c_Out_3_Float, _Add_93d29f50c0a044ee9e64325292f7e58d_Out_2_Float);
float _Saturate_a7aaf24f90954c91aa8bf70234072705_Out_1_Float;
Unity_Saturate_float(_Add_93d29f50c0a044ee9e64325292f7e58d_Out_2_Float, _Saturate_a7aaf24f90954c91aa8bf70234072705_Out_1_Float);
float _Multiply_2c4e8cfdcb0840fda6e31d2a9a7c2ab0_Out_2_Float;
Unity_Multiply_float_float(_WireframeRenderer_ece5db6e8dfb4e9fad05ff1bb6cc2309_Wireframe_3_Float, _Saturate_a7aaf24f90954c91aa8bf70234072705_Out_1_Float, _Multiply_2c4e8cfdcb0840fda6e31d2a9a7c2ab0_Out_2_Float);
float4 _Multiply_332e3fb1592245a4a116de6d6dc95b8a_Out_2_Vector4;
Unity_Multiply_float4_float4(_Property_c74b42315a444fa6aab2c9ce9a824d6f_Out_0_Vector4, (_Multiply_2c4e8cfdcb0840fda6e31d2a9a7c2ab0_Out_2_Float.xxxx), _Multiply_332e3fb1592245a4a116de6d6dc95b8a_Out_2_Vector4);
surface.BaseColor = (_Multiply_332e3fb1592245a4a116de6d6dc95b8a_Out_2_Vector4.xyz);
surface.Alpha = float(1);
return surface;
}

// --------------------------------------------------
// Build Graph Inputs
#ifdef HAVE_VFX_MODIFICATION
#define VFX_SRP_ATTRIBUTES Attributes
#define VFX_SRP_VARYINGS Varyings
#define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
#endif
VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal =                          input.normalOS;
    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
    output.ObjectSpacePosition =                        input.positionOS;
#if UNITY_ANY_INSTANCING_ENABLED
#else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
#endif

    return output;
}
SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

#ifdef HAVE_VFX_MODIFICATION
#if VFX_USE_GRAPH_VALUES
    uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
    /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
#endif
    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

#endif

    





    output.WorldSpacePosition = input.positionWS;

    #if UNITY_UV_STARTS_AT_TOP
    #else
    #endif


    output.uv0 = input.texCoord0;
    output.uv1 = input.texCoord1;
    output.uv2 = input.texCoord2;
    output.uv3 = input.texCoord3;
    output.uv4 = input.texCoord4;
    output.uv5 = input.texCoord5;
    output.uv6 = input.texCoord6;
    output.uv7 = input.texCoord7;
#if UNITY_ANY_INSTANCING_ENABLED
#else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

        return output;
}

// --------------------------------------------------
// Main

#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"

// --------------------------------------------------
// Visual Effect Vertex Invocations
#ifdef HAVE_VFX_MODIFICATION
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
#endif

ENDHLSL
}
Pass
{
    Name "MotionVectors"
    Tags
    {
        "LightMode" = "MotionVectors"
    }

// Render State
Cull Off
ZTest LEqual
ZWrite On
ColorMask RG

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM

// Pragmas
#pragma target 3.5
#pragma multi_compile_instancing
#pragma vertex vert
#pragma fragment frag

// Keywords
// PassKeywords: <None>
// GraphKeywords: <None>

// Defines

#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_MOTION_VECTORS


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

// --------------------------------------------------
// Structs and Packing

// custom interpolators pre packing
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

struct Attributes
{
 float3 positionOS : POSITION;
#if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};
struct SurfaceDescriptionInputs
{
};
struct VertexDescriptionInputs
{
 float3 ObjectSpacePosition;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings (Varyings input)
{
PackedVaryings output;
ZERO_INITIALIZE(PackedVaryings, output);
output.positionCS = input.positionCS;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}

Varyings UnpackVaryings (PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)
float _Wireframe_Thickness;
float _Wireframe_Anti_aliasing;
float4 _Wireframe_Color;
UNITY_TEXTURE_STREAMING_DEBUG_VARS;
CBUFFER_END


// Object and Global properties
float4x4 _WireframeShaderMaskData1;
float4x4 _WireframeShaderMaskData2;

// Graph Includes
// GraphIncludes: <None>

// -- Property used by ScenePickingPass
#ifdef SCENEPICKINGPASS
float4 _SelectionID;
#endif

// -- Properties used by SceneSelectionPass
#ifdef SCENESELECTIONPASS
int _ObjectId;
int _PassValue;
#endif

// Graph Functions
// GraphFunctions: <None>

// Custom interpolators pre vertex
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
float3 Position;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
description.Position = IN.ObjectSpacePosition;
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
surface.Alpha = float(1);
return surface;
}

// --------------------------------------------------
// Build Graph Inputs
#ifdef HAVE_VFX_MODIFICATION
#define VFX_SRP_ATTRIBUTES Attributes
#define VFX_SRP_VARYINGS Varyings
#define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
#endif
VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpacePosition =                        input.positionOS;
#if UNITY_ANY_INSTANCING_ENABLED
#else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
#endif

    return output;
}
SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

#ifdef HAVE_VFX_MODIFICATION
#if VFX_USE_GRAPH_VALUES
    uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
    /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
#endif
    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

#endif

    






    #if UNITY_UV_STARTS_AT_TOP
    #else
    #endif


#if UNITY_ANY_INSTANCING_ENABLED
#else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

        return output;
}

// --------------------------------------------------
// Main

#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/MotionVectorPass.hlsl"

// --------------------------------------------------
// Visual Effect Vertex Invocations
#ifdef HAVE_VFX_MODIFICATION
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
#endif

ENDHLSL
}
Pass
{
    Name "DepthNormalsOnly"
    Tags
    {
        "LightMode" = "DepthNormalsOnly"
    }

// Render State
Cull Off
ZTest LEqual
ZWrite On

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM

// Pragmas
#pragma target 2.0
#pragma multi_compile_instancing
#pragma vertex vert
#pragma fragment frag

// Keywords
#pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
// GraphKeywords: <None>

// Defines

#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
#define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
#define VARYINGS_NEED_NORMAL_WS
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
#define _SURFACE_TYPE_TRANSPARENT 1


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

// --------------------------------------------------
// Structs and Packing

// custom interpolators pre packing
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

struct Attributes
{
 float3 positionOS : POSITION;
 float3 normalOS : NORMAL;
 float4 tangentOS : TANGENT;
#if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
 float3 normalWS;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};
struct SurfaceDescriptionInputs
{
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
 float3 normalWS : INTERP0;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings (Varyings input)
{
PackedVaryings output;
ZERO_INITIALIZE(PackedVaryings, output);
output.positionCS = input.positionCS;
output.normalWS.xyz = input.normalWS;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}

Varyings UnpackVaryings (PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
output.normalWS = input.normalWS.xyz;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)
float _Wireframe_Thickness;
float _Wireframe_Anti_aliasing;
float4 _Wireframe_Color;
UNITY_TEXTURE_STREAMING_DEBUG_VARS;
CBUFFER_END


// Object and Global properties
float4x4 _WireframeShaderMaskData1;
float4x4 _WireframeShaderMaskData2;

// Graph Includes
// GraphIncludes: <None>

// -- Property used by ScenePickingPass
#ifdef SCENEPICKINGPASS
float4 _SelectionID;
#endif

// -- Properties used by SceneSelectionPass
#ifdef SCENESELECTIONPASS
int _ObjectId;
int _PassValue;
#endif

// Graph Functions
// GraphFunctions: <None>

// Custom interpolators pre vertex
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
description.Position = IN.ObjectSpacePosition;
description.Normal = IN.ObjectSpaceNormal;
description.Tangent = IN.ObjectSpaceTangent;
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
surface.Alpha = float(1);
return surface;
}

// --------------------------------------------------
// Build Graph Inputs
#ifdef HAVE_VFX_MODIFICATION
#define VFX_SRP_ATTRIBUTES Attributes
#define VFX_SRP_VARYINGS Varyings
#define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
#endif
VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal =                          input.normalOS;
    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
    output.ObjectSpacePosition =                        input.positionOS;
#if UNITY_ANY_INSTANCING_ENABLED
#else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
#endif

    return output;
}
SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

#ifdef HAVE_VFX_MODIFICATION
#if VFX_USE_GRAPH_VALUES
    uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
    /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
#endif
    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

#endif

    






    #if UNITY_UV_STARTS_AT_TOP
    #else
    #endif


#if UNITY_ANY_INSTANCING_ENABLED
#else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

        return output;
}

// --------------------------------------------------
// Main

#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

// --------------------------------------------------
// Visual Effect Vertex Invocations
#ifdef HAVE_VFX_MODIFICATION
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
#endif

ENDHLSL
}
Pass
{
    Name "ShadowCaster"
    Tags
    {
        "LightMode" = "ShadowCaster"
    }

// Render State
Cull Off
ZTest LEqual
ZWrite On
ColorMask 0

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM

// Pragmas
#pragma target 2.0
#pragma multi_compile_instancing
#pragma vertex vert
#pragma fragment frag

// Keywords
#pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
// GraphKeywords: <None>

// Defines

#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
#define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
#define VARYINGS_NEED_NORMAL_WS
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_SHADOWCASTER


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

// --------------------------------------------------
// Structs and Packing

// custom interpolators pre packing
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

struct Attributes
{
 float3 positionOS : POSITION;
 float3 normalOS : NORMAL;
 float4 tangentOS : TANGENT;
#if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
 float3 normalWS;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};
struct SurfaceDescriptionInputs
{
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
 float3 normalWS : INTERP0;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings (Varyings input)
{
PackedVaryings output;
ZERO_INITIALIZE(PackedVaryings, output);
output.positionCS = input.positionCS;
output.normalWS.xyz = input.normalWS;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}

Varyings UnpackVaryings (PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
output.normalWS = input.normalWS.xyz;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)
float _Wireframe_Thickness;
float _Wireframe_Anti_aliasing;
float4 _Wireframe_Color;
UNITY_TEXTURE_STREAMING_DEBUG_VARS;
CBUFFER_END


// Object and Global properties
float4x4 _WireframeShaderMaskData1;
float4x4 _WireframeShaderMaskData2;

// Graph Includes
// GraphIncludes: <None>

// -- Property used by ScenePickingPass
#ifdef SCENEPICKINGPASS
float4 _SelectionID;
#endif

// -- Properties used by SceneSelectionPass
#ifdef SCENESELECTIONPASS
int _ObjectId;
int _PassValue;
#endif

// Graph Functions
// GraphFunctions: <None>

// Custom interpolators pre vertex
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
description.Position = IN.ObjectSpacePosition;
description.Normal = IN.ObjectSpaceNormal;
description.Tangent = IN.ObjectSpaceTangent;
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
surface.Alpha = float(1);
return surface;
}

// --------------------------------------------------
// Build Graph Inputs
#ifdef HAVE_VFX_MODIFICATION
#define VFX_SRP_ATTRIBUTES Attributes
#define VFX_SRP_VARYINGS Varyings
#define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
#endif
VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal =                          input.normalOS;
    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
    output.ObjectSpacePosition =                        input.positionOS;
#if UNITY_ANY_INSTANCING_ENABLED
#else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
#endif

    return output;
}
SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

#ifdef HAVE_VFX_MODIFICATION
#if VFX_USE_GRAPH_VALUES
    uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
    /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
#endif
    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

#endif

    






    #if UNITY_UV_STARTS_AT_TOP
    #else
    #endif


#if UNITY_ANY_INSTANCING_ENABLED
#else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

        return output;
}

// --------------------------------------------------
// Main

#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

// --------------------------------------------------
// Visual Effect Vertex Invocations
#ifdef HAVE_VFX_MODIFICATION
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
#endif

ENDHLSL
}
Pass
{
    Name "GBuffer"
    Tags
    {
        "LightMode" = "UniversalGBuffer"
    }

// Render State
Cull Off
Blend SrcAlpha One, One One
ZTest LEqual
ZWrite Off

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM

// Pragmas
#pragma target 45,0
#pragma exclude_renderers gles3 glcore
#pragma multi_compile_instancing
#pragma instancing_options renderinglayer
#pragma require tessellation
#pragma vertex Vertex
#pragma hull Hull
#pragma domain Domain
#define _WIREFRAME_IS_DYNAMIC
#pragma shader_feature_local _ _WIREFRAME_SHADER_SHAPE_QUAD
#pragma shader_feature_local _ _WIREFRAME_SHADER_STYLE_NORMALIZED _WIREFRAME_SHADER_STYLE_SCREEN_SPACE
#define RENDER_PIPELINE_UNIVERSAL

#pragma fragment frag

// Keywords
#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
#pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
#pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
#pragma multi_compile _ SHADOWS_SHADOWMASK
// GraphKeywords: <None>

// Defines

#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define ATTRIBUTES_NEED_TEXCOORD0
#define ATTRIBUTES_NEED_TEXCOORD1
#define ATTRIBUTES_NEED_TEXCOORD2
#define ATTRIBUTES_NEED_TEXCOORD3
#define ATTRIBUTES_NEED_TEXCOORD4
#define ATTRIBUTES_NEED_TEXCOORD5
#define ATTRIBUTES_NEED_TEXCOORD6
#define ATTRIBUTES_NEED_TEXCOORD7
#define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
#define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define VARYINGS_NEED_TEXCOORD0
#define VARYINGS_NEED_TEXCOORD1
#define VARYINGS_NEED_TEXCOORD2
#define VARYINGS_NEED_TEXCOORD3
#define VARYINGS_NEED_TEXCOORD4
#define VARYINGS_NEED_TEXCOORD5
#define VARYINGS_NEED_TEXCOORD6
#define VARYINGS_NEED_TEXCOORD7
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_GBUFFER
#define _SURFACE_TYPE_TRANSPARENT 1


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

// --------------------------------------------------
// Structs and Packing

// custom interpolators pre packing
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

struct Attributes
{
 float3 positionOS : POSITION;
 float3 normalOS : NORMAL;
 float4 tangentOS : TANGENT;
 float4 uv0 : TEXCOORD0;
 float4 uv1 : TEXCOORD1;
 float4 uv2 : TEXCOORD2;
 float4 uv3 : TEXCOORD3;
 float4 uv4 : TEXCOORD4;
 float4 uv5 : TEXCOORD5;
 float4 uv6 : TEXCOORD6;
 float4 uv7 : TEXCOORD7;
#if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
 float3 positionWS;
 float3 normalWS;
 float4 texCoord0;
 float4 texCoord1;
 float4 texCoord2;
 float4 texCoord3;
 float4 texCoord4;
 float4 texCoord5;
 float4 texCoord6;
 float4 texCoord7;
#if !defined(LIGHTMAP_ON)
 float3 sh;
#endif
#if defined(USE_APV_PROBE_OCCLUSION)
 float4 probeOcclusion;
#endif
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
float3 barycentric;
};
struct SurfaceDescriptionInputs
{
 float3 WorldSpacePosition;
 float4 uv0;
 float4 uv1;
 float4 uv2;
 float4 uv3;
 float4 uv4;
 float4 uv5;
 float4 uv6;
 float4 uv7;
float3 barycentric;
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
};
struct PackedVaryings
{
float3 barycentric : INTERP12;
 float4 positionCS : SV_POSITION;
#if !defined(LIGHTMAP_ON)
 float3 sh : INTERP0;
#endif
#if defined(USE_APV_PROBE_OCCLUSION)
 float4 probeOcclusion : INTERP1;
#endif
 float4 texCoord0 : INTERP2;
 float4 texCoord1 : INTERP3;
 float4 texCoord2 : INTERP4;
 float4 texCoord3 : INTERP5;
 float4 texCoord4 : INTERP6;
 float4 texCoord5 : INTERP7;
 float4 texCoord6 : INTERP8;
 float4 texCoord7 : INTERP9;
 float3 positionWS : INTERP10;
 float3 normalWS : INTERP11;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings (Varyings input)
{
PackedVaryings output;
ZERO_INITIALIZE(PackedVaryings, output);
output.positionCS = input.positionCS;
#if !defined(LIGHTMAP_ON)
output.sh = input.sh;
#endif
#if defined(USE_APV_PROBE_OCCLUSION)
output.probeOcclusion = input.probeOcclusion;
#endif
output.texCoord0.xyzw = input.texCoord0;
output.texCoord1.xyzw = input.texCoord1;
output.texCoord2.xyzw = input.texCoord2;
output.texCoord3.xyzw = input.texCoord3;
output.texCoord4.xyzw = input.texCoord4;
output.texCoord5.xyzw = input.texCoord5;
output.texCoord6.xyzw = input.texCoord6;
output.texCoord7.xyzw = input.texCoord7;
output.positionWS.xyz = input.positionWS;
output.normalWS.xyz = input.normalWS;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
output.barycentric = input.barycentric;
return output;
}

Varyings UnpackVaryings (PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
#if !defined(LIGHTMAP_ON)
output.sh = input.sh;
#endif
#if defined(USE_APV_PROBE_OCCLUSION)
output.probeOcclusion = input.probeOcclusion;
#endif
output.texCoord0 = input.texCoord0.xyzw;
output.texCoord1 = input.texCoord1.xyzw;
output.texCoord2 = input.texCoord2.xyzw;
output.texCoord3 = input.texCoord3.xyzw;
output.texCoord4 = input.texCoord4.xyzw;
output.texCoord5 = input.texCoord5.xyzw;
output.texCoord6 = input.texCoord6.xyzw;
output.texCoord7 = input.texCoord7.xyzw;
output.positionWS = input.positionWS.xyz;
output.normalWS = input.normalWS.xyz;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
output.barycentric = input.barycentric;
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)
float _Wireframe_Thickness;
float _Wireframe_Anti_aliasing;
float4 _Wireframe_Color;
UNITY_TEXTURE_STREAMING_DEBUG_VARS;
CBUFFER_END


// Object and Global properties
float4x4 _WireframeShaderMaskData1;
float4x4 _WireframeShaderMaskData2;

// Graph Includes
// GraphIncludes: <None>

// -- Property used by ScenePickingPass
#ifdef SCENEPICKINGPASS
float4 _SelectionID;
#endif

// -- Properties used by SceneSelectionPass
#ifdef SCENESELECTIONPASS
int _ObjectId;
int _PassValue;
#endif

// Graph Functions

void WireframeRenderer_float(float3 barycentric, float3 thickness, float antiAliasing, float renderInScreenSpace, out float OutWireframe, out float2 OutBarycentricUV)
{
    #if defined(_WIREFRAME_IS_DYNAMIC)
        float3 fw = fwidth(barycentric);

        float3 t = thickness.xxx;

        #if defined(_WIREFRAME_IS_DYNAMIC)
            #if defined(_WIREFRAME_SHADER_STYLE_SCREEN_SPACE)
                t *= fw * 5;
            #endif
        #else
            t *= lerp(1, fw * 5, saturate(renderInScreenSpace));
        #endif                    

        float3 df = barycentric - t;
        df /= fw * antiAliasing * 10 + 1e-6;
        float e = min(df.x, min(df.y, df.z));

        OutWireframe = 1 - smoothstep(0.0, 1.0, e + 0.5);

        df = barycentric / t;
        float u = min(df.x, min(df.y, df.z));
        OutBarycentricUV = float2(saturate(u), 0.5);
    #else
        OutWireframe = 0;
        OutBarycentricUV = float2(0, 0);
    #endif
}

void WireframeShaderDynamicMaskCube_float(float3 vertexPositionWS, float4x4 ShaderData, float Noise, out float Out)
{
            float3 cubePosition = ShaderData[0].xyz;
        	float4 cubeRotation = ShaderData[1].xyzw;
        	float3 cubeScale    = ShaderData[2].xyz;
        	float fallOff       = ShaderData[3].x;
        	float intensity     = ShaderData[3].y;
            

            vertexPositionWS = GetAbsolutePositionWS(vertexPositionWS);
        	float3 v = vertexPositionWS - cubePosition;
        	float3 u = cubeRotation.xyz;
            float w = -cubeRotation.w;
            float3 position =  2.0f * dot(u, v) * u + (w * w - dot(u, u)) * v +  2.0f * w * cross(u, v);

        	float3 boundsMax = cubeScale * 0.5 + Noise;
        	float3 boundsMin = -boundsMax;  

        	float3 s = smoothstep(boundsMin, boundsMin + fallOff, position) - 
        	           smoothstep(boundsMax - fallOff, boundsMax, position);

        	float mask = saturate(s.x * s.y * s.z);

        	Out = mask * intensity;
        }

void WireframeShaderDynamicMaskSphere_float(float3 vertexPositionWS, float4x4 ShaderData, float Noise, out float Out)
{
            float3 spherePosition = ShaderData[0].xyz;
        	float sphereRadius    = ShaderData[0].w;
        	float fallOff         = ShaderData[3].x;
        	float intensity       = ShaderData[3].y;


            vertexPositionWS = GetAbsolutePositionWS(vertexPositionWS);
        	float d = distance(vertexPositionWS, spherePosition);

            float mask = 1 - saturate(max(0, d - Noise - sphereRadius + fallOff) / fallOff);

            Out = mask * intensity;
        }

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Saturate_float(float In, out float Out)
{
    Out = saturate(In);
}

void Unity_Multiply_float_float(float A, float B, out float Out)
{
Out = A * B;
}

void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
{
Out = A * B;
}

// Custom interpolators pre vertex
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
description.Position = IN.ObjectSpacePosition;
description.Normal = IN.ObjectSpaceNormal;
description.Tangent = IN.ObjectSpaceTangent;
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float3 BaseColor;
float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
float4 _Property_c74b42315a444fa6aab2c9ce9a824d6f_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Wireframe_Color) : _Wireframe_Color;
float _Property_1dc4788b9eca4069baa399efa4413298_Out_0_Float = _Wireframe_Thickness;
float _Property_8b57c7d9cbef4037966ba71e85a6a06c_Out_0_Float = _Wireframe_Anti_aliasing;
float _WireframeRenderer_ece5db6e8dfb4e9fad05ff1bb6cc2309_Wireframe_3_Float;
float2 _WireframeRenderer_ece5db6e8dfb4e9fad05ff1bb6cc2309_BarycentricUV_4_Vector2;
WireframeRenderer_float(IN.barycentric.xyz, max(0, _Property_1dc4788b9eca4069baa399efa4413298_Out_0_Float), max(0, _Property_8b57c7d9cbef4037966ba71e85a6a06c_Out_0_Float), 0, _WireframeRenderer_ece5db6e8dfb4e9fad05ff1bb6cc2309_Wireframe_3_Float, _WireframeRenderer_ece5db6e8dfb4e9fad05ff1bb6cc2309_BarycentricUV_4_Vector2);
float4x4 _Property_c3b4c128ba554fe098057745845e9910_Out_0_Matrix4 = _WireframeShaderMaskData1;
float _DynamicMask_8913d339bdd94f139301daaca928d45e_Out_3_Float;
WireframeShaderDynamicMaskCube_float(IN.WorldSpacePosition, _Property_c3b4c128ba554fe098057745845e9910_Out_0_Matrix4, float(0), _DynamicMask_8913d339bdd94f139301daaca928d45e_Out_3_Float);
float4x4 _Property_4558ada8dab04741a34bdee6a310d029_Out_0_Matrix4 = _WireframeShaderMaskData2;
float _DynamicMask_2272a71ebb0c41c996cacac6ba5af67c_Out_3_Float;
WireframeShaderDynamicMaskSphere_float(IN.WorldSpacePosition, _Property_4558ada8dab04741a34bdee6a310d029_Out_0_Matrix4, float(0), _DynamicMask_2272a71ebb0c41c996cacac6ba5af67c_Out_3_Float);
float _Add_93d29f50c0a044ee9e64325292f7e58d_Out_2_Float;
Unity_Add_float(_DynamicMask_8913d339bdd94f139301daaca928d45e_Out_3_Float, _DynamicMask_2272a71ebb0c41c996cacac6ba5af67c_Out_3_Float, _Add_93d29f50c0a044ee9e64325292f7e58d_Out_2_Float);
float _Saturate_a7aaf24f90954c91aa8bf70234072705_Out_1_Float;
Unity_Saturate_float(_Add_93d29f50c0a044ee9e64325292f7e58d_Out_2_Float, _Saturate_a7aaf24f90954c91aa8bf70234072705_Out_1_Float);
float _Multiply_2c4e8cfdcb0840fda6e31d2a9a7c2ab0_Out_2_Float;
Unity_Multiply_float_float(_WireframeRenderer_ece5db6e8dfb4e9fad05ff1bb6cc2309_Wireframe_3_Float, _Saturate_a7aaf24f90954c91aa8bf70234072705_Out_1_Float, _Multiply_2c4e8cfdcb0840fda6e31d2a9a7c2ab0_Out_2_Float);
float4 _Multiply_332e3fb1592245a4a116de6d6dc95b8a_Out_2_Vector4;
Unity_Multiply_float4_float4(_Property_c74b42315a444fa6aab2c9ce9a824d6f_Out_0_Vector4, (_Multiply_2c4e8cfdcb0840fda6e31d2a9a7c2ab0_Out_2_Float.xxxx), _Multiply_332e3fb1592245a4a116de6d6dc95b8a_Out_2_Vector4);
surface.BaseColor = (_Multiply_332e3fb1592245a4a116de6d6dc95b8a_Out_2_Vector4.xyz);
surface.Alpha = float(1);
return surface;
}

// --------------------------------------------------
// Build Graph Inputs
#ifdef HAVE_VFX_MODIFICATION
#define VFX_SRP_ATTRIBUTES Attributes
#define VFX_SRP_VARYINGS Varyings
#define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
#endif
VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal =                          input.normalOS;
    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
    output.ObjectSpacePosition =                        input.positionOS;
#if UNITY_ANY_INSTANCING_ENABLED
#else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
#endif

    return output;
}
SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

#ifdef HAVE_VFX_MODIFICATION
#if VFX_USE_GRAPH_VALUES
    uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
    /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
#endif
    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

#endif

    





    output.WorldSpacePosition = input.positionWS;

    #if UNITY_UV_STARTS_AT_TOP
    #else
    #endif


    output.uv0 = input.texCoord0;
    output.uv1 = input.texCoord1;
    output.uv2 = input.texCoord2;
    output.uv3 = input.texCoord3;
    output.uv4 = input.texCoord4;
    output.uv5 = input.texCoord5;
    output.uv6 = input.texCoord6;
    output.uv7 = input.texCoord7;
#if UNITY_ANY_INSTANCING_ENABLED
#else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

output.barycentric = input.barycentric;
        return output;
}

// --------------------------------------------------
// Main

#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitGBufferPass.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/GBufferOutputFormat.hlsl"

// --------------------------------------------------
// Visual Effect Vertex Invocations
#ifdef HAVE_VFX_MODIFICATION
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
#endif

struct Appdata
{
	float3 positionOS : INTERNALTESSPOS;

	#if defined(ATTRIBUTES_NEED_NORMAL)
		float3 normalOS : NORMAL;
	#endif

	#if defined(ATTRIBUTES_NEED_TANGENT)
		float4 tangentOS : TANGENT;
	#endif

	#if defined(ATTRIBUTES_NEED_TEXCOORD0)
		float4 uv0 : TEXCOORD0;
	#endif

	#if defined(ATTRIBUTES_NEED_TEXCOORD1)
		float4 uv1 : TEXCOORD1;
	#endif

	#if defined(ATTRIBUTES_NEED_TEXCOORD2)
		float4 uv2 : TEXCOORD2;
	#endif

	#if defined(ATTRIBUTES_NEED_TEXCOORD3)
		float4 uv3 : TEXCOORD3;
	#endif

	#if UNITY_VERSION >= 60030000
		#if defined(ATTRIBUTES_NEED_TEXCOORD4)
			float4 uv4 : TEXCOORD4;
		#endif

		#if defined(ATTRIBUTES_NEED_TEXCOORD5)
			float4 uv5 : TEXCOORD5;
		#endif

		#if defined(ATTRIBUTES_NEED_TEXCOORD6)
			float4 uv6 : TEXCOORD6;
		#endif

		#if defined(ATTRIBUTES_NEED_TEXCOORD7)
			float4 uv7 : TEXCOORD7;
		#endif
	#endif

	#if defined(ATTRIBUTES_NEED_COLOR)
		float4 color : COLOR;
	#endif

	UNITY_VERTEX_INPUT_INSTANCE_ID
};

Appdata Vertex (Attributes v)
{
	Appdata o;
	UNITY_SETUP_INSTANCE_ID(v);
	UNITY_TRANSFER_INSTANCE_ID(v, o);

	o.positionOS = v.positionOS;

	#if defined(ATTRIBUTES_NEED_NORMAL)
		o.normalOS = v.normalOS;
	#endif

	#if defined(ATTRIBUTES_NEED_TANGENT)
		o.tangentOS = v.tangentOS;
	#endif

	#if defined(ATTRIBUTES_NEED_TEXCOORD0)
		o.uv0 = v.uv0;
	#endif

	#if defined(ATTRIBUTES_NEED_TEXCOORD1)
		o.uv1 = v.uv1;
	#endif

	#if defined(ATTRIBUTES_NEED_TEXCOORD2)
		o.uv2 = v.uv2;
	#endif

	#if defined(ATTRIBUTES_NEED_TEXCOORD3)
		o.uv3 = v.uv3;
	#endif

	#if UNITY_VERSION >= 60030000
		#if defined(ATTRIBUTES_NEED_TEXCOORD4)
			o.uv4 = v.uv4;
		#endif

		#if defined(ATTRIBUTES_NEED_TEXCOORD5)
			o.uv5 = v.uv5;
		#endif

		#if defined(ATTRIBUTES_NEED_TEXCOORD6)
			o.uv6 = v.uv6;
		#endif

		#if defined(ATTRIBUTES_NEED_TEXCOORD7)
			o.uv7 = v.uv7;
		#endif
	#endif

	#if defined(ATTRIBUTES_NEED_COLOR)
		o.color = v.color;
	#endif

	return o;  
}

struct TessellationFactors 
{
    float edge[3] : SV_TessFactor;
    float inside : SV_InsideTessFactor;
};

TessellationFactors PatchConstantFunction (InputPatch<Appdata,3> input)
{
	TessellationFactors output;	
	output.edge[0] = 1;
	output.edge[1] = 1; 
	output.edge[2] = 1; 
	output.inside = 1;

	return output;
}

[domain("tri")]
[partitioning("integer")]
[outputtopology("triangle_cw")]
[patchconstantfunc("PatchConstantFunction")]
[outputcontrolpoints(3)]
Appdata Hull (InputPatch<Appdata,3> patch, uint id : SV_OutputControlPointID) 
{
	return patch[id];
}

void WireframeShaderCalculateBarycentric(float3 vertex1, float3 vertex2, float3 vertex3, out float3 bary1, out float3 bary2, out float3 bary3)
{	
	#if defined(_WIREFRAME_SHADER_STYLE_NORMALIZED) || defined(_WIREFRAME_SHADER_SHAPE_QUAD)
		float d1 = distance(vertex1, vertex2);
		float d2 = distance(vertex2, vertex3);
		float d3 = distance(vertex3, vertex1);		
	#endif

	#if defined(_WIREFRAME_SHADER_STYLE_NORMALIZED)
	 
		float4 b = float4(0, 
		                  length(cross(vertex3 - vertex1, vertex3 - vertex2)) / d1, 
						  length(cross(vertex1 - vertex2, vertex1 - vertex3)) / d2, 
						  length(cross(vertex2 - vertex1, vertex2 - vertex3)) / d3);
		b /= min(b.y, min(b.z, b.w));

		bary1 = b.xzx;
		bary2 = b.xxw;
		bary3 = b.yxx;	

	#else
		
		bary1 = float3(0, 1, 0);
		bary2 = float3(0, 0, 1);
		bary3 = float3(1, 0, 0);

	#endif


	#if defined(_WIREFRAME_SHADER_SHAPE_QUAD)
		bary1.x = ((d1 > d2) && (d1 > d3)) ? 10000 : 0;
		bary1.z = ((d3 >= d1) && (d3 > d2)) ? 10000 : 0;
		bary2.y = ((d2 >= d1) && (d2 >= d3)) ? 10000 : 0;
	#endif
}

#define TESSELLATION_INTERPOLATE(a) patch[0].a * bary.x + patch[1].a * bary.y + patch[2].a * bary.z

[domain("tri")]
PackedVaryings Domain(TessellationFactors factors, OutputPatch<Appdata, 3> patch, float3 bary : SV_DomainLocation)
{
	Attributes output = (Attributes) 0;
	output.positionOS = TESSELLATION_INTERPOLATE(positionOS);

	#if defined(ATTRIBUTES_NEED_NORMAL)
		output.normalOS = TESSELLATION_INTERPOLATE(normalOS);
	#endif

	#if defined(ATTRIBUTES_NEED_TANGENT)
		output.tangentOS = TESSELLATION_INTERPOLATE(tangentOS);
	#endif

	#if defined(ATTRIBUTES_NEED_TEXCOORD0)
		output.uv0 = TESSELLATION_INTERPOLATE(uv0);
	#endif

	#if defined(ATTRIBUTES_NEED_TEXCOORD1)
		output.uv1 = TESSELLATION_INTERPOLATE(uv1);
	#endif

	#if defined(ATTRIBUTES_NEED_TEXCOORD2)
		output.uv2 = TESSELLATION_INTERPOLATE(uv2);
	#endif

	#if defined(ATTRIBUTES_NEED_TEXCOORD3)
		output.uv3 = TESSELLATION_INTERPOLATE(uv3);
	#endif

	#if UNITY_VERSION >= 60030000
		#if defined(ATTRIBUTES_NEED_TEXCOORD4)
			output.uv4 = TESSELLATION_INTERPOLATE(uv4);
		#endif

		#if defined(ATTRIBUTES_NEED_TEXCOORD5)
			output.uv5 = TESSELLATION_INTERPOLATE(uv5);
		#endif

		#if defined(ATTRIBUTES_NEED_TEXCOORD6)
			output.uv6 = TESSELLATION_INTERPOLATE(uv6);
		#endif

		#if defined(ATTRIBUTES_NEED_TEXCOORD7)
			output.uv7 = TESSELLATION_INTERPOLATE(uv7);
		#endif
	#endif

	#if defined(ATTRIBUTES_NEED_COLOR)
		output.color = TESSELLATION_INTERPOLATE(color);
	#endif

	UNITY_TRANSFER_INSTANCE_ID(patch[0], output);


    #if defined(RENDER_PIPELINE_HIGH_DEFINITION) && ((SHADERPASS == SHADERPASS_FORWARD && defined(_WRITE_TRANSPARENT_MOTION_VECTOR)) || (SHADERPASS == SHADERPASS_FORWARD_UNLIT && defined(_WRITE_TRANSPARENT_MOTION_VECTOR)) || (SHADERPASS == SHADERPASS_MOTION_VECTORS))
        AttributesPass inputPass = (AttributesPass)0;
	    PackedVaryings pv = vert(output, inputPass);
    #else
        PackedVaryings pv = vert(output);
    #endif


	float3 b0;
	float3 b1;
	float3 b2;
	WireframeShaderCalculateBarycentric(patch[0].positionOS, patch[1].positionOS, patch[2].positionOS, b0, b1, b2);

	pv.barycentric = b0 * bary.x + b1 * bary.y + b2 * bary.z;


	return pv;
}
ENDHLSL
}
Pass
{
    Name "SceneSelectionPass"
    Tags
    {
        "LightMode" = "SceneSelectionPass"
    }

// Render State
Cull Off

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM

// Pragmas
#pragma target 2.0
#pragma vertex vert
#pragma fragment frag

// Keywords
// PassKeywords: <None>
// GraphKeywords: <None>

// Defines

#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
#define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_DEPTHONLY
#define SCENESELECTIONPASS 1
#define ALPHA_CLIP_THRESHOLD 1


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

// --------------------------------------------------
// Structs and Packing

// custom interpolators pre packing
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

struct Attributes
{
 float3 positionOS : POSITION;
 float3 normalOS : NORMAL;
 float4 tangentOS : TANGENT;
#if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};
struct SurfaceDescriptionInputs
{
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings (Varyings input)
{
PackedVaryings output;
ZERO_INITIALIZE(PackedVaryings, output);
output.positionCS = input.positionCS;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}

Varyings UnpackVaryings (PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)
float _Wireframe_Thickness;
float _Wireframe_Anti_aliasing;
float4 _Wireframe_Color;
UNITY_TEXTURE_STREAMING_DEBUG_VARS;
CBUFFER_END


// Object and Global properties
float4x4 _WireframeShaderMaskData1;
float4x4 _WireframeShaderMaskData2;

// Graph Includes
// GraphIncludes: <None>

// -- Property used by ScenePickingPass
#ifdef SCENEPICKINGPASS
float4 _SelectionID;
#endif

// -- Properties used by SceneSelectionPass
#ifdef SCENESELECTIONPASS
int _ObjectId;
int _PassValue;
#endif

// Graph Functions
// GraphFunctions: <None>

// Custom interpolators pre vertex
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
description.Position = IN.ObjectSpacePosition;
description.Normal = IN.ObjectSpaceNormal;
description.Tangent = IN.ObjectSpaceTangent;
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
surface.Alpha = float(1);
return surface;
}

// --------------------------------------------------
// Build Graph Inputs
#ifdef HAVE_VFX_MODIFICATION
#define VFX_SRP_ATTRIBUTES Attributes
#define VFX_SRP_VARYINGS Varyings
#define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
#endif
VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal =                          input.normalOS;
    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
    output.ObjectSpacePosition =                        input.positionOS;
#if UNITY_ANY_INSTANCING_ENABLED
#else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
#endif

    return output;
}
SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

#ifdef HAVE_VFX_MODIFICATION
#if VFX_USE_GRAPH_VALUES
    uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
    /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
#endif
    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

#endif

    






    #if UNITY_UV_STARTS_AT_TOP
    #else
    #endif


#if UNITY_ANY_INSTANCING_ENABLED
#else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

        return output;
}

// --------------------------------------------------
// Main

#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

// --------------------------------------------------
// Visual Effect Vertex Invocations
#ifdef HAVE_VFX_MODIFICATION
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
#endif

ENDHLSL
}
Pass
{
    Name "ScenePickingPass"
    Tags
    {
        "LightMode" = "Picking"
    }

// Render State
Cull Off

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM

// Pragmas
#pragma target 20,0
#pragma require tessellation
#pragma vertex Vertex
#pragma hull Hull
#pragma domain Domain
#define _WIREFRAME_IS_DYNAMIC
#pragma shader_feature_local _ _WIREFRAME_SHADER_SHAPE_QUAD
#pragma shader_feature_local _ _WIREFRAME_SHADER_STYLE_NORMALIZED _WIREFRAME_SHADER_STYLE_SCREEN_SPACE
#define RENDER_PIPELINE_UNIVERSAL

#pragma fragment frag

// Keywords
// PassKeywords: <None>
// GraphKeywords: <None>

// Defines

#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define ATTRIBUTES_NEED_TEXCOORD0
#define ATTRIBUTES_NEED_TEXCOORD1
#define ATTRIBUTES_NEED_TEXCOORD2
#define ATTRIBUTES_NEED_TEXCOORD3
#define ATTRIBUTES_NEED_TEXCOORD4
#define ATTRIBUTES_NEED_TEXCOORD5
#define ATTRIBUTES_NEED_TEXCOORD6
#define ATTRIBUTES_NEED_TEXCOORD7
#define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
#define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_TEXCOORD0
#define VARYINGS_NEED_TEXCOORD1
#define VARYINGS_NEED_TEXCOORD2
#define VARYINGS_NEED_TEXCOORD3
#define VARYINGS_NEED_TEXCOORD4
#define VARYINGS_NEED_TEXCOORD5
#define VARYINGS_NEED_TEXCOORD6
#define VARYINGS_NEED_TEXCOORD7
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_DEPTHONLY
#define SCENEPICKINGPASS 1
#define ALPHA_CLIP_THRESHOLD 1


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

// --------------------------------------------------
// Structs and Packing

// custom interpolators pre packing
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

struct Attributes
{
 float3 positionOS : POSITION;
 float3 normalOS : NORMAL;
 float4 tangentOS : TANGENT;
 float4 uv0 : TEXCOORD0;
 float4 uv1 : TEXCOORD1;
 float4 uv2 : TEXCOORD2;
 float4 uv3 : TEXCOORD3;
 float4 uv4 : TEXCOORD4;
 float4 uv5 : TEXCOORD5;
 float4 uv6 : TEXCOORD6;
 float4 uv7 : TEXCOORD7;
#if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
 float3 positionWS;
 float4 texCoord0;
 float4 texCoord1;
 float4 texCoord2;
 float4 texCoord3;
 float4 texCoord4;
 float4 texCoord5;
 float4 texCoord6;
 float4 texCoord7;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
float3 barycentric;
};
struct SurfaceDescriptionInputs
{
 float3 WorldSpacePosition;
 float4 uv0;
 float4 uv1;
 float4 uv2;
 float4 uv3;
 float4 uv4;
 float4 uv5;
 float4 uv6;
 float4 uv7;
float3 barycentric;
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
};
struct PackedVaryings
{
float3 barycentric : INTERP9;
 float4 positionCS : SV_POSITION;
 float4 texCoord0 : INTERP0;
 float4 texCoord1 : INTERP1;
 float4 texCoord2 : INTERP2;
 float4 texCoord3 : INTERP3;
 float4 texCoord4 : INTERP4;
 float4 texCoord5 : INTERP5;
 float4 texCoord6 : INTERP6;
 float4 texCoord7 : INTERP7;
 float3 positionWS : INTERP8;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings (Varyings input)
{
PackedVaryings output;
ZERO_INITIALIZE(PackedVaryings, output);
output.positionCS = input.positionCS;
output.texCoord0.xyzw = input.texCoord0;
output.texCoord1.xyzw = input.texCoord1;
output.texCoord2.xyzw = input.texCoord2;
output.texCoord3.xyzw = input.texCoord3;
output.texCoord4.xyzw = input.texCoord4;
output.texCoord5.xyzw = input.texCoord5;
output.texCoord6.xyzw = input.texCoord6;
output.texCoord7.xyzw = input.texCoord7;
output.positionWS.xyz = input.positionWS;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
output.barycentric = input.barycentric;
return output;
}

Varyings UnpackVaryings (PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
output.texCoord0 = input.texCoord0.xyzw;
output.texCoord1 = input.texCoord1.xyzw;
output.texCoord2 = input.texCoord2.xyzw;
output.texCoord3 = input.texCoord3.xyzw;
output.texCoord4 = input.texCoord4.xyzw;
output.texCoord5 = input.texCoord5.xyzw;
output.texCoord6 = input.texCoord6.xyzw;
output.texCoord7 = input.texCoord7.xyzw;
output.positionWS = input.positionWS.xyz;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
output.barycentric = input.barycentric;
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)
float _Wireframe_Thickness;
float _Wireframe_Anti_aliasing;
float4 _Wireframe_Color;
UNITY_TEXTURE_STREAMING_DEBUG_VARS;
CBUFFER_END


// Object and Global properties
float4x4 _WireframeShaderMaskData1;
float4x4 _WireframeShaderMaskData2;

// Graph Includes
// GraphIncludes: <None>

// -- Property used by ScenePickingPass
#ifdef SCENEPICKINGPASS
float4 _SelectionID;
#endif

// -- Properties used by SceneSelectionPass
#ifdef SCENESELECTIONPASS
int _ObjectId;
int _PassValue;
#endif

// Graph Functions

void WireframeRenderer_float(float3 barycentric, float3 thickness, float antiAliasing, float renderInScreenSpace, out float OutWireframe, out float2 OutBarycentricUV)
{
    #if defined(_WIREFRAME_IS_DYNAMIC)
        float3 fw = fwidth(barycentric);

        float3 t = thickness.xxx;

        #if defined(_WIREFRAME_IS_DYNAMIC)
            #if defined(_WIREFRAME_SHADER_STYLE_SCREEN_SPACE)
                t *= fw * 5;
            #endif
        #else
            t *= lerp(1, fw * 5, saturate(renderInScreenSpace));
        #endif                    

        float3 df = barycentric - t;
        df /= fw * antiAliasing * 10 + 1e-6;
        float e = min(df.x, min(df.y, df.z));

        OutWireframe = 1 - smoothstep(0.0, 1.0, e + 0.5);

        df = barycentric / t;
        float u = min(df.x, min(df.y, df.z));
        OutBarycentricUV = float2(saturate(u), 0.5);
    #else
        OutWireframe = 0;
        OutBarycentricUV = float2(0, 0);
    #endif
}

void WireframeShaderDynamicMaskCube_float(float3 vertexPositionWS, float4x4 ShaderData, float Noise, out float Out)
{
            float3 cubePosition = ShaderData[0].xyz;
        	float4 cubeRotation = ShaderData[1].xyzw;
        	float3 cubeScale    = ShaderData[2].xyz;
        	float fallOff       = ShaderData[3].x;
        	float intensity     = ShaderData[3].y;
            

            vertexPositionWS = GetAbsolutePositionWS(vertexPositionWS);
        	float3 v = vertexPositionWS - cubePosition;
        	float3 u = cubeRotation.xyz;
            float w = -cubeRotation.w;
            float3 position =  2.0f * dot(u, v) * u + (w * w - dot(u, u)) * v +  2.0f * w * cross(u, v);

        	float3 boundsMax = cubeScale * 0.5 + Noise;
        	float3 boundsMin = -boundsMax;  

        	float3 s = smoothstep(boundsMin, boundsMin + fallOff, position) - 
        	           smoothstep(boundsMax - fallOff, boundsMax, position);

        	float mask = saturate(s.x * s.y * s.z);

        	Out = mask * intensity;
        }

void WireframeShaderDynamicMaskSphere_float(float3 vertexPositionWS, float4x4 ShaderData, float Noise, out float Out)
{
            float3 spherePosition = ShaderData[0].xyz;
        	float sphereRadius    = ShaderData[0].w;
        	float fallOff         = ShaderData[3].x;
        	float intensity       = ShaderData[3].y;


            vertexPositionWS = GetAbsolutePositionWS(vertexPositionWS);
        	float d = distance(vertexPositionWS, spherePosition);

            float mask = 1 - saturate(max(0, d - Noise - sphereRadius + fallOff) / fallOff);

            Out = mask * intensity;
        }

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Saturate_float(float In, out float Out)
{
    Out = saturate(In);
}

void Unity_Multiply_float_float(float A, float B, out float Out)
{
Out = A * B;
}

void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
{
Out = A * B;
}

// Custom interpolators pre vertex
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
description.Position = IN.ObjectSpacePosition;
description.Normal = IN.ObjectSpaceNormal;
description.Tangent = IN.ObjectSpaceTangent;
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float3 BaseColor;
float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
float4 _Property_c74b42315a444fa6aab2c9ce9a824d6f_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Wireframe_Color) : _Wireframe_Color;
float _Property_1dc4788b9eca4069baa399efa4413298_Out_0_Float = _Wireframe_Thickness;
float _Property_8b57c7d9cbef4037966ba71e85a6a06c_Out_0_Float = _Wireframe_Anti_aliasing;
float _WireframeRenderer_ece5db6e8dfb4e9fad05ff1bb6cc2309_Wireframe_3_Float;
float2 _WireframeRenderer_ece5db6e8dfb4e9fad05ff1bb6cc2309_BarycentricUV_4_Vector2;
WireframeRenderer_float(IN.barycentric.xyz, max(0, _Property_1dc4788b9eca4069baa399efa4413298_Out_0_Float), max(0, _Property_8b57c7d9cbef4037966ba71e85a6a06c_Out_0_Float), 0, _WireframeRenderer_ece5db6e8dfb4e9fad05ff1bb6cc2309_Wireframe_3_Float, _WireframeRenderer_ece5db6e8dfb4e9fad05ff1bb6cc2309_BarycentricUV_4_Vector2);
float4x4 _Property_c3b4c128ba554fe098057745845e9910_Out_0_Matrix4 = _WireframeShaderMaskData1;
float _DynamicMask_8913d339bdd94f139301daaca928d45e_Out_3_Float;
WireframeShaderDynamicMaskCube_float(IN.WorldSpacePosition, _Property_c3b4c128ba554fe098057745845e9910_Out_0_Matrix4, float(0), _DynamicMask_8913d339bdd94f139301daaca928d45e_Out_3_Float);
float4x4 _Property_4558ada8dab04741a34bdee6a310d029_Out_0_Matrix4 = _WireframeShaderMaskData2;
float _DynamicMask_2272a71ebb0c41c996cacac6ba5af67c_Out_3_Float;
WireframeShaderDynamicMaskSphere_float(IN.WorldSpacePosition, _Property_4558ada8dab04741a34bdee6a310d029_Out_0_Matrix4, float(0), _DynamicMask_2272a71ebb0c41c996cacac6ba5af67c_Out_3_Float);
float _Add_93d29f50c0a044ee9e64325292f7e58d_Out_2_Float;
Unity_Add_float(_DynamicMask_8913d339bdd94f139301daaca928d45e_Out_3_Float, _DynamicMask_2272a71ebb0c41c996cacac6ba5af67c_Out_3_Float, _Add_93d29f50c0a044ee9e64325292f7e58d_Out_2_Float);
float _Saturate_a7aaf24f90954c91aa8bf70234072705_Out_1_Float;
Unity_Saturate_float(_Add_93d29f50c0a044ee9e64325292f7e58d_Out_2_Float, _Saturate_a7aaf24f90954c91aa8bf70234072705_Out_1_Float);
float _Multiply_2c4e8cfdcb0840fda6e31d2a9a7c2ab0_Out_2_Float;
Unity_Multiply_float_float(_WireframeRenderer_ece5db6e8dfb4e9fad05ff1bb6cc2309_Wireframe_3_Float, _Saturate_a7aaf24f90954c91aa8bf70234072705_Out_1_Float, _Multiply_2c4e8cfdcb0840fda6e31d2a9a7c2ab0_Out_2_Float);
float4 _Multiply_332e3fb1592245a4a116de6d6dc95b8a_Out_2_Vector4;
Unity_Multiply_float4_float4(_Property_c74b42315a444fa6aab2c9ce9a824d6f_Out_0_Vector4, (_Multiply_2c4e8cfdcb0840fda6e31d2a9a7c2ab0_Out_2_Float.xxxx), _Multiply_332e3fb1592245a4a116de6d6dc95b8a_Out_2_Vector4);
surface.BaseColor = (_Multiply_332e3fb1592245a4a116de6d6dc95b8a_Out_2_Vector4.xyz);
surface.Alpha = float(1);
return surface;
}

// --------------------------------------------------
// Build Graph Inputs
#ifdef HAVE_VFX_MODIFICATION
#define VFX_SRP_ATTRIBUTES Attributes
#define VFX_SRP_VARYINGS Varyings
#define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
#endif
VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal =                          input.normalOS;
    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
    output.ObjectSpacePosition =                        input.positionOS;
#if UNITY_ANY_INSTANCING_ENABLED
#else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
#endif

    return output;
}
SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

#ifdef HAVE_VFX_MODIFICATION
#if VFX_USE_GRAPH_VALUES
    uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
    /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
#endif
    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

#endif

    





    output.WorldSpacePosition = input.positionWS;

    #if UNITY_UV_STARTS_AT_TOP
    #else
    #endif


    output.uv0 = input.texCoord0;
    output.uv1 = input.texCoord1;
    output.uv2 = input.texCoord2;
    output.uv3 = input.texCoord3;
    output.uv4 = input.texCoord4;
    output.uv5 = input.texCoord5;
    output.uv6 = input.texCoord6;
    output.uv7 = input.texCoord7;
#if UNITY_ANY_INSTANCING_ENABLED
#else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

output.barycentric = input.barycentric;
        return output;
}

// --------------------------------------------------
// Main

#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

// --------------------------------------------------
// Visual Effect Vertex Invocations
#ifdef HAVE_VFX_MODIFICATION
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
#endif

struct Appdata
{
	float3 positionOS : INTERNALTESSPOS;

	#if defined(ATTRIBUTES_NEED_NORMAL)
		float3 normalOS : NORMAL;
	#endif

	#if defined(ATTRIBUTES_NEED_TANGENT)
		float4 tangentOS : TANGENT;
	#endif

	#if defined(ATTRIBUTES_NEED_TEXCOORD0)
		float4 uv0 : TEXCOORD0;
	#endif

	#if defined(ATTRIBUTES_NEED_TEXCOORD1)
		float4 uv1 : TEXCOORD1;
	#endif

	#if defined(ATTRIBUTES_NEED_TEXCOORD2)
		float4 uv2 : TEXCOORD2;
	#endif

	#if defined(ATTRIBUTES_NEED_TEXCOORD3)
		float4 uv3 : TEXCOORD3;
	#endif

	#if UNITY_VERSION >= 60030000
		#if defined(ATTRIBUTES_NEED_TEXCOORD4)
			float4 uv4 : TEXCOORD4;
		#endif

		#if defined(ATTRIBUTES_NEED_TEXCOORD5)
			float4 uv5 : TEXCOORD5;
		#endif

		#if defined(ATTRIBUTES_NEED_TEXCOORD6)
			float4 uv6 : TEXCOORD6;
		#endif

		#if defined(ATTRIBUTES_NEED_TEXCOORD7)
			float4 uv7 : TEXCOORD7;
		#endif
	#endif

	#if defined(ATTRIBUTES_NEED_COLOR)
		float4 color : COLOR;
	#endif

	UNITY_VERTEX_INPUT_INSTANCE_ID
};

Appdata Vertex (Attributes v)
{
	Appdata o;
	UNITY_SETUP_INSTANCE_ID(v);
	UNITY_TRANSFER_INSTANCE_ID(v, o);

	o.positionOS = v.positionOS;

	#if defined(ATTRIBUTES_NEED_NORMAL)
		o.normalOS = v.normalOS;
	#endif

	#if defined(ATTRIBUTES_NEED_TANGENT)
		o.tangentOS = v.tangentOS;
	#endif

	#if defined(ATTRIBUTES_NEED_TEXCOORD0)
		o.uv0 = v.uv0;
	#endif

	#if defined(ATTRIBUTES_NEED_TEXCOORD1)
		o.uv1 = v.uv1;
	#endif

	#if defined(ATTRIBUTES_NEED_TEXCOORD2)
		o.uv2 = v.uv2;
	#endif

	#if defined(ATTRIBUTES_NEED_TEXCOORD3)
		o.uv3 = v.uv3;
	#endif

	#if UNITY_VERSION >= 60030000
		#if defined(ATTRIBUTES_NEED_TEXCOORD4)
			o.uv4 = v.uv4;
		#endif

		#if defined(ATTRIBUTES_NEED_TEXCOORD5)
			o.uv5 = v.uv5;
		#endif

		#if defined(ATTRIBUTES_NEED_TEXCOORD6)
			o.uv6 = v.uv6;
		#endif

		#if defined(ATTRIBUTES_NEED_TEXCOORD7)
			o.uv7 = v.uv7;
		#endif
	#endif

	#if defined(ATTRIBUTES_NEED_COLOR)
		o.color = v.color;
	#endif

	return o;  
}

struct TessellationFactors 
{
    float edge[3] : SV_TessFactor;
    float inside : SV_InsideTessFactor;
};

TessellationFactors PatchConstantFunction (InputPatch<Appdata,3> input)
{
	TessellationFactors output;	
	output.edge[0] = 1;
	output.edge[1] = 1; 
	output.edge[2] = 1; 
	output.inside = 1;

	return output;
}

[domain("tri")]
[partitioning("integer")]
[outputtopology("triangle_cw")]
[patchconstantfunc("PatchConstantFunction")]
[outputcontrolpoints(3)]
Appdata Hull (InputPatch<Appdata,3> patch, uint id : SV_OutputControlPointID) 
{
	return patch[id];
}

void WireframeShaderCalculateBarycentric(float3 vertex1, float3 vertex2, float3 vertex3, out float3 bary1, out float3 bary2, out float3 bary3)
{	
	#if defined(_WIREFRAME_SHADER_STYLE_NORMALIZED) || defined(_WIREFRAME_SHADER_SHAPE_QUAD)
		float d1 = distance(vertex1, vertex2);
		float d2 = distance(vertex2, vertex3);
		float d3 = distance(vertex3, vertex1);		
	#endif

	#if defined(_WIREFRAME_SHADER_STYLE_NORMALIZED)
	 
		float4 b = float4(0, 
		                  length(cross(vertex3 - vertex1, vertex3 - vertex2)) / d1, 
						  length(cross(vertex1 - vertex2, vertex1 - vertex3)) / d2, 
						  length(cross(vertex2 - vertex1, vertex2 - vertex3)) / d3);
		b /= min(b.y, min(b.z, b.w));

		bary1 = b.xzx;
		bary2 = b.xxw;
		bary3 = b.yxx;	

	#else
		
		bary1 = float3(0, 1, 0);
		bary2 = float3(0, 0, 1);
		bary3 = float3(1, 0, 0);

	#endif


	#if defined(_WIREFRAME_SHADER_SHAPE_QUAD)
		bary1.x = ((d1 > d2) && (d1 > d3)) ? 10000 : 0;
		bary1.z = ((d3 >= d1) && (d3 > d2)) ? 10000 : 0;
		bary2.y = ((d2 >= d1) && (d2 >= d3)) ? 10000 : 0;
	#endif
}

#define TESSELLATION_INTERPOLATE(a) patch[0].a * bary.x + patch[1].a * bary.y + patch[2].a * bary.z

[domain("tri")]
PackedVaryings Domain(TessellationFactors factors, OutputPatch<Appdata, 3> patch, float3 bary : SV_DomainLocation)
{
	Attributes output = (Attributes) 0;
	output.positionOS = TESSELLATION_INTERPOLATE(positionOS);

	#if defined(ATTRIBUTES_NEED_NORMAL)
		output.normalOS = TESSELLATION_INTERPOLATE(normalOS);
	#endif

	#if defined(ATTRIBUTES_NEED_TANGENT)
		output.tangentOS = TESSELLATION_INTERPOLATE(tangentOS);
	#endif

	#if defined(ATTRIBUTES_NEED_TEXCOORD0)
		output.uv0 = TESSELLATION_INTERPOLATE(uv0);
	#endif

	#if defined(ATTRIBUTES_NEED_TEXCOORD1)
		output.uv1 = TESSELLATION_INTERPOLATE(uv1);
	#endif

	#if defined(ATTRIBUTES_NEED_TEXCOORD2)
		output.uv2 = TESSELLATION_INTERPOLATE(uv2);
	#endif

	#if defined(ATTRIBUTES_NEED_TEXCOORD3)
		output.uv3 = TESSELLATION_INTERPOLATE(uv3);
	#endif

	#if UNITY_VERSION >= 60030000
		#if defined(ATTRIBUTES_NEED_TEXCOORD4)
			output.uv4 = TESSELLATION_INTERPOLATE(uv4);
		#endif

		#if defined(ATTRIBUTES_NEED_TEXCOORD5)
			output.uv5 = TESSELLATION_INTERPOLATE(uv5);
		#endif

		#if defined(ATTRIBUTES_NEED_TEXCOORD6)
			output.uv6 = TESSELLATION_INTERPOLATE(uv6);
		#endif

		#if defined(ATTRIBUTES_NEED_TEXCOORD7)
			output.uv7 = TESSELLATION_INTERPOLATE(uv7);
		#endif
	#endif

	#if defined(ATTRIBUTES_NEED_COLOR)
		output.color = TESSELLATION_INTERPOLATE(color);
	#endif

	UNITY_TRANSFER_INSTANCE_ID(patch[0], output);


    #if defined(RENDER_PIPELINE_HIGH_DEFINITION) && ((SHADERPASS == SHADERPASS_FORWARD && defined(_WRITE_TRANSPARENT_MOTION_VECTOR)) || (SHADERPASS == SHADERPASS_FORWARD_UNLIT && defined(_WRITE_TRANSPARENT_MOTION_VECTOR)) || (SHADERPASS == SHADERPASS_MOTION_VECTORS))
        AttributesPass inputPass = (AttributesPass)0;
	    PackedVaryings pv = vert(output, inputPass);
    #else
        PackedVaryings pv = vert(output);
    #endif


	float3 b0;
	float3 b1;
	float3 b2;
	WireframeShaderCalculateBarycentric(patch[0].positionOS, patch[1].positionOS, patch[2].positionOS, b0, b1, b2);

	pv.barycentric = b0 * bary.x + b1 * bary.y + b2 * bary.z;


	return pv;
}
ENDHLSL
}
}
CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
CustomEditorForRenderPipeline "UnityEditor.ShaderGraphUnlitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
FallBack "Hidden/Shader Graph/FallbackError"
}

/*ShaderGraphBody_Begin
{
    "m_SGVersion": 3,
    "m_Type": "UnityEditor.ShaderGraph.GraphData",
    "m_ObjectId": "35927402641e4517bcb949df90092197",
    "m_Properties": [
        {
            "m_Id": "46fff3d947ef48aba19f8af053342064"
        },
        {
            "m_Id": "fa96b8e4c3cf4ba39c8692064c29b868"
        },
        {
            "m_Id": "f96e48a170a3461ea6881cc0b6a34099"
        },
        {
            "m_Id": "27366eacf0ae411bb25428a818ec1c5a"
        },
        {
            "m_Id": "d457418e22434e0587988d59fb8f2e12"
        }
    ],
    "m_Keywords": [],
    "m_Dropdowns": [],
    "m_CategoryData": [
        {
            "m_Id": "dd6fcdf0141b461d9ce07ca51467b3c4"
        }
    ],
    "m_Nodes": [
        {
            "m_Id": "a0ff7a5655a241a693febc2166745dd3"
        },
        {
            "m_Id": "1dc4788b9eca4069baa399efa4413298"
        },
        {
            "m_Id": "8b57c7d9cbef4037966ba71e85a6a06c"
        },
        {
            "m_Id": "c74b42315a444fa6aab2c9ce9a824d6f"
        },
        {
            "m_Id": "332e3fb1592245a4a116de6d6dc95b8a"
        },
        {
            "m_Id": "2c4e8cfdcb0840fda6e31d2a9a7c2ab0"
        },
        {
            "m_Id": "65dfa2755ddf4a27869d138fea1957b6"
        },
        {
            "m_Id": "8dae6a3aaeac4d2c8120d1cee1312e5f"
        },
        {
            "m_Id": "200455910ddd4cdf8bc49fa459421e1a"
        },
        {
            "m_Id": "c7a7bb8c9f2d4ee5af3a7f0219e07689"
        },
        {
            "m_Id": "c3b4c128ba554fe098057745845e9910"
        },
        {
            "m_Id": "4558ada8dab04741a34bdee6a310d029"
        },
        {
            "m_Id": "93d29f50c0a044ee9e64325292f7e58d"
        },
        {
            "m_Id": "a7aaf24f90954c91aa8bf70234072705"
        },
        {
            "m_Id": "8913d339bdd94f139301daaca928d45e"
        },
        {
            "m_Id": "2272a71ebb0c41c996cacac6ba5af67c"
        },
        {
            "m_Id": "ece5db6e8dfb4e9fad05ff1bb6cc2309"
        }
    ],
    "m_GroupDatas": [
        {
            "m_Id": "934bf1fbccb7436f8d9c204049f396c2"
        }
    ],
    "m_StickyNoteDatas": [],
    "m_Edges": [
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "1dc4788b9eca4069baa399efa4413298"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "ece5db6e8dfb4e9fad05ff1bb6cc2309"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "2272a71ebb0c41c996cacac6ba5af67c"
                },
                "m_SlotId": 3
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "93d29f50c0a044ee9e64325292f7e58d"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "2c4e8cfdcb0840fda6e31d2a9a7c2ab0"
                },
                "m_SlotId": 2
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "332e3fb1592245a4a116de6d6dc95b8a"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "332e3fb1592245a4a116de6d6dc95b8a"
                },
                "m_SlotId": 2
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "a0ff7a5655a241a693febc2166745dd3"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "4558ada8dab04741a34bdee6a310d029"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "2272a71ebb0c41c996cacac6ba5af67c"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "8913d339bdd94f139301daaca928d45e"
                },
                "m_SlotId": 3
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "93d29f50c0a044ee9e64325292f7e58d"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "8b57c7d9cbef4037966ba71e85a6a06c"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "ece5db6e8dfb4e9fad05ff1bb6cc2309"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "93d29f50c0a044ee9e64325292f7e58d"
                },
                "m_SlotId": 2
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "a7aaf24f90954c91aa8bf70234072705"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "a7aaf24f90954c91aa8bf70234072705"
                },
                "m_SlotId": 1
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "2c4e8cfdcb0840fda6e31d2a9a7c2ab0"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "c3b4c128ba554fe098057745845e9910"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "8913d339bdd94f139301daaca928d45e"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "c74b42315a444fa6aab2c9ce9a824d6f"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "332e3fb1592245a4a116de6d6dc95b8a"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "ece5db6e8dfb4e9fad05ff1bb6cc2309"
                },
                "m_SlotId": 3
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "2c4e8cfdcb0840fda6e31d2a9a7c2ab0"
                },
                "m_SlotId": 0
            }
        }
    ],
    "m_VertexContext": {
        "m_Position": {
            "x": 0.0,
            "y": 0.0
        },
        "m_Blocks": [
            {
                "m_Id": "65dfa2755ddf4a27869d138fea1957b6"
            },
            {
                "m_Id": "8dae6a3aaeac4d2c8120d1cee1312e5f"
            },
            {
                "m_Id": "200455910ddd4cdf8bc49fa459421e1a"
            }
        ]
    },
    "m_FragmentContext": {
        "m_Position": {
            "x": 0.0,
            "y": 200.0
        },
        "m_Blocks": [
            {
                "m_Id": "a0ff7a5655a241a693febc2166745dd3"
            },
            {
                "m_Id": "c7a7bb8c9f2d4ee5af3a7f0219e07689"
            }
        ]
    },
    "m_PreviewData": {
        "serializedMesh": {
            "m_SerializedMesh": "{\"mesh\":{\"instanceID\":0}}",
            "m_Guid": ""
        },
        "preventRotation": false
    },
    "m_Path": "Amazing Assets/Dynamic Wireframe Shader/Examples/Masks",
    "m_GraphPrecision": 1,
    "m_PreviewMode": 2,
    "m_OutputNode": {
        "m_Id": ""
    },
    "m_ActiveTargets": [
        {
            "m_Id": "dec45dfe63994bc89826658d10a3ebef"
        }
    ]
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "068af20f662a46cfbcc8d41b6423b55c",
    "m_Id": 3,
    "m_DisplayName": "Out",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "Out",
    "m_StageCapability": 3,
    "m_Value": 0.0,
    "m_DefaultValue": 0.0,
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "0a48d57fa25d4854b02a09db6dac2370",
    "m_Id": 2,
    "m_DisplayName": "Noise",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "Noise",
    "m_StageCapability": 3,
    "m_Value": 0.0,
    "m_DefaultValue": 0.0,
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.Rendering.HighDefinition.ShaderGraph.LightingData",
    "m_ObjectId": "18c9698050f74381b4641de98bce28e1",
    "m_NormalDropOffSpace": 0,
    "m_BlendPreserveSpecular": true,
    "m_ReceiveDecals": true,
    "m_ReceiveSSR": true,
    "m_ReceiveSSRTransparent": false,
    "m_SpecularAA": false,
    "m_SpecularOcclusionMode": 1,
    "m_OverrideBakedGI": false
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.PropertyNode",
    "m_ObjectId": "1dc4788b9eca4069baa399efa4413298",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "Property",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1531.63623046875,
            "y": 89.8908920288086,
            "width": 186.7635498046875,
            "height": 33.163658142089847
        }
    },
    "m_Slots": [
        {
            "m_Id": "9f1d5bd043634e9a841740a0640c5738"
        }
    ],
    "synonyms": [],
    "m_Precision": 0,
    "m_PreviewExpanded": true,
    "m_DismissedVersion": 0,
    "m_PreviewMode": 0,
    "m_CustomColors": {
        "m_SerializableColors": []
    },
    "m_Property": {
        "m_Id": "fa96b8e4c3cf4ba39c8692064c29b868"
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.BlockNode",
    "m_ObjectId": "200455910ddd4cdf8bc49fa459421e1a",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "VertexDescription.Tangent",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": 0.0,
            "y": 0.0,
            "width": 0.0,
            "height": 0.0
        }
    },
    "m_Slots": [
        {
            "m_Id": "2a98727a0d574fc0b9be33188df9c30f"
        }
    ],
    "synonyms": [],
    "m_Precision": 0,
    "m_PreviewExpanded": true,
    "m_DismissedVersion": 0,
    "m_PreviewMode": 0,
    "m_CustomColors": {
        "m_SerializableColors": []
    },
    "m_SerializedDescriptor": "VertexDescription.Tangent"
}

{
    "m_SGVersion": 0,
    "m_Type": "AmazingAssets.DynamicWireframeShaderGenerator.Editor.DynamicMaskNode",
    "m_ObjectId": "2272a71ebb0c41c996cacac6ba5af67c",
    "m_Group": {
        "m_Id": "934bf1fbccb7436f8d9c204049f396c2"
    },
    "m_Name": "Dynamic Mask",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1554.3271484375,
            "y": 678.1090698242188,
            "width": 222.5452880859375,
            "height": 152.727294921875
        }
    },
    "m_Slots": [
        {
            "m_Id": "d3ec0074cb2e436eb6d6d9c98bfc2bd5"
        },
        {
            "m_Id": "a15532e0db4d410499b93416206b0524"
        },
        {
            "m_Id": "0a48d57fa25d4854b02a09db6dac2370"
        },
        {
            "m_Id": "f4030837256346c994f273a9c52efa67"
        }
    ],
    "synonyms": [],
    "m_Precision": 0,
    "m_PreviewExpanded": false,
    "m_DismissedVersion": 0,
    "m_PreviewMode": 0,
    "m_CustomColors": {
        "m_SerializableColors": []
    },
    "m_MaskType": 1
}

{
    "m_SGVersion": 1,
    "m_Type": "UnityEditor.ShaderGraph.Matrix4ShaderProperty",
    "m_ObjectId": "27366eacf0ae411bb25428a818ec1c5a",
    "m_Guid": {
        "m_GuidSerialized": "8fe35e61-038e-4d5e-a602-47bef497c2cd"
    },
    "m_Name": "WireframeShaderMaskData2",
    "m_DefaultRefNameVersion": 1,
    "m_RefNameGeneratedByDisplayName": "WireframeShaderMaskData2",
    "m_DefaultReferenceName": "_WireframeShaderMaskData2",
    "m_OverrideReferenceName": "",
    "m_GeneratePropertyBlock": false,
    "m_UseCustomSlotLabel": false,
    "m_CustomSlotLabel": "",
    "m_DismissedVersion": 0,
    "m_Precision": 0,
    "overrideHLSLDeclaration": true,
    "hlslDeclarationOverride": 1,
    "m_Hidden": false,
    "m_Value": {
        "e00": 1.0,
        "e01": 0.0,
        "e02": 0.0,
        "e03": 0.0,
        "e10": 0.0,
        "e11": 1.0,
        "e12": 0.0,
        "e13": 0.0,
        "e20": 0.0,
        "e21": 0.0,
        "e22": 1.0,
        "e23": 0.0,
        "e30": 0.0,
        "e31": 0.0,
        "e32": 0.0,
        "e33": 1.0
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.TangentMaterialSlot",
    "m_ObjectId": "2a98727a0d574fc0b9be33188df9c30f",
    "m_Id": 0,
    "m_DisplayName": "Tangent",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "Tangent",
    "m_StageCapability": 1,
    "m_Value": {
        "x": 0.0,
        "y": 0.0,
        "z": 0.0
    },
    "m_DefaultValue": {
        "x": 0.0,
        "y": 0.0,
        "z": 0.0
    },
    "m_Labels": [],
    "m_Space": 0
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.MultiplyNode",
    "m_ObjectId": "2c4e8cfdcb0840fda6e31d2a9a7c2ab0",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "Multiply",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -835.2000732421875,
            "y": 219.05450439453126,
            "width": 130.03643798828126,
            "height": 117.81817626953125
        }
    },
    "m_Slots": [
        {
            "m_Id": "654bca4165d34fbcace2d01d87cb9e94"
        },
        {
            "m_Id": "d7c28f5e14084740a40c0351a6d64b1e"
        },
        {
            "m_Id": "b200332ea65b402397262f4f33ea3a0c"
        }
    ],
    "synonyms": [
        "multiplication",
        "times",
        "x"
    ],
    "m_Precision": 0,
    "m_PreviewExpanded": false,
    "m_DismissedVersion": 0,
    "m_PreviewMode": 0,
    "m_CustomColors": {
        "m_SerializableColors": []
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.PositionMaterialSlot",
    "m_ObjectId": "2f5f6d0d514248c28a8209ebbd2b7bd7",
    "m_Id": 0,
    "m_DisplayName": "vertex Position WS",
    "m_SlotType": 0,
    "m_Hidden": true,
    "m_ShaderOutputName": "vertexPositionWS",
    "m_StageCapability": 3,
    "m_Value": {
        "x": 0.0,
        "y": 0.0,
        "z": 0.0
    },
    "m_DefaultValue": {
        "x": 0.0,
        "y": 0.0,
        "z": 0.0
    },
    "m_Labels": [],
    "m_Space": 2
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.MultiplyNode",
    "m_ObjectId": "332e3fb1592245a4a116de6d6dc95b8a",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "Multiply",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -329.01824951171877,
            "y": 193.74545288085938,
            "width": 132.6545867919922,
            "height": 116.9454345703125
        }
    },
    "m_Slots": [
        {
            "m_Id": "ba5f137cf3244cd4874985b6c7e02de2"
        },
        {
            "m_Id": "46be50338a2c40b9a6d6cc6ee4f6b363"
        },
        {
            "m_Id": "3c37c1b79715495c952c96d788bd2768"
        }
    ],
    "synonyms": [
        "multiplication",
        "times",
        "x"
    ],
    "m_Precision": 0,
    "m_PreviewExpanded": false,
    "m_DismissedVersion": 0,
    "m_PreviewMode": 0,
    "m_CustomColors": {
        "m_SerializableColors": []
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.Rendering.HighDefinition.ShaderGraph.HDUnlitData",
    "m_ObjectId": "340a8f7201bb4a1e9cfdda0cf39ddd5e",
    "m_EnableShadowMatte": false,
    "m_DistortionOnly": false
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "34a829e70b6f4b5ca814ca5a635aad8e",
    "m_Id": 1,
    "m_DisplayName": "Anti-aliasing",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "Anti-aliasing",
    "m_StageCapability": 3,
    "m_Value": 0.20000000298023225,
    "m_DefaultValue": 0.20000000298023225,
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.Rendering.HighDefinition.ShaderGraph.HDUnlitSubTarget",
    "m_ObjectId": "39581a4de0354281aaa86ee401b6cfb4"
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "3c37c1b79715495c952c96d788bd2768",
    "m_Id": 2,
    "m_DisplayName": "Out",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "Out",
    "m_StageCapability": 3,
    "m_Value": {
        "e00": 0.0,
        "e01": 0.0,
        "e02": 0.0,
        "e03": 0.0,
        "e10": 0.0,
        "e11": 0.0,
        "e12": 0.0,
        "e13": 0.0,
        "e20": 0.0,
        "e21": 0.0,
        "e22": 0.0,
        "e23": 0.0,
        "e30": 0.0,
        "e31": 0.0,
        "e32": 0.0,
        "e33": 0.0
    },
    "m_DefaultValue": {
        "e00": 1.0,
        "e01": 0.0,
        "e02": 0.0,
        "e03": 0.0,
        "e10": 0.0,
        "e11": 1.0,
        "e12": 0.0,
        "e13": 0.0,
        "e20": 0.0,
        "e21": 0.0,
        "e22": 1.0,
        "e23": 0.0,
        "e30": 0.0,
        "e31": 0.0,
        "e32": 0.0,
        "e33": 1.0
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "41d27d20a6394b58b21fd95c16c8e8cb",
    "m_Id": 2,
    "m_DisplayName": "Noise",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "Noise",
    "m_StageCapability": 3,
    "m_Value": 0.0,
    "m_DefaultValue": 0.0,
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector4MaterialSlot",
    "m_ObjectId": "449bfcec928742928ba6f408f4443aa8",
    "m_Id": 0,
    "m_DisplayName": "Wireframe Color",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "Out",
    "m_StageCapability": 3,
    "m_Value": {
        "x": 0.0,
        "y": 0.0,
        "z": 0.0,
        "w": 0.0
    },
    "m_DefaultValue": {
        "x": 0.0,
        "y": 0.0,
        "z": 0.0,
        "w": 0.0
    },
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.PropertyNode",
    "m_ObjectId": "4558ada8dab04741a34bdee6a310d029",
    "m_Group": {
        "m_Id": "934bf1fbccb7436f8d9c204049f396c2"
    },
    "m_Name": "Property",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1896.436279296875,
            "y": 722.6181640625,
            "width": 231.272705078125,
            "height": 32.2908935546875
        }
    },
    "m_Slots": [
        {
            "m_Id": "8c8af7625b564eb6ba804f0bfa77e2b2"
        }
    ],
    "synonyms": [],
    "m_Precision": 0,
    "m_PreviewExpanded": true,
    "m_DismissedVersion": 0,
    "m_PreviewMode": 0,
    "m_CustomColors": {
        "m_SerializableColors": []
    },
    "m_Property": {
        "m_Id": "27366eacf0ae411bb25428a818ec1c5a"
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "46be50338a2c40b9a6d6cc6ee4f6b363",
    "m_Id": 1,
    "m_DisplayName": "B",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "B",
    "m_StageCapability": 3,
    "m_Value": {
        "e00": 2.0,
        "e01": 2.0,
        "e02": 2.0,
        "e03": 2.0,
        "e10": 2.0,
        "e11": 2.0,
        "e12": 2.0,
        "e13": 2.0,
        "e20": 2.0,
        "e21": 2.0,
        "e22": 2.0,
        "e23": 2.0,
        "e30": 2.0,
        "e31": 2.0,
        "e32": 2.0,
        "e33": 2.0
    },
    "m_DefaultValue": {
        "e00": 1.0,
        "e01": 0.0,
        "e02": 0.0,
        "e03": 0.0,
        "e10": 0.0,
        "e11": 1.0,
        "e12": 0.0,
        "e13": 0.0,
        "e20": 0.0,
        "e21": 0.0,
        "e22": 1.0,
        "e23": 0.0,
        "e30": 0.0,
        "e31": 0.0,
        "e32": 0.0,
        "e33": 1.0
    }
}

{
    "m_SGVersion": 1,
    "m_Type": "UnityEditor.ShaderGraph.Matrix4ShaderProperty",
    "m_ObjectId": "46fff3d947ef48aba19f8af053342064",
    "m_Guid": {
        "m_GuidSerialized": "b87a7553-012f-4b47-bec4-44ff2e17b637"
    },
    "m_Name": "WireframeShaderMaskData1",
    "m_DefaultRefNameVersion": 1,
    "m_RefNameGeneratedByDisplayName": "WireframeShaderMaskData1",
    "m_DefaultReferenceName": "_WireframeShaderMaskData1",
    "m_OverrideReferenceName": "",
    "m_GeneratePropertyBlock": false,
    "m_UseCustomSlotLabel": false,
    "m_CustomSlotLabel": "",
    "m_DismissedVersion": 0,
    "m_Precision": 0,
    "overrideHLSLDeclaration": true,
    "hlslDeclarationOverride": 1,
    "m_Hidden": false,
    "m_Value": {
        "e00": 1.0,
        "e01": 0.0,
        "e02": 0.0,
        "e03": 0.0,
        "e10": 0.0,
        "e11": 1.0,
        "e12": 0.0,
        "e13": 0.0,
        "e20": 0.0,
        "e21": 0.0,
        "e22": 1.0,
        "e23": 0.0,
        "e30": 0.0,
        "e31": 0.0,
        "e32": 0.0,
        "e33": 1.0
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "5f2d95557d72432cba33156f0eabe9a9",
    "m_Id": 3,
    "m_DisplayName": "Wireframe",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "Wireframe",
    "m_StageCapability": 2,
    "m_Value": 0.0,
    "m_DefaultValue": 0.0,
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.NormalMaterialSlot",
    "m_ObjectId": "60ab4bef97654de18a5e8b9212d41911",
    "m_Id": 0,
    "m_DisplayName": "Normal",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "Normal",
    "m_StageCapability": 1,
    "m_Value": {
        "x": 0.0,
        "y": 0.0,
        "z": 0.0
    },
    "m_DefaultValue": {
        "x": 0.0,
        "y": 0.0,
        "z": 0.0
    },
    "m_Labels": [],
    "m_Space": 0
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "654bca4165d34fbcace2d01d87cb9e94",
    "m_Id": 0,
    "m_DisplayName": "A",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "A",
    "m_StageCapability": 3,
    "m_Value": {
        "e00": 0.0,
        "e01": 0.0,
        "e02": 0.0,
        "e03": 0.0,
        "e10": 0.0,
        "e11": 0.0,
        "e12": 0.0,
        "e13": 0.0,
        "e20": 0.0,
        "e21": 0.0,
        "e22": 0.0,
        "e23": 0.0,
        "e30": 0.0,
        "e31": 0.0,
        "e32": 0.0,
        "e33": 0.0
    },
    "m_DefaultValue": {
        "e00": 1.0,
        "e01": 0.0,
        "e02": 0.0,
        "e03": 0.0,
        "e10": 0.0,
        "e11": 1.0,
        "e12": 0.0,
        "e13": 0.0,
        "e20": 0.0,
        "e21": 0.0,
        "e22": 1.0,
        "e23": 0.0,
        "e30": 0.0,
        "e31": 0.0,
        "e32": 0.0,
        "e33": 1.0
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.BlockNode",
    "m_ObjectId": "65dfa2755ddf4a27869d138fea1957b6",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "VertexDescription.Position",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": 0.0,
            "y": 0.0,
            "width": 0.0,
            "height": 0.0
        }
    },
    "m_Slots": [
        {
            "m_Id": "dd8d59f7396744f0a001b4bf4cf457f7"
        }
    ],
    "synonyms": [],
    "m_Precision": 0,
    "m_PreviewExpanded": true,
    "m_DismissedVersion": 0,
    "m_PreviewMode": 0,
    "m_CustomColors": {
        "m_SerializableColors": []
    },
    "m_SerializedDescriptor": "VertexDescription.Position"
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector2MaterialSlot",
    "m_ObjectId": "6626242b104f43faa4274124463c5680",
    "m_Id": 4,
    "m_DisplayName": "Barycentric UV",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "Barycentric UV",
    "m_StageCapability": 2,
    "m_Value": {
        "x": 0.0,
        "y": 0.0
    },
    "m_DefaultValue": {
        "x": 0.0,
        "y": 0.0
    },
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "6ceece7b861946df8ca59314d71f03a6",
    "m_Id": 2,
    "m_DisplayName": "Out",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "Out",
    "m_StageCapability": 3,
    "m_Value": {
        "x": 0.0,
        "y": 0.0,
        "z": 0.0,
        "w": 0.0
    },
    "m_DefaultValue": {
        "x": 0.0,
        "y": 0.0,
        "z": 0.0,
        "w": 0.0
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.Rendering.HighDefinition.ShaderGraph.BuiltinData",
    "m_ObjectId": "7f68bdd19ecd4b63aba87ea78ea13cbd",
    "m_Distortion": false,
    "m_DistortionMode": 0,
    "m_DistortionDepthTest": true,
    "m_AddPrecomputedVelocity": false,
    "m_TransparentWritesMotionVec": false,
    "m_DepthOffset": false,
    "m_ConservativeDepthOffset": false,
    "m_TransparencyFog": true,
    "m_AlphaTestShadow": false,
    "m_BackThenFrontRendering": false,
    "m_TransparentDepthPrepass": false,
    "m_TransparentDepthPostpass": false,
    "m_SupportLodCrossFade": false
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "814659227dcc491ca03c3f4c37a9afce",
    "m_Id": 0,
    "m_DisplayName": "Thickness",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "Thickness",
    "m_StageCapability": 3,
    "m_Value": 0.009999999776482582,
    "m_DefaultValue": 0.009999999776482582,
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "AmazingAssets.DynamicWireframeShaderGenerator.Editor.DynamicMaskNode",
    "m_ObjectId": "8913d339bdd94f139301daaca928d45e",
    "m_Group": {
        "m_Id": "934bf1fbccb7436f8d9c204049f396c2"
    },
    "m_Name": "Dynamic Mask",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1554.3271484375,
            "y": 463.41815185546877,
            "width": 222.5452880859375,
            "height": 152.727294921875
        }
    },
    "m_Slots": [
        {
            "m_Id": "2f5f6d0d514248c28a8209ebbd2b7bd7"
        },
        {
            "m_Id": "f90c40bbaad641128a6f2acd1a51d0a8"
        },
        {
            "m_Id": "41d27d20a6394b58b21fd95c16c8e8cb"
        },
        {
            "m_Id": "068af20f662a46cfbcc8d41b6423b55c"
        }
    ],
    "synonyms": [],
    "m_Precision": 0,
    "m_PreviewExpanded": false,
    "m_DismissedVersion": 0,
    "m_PreviewMode": 0,
    "m_CustomColors": {
        "m_SerializableColors": []
    },
    "m_MaskType": 2
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.PropertyNode",
    "m_ObjectId": "8b57c7d9cbef4037966ba71e85a6a06c",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "Property",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1543.8544921875,
            "y": 136.1454315185547,
            "width": 198.9818115234375,
            "height": 33.16363525390625
        }
    },
    "m_Slots": [
        {
            "m_Id": "f99ceeb6964c49978e38868e18f86a44"
        }
    ],
    "synonyms": [],
    "m_Precision": 0,
    "m_PreviewExpanded": true,
    "m_DismissedVersion": 0,
    "m_PreviewMode": 0,
    "m_CustomColors": {
        "m_SerializableColors": []
    },
    "m_Property": {
        "m_Id": "f96e48a170a3461ea6881cc0b6a34099"
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Matrix4MaterialSlot",
    "m_ObjectId": "8c8af7625b564eb6ba804f0bfa77e2b2",
    "m_Id": 0,
    "m_DisplayName": "WireframeShaderMaskData2",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "Out",
    "m_StageCapability": 3,
    "m_Value": {
        "e00": 1.0,
        "e01": 0.0,
        "e02": 0.0,
        "e03": 0.0,
        "e10": 0.0,
        "e11": 1.0,
        "e12": 0.0,
        "e13": 0.0,
        "e20": 0.0,
        "e21": 0.0,
        "e22": 1.0,
        "e23": 0.0,
        "e30": 0.0,
        "e31": 0.0,
        "e32": 0.0,
        "e33": 1.0
    },
    "m_DefaultValue": {
        "e00": 1.0,
        "e01": 0.0,
        "e02": 0.0,
        "e03": 0.0,
        "e10": 0.0,
        "e11": 1.0,
        "e12": 0.0,
        "e13": 0.0,
        "e20": 0.0,
        "e21": 0.0,
        "e22": 1.0,
        "e23": 0.0,
        "e30": 0.0,
        "e31": 0.0,
        "e32": 0.0,
        "e33": 1.0
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.BlockNode",
    "m_ObjectId": "8dae6a3aaeac4d2c8120d1cee1312e5f",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "VertexDescription.Normal",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": 0.0,
            "y": 0.0,
            "width": 0.0,
            "height": 0.0
        }
    },
    "m_Slots": [
        {
            "m_Id": "60ab4bef97654de18a5e8b9212d41911"
        }
    ],
    "synonyms": [],
    "m_Precision": 0,
    "m_PreviewExpanded": true,
    "m_DismissedVersion": 0,
    "m_PreviewMode": 0,
    "m_CustomColors": {
        "m_SerializableColors": []
    },
    "m_SerializedDescriptor": "VertexDescription.Normal"
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "8e6a1067470d48fdbb17d8a97f549a4f",
    "m_Id": 0,
    "m_DisplayName": "A",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "A",
    "m_StageCapability": 3,
    "m_Value": {
        "x": 0.0,
        "y": 0.0,
        "z": 0.0,
        "w": 0.0
    },
    "m_DefaultValue": {
        "x": 0.0,
        "y": 0.0,
        "z": 0.0,
        "w": 0.0
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.GroupData",
    "m_ObjectId": "934bf1fbccb7436f8d9c204049f396c2",
    "m_Title": "Dynamic Masks",
    "m_Position": {
        "x": -1920.8726806640625,
        "y": 405.8182067871094
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.AddNode",
    "m_ObjectId": "93d29f50c0a044ee9e64325292f7e58d",
    "m_Group": {
        "m_Id": "934bf1fbccb7436f8d9c204049f396c2"
    },
    "m_Name": "Add",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1261.0909423828125,
            "y": 561.1636352539063,
            "width": 129.1636962890625,
            "height": 116.9454345703125
        }
    },
    "m_Slots": [
        {
            "m_Id": "8e6a1067470d48fdbb17d8a97f549a4f"
        },
        {
            "m_Id": "f2e41315c2e943e1b9d50d44cafe1789"
        },
        {
            "m_Id": "6ceece7b861946df8ca59314d71f03a6"
        }
    ],
    "synonyms": [
        "addition",
        "sum",
        "plus"
    ],
    "m_Precision": 0,
    "m_PreviewExpanded": false,
    "m_DismissedVersion": 0,
    "m_PreviewMode": 0,
    "m_CustomColors": {
        "m_SerializableColors": []
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "9f1d5bd043634e9a841740a0640c5738",
    "m_Id": 0,
    "m_DisplayName": "Wireframe Thickness",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "Out",
    "m_StageCapability": 3,
    "m_Value": 0.0,
    "m_DefaultValue": 0.0,
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.BlockNode",
    "m_ObjectId": "a0ff7a5655a241a693febc2166745dd3",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "SurfaceDescription.BaseColor",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": 0.0,
            "y": 0.0,
            "width": 0.0,
            "height": 0.0
        }
    },
    "m_Slots": [
        {
            "m_Id": "c98dfd4263374782ac4f99dc8866b3e9"
        }
    ],
    "synonyms": [],
    "m_Precision": 0,
    "m_PreviewExpanded": true,
    "m_DismissedVersion": 0,
    "m_PreviewMode": 0,
    "m_CustomColors": {
        "m_SerializableColors": []
    },
    "m_SerializedDescriptor": "SurfaceDescription.BaseColor"
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Matrix4MaterialSlot",
    "m_ObjectId": "a15532e0db4d410499b93416206b0524",
    "m_Id": 1,
    "m_DisplayName": "Shader Data",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "ShaderData",
    "m_StageCapability": 3,
    "m_Value": {
        "e00": 1.0,
        "e01": 0.0,
        "e02": 0.0,
        "e03": 0.0,
        "e10": 0.0,
        "e11": 1.0,
        "e12": 0.0,
        "e13": 0.0,
        "e20": 0.0,
        "e21": 0.0,
        "e22": 1.0,
        "e23": 0.0,
        "e30": 0.0,
        "e31": 0.0,
        "e32": 0.0,
        "e33": 1.0
    },
    "m_DefaultValue": {
        "e00": 1.0,
        "e01": 0.0,
        "e02": 0.0,
        "e03": 0.0,
        "e10": 0.0,
        "e11": 1.0,
        "e12": 0.0,
        "e13": 0.0,
        "e20": 0.0,
        "e21": 0.0,
        "e22": 1.0,
        "e23": 0.0,
        "e30": 0.0,
        "e31": 0.0,
        "e32": 0.0,
        "e33": 1.0
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.SaturateNode",
    "m_ObjectId": "a7aaf24f90954c91aa8bf70234072705",
    "m_Group": {
        "m_Id": "934bf1fbccb7436f8d9c204049f396c2"
    },
    "m_Name": "Saturate",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1092.6544189453125,
            "y": 561.1636352539063,
            "width": 130.90899658203126,
            "height": 93.3817138671875
        }
    },
    "m_Slots": [
        {
            "m_Id": "f03612dfa87b45039c45b120b8019057"
        },
        {
            "m_Id": "b7f62b5cbf95461faf721f627c1e62f6"
        }
    ],
    "synonyms": [
        "clamp"
    ],
    "m_Precision": 0,
    "m_PreviewExpanded": false,
    "m_DismissedVersion": 0,
    "m_PreviewMode": 0,
    "m_CustomColors": {
        "m_SerializableColors": []
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "b200332ea65b402397262f4f33ea3a0c",
    "m_Id": 2,
    "m_DisplayName": "Out",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "Out",
    "m_StageCapability": 3,
    "m_Value": {
        "e00": 0.0,
        "e01": 0.0,
        "e02": 0.0,
        "e03": 0.0,
        "e10": 0.0,
        "e11": 0.0,
        "e12": 0.0,
        "e13": 0.0,
        "e20": 0.0,
        "e21": 0.0,
        "e22": 0.0,
        "e23": 0.0,
        "e30": 0.0,
        "e31": 0.0,
        "e32": 0.0,
        "e33": 0.0
    },
    "m_DefaultValue": {
        "e00": 1.0,
        "e01": 0.0,
        "e02": 0.0,
        "e03": 0.0,
        "e10": 0.0,
        "e11": 1.0,
        "e12": 0.0,
        "e13": 0.0,
        "e20": 0.0,
        "e21": 0.0,
        "e22": 1.0,
        "e23": 0.0,
        "e30": 0.0,
        "e31": 0.0,
        "e32": 0.0,
        "e33": 1.0
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "b7f62b5cbf95461faf721f627c1e62f6",
    "m_Id": 1,
    "m_DisplayName": "Out",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "Out",
    "m_StageCapability": 3,
    "m_Value": {
        "x": 0.0,
        "y": 0.0,
        "z": 0.0,
        "w": 0.0
    },
    "m_DefaultValue": {
        "x": 0.0,
        "y": 0.0,
        "z": 0.0,
        "w": 0.0
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "ba5f137cf3244cd4874985b6c7e02de2",
    "m_Id": 0,
    "m_DisplayName": "A",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "A",
    "m_StageCapability": 3,
    "m_Value": {
        "e00": 0.0,
        "e01": 0.0,
        "e02": 0.0,
        "e03": 0.0,
        "e10": 0.0,
        "e11": 0.0,
        "e12": 0.0,
        "e13": 0.0,
        "e20": 0.0,
        "e21": 0.0,
        "e22": 0.0,
        "e23": 0.0,
        "e30": 0.0,
        "e31": 0.0,
        "e32": 0.0,
        "e33": 0.0
    },
    "m_DefaultValue": {
        "e00": 1.0,
        "e01": 0.0,
        "e02": 0.0,
        "e03": 0.0,
        "e10": 0.0,
        "e11": 1.0,
        "e12": 0.0,
        "e13": 0.0,
        "e20": 0.0,
        "e21": 0.0,
        "e22": 1.0,
        "e23": 0.0,
        "e30": 0.0,
        "e31": 0.0,
        "e32": 0.0,
        "e33": 1.0
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.PropertyNode",
    "m_ObjectId": "c3b4c128ba554fe098057745845e9910",
    "m_Group": {
        "m_Id": "934bf1fbccb7436f8d9c204049f396c2"
    },
    "m_Name": "Property",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1894.6907958984375,
            "y": 507.9272155761719,
            "width": 229.5272216796875,
            "height": 32.290924072265628
        }
    },
    "m_Slots": [
        {
            "m_Id": "e2110b8759bb4d5fa4343ae0770bfc70"
        }
    ],
    "synonyms": [],
    "m_Precision": 0,
    "m_PreviewExpanded": true,
    "m_DismissedVersion": 0,
    "m_PreviewMode": 0,
    "m_CustomColors": {
        "m_SerializableColors": []
    },
    "m_Property": {
        "m_Id": "46fff3d947ef48aba19f8af053342064"
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.PropertyNode",
    "m_ObjectId": "c74b42315a444fa6aab2c9ce9a824d6f",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "Property",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -530.6182250976563,
            "y": 199.8544921875,
            "width": 164.07275390625,
            "height": 32.29093933105469
        }
    },
    "m_Slots": [
        {
            "m_Id": "449bfcec928742928ba6f408f4443aa8"
        }
    ],
    "synonyms": [],
    "m_Precision": 0,
    "m_PreviewExpanded": true,
    "m_DismissedVersion": 0,
    "m_PreviewMode": 0,
    "m_CustomColors": {
        "m_SerializableColors": []
    },
    "m_Property": {
        "m_Id": "d457418e22434e0587988d59fb8f2e12"
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.BlockNode",
    "m_ObjectId": "c7a7bb8c9f2d4ee5af3a7f0219e07689",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "SurfaceDescription.Alpha",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": 0.0,
            "y": 0.0,
            "width": 0.0,
            "height": 0.0
        }
    },
    "m_Slots": [
        {
            "m_Id": "e63e398b31cb4d65b841d209a20d0de8"
        }
    ],
    "synonyms": [],
    "m_Precision": 0,
    "m_PreviewExpanded": true,
    "m_DismissedVersion": 0,
    "m_PreviewMode": 0,
    "m_CustomColors": {
        "m_SerializableColors": []
    },
    "m_SerializedDescriptor": "SurfaceDescription.Alpha"
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.ColorRGBMaterialSlot",
    "m_ObjectId": "c98dfd4263374782ac4f99dc8866b3e9",
    "m_Id": 0,
    "m_DisplayName": "Base Color",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "BaseColor",
    "m_StageCapability": 2,
    "m_Value": {
        "x": 0.5,
        "y": 0.5,
        "z": 0.5
    },
    "m_DefaultValue": {
        "x": 0.0,
        "y": 0.0,
        "z": 0.0
    },
    "m_Labels": [],
    "m_ColorMode": 0,
    "m_DefaultColor": {
        "r": 0.5,
        "g": 0.5,
        "b": 0.5,
        "a": 1.0
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.PositionMaterialSlot",
    "m_ObjectId": "d3ec0074cb2e436eb6d6d9c98bfc2bd5",
    "m_Id": 0,
    "m_DisplayName": "vertex Position WS",
    "m_SlotType": 0,
    "m_Hidden": true,
    "m_ShaderOutputName": "vertexPositionWS",
    "m_StageCapability": 3,
    "m_Value": {
        "x": 0.0,
        "y": 0.0,
        "z": 0.0
    },
    "m_DefaultValue": {
        "x": 0.0,
        "y": 0.0,
        "z": 0.0
    },
    "m_Labels": [],
    "m_Space": 2
}

{
    "m_SGVersion": 3,
    "m_Type": "UnityEditor.ShaderGraph.Internal.ColorShaderProperty",
    "m_ObjectId": "d457418e22434e0587988d59fb8f2e12",
    "m_Guid": {
        "m_GuidSerialized": "06a49765-a554-4426-9643-3bfc72074371"
    },
    "m_Name": "Wireframe Color",
    "m_DefaultRefNameVersion": 1,
    "m_RefNameGeneratedByDisplayName": "Wireframe Color",
    "m_DefaultReferenceName": "_Wireframe_Color",
    "m_OverrideReferenceName": "",
    "m_GeneratePropertyBlock": true,
    "m_UseCustomSlotLabel": false,
    "m_CustomSlotLabel": "",
    "m_DismissedVersion": 0,
    "m_Precision": 0,
    "overrideHLSLDeclaration": false,
    "hlslDeclarationOverride": 0,
    "m_Hidden": false,
    "m_Value": {
        "r": 1.0,
        "g": 1.0,
        "b": 1.0,
        "a": 1.0
    },
    "isMainColor": false,
    "m_ColorMode": 1
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.Rendering.HighDefinition.ShaderGraph.SystemData",
    "m_ObjectId": "d755ae36f95b4fc0b36eb8cc5ba58361",
    "m_MaterialNeedsUpdateHash": 280370,
    "m_SurfaceType": 0,
    "m_RenderingPass": 1,
    "m_BlendMode": 0,
    "m_ZTest": 4,
    "m_ZWrite": false,
    "m_TransparentCullMode": 2,
    "m_OpaqueCullMode": 2,
    "m_SortPriority": 0,
    "m_AlphaTest": true,
    "m_TransparentDepthPrepass": false,
    "m_TransparentDepthPostpass": false,
    "m_SupportLodCrossFade": false,
    "m_DoubleSidedMode": 0,
    "m_DOTSInstancing": false,
    "m_CustomVelocity": false,
    "m_Tessellation": false,
    "m_TessellationMode": 0,
    "m_TessellationFactorMinDistance": 20.0,
    "m_TessellationFactorMaxDistance": 50.0,
    "m_TessellationFactorTriangleSize": 100.0,
    "m_TessellationShapeFactor": 0.75,
    "m_TessellationBackFaceCullEpsilon": -0.25,
    "m_TessellationMaxDisplacement": 0.009999999776482582,
    "m_Version": 1,
    "inspectorFoldoutMask": 0
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "d7c28f5e14084740a40c0351a6d64b1e",
    "m_Id": 1,
    "m_DisplayName": "B",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "B",
    "m_StageCapability": 3,
    "m_Value": {
        "e00": 2.0,
        "e01": 2.0,
        "e02": 2.0,
        "e03": 2.0,
        "e10": 2.0,
        "e11": 2.0,
        "e12": 2.0,
        "e13": 2.0,
        "e20": 2.0,
        "e21": 2.0,
        "e22": 2.0,
        "e23": 2.0,
        "e30": 2.0,
        "e31": 2.0,
        "e32": 2.0,
        "e33": 2.0
    },
    "m_DefaultValue": {
        "e00": 1.0,
        "e01": 0.0,
        "e02": 0.0,
        "e03": 0.0,
        "e10": 0.0,
        "e11": 1.0,
        "e12": 0.0,
        "e13": 0.0,
        "e20": 0.0,
        "e21": 0.0,
        "e22": 1.0,
        "e23": 0.0,
        "e30": 0.0,
        "e31": 0.0,
        "e32": 0.0,
        "e33": 1.0
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.CategoryData",
    "m_ObjectId": "dd6fcdf0141b461d9ce07ca51467b3c4",
    "m_Name": "",
    "m_ChildObjectList": [
        {
            "m_Id": "fa96b8e4c3cf4ba39c8692064c29b868"
        },
        {
            "m_Id": "f96e48a170a3461ea6881cc0b6a34099"
        },
        {
            "m_Id": "d457418e22434e0587988d59fb8f2e12"
        },
        {
            "m_Id": "46fff3d947ef48aba19f8af053342064"
        },
        {
            "m_Id": "27366eacf0ae411bb25428a818ec1c5a"
        }
    ]
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.PositionMaterialSlot",
    "m_ObjectId": "dd8d59f7396744f0a001b4bf4cf457f7",
    "m_Id": 0,
    "m_DisplayName": "Position",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "Position",
    "m_StageCapability": 1,
    "m_Value": {
        "x": 0.0,
        "y": 0.0,
        "z": 0.0
    },
    "m_DefaultValue": {
        "x": 0.0,
        "y": 0.0,
        "z": 0.0
    },
    "m_Labels": [],
    "m_Space": 0
}

{
    "m_SGVersion": 1,
    "m_Type": "UnityEditor.Rendering.Universal.ShaderGraph.UniversalTarget",
    "m_ObjectId": "dec45dfe63994bc89826658d10a3ebef",
    "m_Datas": [],
    "m_ActiveSubTarget": {
        "m_Id": "f27849a457a14c89bd59e49b3cae2dbd"
    },
    "m_AllowMaterialOverride": false,
    "m_SurfaceType": 1,
    "m_ZTestMode": 4,
    "m_ZWriteControl": 0,
    "m_AlphaMode": 2,
    "m_RenderFace": 0,
    "m_AlphaClip": false,
    "m_CastShadows": true,
    "m_ReceiveShadows": true,
    "m_SupportsLODCrossFade": false,
    "m_CustomEditorGUI": "",
    "m_SupportVFX": false
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Matrix4MaterialSlot",
    "m_ObjectId": "e2110b8759bb4d5fa4343ae0770bfc70",
    "m_Id": 0,
    "m_DisplayName": "WireframeShaderMaskData1",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "Out",
    "m_StageCapability": 3,
    "m_Value": {
        "e00": 1.0,
        "e01": 0.0,
        "e02": 0.0,
        "e03": 0.0,
        "e10": 0.0,
        "e11": 1.0,
        "e12": 0.0,
        "e13": 0.0,
        "e20": 0.0,
        "e21": 0.0,
        "e22": 1.0,
        "e23": 0.0,
        "e30": 0.0,
        "e31": 0.0,
        "e32": 0.0,
        "e33": 1.0
    },
    "m_DefaultValue": {
        "e00": 1.0,
        "e01": 0.0,
        "e02": 0.0,
        "e03": 0.0,
        "e10": 0.0,
        "e11": 1.0,
        "e12": 0.0,
        "e13": 0.0,
        "e20": 0.0,
        "e21": 0.0,
        "e22": 1.0,
        "e23": 0.0,
        "e30": 0.0,
        "e31": 0.0,
        "e32": 0.0,
        "e33": 1.0
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.Rendering.HighDefinition.ShaderGraph.HDLitSubTarget",
    "m_ObjectId": "e4335c2878f04db5af0adb530304d760"
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "e63e398b31cb4d65b841d209a20d0de8",
    "m_Id": 0,
    "m_DisplayName": "Alpha",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "Alpha",
    "m_StageCapability": 2,
    "m_Value": 1.0,
    "m_DefaultValue": 1.0,
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "AmazingAssets.DynamicWireframeShaderGenerator.Editor.WireframeRendererNode",
    "m_ObjectId": "ece5db6e8dfb4e9fad05ff1bb6cc2309",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "Wireframe Renderer",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1261.0906982421875,
            "y": 67.20001983642578,
            "width": 315.92724609375,
            "height": 164.9454345703125
        }
    },
    "m_Slots": [
        {
            "m_Id": "814659227dcc491ca03c3f4c37a9afce"
        },
        {
            "m_Id": "34a829e70b6f4b5ca814ca5a635aad8e"
        },
        {
            "m_Id": "5f2d95557d72432cba33156f0eabe9a9"
        },
        {
            "m_Id": "6626242b104f43faa4274124463c5680"
        }
    ],
    "synonyms": [],
    "m_Precision": 0,
    "m_PreviewExpanded": true,
    "m_DismissedVersion": 0,
    "m_PreviewMode": 0,
    "m_CustomColors": {
        "m_SerializableColors": []
    },
    "m_Thickness": 0.009999999776482582,
    "m_AntiAliasing": 0.20000000298023225
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "f03612dfa87b45039c45b120b8019057",
    "m_Id": 0,
    "m_DisplayName": "In",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "In",
    "m_StageCapability": 3,
    "m_Value": {
        "x": 0.0,
        "y": 0.0,
        "z": 0.0,
        "w": 0.0
    },
    "m_DefaultValue": {
        "x": 0.0,
        "y": 0.0,
        "z": 0.0,
        "w": 0.0
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.Rendering.HighDefinition.ShaderGraph.HDLitData",
    "m_ObjectId": "f0645e8f19b34f78905d91f42f4e329d",
    "m_RayTracing": false,
    "m_MaterialType": 0,
    "m_RefractionModel": 0,
    "m_SSSTransmission": true,
    "m_EnergyConservingSpecular": true,
    "m_ClearCoat": false
}

{
    "m_SGVersion": 2,
    "m_Type": "UnityEditor.Rendering.Universal.ShaderGraph.UniversalUnlitSubTarget",
    "m_ObjectId": "f27849a457a14c89bd59e49b3cae2dbd"
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "f2e41315c2e943e1b9d50d44cafe1789",
    "m_Id": 1,
    "m_DisplayName": "B",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "B",
    "m_StageCapability": 3,
    "m_Value": {
        "x": 0.0,
        "y": 0.0,
        "z": 0.0,
        "w": 0.0
    },
    "m_DefaultValue": {
        "x": 0.0,
        "y": 0.0,
        "z": 0.0,
        "w": 0.0
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "f4030837256346c994f273a9c52efa67",
    "m_Id": 3,
    "m_DisplayName": "Out",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "Out",
    "m_StageCapability": 3,
    "m_Value": 0.0,
    "m_DefaultValue": 0.0,
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Matrix4MaterialSlot",
    "m_ObjectId": "f90c40bbaad641128a6f2acd1a51d0a8",
    "m_Id": 1,
    "m_DisplayName": "Shader Data",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "ShaderData",
    "m_StageCapability": 3,
    "m_Value": {
        "e00": 1.0,
        "e01": 0.0,
        "e02": 0.0,
        "e03": 0.0,
        "e10": 0.0,
        "e11": 1.0,
        "e12": 0.0,
        "e13": 0.0,
        "e20": 0.0,
        "e21": 0.0,
        "e22": 1.0,
        "e23": 0.0,
        "e30": 0.0,
        "e31": 0.0,
        "e32": 0.0,
        "e33": 1.0
    },
    "m_DefaultValue": {
        "e00": 1.0,
        "e01": 0.0,
        "e02": 0.0,
        "e03": 0.0,
        "e10": 0.0,
        "e11": 1.0,
        "e12": 0.0,
        "e13": 0.0,
        "e20": 0.0,
        "e21": 0.0,
        "e22": 1.0,
        "e23": 0.0,
        "e30": 0.0,
        "e31": 0.0,
        "e32": 0.0,
        "e33": 1.0
    }
}

{
    "m_SGVersion": 1,
    "m_Type": "UnityEditor.ShaderGraph.Internal.Vector1ShaderProperty",
    "m_ObjectId": "f96e48a170a3461ea6881cc0b6a34099",
    "m_Guid": {
        "m_GuidSerialized": "2fbdf329-38d4-4e72-832a-7e85b3230eec"
    },
    "m_Name": "Wireframe Anti-aliasing",
    "m_DefaultRefNameVersion": 1,
    "m_RefNameGeneratedByDisplayName": "Wireframe Anti-aliasing",
    "m_DefaultReferenceName": "_Wireframe_Anti_aliasing",
    "m_OverrideReferenceName": "",
    "m_GeneratePropertyBlock": true,
    "m_UseCustomSlotLabel": false,
    "m_CustomSlotLabel": "",
    "m_DismissedVersion": 0,
    "m_Precision": 0,
    "overrideHLSLDeclaration": false,
    "hlslDeclarationOverride": 0,
    "m_Hidden": false,
    "m_Value": 0.20000000298023225,
    "m_FloatType": 1,
    "m_RangeValues": {
        "x": 0.0,
        "y": 1.0
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "f99ceeb6964c49978e38868e18f86a44",
    "m_Id": 0,
    "m_DisplayName": "Wireframe Anti-aliasing",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "Out",
    "m_StageCapability": 3,
    "m_Value": 0.0,
    "m_DefaultValue": 0.0,
    "m_Labels": []
}

{
    "m_SGVersion": 1,
    "m_Type": "UnityEditor.ShaderGraph.Internal.Vector1ShaderProperty",
    "m_ObjectId": "fa96b8e4c3cf4ba39c8692064c29b868",
    "m_Guid": {
        "m_GuidSerialized": "7c270cf6-d189-4dc3-b4c4-9a811ebafb75"
    },
    "m_Name": "Wireframe Thickness",
    "m_DefaultRefNameVersion": 1,
    "m_RefNameGeneratedByDisplayName": "Wireframe Thickness",
    "m_DefaultReferenceName": "_Wireframe_Thickness",
    "m_OverrideReferenceName": "",
    "m_GeneratePropertyBlock": true,
    "m_UseCustomSlotLabel": false,
    "m_CustomSlotLabel": "",
    "m_DismissedVersion": 0,
    "m_Precision": 0,
    "overrideHLSLDeclaration": false,
    "hlslDeclarationOverride": 0,
    "m_Hidden": false,
    "m_Value": 0.009999999776482582,
    "m_FloatType": 1,
    "m_RangeValues": {
        "x": 0.0,
        "y": 1.0
    }
}


ShaderGraphBody_End*/

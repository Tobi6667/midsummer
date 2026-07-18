// Dynamic Wireframe Shader <https://u3d.as/3WyY>
// Copyright (c) Amazing Assets <https://amazingassets.world>

Shader "Amazing Assets/Dynamic Wireframe Shader/Examples/Masks/Lit (Dynamic Wireframe)"
{
Properties
{
[KeywordEnum(Triangle, Quad)] _Wireframe_Shader_Shape("Wireframe Shape", int) = 0
[KeywordEnum(Default, Normalized, Screen Space)] _Wireframe_Shader_Style("Wireframe Style", int) = 0

_Wireframe_Thickness("Wireframe Thickness", Range(0, 1)) = 0.01
_Wireframe_Anti_aliasing("Wireframe Anti-aliasing", Range(0, 1)) = 0.2
[HDR]_Wireframe_Color("Wireframe Color", Color) = (1, 1, 1, 1)
[NoScaleOffset]_BaseColorMap("Base Map", 2D) = "white" {}
[Normal][NoScaleOffset]_NormalMap("Normal Map", 2D) = "bump" {}
[NoScaleOffset]_MaskMap("Mask Map", 2D) = "white" {}
_Metallic("Metallic", Range(0, 1)) = 0
_Smoothness("Smoothness", Range(0, 1)) = 0
_Occlusion("Occlusion", Range(0, 1)) = 1
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
"RenderType"="Opaque"
"UniversalMaterialType" = "Lit"
"Queue"="Geometry"
"DisableBatching"="False"
"ShaderGraphShader"="true"
"ShaderGraphTargetId"="UniversalLitSubTarget"
}
Pass
{
    Name "Universal Forward"
    Tags
    {
        "LightMode" = "UniversalForward"
    }

// Render State
Cull Back
Blend One Zero
ZTest LEqual
ZWrite On

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM

// Pragmas
#pragma target 5.0
#pragma multi_compile_instancing
#pragma multi_compile_fog
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
#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
#pragma multi_compile _ LIGHTMAP_ON
#pragma multi_compile _ DYNAMICLIGHTMAP_ON
#pragma multi_compile _ DIRLIGHTMAP_COMBINED
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
#pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
#pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
#pragma multi_compile_fragment _ _SHADOWS_SOFT
#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
#pragma multi_compile _ SHADOWS_SHADOWMASK
#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
#pragma multi_compile_fragment _ _LIGHT_LAYERS
#pragma multi_compile_fragment _ DEBUG_DISPLAY
#pragma multi_compile_fragment _ _LIGHT_COOKIES
#pragma multi_compile _ _FORWARD_PLUS
// GraphKeywords: <None>

// Defines

#define _NORMALMAP 1
#define _NORMAL_DROPOFF_TS 1
#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define ATTRIBUTES_NEED_TEXCOORD0
#define ATTRIBUTES_NEED_TEXCOORD1
#define ATTRIBUTES_NEED_TEXCOORD2
#define ATTRIBUTES_NEED_TEXCOORD3
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define VARYINGS_NEED_TANGENT_WS
#define VARYINGS_NEED_TEXCOORD0
#define VARYINGS_NEED_TEXCOORD1
#define VARYINGS_NEED_TEXCOORD2
#define VARYINGS_NEED_TEXCOORD3
#define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
#define VARYINGS_NEED_SHADOW_COORD
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_FORWARD
#define _FOG_FRAGMENT 1
/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
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
#if UNITY_ANY_INSTANCING_ENABLED
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
 float3 positionWS;
 float3 normalWS;
 float4 tangentWS;
 float4 texCoord0;
 float4 texCoord1;
 float4 texCoord2;
 float4 texCoord3;
#if defined(LIGHTMAP_ON)
 float2 staticLightmapUV;
#endif
#if defined(DYNAMICLIGHTMAP_ON)
 float2 dynamicLightmapUV;
#endif
#if !defined(LIGHTMAP_ON)
 float3 sh;
#endif
 float4 fogFactorAndVertexLight;
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
 float4 shadowCoord;
#endif
#if UNITY_ANY_INSTANCING_ENABLED
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
 float3 TangentSpaceNormal;
 float3 WorldSpacePosition;
 float4 uv0;
 float4 uv1;
 float4 uv2;
 float4 uv3;
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
#if defined(LIGHTMAP_ON)
 float2 staticLightmapUV : INTERP0;
#endif
#if defined(DYNAMICLIGHTMAP_ON)
 float2 dynamicLightmapUV : INTERP1;
#endif
#if !defined(LIGHTMAP_ON)
 float3 sh : INTERP2;
#endif
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
 float4 shadowCoord : INTERP3;
#endif
 float4 tangentWS : INTERP4;
 float4 texCoord0 : INTERP5;
 float4 texCoord1 : INTERP6;
 float4 texCoord2 : INTERP7;
 float4 texCoord3 : INTERP8;
 float4 fogFactorAndVertexLight : INTERP9;
 float3 positionWS : INTERP10;
 float3 normalWS : INTERP11;
#if UNITY_ANY_INSTANCING_ENABLED
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
#if defined(LIGHTMAP_ON)
output.staticLightmapUV = input.staticLightmapUV;
#endif
#if defined(DYNAMICLIGHTMAP_ON)
output.dynamicLightmapUV = input.dynamicLightmapUV;
#endif
#if !defined(LIGHTMAP_ON)
output.sh = input.sh;
#endif
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
output.shadowCoord = input.shadowCoord;
#endif
output.tangentWS.xyzw = input.tangentWS;
output.texCoord0.xyzw = input.texCoord0;
output.texCoord1.xyzw = input.texCoord1;
output.texCoord2.xyzw = input.texCoord2;
output.texCoord3.xyzw = input.texCoord3;
output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
output.positionWS.xyz = input.positionWS;
output.normalWS.xyz = input.normalWS;
#if UNITY_ANY_INSTANCING_ENABLED
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
#if defined(LIGHTMAP_ON)
output.staticLightmapUV = input.staticLightmapUV;
#endif
#if defined(DYNAMICLIGHTMAP_ON)
output.dynamicLightmapUV = input.dynamicLightmapUV;
#endif
#if !defined(LIGHTMAP_ON)
output.sh = input.sh;
#endif
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
output.shadowCoord = input.shadowCoord;
#endif
output.tangentWS = input.tangentWS.xyzw;
output.texCoord0 = input.texCoord0.xyzw;
output.texCoord1 = input.texCoord1.xyzw;
output.texCoord2 = input.texCoord2.xyzw;
output.texCoord3 = input.texCoord3.xyzw;
output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
output.positionWS = input.positionWS.xyz;
output.normalWS = input.normalWS.xyz;
#if UNITY_ANY_INSTANCING_ENABLED
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
float4 _BaseColorMap_TexelSize;
float _Metallic;
float _Smoothness;
float _Occlusion;
float4 _NormalMap_TexelSize;
float4 _MaskMap_TexelSize;
float _Wireframe_Thickness;
float4 _Wireframe_Color;
float _Wireframe_Anti_aliasing;
CBUFFER_END


// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
float4x4 _WireframeShaderMaskData2;
TEXTURE2D(_BaseColorMap);
SAMPLER(sampler_BaseColorMap);
float4x4 _WireframeShaderMaskData1;
TEXTURE2D(_NormalMap);
SAMPLER(sampler_NormalMap);
TEXTURE2D(_MaskMap);
SAMPLER(sampler_MaskMap);

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

void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
{
    Out = lerp(A, B, T);
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
float3 NormalTS;
float3 Emission;
float Metallic;
float Smoothness;
float Occlusion;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
UnityTexture2D _Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseColorMap);
float4 _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D.tex, _Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D.samplerstate, _Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
float _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_R_4_Float = _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4.r;
float _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_G_5_Float = _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4.g;
float _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_B_6_Float = _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4.b;
float _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_A_7_Float = _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4.a;
float4 _Property_fea879b3f3324ecb9cb1e0f2f9890529_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Wireframe_Color) : _Wireframe_Color;
float _Property_1dc4788b9eca4069baa399efa4413298_Out_0_Float = _Wireframe_Thickness;
float _Property_8b57c7d9cbef4037966ba71e85a6a06c_Out_0_Float = _Wireframe_Anti_aliasing;
float _WireframeRenderer_8b6e53cbe97c4fee809b54677b9a7128_Wireframe_3_Float;
float2 _WireframeRenderer_8b6e53cbe97c4fee809b54677b9a7128_BarycentricUV_4_Vector2;
WireframeRenderer_float(IN.barycentric.xyz, max(0, _Property_1dc4788b9eca4069baa399efa4413298_Out_0_Float), max(0, _Property_8b57c7d9cbef4037966ba71e85a6a06c_Out_0_Float), 0, _WireframeRenderer_8b6e53cbe97c4fee809b54677b9a7128_Wireframe_3_Float, _WireframeRenderer_8b6e53cbe97c4fee809b54677b9a7128_BarycentricUV_4_Vector2);
float4x4 _Property_4baf1dcd456b43f2bf0aae60a6240a0f_Out_0_Matrix4 = _WireframeShaderMaskData1;
float _DynamicMask_e6689341c7c04c1bb33ed3b487300049_Out_3_Float;
WireframeShaderDynamicMaskCube_float(IN.WorldSpacePosition, _Property_4baf1dcd456b43f2bf0aae60a6240a0f_Out_0_Matrix4, 0, _DynamicMask_e6689341c7c04c1bb33ed3b487300049_Out_3_Float);
float4x4 _Property_182bc4539ba648d2b933f00c42f90390_Out_0_Matrix4 = _WireframeShaderMaskData2;
float _DynamicMask_b2fc7ae4954b44eeb314569a9a849f6f_Out_3_Float;
WireframeShaderDynamicMaskSphere_float(IN.WorldSpacePosition, _Property_182bc4539ba648d2b933f00c42f90390_Out_0_Matrix4, 0, _DynamicMask_b2fc7ae4954b44eeb314569a9a849f6f_Out_3_Float);
float _Add_d570aea5942649aba75f7914130198d9_Out_2_Float;
Unity_Add_float(_DynamicMask_e6689341c7c04c1bb33ed3b487300049_Out_3_Float, _DynamicMask_b2fc7ae4954b44eeb314569a9a849f6f_Out_3_Float, _Add_d570aea5942649aba75f7914130198d9_Out_2_Float);
float _Saturate_a60e6e3d79d04cf9ac5fa0f6b0d4ffef_Out_1_Float;
Unity_Saturate_float(_Add_d570aea5942649aba75f7914130198d9_Out_2_Float, _Saturate_a60e6e3d79d04cf9ac5fa0f6b0d4ffef_Out_1_Float);
float _Multiply_b3cffbd67298456b992ab87b0e1b94d7_Out_2_Float;
Unity_Multiply_float_float(_WireframeRenderer_8b6e53cbe97c4fee809b54677b9a7128_Wireframe_3_Float, _Saturate_a60e6e3d79d04cf9ac5fa0f6b0d4ffef_Out_1_Float, _Multiply_b3cffbd67298456b992ab87b0e1b94d7_Out_2_Float);
float4 _Lerp_130fe097f09542d1b7fa52dfa8fd1871_Out_3_Vector4;
Unity_Lerp_float4(_SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4, _Property_fea879b3f3324ecb9cb1e0f2f9890529_Out_0_Vector4, (_Multiply_b3cffbd67298456b992ab87b0e1b94d7_Out_2_Float.xxxx), _Lerp_130fe097f09542d1b7fa52dfa8fd1871_Out_3_Vector4);
UnityTexture2D _Property_354f04f299e94eb3aeb99dea1d1e9cb2_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_NormalMap);
float4 _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_354f04f299e94eb3aeb99dea1d1e9cb2_Out_0_Texture2D.tex, _Property_354f04f299e94eb3aeb99dea1d1e9cb2_Out_0_Texture2D.samplerstate, _Property_354f04f299e94eb3aeb99dea1d1e9cb2_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
_SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4);
float _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_R_4_Float = _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4.r;
float _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_G_5_Float = _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4.g;
float _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_B_6_Float = _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4.b;
float _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_A_7_Float = _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4.a;
UnityTexture2D _Property_6dd7819e424c402fb1716035e270a4c8_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MaskMap);
float4 _SampleTexture2D_9bacd1d8d3194f1a909e0626a17f0a93_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_6dd7819e424c402fb1716035e270a4c8_Out_0_Texture2D.tex, _Property_6dd7819e424c402fb1716035e270a4c8_Out_0_Texture2D.samplerstate, _Property_6dd7819e424c402fb1716035e270a4c8_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
float _SampleTexture2D_9bacd1d8d3194f1a909e0626a17f0a93_R_4_Float = _SampleTexture2D_9bacd1d8d3194f1a909e0626a17f0a93_RGBA_0_Vector4.r;
float _SampleTexture2D_9bacd1d8d3194f1a909e0626a17f0a93_G_5_Float = _SampleTexture2D_9bacd1d8d3194f1a909e0626a17f0a93_RGBA_0_Vector4.g;
float _SampleTexture2D_9bacd1d8d3194f1a909e0626a17f0a93_B_6_Float = _SampleTexture2D_9bacd1d8d3194f1a909e0626a17f0a93_RGBA_0_Vector4.b;
float _SampleTexture2D_9bacd1d8d3194f1a909e0626a17f0a93_A_7_Float = _SampleTexture2D_9bacd1d8d3194f1a909e0626a17f0a93_RGBA_0_Vector4.a;
float _Property_7be0d2ff2c5f4926a7df4197b8a5a50b_Out_0_Float = _Metallic;
float _Property_7f3cbaed20da468c9673eedd1a7cdb21_Out_0_Float = _Occlusion;
float _Property_e736e9327527475591515cc473446022_Out_0_Float = _Smoothness;
float4 _Vector4_a323fdd57f844bd4b77bbbfbc3724586_Out_0_Vector4 = float4(_Property_7be0d2ff2c5f4926a7df4197b8a5a50b_Out_0_Float, _Property_7f3cbaed20da468c9673eedd1a7cdb21_Out_0_Float, 0, _Property_e736e9327527475591515cc473446022_Out_0_Float);
float4 _Multiply_e8ba8aacd2e94a59973b09180d2b3ffe_Out_2_Vector4;
Unity_Multiply_float4_float4(_SampleTexture2D_9bacd1d8d3194f1a909e0626a17f0a93_RGBA_0_Vector4, _Vector4_a323fdd57f844bd4b77bbbfbc3724586_Out_0_Vector4, _Multiply_e8ba8aacd2e94a59973b09180d2b3ffe_Out_2_Vector4);
float _Split_b128fdcca5a64a7094c0b715bebb918b_R_1_Float = _Multiply_e8ba8aacd2e94a59973b09180d2b3ffe_Out_2_Vector4[0];
float _Split_b128fdcca5a64a7094c0b715bebb918b_G_2_Float = _Multiply_e8ba8aacd2e94a59973b09180d2b3ffe_Out_2_Vector4[1];
float _Split_b128fdcca5a64a7094c0b715bebb918b_B_3_Float = _Multiply_e8ba8aacd2e94a59973b09180d2b3ffe_Out_2_Vector4[2];
float _Split_b128fdcca5a64a7094c0b715bebb918b_A_4_Float = _Multiply_e8ba8aacd2e94a59973b09180d2b3ffe_Out_2_Vector4[3];
surface.BaseColor = (_Lerp_130fe097f09542d1b7fa52dfa8fd1871_Out_3_Vector4.xyz);
surface.NormalTS = (_SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4.xyz);
surface.Emission = float3(0, 0, 0);
surface.Metallic = _Split_b128fdcca5a64a7094c0b715bebb918b_R_1_Float;
surface.Smoothness = _Split_b128fdcca5a64a7094c0b715bebb918b_A_4_Float;
surface.Occlusion = _Split_b128fdcca5a64a7094c0b715bebb918b_G_2_Float;
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

    



    output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


    output.WorldSpacePosition = input.positionWS;

    #if UNITY_UV_STARTS_AT_TOP
    #else
    #endif


    output.uv0 = input.texCoord0;
    output.uv1 = input.texCoord1;
    output.uv2 = input.texCoord2;
    output.uv3 = input.texCoord3;
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
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

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
    Name "GBuffer"
    Tags
    {
        "LightMode" = "UniversalGBuffer"
    }

// Render State
Cull Back
Blend One Zero
ZTest LEqual
ZWrite On

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM

// Pragmas
#pragma target 5.0
#pragma exclude_renderers gles gles3 glcore
#pragma multi_compile_instancing
#pragma multi_compile_fog
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
#pragma multi_compile _ LIGHTMAP_ON
#pragma multi_compile _ DYNAMICLIGHTMAP_ON
#pragma multi_compile _ DIRLIGHTMAP_COMBINED
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
#pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
#pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
#pragma multi_compile_fragment _ _SHADOWS_SOFT
#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
#pragma multi_compile _ SHADOWS_SHADOWMASK
#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
#pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
#pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
#pragma multi_compile_fragment _ DEBUG_DISPLAY
// GraphKeywords: <None>

// Defines

#define _NORMALMAP 1
#define _NORMAL_DROPOFF_TS 1
#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define ATTRIBUTES_NEED_TEXCOORD0
#define ATTRIBUTES_NEED_TEXCOORD1
#define ATTRIBUTES_NEED_TEXCOORD2
#define ATTRIBUTES_NEED_TEXCOORD3
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define VARYINGS_NEED_TANGENT_WS
#define VARYINGS_NEED_TEXCOORD0
#define VARYINGS_NEED_TEXCOORD1
#define VARYINGS_NEED_TEXCOORD2
#define VARYINGS_NEED_TEXCOORD3
#define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
#define VARYINGS_NEED_SHADOW_COORD
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_GBUFFER
#define _FOG_FRAGMENT 1
/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
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
#if UNITY_ANY_INSTANCING_ENABLED
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
 float3 positionWS;
 float3 normalWS;
 float4 tangentWS;
 float4 texCoord0;
 float4 texCoord1;
 float4 texCoord2;
 float4 texCoord3;
#if defined(LIGHTMAP_ON)
 float2 staticLightmapUV;
#endif
#if defined(DYNAMICLIGHTMAP_ON)
 float2 dynamicLightmapUV;
#endif
#if !defined(LIGHTMAP_ON)
 float3 sh;
#endif
 float4 fogFactorAndVertexLight;
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
 float4 shadowCoord;
#endif
#if UNITY_ANY_INSTANCING_ENABLED
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
 float3 TangentSpaceNormal;
 float3 WorldSpacePosition;
 float4 uv0;
 float4 uv1;
 float4 uv2;
 float4 uv3;
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
#if defined(LIGHTMAP_ON)
 float2 staticLightmapUV : INTERP0;
#endif
#if defined(DYNAMICLIGHTMAP_ON)
 float2 dynamicLightmapUV : INTERP1;
#endif
#if !defined(LIGHTMAP_ON)
 float3 sh : INTERP2;
#endif
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
 float4 shadowCoord : INTERP3;
#endif
 float4 tangentWS : INTERP4;
 float4 texCoord0 : INTERP5;
 float4 texCoord1 : INTERP6;
 float4 texCoord2 : INTERP7;
 float4 texCoord3 : INTERP8;
 float4 fogFactorAndVertexLight : INTERP9;
 float3 positionWS : INTERP10;
 float3 normalWS : INTERP11;
#if UNITY_ANY_INSTANCING_ENABLED
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
#if defined(LIGHTMAP_ON)
output.staticLightmapUV = input.staticLightmapUV;
#endif
#if defined(DYNAMICLIGHTMAP_ON)
output.dynamicLightmapUV = input.dynamicLightmapUV;
#endif
#if !defined(LIGHTMAP_ON)
output.sh = input.sh;
#endif
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
output.shadowCoord = input.shadowCoord;
#endif
output.tangentWS.xyzw = input.tangentWS;
output.texCoord0.xyzw = input.texCoord0;
output.texCoord1.xyzw = input.texCoord1;
output.texCoord2.xyzw = input.texCoord2;
output.texCoord3.xyzw = input.texCoord3;
output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
output.positionWS.xyz = input.positionWS;
output.normalWS.xyz = input.normalWS;
#if UNITY_ANY_INSTANCING_ENABLED
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
#if defined(LIGHTMAP_ON)
output.staticLightmapUV = input.staticLightmapUV;
#endif
#if defined(DYNAMICLIGHTMAP_ON)
output.dynamicLightmapUV = input.dynamicLightmapUV;
#endif
#if !defined(LIGHTMAP_ON)
output.sh = input.sh;
#endif
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
output.shadowCoord = input.shadowCoord;
#endif
output.tangentWS = input.tangentWS.xyzw;
output.texCoord0 = input.texCoord0.xyzw;
output.texCoord1 = input.texCoord1.xyzw;
output.texCoord2 = input.texCoord2.xyzw;
output.texCoord3 = input.texCoord3.xyzw;
output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
output.positionWS = input.positionWS.xyz;
output.normalWS = input.normalWS.xyz;
#if UNITY_ANY_INSTANCING_ENABLED
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
float4 _BaseColorMap_TexelSize;
float _Metallic;
float _Smoothness;
float _Occlusion;
float4 _NormalMap_TexelSize;
float4 _MaskMap_TexelSize;
float _Wireframe_Thickness;
float4 _Wireframe_Color;
float _Wireframe_Anti_aliasing;
CBUFFER_END


// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
float4x4 _WireframeShaderMaskData2;
TEXTURE2D(_BaseColorMap);
SAMPLER(sampler_BaseColorMap);
float4x4 _WireframeShaderMaskData1;
TEXTURE2D(_NormalMap);
SAMPLER(sampler_NormalMap);
TEXTURE2D(_MaskMap);
SAMPLER(sampler_MaskMap);

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

void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
{
    Out = lerp(A, B, T);
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
float3 NormalTS;
float3 Emission;
float Metallic;
float Smoothness;
float Occlusion;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
UnityTexture2D _Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseColorMap);
float4 _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D.tex, _Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D.samplerstate, _Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
float _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_R_4_Float = _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4.r;
float _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_G_5_Float = _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4.g;
float _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_B_6_Float = _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4.b;
float _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_A_7_Float = _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4.a;
float4 _Property_fea879b3f3324ecb9cb1e0f2f9890529_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Wireframe_Color) : _Wireframe_Color;
float _Property_1dc4788b9eca4069baa399efa4413298_Out_0_Float = _Wireframe_Thickness;
float _Property_8b57c7d9cbef4037966ba71e85a6a06c_Out_0_Float = _Wireframe_Anti_aliasing;
float _WireframeRenderer_8b6e53cbe97c4fee809b54677b9a7128_Wireframe_3_Float;
float2 _WireframeRenderer_8b6e53cbe97c4fee809b54677b9a7128_BarycentricUV_4_Vector2;
WireframeRenderer_float(IN.barycentric.xyz, max(0, _Property_1dc4788b9eca4069baa399efa4413298_Out_0_Float), max(0, _Property_8b57c7d9cbef4037966ba71e85a6a06c_Out_0_Float), 0, _WireframeRenderer_8b6e53cbe97c4fee809b54677b9a7128_Wireframe_3_Float, _WireframeRenderer_8b6e53cbe97c4fee809b54677b9a7128_BarycentricUV_4_Vector2);
float4x4 _Property_4baf1dcd456b43f2bf0aae60a6240a0f_Out_0_Matrix4 = _WireframeShaderMaskData1;
float _DynamicMask_e6689341c7c04c1bb33ed3b487300049_Out_3_Float;
WireframeShaderDynamicMaskCube_float(IN.WorldSpacePosition, _Property_4baf1dcd456b43f2bf0aae60a6240a0f_Out_0_Matrix4, 0, _DynamicMask_e6689341c7c04c1bb33ed3b487300049_Out_3_Float);
float4x4 _Property_182bc4539ba648d2b933f00c42f90390_Out_0_Matrix4 = _WireframeShaderMaskData2;
float _DynamicMask_b2fc7ae4954b44eeb314569a9a849f6f_Out_3_Float;
WireframeShaderDynamicMaskSphere_float(IN.WorldSpacePosition, _Property_182bc4539ba648d2b933f00c42f90390_Out_0_Matrix4, 0, _DynamicMask_b2fc7ae4954b44eeb314569a9a849f6f_Out_3_Float);
float _Add_d570aea5942649aba75f7914130198d9_Out_2_Float;
Unity_Add_float(_DynamicMask_e6689341c7c04c1bb33ed3b487300049_Out_3_Float, _DynamicMask_b2fc7ae4954b44eeb314569a9a849f6f_Out_3_Float, _Add_d570aea5942649aba75f7914130198d9_Out_2_Float);
float _Saturate_a60e6e3d79d04cf9ac5fa0f6b0d4ffef_Out_1_Float;
Unity_Saturate_float(_Add_d570aea5942649aba75f7914130198d9_Out_2_Float, _Saturate_a60e6e3d79d04cf9ac5fa0f6b0d4ffef_Out_1_Float);
float _Multiply_b3cffbd67298456b992ab87b0e1b94d7_Out_2_Float;
Unity_Multiply_float_float(_WireframeRenderer_8b6e53cbe97c4fee809b54677b9a7128_Wireframe_3_Float, _Saturate_a60e6e3d79d04cf9ac5fa0f6b0d4ffef_Out_1_Float, _Multiply_b3cffbd67298456b992ab87b0e1b94d7_Out_2_Float);
float4 _Lerp_130fe097f09542d1b7fa52dfa8fd1871_Out_3_Vector4;
Unity_Lerp_float4(_SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4, _Property_fea879b3f3324ecb9cb1e0f2f9890529_Out_0_Vector4, (_Multiply_b3cffbd67298456b992ab87b0e1b94d7_Out_2_Float.xxxx), _Lerp_130fe097f09542d1b7fa52dfa8fd1871_Out_3_Vector4);
UnityTexture2D _Property_354f04f299e94eb3aeb99dea1d1e9cb2_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_NormalMap);
float4 _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_354f04f299e94eb3aeb99dea1d1e9cb2_Out_0_Texture2D.tex, _Property_354f04f299e94eb3aeb99dea1d1e9cb2_Out_0_Texture2D.samplerstate, _Property_354f04f299e94eb3aeb99dea1d1e9cb2_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
_SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4);
float _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_R_4_Float = _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4.r;
float _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_G_5_Float = _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4.g;
float _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_B_6_Float = _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4.b;
float _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_A_7_Float = _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4.a;
UnityTexture2D _Property_6dd7819e424c402fb1716035e270a4c8_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MaskMap);
float4 _SampleTexture2D_9bacd1d8d3194f1a909e0626a17f0a93_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_6dd7819e424c402fb1716035e270a4c8_Out_0_Texture2D.tex, _Property_6dd7819e424c402fb1716035e270a4c8_Out_0_Texture2D.samplerstate, _Property_6dd7819e424c402fb1716035e270a4c8_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
float _SampleTexture2D_9bacd1d8d3194f1a909e0626a17f0a93_R_4_Float = _SampleTexture2D_9bacd1d8d3194f1a909e0626a17f0a93_RGBA_0_Vector4.r;
float _SampleTexture2D_9bacd1d8d3194f1a909e0626a17f0a93_G_5_Float = _SampleTexture2D_9bacd1d8d3194f1a909e0626a17f0a93_RGBA_0_Vector4.g;
float _SampleTexture2D_9bacd1d8d3194f1a909e0626a17f0a93_B_6_Float = _SampleTexture2D_9bacd1d8d3194f1a909e0626a17f0a93_RGBA_0_Vector4.b;
float _SampleTexture2D_9bacd1d8d3194f1a909e0626a17f0a93_A_7_Float = _SampleTexture2D_9bacd1d8d3194f1a909e0626a17f0a93_RGBA_0_Vector4.a;
float _Property_7be0d2ff2c5f4926a7df4197b8a5a50b_Out_0_Float = _Metallic;
float _Property_7f3cbaed20da468c9673eedd1a7cdb21_Out_0_Float = _Occlusion;
float _Property_e736e9327527475591515cc473446022_Out_0_Float = _Smoothness;
float4 _Vector4_a323fdd57f844bd4b77bbbfbc3724586_Out_0_Vector4 = float4(_Property_7be0d2ff2c5f4926a7df4197b8a5a50b_Out_0_Float, _Property_7f3cbaed20da468c9673eedd1a7cdb21_Out_0_Float, 0, _Property_e736e9327527475591515cc473446022_Out_0_Float);
float4 _Multiply_e8ba8aacd2e94a59973b09180d2b3ffe_Out_2_Vector4;
Unity_Multiply_float4_float4(_SampleTexture2D_9bacd1d8d3194f1a909e0626a17f0a93_RGBA_0_Vector4, _Vector4_a323fdd57f844bd4b77bbbfbc3724586_Out_0_Vector4, _Multiply_e8ba8aacd2e94a59973b09180d2b3ffe_Out_2_Vector4);
float _Split_b128fdcca5a64a7094c0b715bebb918b_R_1_Float = _Multiply_e8ba8aacd2e94a59973b09180d2b3ffe_Out_2_Vector4[0];
float _Split_b128fdcca5a64a7094c0b715bebb918b_G_2_Float = _Multiply_e8ba8aacd2e94a59973b09180d2b3ffe_Out_2_Vector4[1];
float _Split_b128fdcca5a64a7094c0b715bebb918b_B_3_Float = _Multiply_e8ba8aacd2e94a59973b09180d2b3ffe_Out_2_Vector4[2];
float _Split_b128fdcca5a64a7094c0b715bebb918b_A_4_Float = _Multiply_e8ba8aacd2e94a59973b09180d2b3ffe_Out_2_Vector4[3];
surface.BaseColor = (_Lerp_130fe097f09542d1b7fa52dfa8fd1871_Out_3_Vector4.xyz);
surface.NormalTS = (_SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4.xyz);
surface.Emission = float3(0, 0, 0);
surface.Metallic = _Split_b128fdcca5a64a7094c0b715bebb918b_R_1_Float;
surface.Smoothness = _Split_b128fdcca5a64a7094c0b715bebb918b_A_4_Float;
surface.Occlusion = _Split_b128fdcca5a64a7094c0b715bebb918b_G_2_Float;
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

    



    output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


    output.WorldSpacePosition = input.positionWS;

    #if UNITY_UV_STARTS_AT_TOP
    #else
    #endif


    output.uv0 = input.texCoord0;
    output.uv1 = input.texCoord1;
    output.uv2 = input.texCoord2;
    output.uv3 = input.texCoord3;
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
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"

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
    Name "ShadowCaster"
    Tags
    {
        "LightMode" = "ShadowCaster"
    }

// Render State
Cull Back
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

#define _NORMALMAP 1
#define _NORMAL_DROPOFF_TS 1
#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define VARYINGS_NEED_NORMAL_WS
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_SHADOWCASTER
/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
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
#if UNITY_ANY_INSTANCING_ENABLED
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
 float3 normalWS;
#if UNITY_ANY_INSTANCING_ENABLED
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
#if UNITY_ANY_INSTANCING_ENABLED
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
#if UNITY_ANY_INSTANCING_ENABLED
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
#if UNITY_ANY_INSTANCING_ENABLED
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
float4 _BaseColorMap_TexelSize;
float _Metallic;
float _Smoothness;
float _Occlusion;
float4 _NormalMap_TexelSize;
float4 _MaskMap_TexelSize;
float _Wireframe_Thickness;
float4 _Wireframe_Color;
float _Wireframe_Anti_aliasing;
CBUFFER_END


// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
float4x4 _WireframeShaderMaskData2;
TEXTURE2D(_BaseColorMap);
SAMPLER(sampler_BaseColorMap);
float4x4 _WireframeShaderMaskData1;
TEXTURE2D(_NormalMap);
SAMPLER(sampler_NormalMap);
TEXTURE2D(_MaskMap);
SAMPLER(sampler_MaskMap);

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
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
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
    Name "DepthOnly"
    Tags
    {
        "LightMode" = "DepthOnly"
    }

// Render State
Cull Back
ZTest LEqual
ZWrite On
ColorMask R

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
// PassKeywords: <None>
// GraphKeywords: <None>

// Defines

#define _NORMALMAP 1
#define _NORMAL_DROPOFF_TS 1
#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_DEPTHONLY
/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
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
#if UNITY_ANY_INSTANCING_ENABLED
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
#if UNITY_ANY_INSTANCING_ENABLED
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
#if UNITY_ANY_INSTANCING_ENABLED
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
#if UNITY_ANY_INSTANCING_ENABLED
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
#if UNITY_ANY_INSTANCING_ENABLED
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
float4 _BaseColorMap_TexelSize;
float _Metallic;
float _Smoothness;
float _Occlusion;
float4 _NormalMap_TexelSize;
float4 _MaskMap_TexelSize;
float _Wireframe_Thickness;
float4 _Wireframe_Color;
float _Wireframe_Anti_aliasing;
CBUFFER_END


// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
float4x4 _WireframeShaderMaskData2;
TEXTURE2D(_BaseColorMap);
SAMPLER(sampler_BaseColorMap);
float4x4 _WireframeShaderMaskData1;
TEXTURE2D(_NormalMap);
SAMPLER(sampler_NormalMap);
TEXTURE2D(_MaskMap);
SAMPLER(sampler_MaskMap);

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
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
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
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

// --------------------------------------------------
// Visual Effect Vertex Invocations
#ifdef HAVE_VFX_MODIFICATION
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
#endif

ENDHLSL
}
Pass
{
    Name "DepthNormals"
    Tags
    {
        "LightMode" = "DepthNormals"
    }

// Render State
Cull Back
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
// PassKeywords: <None>
// GraphKeywords: <None>

// Defines

#define _NORMALMAP 1
#define _NORMAL_DROPOFF_TS 1
#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define ATTRIBUTES_NEED_TEXCOORD0
#define ATTRIBUTES_NEED_TEXCOORD1
#define VARYINGS_NEED_NORMAL_WS
#define VARYINGS_NEED_TANGENT_WS
#define VARYINGS_NEED_TEXCOORD0
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_DEPTHNORMALS
/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
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
 float4 uv0 : TEXCOORD0;
 float4 uv1 : TEXCOORD1;
#if UNITY_ANY_INSTANCING_ENABLED
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
 float3 normalWS;
 float4 tangentWS;
 float4 texCoord0;
#if UNITY_ANY_INSTANCING_ENABLED
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
 float3 TangentSpaceNormal;
 float4 uv0;
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
 float4 tangentWS : INTERP0;
 float4 texCoord0 : INTERP1;
 float3 normalWS : INTERP2;
#if UNITY_ANY_INSTANCING_ENABLED
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
output.tangentWS.xyzw = input.tangentWS;
output.texCoord0.xyzw = input.texCoord0;
output.normalWS.xyz = input.normalWS;
#if UNITY_ANY_INSTANCING_ENABLED
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
output.tangentWS = input.tangentWS.xyzw;
output.texCoord0 = input.texCoord0.xyzw;
output.normalWS = input.normalWS.xyz;
#if UNITY_ANY_INSTANCING_ENABLED
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
float4 _BaseColorMap_TexelSize;
float _Metallic;
float _Smoothness;
float _Occlusion;
float4 _NormalMap_TexelSize;
float4 _MaskMap_TexelSize;
float _Wireframe_Thickness;
float4 _Wireframe_Color;
float _Wireframe_Anti_aliasing;
CBUFFER_END


// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
float4x4 _WireframeShaderMaskData2;
TEXTURE2D(_BaseColorMap);
SAMPLER(sampler_BaseColorMap);
float4x4 _WireframeShaderMaskData1;
TEXTURE2D(_NormalMap);
SAMPLER(sampler_NormalMap);
TEXTURE2D(_MaskMap);
SAMPLER(sampler_MaskMap);

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
float3 NormalTS;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
UnityTexture2D _Property_354f04f299e94eb3aeb99dea1d1e9cb2_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_NormalMap);
float4 _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_354f04f299e94eb3aeb99dea1d1e9cb2_Out_0_Texture2D.tex, _Property_354f04f299e94eb3aeb99dea1d1e9cb2_Out_0_Texture2D.samplerstate, _Property_354f04f299e94eb3aeb99dea1d1e9cb2_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
_SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4);
float _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_R_4_Float = _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4.r;
float _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_G_5_Float = _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4.g;
float _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_B_6_Float = _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4.b;
float _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_A_7_Float = _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4.a;
surface.NormalTS = (_SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4.xyz);
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

    



    output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);



    #if UNITY_UV_STARTS_AT_TOP
    #else
    #endif


    output.uv0 = input.texCoord0;
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
    Name "Meta"
    Tags
    {
        "LightMode" = "Meta"
    }

// Render State
Cull Off

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM

// Pragmas
#pragma target 5.0
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
#pragma shader_feature _ EDITOR_VISUALIZATION
// GraphKeywords: <None>

// Defines

#define _NORMALMAP 1
#define _NORMAL_DROPOFF_TS 1
#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define ATTRIBUTES_NEED_TEXCOORD0
#define ATTRIBUTES_NEED_TEXCOORD1
#define ATTRIBUTES_NEED_TEXCOORD2
#define ATTRIBUTES_NEED_TEXCOORD3
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_TEXCOORD0
#define VARYINGS_NEED_TEXCOORD1
#define VARYINGS_NEED_TEXCOORD2
#define VARYINGS_NEED_TEXCOORD3
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_META
#define _FOG_FRAGMENT 1
/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
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
#if UNITY_ANY_INSTANCING_ENABLED
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
#if UNITY_ANY_INSTANCING_ENABLED
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
float3 barycentric : INTERP5;
 float4 positionCS : SV_POSITION;
 float4 texCoord0 : INTERP0;
 float4 texCoord1 : INTERP1;
 float4 texCoord2 : INTERP2;
 float4 texCoord3 : INTERP3;
 float3 positionWS : INTERP4;
#if UNITY_ANY_INSTANCING_ENABLED
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
output.positionWS.xyz = input.positionWS;
#if UNITY_ANY_INSTANCING_ENABLED
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
output.positionWS = input.positionWS.xyz;
#if UNITY_ANY_INSTANCING_ENABLED
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
float4 _BaseColorMap_TexelSize;
float _Metallic;
float _Smoothness;
float _Occlusion;
float4 _NormalMap_TexelSize;
float4 _MaskMap_TexelSize;
float _Wireframe_Thickness;
float4 _Wireframe_Color;
float _Wireframe_Anti_aliasing;
CBUFFER_END


// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
float4x4 _WireframeShaderMaskData2;
TEXTURE2D(_BaseColorMap);
SAMPLER(sampler_BaseColorMap);
float4x4 _WireframeShaderMaskData1;
TEXTURE2D(_NormalMap);
SAMPLER(sampler_NormalMap);
TEXTURE2D(_MaskMap);
SAMPLER(sampler_MaskMap);

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

void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
{
    Out = lerp(A, B, T);
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
float3 Emission;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
UnityTexture2D _Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseColorMap);
float4 _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D.tex, _Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D.samplerstate, _Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
float _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_R_4_Float = _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4.r;
float _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_G_5_Float = _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4.g;
float _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_B_6_Float = _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4.b;
float _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_A_7_Float = _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4.a;
float4 _Property_fea879b3f3324ecb9cb1e0f2f9890529_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Wireframe_Color) : _Wireframe_Color;
float _Property_1dc4788b9eca4069baa399efa4413298_Out_0_Float = _Wireframe_Thickness;
float _Property_8b57c7d9cbef4037966ba71e85a6a06c_Out_0_Float = _Wireframe_Anti_aliasing;
float _WireframeRenderer_8b6e53cbe97c4fee809b54677b9a7128_Wireframe_3_Float;
float2 _WireframeRenderer_8b6e53cbe97c4fee809b54677b9a7128_BarycentricUV_4_Vector2;
WireframeRenderer_float(IN.barycentric.xyz, max(0, _Property_1dc4788b9eca4069baa399efa4413298_Out_0_Float), max(0, _Property_8b57c7d9cbef4037966ba71e85a6a06c_Out_0_Float), 0, _WireframeRenderer_8b6e53cbe97c4fee809b54677b9a7128_Wireframe_3_Float, _WireframeRenderer_8b6e53cbe97c4fee809b54677b9a7128_BarycentricUV_4_Vector2);
float4x4 _Property_4baf1dcd456b43f2bf0aae60a6240a0f_Out_0_Matrix4 = _WireframeShaderMaskData1;
float _DynamicMask_e6689341c7c04c1bb33ed3b487300049_Out_3_Float;
WireframeShaderDynamicMaskCube_float(IN.WorldSpacePosition, _Property_4baf1dcd456b43f2bf0aae60a6240a0f_Out_0_Matrix4, 0, _DynamicMask_e6689341c7c04c1bb33ed3b487300049_Out_3_Float);
float4x4 _Property_182bc4539ba648d2b933f00c42f90390_Out_0_Matrix4 = _WireframeShaderMaskData2;
float _DynamicMask_b2fc7ae4954b44eeb314569a9a849f6f_Out_3_Float;
WireframeShaderDynamicMaskSphere_float(IN.WorldSpacePosition, _Property_182bc4539ba648d2b933f00c42f90390_Out_0_Matrix4, 0, _DynamicMask_b2fc7ae4954b44eeb314569a9a849f6f_Out_3_Float);
float _Add_d570aea5942649aba75f7914130198d9_Out_2_Float;
Unity_Add_float(_DynamicMask_e6689341c7c04c1bb33ed3b487300049_Out_3_Float, _DynamicMask_b2fc7ae4954b44eeb314569a9a849f6f_Out_3_Float, _Add_d570aea5942649aba75f7914130198d9_Out_2_Float);
float _Saturate_a60e6e3d79d04cf9ac5fa0f6b0d4ffef_Out_1_Float;
Unity_Saturate_float(_Add_d570aea5942649aba75f7914130198d9_Out_2_Float, _Saturate_a60e6e3d79d04cf9ac5fa0f6b0d4ffef_Out_1_Float);
float _Multiply_b3cffbd67298456b992ab87b0e1b94d7_Out_2_Float;
Unity_Multiply_float_float(_WireframeRenderer_8b6e53cbe97c4fee809b54677b9a7128_Wireframe_3_Float, _Saturate_a60e6e3d79d04cf9ac5fa0f6b0d4ffef_Out_1_Float, _Multiply_b3cffbd67298456b992ab87b0e1b94d7_Out_2_Float);
float4 _Lerp_130fe097f09542d1b7fa52dfa8fd1871_Out_3_Vector4;
Unity_Lerp_float4(_SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4, _Property_fea879b3f3324ecb9cb1e0f2f9890529_Out_0_Vector4, (_Multiply_b3cffbd67298456b992ab87b0e1b94d7_Out_2_Float.xxxx), _Lerp_130fe097f09542d1b7fa52dfa8fd1871_Out_3_Vector4);
surface.BaseColor = (_Lerp_130fe097f09542d1b7fa52dfa8fd1871_Out_3_Vector4.xyz);
surface.Emission = float3(0, 0, 0);
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
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

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

#define _NORMALMAP 1
#define _NORMAL_DROPOFF_TS 1
#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_DEPTHONLY
#define SCENESELECTIONPASS 1
#define ALPHA_CLIP_THRESHOLD 1
/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
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
#if UNITY_ANY_INSTANCING_ENABLED
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
#if UNITY_ANY_INSTANCING_ENABLED
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
#if UNITY_ANY_INSTANCING_ENABLED
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
#if UNITY_ANY_INSTANCING_ENABLED
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
#if UNITY_ANY_INSTANCING_ENABLED
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
float4 _BaseColorMap_TexelSize;
float _Metallic;
float _Smoothness;
float _Occlusion;
float4 _NormalMap_TexelSize;
float4 _MaskMap_TexelSize;
float _Wireframe_Thickness;
float4 _Wireframe_Color;
float _Wireframe_Anti_aliasing;
CBUFFER_END


// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
float4x4 _WireframeShaderMaskData2;
TEXTURE2D(_BaseColorMap);
SAMPLER(sampler_BaseColorMap);
float4x4 _WireframeShaderMaskData1;
TEXTURE2D(_NormalMap);
SAMPLER(sampler_NormalMap);
TEXTURE2D(_MaskMap);
SAMPLER(sampler_MaskMap);

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
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
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
Cull Back

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

#define _NORMALMAP 1
#define _NORMAL_DROPOFF_TS 1
#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_DEPTHONLY
#define SCENEPICKINGPASS 1
#define ALPHA_CLIP_THRESHOLD 1
/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
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
#if UNITY_ANY_INSTANCING_ENABLED
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
#if UNITY_ANY_INSTANCING_ENABLED
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
#if UNITY_ANY_INSTANCING_ENABLED
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
#if UNITY_ANY_INSTANCING_ENABLED
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
#if UNITY_ANY_INSTANCING_ENABLED
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
float4 _BaseColorMap_TexelSize;
float _Metallic;
float _Smoothness;
float _Occlusion;
float4 _NormalMap_TexelSize;
float4 _MaskMap_TexelSize;
float _Wireframe_Thickness;
float4 _Wireframe_Color;
float _Wireframe_Anti_aliasing;
CBUFFER_END


// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
float4x4 _WireframeShaderMaskData2;
TEXTURE2D(_BaseColorMap);
SAMPLER(sampler_BaseColorMap);
float4x4 _WireframeShaderMaskData1;
TEXTURE2D(_NormalMap);
SAMPLER(sampler_NormalMap);
TEXTURE2D(_MaskMap);
SAMPLER(sampler_MaskMap);

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
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
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
    // Name: <None>
    Tags
    {
        "LightMode" = "Universal2D"
    }

// Render State
Cull Back
Blend One Zero
ZTest LEqual
ZWrite On

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

#define _NORMALMAP 1
#define _NORMAL_DROPOFF_TS 1
#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define ATTRIBUTES_NEED_TEXCOORD0
#define ATTRIBUTES_NEED_TEXCOORD1
#define ATTRIBUTES_NEED_TEXCOORD2
#define ATTRIBUTES_NEED_TEXCOORD3
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_TEXCOORD0
#define VARYINGS_NEED_TEXCOORD1
#define VARYINGS_NEED_TEXCOORD2
#define VARYINGS_NEED_TEXCOORD3
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_2D
/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
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
 float4 uv0 : TEXCOORD0;
 float4 uv1 : TEXCOORD1;
 float4 uv2 : TEXCOORD2;
 float4 uv3 : TEXCOORD3;
#if UNITY_ANY_INSTANCING_ENABLED
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
#if UNITY_ANY_INSTANCING_ENABLED
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
 float3 positionWS : INTERP4;
#if UNITY_ANY_INSTANCING_ENABLED
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
output.positionWS.xyz = input.positionWS;
#if UNITY_ANY_INSTANCING_ENABLED
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
output.positionWS = input.positionWS.xyz;
#if UNITY_ANY_INSTANCING_ENABLED
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
float4 _BaseColorMap_TexelSize;
float _Metallic;
float _Smoothness;
float _Occlusion;
float4 _NormalMap_TexelSize;
float4 _MaskMap_TexelSize;
float _Wireframe_Thickness;
float4 _Wireframe_Color;
float _Wireframe_Anti_aliasing;
CBUFFER_END


// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
float4x4 _WireframeShaderMaskData2;
TEXTURE2D(_BaseColorMap);
SAMPLER(sampler_BaseColorMap);
float4x4 _WireframeShaderMaskData1;
TEXTURE2D(_NormalMap);
SAMPLER(sampler_NormalMap);
TEXTURE2D(_MaskMap);
SAMPLER(sampler_MaskMap);

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

void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
{
    Out = lerp(A, B, T);
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
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
UnityTexture2D _Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseColorMap);
float4 _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D.tex, _Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D.samplerstate, _Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
float _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_R_4_Float = _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4.r;
float _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_G_5_Float = _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4.g;
float _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_B_6_Float = _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4.b;
float _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_A_7_Float = _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4.a;
float4 _Property_fea879b3f3324ecb9cb1e0f2f9890529_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Wireframe_Color) : _Wireframe_Color;
float _Property_1dc4788b9eca4069baa399efa4413298_Out_0_Float = _Wireframe_Thickness;
float _Property_8b57c7d9cbef4037966ba71e85a6a06c_Out_0_Float = _Wireframe_Anti_aliasing;
float _WireframeRenderer_8b6e53cbe97c4fee809b54677b9a7128_Wireframe_3_Float;
float2 _WireframeRenderer_8b6e53cbe97c4fee809b54677b9a7128_BarycentricUV_4_Vector2;
WireframeRenderer_float(IN.uv3.xyz, max(0, _Property_1dc4788b9eca4069baa399efa4413298_Out_0_Float), max(0, _Property_8b57c7d9cbef4037966ba71e85a6a06c_Out_0_Float), 0, _WireframeRenderer_8b6e53cbe97c4fee809b54677b9a7128_Wireframe_3_Float, _WireframeRenderer_8b6e53cbe97c4fee809b54677b9a7128_BarycentricUV_4_Vector2);
float4x4 _Property_4baf1dcd456b43f2bf0aae60a6240a0f_Out_0_Matrix4 = _WireframeShaderMaskData1;
float _DynamicMask_e6689341c7c04c1bb33ed3b487300049_Out_3_Float;
WireframeShaderDynamicMaskCube_float(IN.WorldSpacePosition, _Property_4baf1dcd456b43f2bf0aae60a6240a0f_Out_0_Matrix4, 0, _DynamicMask_e6689341c7c04c1bb33ed3b487300049_Out_3_Float);
float4x4 _Property_182bc4539ba648d2b933f00c42f90390_Out_0_Matrix4 = _WireframeShaderMaskData2;
float _DynamicMask_b2fc7ae4954b44eeb314569a9a849f6f_Out_3_Float;
WireframeShaderDynamicMaskSphere_float(IN.WorldSpacePosition, _Property_182bc4539ba648d2b933f00c42f90390_Out_0_Matrix4, 0, _DynamicMask_b2fc7ae4954b44eeb314569a9a849f6f_Out_3_Float);
float _Add_d570aea5942649aba75f7914130198d9_Out_2_Float;
Unity_Add_float(_DynamicMask_e6689341c7c04c1bb33ed3b487300049_Out_3_Float, _DynamicMask_b2fc7ae4954b44eeb314569a9a849f6f_Out_3_Float, _Add_d570aea5942649aba75f7914130198d9_Out_2_Float);
float _Saturate_a60e6e3d79d04cf9ac5fa0f6b0d4ffef_Out_1_Float;
Unity_Saturate_float(_Add_d570aea5942649aba75f7914130198d9_Out_2_Float, _Saturate_a60e6e3d79d04cf9ac5fa0f6b0d4ffef_Out_1_Float);
float _Multiply_b3cffbd67298456b992ab87b0e1b94d7_Out_2_Float;
Unity_Multiply_float_float(_WireframeRenderer_8b6e53cbe97c4fee809b54677b9a7128_Wireframe_3_Float, _Saturate_a60e6e3d79d04cf9ac5fa0f6b0d4ffef_Out_1_Float, _Multiply_b3cffbd67298456b992ab87b0e1b94d7_Out_2_Float);
float4 _Lerp_130fe097f09542d1b7fa52dfa8fd1871_Out_3_Vector4;
Unity_Lerp_float4(_SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4, _Property_fea879b3f3324ecb9cb1e0f2f9890529_Out_0_Vector4, (_Multiply_b3cffbd67298456b992ab87b0e1b94d7_Out_2_Float.xxxx), _Lerp_130fe097f09542d1b7fa52dfa8fd1871_Out_3_Vector4);
surface.BaseColor = (_Lerp_130fe097f09542d1b7fa52dfa8fd1871_Out_3_Vector4.xyz);
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
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

// --------------------------------------------------
// Visual Effect Vertex Invocations
#ifdef HAVE_VFX_MODIFICATION
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
#endif

ENDHLSL
}
}
CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
FallBack "Hidden/Shader Graph/FallbackError"
}

/*ShaderGraphBody_Begin
{
    "m_SGVersion": 3,
    "m_Type": "UnityEditor.ShaderGraph.GraphData",
    "m_ObjectId": "35927402641e4517bcb949df90092197",
    "m_Properties": [
        {
            "m_Id": "937f028802f64a58a20c076445e50f2e"
        },
        {
            "m_Id": "842fd52f0e9a4711a43832f3f8277716"
        },
        {
            "m_Id": "da1822c6f5a44b2ab54c0ee0111a7ac1"
        },
        {
            "m_Id": "5ab111f7f3fa4c91a4f0289f06c16f3d"
        },
        {
            "m_Id": "84c0b020a2ac444aa5f6fb7f18c449f2"
        },
        {
            "m_Id": "b8c204dc160d43a298e621c8c920af8a"
        },
        {
            "m_Id": "0dc0be771cc64b1bb628f567cb187a44"
        },
        {
            "m_Id": "b19a2e9544e84848bf3f4b19948a8a63"
        },
        {
            "m_Id": "fa96b8e4c3cf4ba39c8692064c29b868"
        },
        {
            "m_Id": "d3b158c4672e4988b5b4ac8180ab6742"
        },
        {
            "m_Id": "f96e48a170a3461ea6881cc0b6a34099"
        }
    ],
    "m_Keywords": [],
    "m_Dropdowns": [],
    "m_CategoryData": [
        {
            "m_Id": "dd6fcdf0141b461d9ce07ca51467b3c4"
        },
        {
            "m_Id": "78a625ecc88b402696da4b19223af879"
        },
        {
            "m_Id": "54de580d954f49e6b5731b11f1dcdd35"
        }
    ],
    "m_Nodes": [
        {
            "m_Id": "a0ff7a5655a241a693febc2166745dd3"
        },
        {
            "m_Id": "4324d39072de4d928c7d1848983bb03a"
        },
        {
            "m_Id": "f1a6a40111e048918c477da6c320139d"
        },
        {
            "m_Id": "223f143177fe4cbfbe17cfa0dfc1eb71"
        },
        {
            "m_Id": "9378eb7ab88347b093b169c87551d064"
        },
        {
            "m_Id": "195081f1ea634199a5f67314d3febc32"
        },
        {
            "m_Id": "7699a0563c2a4636b70c794ae6b5420e"
        },
        {
            "m_Id": "354f04f299e94eb3aeb99dea1d1e9cb2"
        },
        {
            "m_Id": "ee1c94e2e7134f96b17bbdca87acc73f"
        },
        {
            "m_Id": "1dc4788b9eca4069baa399efa4413298"
        },
        {
            "m_Id": "8b57c7d9cbef4037966ba71e85a6a06c"
        },
        {
            "m_Id": "130fe097f09542d1b7fa52dfa8fd1871"
        },
        {
            "m_Id": "b3cffbd67298456b992ab87b0e1b94d7"
        },
        {
            "m_Id": "fea879b3f3324ecb9cb1e0f2f9890529"
        },
        {
            "m_Id": "6dd7819e424c402fb1716035e270a4c8"
        },
        {
            "m_Id": "9bacd1d8d3194f1a909e0626a17f0a93"
        },
        {
            "m_Id": "7be0d2ff2c5f4926a7df4197b8a5a50b"
        },
        {
            "m_Id": "a323fdd57f844bd4b77bbbfbc3724586"
        },
        {
            "m_Id": "7f3cbaed20da468c9673eedd1a7cdb21"
        },
        {
            "m_Id": "b128fdcca5a64a7094c0b715bebb918b"
        },
        {
            "m_Id": "e8ba8aacd2e94a59973b09180d2b3ffe"
        },
        {
            "m_Id": "e736e9327527475591515cc473446022"
        },
        {
            "m_Id": "61443c13e4e6478db7f39de5b2fc0912"
        },
        {
            "m_Id": "cf8b9bf5cc9549f59bd6dc9554d3596f"
        },
        {
            "m_Id": "1c55779b66f6451f89723c97ed9f9ac8"
        },
        {
            "m_Id": "653d13a86ab946c195c7ca1b0e841886"
        },
        {
            "m_Id": "4baf1dcd456b43f2bf0aae60a6240a0f"
        },
        {
            "m_Id": "182bc4539ba648d2b933f00c42f90390"
        },
        {
            "m_Id": "d570aea5942649aba75f7914130198d9"
        },
        {
            "m_Id": "a60e6e3d79d04cf9ac5fa0f6b0d4ffef"
        },
        {
            "m_Id": "8b6e53cbe97c4fee809b54677b9a7128"
        },
        {
            "m_Id": "e6689341c7c04c1bb33ed3b487300049"
        },
        {
            "m_Id": "b2fc7ae4954b44eeb314569a9a849f6f"
        }
    ],
    "m_GroupDatas": [
        {
            "m_Id": "7c985fb07f3644dab9661170f6578499"
        },
        {
            "m_Id": "fd00382be8834040a9e03a234a798cf5"
        }
    ],
    "m_StickyNoteDatas": [],
    "m_Edges": [
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "130fe097f09542d1b7fa52dfa8fd1871"
                },
                "m_SlotId": 3
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
                    "m_Id": "182bc4539ba648d2b933f00c42f90390"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "b2fc7ae4954b44eeb314569a9a849f6f"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "195081f1ea634199a5f67314d3febc32"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "7699a0563c2a4636b70c794ae6b5420e"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "1dc4788b9eca4069baa399efa4413298"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "8b6e53cbe97c4fee809b54677b9a7128"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "354f04f299e94eb3aeb99dea1d1e9cb2"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "ee1c94e2e7134f96b17bbdca87acc73f"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "4baf1dcd456b43f2bf0aae60a6240a0f"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "e6689341c7c04c1bb33ed3b487300049"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "6dd7819e424c402fb1716035e270a4c8"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "9bacd1d8d3194f1a909e0626a17f0a93"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "7699a0563c2a4636b70c794ae6b5420e"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "130fe097f09542d1b7fa52dfa8fd1871"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "7be0d2ff2c5f4926a7df4197b8a5a50b"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "a323fdd57f844bd4b77bbbfbc3724586"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "7f3cbaed20da468c9673eedd1a7cdb21"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "a323fdd57f844bd4b77bbbfbc3724586"
                },
                "m_SlotId": 2
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
                    "m_Id": "8b6e53cbe97c4fee809b54677b9a7128"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "8b6e53cbe97c4fee809b54677b9a7128"
                },
                "m_SlotId": 3
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "b3cffbd67298456b992ab87b0e1b94d7"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "9bacd1d8d3194f1a909e0626a17f0a93"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "e8ba8aacd2e94a59973b09180d2b3ffe"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "a323fdd57f844bd4b77bbbfbc3724586"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "e8ba8aacd2e94a59973b09180d2b3ffe"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "a60e6e3d79d04cf9ac5fa0f6b0d4ffef"
                },
                "m_SlotId": 1
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "b3cffbd67298456b992ab87b0e1b94d7"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "b128fdcca5a64a7094c0b715bebb918b"
                },
                "m_SlotId": 1
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "f1a6a40111e048918c477da6c320139d"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "b128fdcca5a64a7094c0b715bebb918b"
                },
                "m_SlotId": 2
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "9378eb7ab88347b093b169c87551d064"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "b128fdcca5a64a7094c0b715bebb918b"
                },
                "m_SlotId": 4
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "223f143177fe4cbfbe17cfa0dfc1eb71"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "b2fc7ae4954b44eeb314569a9a849f6f"
                },
                "m_SlotId": 3
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "d570aea5942649aba75f7914130198d9"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "b3cffbd67298456b992ab87b0e1b94d7"
                },
                "m_SlotId": 2
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "130fe097f09542d1b7fa52dfa8fd1871"
                },
                "m_SlotId": 2
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "d570aea5942649aba75f7914130198d9"
                },
                "m_SlotId": 2
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "a60e6e3d79d04cf9ac5fa0f6b0d4ffef"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "e6689341c7c04c1bb33ed3b487300049"
                },
                "m_SlotId": 3
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "d570aea5942649aba75f7914130198d9"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "e736e9327527475591515cc473446022"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "a323fdd57f844bd4b77bbbfbc3724586"
                },
                "m_SlotId": 4
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "e8ba8aacd2e94a59973b09180d2b3ffe"
                },
                "m_SlotId": 2
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "b128fdcca5a64a7094c0b715bebb918b"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "ee1c94e2e7134f96b17bbdca87acc73f"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "4324d39072de4d928c7d1848983bb03a"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "fea879b3f3324ecb9cb1e0f2f9890529"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "130fe097f09542d1b7fa52dfa8fd1871"
                },
                "m_SlotId": 1
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
                "m_Id": "61443c13e4e6478db7f39de5b2fc0912"
            },
            {
                "m_Id": "cf8b9bf5cc9549f59bd6dc9554d3596f"
            },
            {
                "m_Id": "1c55779b66f6451f89723c97ed9f9ac8"
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
                "m_Id": "653d13a86ab946c195c7ca1b0e841886"
            },
            {
                "m_Id": "4324d39072de4d928c7d1848983bb03a"
            },
            {
                "m_Id": "f1a6a40111e048918c477da6c320139d"
            },
            {
                "m_Id": "9378eb7ab88347b093b169c87551d064"
            },
            {
                "m_Id": "223f143177fe4cbfbe17cfa0dfc1eb71"
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
            "m_Id": "5aaacd9dfdbd46f188f277c43bca82aa"
        }
    ]
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "01b724267af44d95933f7d4b5d035fde",
    "m_Id": 0,
    "m_DisplayName": "Metallic",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "Metallic",
    "m_StageCapability": 2,
    "m_Value": 0.0,
    "m_DefaultValue": 0.0,
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.TangentMaterialSlot",
    "m_ObjectId": "063a75a2393f43e5b777e23666b48e72",
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
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "0962ebb6d48d4546b64ea5f5c4b8683c",
    "m_Id": 0,
    "m_DisplayName": "Smoothness",
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
    "m_Type": "UnityEditor.ShaderGraph.PositionMaterialSlot",
    "m_ObjectId": "0a2aa242d18545c2bf8176d25712766a",
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
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Internal.Texture2DShaderProperty",
    "m_ObjectId": "0dc0be771cc64b1bb628f567cb187a44",
    "m_Guid": {
        "m_GuidSerialized": "f90ae32a-ff03-48ad-9062-fe9975c95401"
    },
    "m_Name": "Normal Map",
    "m_DefaultRefNameVersion": 1,
    "m_RefNameGeneratedByDisplayName": "Normal Map",
    "m_DefaultReferenceName": "_Normal_Map",
    "m_OverrideReferenceName": "_NormalMap",
    "m_GeneratePropertyBlock": true,
    "m_UseCustomSlotLabel": false,
    "m_CustomSlotLabel": "",
    "m_DismissedVersion": 0,
    "m_Precision": 0,
    "overrideHLSLDeclaration": false,
    "hlslDeclarationOverride": 0,
    "m_Hidden": false,
    "m_Value": {
        "m_SerializedTexture": "{\"texture\":{\"instanceID\":0}}",
        "m_Guid": ""
    },
    "isMainTexture": false,
    "useTilingAndOffset": false,
    "m_Modifiable": true,
    "m_DefaultType": 3
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "0f24053e80fe4f66bf9b7b8bbf0428ec",
    "m_Id": 2,
    "m_DisplayName": "G",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "G",
    "m_StageCapability": 3,
    "m_Value": 0.0,
    "m_DefaultValue": 0.0,
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.LerpNode",
    "m_ObjectId": "130fe097f09542d1b7fa52dfa8fd1871",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "Lerp",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -423.2727355957031,
            "y": -116.94548034667969,
            "width": 132.65457153320313,
            "height": 141.38186645507813
        }
    },
    "m_Slots": [
        {
            "m_Id": "f74bff52633948b68a4c46e16aac0d77"
        },
        {
            "m_Id": "7a2cb522806b4185b512cd9dd1da18d4"
        },
        {
            "m_Id": "a27307b823b04fd4aa930130f3ddaa3d"
        },
        {
            "m_Id": "5fd2c974d97f4ad28bfb5432d450b9ec"
        }
    ],
    "synonyms": [
        "mix",
        "blend",
        "linear interpolate"
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
    "m_Type": "UnityEditor.ShaderGraph.SamplerStateMaterialSlot",
    "m_ObjectId": "1541f7b97ff147298033d9a478313ef5",
    "m_Id": 3,
    "m_DisplayName": "Sampler",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "Sampler",
    "m_StageCapability": 3,
    "m_BareResource": false
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.PropertyNode",
    "m_ObjectId": "182bc4539ba648d2b933f00c42f90390",
    "m_Group": {
        "m_Id": "fd00382be8834040a9e03a234a798cf5"
    },
    "m_Name": "Property",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -2302.254638671875,
            "y": 431.1272888183594,
            "width": 231.2724609375,
            "height": 32.290924072265628
        }
    },
    "m_Slots": [
        {
            "m_Id": "7d3839519e704425bea1477dcf4a7f32"
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
        "m_Id": "937f028802f64a58a20c076445e50f2e"
    }
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
    "m_ObjectId": "195081f1ea634199a5f67314d3febc32",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "Property",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -932.9454345703125,
            "y": -233.01820373535157,
            "width": 137.0181884765625,
            "height": 32.29090881347656
        }
    },
    "m_Slots": [
        {
            "m_Id": "b23e0dcee3394774b2577dcad4c4895d"
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
        "m_Id": "842fd52f0e9a4711a43832f3f8277716"
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "1ae3da6e32044a498a36f26f9e99d68b",
    "m_Id": 3,
    "m_DisplayName": "Z",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "Z",
    "m_StageCapability": 3,
    "m_Value": 0.0,
    "m_DefaultValue": 0.0,
    "m_Labels": [
        "Z"
    ]
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.UVMaterialSlot",
    "m_ObjectId": "1b8e5acbb2ca49a791df91d6ae58e85e",
    "m_Id": 2,
    "m_DisplayName": "UV",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "UV",
    "m_StageCapability": 3,
    "m_Value": {
        "x": 0.0,
        "y": 0.0
    },
    "m_DefaultValue": {
        "x": 0.0,
        "y": 0.0
    },
    "m_Labels": [],
    "m_Channel": 0
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.BlockNode",
    "m_ObjectId": "1c55779b66f6451f89723c97ed9f9ac8",
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
            "m_Id": "063a75a2393f43e5b777e23666b48e72"
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
            "x": -1923.4906005859375,
            "y": -240.87261962890626,
            "width": 186.7635498046875,
            "height": 32.290863037109378
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
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "21a2226491864192a0b90be507491392",
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
    "m_Type": "UnityEditor.ShaderGraph.BlockNode",
    "m_ObjectId": "223f143177fe4cbfbe17cfa0dfc1eb71",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "SurfaceDescription.Smoothness",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": 6.9818434715271,
            "y": 528.8727416992188,
            "width": 199.85458374023438,
            "height": 40.14544677734375
        }
    },
    "m_Slots": [
        {
            "m_Id": "8e703717eb584bd0904ab61159dbf49c"
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
    "m_SerializedDescriptor": "SurfaceDescription.Smoothness"
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "26957a32f030431582376646e9cb1432",
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
    "m_Type": "UnityEditor.ShaderGraph.Texture2DMaterialSlot",
    "m_ObjectId": "2b3345c358aa445994ff1eb8d699c80a",
    "m_Id": 0,
    "m_DisplayName": "Mask Map",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "Out",
    "m_StageCapability": 3,
    "m_BareResource": false
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "2d32fca700404eae8fb9f7e719ccce57",
    "m_Id": 0,
    "m_DisplayName": "Occlusion",
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
    "m_ObjectId": "31706ca62de048809357f470b59c459d",
    "m_Id": 4,
    "m_DisplayName": "W",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "W",
    "m_StageCapability": 3,
    "m_Value": 0.0,
    "m_DefaultValue": 0.0,
    "m_Labels": [
        "W"
    ]
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
    "m_Type": "UnityEditor.ShaderGraph.PropertyNode",
    "m_ObjectId": "354f04f299e94eb3aeb99dea1d1e9cb2",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "Property",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -656.2908325195313,
            "y": 315.05450439453127,
            "width": 149.236328125,
            "height": 32.290985107421878
        }
    },
    "m_Slots": [
        {
            "m_Id": "82b72e992be840f685ce407a3a0f3060"
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
        "m_Id": "0dc0be771cc64b1bb628f567cb187a44"
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "35902d1d93184e83b0c0037c8af0a768",
    "m_Id": 0,
    "m_DisplayName": "Metallic",
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
    "m_Type": "UnityEditor.Rendering.HighDefinition.ShaderGraph.HDUnlitSubTarget",
    "m_ObjectId": "39581a4de0354281aaa86ee401b6cfb4"
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.BlockNode",
    "m_ObjectId": "4324d39072de4d928c7d1848983bb03a",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "SurfaceDescription.NormalTS",
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
            "m_Id": "a90c2dc97c6f4f78b6ce0fae204341a3"
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
    "m_SerializedDescriptor": "SurfaceDescription.NormalTS"
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Texture2DInputMaterialSlot",
    "m_ObjectId": "44dc67eb09b24e2c9906e495b2a70d15",
    "m_Id": 1,
    "m_DisplayName": "Texture",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "Texture",
    "m_StageCapability": 3,
    "m_BareResource": false,
    "m_Texture": {
        "m_SerializedTexture": "{\"texture\":{\"instanceID\":0}}",
        "m_Guid": ""
    },
    "m_DefaultType": 0
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.PositionMaterialSlot",
    "m_ObjectId": "4919ca3e26c141c6ac3832a260d4977a",
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "497954928cb343c086ba15f3b58a24e3",
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
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "4a8838bf18f94291bf13f0220122f2b7",
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
    "m_Type": "UnityEditor.ShaderGraph.PropertyNode",
    "m_ObjectId": "4baf1dcd456b43f2bf0aae60a6240a0f",
    "m_Group": {
        "m_Id": "fd00382be8834040a9e03a234a798cf5"
    },
    "m_Name": "Property",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -2300.509033203125,
            "y": 216.4363555908203,
            "width": 229.52734375,
            "height": 32.29090881347656
        }
    },
    "m_Slots": [
        {
            "m_Id": "dbce00f16cc4493a91de6589becf3708"
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
        "m_Id": "5ab111f7f3fa4c91a4f0289f06c16f3d"
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.CategoryData",
    "m_ObjectId": "54de580d954f49e6b5731b11f1dcdd35",
    "m_Name": "Base",
    "m_ChildObjectList": [
        {
            "m_Id": "842fd52f0e9a4711a43832f3f8277716"
        },
        {
            "m_Id": "0dc0be771cc64b1bb628f567cb187a44"
        },
        {
            "m_Id": "b19a2e9544e84848bf3f4b19948a8a63"
        },
        {
            "m_Id": "da1822c6f5a44b2ab54c0ee0111a7ac1"
        },
        {
            "m_Id": "84c0b020a2ac444aa5f6fb7f18c449f2"
        },
        {
            "m_Id": "b8c204dc160d43a298e621c8c920af8a"
        }
    ]
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "555a755e7409424b93354b369d6c5c85",
    "m_Id": 7,
    "m_DisplayName": "A",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "A",
    "m_StageCapability": 2,
    "m_Value": 0.0,
    "m_DefaultValue": 0.0,
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "56d60ff234af4d19b9de32ce0a287207",
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "57b33f820c024ff9b926d3cd798ced82",
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
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "5815349b9368469e86d14abe0f3889aa",
    "m_Id": 4,
    "m_DisplayName": "A",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "A",
    "m_StageCapability": 3,
    "m_Value": 0.0,
    "m_DefaultValue": 0.0,
    "m_Labels": []
}

{
    "m_SGVersion": 1,
    "m_Type": "UnityEditor.Rendering.Universal.ShaderGraph.UniversalTarget",
    "m_ObjectId": "5aaacd9dfdbd46f188f277c43bca82aa",
    "m_Datas": [],
    "m_ActiveSubTarget": {
        "m_Id": "81106e156bff4c9c93667ea648b1aa69"
    },
    "m_AllowMaterialOverride": false,
    "m_SurfaceType": 0,
    "m_ZTestMode": 4,
    "m_ZWriteControl": 0,
    "m_AlphaMode": 0,
    "m_RenderFace": 2,
    "m_AlphaClip": false,
    "m_CastShadows": true,
    "m_ReceiveShadows": true,
    "m_SupportsLODCrossFade": false,
    "m_CustomEditorGUI": "",
    "m_SupportVFX": false
}

{
    "m_SGVersion": 1,
    "m_Type": "UnityEditor.ShaderGraph.Matrix4ShaderProperty",
    "m_ObjectId": "5ab111f7f3fa4c91a4f0289f06c16f3d",
    "m_Guid": {
        "m_GuidSerialized": "7ddea530-df44-49de-a518-e9cf64174659"
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "5fd2c974d97f4ad28bfb5432d450b9ec",
    "m_Id": 3,
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
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "608b1d4e1c614e99ad3b8666f8da5a58",
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
    "m_Type": "UnityEditor.ShaderGraph.BlockNode",
    "m_ObjectId": "61443c13e4e6478db7f39de5b2fc0912",
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
            "m_Id": "0a2aa242d18545c2bf8176d25712766a"
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
    "m_Type": "UnityEditor.ShaderGraph.UVMaterialSlot",
    "m_ObjectId": "642671cb557a4462b8f7d57633e40fc5",
    "m_Id": 2,
    "m_DisplayName": "UV",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "UV",
    "m_StageCapability": 3,
    "m_Value": {
        "x": 0.0,
        "y": 0.0
    },
    "m_DefaultValue": {
        "x": 0.0,
        "y": 0.0
    },
    "m_Labels": [],
    "m_Channel": 0
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.NormalMaterialSlot",
    "m_ObjectId": "6472603213a6485dabd0e1543aa5c51e",
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
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "648cc1b7cf0a42b291579c9d43cc387e",
    "m_Id": 1,
    "m_DisplayName": "X",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "X",
    "m_StageCapability": 3,
    "m_Value": 0.0,
    "m_DefaultValue": 0.0,
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.BlockNode",
    "m_ObjectId": "653d13a86ab946c195c7ca1b0e841886",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "SurfaceDescription.Emission",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": 8.727349281311036,
            "y": 266.18182373046877,
            "width": 199.85447692871095,
            "height": 41.01812744140625
        }
    },
    "m_Slots": [
        {
            "m_Id": "a4618ccc7ab64f598a715804f2349097"
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
    "m_SerializedDescriptor": "SurfaceDescription.Emission"
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "68f9bd55846d4cf580935224b4647981",
    "m_Id": 6,
    "m_DisplayName": "B",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "B",
    "m_StageCapability": 2,
    "m_Value": 0.0,
    "m_DefaultValue": 0.0,
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.UVMaterialSlot",
    "m_ObjectId": "6a06d6f9ab4749d8a3c7c02491c78fed",
    "m_Id": 2,
    "m_DisplayName": "UV",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "UV",
    "m_StageCapability": 3,
    "m_Value": {
        "x": 0.0,
        "y": 0.0
    },
    "m_DefaultValue": {
        "x": 0.0,
        "y": 0.0
    },
    "m_Labels": [],
    "m_Channel": 0
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.PropertyNode",
    "m_ObjectId": "6dd7819e424c402fb1716035e270a4c8",
    "m_Group": {
        "m_Id": "7c985fb07f3644dab9661170f6578499"
    },
    "m_Name": "Property",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1016.7272338867188,
            "y": 717.3817749023438,
            "width": 139.63623046875,
            "height": 33.16363525390625
        }
    },
    "m_Slots": [
        {
            "m_Id": "2b3345c358aa445994ff1eb8d699c80a"
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
        "m_Id": "b19a2e9544e84848bf3f4b19948a8a63"
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "741eed2052ba4bfd9c8df46ae7c58142",
    "m_Id": 6,
    "m_DisplayName": "B",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "B",
    "m_StageCapability": 2,
    "m_Value": 0.0,
    "m_DefaultValue": 0.0,
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "7586e2d229e545a39a68109a65146412",
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
    "m_Type": "UnityEditor.ShaderGraph.SampleTexture2DNode",
    "m_ObjectId": "7699a0563c2a4636b70c794ae6b5420e",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "Sample Texture 2D",
    "m_DrawState": {
        "m_Expanded": false,
        "m_Position": {
            "serializedVersion": "2",
            "x": -758.3999633789063,
            "y": -272.2908630371094,
            "width": 184.14544677734376,
            "height": 155.34544372558595
        }
    },
    "m_Slots": [
        {
            "m_Id": "e4dbc20d90f64f6881ac9c776f01d9c9"
        },
        {
            "m_Id": "a69620faedd84dc08312485516f2b0f8"
        },
        {
            "m_Id": "d81c992093df4cad9bc68c6388612795"
        },
        {
            "m_Id": "68f9bd55846d4cf580935224b4647981"
        },
        {
            "m_Id": "ecb92ce6f8c544d1807a496ea75d25ed"
        },
        {
            "m_Id": "44dc67eb09b24e2c9906e495b2a70d15"
        },
        {
            "m_Id": "6a06d6f9ab4749d8a3c7c02491c78fed"
        },
        {
            "m_Id": "998283e1cf1a433cb42637c0cffaf851"
        }
    ],
    "synonyms": [
        "tex2d"
    ],
    "m_Precision": 0,
    "m_PreviewExpanded": false,
    "m_DismissedVersion": 0,
    "m_PreviewMode": 0,
    "m_CustomColors": {
        "m_SerializableColors": []
    },
    "m_TextureType": 0,
    "m_NormalMapSpace": 0,
    "m_EnableGlobalMipBias": true,
    "m_MipSamplingMode": 0
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "77873a82123e4f8abae6df157a879061",
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
    "m_ObjectId": "78a625ecc88b402696da4b19223af879",
    "m_Name": "Wireframe",
    "m_ChildObjectList": [
        {
            "m_Id": "fa96b8e4c3cf4ba39c8692064c29b868"
        },
        {
            "m_Id": "f96e48a170a3461ea6881cc0b6a34099"
        },
        {
            "m_Id": "d3b158c4672e4988b5b4ac8180ab6742"
        },
        {
            "m_Id": "5ab111f7f3fa4c91a4f0289f06c16f3d"
        },
        {
            "m_Id": "937f028802f64a58a20c076445e50f2e"
        }
    ]
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "7929d885cac34723975734b159f56ba2",
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "7a2cb522806b4185b512cd9dd1da18d4",
    "m_Id": 1,
    "m_DisplayName": "B",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "B",
    "m_StageCapability": 3,
    "m_Value": {
        "x": 1.0,
        "y": 1.0,
        "z": 1.0,
        "w": 1.0
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "7a527715caa84f229a4811a4855257a8",
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
    "m_Type": "UnityEditor.ShaderGraph.PropertyNode",
    "m_ObjectId": "7be0d2ff2c5f4926a7df4197b8a5a50b",
    "m_Group": {
        "m_Id": "7c985fb07f3644dab9661170f6578499"
    },
    "m_Name": "Property",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -996.654541015625,
            "y": 895.4181518554688,
            "width": 117.8182373046875,
            "height": 33.1636962890625
        }
    },
    "m_Slots": [
        {
            "m_Id": "35902d1d93184e83b0c0037c8af0a768"
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
        "m_Id": "da1822c6f5a44b2ab54c0ee0111a7ac1"
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.GroupData",
    "m_ObjectId": "7c985fb07f3644dab9661170f6578499",
    "m_Title": "Metallic / Smoothness / Occlusion",
    "m_Position": {
        "x": -1044.654541015625,
        "y": 619.6362915039063
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Matrix4MaterialSlot",
    "m_ObjectId": "7d3839519e704425bea1477dcf4a7f32",
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
    "m_Type": "UnityEditor.ShaderGraph.Texture2DInputMaterialSlot",
    "m_ObjectId": "7e431846d43640d2bc8d9e7d3268f2db",
    "m_Id": 1,
    "m_DisplayName": "Texture",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "Texture",
    "m_StageCapability": 3,
    "m_BareResource": false,
    "m_Texture": {
        "m_SerializedTexture": "{\"texture\":{\"instanceID\":0}}",
        "m_Guid": ""
    },
    "m_DefaultType": 0
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.PropertyNode",
    "m_ObjectId": "7f3cbaed20da468c9673eedd1a7cdb21",
    "m_Group": {
        "m_Id": "7c985fb07f3644dab9661170f6578499"
    },
    "m_Name": "Property",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1007.127197265625,
            "y": 923.3453979492188,
            "width": 128.2908935546875,
            "height": 33.16357421875
        }
    },
    "m_Slots": [
        {
            "m_Id": "2d32fca700404eae8fb9f7e719ccce57"
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
        "m_Id": "b8c204dc160d43a298e621c8c920af8a"
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
    "m_ObjectId": "7f6cb7377d63426a8e4e5afc46a3a391",
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
    "m_SGVersion": 2,
    "m_Type": "UnityEditor.Rendering.Universal.ShaderGraph.UniversalLitSubTarget",
    "m_ObjectId": "81106e156bff4c9c93667ea648b1aa69",
    "m_WorkflowMode": 1,
    "m_NormalDropOffSpace": 0,
    "m_ClearCoat": false,
    "m_BlendModePreserveSpecular": true
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Texture2DMaterialSlot",
    "m_ObjectId": "82b72e992be840f685ce407a3a0f3060",
    "m_Id": 0,
    "m_DisplayName": "Normal Map",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "Out",
    "m_StageCapability": 3,
    "m_BareResource": false
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector4MaterialSlot",
    "m_ObjectId": "832b4d561e7b4790a49ddd757bb8e068",
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
    "m_Type": "UnityEditor.ShaderGraph.Internal.Texture2DShaderProperty",
    "m_ObjectId": "842fd52f0e9a4711a43832f3f8277716",
    "m_Guid": {
        "m_GuidSerialized": "eb5a3a35-dd2e-4249-ac30-5acc36c0690f"
    },
    "m_Name": "Base Map",
    "m_DefaultRefNameVersion": 1,
    "m_RefNameGeneratedByDisplayName": "Base Map",
    "m_DefaultReferenceName": "_Base_Map",
    "m_OverrideReferenceName": "_BaseColorMap",
    "m_GeneratePropertyBlock": true,
    "m_UseCustomSlotLabel": false,
    "m_CustomSlotLabel": "",
    "m_DismissedVersion": 0,
    "m_Precision": 0,
    "overrideHLSLDeclaration": false,
    "hlslDeclarationOverride": 0,
    "m_Hidden": false,
    "m_Value": {
        "m_SerializedTexture": "{\"texture\":{\"instanceID\":0}}",
        "m_Guid": ""
    },
    "isMainTexture": false,
    "useTilingAndOffset": false,
    "m_Modifiable": true,
    "m_DefaultType": 0
}

{
    "m_SGVersion": 1,
    "m_Type": "UnityEditor.ShaderGraph.Internal.Vector1ShaderProperty",
    "m_ObjectId": "84c0b020a2ac444aa5f6fb7f18c449f2",
    "m_Guid": {
        "m_GuidSerialized": "1a8ba164-6e2f-425b-9ec5-b7c62cc9865b"
    },
    "m_Name": "Smoothness",
    "m_DefaultRefNameVersion": 1,
    "m_RefNameGeneratedByDisplayName": "Smoothness",
    "m_DefaultReferenceName": "_Smoothness",
    "m_OverrideReferenceName": "",
    "m_GeneratePropertyBlock": true,
    "m_UseCustomSlotLabel": false,
    "m_CustomSlotLabel": "",
    "m_DismissedVersion": 0,
    "m_Precision": 0,
    "overrideHLSLDeclaration": false,
    "hlslDeclarationOverride": 0,
    "m_Hidden": false,
    "m_Value": 0.0,
    "m_FloatType": 1,
    "m_RangeValues": {
        "x": 0.0,
        "y": 1.0
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Matrix4MaterialSlot",
    "m_ObjectId": "89f766f41e574232a7e8a5b785d5f439",
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
            "x": -1935.7088623046875,
            "y": -194.61814880371095,
            "width": 198.9818115234375,
            "height": 32.29096984863281
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
    "m_Type": "AmazingAssets.DynamicWireframeShaderGenerator.Editor.WireframeRendererNode",
    "m_ObjectId": "8b6e53cbe97c4fee809b54677b9a7128",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "Wireframe Renderer",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1683.490966796875,
            "y": -272.2909240722656,
            "width": 315.92724609375,
            "height": 164.94544982910157
        }
    },
    "m_Slots": [
        {
            "m_Id": "7f6cb7377d63426a8e4e5afc46a3a391"
        },
        {
            "m_Id": "7929d885cac34723975734b159f56ba2"
        },
        {
            "m_Id": "21a2226491864192a0b90be507491392"
        },
        {
            "m_Id": "db930cf370314af3889180e70c010c7a"
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
    "m_Type": "UnityEditor.ShaderGraph.Vector4MaterialSlot",
    "m_ObjectId": "8d0cc36f3a4d47229a4f5842d05b2daa",
    "m_Id": 0,
    "m_DisplayName": "RGBA",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "RGBA",
    "m_StageCapability": 2,
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
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "8e703717eb584bd0904ab61159dbf49c",
    "m_Id": 0,
    "m_DisplayName": "Smoothness",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "Smoothness",
    "m_StageCapability": 2,
    "m_Value": 0.5,
    "m_DefaultValue": 0.5,
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "8f187c9977144dd5afbc1df93e431777",
    "m_Id": 4,
    "m_DisplayName": "R",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "R",
    "m_StageCapability": 2,
    "m_Value": 0.0,
    "m_DefaultValue": 0.0,
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.BlockNode",
    "m_ObjectId": "9378eb7ab88347b093b169c87551d064",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "SurfaceDescription.Occlusion",
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
            "m_Id": "cf90db5e5c5147b38fe0082241ecb138"
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
    "m_SerializedDescriptor": "SurfaceDescription.Occlusion"
}

{
    "m_SGVersion": 1,
    "m_Type": "UnityEditor.ShaderGraph.Matrix4ShaderProperty",
    "m_ObjectId": "937f028802f64a58a20c076445e50f2e",
    "m_Guid": {
        "m_GuidSerialized": "b441f9ed-481f-4ec1-b7a0-f6a577b2aa49"
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
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "94d27173e8094ee592846781b3eb8663",
    "m_Id": 1,
    "m_DisplayName": "R",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "R",
    "m_StageCapability": 3,
    "m_Value": 0.0,
    "m_DefaultValue": 0.0,
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.SamplerStateMaterialSlot",
    "m_ObjectId": "9809dc607ba44223bf310719ac9cf814",
    "m_Id": 3,
    "m_DisplayName": "Sampler",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "Sampler",
    "m_StageCapability": 3,
    "m_BareResource": false
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.SamplerStateMaterialSlot",
    "m_ObjectId": "998283e1cf1a433cb42637c0cffaf851",
    "m_Id": 3,
    "m_DisplayName": "Sampler",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "Sampler",
    "m_StageCapability": 3,
    "m_BareResource": false
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "9ad065ea94a94af899861e015730488b",
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
    "m_Type": "UnityEditor.ShaderGraph.SampleTexture2DNode",
    "m_ObjectId": "9bacd1d8d3194f1a909e0626a17f0a93",
    "m_Group": {
        "m_Id": "7c985fb07f3644dab9661170f6578499"
    },
    "m_Name": "Sample Texture 2D",
    "m_DrawState": {
        "m_Expanded": false,
        "m_Position": {
            "serializedVersion": "2",
            "x": -838.6908569335938,
            "y": 677.236328125,
            "width": 184.1453857421875,
            "height": 155.345458984375
        }
    },
    "m_Slots": [
        {
            "m_Id": "8d0cc36f3a4d47229a4f5842d05b2daa"
        },
        {
            "m_Id": "aea9a7b4dc164f25b81ee97eb9e7f40f"
        },
        {
            "m_Id": "acd7dea226d54b98baf647578450ddc2"
        },
        {
            "m_Id": "a905a848946840a089524d9309b9570d"
        },
        {
            "m_Id": "555a755e7409424b93354b369d6c5c85"
        },
        {
            "m_Id": "7e431846d43640d2bc8d9e7d3268f2db"
        },
        {
            "m_Id": "642671cb557a4462b8f7d57633e40fc5"
        },
        {
            "m_Id": "1541f7b97ff147298033d9a478313ef5"
        }
    ],
    "synonyms": [
        "tex2d"
    ],
    "m_Precision": 0,
    "m_PreviewExpanded": false,
    "m_DismissedVersion": 0,
    "m_PreviewMode": 0,
    "m_CustomColors": {
        "m_SerializableColors": []
    },
    "m_TextureType": 0,
    "m_NormalMapSpace": 0,
    "m_EnableGlobalMipBias": true,
    "m_MipSamplingMode": 0
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "a27307b823b04fd4aa930130f3ddaa3d",
    "m_Id": 2,
    "m_DisplayName": "T",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "T",
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
    "m_Type": "UnityEditor.ShaderGraph.Vector4Node",
    "m_ObjectId": "a323fdd57f844bd4b77bbbfbc3724586",
    "m_Group": {
        "m_Id": "7c985fb07f3644dab9661170f6578499"
    },
    "m_Name": "Vector 4",
    "m_DrawState": {
        "m_Expanded": false,
        "m_Position": {
            "serializedVersion": "2",
            "x": -788.0726928710938,
            "y": 857.8908081054688,
            "width": 133.5272216796875,
            "height": 124.79998779296875
        }
    },
    "m_Slots": [
        {
            "m_Id": "648cc1b7cf0a42b291579c9d43cc387e"
        },
        {
            "m_Id": "f480a3129542455094b2ad0f977e3eb7"
        },
        {
            "m_Id": "1ae3da6e32044a498a36f26f9e99d68b"
        },
        {
            "m_Id": "31706ca62de048809357f470b59c459d"
        },
        {
            "m_Id": "b839bbe1063c4af095b9b47cd43d4382"
        }
    ],
    "synonyms": [
        "4",
        "v4",
        "vec4",
        "float4"
    ],
    "m_Precision": 0,
    "m_PreviewExpanded": true,
    "m_DismissedVersion": 0,
    "m_PreviewMode": 0,
    "m_CustomColors": {
        "m_SerializableColors": []
    },
    "m_Value": {
        "x": 0.0,
        "y": 0.0,
        "z": 0.0,
        "w": 0.0
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.ColorRGBMaterialSlot",
    "m_ObjectId": "a4618ccc7ab64f598a715804f2349097",
    "m_Id": 0,
    "m_DisplayName": "Emission",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "Emission",
    "m_StageCapability": 2,
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
    "m_ColorMode": 1,
    "m_DefaultColor": {
        "r": 0.0,
        "g": 0.0,
        "b": 0.0,
        "a": 1.0
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.SaturateNode",
    "m_ObjectId": "a60e6e3d79d04cf9ac5fa0f6b0d4ffef",
    "m_Group": {
        "m_Id": "fd00382be8834040a9e03a234a798cf5"
    },
    "m_Name": "Saturate",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1498.4727783203125,
            "y": 269.6726989746094,
            "width": 130.9091796875,
            "height": 93.38180541992188
        }
    },
    "m_Slots": [
        {
            "m_Id": "f649cc4d9df542188735cc53be005805"
        },
        {
            "m_Id": "57b33f820c024ff9b926d3cd798ced82"
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
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "a69620faedd84dc08312485516f2b0f8",
    "m_Id": 4,
    "m_DisplayName": "R",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "R",
    "m_StageCapability": 2,
    "m_Value": 0.0,
    "m_DefaultValue": 0.0,
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "a905a848946840a089524d9309b9570d",
    "m_Id": 6,
    "m_DisplayName": "B",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "B",
    "m_StageCapability": 2,
    "m_Value": 0.0,
    "m_DefaultValue": 0.0,
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.NormalMaterialSlot",
    "m_ObjectId": "a90c2dc97c6f4f78b6ce0fae204341a3",
    "m_Id": 0,
    "m_DisplayName": "Normal (Tangent Space)",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "NormalTS",
    "m_StageCapability": 2,
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
    "m_Space": 3
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "acd7dea226d54b98baf647578450ddc2",
    "m_Id": 5,
    "m_DisplayName": "G",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "G",
    "m_StageCapability": 2,
    "m_Value": 0.0,
    "m_DefaultValue": 0.0,
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "aea9a7b4dc164f25b81ee97eb9e7f40f",
    "m_Id": 4,
    "m_DisplayName": "R",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "R",
    "m_StageCapability": 2,
    "m_Value": 0.0,
    "m_DefaultValue": 0.0,
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.SplitNode",
    "m_ObjectId": "b128fdcca5a64a7094c0b715bebb918b",
    "m_Group": {
        "m_Id": "7c985fb07f3644dab9661170f6578499"
    },
    "m_Name": "Split",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -459.9272766113281,
            "y": 754.9089965820313,
            "width": 122.18185424804688,
            "height": 148.36370849609376
        }
    },
    "m_Slots": [
        {
            "m_Id": "56d60ff234af4d19b9de32ce0a287207"
        },
        {
            "m_Id": "94d27173e8094ee592846781b3eb8663"
        },
        {
            "m_Id": "0f24053e80fe4f66bf9b7b8bbf0428ec"
        },
        {
            "m_Id": "fcc3ce5f53dc4876ad7a30879740310d"
        },
        {
            "m_Id": "5815349b9368469e86d14abe0f3889aa"
        }
    ],
    "synonyms": [
        "separate"
    ],
    "m_Precision": 0,
    "m_PreviewExpanded": true,
    "m_DismissedVersion": 0,
    "m_PreviewMode": 0,
    "m_CustomColors": {
        "m_SerializableColors": []
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Internal.Texture2DShaderProperty",
    "m_ObjectId": "b19a2e9544e84848bf3f4b19948a8a63",
    "m_Guid": {
        "m_GuidSerialized": "e6de0698-5b26-4050-a4b6-45e0cdcb19c1"
    },
    "m_Name": "Mask Map",
    "m_DefaultRefNameVersion": 1,
    "m_RefNameGeneratedByDisplayName": "Mask Map",
    "m_DefaultReferenceName": "_Mask_Map",
    "m_OverrideReferenceName": "_MaskMap",
    "m_GeneratePropertyBlock": true,
    "m_UseCustomSlotLabel": false,
    "m_CustomSlotLabel": "",
    "m_DismissedVersion": 0,
    "m_Precision": 0,
    "overrideHLSLDeclaration": false,
    "hlslDeclarationOverride": 0,
    "m_Hidden": false,
    "m_Value": {
        "m_SerializedTexture": "{\"texture\":{\"instanceID\":0}}",
        "m_Guid": ""
    },
    "isMainTexture": false,
    "useTilingAndOffset": false,
    "m_Modifiable": true,
    "m_DefaultType": 0
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Texture2DMaterialSlot",
    "m_ObjectId": "b23e0dcee3394774b2577dcad4c4895d",
    "m_Id": 0,
    "m_DisplayName": "Base Map",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "Out",
    "m_StageCapability": 3,
    "m_BareResource": false
}

{
    "m_SGVersion": 0,
    "m_Type": "AmazingAssets.DynamicWireframeShaderGenerator.Editor.DynamicMaskNode",
    "m_ObjectId": "b2fc7ae4954b44eeb314569a9a849f6f",
    "m_Group": {
        "m_Id": "fd00382be8834040a9e03a234a798cf5"
    },
    "m_Name": "Dynamic Mask",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1960.1455078125,
            "y": 386.6181945800781,
            "width": 223.418212890625,
            "height": 152.72726440429688
        }
    },
    "m_Slots": [
        {
            "m_Id": "f3bf1ce420e3444a9a4b4f47ebc68385"
        },
        {
            "m_Id": "fd8278725025418191ed4fcbda392e3a"
        },
        {
            "m_Id": "4a8838bf18f94291bf13f0220122f2b7"
        },
        {
            "m_Id": "ea25fe4678f54d7c8e25307964191a07"
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
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.MultiplyNode",
    "m_ObjectId": "b3cffbd67298456b992ab87b0e1b94d7",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "Multiply",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1189.5272216796875,
            "y": -72.43635559082031,
            "width": 130.0364990234375,
            "height": 116.94544982910156
        }
    },
    "m_Slots": [
        {
            "m_Id": "26957a32f030431582376646e9cb1432"
        },
        {
            "m_Id": "77873a82123e4f8abae6df157a879061"
        },
        {
            "m_Id": "b6e4340241ac4472881b5040d25319e8"
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "b6e4340241ac4472881b5040d25319e8",
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
    "m_Type": "UnityEditor.ShaderGraph.Vector4MaterialSlot",
    "m_ObjectId": "b839bbe1063c4af095b9b47cd43d4382",
    "m_Id": 0,
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
    },
    "m_Labels": []
}

{
    "m_SGVersion": 1,
    "m_Type": "UnityEditor.ShaderGraph.Internal.Vector1ShaderProperty",
    "m_ObjectId": "b8c204dc160d43a298e621c8c920af8a",
    "m_Guid": {
        "m_GuidSerialized": "1f497d41-382d-4eab-8693-3447fb36846b"
    },
    "m_Name": "Occlusion",
    "m_DefaultRefNameVersion": 1,
    "m_RefNameGeneratedByDisplayName": "Occlusion",
    "m_DefaultReferenceName": "_Occlusion",
    "m_OverrideReferenceName": "",
    "m_GeneratePropertyBlock": true,
    "m_UseCustomSlotLabel": false,
    "m_CustomSlotLabel": "",
    "m_DismissedVersion": 0,
    "m_Precision": 0,
    "overrideHLSLDeclaration": false,
    "hlslDeclarationOverride": 0,
    "m_Hidden": false,
    "m_Value": 1.0,
    "m_FloatType": 1,
    "m_RangeValues": {
        "x": 0.0,
        "y": 1.0
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "bd9b2f0fdf8a46609ad114a3d4424f6e",
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
    "m_Type": "UnityEditor.ShaderGraph.Vector4MaterialSlot",
    "m_ObjectId": "bf6f3ff1225d4870bbfb73bc9dfabe0f",
    "m_Id": 0,
    "m_DisplayName": "RGBA",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "RGBA",
    "m_StageCapability": 2,
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "ca247d8cd8764a8cb6f6680420c9f121",
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
    "m_Type": "UnityEditor.ShaderGraph.BlockNode",
    "m_ObjectId": "cf8b9bf5cc9549f59bd6dc9554d3596f",
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
            "m_Id": "6472603213a6485dabd0e1543aa5c51e"
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
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "cf90db5e5c5147b38fe0082241ecb138",
    "m_Id": 0,
    "m_DisplayName": "Ambient Occlusion",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "Occlusion",
    "m_StageCapability": 2,
    "m_Value": 1.0,
    "m_DefaultValue": 1.0,
    "m_Labels": []
}

{
    "m_SGVersion": 3,
    "m_Type": "UnityEditor.ShaderGraph.Internal.ColorShaderProperty",
    "m_ObjectId": "d3b158c4672e4988b5b4ac8180ab6742",
    "m_Guid": {
        "m_GuidSerialized": "260623d9-763f-4ecc-9f0f-fb0a88542331"
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
    "m_Type": "UnityEditor.ShaderGraph.AddNode",
    "m_ObjectId": "d570aea5942649aba75f7914130198d9",
    "m_Group": {
        "m_Id": "fd00382be8834040a9e03a234a798cf5"
    },
    "m_Name": "Add",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1666.9090576171875,
            "y": 269.6726989746094,
            "width": 129.1636962890625,
            "height": 116.94546508789063
        }
    },
    "m_Slots": [
        {
            "m_Id": "bd9b2f0fdf8a46609ad114a3d4424f6e"
        },
        {
            "m_Id": "7a527715caa84f229a4811a4855257a8"
        },
        {
            "m_Id": "9ad065ea94a94af899861e015730488b"
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
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "d81c992093df4cad9bc68c6388612795",
    "m_Id": 5,
    "m_DisplayName": "G",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "G",
    "m_StageCapability": 2,
    "m_Value": 0.0,
    "m_DefaultValue": 0.0,
    "m_Labels": []
}

{
    "m_SGVersion": 1,
    "m_Type": "UnityEditor.ShaderGraph.Internal.Vector1ShaderProperty",
    "m_ObjectId": "da1822c6f5a44b2ab54c0ee0111a7ac1",
    "m_Guid": {
        "m_GuidSerialized": "79d77d40-04e8-45a2-9898-c572ee4b2266"
    },
    "m_Name": "Metallic",
    "m_DefaultRefNameVersion": 1,
    "m_RefNameGeneratedByDisplayName": "Metallic",
    "m_DefaultReferenceName": "_Metallic",
    "m_OverrideReferenceName": "",
    "m_GeneratePropertyBlock": true,
    "m_UseCustomSlotLabel": false,
    "m_CustomSlotLabel": "",
    "m_DismissedVersion": 0,
    "m_Precision": 0,
    "overrideHLSLDeclaration": false,
    "hlslDeclarationOverride": 0,
    "m_Hidden": false,
    "m_Value": 0.0,
    "m_FloatType": 1,
    "m_RangeValues": {
        "x": 0.0,
        "y": 1.0
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector2MaterialSlot",
    "m_ObjectId": "db930cf370314af3889180e70c010c7a",
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
    "m_Type": "UnityEditor.ShaderGraph.Matrix4MaterialSlot",
    "m_ObjectId": "dbce00f16cc4493a91de6589becf3708",
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
    "m_Type": "UnityEditor.ShaderGraph.CategoryData",
    "m_ObjectId": "dd6fcdf0141b461d9ce07ca51467b3c4",
    "m_Name": "",
    "m_ChildObjectList": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.Rendering.HighDefinition.ShaderGraph.HDLitSubTarget",
    "m_ObjectId": "e4335c2878f04db5af0adb530304d760"
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector4MaterialSlot",
    "m_ObjectId": "e4dbc20d90f64f6881ac9c776f01d9c9",
    "m_Id": 0,
    "m_DisplayName": "RGBA",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "RGBA",
    "m_StageCapability": 2,
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
    "m_Type": "AmazingAssets.DynamicWireframeShaderGenerator.Editor.DynamicMaskNode",
    "m_ObjectId": "e6689341c7c04c1bb33ed3b487300049",
    "m_Group": {
        "m_Id": "fd00382be8834040a9e03a234a798cf5"
    },
    "m_Name": "Dynamic Mask",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1960.1455078125,
            "y": 171.92730712890626,
            "width": 223.418212890625,
            "height": 152.72723388671876
        }
    },
    "m_Slots": [
        {
            "m_Id": "4919ca3e26c141c6ac3832a260d4977a"
        },
        {
            "m_Id": "89f766f41e574232a7e8a5b785d5f439"
        },
        {
            "m_Id": "ecf4b973879b4233a28dedead48647bc"
        },
        {
            "m_Id": "608b1d4e1c614e99ad3b8666f8da5a58"
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
    "m_ObjectId": "e736e9327527475591515cc473446022",
    "m_Group": {
        "m_Id": "7c985fb07f3644dab9661170f6578499"
    },
    "m_Name": "Property",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1020.2182006835938,
            "y": 949.5272216796875,
            "width": 141.38189697265626,
            "height": 33.16357421875
        }
    },
    "m_Slots": [
        {
            "m_Id": "0962ebb6d48d4546b64ea5f5c4b8683c"
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
        "m_Id": "84c0b020a2ac444aa5f6fb7f18c449f2"
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.MultiplyNode",
    "m_ObjectId": "e8ba8aacd2e94a59973b09180d2b3ffe",
    "m_Group": {
        "m_Id": "7c985fb07f3644dab9661170f6578499"
    },
    "m_Name": "Multiply",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -592.5818481445313,
            "y": 754.9089965820313,
            "width": 132.65457153320313,
            "height": 117.8182373046875
        }
    },
    "m_Slots": [
        {
            "m_Id": "497954928cb343c086ba15f3b58a24e3"
        },
        {
            "m_Id": "ca247d8cd8764a8cb6f6680420c9f121"
        },
        {
            "m_Id": "7586e2d229e545a39a68109a65146412"
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
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "ea25fe4678f54d7c8e25307964191a07",
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
    "m_ObjectId": "ecb92ce6f8c544d1807a496ea75d25ed",
    "m_Id": 7,
    "m_DisplayName": "A",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "A",
    "m_StageCapability": 2,
    "m_Value": 0.0,
    "m_DefaultValue": 0.0,
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "ecf4b973879b4233a28dedead48647bc",
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
    "m_Type": "UnityEditor.ShaderGraph.SampleTexture2DNode",
    "m_ObjectId": "ee1c94e2e7134f96b17bbdca87acc73f",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "Sample Texture 2D",
    "m_DrawState": {
        "m_Expanded": false,
        "m_Position": {
            "serializedVersion": "2",
            "x": -474.7635803222656,
            "y": 274.9090881347656,
            "width": 184.1453857421875,
            "height": 155.34539794921876
        }
    },
    "m_Slots": [
        {
            "m_Id": "bf6f3ff1225d4870bbfb73bc9dfabe0f"
        },
        {
            "m_Id": "8f187c9977144dd5afbc1df93e431777"
        },
        {
            "m_Id": "fa619300539e43e1837b04d87209c3fa"
        },
        {
            "m_Id": "741eed2052ba4bfd9c8df46ae7c58142"
        },
        {
            "m_Id": "f30a928f391747679f7a001b289a1298"
        },
        {
            "m_Id": "ef5b940bff4a47b7997bfa675047c85b"
        },
        {
            "m_Id": "1b8e5acbb2ca49a791df91d6ae58e85e"
        },
        {
            "m_Id": "9809dc607ba44223bf310719ac9cf814"
        }
    ],
    "synonyms": [
        "tex2d"
    ],
    "m_Precision": 0,
    "m_PreviewExpanded": false,
    "m_DismissedVersion": 0,
    "m_PreviewMode": 0,
    "m_CustomColors": {
        "m_SerializableColors": []
    },
    "m_TextureType": 1,
    "m_NormalMapSpace": 0,
    "m_EnableGlobalMipBias": true,
    "m_MipSamplingMode": 0
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Texture2DInputMaterialSlot",
    "m_ObjectId": "ef5b940bff4a47b7997bfa675047c85b",
    "m_Id": 1,
    "m_DisplayName": "Texture",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "Texture",
    "m_StageCapability": 3,
    "m_BareResource": false,
    "m_Texture": {
        "m_SerializedTexture": "{\"texture\":{\"instanceID\":0}}",
        "m_Guid": ""
    },
    "m_DefaultType": 3
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
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.BlockNode",
    "m_ObjectId": "f1a6a40111e048918c477da6c320139d",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "SurfaceDescription.Metallic",
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
            "m_Id": "01b724267af44d95933f7d4b5d035fde"
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
    "m_SerializedDescriptor": "SurfaceDescription.Metallic"
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "f30a928f391747679f7a001b289a1298",
    "m_Id": 7,
    "m_DisplayName": "A",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "A",
    "m_StageCapability": 2,
    "m_Value": 0.0,
    "m_DefaultValue": 0.0,
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.PositionMaterialSlot",
    "m_ObjectId": "f3bf1ce420e3444a9a4b4f47ebc68385",
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
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "f480a3129542455094b2ad0f977e3eb7",
    "m_Id": 2,
    "m_DisplayName": "Y",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "Y",
    "m_StageCapability": 3,
    "m_Value": 0.0,
    "m_DefaultValue": 0.0,
    "m_Labels": [
        "Y"
    ]
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "f649cc4d9df542188735cc53be005805",
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "f74bff52633948b68a4c46e16aac0d77",
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
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "fa619300539e43e1837b04d87209c3fa",
    "m_Id": 5,
    "m_DisplayName": "G",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "G",
    "m_StageCapability": 2,
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

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "fcc3ce5f53dc4876ad7a30879740310d",
    "m_Id": 3,
    "m_DisplayName": "B",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "B",
    "m_StageCapability": 3,
    "m_Value": 0.0,
    "m_DefaultValue": 0.0,
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.GroupData",
    "m_ObjectId": "fd00382be8834040a9e03a234a798cf5",
    "m_Title": "Dynamic Masks",
    "m_Position": {
        "x": -2324.945556640625,
        "y": 114.3272705078125
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Matrix4MaterialSlot",
    "m_ObjectId": "fd8278725025418191ed4fcbda392e3a",
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
    "m_Type": "UnityEditor.ShaderGraph.PropertyNode",
    "m_ObjectId": "fea879b3f3324ecb9cb1e0f2f9890529",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "Property",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -738.3273315429688,
            "y": -58.472740173339847,
            "width": 164.07281494140626,
            "height": 32.29090881347656
        }
    },
    "m_Slots": [
        {
            "m_Id": "832b4d561e7b4790a49ddd757bb8e068"
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
        "m_Id": "d3b158c4672e4988b5b4ac8180ab6742"
    }
}


ShaderGraphBody_End*/

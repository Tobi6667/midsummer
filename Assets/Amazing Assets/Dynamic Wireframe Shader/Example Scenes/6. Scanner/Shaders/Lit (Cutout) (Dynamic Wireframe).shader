// Dynamic Wireframe Shader <https://u3d.as/3WyY>
// Copyright (c) Amazing Assets <https://amazingassets.world>

Shader "Amazing Assets/Dynamic Wireframe Shader/Examples/Scanner/Lit (Cutout) (Dynamic Wireframe)"
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
_Scanner_Glow_Color("Scanner Glow Color", Color) = (0, 0, 0, 1)
_Scanner_Glow_Emission("Scanner Glow Emission", Float) = 1
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
"Queue"="AlphaTest"
"DisableBatching"="False"
"ShaderGraphShader"="true"
"ShaderGraphTargetId"="UniversalLitSubTarget"
}
Pass
{
    Name "ForwardLit"
    Tags
    {
        "LightMode" = "UniversalForward"
    }

// Render State
Cull Back
Blend One Zero
ZTest LEqual
ZWrite On
AlphaToMask On

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
#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
#pragma multi_compile_fragment _ _SCREEN_SPACE_IRRADIANCE
#pragma multi_compile _ LIGHTMAP_ON
#pragma multi_compile _ DYNAMICLIGHTMAP_ON
#pragma multi_compile _ DIRLIGHTMAP_COMBINED
#pragma multi_compile _ USE_LEGACY_LIGHTMAPS
#pragma multi_compile _ LIGHTMAP_BICUBIC_SAMPLING
#pragma multi_compile _ REFLECTION_PROBE_ROTATION
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
#pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
#pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
#pragma multi_compile_fragment _ _REFLECTION_PROBE_ATLAS
#pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
#pragma multi_compile _ SHADOWS_SHADOWMASK
#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
#pragma multi_compile_fragment _ _LIGHT_LAYERS
#pragma multi_compile_fragment _ DEBUG_DISPLAY
#pragma multi_compile_fragment _ _LIGHT_COOKIES
#pragma multi_compile _ _CLUSTER_LIGHT_LOOP
#pragma multi_compile _ EVALUATE_SH_MIXED EVALUATE_SH_VERTEX
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
#define ATTRIBUTES_NEED_TEXCOORD4
#define ATTRIBUTES_NEED_TEXCOORD5
#define ATTRIBUTES_NEED_TEXCOORD6
#define ATTRIBUTES_NEED_TEXCOORD7
#define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
#define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define VARYINGS_NEED_TANGENT_WS
#define VARYINGS_NEED_TEXCOORD0
#define VARYINGS_NEED_TEXCOORD1
#define VARYINGS_NEED_TEXCOORD2
#define VARYINGS_NEED_TEXCOORD3
#define VARYINGS_NEED_TEXCOORD4
#define VARYINGS_NEED_TEXCOORD5
#define VARYINGS_NEED_TEXCOORD6
#define VARYINGS_NEED_TEXCOORD7
#define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
#define VARYINGS_NEED_SHADOW_COORD
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_FORWARD
#define _ALPHATEST_ON 1


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Fog.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
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
 float4 tangentWS;
 float4 texCoord0;
 float4 texCoord1;
 float4 texCoord2;
 float4 texCoord3;
 float4 texCoord4;
 float4 texCoord5;
 float4 texCoord6;
 float4 texCoord7;
#if defined(LIGHTMAP_ON)
 float2 staticLightmapUV;
#endif
#if defined(DYNAMICLIGHTMAP_ON)
 float2 dynamicLightmapUV;
#endif
#if !defined(LIGHTMAP_ON)
 float3 sh;
#endif
#if defined(USE_APV_PROBE_OCCLUSION)
 float4 probeOcclusion;
#endif
 float4 fogFactorAndVertexLight;
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
 float4 shadowCoord;
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
};
struct SurfaceDescriptionInputs
{
 float3 TangentSpaceNormal;
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
#if defined(LIGHTMAP_ON)
 float2 staticLightmapUV : INTERP0;
#endif
#if defined(DYNAMICLIGHTMAP_ON)
 float2 dynamicLightmapUV : INTERP1;
#endif
#if !defined(LIGHTMAP_ON)
 float3 sh : INTERP2;
#endif
#if defined(USE_APV_PROBE_OCCLUSION)
 float4 probeOcclusion : INTERP3;
#endif
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
 float4 shadowCoord : INTERP4;
#endif
 float4 tangentWS : INTERP5;
 float4 texCoord0 : INTERP6;
 float4 texCoord1 : INTERP7;
 float4 texCoord2 : INTERP8;
 float4 texCoord3 : INTERP9;
 float4 texCoord4 : INTERP10;
 float4 texCoord5 : INTERP11;
 float4 texCoord6 : INTERP12;
 float4 texCoord7 : INTERP13;
 float4 fogFactorAndVertexLight : INTERP14;
 float3 positionWS : INTERP15;
 float3 normalWS : INTERP16;
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
#if defined(LIGHTMAP_ON)
output.staticLightmapUV = input.staticLightmapUV;
#endif
#if defined(DYNAMICLIGHTMAP_ON)
output.dynamicLightmapUV = input.dynamicLightmapUV;
#endif
#if !defined(LIGHTMAP_ON)
output.sh = input.sh;
#endif
#if defined(USE_APV_PROBE_OCCLUSION)
output.probeOcclusion = input.probeOcclusion;
#endif
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
output.shadowCoord = input.shadowCoord;
#endif
output.tangentWS.xyzw = input.tangentWS;
output.texCoord0.xyzw = input.texCoord0;
output.texCoord1.xyzw = input.texCoord1;
output.texCoord2.xyzw = input.texCoord2;
output.texCoord3.xyzw = input.texCoord3;
output.texCoord4.xyzw = input.texCoord4;
output.texCoord5.xyzw = input.texCoord5;
output.texCoord6.xyzw = input.texCoord6;
output.texCoord7.xyzw = input.texCoord7;
output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
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
#if defined(LIGHTMAP_ON)
output.staticLightmapUV = input.staticLightmapUV;
#endif
#if defined(DYNAMICLIGHTMAP_ON)
output.dynamicLightmapUV = input.dynamicLightmapUV;
#endif
#if !defined(LIGHTMAP_ON)
output.sh = input.sh;
#endif
#if defined(USE_APV_PROBE_OCCLUSION)
output.probeOcclusion = input.probeOcclusion;
#endif
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
output.shadowCoord = input.shadowCoord;
#endif
output.tangentWS = input.tangentWS.xyzw;
output.texCoord0 = input.texCoord0.xyzw;
output.texCoord1 = input.texCoord1.xyzw;
output.texCoord2 = input.texCoord2.xyzw;
output.texCoord3 = input.texCoord3.xyzw;
output.texCoord4 = input.texCoord4.xyzw;
output.texCoord5 = input.texCoord5.xyzw;
output.texCoord6 = input.texCoord6.xyzw;
output.texCoord7 = input.texCoord7.xyzw;
output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
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
float4x4 _WireframeShaderMaskData;
float4 _BaseColorMap_TexelSize;
float4 _Scanner_Glow_Color;
float _Smoothness;
float _Occlusion;
float _Metallic;
float4 _NormalMap_TexelSize;
float4 _MaskMap_TexelSize;
float _Wireframe_Thickness;
float4 _Wireframe_Color;
float _Wireframe_Anti_aliasing;
float _Scanner_Glow_Emission;
UNITY_TEXTURE_STREAMING_DEBUG_VARS;
CBUFFER_END


// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_BaseColorMap);
SAMPLER(sampler_BaseColorMap);
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

void WireframeShaderDynamicMaskPlane_float(float3 vertexPositionWS, float4x4 ShaderData, float Noise, out float Out)
{
            float3 planePosition = ShaderData[0].xyz;
        	float3 planeNormal   = ShaderData[1].xyz;
        	float fallOff        = ShaderData[3].x;
        	float intensity      = ShaderData[3].y;


            vertexPositionWS = GetAbsolutePositionWS(vertexPositionWS);
        	float mask = dot(planeNormal, (vertexPositionWS - planePosition)) - Noise;

            Out = saturate(mask / fallOff) * intensity;
        }

void Unity_Multiply_float_float(float A, float B, out float Out)
{
Out = A * B;
}

void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
{
    Out = lerp(A, B, T);
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
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
float Alpha;
float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
UnityTexture2D _Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D = UnityBuildTexture2DStructInternal(_BaseColorMap, sampler_BaseColorMap, _BaseColorMap_TexelSize, float4(1, 1, 0, 0), float4(0, 0, 0, 0));
float4 _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D.tex, _Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D.samplerstate, _Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
if (_Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D.hdrDecode.x > 0)
_SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4 = DecodeHDRSample(_SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4, _Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D.hdrDecode);
float _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_R_4_Float = _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4.r;
float _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_G_5_Float = _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4.g;
float _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_B_6_Float = _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4.b;
float _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_A_7_Float = _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4.a;
float4 _Property_fea879b3f3324ecb9cb1e0f2f9890529_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Wireframe_Color) : _Wireframe_Color;
float _Property_1dc4788b9eca4069baa399efa4413298_Out_0_Float = _Wireframe_Thickness;
float _Property_8b57c7d9cbef4037966ba71e85a6a06c_Out_0_Float = _Wireframe_Anti_aliasing;
float _WireframeRenderer_7094b2718889469d8b1d2d7e9831bf6a_Wireframe_3_Float;
float2 _WireframeRenderer_7094b2718889469d8b1d2d7e9831bf6a_BarycentricUV_4_Vector2;
WireframeRenderer_float(IN.uv3.xyz, max(0, _Property_1dc4788b9eca4069baa399efa4413298_Out_0_Float), max(0, _Property_8b57c7d9cbef4037966ba71e85a6a06c_Out_0_Float), 0, _WireframeRenderer_7094b2718889469d8b1d2d7e9831bf6a_Wireframe_3_Float, _WireframeRenderer_7094b2718889469d8b1d2d7e9831bf6a_BarycentricUV_4_Vector2);
float4x4 _Property_c2fcbed1c8b9408fb9e6665d295dd052_Out_0_Matrix4 = _WireframeShaderMaskData;
float _DynamicMask_32111ad8088744399d405eb222eab7ea_Out_3_Float;
WireframeShaderDynamicMaskPlane_float(IN.WorldSpacePosition, _Property_c2fcbed1c8b9408fb9e6665d295dd052_Out_0_Matrix4, float(0), _DynamicMask_32111ad8088744399d405eb222eab7ea_Out_3_Float);
float _Multiply_b0960d3afcdd41aca8cb2c6f7dc0bb74_Out_2_Float;
Unity_Multiply_float_float(_WireframeRenderer_7094b2718889469d8b1d2d7e9831bf6a_Wireframe_3_Float, _DynamicMask_32111ad8088744399d405eb222eab7ea_Out_3_Float, _Multiply_b0960d3afcdd41aca8cb2c6f7dc0bb74_Out_2_Float);
float4 _Lerp_130fe097f09542d1b7fa52dfa8fd1871_Out_3_Vector4;
Unity_Lerp_float4(_SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4, _Property_fea879b3f3324ecb9cb1e0f2f9890529_Out_0_Vector4, (_Multiply_b0960d3afcdd41aca8cb2c6f7dc0bb74_Out_2_Float.xxxx), _Lerp_130fe097f09542d1b7fa52dfa8fd1871_Out_3_Vector4);
UnityTexture2D _Property_354f04f299e94eb3aeb99dea1d1e9cb2_Out_0_Texture2D = UnityBuildTexture2DStructInternal(_NormalMap, sampler_NormalMap, _NormalMap_TexelSize, float4(1, 1, 0, 0), float4(0, 0, 0, 0));
float4 _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_354f04f299e94eb3aeb99dea1d1e9cb2_Out_0_Texture2D.tex, _Property_354f04f299e94eb3aeb99dea1d1e9cb2_Out_0_Texture2D.samplerstate, _Property_354f04f299e94eb3aeb99dea1d1e9cb2_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
if (_Property_354f04f299e94eb3aeb99dea1d1e9cb2_Out_0_Texture2D.hdrDecode.x > 0)
_SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4 = DecodeHDRSample(_SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4, _Property_354f04f299e94eb3aeb99dea1d1e9cb2_Out_0_Texture2D.hdrDecode);
_SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4);
float _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_R_4_Float = _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4.r;
float _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_G_5_Float = _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4.g;
float _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_B_6_Float = _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4.b;
float _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_A_7_Float = _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4.a;
float4 _Property_bdb9446ca60e4334aaf2d68ef022f6df_Out_0_Vector4 = _Scanner_Glow_Color;
float _Property_786bc74c310d4091adde84ab0c1d72d6_Out_0_Float = _Scanner_Glow_Emission;
float _Multiply_40c4e74cfa634e1ca24c7bafe634a7c6_Out_2_Float;
Unity_Multiply_float_float(_Property_786bc74c310d4091adde84ab0c1d72d6_Out_0_Float, _Property_786bc74c310d4091adde84ab0c1d72d6_Out_0_Float, _Multiply_40c4e74cfa634e1ca24c7bafe634a7c6_Out_2_Float);
float _OneMinus_a4821fb7622e45819daa3b83ed31f32f_Out_1_Float;
Unity_OneMinus_float(_DynamicMask_32111ad8088744399d405eb222eab7ea_Out_3_Float, _OneMinus_a4821fb7622e45819daa3b83ed31f32f_Out_1_Float);
float _Multiply_55da36dd653c4a869854dc914d0c0772_Out_2_Float;
Unity_Multiply_float_float(_DynamicMask_32111ad8088744399d405eb222eab7ea_Out_3_Float, _OneMinus_a4821fb7622e45819daa3b83ed31f32f_Out_1_Float, _Multiply_55da36dd653c4a869854dc914d0c0772_Out_2_Float);
float _Multiply_a98dec7346c143bca3285adc673e52bd_Out_2_Float;
Unity_Multiply_float_float(_Multiply_55da36dd653c4a869854dc914d0c0772_Out_2_Float, _Multiply_55da36dd653c4a869854dc914d0c0772_Out_2_Float, _Multiply_a98dec7346c143bca3285adc673e52bd_Out_2_Float);
float _Multiply_6cfe4d8447ff49c99dd292fb734bd70c_Out_2_Float;
Unity_Multiply_float_float(_Multiply_40c4e74cfa634e1ca24c7bafe634a7c6_Out_2_Float, _Multiply_a98dec7346c143bca3285adc673e52bd_Out_2_Float, _Multiply_6cfe4d8447ff49c99dd292fb734bd70c_Out_2_Float);
float4 _Multiply_4382fbf7eea741d8ac9db946ef8e8f35_Out_2_Vector4;
Unity_Multiply_float4_float4(_Property_bdb9446ca60e4334aaf2d68ef022f6df_Out_0_Vector4, (_Multiply_6cfe4d8447ff49c99dd292fb734bd70c_Out_2_Float.xxxx), _Multiply_4382fbf7eea741d8ac9db946ef8e8f35_Out_2_Vector4);
float4 _Property_f8bc404cb1f0474081562f509e25130e_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Wireframe_Color) : _Wireframe_Color;
float4 _Lerp_673aa80ed8444024935140cccdff3aea_Out_3_Vector4;
Unity_Lerp_float4(_Multiply_4382fbf7eea741d8ac9db946ef8e8f35_Out_2_Vector4, _Property_f8bc404cb1f0474081562f509e25130e_Out_0_Vector4, (_Multiply_b0960d3afcdd41aca8cb2c6f7dc0bb74_Out_2_Float.xxxx), _Lerp_673aa80ed8444024935140cccdff3aea_Out_3_Vector4);
UnityTexture2D _Property_34cf830a0a7943f0a3dd904707c6cd50_Out_0_Texture2D = UnityBuildTexture2DStructInternal(_MaskMap, sampler_MaskMap, _MaskMap_TexelSize, float4(1, 1, 0, 0), float4(0, 0, 0, 0));
float4 _SampleTexture2D_5cb5ecb8bbac4b90b42465076353d1b3_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_34cf830a0a7943f0a3dd904707c6cd50_Out_0_Texture2D.tex, _Property_34cf830a0a7943f0a3dd904707c6cd50_Out_0_Texture2D.samplerstate, _Property_34cf830a0a7943f0a3dd904707c6cd50_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
if (_Property_34cf830a0a7943f0a3dd904707c6cd50_Out_0_Texture2D.hdrDecode.x > 0)
_SampleTexture2D_5cb5ecb8bbac4b90b42465076353d1b3_RGBA_0_Vector4 = DecodeHDRSample(_SampleTexture2D_5cb5ecb8bbac4b90b42465076353d1b3_RGBA_0_Vector4, _Property_34cf830a0a7943f0a3dd904707c6cd50_Out_0_Texture2D.hdrDecode);
float _SampleTexture2D_5cb5ecb8bbac4b90b42465076353d1b3_R_4_Float = _SampleTexture2D_5cb5ecb8bbac4b90b42465076353d1b3_RGBA_0_Vector4.r;
float _SampleTexture2D_5cb5ecb8bbac4b90b42465076353d1b3_G_5_Float = _SampleTexture2D_5cb5ecb8bbac4b90b42465076353d1b3_RGBA_0_Vector4.g;
float _SampleTexture2D_5cb5ecb8bbac4b90b42465076353d1b3_B_6_Float = _SampleTexture2D_5cb5ecb8bbac4b90b42465076353d1b3_RGBA_0_Vector4.b;
float _SampleTexture2D_5cb5ecb8bbac4b90b42465076353d1b3_A_7_Float = _SampleTexture2D_5cb5ecb8bbac4b90b42465076353d1b3_RGBA_0_Vector4.a;
float _Property_83bfc61641084bffa14d057e840bc1a4_Out_0_Float = _Metallic;
float _Property_49afa605221947c696ffbfac306a7f5b_Out_0_Float = _Occlusion;
float _Property_a3b68a3e755144ee84377e58075facb1_Out_0_Float = _Smoothness;
float4 _Vector4_2e0a384889c84b3fabad9cd4921487d7_Out_0_Vector4 = float4(_Property_83bfc61641084bffa14d057e840bc1a4_Out_0_Float, _Property_49afa605221947c696ffbfac306a7f5b_Out_0_Float, float(0), _Property_a3b68a3e755144ee84377e58075facb1_Out_0_Float);
float4 _Multiply_20b8071b3402402db6c81e272e22d5f5_Out_2_Vector4;
Unity_Multiply_float4_float4(_SampleTexture2D_5cb5ecb8bbac4b90b42465076353d1b3_RGBA_0_Vector4, _Vector4_2e0a384889c84b3fabad9cd4921487d7_Out_0_Vector4, _Multiply_20b8071b3402402db6c81e272e22d5f5_Out_2_Vector4);
float _Split_0334e1ac8bdd4cafa3404d8fc87d253c_R_1_Float = _Multiply_20b8071b3402402db6c81e272e22d5f5_Out_2_Vector4[0];
float _Split_0334e1ac8bdd4cafa3404d8fc87d253c_G_2_Float = _Multiply_20b8071b3402402db6c81e272e22d5f5_Out_2_Vector4[1];
float _Split_0334e1ac8bdd4cafa3404d8fc87d253c_B_3_Float = _Multiply_20b8071b3402402db6c81e272e22d5f5_Out_2_Vector4[2];
float _Split_0334e1ac8bdd4cafa3404d8fc87d253c_A_4_Float = _Multiply_20b8071b3402402db6c81e272e22d5f5_Out_2_Vector4[3];
surface.BaseColor = (_Lerp_130fe097f09542d1b7fa52dfa8fd1871_Out_3_Vector4.xyz);
surface.NormalTS = (_SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4.xyz);
surface.Emission = (_Lerp_673aa80ed8444024935140cccdff3aea_Out_3_Vector4.xyz);
surface.Metallic = _Split_0334e1ac8bdd4cafa3404d8fc87d253c_R_1_Float;
surface.Smoothness = _Split_0334e1ac8bdd4cafa3404d8fc87d253c_A_4_Float;
surface.Occlusion = _Split_0334e1ac8bdd4cafa3404d8fc87d253c_G_2_Float;
surface.Alpha = _DynamicMask_32111ad8088744399d405eb222eab7ea_Out_3_Float;
surface.AlphaClipThreshold = float(0.01);
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

    



    output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


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
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

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
#pragma multi_compile_fragment _ _SCREEN_SPACE_IRRADIANCE
#pragma multi_compile _ LIGHTMAP_ON
#pragma multi_compile _ DYNAMICLIGHTMAP_ON
#pragma multi_compile _ DIRLIGHTMAP_COMBINED
#pragma multi_compile _ USE_LEGACY_LIGHTMAPS
#pragma multi_compile _ LIGHTMAP_BICUBIC_SAMPLING
#pragma multi_compile _ REFLECTION_PROBE_ROTATION
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
#pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
#pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
#pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
#pragma multi_compile _ SHADOWS_SHADOWMASK
#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
#pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
#pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
#pragma multi_compile_fragment _ DEBUG_DISPLAY
#pragma multi_compile _ _CLUSTER_LIGHT_LOOP
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
#define ATTRIBUTES_NEED_TEXCOORD4
#define ATTRIBUTES_NEED_TEXCOORD5
#define ATTRIBUTES_NEED_TEXCOORD6
#define ATTRIBUTES_NEED_TEXCOORD7
#define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
#define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define VARYINGS_NEED_TANGENT_WS
#define VARYINGS_NEED_TEXCOORD0
#define VARYINGS_NEED_TEXCOORD1
#define VARYINGS_NEED_TEXCOORD2
#define VARYINGS_NEED_TEXCOORD3
#define VARYINGS_NEED_TEXCOORD4
#define VARYINGS_NEED_TEXCOORD5
#define VARYINGS_NEED_TEXCOORD6
#define VARYINGS_NEED_TEXCOORD7
#define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
#define VARYINGS_NEED_SHADOW_COORD
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_GBUFFER
#define _FOG_FRAGMENT 1
#define _ALPHATEST_ON 1


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Fog.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
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
 float4 tangentWS;
 float4 texCoord0;
 float4 texCoord1;
 float4 texCoord2;
 float4 texCoord3;
 float4 texCoord4;
 float4 texCoord5;
 float4 texCoord6;
 float4 texCoord7;
#if defined(LIGHTMAP_ON)
 float2 staticLightmapUV;
#endif
#if defined(DYNAMICLIGHTMAP_ON)
 float2 dynamicLightmapUV;
#endif
#if !defined(LIGHTMAP_ON)
 float3 sh;
#endif
#if defined(USE_APV_PROBE_OCCLUSION)
 float4 probeOcclusion;
#endif
 float4 fogFactorAndVertexLight;
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
 float4 shadowCoord;
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
 float3 TangentSpaceNormal;
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
float3 barycentric : INTERP17;
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
#if defined(USE_APV_PROBE_OCCLUSION)
 float4 probeOcclusion : INTERP3;
#endif
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
 float4 shadowCoord : INTERP4;
#endif
 float4 tangentWS : INTERP5;
 float4 texCoord0 : INTERP6;
 float4 texCoord1 : INTERP7;
 float4 texCoord2 : INTERP8;
 float4 texCoord3 : INTERP9;
 float4 texCoord4 : INTERP10;
 float4 texCoord5 : INTERP11;
 float4 texCoord6 : INTERP12;
 float4 texCoord7 : INTERP13;
 float4 fogFactorAndVertexLight : INTERP14;
 float3 positionWS : INTERP15;
 float3 normalWS : INTERP16;
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
#if defined(LIGHTMAP_ON)
output.staticLightmapUV = input.staticLightmapUV;
#endif
#if defined(DYNAMICLIGHTMAP_ON)
output.dynamicLightmapUV = input.dynamicLightmapUV;
#endif
#if !defined(LIGHTMAP_ON)
output.sh = input.sh;
#endif
#if defined(USE_APV_PROBE_OCCLUSION)
output.probeOcclusion = input.probeOcclusion;
#endif
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
output.shadowCoord = input.shadowCoord;
#endif
output.tangentWS.xyzw = input.tangentWS;
output.texCoord0.xyzw = input.texCoord0;
output.texCoord1.xyzw = input.texCoord1;
output.texCoord2.xyzw = input.texCoord2;
output.texCoord3.xyzw = input.texCoord3;
output.texCoord4.xyzw = input.texCoord4;
output.texCoord5.xyzw = input.texCoord5;
output.texCoord6.xyzw = input.texCoord6;
output.texCoord7.xyzw = input.texCoord7;
output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
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
#if defined(LIGHTMAP_ON)
output.staticLightmapUV = input.staticLightmapUV;
#endif
#if defined(DYNAMICLIGHTMAP_ON)
output.dynamicLightmapUV = input.dynamicLightmapUV;
#endif
#if !defined(LIGHTMAP_ON)
output.sh = input.sh;
#endif
#if defined(USE_APV_PROBE_OCCLUSION)
output.probeOcclusion = input.probeOcclusion;
#endif
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
output.shadowCoord = input.shadowCoord;
#endif
output.tangentWS = input.tangentWS.xyzw;
output.texCoord0 = input.texCoord0.xyzw;
output.texCoord1 = input.texCoord1.xyzw;
output.texCoord2 = input.texCoord2.xyzw;
output.texCoord3 = input.texCoord3.xyzw;
output.texCoord4 = input.texCoord4.xyzw;
output.texCoord5 = input.texCoord5.xyzw;
output.texCoord6 = input.texCoord6.xyzw;
output.texCoord7 = input.texCoord7.xyzw;
output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
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
float4x4 _WireframeShaderMaskData;
float4 _BaseColorMap_TexelSize;
float4 _Scanner_Glow_Color;
float _Smoothness;
float _Occlusion;
float _Metallic;
float4 _NormalMap_TexelSize;
float4 _MaskMap_TexelSize;
float _Wireframe_Thickness;
float4 _Wireframe_Color;
float _Wireframe_Anti_aliasing;
float _Scanner_Glow_Emission;
UNITY_TEXTURE_STREAMING_DEBUG_VARS;
CBUFFER_END


// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_BaseColorMap);
SAMPLER(sampler_BaseColorMap);
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

void WireframeShaderDynamicMaskPlane_float(float3 vertexPositionWS, float4x4 ShaderData, float Noise, out float Out)
{
            float3 planePosition = ShaderData[0].xyz;
        	float3 planeNormal   = ShaderData[1].xyz;
        	float fallOff        = ShaderData[3].x;
        	float intensity      = ShaderData[3].y;


            vertexPositionWS = GetAbsolutePositionWS(vertexPositionWS);
        	float mask = dot(planeNormal, (vertexPositionWS - planePosition)) - Noise;

            Out = saturate(mask / fallOff) * intensity;
        }

void Unity_Multiply_float_float(float A, float B, out float Out)
{
Out = A * B;
}

void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
{
    Out = lerp(A, B, T);
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
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
float Alpha;
float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
UnityTexture2D _Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D = UnityBuildTexture2DStructInternal(_BaseColorMap, sampler_BaseColorMap, _BaseColorMap_TexelSize, float4(1, 1, 0, 0), float4(0, 0, 0, 0));
float4 _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D.tex, _Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D.samplerstate, _Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
if (_Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D.hdrDecode.x > 0)
_SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4 = DecodeHDRSample(_SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4, _Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D.hdrDecode);
float _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_R_4_Float = _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4.r;
float _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_G_5_Float = _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4.g;
float _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_B_6_Float = _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4.b;
float _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_A_7_Float = _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4.a;
float4 _Property_fea879b3f3324ecb9cb1e0f2f9890529_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Wireframe_Color) : _Wireframe_Color;
float _Property_1dc4788b9eca4069baa399efa4413298_Out_0_Float = _Wireframe_Thickness;
float _Property_8b57c7d9cbef4037966ba71e85a6a06c_Out_0_Float = _Wireframe_Anti_aliasing;
float _WireframeRenderer_7094b2718889469d8b1d2d7e9831bf6a_Wireframe_3_Float;
float2 _WireframeRenderer_7094b2718889469d8b1d2d7e9831bf6a_BarycentricUV_4_Vector2;
WireframeRenderer_float(IN.barycentric.xyz, max(0, _Property_1dc4788b9eca4069baa399efa4413298_Out_0_Float), max(0, _Property_8b57c7d9cbef4037966ba71e85a6a06c_Out_0_Float), 0, _WireframeRenderer_7094b2718889469d8b1d2d7e9831bf6a_Wireframe_3_Float, _WireframeRenderer_7094b2718889469d8b1d2d7e9831bf6a_BarycentricUV_4_Vector2);
float4x4 _Property_c2fcbed1c8b9408fb9e6665d295dd052_Out_0_Matrix4 = _WireframeShaderMaskData;
float _DynamicMask_32111ad8088744399d405eb222eab7ea_Out_3_Float;
WireframeShaderDynamicMaskPlane_float(IN.WorldSpacePosition, _Property_c2fcbed1c8b9408fb9e6665d295dd052_Out_0_Matrix4, float(0), _DynamicMask_32111ad8088744399d405eb222eab7ea_Out_3_Float);
float _Multiply_b0960d3afcdd41aca8cb2c6f7dc0bb74_Out_2_Float;
Unity_Multiply_float_float(_WireframeRenderer_7094b2718889469d8b1d2d7e9831bf6a_Wireframe_3_Float, _DynamicMask_32111ad8088744399d405eb222eab7ea_Out_3_Float, _Multiply_b0960d3afcdd41aca8cb2c6f7dc0bb74_Out_2_Float);
float4 _Lerp_130fe097f09542d1b7fa52dfa8fd1871_Out_3_Vector4;
Unity_Lerp_float4(_SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4, _Property_fea879b3f3324ecb9cb1e0f2f9890529_Out_0_Vector4, (_Multiply_b0960d3afcdd41aca8cb2c6f7dc0bb74_Out_2_Float.xxxx), _Lerp_130fe097f09542d1b7fa52dfa8fd1871_Out_3_Vector4);
UnityTexture2D _Property_354f04f299e94eb3aeb99dea1d1e9cb2_Out_0_Texture2D = UnityBuildTexture2DStructInternal(_NormalMap, sampler_NormalMap, _NormalMap_TexelSize, float4(1, 1, 0, 0), float4(0, 0, 0, 0));
float4 _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_354f04f299e94eb3aeb99dea1d1e9cb2_Out_0_Texture2D.tex, _Property_354f04f299e94eb3aeb99dea1d1e9cb2_Out_0_Texture2D.samplerstate, _Property_354f04f299e94eb3aeb99dea1d1e9cb2_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
if (_Property_354f04f299e94eb3aeb99dea1d1e9cb2_Out_0_Texture2D.hdrDecode.x > 0)
_SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4 = DecodeHDRSample(_SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4, _Property_354f04f299e94eb3aeb99dea1d1e9cb2_Out_0_Texture2D.hdrDecode);
_SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4);
float _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_R_4_Float = _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4.r;
float _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_G_5_Float = _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4.g;
float _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_B_6_Float = _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4.b;
float _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_A_7_Float = _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4.a;
float4 _Property_bdb9446ca60e4334aaf2d68ef022f6df_Out_0_Vector4 = _Scanner_Glow_Color;
float _Property_786bc74c310d4091adde84ab0c1d72d6_Out_0_Float = _Scanner_Glow_Emission;
float _Multiply_40c4e74cfa634e1ca24c7bafe634a7c6_Out_2_Float;
Unity_Multiply_float_float(_Property_786bc74c310d4091adde84ab0c1d72d6_Out_0_Float, _Property_786bc74c310d4091adde84ab0c1d72d6_Out_0_Float, _Multiply_40c4e74cfa634e1ca24c7bafe634a7c6_Out_2_Float);
float _OneMinus_a4821fb7622e45819daa3b83ed31f32f_Out_1_Float;
Unity_OneMinus_float(_DynamicMask_32111ad8088744399d405eb222eab7ea_Out_3_Float, _OneMinus_a4821fb7622e45819daa3b83ed31f32f_Out_1_Float);
float _Multiply_55da36dd653c4a869854dc914d0c0772_Out_2_Float;
Unity_Multiply_float_float(_DynamicMask_32111ad8088744399d405eb222eab7ea_Out_3_Float, _OneMinus_a4821fb7622e45819daa3b83ed31f32f_Out_1_Float, _Multiply_55da36dd653c4a869854dc914d0c0772_Out_2_Float);
float _Multiply_a98dec7346c143bca3285adc673e52bd_Out_2_Float;
Unity_Multiply_float_float(_Multiply_55da36dd653c4a869854dc914d0c0772_Out_2_Float, _Multiply_55da36dd653c4a869854dc914d0c0772_Out_2_Float, _Multiply_a98dec7346c143bca3285adc673e52bd_Out_2_Float);
float _Multiply_6cfe4d8447ff49c99dd292fb734bd70c_Out_2_Float;
Unity_Multiply_float_float(_Multiply_40c4e74cfa634e1ca24c7bafe634a7c6_Out_2_Float, _Multiply_a98dec7346c143bca3285adc673e52bd_Out_2_Float, _Multiply_6cfe4d8447ff49c99dd292fb734bd70c_Out_2_Float);
float4 _Multiply_4382fbf7eea741d8ac9db946ef8e8f35_Out_2_Vector4;
Unity_Multiply_float4_float4(_Property_bdb9446ca60e4334aaf2d68ef022f6df_Out_0_Vector4, (_Multiply_6cfe4d8447ff49c99dd292fb734bd70c_Out_2_Float.xxxx), _Multiply_4382fbf7eea741d8ac9db946ef8e8f35_Out_2_Vector4);
float4 _Property_f8bc404cb1f0474081562f509e25130e_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Wireframe_Color) : _Wireframe_Color;
float4 _Lerp_673aa80ed8444024935140cccdff3aea_Out_3_Vector4;
Unity_Lerp_float4(_Multiply_4382fbf7eea741d8ac9db946ef8e8f35_Out_2_Vector4, _Property_f8bc404cb1f0474081562f509e25130e_Out_0_Vector4, (_Multiply_b0960d3afcdd41aca8cb2c6f7dc0bb74_Out_2_Float.xxxx), _Lerp_673aa80ed8444024935140cccdff3aea_Out_3_Vector4);
UnityTexture2D _Property_34cf830a0a7943f0a3dd904707c6cd50_Out_0_Texture2D = UnityBuildTexture2DStructInternal(_MaskMap, sampler_MaskMap, _MaskMap_TexelSize, float4(1, 1, 0, 0), float4(0, 0, 0, 0));
float4 _SampleTexture2D_5cb5ecb8bbac4b90b42465076353d1b3_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_34cf830a0a7943f0a3dd904707c6cd50_Out_0_Texture2D.tex, _Property_34cf830a0a7943f0a3dd904707c6cd50_Out_0_Texture2D.samplerstate, _Property_34cf830a0a7943f0a3dd904707c6cd50_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
if (_Property_34cf830a0a7943f0a3dd904707c6cd50_Out_0_Texture2D.hdrDecode.x > 0)
_SampleTexture2D_5cb5ecb8bbac4b90b42465076353d1b3_RGBA_0_Vector4 = DecodeHDRSample(_SampleTexture2D_5cb5ecb8bbac4b90b42465076353d1b3_RGBA_0_Vector4, _Property_34cf830a0a7943f0a3dd904707c6cd50_Out_0_Texture2D.hdrDecode);
float _SampleTexture2D_5cb5ecb8bbac4b90b42465076353d1b3_R_4_Float = _SampleTexture2D_5cb5ecb8bbac4b90b42465076353d1b3_RGBA_0_Vector4.r;
float _SampleTexture2D_5cb5ecb8bbac4b90b42465076353d1b3_G_5_Float = _SampleTexture2D_5cb5ecb8bbac4b90b42465076353d1b3_RGBA_0_Vector4.g;
float _SampleTexture2D_5cb5ecb8bbac4b90b42465076353d1b3_B_6_Float = _SampleTexture2D_5cb5ecb8bbac4b90b42465076353d1b3_RGBA_0_Vector4.b;
float _SampleTexture2D_5cb5ecb8bbac4b90b42465076353d1b3_A_7_Float = _SampleTexture2D_5cb5ecb8bbac4b90b42465076353d1b3_RGBA_0_Vector4.a;
float _Property_83bfc61641084bffa14d057e840bc1a4_Out_0_Float = _Metallic;
float _Property_49afa605221947c696ffbfac306a7f5b_Out_0_Float = _Occlusion;
float _Property_a3b68a3e755144ee84377e58075facb1_Out_0_Float = _Smoothness;
float4 _Vector4_2e0a384889c84b3fabad9cd4921487d7_Out_0_Vector4 = float4(_Property_83bfc61641084bffa14d057e840bc1a4_Out_0_Float, _Property_49afa605221947c696ffbfac306a7f5b_Out_0_Float, float(0), _Property_a3b68a3e755144ee84377e58075facb1_Out_0_Float);
float4 _Multiply_20b8071b3402402db6c81e272e22d5f5_Out_2_Vector4;
Unity_Multiply_float4_float4(_SampleTexture2D_5cb5ecb8bbac4b90b42465076353d1b3_RGBA_0_Vector4, _Vector4_2e0a384889c84b3fabad9cd4921487d7_Out_0_Vector4, _Multiply_20b8071b3402402db6c81e272e22d5f5_Out_2_Vector4);
float _Split_0334e1ac8bdd4cafa3404d8fc87d253c_R_1_Float = _Multiply_20b8071b3402402db6c81e272e22d5f5_Out_2_Vector4[0];
float _Split_0334e1ac8bdd4cafa3404d8fc87d253c_G_2_Float = _Multiply_20b8071b3402402db6c81e272e22d5f5_Out_2_Vector4[1];
float _Split_0334e1ac8bdd4cafa3404d8fc87d253c_B_3_Float = _Multiply_20b8071b3402402db6c81e272e22d5f5_Out_2_Vector4[2];
float _Split_0334e1ac8bdd4cafa3404d8fc87d253c_A_4_Float = _Multiply_20b8071b3402402db6c81e272e22d5f5_Out_2_Vector4[3];
surface.BaseColor = (_Lerp_130fe097f09542d1b7fa52dfa8fd1871_Out_3_Vector4.xyz);
surface.NormalTS = (_SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4.xyz);
surface.Emission = (_Lerp_673aa80ed8444024935140cccdff3aea_Out_3_Vector4.xyz);
surface.Metallic = _Split_0334e1ac8bdd4cafa3404d8fc87d253c_R_1_Float;
surface.Smoothness = _Split_0334e1ac8bdd4cafa3404d8fc87d253c_A_4_Float;
surface.Occlusion = _Split_0334e1ac8bdd4cafa3404d8fc87d253c_G_2_Float;
surface.Alpha = _DynamicMask_32111ad8088744399d405eb222eab7ea_Out_3_Float;
surface.AlphaClipThreshold = float(0.01);
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

    



    output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


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
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/GBufferOutput.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"
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
#define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
#define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_SHADOWCASTER
#define _ALPHATEST_ON 1


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
 float3 positionWS;
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
 float3 WorldSpacePosition;
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
 float3 positionWS : INTERP0;
 float3 normalWS : INTERP1;
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
float4x4 _WireframeShaderMaskData;
float4 _BaseColorMap_TexelSize;
float4 _Scanner_Glow_Color;
float _Smoothness;
float _Occlusion;
float _Metallic;
float4 _NormalMap_TexelSize;
float4 _MaskMap_TexelSize;
float _Wireframe_Thickness;
float4 _Wireframe_Color;
float _Wireframe_Anti_aliasing;
float _Scanner_Glow_Emission;
UNITY_TEXTURE_STREAMING_DEBUG_VARS;
CBUFFER_END


// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_BaseColorMap);
SAMPLER(sampler_BaseColorMap);
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

void WireframeShaderDynamicMaskPlane_float(float3 vertexPositionWS, float4x4 ShaderData, float Noise, out float Out)
{
            float3 planePosition = ShaderData[0].xyz;
        	float3 planeNormal   = ShaderData[1].xyz;
        	float fallOff        = ShaderData[3].x;
        	float intensity      = ShaderData[3].y;


            vertexPositionWS = GetAbsolutePositionWS(vertexPositionWS);
        	float mask = dot(planeNormal, (vertexPositionWS - planePosition)) - Noise;

            Out = saturate(mask / fallOff) * intensity;
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
float Alpha;
float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
float4x4 _Property_c2fcbed1c8b9408fb9e6665d295dd052_Out_0_Matrix4 = _WireframeShaderMaskData;
float _DynamicMask_32111ad8088744399d405eb222eab7ea_Out_3_Float;
WireframeShaderDynamicMaskPlane_float(IN.WorldSpacePosition, _Property_c2fcbed1c8b9408fb9e6665d295dd052_Out_0_Matrix4, float(0), _DynamicMask_32111ad8088744399d405eb222eab7ea_Out_3_Float);
surface.Alpha = _DynamicMask_32111ad8088744399d405eb222eab7ea_Out_3_Float;
surface.AlphaClipThreshold = float(0.01);
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
    Name "MotionVectors"
    Tags
    {
        "LightMode" = "MotionVectors"
    }

// Render State
Cull Back
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

#define _NORMALMAP 1
#define _NORMAL_DROPOFF_TS 1
#define VARYINGS_NEED_POSITION_WS
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_MOTION_VECTORS
#define _ALPHATEST_ON 1


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
 float3 positionWS;
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
};
struct VertexDescriptionInputs
{
 float3 ObjectSpacePosition;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
 float3 positionWS : INTERP0;
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
return output;
}

Varyings UnpackVaryings (PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
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
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)
float4x4 _WireframeShaderMaskData;
float4 _BaseColorMap_TexelSize;
float4 _Scanner_Glow_Color;
float _Smoothness;
float _Occlusion;
float _Metallic;
float4 _NormalMap_TexelSize;
float4 _MaskMap_TexelSize;
float _Wireframe_Thickness;
float4 _Wireframe_Color;
float _Wireframe_Anti_aliasing;
float _Scanner_Glow_Emission;
UNITY_TEXTURE_STREAMING_DEBUG_VARS;
CBUFFER_END


// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_BaseColorMap);
SAMPLER(sampler_BaseColorMap);
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

void WireframeShaderDynamicMaskPlane_float(float3 vertexPositionWS, float4x4 ShaderData, float Noise, out float Out)
{
            float3 planePosition = ShaderData[0].xyz;
        	float3 planeNormal   = ShaderData[1].xyz;
        	float fallOff        = ShaderData[3].x;
        	float intensity      = ShaderData[3].y;


            vertexPositionWS = GetAbsolutePositionWS(vertexPositionWS);
        	float mask = dot(planeNormal, (vertexPositionWS - planePosition)) - Noise;

            Out = saturate(mask / fallOff) * intensity;
        }

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
float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
float4x4 _Property_c2fcbed1c8b9408fb9e6665d295dd052_Out_0_Matrix4 = _WireframeShaderMaskData;
float _DynamicMask_32111ad8088744399d405eb222eab7ea_Out_3_Float;
WireframeShaderDynamicMaskPlane_float(IN.WorldSpacePosition, _Property_c2fcbed1c8b9408fb9e6665d295dd052_Out_0_Matrix4, float(0), _DynamicMask_32111ad8088744399d405eb222eab7ea_Out_3_Float);
surface.Alpha = _DynamicMask_32111ad8088744399d405eb222eab7ea_Out_3_Float;
surface.AlphaClipThreshold = float(0.01);
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

    





    output.WorldSpacePosition = input.positionWS;

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
#define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
#define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
#define VARYINGS_NEED_POSITION_WS
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_DEPTHONLY
#define _ALPHATEST_ON 1


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
 float3 positionWS;
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
 float3 positionWS : INTERP0;
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
return output;
}

Varyings UnpackVaryings (PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
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
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)
float4x4 _WireframeShaderMaskData;
float4 _BaseColorMap_TexelSize;
float4 _Scanner_Glow_Color;
float _Smoothness;
float _Occlusion;
float _Metallic;
float4 _NormalMap_TexelSize;
float4 _MaskMap_TexelSize;
float _Wireframe_Thickness;
float4 _Wireframe_Color;
float _Wireframe_Anti_aliasing;
float _Scanner_Glow_Emission;
UNITY_TEXTURE_STREAMING_DEBUG_VARS;
CBUFFER_END


// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_BaseColorMap);
SAMPLER(sampler_BaseColorMap);
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

void WireframeShaderDynamicMaskPlane_float(float3 vertexPositionWS, float4x4 ShaderData, float Noise, out float Out)
{
            float3 planePosition = ShaderData[0].xyz;
        	float3 planeNormal   = ShaderData[1].xyz;
        	float fallOff        = ShaderData[3].x;
        	float intensity      = ShaderData[3].y;


            vertexPositionWS = GetAbsolutePositionWS(vertexPositionWS);
        	float mask = dot(planeNormal, (vertexPositionWS - planePosition)) - Noise;

            Out = saturate(mask / fallOff) * intensity;
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
float Alpha;
float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
float4x4 _Property_c2fcbed1c8b9408fb9e6665d295dd052_Out_0_Matrix4 = _WireframeShaderMaskData;
float _DynamicMask_32111ad8088744399d405eb222eab7ea_Out_3_Float;
WireframeShaderDynamicMaskPlane_float(IN.WorldSpacePosition, _Property_c2fcbed1c8b9408fb9e6665d295dd052_Out_0_Matrix4, float(0), _DynamicMask_32111ad8088744399d405eb222eab7ea_Out_3_Float);
surface.Alpha = _DynamicMask_32111ad8088744399d405eb222eab7ea_Out_3_Float;
surface.AlphaClipThreshold = float(0.01);
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
#define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
#define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define VARYINGS_NEED_TANGENT_WS
#define VARYINGS_NEED_TEXCOORD0
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_DEPTHNORMALS
#define _ALPHATEST_ON 1


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
 float4 uv0 : TEXCOORD0;
 float4 uv1 : TEXCOORD1;
#if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
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
 float3 TangentSpaceNormal;
 float3 WorldSpacePosition;
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
 float3 positionWS : INTERP2;
 float3 normalWS : INTERP3;
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
output.tangentWS.xyzw = input.tangentWS;
output.texCoord0.xyzw = input.texCoord0;
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
output.tangentWS = input.tangentWS.xyzw;
output.texCoord0 = input.texCoord0.xyzw;
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
float4x4 _WireframeShaderMaskData;
float4 _BaseColorMap_TexelSize;
float4 _Scanner_Glow_Color;
float _Smoothness;
float _Occlusion;
float _Metallic;
float4 _NormalMap_TexelSize;
float4 _MaskMap_TexelSize;
float _Wireframe_Thickness;
float4 _Wireframe_Color;
float _Wireframe_Anti_aliasing;
float _Scanner_Glow_Emission;
UNITY_TEXTURE_STREAMING_DEBUG_VARS;
CBUFFER_END


// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_BaseColorMap);
SAMPLER(sampler_BaseColorMap);
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

void WireframeShaderDynamicMaskPlane_float(float3 vertexPositionWS, float4x4 ShaderData, float Noise, out float Out)
{
            float3 planePosition = ShaderData[0].xyz;
        	float3 planeNormal   = ShaderData[1].xyz;
        	float fallOff        = ShaderData[3].x;
        	float intensity      = ShaderData[3].y;


            vertexPositionWS = GetAbsolutePositionWS(vertexPositionWS);
        	float mask = dot(planeNormal, (vertexPositionWS - planePosition)) - Noise;

            Out = saturate(mask / fallOff) * intensity;
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
float3 NormalTS;
float Alpha;
float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
UnityTexture2D _Property_354f04f299e94eb3aeb99dea1d1e9cb2_Out_0_Texture2D = UnityBuildTexture2DStructInternal(_NormalMap, sampler_NormalMap, _NormalMap_TexelSize, float4(1, 1, 0, 0), float4(0, 0, 0, 0));
float4 _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_354f04f299e94eb3aeb99dea1d1e9cb2_Out_0_Texture2D.tex, _Property_354f04f299e94eb3aeb99dea1d1e9cb2_Out_0_Texture2D.samplerstate, _Property_354f04f299e94eb3aeb99dea1d1e9cb2_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
if (_Property_354f04f299e94eb3aeb99dea1d1e9cb2_Out_0_Texture2D.hdrDecode.x > 0)
_SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4 = DecodeHDRSample(_SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4, _Property_354f04f299e94eb3aeb99dea1d1e9cb2_Out_0_Texture2D.hdrDecode);
_SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4);
float _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_R_4_Float = _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4.r;
float _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_G_5_Float = _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4.g;
float _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_B_6_Float = _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4.b;
float _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_A_7_Float = _SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4.a;
float4x4 _Property_c2fcbed1c8b9408fb9e6665d295dd052_Out_0_Matrix4 = _WireframeShaderMaskData;
float _DynamicMask_32111ad8088744399d405eb222eab7ea_Out_3_Float;
WireframeShaderDynamicMaskPlane_float(IN.WorldSpacePosition, _Property_c2fcbed1c8b9408fb9e6665d295dd052_Out_0_Matrix4, float(0), _DynamicMask_32111ad8088744399d405eb222eab7ea_Out_3_Float);
surface.NormalTS = (_SampleTexture2D_ee1c94e2e7134f96b17bbdca87acc73f_RGBA_0_Vector4.xyz);
surface.Alpha = _DynamicMask_32111ad8088744399d405eb222eab7ea_Out_3_Float;
surface.AlphaClipThreshold = float(0.01);
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

    



    output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


    output.WorldSpacePosition = input.positionWS;

    #if UNITY_UV_STARTS_AT_TOP
    #else
    #endif


    output.uv0 = input.texCoord0;
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
#define ATTRIBUTES_NEED_TEXCOORD4
#define ATTRIBUTES_NEED_TEXCOORD5
#define ATTRIBUTES_NEED_TEXCOORD6
#define ATTRIBUTES_NEED_TEXCOORD7
#define ATTRIBUTES_NEED_INSTANCEID
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
#define SHADERPASS SHADERPASS_META
#define _FOG_FRAGMENT 1
#define _ALPHATEST_ON 1


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
float4x4 _WireframeShaderMaskData;
float4 _BaseColorMap_TexelSize;
float4 _Scanner_Glow_Color;
float _Smoothness;
float _Occlusion;
float _Metallic;
float4 _NormalMap_TexelSize;
float4 _MaskMap_TexelSize;
float _Wireframe_Thickness;
float4 _Wireframe_Color;
float _Wireframe_Anti_aliasing;
float _Scanner_Glow_Emission;
UNITY_TEXTURE_STREAMING_DEBUG_VARS;
CBUFFER_END


// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_BaseColorMap);
SAMPLER(sampler_BaseColorMap);
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

void WireframeShaderDynamicMaskPlane_float(float3 vertexPositionWS, float4x4 ShaderData, float Noise, out float Out)
{
            float3 planePosition = ShaderData[0].xyz;
        	float3 planeNormal   = ShaderData[1].xyz;
        	float fallOff        = ShaderData[3].x;
        	float intensity      = ShaderData[3].y;


            vertexPositionWS = GetAbsolutePositionWS(vertexPositionWS);
        	float mask = dot(planeNormal, (vertexPositionWS - planePosition)) - Noise;

            Out = saturate(mask / fallOff) * intensity;
        }

void Unity_Multiply_float_float(float A, float B, out float Out)
{
Out = A * B;
}

void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
{
    Out = lerp(A, B, T);
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
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
float3 Emission;
float Alpha;
float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
UnityTexture2D _Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D = UnityBuildTexture2DStructInternal(_BaseColorMap, sampler_BaseColorMap, _BaseColorMap_TexelSize, float4(1, 1, 0, 0), float4(0, 0, 0, 0));
float4 _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D.tex, _Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D.samplerstate, _Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
if (_Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D.hdrDecode.x > 0)
_SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4 = DecodeHDRSample(_SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4, _Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D.hdrDecode);
float _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_R_4_Float = _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4.r;
float _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_G_5_Float = _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4.g;
float _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_B_6_Float = _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4.b;
float _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_A_7_Float = _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4.a;
float4 _Property_fea879b3f3324ecb9cb1e0f2f9890529_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Wireframe_Color) : _Wireframe_Color;
float _Property_1dc4788b9eca4069baa399efa4413298_Out_0_Float = _Wireframe_Thickness;
float _Property_8b57c7d9cbef4037966ba71e85a6a06c_Out_0_Float = _Wireframe_Anti_aliasing;
float _WireframeRenderer_7094b2718889469d8b1d2d7e9831bf6a_Wireframe_3_Float;
float2 _WireframeRenderer_7094b2718889469d8b1d2d7e9831bf6a_BarycentricUV_4_Vector2;
WireframeRenderer_float(IN.barycentric.xyz, max(0, _Property_1dc4788b9eca4069baa399efa4413298_Out_0_Float), max(0, _Property_8b57c7d9cbef4037966ba71e85a6a06c_Out_0_Float), 0, _WireframeRenderer_7094b2718889469d8b1d2d7e9831bf6a_Wireframe_3_Float, _WireframeRenderer_7094b2718889469d8b1d2d7e9831bf6a_BarycentricUV_4_Vector2);
float4x4 _Property_c2fcbed1c8b9408fb9e6665d295dd052_Out_0_Matrix4 = _WireframeShaderMaskData;
float _DynamicMask_32111ad8088744399d405eb222eab7ea_Out_3_Float;
WireframeShaderDynamicMaskPlane_float(IN.WorldSpacePosition, _Property_c2fcbed1c8b9408fb9e6665d295dd052_Out_0_Matrix4, float(0), _DynamicMask_32111ad8088744399d405eb222eab7ea_Out_3_Float);
float _Multiply_b0960d3afcdd41aca8cb2c6f7dc0bb74_Out_2_Float;
Unity_Multiply_float_float(_WireframeRenderer_7094b2718889469d8b1d2d7e9831bf6a_Wireframe_3_Float, _DynamicMask_32111ad8088744399d405eb222eab7ea_Out_3_Float, _Multiply_b0960d3afcdd41aca8cb2c6f7dc0bb74_Out_2_Float);
float4 _Lerp_130fe097f09542d1b7fa52dfa8fd1871_Out_3_Vector4;
Unity_Lerp_float4(_SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4, _Property_fea879b3f3324ecb9cb1e0f2f9890529_Out_0_Vector4, (_Multiply_b0960d3afcdd41aca8cb2c6f7dc0bb74_Out_2_Float.xxxx), _Lerp_130fe097f09542d1b7fa52dfa8fd1871_Out_3_Vector4);
float4 _Property_bdb9446ca60e4334aaf2d68ef022f6df_Out_0_Vector4 = _Scanner_Glow_Color;
float _Property_786bc74c310d4091adde84ab0c1d72d6_Out_0_Float = _Scanner_Glow_Emission;
float _Multiply_40c4e74cfa634e1ca24c7bafe634a7c6_Out_2_Float;
Unity_Multiply_float_float(_Property_786bc74c310d4091adde84ab0c1d72d6_Out_0_Float, _Property_786bc74c310d4091adde84ab0c1d72d6_Out_0_Float, _Multiply_40c4e74cfa634e1ca24c7bafe634a7c6_Out_2_Float);
float _OneMinus_a4821fb7622e45819daa3b83ed31f32f_Out_1_Float;
Unity_OneMinus_float(_DynamicMask_32111ad8088744399d405eb222eab7ea_Out_3_Float, _OneMinus_a4821fb7622e45819daa3b83ed31f32f_Out_1_Float);
float _Multiply_55da36dd653c4a869854dc914d0c0772_Out_2_Float;
Unity_Multiply_float_float(_DynamicMask_32111ad8088744399d405eb222eab7ea_Out_3_Float, _OneMinus_a4821fb7622e45819daa3b83ed31f32f_Out_1_Float, _Multiply_55da36dd653c4a869854dc914d0c0772_Out_2_Float);
float _Multiply_a98dec7346c143bca3285adc673e52bd_Out_2_Float;
Unity_Multiply_float_float(_Multiply_55da36dd653c4a869854dc914d0c0772_Out_2_Float, _Multiply_55da36dd653c4a869854dc914d0c0772_Out_2_Float, _Multiply_a98dec7346c143bca3285adc673e52bd_Out_2_Float);
float _Multiply_6cfe4d8447ff49c99dd292fb734bd70c_Out_2_Float;
Unity_Multiply_float_float(_Multiply_40c4e74cfa634e1ca24c7bafe634a7c6_Out_2_Float, _Multiply_a98dec7346c143bca3285adc673e52bd_Out_2_Float, _Multiply_6cfe4d8447ff49c99dd292fb734bd70c_Out_2_Float);
float4 _Multiply_4382fbf7eea741d8ac9db946ef8e8f35_Out_2_Vector4;
Unity_Multiply_float4_float4(_Property_bdb9446ca60e4334aaf2d68ef022f6df_Out_0_Vector4, (_Multiply_6cfe4d8447ff49c99dd292fb734bd70c_Out_2_Float.xxxx), _Multiply_4382fbf7eea741d8ac9db946ef8e8f35_Out_2_Vector4);
float4 _Property_f8bc404cb1f0474081562f509e25130e_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Wireframe_Color) : _Wireframe_Color;
float4 _Lerp_673aa80ed8444024935140cccdff3aea_Out_3_Vector4;
Unity_Lerp_float4(_Multiply_4382fbf7eea741d8ac9db946ef8e8f35_Out_2_Vector4, _Property_f8bc404cb1f0474081562f509e25130e_Out_0_Vector4, (_Multiply_b0960d3afcdd41aca8cb2c6f7dc0bb74_Out_2_Float.xxxx), _Lerp_673aa80ed8444024935140cccdff3aea_Out_3_Vector4);
surface.BaseColor = (_Lerp_130fe097f09542d1b7fa52dfa8fd1871_Out_3_Vector4.xyz);
surface.Emission = (_Lerp_673aa80ed8444024935140cccdff3aea_Out_3_Vector4.xyz);
surface.Alpha = _DynamicMask_32111ad8088744399d405eb222eab7ea_Out_3_Float;
surface.AlphaClipThreshold = float(0.01);
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
#define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
#define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
#define VARYINGS_NEED_POSITION_WS
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_DEPTHONLY
#define SCENESELECTIONPASS 1
#define ALPHA_CLIP_THRESHOLD 1
#define _ALPHATEST_ON 1


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
 float3 positionWS;
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
 float3 positionWS : INTERP0;
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
return output;
}

Varyings UnpackVaryings (PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
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
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)
float4x4 _WireframeShaderMaskData;
float4 _BaseColorMap_TexelSize;
float4 _Scanner_Glow_Color;
float _Smoothness;
float _Occlusion;
float _Metallic;
float4 _NormalMap_TexelSize;
float4 _MaskMap_TexelSize;
float _Wireframe_Thickness;
float4 _Wireframe_Color;
float _Wireframe_Anti_aliasing;
float _Scanner_Glow_Emission;
UNITY_TEXTURE_STREAMING_DEBUG_VARS;
CBUFFER_END


// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_BaseColorMap);
SAMPLER(sampler_BaseColorMap);
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

void WireframeShaderDynamicMaskPlane_float(float3 vertexPositionWS, float4x4 ShaderData, float Noise, out float Out)
{
            float3 planePosition = ShaderData[0].xyz;
        	float3 planeNormal   = ShaderData[1].xyz;
        	float fallOff        = ShaderData[3].x;
        	float intensity      = ShaderData[3].y;


            vertexPositionWS = GetAbsolutePositionWS(vertexPositionWS);
        	float mask = dot(planeNormal, (vertexPositionWS - planePosition)) - Noise;

            Out = saturate(mask / fallOff) * intensity;
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
float Alpha;
float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
float4x4 _Property_c2fcbed1c8b9408fb9e6665d295dd052_Out_0_Matrix4 = _WireframeShaderMaskData;
float _DynamicMask_32111ad8088744399d405eb222eab7ea_Out_3_Float;
WireframeShaderDynamicMaskPlane_float(IN.WorldSpacePosition, _Property_c2fcbed1c8b9408fb9e6665d295dd052_Out_0_Matrix4, float(0), _DynamicMask_32111ad8088744399d405eb222eab7ea_Out_3_Float);
surface.Alpha = _DynamicMask_32111ad8088744399d405eb222eab7ea_Out_3_Float;
surface.AlphaClipThreshold = float(0.01);
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
Cull Back

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

#define _NORMALMAP 1
#define _NORMAL_DROPOFF_TS 1
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
#define _ALPHATEST_ON 1


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
float4x4 _WireframeShaderMaskData;
float4 _BaseColorMap_TexelSize;
float4 _Scanner_Glow_Color;
float _Smoothness;
float _Occlusion;
float _Metallic;
float4 _NormalMap_TexelSize;
float4 _MaskMap_TexelSize;
float _Wireframe_Thickness;
float4 _Wireframe_Color;
float _Wireframe_Anti_aliasing;
float _Scanner_Glow_Emission;
UNITY_TEXTURE_STREAMING_DEBUG_VARS;
CBUFFER_END


// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_BaseColorMap);
SAMPLER(sampler_BaseColorMap);
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

void WireframeShaderDynamicMaskPlane_float(float3 vertexPositionWS, float4x4 ShaderData, float Noise, out float Out)
{
            float3 planePosition = ShaderData[0].xyz;
        	float3 planeNormal   = ShaderData[1].xyz;
        	float fallOff        = ShaderData[3].x;
        	float intensity      = ShaderData[3].y;


            vertexPositionWS = GetAbsolutePositionWS(vertexPositionWS);
        	float mask = dot(planeNormal, (vertexPositionWS - planePosition)) - Noise;

            Out = saturate(mask / fallOff) * intensity;
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
float Alpha;
float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
UnityTexture2D _Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D = UnityBuildTexture2DStructInternal(_BaseColorMap, sampler_BaseColorMap, _BaseColorMap_TexelSize, float4(1, 1, 0, 0), float4(0, 0, 0, 0));
float4 _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D.tex, _Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D.samplerstate, _Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
if (_Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D.hdrDecode.x > 0)
_SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4 = DecodeHDRSample(_SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4, _Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D.hdrDecode);
float _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_R_4_Float = _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4.r;
float _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_G_5_Float = _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4.g;
float _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_B_6_Float = _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4.b;
float _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_A_7_Float = _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4.a;
float4 _Property_fea879b3f3324ecb9cb1e0f2f9890529_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Wireframe_Color) : _Wireframe_Color;
float _Property_1dc4788b9eca4069baa399efa4413298_Out_0_Float = _Wireframe_Thickness;
float _Property_8b57c7d9cbef4037966ba71e85a6a06c_Out_0_Float = _Wireframe_Anti_aliasing;
float _WireframeRenderer_7094b2718889469d8b1d2d7e9831bf6a_Wireframe_3_Float;
float2 _WireframeRenderer_7094b2718889469d8b1d2d7e9831bf6a_BarycentricUV_4_Vector2;
WireframeRenderer_float(IN.barycentric.xyz, max(0, _Property_1dc4788b9eca4069baa399efa4413298_Out_0_Float), max(0, _Property_8b57c7d9cbef4037966ba71e85a6a06c_Out_0_Float), 0, _WireframeRenderer_7094b2718889469d8b1d2d7e9831bf6a_Wireframe_3_Float, _WireframeRenderer_7094b2718889469d8b1d2d7e9831bf6a_BarycentricUV_4_Vector2);
float4x4 _Property_c2fcbed1c8b9408fb9e6665d295dd052_Out_0_Matrix4 = _WireframeShaderMaskData;
float _DynamicMask_32111ad8088744399d405eb222eab7ea_Out_3_Float;
WireframeShaderDynamicMaskPlane_float(IN.WorldSpacePosition, _Property_c2fcbed1c8b9408fb9e6665d295dd052_Out_0_Matrix4, float(0), _DynamicMask_32111ad8088744399d405eb222eab7ea_Out_3_Float);
float _Multiply_b0960d3afcdd41aca8cb2c6f7dc0bb74_Out_2_Float;
Unity_Multiply_float_float(_WireframeRenderer_7094b2718889469d8b1d2d7e9831bf6a_Wireframe_3_Float, _DynamicMask_32111ad8088744399d405eb222eab7ea_Out_3_Float, _Multiply_b0960d3afcdd41aca8cb2c6f7dc0bb74_Out_2_Float);
float4 _Lerp_130fe097f09542d1b7fa52dfa8fd1871_Out_3_Vector4;
Unity_Lerp_float4(_SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4, _Property_fea879b3f3324ecb9cb1e0f2f9890529_Out_0_Vector4, (_Multiply_b0960d3afcdd41aca8cb2c6f7dc0bb74_Out_2_Float.xxxx), _Lerp_130fe097f09542d1b7fa52dfa8fd1871_Out_3_Vector4);
surface.BaseColor = (_Lerp_130fe097f09542d1b7fa52dfa8fd1871_Out_3_Vector4.xyz);
surface.Alpha = _DynamicMask_32111ad8088744399d405eb222eab7ea_Out_3_Float;
surface.AlphaClipThreshold = float(0.01);
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
Pass
{
    Name "Universal 2D"
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

#define _NORMALMAP 1
#define _NORMAL_DROPOFF_TS 1
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
#define SHADERPASS SHADERPASS_2D
#define _ALPHATEST_ON 1


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
float4x4 _WireframeShaderMaskData;
float4 _BaseColorMap_TexelSize;
float4 _Scanner_Glow_Color;
float _Smoothness;
float _Occlusion;
float _Metallic;
float4 _NormalMap_TexelSize;
float4 _MaskMap_TexelSize;
float _Wireframe_Thickness;
float4 _Wireframe_Color;
float _Wireframe_Anti_aliasing;
float _Scanner_Glow_Emission;
UNITY_TEXTURE_STREAMING_DEBUG_VARS;
CBUFFER_END


// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_BaseColorMap);
SAMPLER(sampler_BaseColorMap);
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

void WireframeShaderDynamicMaskPlane_float(float3 vertexPositionWS, float4x4 ShaderData, float Noise, out float Out)
{
            float3 planePosition = ShaderData[0].xyz;
        	float3 planeNormal   = ShaderData[1].xyz;
        	float fallOff        = ShaderData[3].x;
        	float intensity      = ShaderData[3].y;


            vertexPositionWS = GetAbsolutePositionWS(vertexPositionWS);
        	float mask = dot(planeNormal, (vertexPositionWS - planePosition)) - Noise;

            Out = saturate(mask / fallOff) * intensity;
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
float Alpha;
float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
UnityTexture2D _Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D = UnityBuildTexture2DStructInternal(_BaseColorMap, sampler_BaseColorMap, _BaseColorMap_TexelSize, float4(1, 1, 0, 0), float4(0, 0, 0, 0));
float4 _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D.tex, _Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D.samplerstate, _Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
if (_Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D.hdrDecode.x > 0)
_SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4 = DecodeHDRSample(_SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4, _Property_195081f1ea634199a5f67314d3febc32_Out_0_Texture2D.hdrDecode);
float _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_R_4_Float = _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4.r;
float _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_G_5_Float = _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4.g;
float _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_B_6_Float = _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4.b;
float _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_A_7_Float = _SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4.a;
float4 _Property_fea879b3f3324ecb9cb1e0f2f9890529_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Wireframe_Color) : _Wireframe_Color;
float _Property_1dc4788b9eca4069baa399efa4413298_Out_0_Float = _Wireframe_Thickness;
float _Property_8b57c7d9cbef4037966ba71e85a6a06c_Out_0_Float = _Wireframe_Anti_aliasing;
float _WireframeRenderer_7094b2718889469d8b1d2d7e9831bf6a_Wireframe_3_Float;
float2 _WireframeRenderer_7094b2718889469d8b1d2d7e9831bf6a_BarycentricUV_4_Vector2;
WireframeRenderer_float(IN.barycentric.xyz, max(0, _Property_1dc4788b9eca4069baa399efa4413298_Out_0_Float), max(0, _Property_8b57c7d9cbef4037966ba71e85a6a06c_Out_0_Float), 0, _WireframeRenderer_7094b2718889469d8b1d2d7e9831bf6a_Wireframe_3_Float, _WireframeRenderer_7094b2718889469d8b1d2d7e9831bf6a_BarycentricUV_4_Vector2);
float4x4 _Property_c2fcbed1c8b9408fb9e6665d295dd052_Out_0_Matrix4 = _WireframeShaderMaskData;
float _DynamicMask_32111ad8088744399d405eb222eab7ea_Out_3_Float;
WireframeShaderDynamicMaskPlane_float(IN.WorldSpacePosition, _Property_c2fcbed1c8b9408fb9e6665d295dd052_Out_0_Matrix4, float(0), _DynamicMask_32111ad8088744399d405eb222eab7ea_Out_3_Float);
float _Multiply_b0960d3afcdd41aca8cb2c6f7dc0bb74_Out_2_Float;
Unity_Multiply_float_float(_WireframeRenderer_7094b2718889469d8b1d2d7e9831bf6a_Wireframe_3_Float, _DynamicMask_32111ad8088744399d405eb222eab7ea_Out_3_Float, _Multiply_b0960d3afcdd41aca8cb2c6f7dc0bb74_Out_2_Float);
float4 _Lerp_130fe097f09542d1b7fa52dfa8fd1871_Out_3_Vector4;
Unity_Lerp_float4(_SampleTexture2D_7699a0563c2a4636b70c794ae6b5420e_RGBA_0_Vector4, _Property_fea879b3f3324ecb9cb1e0f2f9890529_Out_0_Vector4, (_Multiply_b0960d3afcdd41aca8cb2c6f7dc0bb74_Out_2_Float.xxxx), _Lerp_130fe097f09542d1b7fa52dfa8fd1871_Out_3_Vector4);
surface.BaseColor = (_Lerp_130fe097f09542d1b7fa52dfa8fd1871_Out_3_Vector4.xyz);
surface.Alpha = _DynamicMask_32111ad8088744399d405eb222eab7ea_Out_3_Float;
surface.AlphaClipThreshold = float(0.01);
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
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

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
            "m_Id": "219f3a903fa043dfa4bf465dcb389cf4"
        },
        {
            "m_Id": "69fd77ac7509495bac99aa508901e31f"
        },
        {
            "m_Id": "6177ce1931734f6085eaa0bb2d476648"
        },
        {
            "m_Id": "9a3ab0f3466c4607b74281dbb4adfd0b"
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
        },
        {
            "m_Id": "285c232de00b4ac080f89daf54666812"
        }
    ],
    "m_Keywords": [],
    "m_Dropdowns": [],
    "m_CategoryData": [
        {
            "m_Id": "dd6fcdf0141b461d9ce07ca51467b3c4"
        },
        {
            "m_Id": "f711fc5b9a8543eea5c82e070f7f1bb7"
        },
        {
            "m_Id": "65a435a0d253424193b7973c27a3a3a3"
        }
    ],
    "m_Nodes": [
        {
            "m_Id": "17bfb3aecbb74395831e0e397f38e9e7"
        },
        {
            "m_Id": "13042d8a354542e1aae4078647339062"
        },
        {
            "m_Id": "e8edb428dc364aaab9a86f55a6e50ea1"
        },
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
            "m_Id": "12901b7b66be40eb8b84bc7723e161ec"
        },
        {
            "m_Id": "223f143177fe4cbfbe17cfa0dfc1eb71"
        },
        {
            "m_Id": "9378eb7ab88347b093b169c87551d064"
        },
        {
            "m_Id": "8e5d6d22aa854f9eb7ad09c4e189d002"
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
            "m_Id": "fea879b3f3324ecb9cb1e0f2f9890529"
        },
        {
            "m_Id": "c2fcbed1c8b9408fb9e6665d295dd052"
        },
        {
            "m_Id": "86722a7582584325b1881f836abb0852"
        },
        {
            "m_Id": "bdb9446ca60e4334aaf2d68ef022f6df"
        },
        {
            "m_Id": "4382fbf7eea741d8ac9db946ef8e8f35"
        },
        {
            "m_Id": "786bc74c310d4091adde84ab0c1d72d6"
        },
        {
            "m_Id": "40c4e74cfa634e1ca24c7bafe634a7c6"
        },
        {
            "m_Id": "6cfe4d8447ff49c99dd292fb734bd70c"
        },
        {
            "m_Id": "673aa80ed8444024935140cccdff3aea"
        },
        {
            "m_Id": "f8bc404cb1f0474081562f509e25130e"
        },
        {
            "m_Id": "55da36dd653c4a869854dc914d0c0772"
        },
        {
            "m_Id": "a4821fb7622e45819daa3b83ed31f32f"
        },
        {
            "m_Id": "b0960d3afcdd41aca8cb2c6f7dc0bb74"
        },
        {
            "m_Id": "a98dec7346c143bca3285adc673e52bd"
        },
        {
            "m_Id": "1d4cc1b0e20e4af9a83687f0d49b6752"
        },
        {
            "m_Id": "e785a6b7e06c4b27a910d0533499d4ae"
        },
        {
            "m_Id": "34cf830a0a7943f0a3dd904707c6cd50"
        },
        {
            "m_Id": "5cb5ecb8bbac4b90b42465076353d1b3"
        },
        {
            "m_Id": "83bfc61641084bffa14d057e840bc1a4"
        },
        {
            "m_Id": "2e0a384889c84b3fabad9cd4921487d7"
        },
        {
            "m_Id": "a3b68a3e755144ee84377e58075facb1"
        },
        {
            "m_Id": "49afa605221947c696ffbfac306a7f5b"
        },
        {
            "m_Id": "20b8071b3402402db6c81e272e22d5f5"
        },
        {
            "m_Id": "0334e1ac8bdd4cafa3404d8fc87d253c"
        },
        {
            "m_Id": "dbaca9971ef44eb8bec8bf86378f95b5"
        },
        {
            "m_Id": "32111ad8088744399d405eb222eab7ea"
        },
        {
            "m_Id": "7094b2718889469d8b1d2d7e9831bf6a"
        }
    ],
    "m_GroupDatas": [
        {
            "m_Id": "5d1b0a9b79bb4867b867f19fef38c9bb"
        },
        {
            "m_Id": "6c38f7e0dec942979f9c113ee7123d9b"
        },
        {
            "m_Id": "80273af3153e44738adaf387e0fc7239"
        }
    ],
    "m_StickyNoteDatas": [],
    "m_Edges": [
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "0334e1ac8bdd4cafa3404d8fc87d253c"
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
                    "m_Id": "0334e1ac8bdd4cafa3404d8fc87d253c"
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
                    "m_Id": "0334e1ac8bdd4cafa3404d8fc87d253c"
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
                    "m_Id": "1d4cc1b0e20e4af9a83687f0d49b6752"
                },
                "m_SlotId": 1
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "e785a6b7e06c4b27a910d0533499d4ae"
                },
                "m_SlotId": 0
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
                    "m_Id": "7094b2718889469d8b1d2d7e9831bf6a"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "20b8071b3402402db6c81e272e22d5f5"
                },
                "m_SlotId": 2
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "0334e1ac8bdd4cafa3404d8fc87d253c"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "2e0a384889c84b3fabad9cd4921487d7"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "20b8071b3402402db6c81e272e22d5f5"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "32111ad8088744399d405eb222eab7ea"
                },
                "m_SlotId": 3
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "1d4cc1b0e20e4af9a83687f0d49b6752"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "32111ad8088744399d405eb222eab7ea"
                },
                "m_SlotId": 3
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "b0960d3afcdd41aca8cb2c6f7dc0bb74"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "32111ad8088744399d405eb222eab7ea"
                },
                "m_SlotId": 3
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "dbaca9971ef44eb8bec8bf86378f95b5"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "34cf830a0a7943f0a3dd904707c6cd50"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "5cb5ecb8bbac4b90b42465076353d1b3"
                },
                "m_SlotId": 1
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
                    "m_Id": "40c4e74cfa634e1ca24c7bafe634a7c6"
                },
                "m_SlotId": 2
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "6cfe4d8447ff49c99dd292fb734bd70c"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "4382fbf7eea741d8ac9db946ef8e8f35"
                },
                "m_SlotId": 2
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "673aa80ed8444024935140cccdff3aea"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "49afa605221947c696ffbfac306a7f5b"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "2e0a384889c84b3fabad9cd4921487d7"
                },
                "m_SlotId": 2
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "55da36dd653c4a869854dc914d0c0772"
                },
                "m_SlotId": 2
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "a98dec7346c143bca3285adc673e52bd"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "55da36dd653c4a869854dc914d0c0772"
                },
                "m_SlotId": 2
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "a98dec7346c143bca3285adc673e52bd"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "5cb5ecb8bbac4b90b42465076353d1b3"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "20b8071b3402402db6c81e272e22d5f5"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "673aa80ed8444024935140cccdff3aea"
                },
                "m_SlotId": 3
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "12901b7b66be40eb8b84bc7723e161ec"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "6cfe4d8447ff49c99dd292fb734bd70c"
                },
                "m_SlotId": 2
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "4382fbf7eea741d8ac9db946ef8e8f35"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "7094b2718889469d8b1d2d7e9831bf6a"
                },
                "m_SlotId": 3
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "b0960d3afcdd41aca8cb2c6f7dc0bb74"
                },
                "m_SlotId": 0
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
                    "m_Id": "786bc74c310d4091adde84ab0c1d72d6"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "40c4e74cfa634e1ca24c7bafe634a7c6"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "786bc74c310d4091adde84ab0c1d72d6"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "40c4e74cfa634e1ca24c7bafe634a7c6"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "83bfc61641084bffa14d057e840bc1a4"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "2e0a384889c84b3fabad9cd4921487d7"
                },
                "m_SlotId": 1
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
                    "m_Id": "7094b2718889469d8b1d2d7e9831bf6a"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "a3b68a3e755144ee84377e58075facb1"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "2e0a384889c84b3fabad9cd4921487d7"
                },
                "m_SlotId": 4
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "a4821fb7622e45819daa3b83ed31f32f"
                },
                "m_SlotId": 1
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "55da36dd653c4a869854dc914d0c0772"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "a98dec7346c143bca3285adc673e52bd"
                },
                "m_SlotId": 2
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "6cfe4d8447ff49c99dd292fb734bd70c"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "b0960d3afcdd41aca8cb2c6f7dc0bb74"
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
                    "m_Id": "b0960d3afcdd41aca8cb2c6f7dc0bb74"
                },
                "m_SlotId": 2
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "673aa80ed8444024935140cccdff3aea"
                },
                "m_SlotId": 2
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "bdb9446ca60e4334aaf2d68ef022f6df"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "4382fbf7eea741d8ac9db946ef8e8f35"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "c2fcbed1c8b9408fb9e6665d295dd052"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "32111ad8088744399d405eb222eab7ea"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "dbaca9971ef44eb8bec8bf86378f95b5"
                },
                "m_SlotId": 1
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "55da36dd653c4a869854dc914d0c0772"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "dbaca9971ef44eb8bec8bf86378f95b5"
                },
                "m_SlotId": 1
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "a4821fb7622e45819daa3b83ed31f32f"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "e785a6b7e06c4b27a910d0533499d4ae"
                },
                "m_SlotId": 1
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "8e5d6d22aa854f9eb7ad09c4e189d002"
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
                    "m_Id": "f8bc404cb1f0474081562f509e25130e"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "673aa80ed8444024935140cccdff3aea"
                },
                "m_SlotId": 1
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
            "x": 231.27264404296876,
            "y": -122.18180847167969
        },
        "m_Blocks": [
            {
                "m_Id": "17bfb3aecbb74395831e0e397f38e9e7"
            },
            {
                "m_Id": "13042d8a354542e1aae4078647339062"
            },
            {
                "m_Id": "e8edb428dc364aaab9a86f55a6e50ea1"
            }
        ]
    },
    "m_FragmentContext": {
        "m_Position": {
            "x": 231.27264404296876,
            "y": 207.70907592773438
        },
        "m_Blocks": [
            {
                "m_Id": "a0ff7a5655a241a693febc2166745dd3"
            },
            {
                "m_Id": "4324d39072de4d928c7d1848983bb03a"
            },
            {
                "m_Id": "12901b7b66be40eb8b84bc7723e161ec"
            },
            {
                "m_Id": "f1a6a40111e048918c477da6c320139d"
            },
            {
                "m_Id": "9378eb7ab88347b093b169c87551d064"
            },
            {
                "m_Id": "223f143177fe4cbfbe17cfa0dfc1eb71"
            },
            {
                "m_Id": "86722a7582584325b1881f836abb0852"
            },
            {
                "m_Id": "8e5d6d22aa854f9eb7ad09c4e189d002"
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
    "m_Path": "Amazing Assets/Dynamic Wireframe Shader/Examples/Scanner",
    "m_GraphPrecision": 1,
    "m_PreviewMode": 2,
    "m_OutputNode": {
        "m_Id": ""
    },
    "m_ActiveTargets": [
        {
            "m_Id": "d911639bce0e4a69a6644e4f61275366"
        }
    ]
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "003b60a2d22d4293bf2e0a895fe7fe59",
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "0113e3fde26f4194940a4edba7ecdf4c",
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
    "m_Type": "UnityEditor.ShaderGraph.SplitNode",
    "m_ObjectId": "0334e1ac8bdd4cafa3404d8fc87d253c",
    "m_Group": {
        "m_Id": "80273af3153e44738adaf387e0fc7239"
    },
    "m_Name": "Split",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -174.5453643798828,
            "y": 630.1090698242188,
            "width": 122.181640625,
            "height": 149.236328125
        }
    },
    "m_Slots": [
        {
            "m_Id": "07ea221724a746ff9dc788d8ef0062ea"
        },
        {
            "m_Id": "6c2bddf4cef2405684b7b675475c9f86"
        },
        {
            "m_Id": "627de1d1199b4a52b497fa76e02fe6b7"
        },
        {
            "m_Id": "7fab0e54a5294eaab75d31e9d2d22b61"
        },
        {
            "m_Id": "a01dd8bab44c42a1a8ea1b9e7f462356"
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
    "m_Type": "UnityEditor.ShaderGraph.UVMaterialSlot",
    "m_ObjectId": "0472edcfffd84f1e8adcb2e36e4ac4d9",
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
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "056b1298ef3a429cbd6230f47cd19769",
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "07e1638db3f44661a26b6dd44d84a980",
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "07ea221724a746ff9dc788d8ef0062ea",
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "080141377e33487f9d39fed811f87e83",
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "0ba24bff6163466a94424392b8b495c3",
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
    "m_ObjectId": "0c3ca5df75e749cc8195189ea9a31601",
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
    "m_Type": "UnityEditor.ShaderGraph.BlockNode",
    "m_ObjectId": "12901b7b66be40eb8b84bc7723e161ec",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "SurfaceDescription.Emission",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": 12.218165397644043,
            "y": 390.9817810058594,
            "width": 199.8545379638672,
            "height": 41.018218994140628
        }
    },
    "m_Slots": [
        {
            "m_Id": "7a16281a74134219ae45d7965d6146e1"
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
    "m_Type": "UnityEditor.ShaderGraph.BlockNode",
    "m_ObjectId": "13042d8a354542e1aae4078647339062",
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
            "m_Id": "efe9cee4e0fd4a6f98abe62ffa0d5e7a"
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
            "x": -368.2908935546875,
            "y": -59.345458984375,
            "width": 133.5273895263672,
            "height": 141.38180541992188
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
    "m_SGVersion": 2,
    "m_Type": "UnityEditor.Rendering.Universal.ShaderGraph.UniversalLitSubTarget",
    "m_ObjectId": "14f8263d9b5e417e909e69860b046683",
    "m_WorkflowMode": 1,
    "m_NormalDropOffSpace": 0,
    "m_ClearCoat": false,
    "m_BlendModePreserveSpecular": true
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.BlockNode",
    "m_ObjectId": "17bfb3aecbb74395831e0e397f38e9e7",
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
            "m_Id": "858916250db847899e399005f6a0ffbd"
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
            "x": -831.708984375,
            "y": -175.41815185546876,
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
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "1c33d89f60bb4298864d07120694f36c",
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
    "m_Type": "UnityEditor.ShaderGraph.RedirectNodeData",
    "m_ObjectId": "1d4cc1b0e20e4af9a83687f0d49b6752",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "Redirect Node",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -2295.272705078125,
            "y": 1166.83642578125,
            "width": 55.8544921875,
            "height": 24.436279296875
        }
    },
    "m_Slots": [
        {
            "m_Id": "a4b8c03253fc400496af9908105041fb"
        },
        {
            "m_Id": "ec57a3b3d9214f0288f9643b9411ac08"
        }
    ],
    "synonyms": [],
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
            "x": -2239.41796875,
            "y": -246.98178100585938,
            "width": 186.763671875,
            "height": 32.290924072265628
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
    "m_Type": "UnityEditor.ShaderGraph.MultiplyNode",
    "m_ObjectId": "20b8071b3402402db6c81e272e22d5f5",
    "m_Group": {
        "m_Id": "80273af3153e44738adaf387e0fc7239"
    },
    "m_Name": "Multiply",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -301.0909118652344,
            "y": 630.1090698242188,
            "width": 132.6545867919922,
            "height": 117.818115234375
        }
    },
    "m_Slots": [
        {
            "m_Id": "07e1638db3f44661a26b6dd44d84a980"
        },
        {
            "m_Id": "9dddd689ede04a19bab66e767498c53f"
        },
        {
            "m_Id": "bfd4ae41d7b9402fae2443d8501f330a"
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
    "m_SGVersion": 3,
    "m_Type": "UnityEditor.ShaderGraph.Internal.ColorShaderProperty",
    "m_ObjectId": "219f3a903fa043dfa4bf465dcb389cf4",
    "m_Guid": {
        "m_GuidSerialized": "65368a2b-f101-4840-942b-c07fe5982a3d"
    },
    "m_Name": "Scanner Glow Color",
    "m_DefaultRefNameVersion": 1,
    "m_RefNameGeneratedByDisplayName": "Scanner Glow Color",
    "m_DefaultReferenceName": "_Scanner_Glow_Color",
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
        "r": 0.0,
        "g": 0.0,
        "b": 0.0,
        "a": 1.0
    },
    "isMainColor": false,
    "m_ColorMode": 0
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
            "x": 13.963617324829102,
            "y": 534.1090087890625,
            "width": 199.8545379638672,
            "height": 40.1455078125
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
    "m_SGVersion": 1,
    "m_Type": "UnityEditor.ShaderGraph.Internal.Vector1ShaderProperty",
    "m_ObjectId": "285c232de00b4ac080f89daf54666812",
    "m_Guid": {
        "m_GuidSerialized": "95f7a05f-8465-4f01-b12a-1d7f8c2be069"
    },
    "m_Name": "Scanner Glow Emission",
    "m_DefaultRefNameVersion": 1,
    "m_RefNameGeneratedByDisplayName": "Scanner Glow Emission",
    "m_DefaultReferenceName": "_Scanner_Glow_Emission",
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
    "m_FloatType": 0,
    "m_RangeValues": {
        "x": 0.0,
        "y": 1.0
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "29a151e4692a4258ad2d8e59db1a0385",
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
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "2af7066b93c64d32bf9e039bb7cef339",
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "2c423af7f7bc4cb6b060abd2b21efc30",
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
    "m_ObjectId": "2c80c490cba04eff9ebec5baf6d356b2",
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
    "m_Type": "UnityEditor.ShaderGraph.Vector4Node",
    "m_ObjectId": "2e0a384889c84b3fabad9cd4921487d7",
    "m_Group": {
        "m_Id": "80273af3153e44738adaf387e0fc7239"
    },
    "m_Name": "Vector 4",
    "m_DrawState": {
        "m_Expanded": false,
        "m_Position": {
            "serializedVersion": "2",
            "x": -496.58172607421877,
            "y": 733.0908203125,
            "width": 133.52725219726563,
            "height": 124.800048828125
        }
    },
    "m_Slots": [
        {
            "m_Id": "fe4a785ea1344ccea596216232b30973"
        },
        {
            "m_Id": "2c80c490cba04eff9ebec5baf6d356b2"
        },
        {
            "m_Id": "003b60a2d22d4293bf2e0a895fe7fe59"
        },
        {
            "m_Id": "1c33d89f60bb4298864d07120694f36c"
        },
        {
            "m_Id": "a6852e83b0344ea1b036e04766755ad6"
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
    "m_Type": "AmazingAssets.DynamicWireframeShaderGenerator.Editor.DynamicMaskNode",
    "m_ObjectId": "32111ad8088744399d405eb222eab7ea",
    "m_Group": {
        "m_Id": "5d1b0a9b79bb4867b867f19fef38c9bb"
    },
    "m_Name": "Dynamic Mask",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -2589.3818359375,
            "y": 13.090855598449707,
            "width": 223.418212890625,
            "height": 153.60003662109376
        }
    },
    "m_Slots": [
        {
            "m_Id": "32dad21eb96240b4957c523d184653f6"
        },
        {
            "m_Id": "64a111953fc843dc9d40959409e138a8"
        },
        {
            "m_Id": "fec881ac7ee1493b92d7a6d2a96b0469"
        },
        {
            "m_Id": "c6f7da26df4f4a6bb9a86d32d7c5643f"
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
    "m_MaskType": 0
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.PositionMaterialSlot",
    "m_ObjectId": "32dad21eb96240b4957c523d184653f6",
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
    "m_Type": "UnityEditor.Rendering.HighDefinition.ShaderGraph.HDUnlitData",
    "m_ObjectId": "340a8f7201bb4a1e9cfdda0cf39ddd5e",
    "m_EnableShadowMatte": false,
    "m_DistortionOnly": false
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.PropertyNode",
    "m_ObjectId": "34cf830a0a7943f0a3dd904707c6cd50",
    "m_Group": {
        "m_Id": "80273af3153e44738adaf387e0fc7239"
    },
    "m_Name": "Property",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -725.2362670898438,
            "y": 592.581787109375,
            "width": 139.63623046875,
            "height": 33.16363525390625
        }
    },
    "m_Slots": [
        {
            "m_Id": "8e2aeff84da648f4a2355b9a1057cc0c"
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
            "x": -601.3091430664063,
            "y": 213.81822204589845,
            "width": 149.23635864257813,
            "height": 32.29087829589844
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "394729e8daec43a7937227dff8fce35f",
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
    "m_Type": "UnityEditor.Rendering.HighDefinition.ShaderGraph.HDUnlitSubTarget",
    "m_ObjectId": "39581a4de0354281aaa86ee401b6cfb4"
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.MultiplyNode",
    "m_ObjectId": "40c4e74cfa634e1ca24c7bafe634a7c6",
    "m_Group": {
        "m_Id": "6c38f7e0dec942979f9c113ee7123d9b"
    },
    "m_Name": "Multiply",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1790.836181640625,
            "y": 329.0181579589844,
            "width": 129.16357421875,
            "height": 117.8182373046875
        }
    },
    "m_Slots": [
        {
            "m_Id": "2c423af7f7bc4cb6b060abd2b21efc30"
        },
        {
            "m_Id": "92922db1c42c4664b85d8d6d41ccd11d"
        },
        {
            "m_Id": "a93f537e62e64e4da4f3395e25b23507"
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
    "m_Type": "UnityEditor.ShaderGraph.MultiplyNode",
    "m_ObjectId": "4382fbf7eea741d8ac9db946ef8e8f35",
    "m_Group": {
        "m_Id": "6c38f7e0dec942979f9c113ee7123d9b"
    },
    "m_Name": "Multiply",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1453.0906982421875,
            "y": 315.0544738769531,
            "width": 132.654541015625,
            "height": 117.8182373046875
        }
    },
    "m_Slots": [
        {
            "m_Id": "4436ca6d837a4117835203e6f040b894"
        },
        {
            "m_Id": "630a9f2b16454fdcba64d2f0d522af19"
        },
        {
            "m_Id": "c31d354c783445378e2e78f60ab5a198"
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
    "m_ObjectId": "44076f74d93b40849f63f74f8e4ba896",
    "m_Id": 0,
    "m_DisplayName": "Scanner Glow Emission",
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "4436ca6d837a4117835203e6f040b894",
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
    "m_Type": "UnityEditor.ShaderGraph.PropertyNode",
    "m_ObjectId": "49afa605221947c696ffbfac306a7f5b",
    "m_Group": {
        "m_Id": "80273af3153e44738adaf387e0fc7239"
    },
    "m_Name": "Property",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -715.6364135742188,
            "y": 798.5453491210938,
            "width": 128.2908935546875,
            "height": 33.16363525390625
        }
    },
    "m_Slots": [
        {
            "m_Id": "e49766cb259a40529a201ebfe1320e8a"
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
        "m_Id": "6177ce1931734f6085eaa0bb2d476648"
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "49dfacebffa44ff1bc72f2481d4d73d8",
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "4d4f5f08f4e3415c8737731424b608cb",
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "4ea520cf05014b5f92154f1cafb7e134",
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "51299f21c5184453a6b97833eaa038b2",
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
    "m_ObjectId": "532cf3f22c20404db4e279b26f19b54d",
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
    "m_Type": "UnityEditor.ShaderGraph.MultiplyNode",
    "m_ObjectId": "55da36dd653c4a869854dc914d0c0772",
    "m_Group": {
        "m_Id": "6c38f7e0dec942979f9c113ee7123d9b"
    },
    "m_Name": "Multiply",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1971.4908447265625,
            "y": 521.0181274414063,
            "width": 129.163818359375,
            "height": 117.8182373046875
        }
    },
    "m_Slots": [
        {
            "m_Id": "0ba24bff6163466a94424392b8b495c3"
        },
        {
            "m_Id": "b03388b8b9bc44e7b99e2138ce6f5c05"
        },
        {
            "m_Id": "d9426b08b62b4307bb475fa207cda26c"
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
    "m_Type": "UnityEditor.ShaderGraph.SampleTexture2DNode",
    "m_ObjectId": "5cb5ecb8bbac4b90b42465076353d1b3",
    "m_Group": {
        "m_Id": "80273af3153e44738adaf387e0fc7239"
    },
    "m_Name": "Sample Texture 2D",
    "m_DrawState": {
        "m_Expanded": false,
        "m_Position": {
            "serializedVersion": "2",
            "x": -547.2000732421875,
            "y": 552.4363403320313,
            "width": 184.14559936523438,
            "height": 155.34539794921876
        }
    },
    "m_Slots": [
        {
            "m_Id": "5cf3daab05e048a19e98b55eb8c5d842"
        },
        {
            "m_Id": "d817e595f12f4066a84a45ab3eebd585"
        },
        {
            "m_Id": "999a33d7656345ec8e45bc9c91d4ec04"
        },
        {
            "m_Id": "d67ec62aa81c4c49b3c58f7cdc976722"
        },
        {
            "m_Id": "0c3ca5df75e749cc8195189ea9a31601"
        },
        {
            "m_Id": "a6a55f0a4a2e48cb8a4c06b40fecf226"
        },
        {
            "m_Id": "0472edcfffd84f1e8adcb2e36e4ac4d9"
        },
        {
            "m_Id": "db0d831e80704cafb92e88a37b59ec75"
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
    "m_Type": "UnityEditor.ShaderGraph.Vector4MaterialSlot",
    "m_ObjectId": "5cf3daab05e048a19e98b55eb8c5d842",
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
    "m_Type": "UnityEditor.ShaderGraph.GroupData",
    "m_ObjectId": "5d1b0a9b79bb4867b867f19fef38c9bb",
    "m_Title": "Dynamic Mask",
    "m_Position": {
        "x": -2917.527099609375,
        "y": -43.636329650878909
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "603e81922e4947908988dbc3a66837c6",
    "m_Id": 0,
    "m_DisplayName": "",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "",
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
    "m_ObjectId": "6177ce1931734f6085eaa0bb2d476648",
    "m_Guid": {
        "m_GuidSerialized": "468a1d44-8571-4c2d-9d1d-67416f1cea2e"
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
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "627de1d1199b4a52b497fa76e02fe6b7",
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "630a9f2b16454fdcba64d2f0d522af19",
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
    "m_Type": "UnityEditor.ShaderGraph.Vector2MaterialSlot",
    "m_ObjectId": "63df42f2ead042c59e8d4c4d1c9b4652",
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
    "m_ObjectId": "64a111953fc843dc9d40959409e138a8",
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
    "m_Type": "UnityEditor.ShaderGraph.CategoryData",
    "m_ObjectId": "65a435a0d253424193b7973c27a3a3a3",
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
            "m_Id": "9a3ab0f3466c4607b74281dbb4adfd0b"
        },
        {
            "m_Id": "69fd77ac7509495bac99aa508901e31f"
        },
        {
            "m_Id": "6177ce1931734f6085eaa0bb2d476648"
        },
        {
            "m_Id": "219f3a903fa043dfa4bf465dcb389cf4"
        },
        {
            "m_Id": "285c232de00b4ac080f89daf54666812"
        }
    ]
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.LerpNode",
    "m_ObjectId": "673aa80ed8444024935140cccdff3aea",
    "m_Group": {
        "m_Id": "6c38f7e0dec942979f9c113ee7123d9b"
    },
    "m_Name": "Lerp",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1028.07275390625,
            "y": 315.0544738769531,
            "width": 132.65460205078126,
            "height": 141.38189697265626
        }
    },
    "m_Slots": [
        {
            "m_Id": "4d4f5f08f4e3415c8737731424b608cb"
        },
        {
            "m_Id": "394729e8daec43a7937227dff8fce35f"
        },
        {
            "m_Id": "f43fe08100904f64929dde231e5a2400"
        },
        {
            "m_Id": "a606d58fdc5f42ae96c8bb5088658882"
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
    "m_SGVersion": 1,
    "m_Type": "UnityEditor.ShaderGraph.Internal.Vector1ShaderProperty",
    "m_ObjectId": "69fd77ac7509495bac99aa508901e31f",
    "m_Guid": {
        "m_GuidSerialized": "334315bb-261c-4af0-a100-248efadc0118"
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
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "6c2bddf4cef2405684b7b675475c9f86",
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
    "m_Type": "UnityEditor.ShaderGraph.GroupData",
    "m_ObjectId": "6c38f7e0dec942979f9c113ee7123d9b",
    "m_Title": "Emission",
    "m_Position": {
        "x": -2241.16357421875,
        "y": 224.29095458984376
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.MultiplyNode",
    "m_ObjectId": "6cfe4d8447ff49c99dd292fb734bd70c",
    "m_Group": {
        "m_Id": "6c38f7e0dec942979f9c113ee7123d9b"
    },
    "m_Name": "Multiply",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1630.25439453125,
            "y": 409.3090515136719,
            "width": 129.1636962890625,
            "height": 117.81820678710938
        }
    },
    "m_Slots": [
        {
            "m_Id": "0113e3fde26f4194940a4edba7ecdf4c"
        },
        {
            "m_Id": "532cf3f22c20404db4e279b26f19b54d"
        },
        {
            "m_Id": "080141377e33487f9d39fed811f87e83"
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
    "m_ObjectId": "6ed91133b35a4558aa69322b4b2e8956",
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "6f6025e0f407414eb39bd5ac60231877",
    "m_Id": 0,
    "m_DisplayName": "",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "",
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
    "m_ObjectId": "705f42eb439348a1b94969586397dfbb",
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
    "m_Type": "AmazingAssets.DynamicWireframeShaderGenerator.Editor.WireframeRendererNode",
    "m_ObjectId": "7094b2718889469d8b1d2d7e9831bf6a",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "Wireframe Renderer",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1977.599609375,
            "y": -281.890869140625,
            "width": 315.92724609375,
            "height": 164.94546508789063
        }
    },
    "m_Slots": [
        {
            "m_Id": "2af7066b93c64d32bf9e039bb7cef339"
        },
        {
            "m_Id": "df5b4d84a42d4752805a2f6af805005b"
        },
        {
            "m_Id": "e0440d1ffe0e4c838421dc8f091e66b4"
        },
        {
            "m_Id": "63df42f2ead042c59e8d4c4d1c9b4652"
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
            "x": -657.16357421875,
            "y": -214.6908721923828,
            "width": 184.14559936523438,
            "height": 155.3454132080078
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
    "m_Type": "UnityEditor.ShaderGraph.PropertyNode",
    "m_ObjectId": "786bc74c310d4091adde84ab0c1d72d6",
    "m_Group": {
        "m_Id": "6c38f7e0dec942979f9c113ee7123d9b"
    },
    "m_Name": "Property",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1995.0543212890625,
            "y": 379.6363525390625,
            "width": 198.1090087890625,
            "height": 33.16363525390625
        }
    },
    "m_Slots": [
        {
            "m_Id": "44076f74d93b40849f63f74f8e4ba896"
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
        "m_Id": "285c232de00b4ac080f89daf54666812"
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.ColorRGBMaterialSlot",
    "m_ObjectId": "7a16281a74134219ae45d7965d6146e1",
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
    "m_ObjectId": "7fab0e54a5294eaab75d31e9d2d22b61",
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
    "m_ObjectId": "80273af3153e44738adaf387e0fc7239",
    "m_Title": "Metallic / Smoothness / Occlusion",
    "m_Position": {
        "x": -753.16357421875,
        "y": 494.8363037109375
    }
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
    "m_Type": "UnityEditor.ShaderGraph.PropertyNode",
    "m_ObjectId": "83bfc61641084bffa14d057e840bc1a4",
    "m_Group": {
        "m_Id": "80273af3153e44738adaf387e0fc7239"
    },
    "m_Name": "Property",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -705.1636962890625,
            "y": 770.6181640625,
            "width": 117.81817626953125,
            "height": 33.16357421875
        }
    },
    "m_Slots": [
        {
            "m_Id": "705f42eb439348a1b94969586397dfbb"
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
        "m_Id": "9a3ab0f3466c4607b74281dbb4adfd0b"
    }
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
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.PositionMaterialSlot",
    "m_ObjectId": "858916250db847899e399005f6a0ffbd",
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
    "m_Type": "UnityEditor.ShaderGraph.BlockNode",
    "m_ObjectId": "86722a7582584325b1881f836abb0852",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "SurfaceDescription.AlphaClipThreshold",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": 1.7454273700714112,
            "y": 588.2180786132813,
            "width": 200.72715759277345,
            "height": 40.1455078125
        }
    },
    "m_Slots": [
        {
            "m_Id": "c740ae79103943d781c59c2d276402e9"
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
    "m_SerializedDescriptor": "SurfaceDescription.AlphaClipThreshold"
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
            "x": -2251.636474609375,
            "y": -198.9818115234375,
            "width": 198.98193359375,
            "height": 32.29093933105469
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
    "m_Type": "UnityEditor.ShaderGraph.Vector4MaterialSlot",
    "m_ObjectId": "8d489e8e6e634ec2a88167c5ac6a3716",
    "m_Id": 0,
    "m_DisplayName": "Scanner Glow Color",
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
    "m_Type": "UnityEditor.ShaderGraph.Texture2DMaterialSlot",
    "m_ObjectId": "8e2aeff84da648f4a2355b9a1057cc0c",
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
    "m_Type": "UnityEditor.ShaderGraph.BlockNode",
    "m_ObjectId": "8e5d6d22aa854f9eb7ad09c4e189d002",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "SurfaceDescription.Alpha",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": 14.836264610290528,
            "y": 542.8363647460938,
            "width": 199.85447692871095,
            "height": 40.14544677734375
        }
    },
    "m_Slots": [
        {
            "m_Id": "29a151e4692a4258ad2d8e59db1a0385"
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "92922db1c42c4664b85d8d6d41ccd11d",
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
    "m_Name": "WireframeShaderMaskData",
    "m_DefaultRefNameVersion": 1,
    "m_RefNameGeneratedByDisplayName": "WireframeShaderMaskData",
    "m_DefaultReferenceName": "_WireframeShaderMaskData",
    "m_OverrideReferenceName": "",
    "m_GeneratePropertyBlock": false,
    "m_UseCustomSlotLabel": false,
    "m_CustomSlotLabel": "",
    "m_DismissedVersion": 0,
    "m_Precision": 0,
    "overrideHLSLDeclaration": true,
    "hlslDeclarationOverride": 2,
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
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "999a33d7656345ec8e45bc9c91d4ec04",
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
    "m_ObjectId": "9a3ab0f3466c4607b74281dbb4adfd0b",
    "m_Guid": {
        "m_GuidSerialized": "f0d161da-6edb-4143-8da9-5d8865e5d053"
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "9b24437a87c54e229f596c2b4908ac45",
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "9dddd689ede04a19bab66e767498c53f",
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
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "a01dd8bab44c42a1a8ea1b9e7f462356",
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
    "m_Type": "UnityEditor.ShaderGraph.PropertyNode",
    "m_ObjectId": "a3b68a3e755144ee84377e58075facb1",
    "m_Group": {
        "m_Id": "80273af3153e44738adaf387e0fc7239"
    },
    "m_Name": "Property",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -728.7271118164063,
            "y": 848.2908935546875,
            "width": 141.381591796875,
            "height": 33.16363525390625
        }
    },
    "m_Slots": [
        {
            "m_Id": "056b1298ef3a429cbd6230f47cd19769"
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
        "m_Id": "69fd77ac7509495bac99aa508901e31f"
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.OneMinusNode",
    "m_ObjectId": "a4821fb7622e45819daa3b83ed31f32f",
    "m_Group": {
        "m_Id": "6c38f7e0dec942979f9c113ee7123d9b"
    },
    "m_Name": "One Minus",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -2134.69091796875,
            "y": 638.8363647460938,
            "width": 130.9091796875,
            "height": 93.3817138671875
        }
    },
    "m_Slots": [
        {
            "m_Id": "efa26c97cee4458dbcbd3ad66d4a4435"
        },
        {
            "m_Id": "51299f21c5184453a6b97833eaa038b2"
        }
    ],
    "synonyms": [
        "complement",
        "invert",
        "opposite"
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "a4b8c03253fc400496af9908105041fb",
    "m_Id": 0,
    "m_DisplayName": "",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "",
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
    "m_Type": "UnityEditor.ShaderGraph.TangentMaterialSlot",
    "m_ObjectId": "a4d4c2c807c44634910997e916e30a1a",
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "a606d58fdc5f42ae96c8bb5088658882",
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
    "m_Type": "UnityEditor.ShaderGraph.Vector4MaterialSlot",
    "m_ObjectId": "a6852e83b0344ea1b036e04766755ad6",
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
    "m_Type": "UnityEditor.ShaderGraph.Texture2DInputMaterialSlot",
    "m_ObjectId": "a6a55f0a4a2e48cb8a4c06b40fecf226",
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "a93f537e62e64e4da4f3395e25b23507",
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
    "m_Type": "UnityEditor.ShaderGraph.MultiplyNode",
    "m_ObjectId": "a98dec7346c143bca3285adc673e52bd",
    "m_Group": {
        "m_Id": "6c38f7e0dec942979f9c113ee7123d9b"
    },
    "m_Name": "Multiply",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1790.836181640625,
            "y": 510.5455017089844,
            "width": 129.16357421875,
            "height": 117.81814575195313
        }
    },
    "m_Slots": [
        {
            "m_Id": "c8d705089bf248de81bae4017a7000ea"
        },
        {
            "m_Id": "6ed91133b35a4558aa69322b4b2e8956"
        },
        {
            "m_Id": "9b24437a87c54e229f596c2b4908ac45"
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
    "m_ObjectId": "b03388b8b9bc44e7b99e2138ce6f5c05",
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
    "m_Type": "UnityEditor.ShaderGraph.MultiplyNode",
    "m_ObjectId": "b0960d3afcdd41aca8cb2c6f7dc0bb74",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "Multiply",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1551.7088623046875,
            "y": -10.472734451293946,
            "width": 129.1636962890625,
            "height": 116.94541931152344
        }
    },
    "m_Slots": [
        {
            "m_Id": "49dfacebffa44ff1bc72f2481d4d73d8"
        },
        {
            "m_Id": "4ea520cf05014b5f92154f1cafb7e134"
        },
        {
            "m_Id": "cab4ac2533074b9bbff4bbeddeea4e4a"
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
    "m_Type": "UnityEditor.ShaderGraph.PropertyNode",
    "m_ObjectId": "bdb9446ca60e4334aaf2d68ef022f6df",
    "m_Group": {
        "m_Id": "6c38f7e0dec942979f9c113ee7123d9b"
    },
    "m_Name": "Property",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1637.2362060546875,
            "y": 281.89093017578127,
            "width": 182.39990234375,
            "height": 33.163543701171878
        }
    },
    "m_Slots": [
        {
            "m_Id": "8d489e8e6e634ec2a88167c5ac6a3716"
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
        "m_Id": "219f3a903fa043dfa4bf465dcb389cf4"
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "bfd4ae41d7b9402fae2443d8501f330a",
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
    "m_Type": "UnityEditor.ShaderGraph.PropertyNode",
    "m_ObjectId": "c2fcbed1c8b9408fb9e6665d295dd052",
    "m_Group": {
        "m_Id": "5d1b0a9b79bb4867b867f19fef38c9bb"
    },
    "m_Name": "Property",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -2893.090576171875,
            "y": 57.59999084472656,
            "width": 224.290771484375,
            "height": 32.29090881347656
        }
    },
    "m_Slots": [
        {
            "m_Id": "d6f3df2ff0de43019f419dea0f6c1344"
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "c31d354c783445378e2e78f60ab5a198",
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
    "m_ObjectId": "c5c556ca694041739e384dac07bba5ff",
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
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "c6f7da26df4f4a6bb9a86d32d7c5643f",
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
    "m_ObjectId": "c740ae79103943d781c59c2d276402e9",
    "m_Id": 0,
    "m_DisplayName": "Alpha Clip Threshold",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "AlphaClipThreshold",
    "m_StageCapability": 2,
    "m_Value": 0.009999999776482582,
    "m_DefaultValue": 0.5,
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "c8d705089bf248de81bae4017a7000ea",
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
    "m_Type": "UnityEditor.ShaderGraph.ColorRGBMaterialSlot",
    "m_ObjectId": "c98dfd4263374782ac4f99dc8866b3e9",
    "m_Id": 0,
    "m_DisplayName": "Base Color",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "BaseColor",
    "m_StageCapability": 2,
    "m_Value": {
        "x": 1.0,
        "y": 1.0,
        "z": 1.0
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
    "m_ObjectId": "cab4ac2533074b9bbff4bbeddeea4e4a",
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
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "d67ec62aa81c4c49b3c58f7cdc976722",
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
    "m_Type": "UnityEditor.ShaderGraph.Matrix4MaterialSlot",
    "m_ObjectId": "d6f3df2ff0de43019f419dea0f6c1344",
    "m_Id": 0,
    "m_DisplayName": "WireframeShaderMaskData",
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
    "m_ObjectId": "d817e595f12f4066a84a45ab3eebd585",
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
    "m_Type": "UnityEditor.Rendering.Universal.ShaderGraph.UniversalTarget",
    "m_ObjectId": "d911639bce0e4a69a6644e4f61275366",
    "m_Datas": [],
    "m_ActiveSubTarget": {
        "m_Id": "14f8263d9b5e417e909e69860b046683"
    },
    "m_AllowMaterialOverride": false,
    "m_SurfaceType": 0,
    "m_ZTestMode": 4,
    "m_ZWriteControl": 0,
    "m_AlphaMode": 0,
    "m_RenderFace": 2,
    "m_AlphaClip": true,
    "m_CastShadows": true,
    "m_ReceiveShadows": true,
    "m_SupportsLODCrossFade": false,
    "m_CustomEditorGUI": "",
    "m_SupportVFX": false
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "d9426b08b62b4307bb475fa207cda26c",
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
    "m_Type": "UnityEditor.ShaderGraph.SamplerStateMaterialSlot",
    "m_ObjectId": "db0d831e80704cafb92e88a37b59ec75",
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
    "m_Type": "UnityEditor.ShaderGraph.RedirectNodeData",
    "m_ObjectId": "dbaca9971ef44eb8bec8bf86378f95b5",
    "m_Group": {
        "m_Id": "6c38f7e0dec942979f9c113ee7123d9b"
    },
    "m_Name": "Redirect Node",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -2216.727294921875,
            "y": 567.272705078125,
            "width": 55.8544921875,
            "height": 24.4364013671875
        }
    },
    "m_Slots": [
        {
            "m_Id": "6f6025e0f407414eb39bd5ac60231877"
        },
        {
            "m_Id": "fbd91e3fcc8e48298ea4769e16834775"
        }
    ],
    "synonyms": [],
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
    "m_Type": "UnityEditor.ShaderGraph.CategoryData",
    "m_ObjectId": "dd6fcdf0141b461d9ce07ca51467b3c4",
    "m_Name": "",
    "m_ChildObjectList": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "df5b4d84a42d4752805a2f6af805005b",
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
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "e0440d1ffe0e4c838421dc8f091e66b4",
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
    "m_Type": "UnityEditor.Rendering.HighDefinition.ShaderGraph.HDLitSubTarget",
    "m_ObjectId": "e4335c2878f04db5af0adb530304d760"
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "e49766cb259a40529a201ebfe1320e8a",
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
    "m_Type": "UnityEditor.ShaderGraph.RedirectNodeData",
    "m_ObjectId": "e785a6b7e06c4b27a910d0533499d4ae",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "Redirect Node",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": 152.7271270751953,
            "y": 1154.6181640625,
            "width": 55.854583740234378,
            "height": 24.4365234375
        }
    },
    "m_Slots": [
        {
            "m_Id": "603e81922e4947908988dbc3a66837c6"
        },
        {
            "m_Id": "f9caa0c5206c4a3e8bc2a460d43f267f"
        }
    ],
    "synonyms": [],
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
    "m_Type": "UnityEditor.ShaderGraph.BlockNode",
    "m_ObjectId": "e8edb428dc364aaab9a86f55a6e50ea1",
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
            "m_Id": "a4d4c2c807c44634910997e916e30a1a"
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "ec57a3b3d9214f0288f9643b9411ac08",
    "m_Id": 1,
    "m_DisplayName": "",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "",
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
            "x": -419.7818908691406,
            "y": 173.6726837158203,
            "width": 184.14541625976563,
            "height": 155.34547424316407
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "efa26c97cee4458dbcbd3ad66d4a4435",
    "m_Id": 0,
    "m_DisplayName": "In",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "In",
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
    "m_Type": "UnityEditor.ShaderGraph.NormalMaterialSlot",
    "m_ObjectId": "efe9cee4e0fd4a6f98abe62ffa0d5e7a",
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "f43fe08100904f64929dde231e5a2400",
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
    "m_Type": "UnityEditor.ShaderGraph.CategoryData",
    "m_ObjectId": "f711fc5b9a8543eea5c82e070f7f1bb7",
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
            "m_Id": "937f028802f64a58a20c076445e50f2e"
        }
    ]
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
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.PropertyNode",
    "m_ObjectId": "f8bc404cb1f0474081562f509e25130e",
    "m_Group": {
        "m_Id": "6c38f7e0dec942979f9c113ee7123d9b"
    },
    "m_Name": "Property",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1279.4180908203125,
            "y": 388.3635559082031,
            "width": 164.0728759765625,
            "height": 33.16363525390625
        }
    },
    "m_Slots": [
        {
            "m_Id": "c5c556ca694041739e384dac07bba5ff"
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "f9caa0c5206c4a3e8bc2a460d43f267f",
    "m_Id": 1,
    "m_DisplayName": "",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "",
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "fbd91e3fcc8e48298ea4769e16834775",
    "m_Id": 1,
    "m_DisplayName": "",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "",
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
    "m_ObjectId": "fe4a785ea1344ccea596216232b30973",
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
            "x": -636.21826171875,
            "y": 4.363637447357178,
            "width": 164.07284545898438,
            "height": 32.29090118408203
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

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "fec881ac7ee1493b92d7a6d2a96b0469",
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


ShaderGraphBody_End*/

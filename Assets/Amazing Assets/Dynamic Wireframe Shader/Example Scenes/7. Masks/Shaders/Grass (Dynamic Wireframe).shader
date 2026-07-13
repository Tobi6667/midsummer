// Dynamic Wireframe Shader <https://u3d.as/3WyY>
// Copyright (c) Amazing Assets <https://amazingassets.world>

Shader "Amazing Assets/Dynamic Wireframe Shader/Examples/Masks/Grass (Dynamic Wireframe)"
{
Properties
{
[KeywordEnum(Triangle, Quad)] _Wireframe_Shader_Shape("Wireframe Shape", int) = 0
[KeywordEnum(Default, Normalized, Screen Space)] _Wireframe_Shader_Style("Wireframe Style", int) = 0

_Wireframe_Thickness("Wireframe Thickness", Range(0, 1)) = 0.01
_Wireframe_Anti_aliasing("Wireframe Anti-aliasing", Range(0, 1)) = 0.2
_Blade_Color_1("Blade Color #1", Color) = (0.2353632, 0.5283019, 0.06728373, 1)
_Blade_Color_2("Blade Color #2", Color) = (0.46308, 0.7169812, 0.09131365, 1)
_Metallic("Metallic", Range(0, 1)) = 0
_Smoothness("Smoothness", Range(0, 1)) = 0
_Wind_Speed("Wind Speed", Float) = 1
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
AlphaToMask On

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM

// Pragmas
#pragma target 2.0
#pragma multi_compile_instancing
#pragma multi_compile_fog
#pragma instancing_options renderinglayer
#pragma vertex vert
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
#define ATTRIBUTES_NEED_TEXCOORD1
#define ATTRIBUTES_NEED_TEXCOORD2
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define VARYINGS_NEED_TANGENT_WS
#define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
#define VARYINGS_NEED_SHADOW_COORD
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_FORWARD
#define _FOG_FRAGMENT 1
#define _ALPHATEST_ON 1
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
 float4 uv1 : TEXCOORD1;
 float4 uv2 : TEXCOORD2;
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
 float4 Color;
};
struct SurfaceDescriptionInputs
{
 float3 TangentSpaceNormal;
 float3 WorldSpacePosition;
 float4 Color;
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
 float3 WorldSpacePosition;
 float3 TimeParameters;
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
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
 float4 shadowCoord : INTERP3;
#endif
 float4 tangentWS : INTERP4;
 float4 fogFactorAndVertexLight : INTERP5;
 float4 Color : INTERP6;
 float3 positionWS : INTERP7;
 float3 normalWS : INTERP8;
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
output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
output.Color.xyzw = input.Color;
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
output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
output.Color = input.Color.xyzw;
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
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)
float _Wireframe_Thickness;
float _Wireframe_Anti_aliasing;
float4 _Blade_Color_2;
float4 _Blade_Color_1;
float _Metallic;
float _Smoothness;
float _Wind_Speed;
CBUFFER_END


// Object and Global properties
float4x4 _WireframeShaderMaskData1;
float4x4 _WireframeShaderMaskData2;

// Graph Includes
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"

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

void UnityGetInstanceID_float(out float Out)
{
#if UNITY_ANY_INSTANCING_ENABLED
    Out = unity_InstanceID;
#else
    Out = 0;
#endif
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Fraction_float(float In, out float Out)
{
    Out = frac(In);
}

void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
{
    Out = lerp(A, B, T);
}

void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
{
Out = A * B;
}

void Unity_Fraction_float3(float3 In, out float3 Out)
{
    Out = frac(In);
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Multiply_float_float(float A, float B, out float Out)
{
Out = A * B;
}

void Unity_Sine_float(float In, out float Out)
{
    Out = sin(In);
}

void Unity_DegreesToRadians_float(float In, out float Out)
{
    Out = radians(In);
}

void Unity_Rotate_Radians_float(float2 UV, float2 Center, float Rotation, out float2 Out)
{
    //rotation matrix
    UV -= Center;
    float s = sin(Rotation);
    float c = cos(Rotation);

    //center rotation matrix
    float2x2 rMatrix = float2x2(c, -s, s, c);
    rMatrix *= 0.5;
    rMatrix += 0.5;
    rMatrix = rMatrix*2 - 1;

    //multiply the UVs by the rotation matrix
    UV.xy = mul(UV.xy, rMatrix);
    UV += Center;

    Out = UV;
}

void Unity_Cosine_float(float In, out float Out)
{
    Out = cos(In);
}

void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
{
    RGBA = float4(R, G, B, A);
    RGB = float3(R, G, B);
    RG = float2(R, G);
}

void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
{
Out = A * B;
}

void Unity_DotProduct_float2(float2 A, float2 B, out float Out)
{
    Out = dot(A, B);
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
    Out = A + B;
}

void Unity_Negate_float(float In, out float Out)
{
    Out = -1 * In;
}

float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
{
float x; Hash_Tchou_2_1_float(p, x);
return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
{
float2 p = UV * Scale.xy;
float2 ip = floor(p);
float2 fp = frac(p);
float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
    Out = smoothstep(Edge1, Edge2, In);
}

void Unity_Saturate_float(float In, out float Out)
{
    Out = saturate(In);
}

void Unity_Lerp_float2(float2 A, float2 B, float2 T, out float2 Out)
{
    Out = lerp(A, B, T);
}

void Unity_SquareRoot_float(float In, out float Out)
{
    Out = sqrt(In);
}

void Unity_Maximum_float(float A, float B, out float Out)
{
    Out = max(A, B);
}

void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
{
    Out = A / B;
}

void Unity_Lerp_float(float A, float B, float T, out float Out)
{
    Out = lerp(A, B, T);
}

struct Bindings_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float
{
float3 TimeParameters;
};

void SG_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float(float _WindDirection, float _WindSpeed, float _WindDirectionVariation, float _PerBladeRandomTimeOffset, float _PerBladeWindIntensityVariation, float _WindIntensity, Bindings_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float IN, out float2 WindDirection_1, out float WindIntensity_2, out float3 Random_3)
{
float2 _Vector2_42921bc8d43346a4bbad7aa650d15962_Out_0_Vector2 = float2(1, 0);
float3 _Multiply_b6ed4cc094134c21943e217e6e271dae_Out_2_Vector3;
Unity_Multiply_float3_float3(SHADERGRAPH_OBJECT_POSITION, float3(37, 190, 29), _Multiply_b6ed4cc094134c21943e217e6e271dae_Out_2_Vector3);
float3 _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3;
Unity_Fraction_float3(_Multiply_b6ed4cc094134c21943e217e6e271dae_Out_2_Vector3, _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3);
float _Split_3967427c51c24bb79cef645976364a55_R_1_Float = _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3[0];
float _Split_3967427c51c24bb79cef645976364a55_G_2_Float = _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3[1];
float _Split_3967427c51c24bb79cef645976364a55_B_3_Float = _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3[2];
float _Split_3967427c51c24bb79cef645976364a55_A_4_Float = 0;
float _Add_ffd28ed6ff854810bd439fbdfc4b2cc2_Out_2_Float;
Unity_Add_float(IN.TimeParameters.x, _Split_3967427c51c24bb79cef645976364a55_B_3_Float, _Add_ffd28ed6ff854810bd439fbdfc4b2cc2_Out_2_Float);
float _Multiply_1185303c6c5d481190d5375ac379cab8_Out_2_Float;
Unity_Multiply_float_float(_Add_ffd28ed6ff854810bd439fbdfc4b2cc2_Out_2_Float, 3, _Multiply_1185303c6c5d481190d5375ac379cab8_Out_2_Float);
float _Sine_c919089f2f34401face2dd9897c9725c_Out_1_Float;
Unity_Sine_float(_Multiply_1185303c6c5d481190d5375ac379cab8_Out_2_Float, _Sine_c919089f2f34401face2dd9897c9725c_Out_1_Float);
float _Property_40290747561641a1bdf5517e6a93430d_Out_0_Float = _WindDirectionVariation;
float _DegreesToRadians_a7fe82a177484cd0af99b4027bc4e3bc_Out_1_Float;
Unity_DegreesToRadians_float(_Property_40290747561641a1bdf5517e6a93430d_Out_0_Float, _DegreesToRadians_a7fe82a177484cd0af99b4027bc4e3bc_Out_1_Float);
float _Multiply_c6dbf243e66746b490b03900b2b27467_Out_2_Float;
Unity_Multiply_float_float(_Sine_c919089f2f34401face2dd9897c9725c_Out_1_Float, _DegreesToRadians_a7fe82a177484cd0af99b4027bc4e3bc_Out_1_Float, _Multiply_c6dbf243e66746b490b03900b2b27467_Out_2_Float);
float2 _Rotate_cf73d535c5fb437aa68912dc0e09ba2f_Out_3_Vector2;
Unity_Rotate_Radians_float(_Vector2_42921bc8d43346a4bbad7aa650d15962_Out_0_Vector2, float2 (0, 0), _Multiply_c6dbf243e66746b490b03900b2b27467_Out_2_Float, _Rotate_cf73d535c5fb437aa68912dc0e09ba2f_Out_3_Vector2);
float _Property_df02aaa16377442d91f0c6be7d036d51_Out_0_Float = _WindDirection;
float _DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float;
Unity_DegreesToRadians_float(_Property_df02aaa16377442d91f0c6be7d036d51_Out_0_Float, _DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float);
float _Add_b051e3fa11c048dd978791daff07720d_Out_2_Float;
Unity_Add_float(_Multiply_c6dbf243e66746b490b03900b2b27467_Out_2_Float, _DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float, _Add_b051e3fa11c048dd978791daff07720d_Out_2_Float);
float _Cosine_0847069386bc4c12a90e1fe3eb1eee73_Out_1_Float;
Unity_Cosine_float(_Add_b051e3fa11c048dd978791daff07720d_Out_2_Float, _Cosine_0847069386bc4c12a90e1fe3eb1eee73_Out_1_Float);
float _Sine_379c87a4cd3c419293869dee73c52de0_Out_1_Float;
Unity_Sine_float(_Add_b051e3fa11c048dd978791daff07720d_Out_2_Float, _Sine_379c87a4cd3c419293869dee73c52de0_Out_1_Float);
float4 _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RGBA_4_Vector4;
float3 _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RGB_5_Vector3;
float2 _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RG_6_Vector2;
Unity_Combine_float(_Cosine_0847069386bc4c12a90e1fe3eb1eee73_Out_1_Float, _Sine_379c87a4cd3c419293869dee73c52de0_Out_1_Float, 0, 0, _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RGBA_4_Vector4, _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RGB_5_Vector3, _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RG_6_Vector2);
float2 _Swizzle_db678fc97ec448fda50408084410c787_Out_1_Vector2 = SHADERGRAPH_OBJECT_POSITION.xz;
float2 _Multiply_5833218c1a7c4d9586d5e8c69ddaabac_Out_2_Vector2;
Unity_Multiply_float2_float2(_Swizzle_db678fc97ec448fda50408084410c787_Out_1_Vector2, float2(0.5, 0.5), _Multiply_5833218c1a7c4d9586d5e8c69ddaabac_Out_2_Vector2);
float _Cosine_3388e8245f6647ca98f5aa9339130c65_Out_1_Float;
Unity_Cosine_float(_DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float, _Cosine_3388e8245f6647ca98f5aa9339130c65_Out_1_Float);
float _Sine_0b39f9f73b2c4016a046ad8da4b84c11_Out_1_Float;
Unity_Sine_float(_DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float, _Sine_0b39f9f73b2c4016a046ad8da4b84c11_Out_1_Float);
float4 _Combine_7f78efe98e4641c1981d47da9bbbe70f_RGBA_4_Vector4;
float3 _Combine_7f78efe98e4641c1981d47da9bbbe70f_RGB_5_Vector3;
float2 _Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2;
Unity_Combine_float(_Cosine_3388e8245f6647ca98f5aa9339130c65_Out_1_Float, _Sine_0b39f9f73b2c4016a046ad8da4b84c11_Out_1_Float, 0, 0, _Combine_7f78efe98e4641c1981d47da9bbbe70f_RGBA_4_Vector4, _Combine_7f78efe98e4641c1981d47da9bbbe70f_RGB_5_Vector3, _Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2);
float _DotProduct_27327ffeb11d404c96d6820c42272ca8_Out_2_Float;
Unity_DotProduct_float2(_Multiply_5833218c1a7c4d9586d5e8c69ddaabac_Out_2_Vector2, _Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2, _DotProduct_27327ffeb11d404c96d6820c42272ca8_Out_2_Float);
float _Multiply_8dc73d49a3b547a19bf5c0d8a4a09920_Out_2_Float;
Unity_Multiply_float_float(_DotProduct_27327ffeb11d404c96d6820c42272ca8_Out_2_Float, 0.7, _Multiply_8dc73d49a3b547a19bf5c0d8a4a09920_Out_2_Float);
float2 _Multiply_c8e01038fa74488a86a9759343a555f5_Out_2_Vector2;
Unity_Multiply_float2_float2((_Multiply_8dc73d49a3b547a19bf5c0d8a4a09920_Out_2_Float.xx), _Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2, _Multiply_c8e01038fa74488a86a9759343a555f5_Out_2_Vector2);
float _Multiply_69e2c5b6e72c4faf8d83ead16a5c0cd6_Out_2_Float;
Unity_Multiply_float_float(_Cosine_3388e8245f6647ca98f5aa9339130c65_Out_1_Float, -1.5708, _Multiply_69e2c5b6e72c4faf8d83ead16a5c0cd6_Out_2_Float);
float4 _Combine_2f7388d585a24290a659f20482d78d94_RGBA_4_Vector4;
float3 _Combine_2f7388d585a24290a659f20482d78d94_RGB_5_Vector3;
float2 _Combine_2f7388d585a24290a659f20482d78d94_RG_6_Vector2;
Unity_Combine_float(_Sine_0b39f9f73b2c4016a046ad8da4b84c11_Out_1_Float, _Multiply_69e2c5b6e72c4faf8d83ead16a5c0cd6_Out_2_Float, 0, 0, _Combine_2f7388d585a24290a659f20482d78d94_RGBA_4_Vector4, _Combine_2f7388d585a24290a659f20482d78d94_RGB_5_Vector3, _Combine_2f7388d585a24290a659f20482d78d94_RG_6_Vector2);
float _DotProduct_e3247c7835f0404893730bc5dcd240a0_Out_2_Float;
Unity_DotProduct_float2(_Multiply_5833218c1a7c4d9586d5e8c69ddaabac_Out_2_Vector2, _Combine_2f7388d585a24290a659f20482d78d94_RG_6_Vector2, _DotProduct_e3247c7835f0404893730bc5dcd240a0_Out_2_Float);
float2 _Multiply_ed7373e7bd6347f89e44dacc83ccf8c1_Out_2_Vector2;
Unity_Multiply_float2_float2((_DotProduct_e3247c7835f0404893730bc5dcd240a0_Out_2_Float.xx), _Combine_2f7388d585a24290a659f20482d78d94_RG_6_Vector2, _Multiply_ed7373e7bd6347f89e44dacc83ccf8c1_Out_2_Vector2);
float2 _Add_f950bfd74ec2464b89d972d5f43aa5b7_Out_2_Vector2;
Unity_Add_float2(_Multiply_c8e01038fa74488a86a9759343a555f5_Out_2_Vector2, _Multiply_ed7373e7bd6347f89e44dacc83ccf8c1_Out_2_Vector2, _Add_f950bfd74ec2464b89d972d5f43aa5b7_Out_2_Vector2);
float _Property_8c38f0ae55594c8787ad0a52af13731b_Out_0_Float = _WindSpeed;
float _Negate_47564bc9ce9645a5916ebc05fb9d63df_Out_1_Float;
Unity_Negate_float(_Property_8c38f0ae55594c8787ad0a52af13731b_Out_0_Float, _Negate_47564bc9ce9645a5916ebc05fb9d63df_Out_1_Float);
float _Multiply_e311852a737c422594c328d00e16414c_Out_2_Float;
Unity_Multiply_float_float(IN.TimeParameters.x, _Negate_47564bc9ce9645a5916ebc05fb9d63df_Out_1_Float, _Multiply_e311852a737c422594c328d00e16414c_Out_2_Float);
float _Property_347528760e804b2ab165732f176f3e97_Out_0_Float = _PerBladeRandomTimeOffset;
float _Multiply_0657e69a5c9b4cb783a0d4021b58a9b1_Out_2_Float;
Unity_Multiply_float_float(_Split_3967427c51c24bb79cef645976364a55_R_1_Float, _Property_347528760e804b2ab165732f176f3e97_Out_0_Float, _Multiply_0657e69a5c9b4cb783a0d4021b58a9b1_Out_2_Float);
float _Add_8e1a8d342102407f97ee7c7b88271e7d_Out_2_Float;
Unity_Add_float(_Multiply_e311852a737c422594c328d00e16414c_Out_2_Float, _Multiply_0657e69a5c9b4cb783a0d4021b58a9b1_Out_2_Float, _Add_8e1a8d342102407f97ee7c7b88271e7d_Out_2_Float);
float2 _Multiply_e39ee6e978424683b1858114ff959110_Out_2_Vector2;
Unity_Multiply_float2_float2(_Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2, (_Add_8e1a8d342102407f97ee7c7b88271e7d_Out_2_Float.xx), _Multiply_e39ee6e978424683b1858114ff959110_Out_2_Vector2);
float2 _Add_302cec4f55d64a65bf1160e9d23f9b71_Out_2_Vector2;
Unity_Add_float2(_Add_f950bfd74ec2464b89d972d5f43aa5b7_Out_2_Vector2, _Multiply_e39ee6e978424683b1858114ff959110_Out_2_Vector2, _Add_302cec4f55d64a65bf1160e9d23f9b71_Out_2_Vector2);
float _GradientNoise_f0d0f1452f814e03824cb2ceb16d6ad2_Out_2_Float;
Unity_GradientNoise_Deterministic_float(_Add_302cec4f55d64a65bf1160e9d23f9b71_Out_2_Vector2, 0.8, _GradientNoise_f0d0f1452f814e03824cb2ceb16d6ad2_Out_2_Float);
float _Smoothstep_4ca6b3a56ada4447bcfcabe8e1a6ee2b_Out_3_Float;
Unity_Smoothstep_float(-0.5, 1.5, _GradientNoise_f0d0f1452f814e03824cb2ceb16d6ad2_Out_2_Float, _Smoothstep_4ca6b3a56ada4447bcfcabe8e1a6ee2b_Out_3_Float);
float _Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float;
Unity_Saturate_float(_Smoothstep_4ca6b3a56ada4447bcfcabe8e1a6ee2b_Out_3_Float, _Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float);
float2 _Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2;
Unity_Lerp_float2(_Rotate_cf73d535c5fb437aa68912dc0e09ba2f_Out_3_Vector2, _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RG_6_Vector2, (_Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float.xx), _Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2);
float _DotProduct_b6d4ff1e79f54760a1f13bc5172c426b_Out_2_Float;
Unity_DotProduct_float2(_Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2, _Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2, _DotProduct_b6d4ff1e79f54760a1f13bc5172c426b_Out_2_Float);
float _SquareRoot_ec802f46201b45ac867b479ae083b1ee_Out_1_Float;
Unity_SquareRoot_float(_DotProduct_b6d4ff1e79f54760a1f13bc5172c426b_Out_2_Float, _SquareRoot_ec802f46201b45ac867b479ae083b1ee_Out_1_Float);
float _Maximum_56d7bd23f19a4866b35324380205c891_Out_2_Float;
Unity_Maximum_float(_SquareRoot_ec802f46201b45ac867b479ae083b1ee_Out_1_Float, 1E-05, _Maximum_56d7bd23f19a4866b35324380205c891_Out_2_Float);
float2 _Divide_bfbaafc2be014557bf2a163156a11a26_Out_2_Vector2;
Unity_Divide_float2(_Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2, (_Maximum_56d7bd23f19a4866b35324380205c891_Out_2_Float.xx), _Divide_bfbaafc2be014557bf2a163156a11a26_Out_2_Vector2);
float _Property_f1f58df30464478cb038a178d9e83682_Out_0_Float = _WindIntensity;
float _Add_ed2907c2a73440cc83d0b31366c5c7ae_Out_2_Float;
Unity_Add_float(IN.TimeParameters.x, _Split_3967427c51c24bb79cef645976364a55_B_3_Float, _Add_ed2907c2a73440cc83d0b31366c5c7ae_Out_2_Float);
float _Multiply_f0258532eb174f5393420713f84f6c8e_Out_2_Float;
Unity_Multiply_float_float(_Add_ed2907c2a73440cc83d0b31366c5c7ae_Out_2_Float, 2, _Multiply_f0258532eb174f5393420713f84f6c8e_Out_2_Float);
float _Sine_17bbe1505e754bbd9eedc59d0757132f_Out_1_Float;
Unity_Sine_float(_Multiply_f0258532eb174f5393420713f84f6c8e_Out_2_Float, _Sine_17bbe1505e754bbd9eedc59d0757132f_Out_1_Float);
float _Multiply_bfdbccbbf3584e1eb7d34b97e3a771c5_Out_2_Float;
Unity_Multiply_float_float(_Add_ed2907c2a73440cc83d0b31366c5c7ae_Out_2_Float, 3, _Multiply_bfdbccbbf3584e1eb7d34b97e3a771c5_Out_2_Float);
float _Sine_775bcfb1287e450094240576942d7a07_Out_1_Float;
Unity_Sine_float(_Multiply_bfdbccbbf3584e1eb7d34b97e3a771c5_Out_2_Float, _Sine_775bcfb1287e450094240576942d7a07_Out_1_Float);
float _Lerp_3cef0baddeb24a408278d7e18640ec45_Out_3_Float;
Unity_Lerp_float(_Sine_17bbe1505e754bbd9eedc59d0757132f_Out_1_Float, _Sine_775bcfb1287e450094240576942d7a07_Out_1_Float, _Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float, _Lerp_3cef0baddeb24a408278d7e18640ec45_Out_3_Float);
float _Property_59edf586db864b7a9b70a1acca2de692_Out_0_Float = _PerBladeWindIntensityVariation;
float _Multiply_13aa0e7d9b29467fa9ca1e4db82d023c_Out_2_Float;
Unity_Multiply_float_float(_Lerp_3cef0baddeb24a408278d7e18640ec45_Out_3_Float, _Property_59edf586db864b7a9b70a1acca2de692_Out_0_Float, _Multiply_13aa0e7d9b29467fa9ca1e4db82d023c_Out_2_Float);
float _Add_5a191ec83e8345689f15b7e3b2da0e21_Out_2_Float;
Unity_Add_float(_Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float, _Multiply_13aa0e7d9b29467fa9ca1e4db82d023c_Out_2_Float, _Add_5a191ec83e8345689f15b7e3b2da0e21_Out_2_Float);
float _Lerp_fb2e17ff05c44b1b8daaa248df6af035_Out_3_Float;
Unity_Lerp_float(0, _Property_f1f58df30464478cb038a178d9e83682_Out_0_Float, _Add_5a191ec83e8345689f15b7e3b2da0e21_Out_2_Float, _Lerp_fb2e17ff05c44b1b8daaa248df6af035_Out_3_Float);
float _Multiply_1565a94cae5148adaa4ad80e978368c6_Out_2_Float;
Unity_Multiply_float_float(_SquareRoot_ec802f46201b45ac867b479ae083b1ee_Out_1_Float, _Lerp_fb2e17ff05c44b1b8daaa248df6af035_Out_3_Float, _Multiply_1565a94cae5148adaa4ad80e978368c6_Out_2_Float);
WindDirection_1 = _Divide_bfbaafc2be014557bf2a163156a11a26_Out_2_Vector2;
WindIntensity_2 = _Multiply_1565a94cae5148adaa4ad80e978368c6_Out_2_Float;
Random_3 = _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3;
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

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_MatrixConstruction_Row_float (float4 M0, float4 M1, float4 M2, float4 M3, out float4x4 Out4x4, out float3x3 Out3x3, out float2x2 Out2x2)
{
Out4x4 = float4x4(M0.x, M0.y, M0.z, M0.w, M1.x, M1.y, M1.z, M1.w, M2.x, M2.y, M2.z, M2.w, M3.x, M3.y, M3.z, M3.w);
Out3x3 = float3x3(M0.x, M0.y, M0.z, M1.x, M1.y, M1.z, M2.x, M2.y, M2.z);
Out2x2 = float2x2(M0.x, M0.y, M1.x, M1.y);
}

void Unity_Multiply_float4x4_float4(float4x4 A, float4 B, out float4 Out)
{
Out = mul(A, B);
}

void Unity_Add_float3(float3 A, float3 B, out float3 Out)
{
    Out = A + B;
}

struct Bindings_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float
{
float3 ObjectSpaceNormal;
float3 ObjectSpaceTangent;
float3 ObjectSpacePosition;
};

void SG_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float(float3 _PositionOS, bool _PositionOS_3016357c5e324f0e825ebc4f84f71f27_IsConnected, float3 _NormalOS, bool _NormalOS_6443e352350b4de9ae048680d0b154e4_IsConnected, float3 _TangentOS, bool _TangentOS_307e55ce70df463b90fe1b65f35443d9_IsConnected, float3 _PivotOffset, float3 _AxisOrientation, float4 _PivotAxis, int _OutputSpace, Bindings_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float IN, out float3 Position_1, out float3 Normal_2, out float3 Tangent_3)
{
float4 _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M0_1_Vector4 = UNITY_MATRIX_I_V[0];
float4 _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M1_2_Vector4 = UNITY_MATRIX_I_V[1];
float4 _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M2_3_Vector4 = UNITY_MATRIX_I_V[2];
float4 _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M3_4_Vector4 = UNITY_MATRIX_I_V[3];
float4 _Property_ecb1ace83c9743d78d86f543dfba0991_Out_0_Vector4 = _PivotAxis;
float4x4 _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4;
float3x3 _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var3x3_5_Matrix3;
float2x2 _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var2x2_6_Matrix2;
Unity_MatrixConstruction_Row_float(_MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M0_1_Vector4, _Property_ecb1ace83c9743d78d86f543dfba0991_Out_0_Vector4, _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M2_3_Vector4, _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M3_4_Vector4, _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4, _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var3x3_5_Matrix3, _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var2x2_6_Matrix2);
float3 _Property_41894a58127942aaae689326334e61fc_Out_0_Vector3 = _PositionOS;
bool _Property_41894a58127942aaae689326334e61fc_Out_0_Vector3_IsConnected = _PositionOS_3016357c5e324f0e825ebc4f84f71f27_IsConnected;
float3 _BranchOnInputConnection_9706ae1834c64f399a8f850ec2dbbb55_Out_3_Vector3 = _Property_41894a58127942aaae689326334e61fc_Out_0_Vector3_IsConnected ? _Property_41894a58127942aaae689326334e61fc_Out_0_Vector3 : IN.ObjectSpacePosition;
float3 _Multiply_cc7f14533a6c433b98a087240efbf8f8_Out_2_Vector3;
Unity_Multiply_float3_float3(_BranchOnInputConnection_9706ae1834c64f399a8f850ec2dbbb55_Out_3_Vector3, float3(length(float3(UNITY_MATRIX_M[0].x, UNITY_MATRIX_M[1].x, UNITY_MATRIX_M[2].x)),
                             length(float3(UNITY_MATRIX_M[0].y, UNITY_MATRIX_M[1].y, UNITY_MATRIX_M[2].y)),
                             length(float3(UNITY_MATRIX_M[0].z, UNITY_MATRIX_M[1].z, UNITY_MATRIX_M[2].z))), _Multiply_cc7f14533a6c433b98a087240efbf8f8_Out_2_Vector3);
float3 _Property_5affae77929448b994beb6b8ffca0b9a_Out_0_Vector3 = _AxisOrientation;
float3 _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3;
Unity_Multiply_float3_float3(_Multiply_cc7f14533a6c433b98a087240efbf8f8_Out_2_Vector3, _Property_5affae77929448b994beb6b8ffca0b9a_Out_0_Vector3, _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3);
float _Split_d13fd31126ee4b94b419613a1463bb24_R_1_Float = _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3[0];
float _Split_d13fd31126ee4b94b419613a1463bb24_G_2_Float = _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3[1];
float _Split_d13fd31126ee4b94b419613a1463bb24_B_3_Float = _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3[2];
float _Split_d13fd31126ee4b94b419613a1463bb24_A_4_Float = 0;
float4 _Combine_3e277c5566fd4af089d839ecf52390f8_RGBA_4_Vector4;
float3 _Combine_3e277c5566fd4af089d839ecf52390f8_RGB_5_Vector3;
float2 _Combine_3e277c5566fd4af089d839ecf52390f8_RG_6_Vector2;
Unity_Combine_float(_Split_d13fd31126ee4b94b419613a1463bb24_R_1_Float, _Split_d13fd31126ee4b94b419613a1463bb24_G_2_Float, _Split_d13fd31126ee4b94b419613a1463bb24_B_3_Float, 0, _Combine_3e277c5566fd4af089d839ecf52390f8_RGBA_4_Vector4, _Combine_3e277c5566fd4af089d839ecf52390f8_RGB_5_Vector3, _Combine_3e277c5566fd4af089d839ecf52390f8_RG_6_Vector2);
float4 _Multiply_b71678c838b541ce80f71613338319bb_Out_2_Vector4;
Unity_Multiply_float4x4_float4(_MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4, _Combine_3e277c5566fd4af089d839ecf52390f8_RGBA_4_Vector4, _Multiply_b71678c838b541ce80f71613338319bb_Out_2_Vector4);
float3 _Swizzle_533fdda21ca44bb783d1af6880283be8_Out_1_Vector3 = _Multiply_b71678c838b541ce80f71613338319bb_Out_2_Vector4.xyz;
float3 _Add_10d54894eefd4263a31339a71dc6a555_Out_2_Vector3;
Unity_Add_float3(_Swizzle_533fdda21ca44bb783d1af6880283be8_Out_1_Vector3, SHADERGRAPH_OBJECT_POSITION, _Add_10d54894eefd4263a31339a71dc6a555_Out_2_Vector3);
float3 _Property_3e2f21cb09ef4a95a3da553bc8c93907_Out_0_Vector3 = _PivotOffset;
float3 _Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3;
Unity_Add_float3(_Add_10d54894eefd4263a31339a71dc6a555_Out_2_Vector3, _Property_3e2f21cb09ef4a95a3da553bc8c93907_Out_0_Vector3, _Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3);
float3 _Transform_c7b91c9bd5a24cbba16a486b2128d2ff_Out_1_Vector3;
{
// Converting Position from AbsoluteWorld to Object via world space
float3 world;
world = GetCameraRelativePositionWS(_Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3.xyz);
_Transform_c7b91c9bd5a24cbba16a486b2128d2ff_Out_1_Vector3 = TransformWorldToObject(world);
}
float3 _OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3;
if (_OutputSpace == 0)
{
_OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3 = _Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3;
}
else if (_OutputSpace == 1)
{
_OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3 = _Transform_c7b91c9bd5a24cbba16a486b2128d2ff_Out_1_Vector3;
}
else
{
_OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3 = _Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3;
}
float3 _Property_6e320129056e479593a9673a6404c2a3_Out_0_Vector3 = _NormalOS;
bool _Property_6e320129056e479593a9673a6404c2a3_Out_0_Vector3_IsConnected = _NormalOS_6443e352350b4de9ae048680d0b154e4_IsConnected;
float3 _BranchOnInputConnection_cdbf96fcdcc94bbc8e16e41d2064eac0_Out_3_Vector3 = _Property_6e320129056e479593a9673a6404c2a3_Out_0_Vector3_IsConnected ? _Property_6e320129056e479593a9673a6404c2a3_Out_0_Vector3 : IN.ObjectSpaceNormal;
float _Split_9df7389f2a034b16b14e80d7ea3cc9eb_R_1_Float = _BranchOnInputConnection_cdbf96fcdcc94bbc8e16e41d2064eac0_Out_3_Vector3[0];
float _Split_9df7389f2a034b16b14e80d7ea3cc9eb_G_2_Float = _BranchOnInputConnection_cdbf96fcdcc94bbc8e16e41d2064eac0_Out_3_Vector3[1];
float _Split_9df7389f2a034b16b14e80d7ea3cc9eb_B_3_Float = _BranchOnInputConnection_cdbf96fcdcc94bbc8e16e41d2064eac0_Out_3_Vector3[2];
float _Split_9df7389f2a034b16b14e80d7ea3cc9eb_A_4_Float = 0;
float4 _Combine_45448fd8d869482ba046251ea2a4986d_RGBA_4_Vector4;
float3 _Combine_45448fd8d869482ba046251ea2a4986d_RGB_5_Vector3;
float2 _Combine_45448fd8d869482ba046251ea2a4986d_RG_6_Vector2;
Unity_Combine_float(_Split_9df7389f2a034b16b14e80d7ea3cc9eb_R_1_Float, _Split_9df7389f2a034b16b14e80d7ea3cc9eb_G_2_Float, _Split_9df7389f2a034b16b14e80d7ea3cc9eb_B_3_Float, 0, _Combine_45448fd8d869482ba046251ea2a4986d_RGBA_4_Vector4, _Combine_45448fd8d869482ba046251ea2a4986d_RGB_5_Vector3, _Combine_45448fd8d869482ba046251ea2a4986d_RG_6_Vector2);
float4 _Multiply_fa8c745148884874b6bda6c5b00b1faf_Out_2_Vector4;
Unity_Multiply_float4x4_float4(_MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4, _Combine_45448fd8d869482ba046251ea2a4986d_RGBA_4_Vector4, _Multiply_fa8c745148884874b6bda6c5b00b1faf_Out_2_Vector4);
float3 _Swizzle_aac6fdf714634855bbb2102e1f03176a_Out_1_Vector3 = _Multiply_fa8c745148884874b6bda6c5b00b1faf_Out_2_Vector4.xyz;
float3 _Transform_ca9dd6096e414ef1aab3fc9c46b8a751_Out_1_Vector3;
{
// Converting Normal from AbsoluteWorld to Object via world space
float3 world;
world = _Swizzle_aac6fdf714634855bbb2102e1f03176a_Out_1_Vector3.xyz;
_Transform_ca9dd6096e414ef1aab3fc9c46b8a751_Out_1_Vector3 = TransformWorldToObjectNormal(world, true);
}
float3 _OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3;
if (_OutputSpace == 0)
{
_OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3 = _Swizzle_aac6fdf714634855bbb2102e1f03176a_Out_1_Vector3;
}
else if (_OutputSpace == 1)
{
_OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3 = _Transform_ca9dd6096e414ef1aab3fc9c46b8a751_Out_1_Vector3;
}
else
{
_OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3 = _Swizzle_aac6fdf714634855bbb2102e1f03176a_Out_1_Vector3;
}
float3 _Property_1caa087de4794f53880c4f3b725272b1_Out_0_Vector3 = _TangentOS;
bool _Property_1caa087de4794f53880c4f3b725272b1_Out_0_Vector3_IsConnected = _TangentOS_307e55ce70df463b90fe1b65f35443d9_IsConnected;
float3 _BranchOnInputConnection_49631555af044120aade11fe1ef46744_Out_3_Vector3 = _Property_1caa087de4794f53880c4f3b725272b1_Out_0_Vector3_IsConnected ? _Property_1caa087de4794f53880c4f3b725272b1_Out_0_Vector3 : IN.ObjectSpaceTangent;
float _Split_38da75d926c34146b97327ecc7d7d0e3_R_1_Float = _BranchOnInputConnection_49631555af044120aade11fe1ef46744_Out_3_Vector3[0];
float _Split_38da75d926c34146b97327ecc7d7d0e3_G_2_Float = _BranchOnInputConnection_49631555af044120aade11fe1ef46744_Out_3_Vector3[1];
float _Split_38da75d926c34146b97327ecc7d7d0e3_B_3_Float = _BranchOnInputConnection_49631555af044120aade11fe1ef46744_Out_3_Vector3[2];
float _Split_38da75d926c34146b97327ecc7d7d0e3_A_4_Float = 0;
float4 _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGBA_4_Vector4;
float3 _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGB_5_Vector3;
float2 _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RG_6_Vector2;
Unity_Combine_float(_Split_38da75d926c34146b97327ecc7d7d0e3_R_1_Float, _Split_38da75d926c34146b97327ecc7d7d0e3_G_2_Float, _Split_38da75d926c34146b97327ecc7d7d0e3_B_3_Float, 0, _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGBA_4_Vector4, _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGB_5_Vector3, _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RG_6_Vector2);
float4 _Multiply_88c2defdee7945aabfad7d073ac15b3c_Out_2_Vector4;
Unity_Multiply_float4x4_float4(_MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4, _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGBA_4_Vector4, _Multiply_88c2defdee7945aabfad7d073ac15b3c_Out_2_Vector4);
float3 _Swizzle_dadec3efd6244574a802fd3e0ab56bb5_Out_1_Vector3 = _Multiply_88c2defdee7945aabfad7d073ac15b3c_Out_2_Vector4.xyz;
float3 _Transform_8906312bacad44698b5e2899041600be_Out_1_Vector3;
{
// Converting Normal from AbsoluteWorld to Object via world space
float3 world;
world = _Swizzle_dadec3efd6244574a802fd3e0ab56bb5_Out_1_Vector3.xyz;
_Transform_8906312bacad44698b5e2899041600be_Out_1_Vector3 = TransformWorldToObjectNormal(world, true);
}
float3 _OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3;
if (_OutputSpace == 0)
{
_OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3 = _Swizzle_dadec3efd6244574a802fd3e0ab56bb5_Out_1_Vector3;
}
else if (_OutputSpace == 1)
{
_OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3 = _Transform_8906312bacad44698b5e2899041600be_Out_1_Vector3;
}
else
{
_OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3 = _Swizzle_dadec3efd6244574a802fd3e0ab56bb5_Out_1_Vector3;
}
Position_1 = _OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3;
Normal_2 = _OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3;
Tangent_3 = _OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3;
}

void Unity_Add_float4(float4 A, float4 B, out float4 Out)
{
    Out = A + B;
}

void Unity_Step_float(float Edge, float In, out float Out)
{
    Out = step(Edge, In);
}

// Custom interpolators pre vertex
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
float4 Color;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
float _InstanceID_2537a879f018425d9660432f4ea146f2_Out_0_Float;
UnityGetInstanceID_float(_InstanceID_2537a879f018425d9660432f4ea146f2_Out_0_Float);
float _Divide_63d9682156f042468629ccab8669beb8_Out_2_Float;
Unity_Divide_float(_InstanceID_2537a879f018425d9660432f4ea146f2_Out_0_Float, 37, _Divide_63d9682156f042468629ccab8669beb8_Out_2_Float);
float _Fraction_052ea01a8a0b4f83b7c6c139a0975ccc_Out_1_Float;
Unity_Fraction_float(_Divide_63d9682156f042468629ccab8669beb8_Out_2_Float, _Fraction_052ea01a8a0b4f83b7c6c139a0975ccc_Out_1_Float);
float4 _Property_19686efd1fb54b50a7d330cad1112554_Out_0_Vector4 = _Blade_Color_2;
float4 _Property_d254ba2921d340f982bfbcfaf5916ad3_Out_0_Vector4 = _Blade_Color_1;
float4 _Lerp_58d751d66dbc479a8656d14d2baf579f_Out_3_Vector4;
Unity_Lerp_float4(_Property_d254ba2921d340f982bfbcfaf5916ad3_Out_0_Vector4, _Property_19686efd1fb54b50a7d330cad1112554_Out_0_Vector4, (_Fraction_052ea01a8a0b4f83b7c6c139a0975ccc_Out_1_Float.xxxx), _Lerp_58d751d66dbc479a8656d14d2baf579f_Out_3_Vector4);
float _Property_dbcc12976b2c4eb4a63c1284e5f1d305_Out_0_Float = _Wind_Speed;
Bindings_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba;
_FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba.TimeParameters = IN.TimeParameters;
float2 _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindDirection_1_Vector2;
float _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindIntensity_2_Float;
float3 _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_Random_3_Vector3;
SG_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float(124, _Property_dbcc12976b2c4eb4a63c1284e5f1d305_Out_0_Float, 0.01, 0.2, 0.1, 0.2, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindDirection_1_Vector2, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindIntensity_2_Float, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_Random_3_Vector3);
float4x4 _Property_e6333f42f10045b8874ca797f7698f1d_Out_0_Matrix4 = _WireframeShaderMaskData1;
float _DynamicMask_50b2c29949db4c9087fc753d984c4250_Out_3_Float;
WireframeShaderDynamicMaskCube_float(IN.WorldSpacePosition, _Property_e6333f42f10045b8874ca797f7698f1d_Out_0_Matrix4, 0, _DynamicMask_50b2c29949db4c9087fc753d984c4250_Out_3_Float);
float4x4 _Property_37070fbe8a4e4576a732a3a352dec45e_Out_0_Matrix4 = _WireframeShaderMaskData2;
float _DynamicMask_0c15310c869f45a5bb095f810944777b_Out_3_Float;
WireframeShaderDynamicMaskSphere_float(IN.WorldSpacePosition, _Property_37070fbe8a4e4576a732a3a352dec45e_Out_0_Matrix4, 0, _DynamicMask_0c15310c869f45a5bb095f810944777b_Out_3_Float);
float _Add_4e24bc1118f94bdb89aeba5ac3067e43_Out_2_Float;
Unity_Add_float(_DynamicMask_50b2c29949db4c9087fc753d984c4250_Out_3_Float, _DynamicMask_0c15310c869f45a5bb095f810944777b_Out_3_Float, _Add_4e24bc1118f94bdb89aeba5ac3067e43_Out_2_Float);
float _Saturate_b1a2ecfe1d1842778d5653a46a7b1782_Out_1_Float;
Unity_Saturate_float(_Add_4e24bc1118f94bdb89aeba5ac3067e43_Out_2_Float, _Saturate_b1a2ecfe1d1842778d5653a46a7b1782_Out_1_Float);
float _OneMinus_153cdd2db72f462c97a7c55eccd49567_Out_1_Float;
Unity_OneMinus_float(_Saturate_b1a2ecfe1d1842778d5653a46a7b1782_Out_1_Float, _OneMinus_153cdd2db72f462c97a7c55eccd49567_Out_1_Float);
float _Multiply_cff561f8195f49188db426fdc084a6ce_Out_2_Float;
Unity_Multiply_float_float(_OneMinus_153cdd2db72f462c97a7c55eccd49567_Out_1_Float, -1, _Multiply_cff561f8195f49188db426fdc084a6ce_Out_2_Float);
float3 _Vector3_2dea481cbff74205a7cee900960a51a9_Out_0_Vector3 = float3(_FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindIntensity_2_Float, _Multiply_cff561f8195f49188db426fdc084a6ce_Out_2_Float, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindIntensity_2_Float);
Bindings_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f;
_BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f.ObjectSpaceNormal = IN.ObjectSpaceNormal;
_BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f.ObjectSpaceTangent = IN.ObjectSpaceTangent;
_BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f.ObjectSpacePosition = IN.ObjectSpacePosition;
float3 _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Position_1_Vector3;
float3 _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Normal_2_Vector3;
float3 _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Tangent_3_Vector3;
SG_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float(float3 (0, 0, 0), false, float3 (0, 0, 0), false, float3 (0, 0, 0), false, _Vector3_2dea481cbff74205a7cee900960a51a9_Out_0_Vector3, float3 (-1, 1, 1), float4 (0, 1, 0, 0), 1, _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f, _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Position_1_Vector3, _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Normal_2_Vector3, _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Tangent_3_Vector3);
description.Position = _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Position_1_Vector3;
description.Normal = IN.ObjectSpaceNormal;
description.Tangent = IN.ObjectSpaceTangent;
description.Color = _Lerp_58d751d66dbc479a8656d14d2baf579f_Out_3_Vector4;
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
output.Color = input.Color;
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
float _Property_a7bf99e3e3cf4540bc6bd38a6aaab41f_Out_0_Float = _Wireframe_Thickness;
float _Property_07fc055baf6a48729fd1b78fbf96db5c_Out_0_Float = _Wireframe_Anti_aliasing;
float4 _Add_c1cf3158744d4822974d88d98d719275_Out_2_Vector4;
Unity_Add_float4(IN.Color, 0, _Add_c1cf3158744d4822974d88d98d719275_Out_2_Vector4);
float _Property_b17d9045f0a44cc8ba01c677192340fe_Out_0_Float = _Metallic;
float _Property_4688972c65be441aa92fdbbcf5d9938e_Out_0_Float = _Smoothness;
float4x4 _Property_768bac82b0684cd0a21ed8a814d35a50_Out_0_Matrix4 = _WireframeShaderMaskData1;
float _DynamicMask_d8cbb946b52f4b01a4d3fd3bc3ea9de1_Out_3_Float;
WireframeShaderDynamicMaskCube_float(IN.WorldSpacePosition, _Property_768bac82b0684cd0a21ed8a814d35a50_Out_0_Matrix4, 0, _DynamicMask_d8cbb946b52f4b01a4d3fd3bc3ea9de1_Out_3_Float);
float4x4 _Property_39e6a912ee0647ed8335e7ab63cd4bed_Out_0_Matrix4 = _WireframeShaderMaskData2;
float _DynamicMask_e413c723ed49470ba4eca3bcf6362548_Out_3_Float;
WireframeShaderDynamicMaskSphere_float(IN.WorldSpacePosition, _Property_39e6a912ee0647ed8335e7ab63cd4bed_Out_0_Matrix4, 0, _DynamicMask_e413c723ed49470ba4eca3bcf6362548_Out_3_Float);
float _Add_c3b10d55feaf4b9baefa4948a8eaed75_Out_2_Float;
Unity_Add_float(_DynamicMask_d8cbb946b52f4b01a4d3fd3bc3ea9de1_Out_3_Float, _DynamicMask_e413c723ed49470ba4eca3bcf6362548_Out_3_Float, _Add_c3b10d55feaf4b9baefa4948a8eaed75_Out_2_Float);
float _Saturate_62dc9cf6a37b4fab9407e114176db70f_Out_1_Float;
Unity_Saturate_float(_Add_c3b10d55feaf4b9baefa4948a8eaed75_Out_2_Float, _Saturate_62dc9cf6a37b4fab9407e114176db70f_Out_1_Float);
float _Step_0f4fbf717a47479eaa1a77f0d38201d7_Out_2_Float;
Unity_Step_float(0.05, _Saturate_62dc9cf6a37b4fab9407e114176db70f_Out_1_Float, _Step_0f4fbf717a47479eaa1a77f0d38201d7_Out_2_Float);
surface.BaseColor = (_Add_c1cf3158744d4822974d88d98d719275_Out_2_Vector4.xyz);
surface.NormalTS = IN.TangentSpaceNormal;
surface.Emission = float3(0, 0, 0);
surface.Metallic = _Property_b17d9045f0a44cc8ba01c677192340fe_Out_0_Float;
surface.Smoothness = _Property_4688972c65be441aa92fdbbcf5d9938e_Out_0_Float;
surface.Occlusion = 1;
surface.Alpha = _Step_0f4fbf717a47479eaa1a77f0d38201d7_Out_2_Float;
surface.AlphaClipThreshold = 0.5;
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
    output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
    output.TimeParameters =                             _TimeParameters.xyz;

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

    output.Color = input.Color;



    output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


    output.WorldSpacePosition = input.positionWS;

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
#pragma target 4.5
#pragma exclude_renderers gles gles3 glcore
#pragma multi_compile_instancing
#pragma multi_compile_fog
#pragma instancing_options renderinglayer
#pragma vertex vert
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
#define ATTRIBUTES_NEED_TEXCOORD1
#define ATTRIBUTES_NEED_TEXCOORD2
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define VARYINGS_NEED_TANGENT_WS
#define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
#define VARYINGS_NEED_SHADOW_COORD
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_GBUFFER
#define _FOG_FRAGMENT 1
#define _ALPHATEST_ON 1
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
 float4 uv1 : TEXCOORD1;
 float4 uv2 : TEXCOORD2;
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
 float4 Color;
};
struct SurfaceDescriptionInputs
{
 float3 TangentSpaceNormal;
 float3 WorldSpacePosition;
 float4 Color;
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
 float3 WorldSpacePosition;
 float3 TimeParameters;
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
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
 float4 shadowCoord : INTERP3;
#endif
 float4 tangentWS : INTERP4;
 float4 fogFactorAndVertexLight : INTERP5;
 float4 Color : INTERP6;
 float3 positionWS : INTERP7;
 float3 normalWS : INTERP8;
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
output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
output.Color.xyzw = input.Color;
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
output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
output.Color = input.Color.xyzw;
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
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)
float _Wireframe_Thickness;
float _Wireframe_Anti_aliasing;
float4 _Blade_Color_2;
float4 _Blade_Color_1;
float _Metallic;
float _Smoothness;
float _Wind_Speed;
CBUFFER_END


// Object and Global properties
float4x4 _WireframeShaderMaskData1;
float4x4 _WireframeShaderMaskData2;

// Graph Includes
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"

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

void UnityGetInstanceID_float(out float Out)
{
#if UNITY_ANY_INSTANCING_ENABLED
    Out = unity_InstanceID;
#else
    Out = 0;
#endif
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Fraction_float(float In, out float Out)
{
    Out = frac(In);
}

void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
{
    Out = lerp(A, B, T);
}

void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
{
Out = A * B;
}

void Unity_Fraction_float3(float3 In, out float3 Out)
{
    Out = frac(In);
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Multiply_float_float(float A, float B, out float Out)
{
Out = A * B;
}

void Unity_Sine_float(float In, out float Out)
{
    Out = sin(In);
}

void Unity_DegreesToRadians_float(float In, out float Out)
{
    Out = radians(In);
}

void Unity_Rotate_Radians_float(float2 UV, float2 Center, float Rotation, out float2 Out)
{
    //rotation matrix
    UV -= Center;
    float s = sin(Rotation);
    float c = cos(Rotation);

    //center rotation matrix
    float2x2 rMatrix = float2x2(c, -s, s, c);
    rMatrix *= 0.5;
    rMatrix += 0.5;
    rMatrix = rMatrix*2 - 1;

    //multiply the UVs by the rotation matrix
    UV.xy = mul(UV.xy, rMatrix);
    UV += Center;

    Out = UV;
}

void Unity_Cosine_float(float In, out float Out)
{
    Out = cos(In);
}

void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
{
    RGBA = float4(R, G, B, A);
    RGB = float3(R, G, B);
    RG = float2(R, G);
}

void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
{
Out = A * B;
}

void Unity_DotProduct_float2(float2 A, float2 B, out float Out)
{
    Out = dot(A, B);
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
    Out = A + B;
}

void Unity_Negate_float(float In, out float Out)
{
    Out = -1 * In;
}

float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
{
float x; Hash_Tchou_2_1_float(p, x);
return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
{
float2 p = UV * Scale.xy;
float2 ip = floor(p);
float2 fp = frac(p);
float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
    Out = smoothstep(Edge1, Edge2, In);
}

void Unity_Saturate_float(float In, out float Out)
{
    Out = saturate(In);
}

void Unity_Lerp_float2(float2 A, float2 B, float2 T, out float2 Out)
{
    Out = lerp(A, B, T);
}

void Unity_SquareRoot_float(float In, out float Out)
{
    Out = sqrt(In);
}

void Unity_Maximum_float(float A, float B, out float Out)
{
    Out = max(A, B);
}

void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
{
    Out = A / B;
}

void Unity_Lerp_float(float A, float B, float T, out float Out)
{
    Out = lerp(A, B, T);
}

struct Bindings_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float
{
float3 TimeParameters;
};

void SG_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float(float _WindDirection, float _WindSpeed, float _WindDirectionVariation, float _PerBladeRandomTimeOffset, float _PerBladeWindIntensityVariation, float _WindIntensity, Bindings_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float IN, out float2 WindDirection_1, out float WindIntensity_2, out float3 Random_3)
{
float2 _Vector2_42921bc8d43346a4bbad7aa650d15962_Out_0_Vector2 = float2(1, 0);
float3 _Multiply_b6ed4cc094134c21943e217e6e271dae_Out_2_Vector3;
Unity_Multiply_float3_float3(SHADERGRAPH_OBJECT_POSITION, float3(37, 190, 29), _Multiply_b6ed4cc094134c21943e217e6e271dae_Out_2_Vector3);
float3 _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3;
Unity_Fraction_float3(_Multiply_b6ed4cc094134c21943e217e6e271dae_Out_2_Vector3, _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3);
float _Split_3967427c51c24bb79cef645976364a55_R_1_Float = _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3[0];
float _Split_3967427c51c24bb79cef645976364a55_G_2_Float = _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3[1];
float _Split_3967427c51c24bb79cef645976364a55_B_3_Float = _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3[2];
float _Split_3967427c51c24bb79cef645976364a55_A_4_Float = 0;
float _Add_ffd28ed6ff854810bd439fbdfc4b2cc2_Out_2_Float;
Unity_Add_float(IN.TimeParameters.x, _Split_3967427c51c24bb79cef645976364a55_B_3_Float, _Add_ffd28ed6ff854810bd439fbdfc4b2cc2_Out_2_Float);
float _Multiply_1185303c6c5d481190d5375ac379cab8_Out_2_Float;
Unity_Multiply_float_float(_Add_ffd28ed6ff854810bd439fbdfc4b2cc2_Out_2_Float, 3, _Multiply_1185303c6c5d481190d5375ac379cab8_Out_2_Float);
float _Sine_c919089f2f34401face2dd9897c9725c_Out_1_Float;
Unity_Sine_float(_Multiply_1185303c6c5d481190d5375ac379cab8_Out_2_Float, _Sine_c919089f2f34401face2dd9897c9725c_Out_1_Float);
float _Property_40290747561641a1bdf5517e6a93430d_Out_0_Float = _WindDirectionVariation;
float _DegreesToRadians_a7fe82a177484cd0af99b4027bc4e3bc_Out_1_Float;
Unity_DegreesToRadians_float(_Property_40290747561641a1bdf5517e6a93430d_Out_0_Float, _DegreesToRadians_a7fe82a177484cd0af99b4027bc4e3bc_Out_1_Float);
float _Multiply_c6dbf243e66746b490b03900b2b27467_Out_2_Float;
Unity_Multiply_float_float(_Sine_c919089f2f34401face2dd9897c9725c_Out_1_Float, _DegreesToRadians_a7fe82a177484cd0af99b4027bc4e3bc_Out_1_Float, _Multiply_c6dbf243e66746b490b03900b2b27467_Out_2_Float);
float2 _Rotate_cf73d535c5fb437aa68912dc0e09ba2f_Out_3_Vector2;
Unity_Rotate_Radians_float(_Vector2_42921bc8d43346a4bbad7aa650d15962_Out_0_Vector2, float2 (0, 0), _Multiply_c6dbf243e66746b490b03900b2b27467_Out_2_Float, _Rotate_cf73d535c5fb437aa68912dc0e09ba2f_Out_3_Vector2);
float _Property_df02aaa16377442d91f0c6be7d036d51_Out_0_Float = _WindDirection;
float _DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float;
Unity_DegreesToRadians_float(_Property_df02aaa16377442d91f0c6be7d036d51_Out_0_Float, _DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float);
float _Add_b051e3fa11c048dd978791daff07720d_Out_2_Float;
Unity_Add_float(_Multiply_c6dbf243e66746b490b03900b2b27467_Out_2_Float, _DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float, _Add_b051e3fa11c048dd978791daff07720d_Out_2_Float);
float _Cosine_0847069386bc4c12a90e1fe3eb1eee73_Out_1_Float;
Unity_Cosine_float(_Add_b051e3fa11c048dd978791daff07720d_Out_2_Float, _Cosine_0847069386bc4c12a90e1fe3eb1eee73_Out_1_Float);
float _Sine_379c87a4cd3c419293869dee73c52de0_Out_1_Float;
Unity_Sine_float(_Add_b051e3fa11c048dd978791daff07720d_Out_2_Float, _Sine_379c87a4cd3c419293869dee73c52de0_Out_1_Float);
float4 _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RGBA_4_Vector4;
float3 _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RGB_5_Vector3;
float2 _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RG_6_Vector2;
Unity_Combine_float(_Cosine_0847069386bc4c12a90e1fe3eb1eee73_Out_1_Float, _Sine_379c87a4cd3c419293869dee73c52de0_Out_1_Float, 0, 0, _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RGBA_4_Vector4, _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RGB_5_Vector3, _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RG_6_Vector2);
float2 _Swizzle_db678fc97ec448fda50408084410c787_Out_1_Vector2 = SHADERGRAPH_OBJECT_POSITION.xz;
float2 _Multiply_5833218c1a7c4d9586d5e8c69ddaabac_Out_2_Vector2;
Unity_Multiply_float2_float2(_Swizzle_db678fc97ec448fda50408084410c787_Out_1_Vector2, float2(0.5, 0.5), _Multiply_5833218c1a7c4d9586d5e8c69ddaabac_Out_2_Vector2);
float _Cosine_3388e8245f6647ca98f5aa9339130c65_Out_1_Float;
Unity_Cosine_float(_DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float, _Cosine_3388e8245f6647ca98f5aa9339130c65_Out_1_Float);
float _Sine_0b39f9f73b2c4016a046ad8da4b84c11_Out_1_Float;
Unity_Sine_float(_DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float, _Sine_0b39f9f73b2c4016a046ad8da4b84c11_Out_1_Float);
float4 _Combine_7f78efe98e4641c1981d47da9bbbe70f_RGBA_4_Vector4;
float3 _Combine_7f78efe98e4641c1981d47da9bbbe70f_RGB_5_Vector3;
float2 _Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2;
Unity_Combine_float(_Cosine_3388e8245f6647ca98f5aa9339130c65_Out_1_Float, _Sine_0b39f9f73b2c4016a046ad8da4b84c11_Out_1_Float, 0, 0, _Combine_7f78efe98e4641c1981d47da9bbbe70f_RGBA_4_Vector4, _Combine_7f78efe98e4641c1981d47da9bbbe70f_RGB_5_Vector3, _Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2);
float _DotProduct_27327ffeb11d404c96d6820c42272ca8_Out_2_Float;
Unity_DotProduct_float2(_Multiply_5833218c1a7c4d9586d5e8c69ddaabac_Out_2_Vector2, _Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2, _DotProduct_27327ffeb11d404c96d6820c42272ca8_Out_2_Float);
float _Multiply_8dc73d49a3b547a19bf5c0d8a4a09920_Out_2_Float;
Unity_Multiply_float_float(_DotProduct_27327ffeb11d404c96d6820c42272ca8_Out_2_Float, 0.7, _Multiply_8dc73d49a3b547a19bf5c0d8a4a09920_Out_2_Float);
float2 _Multiply_c8e01038fa74488a86a9759343a555f5_Out_2_Vector2;
Unity_Multiply_float2_float2((_Multiply_8dc73d49a3b547a19bf5c0d8a4a09920_Out_2_Float.xx), _Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2, _Multiply_c8e01038fa74488a86a9759343a555f5_Out_2_Vector2);
float _Multiply_69e2c5b6e72c4faf8d83ead16a5c0cd6_Out_2_Float;
Unity_Multiply_float_float(_Cosine_3388e8245f6647ca98f5aa9339130c65_Out_1_Float, -1.5708, _Multiply_69e2c5b6e72c4faf8d83ead16a5c0cd6_Out_2_Float);
float4 _Combine_2f7388d585a24290a659f20482d78d94_RGBA_4_Vector4;
float3 _Combine_2f7388d585a24290a659f20482d78d94_RGB_5_Vector3;
float2 _Combine_2f7388d585a24290a659f20482d78d94_RG_6_Vector2;
Unity_Combine_float(_Sine_0b39f9f73b2c4016a046ad8da4b84c11_Out_1_Float, _Multiply_69e2c5b6e72c4faf8d83ead16a5c0cd6_Out_2_Float, 0, 0, _Combine_2f7388d585a24290a659f20482d78d94_RGBA_4_Vector4, _Combine_2f7388d585a24290a659f20482d78d94_RGB_5_Vector3, _Combine_2f7388d585a24290a659f20482d78d94_RG_6_Vector2);
float _DotProduct_e3247c7835f0404893730bc5dcd240a0_Out_2_Float;
Unity_DotProduct_float2(_Multiply_5833218c1a7c4d9586d5e8c69ddaabac_Out_2_Vector2, _Combine_2f7388d585a24290a659f20482d78d94_RG_6_Vector2, _DotProduct_e3247c7835f0404893730bc5dcd240a0_Out_2_Float);
float2 _Multiply_ed7373e7bd6347f89e44dacc83ccf8c1_Out_2_Vector2;
Unity_Multiply_float2_float2((_DotProduct_e3247c7835f0404893730bc5dcd240a0_Out_2_Float.xx), _Combine_2f7388d585a24290a659f20482d78d94_RG_6_Vector2, _Multiply_ed7373e7bd6347f89e44dacc83ccf8c1_Out_2_Vector2);
float2 _Add_f950bfd74ec2464b89d972d5f43aa5b7_Out_2_Vector2;
Unity_Add_float2(_Multiply_c8e01038fa74488a86a9759343a555f5_Out_2_Vector2, _Multiply_ed7373e7bd6347f89e44dacc83ccf8c1_Out_2_Vector2, _Add_f950bfd74ec2464b89d972d5f43aa5b7_Out_2_Vector2);
float _Property_8c38f0ae55594c8787ad0a52af13731b_Out_0_Float = _WindSpeed;
float _Negate_47564bc9ce9645a5916ebc05fb9d63df_Out_1_Float;
Unity_Negate_float(_Property_8c38f0ae55594c8787ad0a52af13731b_Out_0_Float, _Negate_47564bc9ce9645a5916ebc05fb9d63df_Out_1_Float);
float _Multiply_e311852a737c422594c328d00e16414c_Out_2_Float;
Unity_Multiply_float_float(IN.TimeParameters.x, _Negate_47564bc9ce9645a5916ebc05fb9d63df_Out_1_Float, _Multiply_e311852a737c422594c328d00e16414c_Out_2_Float);
float _Property_347528760e804b2ab165732f176f3e97_Out_0_Float = _PerBladeRandomTimeOffset;
float _Multiply_0657e69a5c9b4cb783a0d4021b58a9b1_Out_2_Float;
Unity_Multiply_float_float(_Split_3967427c51c24bb79cef645976364a55_R_1_Float, _Property_347528760e804b2ab165732f176f3e97_Out_0_Float, _Multiply_0657e69a5c9b4cb783a0d4021b58a9b1_Out_2_Float);
float _Add_8e1a8d342102407f97ee7c7b88271e7d_Out_2_Float;
Unity_Add_float(_Multiply_e311852a737c422594c328d00e16414c_Out_2_Float, _Multiply_0657e69a5c9b4cb783a0d4021b58a9b1_Out_2_Float, _Add_8e1a8d342102407f97ee7c7b88271e7d_Out_2_Float);
float2 _Multiply_e39ee6e978424683b1858114ff959110_Out_2_Vector2;
Unity_Multiply_float2_float2(_Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2, (_Add_8e1a8d342102407f97ee7c7b88271e7d_Out_2_Float.xx), _Multiply_e39ee6e978424683b1858114ff959110_Out_2_Vector2);
float2 _Add_302cec4f55d64a65bf1160e9d23f9b71_Out_2_Vector2;
Unity_Add_float2(_Add_f950bfd74ec2464b89d972d5f43aa5b7_Out_2_Vector2, _Multiply_e39ee6e978424683b1858114ff959110_Out_2_Vector2, _Add_302cec4f55d64a65bf1160e9d23f9b71_Out_2_Vector2);
float _GradientNoise_f0d0f1452f814e03824cb2ceb16d6ad2_Out_2_Float;
Unity_GradientNoise_Deterministic_float(_Add_302cec4f55d64a65bf1160e9d23f9b71_Out_2_Vector2, 0.8, _GradientNoise_f0d0f1452f814e03824cb2ceb16d6ad2_Out_2_Float);
float _Smoothstep_4ca6b3a56ada4447bcfcabe8e1a6ee2b_Out_3_Float;
Unity_Smoothstep_float(-0.5, 1.5, _GradientNoise_f0d0f1452f814e03824cb2ceb16d6ad2_Out_2_Float, _Smoothstep_4ca6b3a56ada4447bcfcabe8e1a6ee2b_Out_3_Float);
float _Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float;
Unity_Saturate_float(_Smoothstep_4ca6b3a56ada4447bcfcabe8e1a6ee2b_Out_3_Float, _Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float);
float2 _Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2;
Unity_Lerp_float2(_Rotate_cf73d535c5fb437aa68912dc0e09ba2f_Out_3_Vector2, _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RG_6_Vector2, (_Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float.xx), _Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2);
float _DotProduct_b6d4ff1e79f54760a1f13bc5172c426b_Out_2_Float;
Unity_DotProduct_float2(_Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2, _Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2, _DotProduct_b6d4ff1e79f54760a1f13bc5172c426b_Out_2_Float);
float _SquareRoot_ec802f46201b45ac867b479ae083b1ee_Out_1_Float;
Unity_SquareRoot_float(_DotProduct_b6d4ff1e79f54760a1f13bc5172c426b_Out_2_Float, _SquareRoot_ec802f46201b45ac867b479ae083b1ee_Out_1_Float);
float _Maximum_56d7bd23f19a4866b35324380205c891_Out_2_Float;
Unity_Maximum_float(_SquareRoot_ec802f46201b45ac867b479ae083b1ee_Out_1_Float, 1E-05, _Maximum_56d7bd23f19a4866b35324380205c891_Out_2_Float);
float2 _Divide_bfbaafc2be014557bf2a163156a11a26_Out_2_Vector2;
Unity_Divide_float2(_Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2, (_Maximum_56d7bd23f19a4866b35324380205c891_Out_2_Float.xx), _Divide_bfbaafc2be014557bf2a163156a11a26_Out_2_Vector2);
float _Property_f1f58df30464478cb038a178d9e83682_Out_0_Float = _WindIntensity;
float _Add_ed2907c2a73440cc83d0b31366c5c7ae_Out_2_Float;
Unity_Add_float(IN.TimeParameters.x, _Split_3967427c51c24bb79cef645976364a55_B_3_Float, _Add_ed2907c2a73440cc83d0b31366c5c7ae_Out_2_Float);
float _Multiply_f0258532eb174f5393420713f84f6c8e_Out_2_Float;
Unity_Multiply_float_float(_Add_ed2907c2a73440cc83d0b31366c5c7ae_Out_2_Float, 2, _Multiply_f0258532eb174f5393420713f84f6c8e_Out_2_Float);
float _Sine_17bbe1505e754bbd9eedc59d0757132f_Out_1_Float;
Unity_Sine_float(_Multiply_f0258532eb174f5393420713f84f6c8e_Out_2_Float, _Sine_17bbe1505e754bbd9eedc59d0757132f_Out_1_Float);
float _Multiply_bfdbccbbf3584e1eb7d34b97e3a771c5_Out_2_Float;
Unity_Multiply_float_float(_Add_ed2907c2a73440cc83d0b31366c5c7ae_Out_2_Float, 3, _Multiply_bfdbccbbf3584e1eb7d34b97e3a771c5_Out_2_Float);
float _Sine_775bcfb1287e450094240576942d7a07_Out_1_Float;
Unity_Sine_float(_Multiply_bfdbccbbf3584e1eb7d34b97e3a771c5_Out_2_Float, _Sine_775bcfb1287e450094240576942d7a07_Out_1_Float);
float _Lerp_3cef0baddeb24a408278d7e18640ec45_Out_3_Float;
Unity_Lerp_float(_Sine_17bbe1505e754bbd9eedc59d0757132f_Out_1_Float, _Sine_775bcfb1287e450094240576942d7a07_Out_1_Float, _Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float, _Lerp_3cef0baddeb24a408278d7e18640ec45_Out_3_Float);
float _Property_59edf586db864b7a9b70a1acca2de692_Out_0_Float = _PerBladeWindIntensityVariation;
float _Multiply_13aa0e7d9b29467fa9ca1e4db82d023c_Out_2_Float;
Unity_Multiply_float_float(_Lerp_3cef0baddeb24a408278d7e18640ec45_Out_3_Float, _Property_59edf586db864b7a9b70a1acca2de692_Out_0_Float, _Multiply_13aa0e7d9b29467fa9ca1e4db82d023c_Out_2_Float);
float _Add_5a191ec83e8345689f15b7e3b2da0e21_Out_2_Float;
Unity_Add_float(_Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float, _Multiply_13aa0e7d9b29467fa9ca1e4db82d023c_Out_2_Float, _Add_5a191ec83e8345689f15b7e3b2da0e21_Out_2_Float);
float _Lerp_fb2e17ff05c44b1b8daaa248df6af035_Out_3_Float;
Unity_Lerp_float(0, _Property_f1f58df30464478cb038a178d9e83682_Out_0_Float, _Add_5a191ec83e8345689f15b7e3b2da0e21_Out_2_Float, _Lerp_fb2e17ff05c44b1b8daaa248df6af035_Out_3_Float);
float _Multiply_1565a94cae5148adaa4ad80e978368c6_Out_2_Float;
Unity_Multiply_float_float(_SquareRoot_ec802f46201b45ac867b479ae083b1ee_Out_1_Float, _Lerp_fb2e17ff05c44b1b8daaa248df6af035_Out_3_Float, _Multiply_1565a94cae5148adaa4ad80e978368c6_Out_2_Float);
WindDirection_1 = _Divide_bfbaafc2be014557bf2a163156a11a26_Out_2_Vector2;
WindIntensity_2 = _Multiply_1565a94cae5148adaa4ad80e978368c6_Out_2_Float;
Random_3 = _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3;
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

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_MatrixConstruction_Row_float (float4 M0, float4 M1, float4 M2, float4 M3, out float4x4 Out4x4, out float3x3 Out3x3, out float2x2 Out2x2)
{
Out4x4 = float4x4(M0.x, M0.y, M0.z, M0.w, M1.x, M1.y, M1.z, M1.w, M2.x, M2.y, M2.z, M2.w, M3.x, M3.y, M3.z, M3.w);
Out3x3 = float3x3(M0.x, M0.y, M0.z, M1.x, M1.y, M1.z, M2.x, M2.y, M2.z);
Out2x2 = float2x2(M0.x, M0.y, M1.x, M1.y);
}

void Unity_Multiply_float4x4_float4(float4x4 A, float4 B, out float4 Out)
{
Out = mul(A, B);
}

void Unity_Add_float3(float3 A, float3 B, out float3 Out)
{
    Out = A + B;
}

struct Bindings_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float
{
float3 ObjectSpaceNormal;
float3 ObjectSpaceTangent;
float3 ObjectSpacePosition;
};

void SG_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float(float3 _PositionOS, bool _PositionOS_3016357c5e324f0e825ebc4f84f71f27_IsConnected, float3 _NormalOS, bool _NormalOS_6443e352350b4de9ae048680d0b154e4_IsConnected, float3 _TangentOS, bool _TangentOS_307e55ce70df463b90fe1b65f35443d9_IsConnected, float3 _PivotOffset, float3 _AxisOrientation, float4 _PivotAxis, int _OutputSpace, Bindings_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float IN, out float3 Position_1, out float3 Normal_2, out float3 Tangent_3)
{
float4 _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M0_1_Vector4 = UNITY_MATRIX_I_V[0];
float4 _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M1_2_Vector4 = UNITY_MATRIX_I_V[1];
float4 _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M2_3_Vector4 = UNITY_MATRIX_I_V[2];
float4 _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M3_4_Vector4 = UNITY_MATRIX_I_V[3];
float4 _Property_ecb1ace83c9743d78d86f543dfba0991_Out_0_Vector4 = _PivotAxis;
float4x4 _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4;
float3x3 _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var3x3_5_Matrix3;
float2x2 _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var2x2_6_Matrix2;
Unity_MatrixConstruction_Row_float(_MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M0_1_Vector4, _Property_ecb1ace83c9743d78d86f543dfba0991_Out_0_Vector4, _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M2_3_Vector4, _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M3_4_Vector4, _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4, _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var3x3_5_Matrix3, _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var2x2_6_Matrix2);
float3 _Property_41894a58127942aaae689326334e61fc_Out_0_Vector3 = _PositionOS;
bool _Property_41894a58127942aaae689326334e61fc_Out_0_Vector3_IsConnected = _PositionOS_3016357c5e324f0e825ebc4f84f71f27_IsConnected;
float3 _BranchOnInputConnection_9706ae1834c64f399a8f850ec2dbbb55_Out_3_Vector3 = _Property_41894a58127942aaae689326334e61fc_Out_0_Vector3_IsConnected ? _Property_41894a58127942aaae689326334e61fc_Out_0_Vector3 : IN.ObjectSpacePosition;
float3 _Multiply_cc7f14533a6c433b98a087240efbf8f8_Out_2_Vector3;
Unity_Multiply_float3_float3(_BranchOnInputConnection_9706ae1834c64f399a8f850ec2dbbb55_Out_3_Vector3, float3(length(float3(UNITY_MATRIX_M[0].x, UNITY_MATRIX_M[1].x, UNITY_MATRIX_M[2].x)),
                             length(float3(UNITY_MATRIX_M[0].y, UNITY_MATRIX_M[1].y, UNITY_MATRIX_M[2].y)),
                             length(float3(UNITY_MATRIX_M[0].z, UNITY_MATRIX_M[1].z, UNITY_MATRIX_M[2].z))), _Multiply_cc7f14533a6c433b98a087240efbf8f8_Out_2_Vector3);
float3 _Property_5affae77929448b994beb6b8ffca0b9a_Out_0_Vector3 = _AxisOrientation;
float3 _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3;
Unity_Multiply_float3_float3(_Multiply_cc7f14533a6c433b98a087240efbf8f8_Out_2_Vector3, _Property_5affae77929448b994beb6b8ffca0b9a_Out_0_Vector3, _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3);
float _Split_d13fd31126ee4b94b419613a1463bb24_R_1_Float = _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3[0];
float _Split_d13fd31126ee4b94b419613a1463bb24_G_2_Float = _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3[1];
float _Split_d13fd31126ee4b94b419613a1463bb24_B_3_Float = _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3[2];
float _Split_d13fd31126ee4b94b419613a1463bb24_A_4_Float = 0;
float4 _Combine_3e277c5566fd4af089d839ecf52390f8_RGBA_4_Vector4;
float3 _Combine_3e277c5566fd4af089d839ecf52390f8_RGB_5_Vector3;
float2 _Combine_3e277c5566fd4af089d839ecf52390f8_RG_6_Vector2;
Unity_Combine_float(_Split_d13fd31126ee4b94b419613a1463bb24_R_1_Float, _Split_d13fd31126ee4b94b419613a1463bb24_G_2_Float, _Split_d13fd31126ee4b94b419613a1463bb24_B_3_Float, 0, _Combine_3e277c5566fd4af089d839ecf52390f8_RGBA_4_Vector4, _Combine_3e277c5566fd4af089d839ecf52390f8_RGB_5_Vector3, _Combine_3e277c5566fd4af089d839ecf52390f8_RG_6_Vector2);
float4 _Multiply_b71678c838b541ce80f71613338319bb_Out_2_Vector4;
Unity_Multiply_float4x4_float4(_MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4, _Combine_3e277c5566fd4af089d839ecf52390f8_RGBA_4_Vector4, _Multiply_b71678c838b541ce80f71613338319bb_Out_2_Vector4);
float3 _Swizzle_533fdda21ca44bb783d1af6880283be8_Out_1_Vector3 = _Multiply_b71678c838b541ce80f71613338319bb_Out_2_Vector4.xyz;
float3 _Add_10d54894eefd4263a31339a71dc6a555_Out_2_Vector3;
Unity_Add_float3(_Swizzle_533fdda21ca44bb783d1af6880283be8_Out_1_Vector3, SHADERGRAPH_OBJECT_POSITION, _Add_10d54894eefd4263a31339a71dc6a555_Out_2_Vector3);
float3 _Property_3e2f21cb09ef4a95a3da553bc8c93907_Out_0_Vector3 = _PivotOffset;
float3 _Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3;
Unity_Add_float3(_Add_10d54894eefd4263a31339a71dc6a555_Out_2_Vector3, _Property_3e2f21cb09ef4a95a3da553bc8c93907_Out_0_Vector3, _Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3);
float3 _Transform_c7b91c9bd5a24cbba16a486b2128d2ff_Out_1_Vector3;
{
// Converting Position from AbsoluteWorld to Object via world space
float3 world;
world = GetCameraRelativePositionWS(_Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3.xyz);
_Transform_c7b91c9bd5a24cbba16a486b2128d2ff_Out_1_Vector3 = TransformWorldToObject(world);
}
float3 _OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3;
if (_OutputSpace == 0)
{
_OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3 = _Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3;
}
else if (_OutputSpace == 1)
{
_OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3 = _Transform_c7b91c9bd5a24cbba16a486b2128d2ff_Out_1_Vector3;
}
else
{
_OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3 = _Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3;
}
float3 _Property_6e320129056e479593a9673a6404c2a3_Out_0_Vector3 = _NormalOS;
bool _Property_6e320129056e479593a9673a6404c2a3_Out_0_Vector3_IsConnected = _NormalOS_6443e352350b4de9ae048680d0b154e4_IsConnected;
float3 _BranchOnInputConnection_cdbf96fcdcc94bbc8e16e41d2064eac0_Out_3_Vector3 = _Property_6e320129056e479593a9673a6404c2a3_Out_0_Vector3_IsConnected ? _Property_6e320129056e479593a9673a6404c2a3_Out_0_Vector3 : IN.ObjectSpaceNormal;
float _Split_9df7389f2a034b16b14e80d7ea3cc9eb_R_1_Float = _BranchOnInputConnection_cdbf96fcdcc94bbc8e16e41d2064eac0_Out_3_Vector3[0];
float _Split_9df7389f2a034b16b14e80d7ea3cc9eb_G_2_Float = _BranchOnInputConnection_cdbf96fcdcc94bbc8e16e41d2064eac0_Out_3_Vector3[1];
float _Split_9df7389f2a034b16b14e80d7ea3cc9eb_B_3_Float = _BranchOnInputConnection_cdbf96fcdcc94bbc8e16e41d2064eac0_Out_3_Vector3[2];
float _Split_9df7389f2a034b16b14e80d7ea3cc9eb_A_4_Float = 0;
float4 _Combine_45448fd8d869482ba046251ea2a4986d_RGBA_4_Vector4;
float3 _Combine_45448fd8d869482ba046251ea2a4986d_RGB_5_Vector3;
float2 _Combine_45448fd8d869482ba046251ea2a4986d_RG_6_Vector2;
Unity_Combine_float(_Split_9df7389f2a034b16b14e80d7ea3cc9eb_R_1_Float, _Split_9df7389f2a034b16b14e80d7ea3cc9eb_G_2_Float, _Split_9df7389f2a034b16b14e80d7ea3cc9eb_B_3_Float, 0, _Combine_45448fd8d869482ba046251ea2a4986d_RGBA_4_Vector4, _Combine_45448fd8d869482ba046251ea2a4986d_RGB_5_Vector3, _Combine_45448fd8d869482ba046251ea2a4986d_RG_6_Vector2);
float4 _Multiply_fa8c745148884874b6bda6c5b00b1faf_Out_2_Vector4;
Unity_Multiply_float4x4_float4(_MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4, _Combine_45448fd8d869482ba046251ea2a4986d_RGBA_4_Vector4, _Multiply_fa8c745148884874b6bda6c5b00b1faf_Out_2_Vector4);
float3 _Swizzle_aac6fdf714634855bbb2102e1f03176a_Out_1_Vector3 = _Multiply_fa8c745148884874b6bda6c5b00b1faf_Out_2_Vector4.xyz;
float3 _Transform_ca9dd6096e414ef1aab3fc9c46b8a751_Out_1_Vector3;
{
// Converting Normal from AbsoluteWorld to Object via world space
float3 world;
world = _Swizzle_aac6fdf714634855bbb2102e1f03176a_Out_1_Vector3.xyz;
_Transform_ca9dd6096e414ef1aab3fc9c46b8a751_Out_1_Vector3 = TransformWorldToObjectNormal(world, true);
}
float3 _OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3;
if (_OutputSpace == 0)
{
_OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3 = _Swizzle_aac6fdf714634855bbb2102e1f03176a_Out_1_Vector3;
}
else if (_OutputSpace == 1)
{
_OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3 = _Transform_ca9dd6096e414ef1aab3fc9c46b8a751_Out_1_Vector3;
}
else
{
_OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3 = _Swizzle_aac6fdf714634855bbb2102e1f03176a_Out_1_Vector3;
}
float3 _Property_1caa087de4794f53880c4f3b725272b1_Out_0_Vector3 = _TangentOS;
bool _Property_1caa087de4794f53880c4f3b725272b1_Out_0_Vector3_IsConnected = _TangentOS_307e55ce70df463b90fe1b65f35443d9_IsConnected;
float3 _BranchOnInputConnection_49631555af044120aade11fe1ef46744_Out_3_Vector3 = _Property_1caa087de4794f53880c4f3b725272b1_Out_0_Vector3_IsConnected ? _Property_1caa087de4794f53880c4f3b725272b1_Out_0_Vector3 : IN.ObjectSpaceTangent;
float _Split_38da75d926c34146b97327ecc7d7d0e3_R_1_Float = _BranchOnInputConnection_49631555af044120aade11fe1ef46744_Out_3_Vector3[0];
float _Split_38da75d926c34146b97327ecc7d7d0e3_G_2_Float = _BranchOnInputConnection_49631555af044120aade11fe1ef46744_Out_3_Vector3[1];
float _Split_38da75d926c34146b97327ecc7d7d0e3_B_3_Float = _BranchOnInputConnection_49631555af044120aade11fe1ef46744_Out_3_Vector3[2];
float _Split_38da75d926c34146b97327ecc7d7d0e3_A_4_Float = 0;
float4 _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGBA_4_Vector4;
float3 _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGB_5_Vector3;
float2 _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RG_6_Vector2;
Unity_Combine_float(_Split_38da75d926c34146b97327ecc7d7d0e3_R_1_Float, _Split_38da75d926c34146b97327ecc7d7d0e3_G_2_Float, _Split_38da75d926c34146b97327ecc7d7d0e3_B_3_Float, 0, _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGBA_4_Vector4, _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGB_5_Vector3, _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RG_6_Vector2);
float4 _Multiply_88c2defdee7945aabfad7d073ac15b3c_Out_2_Vector4;
Unity_Multiply_float4x4_float4(_MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4, _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGBA_4_Vector4, _Multiply_88c2defdee7945aabfad7d073ac15b3c_Out_2_Vector4);
float3 _Swizzle_dadec3efd6244574a802fd3e0ab56bb5_Out_1_Vector3 = _Multiply_88c2defdee7945aabfad7d073ac15b3c_Out_2_Vector4.xyz;
float3 _Transform_8906312bacad44698b5e2899041600be_Out_1_Vector3;
{
// Converting Normal from AbsoluteWorld to Object via world space
float3 world;
world = _Swizzle_dadec3efd6244574a802fd3e0ab56bb5_Out_1_Vector3.xyz;
_Transform_8906312bacad44698b5e2899041600be_Out_1_Vector3 = TransformWorldToObjectNormal(world, true);
}
float3 _OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3;
if (_OutputSpace == 0)
{
_OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3 = _Swizzle_dadec3efd6244574a802fd3e0ab56bb5_Out_1_Vector3;
}
else if (_OutputSpace == 1)
{
_OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3 = _Transform_8906312bacad44698b5e2899041600be_Out_1_Vector3;
}
else
{
_OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3 = _Swizzle_dadec3efd6244574a802fd3e0ab56bb5_Out_1_Vector3;
}
Position_1 = _OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3;
Normal_2 = _OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3;
Tangent_3 = _OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3;
}

void Unity_Add_float4(float4 A, float4 B, out float4 Out)
{
    Out = A + B;
}

void Unity_Step_float(float Edge, float In, out float Out)
{
    Out = step(Edge, In);
}

// Custom interpolators pre vertex
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
float4 Color;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
float _InstanceID_2537a879f018425d9660432f4ea146f2_Out_0_Float;
UnityGetInstanceID_float(_InstanceID_2537a879f018425d9660432f4ea146f2_Out_0_Float);
float _Divide_63d9682156f042468629ccab8669beb8_Out_2_Float;
Unity_Divide_float(_InstanceID_2537a879f018425d9660432f4ea146f2_Out_0_Float, 37, _Divide_63d9682156f042468629ccab8669beb8_Out_2_Float);
float _Fraction_052ea01a8a0b4f83b7c6c139a0975ccc_Out_1_Float;
Unity_Fraction_float(_Divide_63d9682156f042468629ccab8669beb8_Out_2_Float, _Fraction_052ea01a8a0b4f83b7c6c139a0975ccc_Out_1_Float);
float4 _Property_19686efd1fb54b50a7d330cad1112554_Out_0_Vector4 = _Blade_Color_2;
float4 _Property_d254ba2921d340f982bfbcfaf5916ad3_Out_0_Vector4 = _Blade_Color_1;
float4 _Lerp_58d751d66dbc479a8656d14d2baf579f_Out_3_Vector4;
Unity_Lerp_float4(_Property_d254ba2921d340f982bfbcfaf5916ad3_Out_0_Vector4, _Property_19686efd1fb54b50a7d330cad1112554_Out_0_Vector4, (_Fraction_052ea01a8a0b4f83b7c6c139a0975ccc_Out_1_Float.xxxx), _Lerp_58d751d66dbc479a8656d14d2baf579f_Out_3_Vector4);
float _Property_dbcc12976b2c4eb4a63c1284e5f1d305_Out_0_Float = _Wind_Speed;
Bindings_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba;
_FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba.TimeParameters = IN.TimeParameters;
float2 _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindDirection_1_Vector2;
float _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindIntensity_2_Float;
float3 _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_Random_3_Vector3;
SG_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float(124, _Property_dbcc12976b2c4eb4a63c1284e5f1d305_Out_0_Float, 0.01, 0.2, 0.1, 0.2, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindDirection_1_Vector2, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindIntensity_2_Float, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_Random_3_Vector3);
float4x4 _Property_e6333f42f10045b8874ca797f7698f1d_Out_0_Matrix4 = _WireframeShaderMaskData1;
float _DynamicMask_50b2c29949db4c9087fc753d984c4250_Out_3_Float;
WireframeShaderDynamicMaskCube_float(IN.WorldSpacePosition, _Property_e6333f42f10045b8874ca797f7698f1d_Out_0_Matrix4, 0, _DynamicMask_50b2c29949db4c9087fc753d984c4250_Out_3_Float);
float4x4 _Property_37070fbe8a4e4576a732a3a352dec45e_Out_0_Matrix4 = _WireframeShaderMaskData2;
float _DynamicMask_0c15310c869f45a5bb095f810944777b_Out_3_Float;
WireframeShaderDynamicMaskSphere_float(IN.WorldSpacePosition, _Property_37070fbe8a4e4576a732a3a352dec45e_Out_0_Matrix4, 0, _DynamicMask_0c15310c869f45a5bb095f810944777b_Out_3_Float);
float _Add_4e24bc1118f94bdb89aeba5ac3067e43_Out_2_Float;
Unity_Add_float(_DynamicMask_50b2c29949db4c9087fc753d984c4250_Out_3_Float, _DynamicMask_0c15310c869f45a5bb095f810944777b_Out_3_Float, _Add_4e24bc1118f94bdb89aeba5ac3067e43_Out_2_Float);
float _Saturate_b1a2ecfe1d1842778d5653a46a7b1782_Out_1_Float;
Unity_Saturate_float(_Add_4e24bc1118f94bdb89aeba5ac3067e43_Out_2_Float, _Saturate_b1a2ecfe1d1842778d5653a46a7b1782_Out_1_Float);
float _OneMinus_153cdd2db72f462c97a7c55eccd49567_Out_1_Float;
Unity_OneMinus_float(_Saturate_b1a2ecfe1d1842778d5653a46a7b1782_Out_1_Float, _OneMinus_153cdd2db72f462c97a7c55eccd49567_Out_1_Float);
float _Multiply_cff561f8195f49188db426fdc084a6ce_Out_2_Float;
Unity_Multiply_float_float(_OneMinus_153cdd2db72f462c97a7c55eccd49567_Out_1_Float, -1, _Multiply_cff561f8195f49188db426fdc084a6ce_Out_2_Float);
float3 _Vector3_2dea481cbff74205a7cee900960a51a9_Out_0_Vector3 = float3(_FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindIntensity_2_Float, _Multiply_cff561f8195f49188db426fdc084a6ce_Out_2_Float, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindIntensity_2_Float);
Bindings_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f;
_BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f.ObjectSpaceNormal = IN.ObjectSpaceNormal;
_BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f.ObjectSpaceTangent = IN.ObjectSpaceTangent;
_BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f.ObjectSpacePosition = IN.ObjectSpacePosition;
float3 _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Position_1_Vector3;
float3 _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Normal_2_Vector3;
float3 _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Tangent_3_Vector3;
SG_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float(float3 (0, 0, 0), false, float3 (0, 0, 0), false, float3 (0, 0, 0), false, _Vector3_2dea481cbff74205a7cee900960a51a9_Out_0_Vector3, float3 (-1, 1, 1), float4 (0, 1, 0, 0), 1, _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f, _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Position_1_Vector3, _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Normal_2_Vector3, _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Tangent_3_Vector3);
description.Position = _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Position_1_Vector3;
description.Normal = IN.ObjectSpaceNormal;
description.Tangent = IN.ObjectSpaceTangent;
description.Color = _Lerp_58d751d66dbc479a8656d14d2baf579f_Out_3_Vector4;
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
output.Color = input.Color;
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
float _Property_a7bf99e3e3cf4540bc6bd38a6aaab41f_Out_0_Float = _Wireframe_Thickness;
float _Property_07fc055baf6a48729fd1b78fbf96db5c_Out_0_Float = _Wireframe_Anti_aliasing;
float4 _Add_c1cf3158744d4822974d88d98d719275_Out_2_Vector4;
Unity_Add_float4(IN.Color, 0, _Add_c1cf3158744d4822974d88d98d719275_Out_2_Vector4);
float _Property_b17d9045f0a44cc8ba01c677192340fe_Out_0_Float = _Metallic;
float _Property_4688972c65be441aa92fdbbcf5d9938e_Out_0_Float = _Smoothness;
float4x4 _Property_768bac82b0684cd0a21ed8a814d35a50_Out_0_Matrix4 = _WireframeShaderMaskData1;
float _DynamicMask_d8cbb946b52f4b01a4d3fd3bc3ea9de1_Out_3_Float;
WireframeShaderDynamicMaskCube_float(IN.WorldSpacePosition, _Property_768bac82b0684cd0a21ed8a814d35a50_Out_0_Matrix4, 0, _DynamicMask_d8cbb946b52f4b01a4d3fd3bc3ea9de1_Out_3_Float);
float4x4 _Property_39e6a912ee0647ed8335e7ab63cd4bed_Out_0_Matrix4 = _WireframeShaderMaskData2;
float _DynamicMask_e413c723ed49470ba4eca3bcf6362548_Out_3_Float;
WireframeShaderDynamicMaskSphere_float(IN.WorldSpacePosition, _Property_39e6a912ee0647ed8335e7ab63cd4bed_Out_0_Matrix4, 0, _DynamicMask_e413c723ed49470ba4eca3bcf6362548_Out_3_Float);
float _Add_c3b10d55feaf4b9baefa4948a8eaed75_Out_2_Float;
Unity_Add_float(_DynamicMask_d8cbb946b52f4b01a4d3fd3bc3ea9de1_Out_3_Float, _DynamicMask_e413c723ed49470ba4eca3bcf6362548_Out_3_Float, _Add_c3b10d55feaf4b9baefa4948a8eaed75_Out_2_Float);
float _Saturate_62dc9cf6a37b4fab9407e114176db70f_Out_1_Float;
Unity_Saturate_float(_Add_c3b10d55feaf4b9baefa4948a8eaed75_Out_2_Float, _Saturate_62dc9cf6a37b4fab9407e114176db70f_Out_1_Float);
float _Step_0f4fbf717a47479eaa1a77f0d38201d7_Out_2_Float;
Unity_Step_float(0.05, _Saturate_62dc9cf6a37b4fab9407e114176db70f_Out_1_Float, _Step_0f4fbf717a47479eaa1a77f0d38201d7_Out_2_Float);
surface.BaseColor = (_Add_c1cf3158744d4822974d88d98d719275_Out_2_Vector4.xyz);
surface.NormalTS = IN.TangentSpaceNormal;
surface.Emission = float3(0, 0, 0);
surface.Metallic = _Property_b17d9045f0a44cc8ba01c677192340fe_Out_0_Float;
surface.Smoothness = _Property_4688972c65be441aa92fdbbcf5d9938e_Out_0_Float;
surface.Occlusion = 1;
surface.Alpha = _Step_0f4fbf717a47479eaa1a77f0d38201d7_Out_2_Float;
surface.AlphaClipThreshold = 0.5;
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
    output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
    output.TimeParameters =                             _TimeParameters.xyz;

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

    output.Color = input.Color;



    output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


    output.WorldSpacePosition = input.positionWS;

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
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"

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
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_SHADOWCASTER
#define _ALPHATEST_ON 1
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
 float3 positionWS;
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
 float3 WorldSpacePosition;
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
 float3 WorldSpacePosition;
 float3 TimeParameters;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
 float3 positionWS : INTERP0;
 float3 normalWS : INTERP1;
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
return output;
}

Varyings UnpackVaryings (PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
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
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)
float _Wireframe_Thickness;
float _Wireframe_Anti_aliasing;
float4 _Blade_Color_2;
float4 _Blade_Color_1;
float _Metallic;
float _Smoothness;
float _Wind_Speed;
CBUFFER_END


// Object and Global properties
float4x4 _WireframeShaderMaskData1;
float4x4 _WireframeShaderMaskData2;

// Graph Includes
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"

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

void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
{
Out = A * B;
}

void Unity_Fraction_float3(float3 In, out float3 Out)
{
    Out = frac(In);
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Multiply_float_float(float A, float B, out float Out)
{
Out = A * B;
}

void Unity_Sine_float(float In, out float Out)
{
    Out = sin(In);
}

void Unity_DegreesToRadians_float(float In, out float Out)
{
    Out = radians(In);
}

void Unity_Rotate_Radians_float(float2 UV, float2 Center, float Rotation, out float2 Out)
{
    //rotation matrix
    UV -= Center;
    float s = sin(Rotation);
    float c = cos(Rotation);

    //center rotation matrix
    float2x2 rMatrix = float2x2(c, -s, s, c);
    rMatrix *= 0.5;
    rMatrix += 0.5;
    rMatrix = rMatrix*2 - 1;

    //multiply the UVs by the rotation matrix
    UV.xy = mul(UV.xy, rMatrix);
    UV += Center;

    Out = UV;
}

void Unity_Cosine_float(float In, out float Out)
{
    Out = cos(In);
}

void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
{
    RGBA = float4(R, G, B, A);
    RGB = float3(R, G, B);
    RG = float2(R, G);
}

void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
{
Out = A * B;
}

void Unity_DotProduct_float2(float2 A, float2 B, out float Out)
{
    Out = dot(A, B);
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
    Out = A + B;
}

void Unity_Negate_float(float In, out float Out)
{
    Out = -1 * In;
}

float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
{
float x; Hash_Tchou_2_1_float(p, x);
return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
{
float2 p = UV * Scale.xy;
float2 ip = floor(p);
float2 fp = frac(p);
float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
    Out = smoothstep(Edge1, Edge2, In);
}

void Unity_Saturate_float(float In, out float Out)
{
    Out = saturate(In);
}

void Unity_Lerp_float2(float2 A, float2 B, float2 T, out float2 Out)
{
    Out = lerp(A, B, T);
}

void Unity_SquareRoot_float(float In, out float Out)
{
    Out = sqrt(In);
}

void Unity_Maximum_float(float A, float B, out float Out)
{
    Out = max(A, B);
}

void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
{
    Out = A / B;
}

void Unity_Lerp_float(float A, float B, float T, out float Out)
{
    Out = lerp(A, B, T);
}

struct Bindings_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float
{
float3 TimeParameters;
};

void SG_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float(float _WindDirection, float _WindSpeed, float _WindDirectionVariation, float _PerBladeRandomTimeOffset, float _PerBladeWindIntensityVariation, float _WindIntensity, Bindings_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float IN, out float2 WindDirection_1, out float WindIntensity_2, out float3 Random_3)
{
float2 _Vector2_42921bc8d43346a4bbad7aa650d15962_Out_0_Vector2 = float2(1, 0);
float3 _Multiply_b6ed4cc094134c21943e217e6e271dae_Out_2_Vector3;
Unity_Multiply_float3_float3(SHADERGRAPH_OBJECT_POSITION, float3(37, 190, 29), _Multiply_b6ed4cc094134c21943e217e6e271dae_Out_2_Vector3);
float3 _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3;
Unity_Fraction_float3(_Multiply_b6ed4cc094134c21943e217e6e271dae_Out_2_Vector3, _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3);
float _Split_3967427c51c24bb79cef645976364a55_R_1_Float = _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3[0];
float _Split_3967427c51c24bb79cef645976364a55_G_2_Float = _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3[1];
float _Split_3967427c51c24bb79cef645976364a55_B_3_Float = _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3[2];
float _Split_3967427c51c24bb79cef645976364a55_A_4_Float = 0;
float _Add_ffd28ed6ff854810bd439fbdfc4b2cc2_Out_2_Float;
Unity_Add_float(IN.TimeParameters.x, _Split_3967427c51c24bb79cef645976364a55_B_3_Float, _Add_ffd28ed6ff854810bd439fbdfc4b2cc2_Out_2_Float);
float _Multiply_1185303c6c5d481190d5375ac379cab8_Out_2_Float;
Unity_Multiply_float_float(_Add_ffd28ed6ff854810bd439fbdfc4b2cc2_Out_2_Float, 3, _Multiply_1185303c6c5d481190d5375ac379cab8_Out_2_Float);
float _Sine_c919089f2f34401face2dd9897c9725c_Out_1_Float;
Unity_Sine_float(_Multiply_1185303c6c5d481190d5375ac379cab8_Out_2_Float, _Sine_c919089f2f34401face2dd9897c9725c_Out_1_Float);
float _Property_40290747561641a1bdf5517e6a93430d_Out_0_Float = _WindDirectionVariation;
float _DegreesToRadians_a7fe82a177484cd0af99b4027bc4e3bc_Out_1_Float;
Unity_DegreesToRadians_float(_Property_40290747561641a1bdf5517e6a93430d_Out_0_Float, _DegreesToRadians_a7fe82a177484cd0af99b4027bc4e3bc_Out_1_Float);
float _Multiply_c6dbf243e66746b490b03900b2b27467_Out_2_Float;
Unity_Multiply_float_float(_Sine_c919089f2f34401face2dd9897c9725c_Out_1_Float, _DegreesToRadians_a7fe82a177484cd0af99b4027bc4e3bc_Out_1_Float, _Multiply_c6dbf243e66746b490b03900b2b27467_Out_2_Float);
float2 _Rotate_cf73d535c5fb437aa68912dc0e09ba2f_Out_3_Vector2;
Unity_Rotate_Radians_float(_Vector2_42921bc8d43346a4bbad7aa650d15962_Out_0_Vector2, float2 (0, 0), _Multiply_c6dbf243e66746b490b03900b2b27467_Out_2_Float, _Rotate_cf73d535c5fb437aa68912dc0e09ba2f_Out_3_Vector2);
float _Property_df02aaa16377442d91f0c6be7d036d51_Out_0_Float = _WindDirection;
float _DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float;
Unity_DegreesToRadians_float(_Property_df02aaa16377442d91f0c6be7d036d51_Out_0_Float, _DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float);
float _Add_b051e3fa11c048dd978791daff07720d_Out_2_Float;
Unity_Add_float(_Multiply_c6dbf243e66746b490b03900b2b27467_Out_2_Float, _DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float, _Add_b051e3fa11c048dd978791daff07720d_Out_2_Float);
float _Cosine_0847069386bc4c12a90e1fe3eb1eee73_Out_1_Float;
Unity_Cosine_float(_Add_b051e3fa11c048dd978791daff07720d_Out_2_Float, _Cosine_0847069386bc4c12a90e1fe3eb1eee73_Out_1_Float);
float _Sine_379c87a4cd3c419293869dee73c52de0_Out_1_Float;
Unity_Sine_float(_Add_b051e3fa11c048dd978791daff07720d_Out_2_Float, _Sine_379c87a4cd3c419293869dee73c52de0_Out_1_Float);
float4 _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RGBA_4_Vector4;
float3 _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RGB_5_Vector3;
float2 _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RG_6_Vector2;
Unity_Combine_float(_Cosine_0847069386bc4c12a90e1fe3eb1eee73_Out_1_Float, _Sine_379c87a4cd3c419293869dee73c52de0_Out_1_Float, 0, 0, _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RGBA_4_Vector4, _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RGB_5_Vector3, _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RG_6_Vector2);
float2 _Swizzle_db678fc97ec448fda50408084410c787_Out_1_Vector2 = SHADERGRAPH_OBJECT_POSITION.xz;
float2 _Multiply_5833218c1a7c4d9586d5e8c69ddaabac_Out_2_Vector2;
Unity_Multiply_float2_float2(_Swizzle_db678fc97ec448fda50408084410c787_Out_1_Vector2, float2(0.5, 0.5), _Multiply_5833218c1a7c4d9586d5e8c69ddaabac_Out_2_Vector2);
float _Cosine_3388e8245f6647ca98f5aa9339130c65_Out_1_Float;
Unity_Cosine_float(_DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float, _Cosine_3388e8245f6647ca98f5aa9339130c65_Out_1_Float);
float _Sine_0b39f9f73b2c4016a046ad8da4b84c11_Out_1_Float;
Unity_Sine_float(_DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float, _Sine_0b39f9f73b2c4016a046ad8da4b84c11_Out_1_Float);
float4 _Combine_7f78efe98e4641c1981d47da9bbbe70f_RGBA_4_Vector4;
float3 _Combine_7f78efe98e4641c1981d47da9bbbe70f_RGB_5_Vector3;
float2 _Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2;
Unity_Combine_float(_Cosine_3388e8245f6647ca98f5aa9339130c65_Out_1_Float, _Sine_0b39f9f73b2c4016a046ad8da4b84c11_Out_1_Float, 0, 0, _Combine_7f78efe98e4641c1981d47da9bbbe70f_RGBA_4_Vector4, _Combine_7f78efe98e4641c1981d47da9bbbe70f_RGB_5_Vector3, _Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2);
float _DotProduct_27327ffeb11d404c96d6820c42272ca8_Out_2_Float;
Unity_DotProduct_float2(_Multiply_5833218c1a7c4d9586d5e8c69ddaabac_Out_2_Vector2, _Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2, _DotProduct_27327ffeb11d404c96d6820c42272ca8_Out_2_Float);
float _Multiply_8dc73d49a3b547a19bf5c0d8a4a09920_Out_2_Float;
Unity_Multiply_float_float(_DotProduct_27327ffeb11d404c96d6820c42272ca8_Out_2_Float, 0.7, _Multiply_8dc73d49a3b547a19bf5c0d8a4a09920_Out_2_Float);
float2 _Multiply_c8e01038fa74488a86a9759343a555f5_Out_2_Vector2;
Unity_Multiply_float2_float2((_Multiply_8dc73d49a3b547a19bf5c0d8a4a09920_Out_2_Float.xx), _Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2, _Multiply_c8e01038fa74488a86a9759343a555f5_Out_2_Vector2);
float _Multiply_69e2c5b6e72c4faf8d83ead16a5c0cd6_Out_2_Float;
Unity_Multiply_float_float(_Cosine_3388e8245f6647ca98f5aa9339130c65_Out_1_Float, -1.5708, _Multiply_69e2c5b6e72c4faf8d83ead16a5c0cd6_Out_2_Float);
float4 _Combine_2f7388d585a24290a659f20482d78d94_RGBA_4_Vector4;
float3 _Combine_2f7388d585a24290a659f20482d78d94_RGB_5_Vector3;
float2 _Combine_2f7388d585a24290a659f20482d78d94_RG_6_Vector2;
Unity_Combine_float(_Sine_0b39f9f73b2c4016a046ad8da4b84c11_Out_1_Float, _Multiply_69e2c5b6e72c4faf8d83ead16a5c0cd6_Out_2_Float, 0, 0, _Combine_2f7388d585a24290a659f20482d78d94_RGBA_4_Vector4, _Combine_2f7388d585a24290a659f20482d78d94_RGB_5_Vector3, _Combine_2f7388d585a24290a659f20482d78d94_RG_6_Vector2);
float _DotProduct_e3247c7835f0404893730bc5dcd240a0_Out_2_Float;
Unity_DotProduct_float2(_Multiply_5833218c1a7c4d9586d5e8c69ddaabac_Out_2_Vector2, _Combine_2f7388d585a24290a659f20482d78d94_RG_6_Vector2, _DotProduct_e3247c7835f0404893730bc5dcd240a0_Out_2_Float);
float2 _Multiply_ed7373e7bd6347f89e44dacc83ccf8c1_Out_2_Vector2;
Unity_Multiply_float2_float2((_DotProduct_e3247c7835f0404893730bc5dcd240a0_Out_2_Float.xx), _Combine_2f7388d585a24290a659f20482d78d94_RG_6_Vector2, _Multiply_ed7373e7bd6347f89e44dacc83ccf8c1_Out_2_Vector2);
float2 _Add_f950bfd74ec2464b89d972d5f43aa5b7_Out_2_Vector2;
Unity_Add_float2(_Multiply_c8e01038fa74488a86a9759343a555f5_Out_2_Vector2, _Multiply_ed7373e7bd6347f89e44dacc83ccf8c1_Out_2_Vector2, _Add_f950bfd74ec2464b89d972d5f43aa5b7_Out_2_Vector2);
float _Property_8c38f0ae55594c8787ad0a52af13731b_Out_0_Float = _WindSpeed;
float _Negate_47564bc9ce9645a5916ebc05fb9d63df_Out_1_Float;
Unity_Negate_float(_Property_8c38f0ae55594c8787ad0a52af13731b_Out_0_Float, _Negate_47564bc9ce9645a5916ebc05fb9d63df_Out_1_Float);
float _Multiply_e311852a737c422594c328d00e16414c_Out_2_Float;
Unity_Multiply_float_float(IN.TimeParameters.x, _Negate_47564bc9ce9645a5916ebc05fb9d63df_Out_1_Float, _Multiply_e311852a737c422594c328d00e16414c_Out_2_Float);
float _Property_347528760e804b2ab165732f176f3e97_Out_0_Float = _PerBladeRandomTimeOffset;
float _Multiply_0657e69a5c9b4cb783a0d4021b58a9b1_Out_2_Float;
Unity_Multiply_float_float(_Split_3967427c51c24bb79cef645976364a55_R_1_Float, _Property_347528760e804b2ab165732f176f3e97_Out_0_Float, _Multiply_0657e69a5c9b4cb783a0d4021b58a9b1_Out_2_Float);
float _Add_8e1a8d342102407f97ee7c7b88271e7d_Out_2_Float;
Unity_Add_float(_Multiply_e311852a737c422594c328d00e16414c_Out_2_Float, _Multiply_0657e69a5c9b4cb783a0d4021b58a9b1_Out_2_Float, _Add_8e1a8d342102407f97ee7c7b88271e7d_Out_2_Float);
float2 _Multiply_e39ee6e978424683b1858114ff959110_Out_2_Vector2;
Unity_Multiply_float2_float2(_Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2, (_Add_8e1a8d342102407f97ee7c7b88271e7d_Out_2_Float.xx), _Multiply_e39ee6e978424683b1858114ff959110_Out_2_Vector2);
float2 _Add_302cec4f55d64a65bf1160e9d23f9b71_Out_2_Vector2;
Unity_Add_float2(_Add_f950bfd74ec2464b89d972d5f43aa5b7_Out_2_Vector2, _Multiply_e39ee6e978424683b1858114ff959110_Out_2_Vector2, _Add_302cec4f55d64a65bf1160e9d23f9b71_Out_2_Vector2);
float _GradientNoise_f0d0f1452f814e03824cb2ceb16d6ad2_Out_2_Float;
Unity_GradientNoise_Deterministic_float(_Add_302cec4f55d64a65bf1160e9d23f9b71_Out_2_Vector2, 0.8, _GradientNoise_f0d0f1452f814e03824cb2ceb16d6ad2_Out_2_Float);
float _Smoothstep_4ca6b3a56ada4447bcfcabe8e1a6ee2b_Out_3_Float;
Unity_Smoothstep_float(-0.5, 1.5, _GradientNoise_f0d0f1452f814e03824cb2ceb16d6ad2_Out_2_Float, _Smoothstep_4ca6b3a56ada4447bcfcabe8e1a6ee2b_Out_3_Float);
float _Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float;
Unity_Saturate_float(_Smoothstep_4ca6b3a56ada4447bcfcabe8e1a6ee2b_Out_3_Float, _Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float);
float2 _Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2;
Unity_Lerp_float2(_Rotate_cf73d535c5fb437aa68912dc0e09ba2f_Out_3_Vector2, _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RG_6_Vector2, (_Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float.xx), _Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2);
float _DotProduct_b6d4ff1e79f54760a1f13bc5172c426b_Out_2_Float;
Unity_DotProduct_float2(_Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2, _Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2, _DotProduct_b6d4ff1e79f54760a1f13bc5172c426b_Out_2_Float);
float _SquareRoot_ec802f46201b45ac867b479ae083b1ee_Out_1_Float;
Unity_SquareRoot_float(_DotProduct_b6d4ff1e79f54760a1f13bc5172c426b_Out_2_Float, _SquareRoot_ec802f46201b45ac867b479ae083b1ee_Out_1_Float);
float _Maximum_56d7bd23f19a4866b35324380205c891_Out_2_Float;
Unity_Maximum_float(_SquareRoot_ec802f46201b45ac867b479ae083b1ee_Out_1_Float, 1E-05, _Maximum_56d7bd23f19a4866b35324380205c891_Out_2_Float);
float2 _Divide_bfbaafc2be014557bf2a163156a11a26_Out_2_Vector2;
Unity_Divide_float2(_Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2, (_Maximum_56d7bd23f19a4866b35324380205c891_Out_2_Float.xx), _Divide_bfbaafc2be014557bf2a163156a11a26_Out_2_Vector2);
float _Property_f1f58df30464478cb038a178d9e83682_Out_0_Float = _WindIntensity;
float _Add_ed2907c2a73440cc83d0b31366c5c7ae_Out_2_Float;
Unity_Add_float(IN.TimeParameters.x, _Split_3967427c51c24bb79cef645976364a55_B_3_Float, _Add_ed2907c2a73440cc83d0b31366c5c7ae_Out_2_Float);
float _Multiply_f0258532eb174f5393420713f84f6c8e_Out_2_Float;
Unity_Multiply_float_float(_Add_ed2907c2a73440cc83d0b31366c5c7ae_Out_2_Float, 2, _Multiply_f0258532eb174f5393420713f84f6c8e_Out_2_Float);
float _Sine_17bbe1505e754bbd9eedc59d0757132f_Out_1_Float;
Unity_Sine_float(_Multiply_f0258532eb174f5393420713f84f6c8e_Out_2_Float, _Sine_17bbe1505e754bbd9eedc59d0757132f_Out_1_Float);
float _Multiply_bfdbccbbf3584e1eb7d34b97e3a771c5_Out_2_Float;
Unity_Multiply_float_float(_Add_ed2907c2a73440cc83d0b31366c5c7ae_Out_2_Float, 3, _Multiply_bfdbccbbf3584e1eb7d34b97e3a771c5_Out_2_Float);
float _Sine_775bcfb1287e450094240576942d7a07_Out_1_Float;
Unity_Sine_float(_Multiply_bfdbccbbf3584e1eb7d34b97e3a771c5_Out_2_Float, _Sine_775bcfb1287e450094240576942d7a07_Out_1_Float);
float _Lerp_3cef0baddeb24a408278d7e18640ec45_Out_3_Float;
Unity_Lerp_float(_Sine_17bbe1505e754bbd9eedc59d0757132f_Out_1_Float, _Sine_775bcfb1287e450094240576942d7a07_Out_1_Float, _Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float, _Lerp_3cef0baddeb24a408278d7e18640ec45_Out_3_Float);
float _Property_59edf586db864b7a9b70a1acca2de692_Out_0_Float = _PerBladeWindIntensityVariation;
float _Multiply_13aa0e7d9b29467fa9ca1e4db82d023c_Out_2_Float;
Unity_Multiply_float_float(_Lerp_3cef0baddeb24a408278d7e18640ec45_Out_3_Float, _Property_59edf586db864b7a9b70a1acca2de692_Out_0_Float, _Multiply_13aa0e7d9b29467fa9ca1e4db82d023c_Out_2_Float);
float _Add_5a191ec83e8345689f15b7e3b2da0e21_Out_2_Float;
Unity_Add_float(_Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float, _Multiply_13aa0e7d9b29467fa9ca1e4db82d023c_Out_2_Float, _Add_5a191ec83e8345689f15b7e3b2da0e21_Out_2_Float);
float _Lerp_fb2e17ff05c44b1b8daaa248df6af035_Out_3_Float;
Unity_Lerp_float(0, _Property_f1f58df30464478cb038a178d9e83682_Out_0_Float, _Add_5a191ec83e8345689f15b7e3b2da0e21_Out_2_Float, _Lerp_fb2e17ff05c44b1b8daaa248df6af035_Out_3_Float);
float _Multiply_1565a94cae5148adaa4ad80e978368c6_Out_2_Float;
Unity_Multiply_float_float(_SquareRoot_ec802f46201b45ac867b479ae083b1ee_Out_1_Float, _Lerp_fb2e17ff05c44b1b8daaa248df6af035_Out_3_Float, _Multiply_1565a94cae5148adaa4ad80e978368c6_Out_2_Float);
WindDirection_1 = _Divide_bfbaafc2be014557bf2a163156a11a26_Out_2_Vector2;
WindIntensity_2 = _Multiply_1565a94cae5148adaa4ad80e978368c6_Out_2_Float;
Random_3 = _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3;
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

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_MatrixConstruction_Row_float (float4 M0, float4 M1, float4 M2, float4 M3, out float4x4 Out4x4, out float3x3 Out3x3, out float2x2 Out2x2)
{
Out4x4 = float4x4(M0.x, M0.y, M0.z, M0.w, M1.x, M1.y, M1.z, M1.w, M2.x, M2.y, M2.z, M2.w, M3.x, M3.y, M3.z, M3.w);
Out3x3 = float3x3(M0.x, M0.y, M0.z, M1.x, M1.y, M1.z, M2.x, M2.y, M2.z);
Out2x2 = float2x2(M0.x, M0.y, M1.x, M1.y);
}

void Unity_Multiply_float4x4_float4(float4x4 A, float4 B, out float4 Out)
{
Out = mul(A, B);
}

void Unity_Add_float3(float3 A, float3 B, out float3 Out)
{
    Out = A + B;
}

struct Bindings_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float
{
float3 ObjectSpaceNormal;
float3 ObjectSpaceTangent;
float3 ObjectSpacePosition;
};

void SG_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float(float3 _PositionOS, bool _PositionOS_3016357c5e324f0e825ebc4f84f71f27_IsConnected, float3 _NormalOS, bool _NormalOS_6443e352350b4de9ae048680d0b154e4_IsConnected, float3 _TangentOS, bool _TangentOS_307e55ce70df463b90fe1b65f35443d9_IsConnected, float3 _PivotOffset, float3 _AxisOrientation, float4 _PivotAxis, int _OutputSpace, Bindings_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float IN, out float3 Position_1, out float3 Normal_2, out float3 Tangent_3)
{
float4 _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M0_1_Vector4 = UNITY_MATRIX_I_V[0];
float4 _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M1_2_Vector4 = UNITY_MATRIX_I_V[1];
float4 _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M2_3_Vector4 = UNITY_MATRIX_I_V[2];
float4 _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M3_4_Vector4 = UNITY_MATRIX_I_V[3];
float4 _Property_ecb1ace83c9743d78d86f543dfba0991_Out_0_Vector4 = _PivotAxis;
float4x4 _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4;
float3x3 _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var3x3_5_Matrix3;
float2x2 _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var2x2_6_Matrix2;
Unity_MatrixConstruction_Row_float(_MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M0_1_Vector4, _Property_ecb1ace83c9743d78d86f543dfba0991_Out_0_Vector4, _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M2_3_Vector4, _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M3_4_Vector4, _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4, _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var3x3_5_Matrix3, _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var2x2_6_Matrix2);
float3 _Property_41894a58127942aaae689326334e61fc_Out_0_Vector3 = _PositionOS;
bool _Property_41894a58127942aaae689326334e61fc_Out_0_Vector3_IsConnected = _PositionOS_3016357c5e324f0e825ebc4f84f71f27_IsConnected;
float3 _BranchOnInputConnection_9706ae1834c64f399a8f850ec2dbbb55_Out_3_Vector3 = _Property_41894a58127942aaae689326334e61fc_Out_0_Vector3_IsConnected ? _Property_41894a58127942aaae689326334e61fc_Out_0_Vector3 : IN.ObjectSpacePosition;
float3 _Multiply_cc7f14533a6c433b98a087240efbf8f8_Out_2_Vector3;
Unity_Multiply_float3_float3(_BranchOnInputConnection_9706ae1834c64f399a8f850ec2dbbb55_Out_3_Vector3, float3(length(float3(UNITY_MATRIX_M[0].x, UNITY_MATRIX_M[1].x, UNITY_MATRIX_M[2].x)),
                             length(float3(UNITY_MATRIX_M[0].y, UNITY_MATRIX_M[1].y, UNITY_MATRIX_M[2].y)),
                             length(float3(UNITY_MATRIX_M[0].z, UNITY_MATRIX_M[1].z, UNITY_MATRIX_M[2].z))), _Multiply_cc7f14533a6c433b98a087240efbf8f8_Out_2_Vector3);
float3 _Property_5affae77929448b994beb6b8ffca0b9a_Out_0_Vector3 = _AxisOrientation;
float3 _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3;
Unity_Multiply_float3_float3(_Multiply_cc7f14533a6c433b98a087240efbf8f8_Out_2_Vector3, _Property_5affae77929448b994beb6b8ffca0b9a_Out_0_Vector3, _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3);
float _Split_d13fd31126ee4b94b419613a1463bb24_R_1_Float = _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3[0];
float _Split_d13fd31126ee4b94b419613a1463bb24_G_2_Float = _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3[1];
float _Split_d13fd31126ee4b94b419613a1463bb24_B_3_Float = _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3[2];
float _Split_d13fd31126ee4b94b419613a1463bb24_A_4_Float = 0;
float4 _Combine_3e277c5566fd4af089d839ecf52390f8_RGBA_4_Vector4;
float3 _Combine_3e277c5566fd4af089d839ecf52390f8_RGB_5_Vector3;
float2 _Combine_3e277c5566fd4af089d839ecf52390f8_RG_6_Vector2;
Unity_Combine_float(_Split_d13fd31126ee4b94b419613a1463bb24_R_1_Float, _Split_d13fd31126ee4b94b419613a1463bb24_G_2_Float, _Split_d13fd31126ee4b94b419613a1463bb24_B_3_Float, 0, _Combine_3e277c5566fd4af089d839ecf52390f8_RGBA_4_Vector4, _Combine_3e277c5566fd4af089d839ecf52390f8_RGB_5_Vector3, _Combine_3e277c5566fd4af089d839ecf52390f8_RG_6_Vector2);
float4 _Multiply_b71678c838b541ce80f71613338319bb_Out_2_Vector4;
Unity_Multiply_float4x4_float4(_MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4, _Combine_3e277c5566fd4af089d839ecf52390f8_RGBA_4_Vector4, _Multiply_b71678c838b541ce80f71613338319bb_Out_2_Vector4);
float3 _Swizzle_533fdda21ca44bb783d1af6880283be8_Out_1_Vector3 = _Multiply_b71678c838b541ce80f71613338319bb_Out_2_Vector4.xyz;
float3 _Add_10d54894eefd4263a31339a71dc6a555_Out_2_Vector3;
Unity_Add_float3(_Swizzle_533fdda21ca44bb783d1af6880283be8_Out_1_Vector3, SHADERGRAPH_OBJECT_POSITION, _Add_10d54894eefd4263a31339a71dc6a555_Out_2_Vector3);
float3 _Property_3e2f21cb09ef4a95a3da553bc8c93907_Out_0_Vector3 = _PivotOffset;
float3 _Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3;
Unity_Add_float3(_Add_10d54894eefd4263a31339a71dc6a555_Out_2_Vector3, _Property_3e2f21cb09ef4a95a3da553bc8c93907_Out_0_Vector3, _Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3);
float3 _Transform_c7b91c9bd5a24cbba16a486b2128d2ff_Out_1_Vector3;
{
// Converting Position from AbsoluteWorld to Object via world space
float3 world;
world = GetCameraRelativePositionWS(_Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3.xyz);
_Transform_c7b91c9bd5a24cbba16a486b2128d2ff_Out_1_Vector3 = TransformWorldToObject(world);
}
float3 _OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3;
if (_OutputSpace == 0)
{
_OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3 = _Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3;
}
else if (_OutputSpace == 1)
{
_OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3 = _Transform_c7b91c9bd5a24cbba16a486b2128d2ff_Out_1_Vector3;
}
else
{
_OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3 = _Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3;
}
float3 _Property_6e320129056e479593a9673a6404c2a3_Out_0_Vector3 = _NormalOS;
bool _Property_6e320129056e479593a9673a6404c2a3_Out_0_Vector3_IsConnected = _NormalOS_6443e352350b4de9ae048680d0b154e4_IsConnected;
float3 _BranchOnInputConnection_cdbf96fcdcc94bbc8e16e41d2064eac0_Out_3_Vector3 = _Property_6e320129056e479593a9673a6404c2a3_Out_0_Vector3_IsConnected ? _Property_6e320129056e479593a9673a6404c2a3_Out_0_Vector3 : IN.ObjectSpaceNormal;
float _Split_9df7389f2a034b16b14e80d7ea3cc9eb_R_1_Float = _BranchOnInputConnection_cdbf96fcdcc94bbc8e16e41d2064eac0_Out_3_Vector3[0];
float _Split_9df7389f2a034b16b14e80d7ea3cc9eb_G_2_Float = _BranchOnInputConnection_cdbf96fcdcc94bbc8e16e41d2064eac0_Out_3_Vector3[1];
float _Split_9df7389f2a034b16b14e80d7ea3cc9eb_B_3_Float = _BranchOnInputConnection_cdbf96fcdcc94bbc8e16e41d2064eac0_Out_3_Vector3[2];
float _Split_9df7389f2a034b16b14e80d7ea3cc9eb_A_4_Float = 0;
float4 _Combine_45448fd8d869482ba046251ea2a4986d_RGBA_4_Vector4;
float3 _Combine_45448fd8d869482ba046251ea2a4986d_RGB_5_Vector3;
float2 _Combine_45448fd8d869482ba046251ea2a4986d_RG_6_Vector2;
Unity_Combine_float(_Split_9df7389f2a034b16b14e80d7ea3cc9eb_R_1_Float, _Split_9df7389f2a034b16b14e80d7ea3cc9eb_G_2_Float, _Split_9df7389f2a034b16b14e80d7ea3cc9eb_B_3_Float, 0, _Combine_45448fd8d869482ba046251ea2a4986d_RGBA_4_Vector4, _Combine_45448fd8d869482ba046251ea2a4986d_RGB_5_Vector3, _Combine_45448fd8d869482ba046251ea2a4986d_RG_6_Vector2);
float4 _Multiply_fa8c745148884874b6bda6c5b00b1faf_Out_2_Vector4;
Unity_Multiply_float4x4_float4(_MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4, _Combine_45448fd8d869482ba046251ea2a4986d_RGBA_4_Vector4, _Multiply_fa8c745148884874b6bda6c5b00b1faf_Out_2_Vector4);
float3 _Swizzle_aac6fdf714634855bbb2102e1f03176a_Out_1_Vector3 = _Multiply_fa8c745148884874b6bda6c5b00b1faf_Out_2_Vector4.xyz;
float3 _Transform_ca9dd6096e414ef1aab3fc9c46b8a751_Out_1_Vector3;
{
// Converting Normal from AbsoluteWorld to Object via world space
float3 world;
world = _Swizzle_aac6fdf714634855bbb2102e1f03176a_Out_1_Vector3.xyz;
_Transform_ca9dd6096e414ef1aab3fc9c46b8a751_Out_1_Vector3 = TransformWorldToObjectNormal(world, true);
}
float3 _OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3;
if (_OutputSpace == 0)
{
_OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3 = _Swizzle_aac6fdf714634855bbb2102e1f03176a_Out_1_Vector3;
}
else if (_OutputSpace == 1)
{
_OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3 = _Transform_ca9dd6096e414ef1aab3fc9c46b8a751_Out_1_Vector3;
}
else
{
_OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3 = _Swizzle_aac6fdf714634855bbb2102e1f03176a_Out_1_Vector3;
}
float3 _Property_1caa087de4794f53880c4f3b725272b1_Out_0_Vector3 = _TangentOS;
bool _Property_1caa087de4794f53880c4f3b725272b1_Out_0_Vector3_IsConnected = _TangentOS_307e55ce70df463b90fe1b65f35443d9_IsConnected;
float3 _BranchOnInputConnection_49631555af044120aade11fe1ef46744_Out_3_Vector3 = _Property_1caa087de4794f53880c4f3b725272b1_Out_0_Vector3_IsConnected ? _Property_1caa087de4794f53880c4f3b725272b1_Out_0_Vector3 : IN.ObjectSpaceTangent;
float _Split_38da75d926c34146b97327ecc7d7d0e3_R_1_Float = _BranchOnInputConnection_49631555af044120aade11fe1ef46744_Out_3_Vector3[0];
float _Split_38da75d926c34146b97327ecc7d7d0e3_G_2_Float = _BranchOnInputConnection_49631555af044120aade11fe1ef46744_Out_3_Vector3[1];
float _Split_38da75d926c34146b97327ecc7d7d0e3_B_3_Float = _BranchOnInputConnection_49631555af044120aade11fe1ef46744_Out_3_Vector3[2];
float _Split_38da75d926c34146b97327ecc7d7d0e3_A_4_Float = 0;
float4 _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGBA_4_Vector4;
float3 _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGB_5_Vector3;
float2 _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RG_6_Vector2;
Unity_Combine_float(_Split_38da75d926c34146b97327ecc7d7d0e3_R_1_Float, _Split_38da75d926c34146b97327ecc7d7d0e3_G_2_Float, _Split_38da75d926c34146b97327ecc7d7d0e3_B_3_Float, 0, _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGBA_4_Vector4, _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGB_5_Vector3, _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RG_6_Vector2);
float4 _Multiply_88c2defdee7945aabfad7d073ac15b3c_Out_2_Vector4;
Unity_Multiply_float4x4_float4(_MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4, _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGBA_4_Vector4, _Multiply_88c2defdee7945aabfad7d073ac15b3c_Out_2_Vector4);
float3 _Swizzle_dadec3efd6244574a802fd3e0ab56bb5_Out_1_Vector3 = _Multiply_88c2defdee7945aabfad7d073ac15b3c_Out_2_Vector4.xyz;
float3 _Transform_8906312bacad44698b5e2899041600be_Out_1_Vector3;
{
// Converting Normal from AbsoluteWorld to Object via world space
float3 world;
world = _Swizzle_dadec3efd6244574a802fd3e0ab56bb5_Out_1_Vector3.xyz;
_Transform_8906312bacad44698b5e2899041600be_Out_1_Vector3 = TransformWorldToObjectNormal(world, true);
}
float3 _OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3;
if (_OutputSpace == 0)
{
_OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3 = _Swizzle_dadec3efd6244574a802fd3e0ab56bb5_Out_1_Vector3;
}
else if (_OutputSpace == 1)
{
_OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3 = _Transform_8906312bacad44698b5e2899041600be_Out_1_Vector3;
}
else
{
_OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3 = _Swizzle_dadec3efd6244574a802fd3e0ab56bb5_Out_1_Vector3;
}
Position_1 = _OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3;
Normal_2 = _OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3;
Tangent_3 = _OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3;
}

void Unity_Step_float(float Edge, float In, out float Out)
{
    Out = step(Edge, In);
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
float _Property_dbcc12976b2c4eb4a63c1284e5f1d305_Out_0_Float = _Wind_Speed;
Bindings_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba;
_FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba.TimeParameters = IN.TimeParameters;
float2 _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindDirection_1_Vector2;
float _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindIntensity_2_Float;
float3 _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_Random_3_Vector3;
SG_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float(124, _Property_dbcc12976b2c4eb4a63c1284e5f1d305_Out_0_Float, 0.01, 0.2, 0.1, 0.2, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindDirection_1_Vector2, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindIntensity_2_Float, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_Random_3_Vector3);
float4x4 _Property_e6333f42f10045b8874ca797f7698f1d_Out_0_Matrix4 = _WireframeShaderMaskData1;
float _DynamicMask_50b2c29949db4c9087fc753d984c4250_Out_3_Float;
WireframeShaderDynamicMaskCube_float(IN.WorldSpacePosition, _Property_e6333f42f10045b8874ca797f7698f1d_Out_0_Matrix4, 0, _DynamicMask_50b2c29949db4c9087fc753d984c4250_Out_3_Float);
float4x4 _Property_37070fbe8a4e4576a732a3a352dec45e_Out_0_Matrix4 = _WireframeShaderMaskData2;
float _DynamicMask_0c15310c869f45a5bb095f810944777b_Out_3_Float;
WireframeShaderDynamicMaskSphere_float(IN.WorldSpacePosition, _Property_37070fbe8a4e4576a732a3a352dec45e_Out_0_Matrix4, 0, _DynamicMask_0c15310c869f45a5bb095f810944777b_Out_3_Float);
float _Add_4e24bc1118f94bdb89aeba5ac3067e43_Out_2_Float;
Unity_Add_float(_DynamicMask_50b2c29949db4c9087fc753d984c4250_Out_3_Float, _DynamicMask_0c15310c869f45a5bb095f810944777b_Out_3_Float, _Add_4e24bc1118f94bdb89aeba5ac3067e43_Out_2_Float);
float _Saturate_b1a2ecfe1d1842778d5653a46a7b1782_Out_1_Float;
Unity_Saturate_float(_Add_4e24bc1118f94bdb89aeba5ac3067e43_Out_2_Float, _Saturate_b1a2ecfe1d1842778d5653a46a7b1782_Out_1_Float);
float _OneMinus_153cdd2db72f462c97a7c55eccd49567_Out_1_Float;
Unity_OneMinus_float(_Saturate_b1a2ecfe1d1842778d5653a46a7b1782_Out_1_Float, _OneMinus_153cdd2db72f462c97a7c55eccd49567_Out_1_Float);
float _Multiply_cff561f8195f49188db426fdc084a6ce_Out_2_Float;
Unity_Multiply_float_float(_OneMinus_153cdd2db72f462c97a7c55eccd49567_Out_1_Float, -1, _Multiply_cff561f8195f49188db426fdc084a6ce_Out_2_Float);
float3 _Vector3_2dea481cbff74205a7cee900960a51a9_Out_0_Vector3 = float3(_FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindIntensity_2_Float, _Multiply_cff561f8195f49188db426fdc084a6ce_Out_2_Float, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindIntensity_2_Float);
Bindings_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f;
_BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f.ObjectSpaceNormal = IN.ObjectSpaceNormal;
_BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f.ObjectSpaceTangent = IN.ObjectSpaceTangent;
_BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f.ObjectSpacePosition = IN.ObjectSpacePosition;
float3 _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Position_1_Vector3;
float3 _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Normal_2_Vector3;
float3 _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Tangent_3_Vector3;
SG_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float(float3 (0, 0, 0), false, float3 (0, 0, 0), false, float3 (0, 0, 0), false, _Vector3_2dea481cbff74205a7cee900960a51a9_Out_0_Vector3, float3 (-1, 1, 1), float4 (0, 1, 0, 0), 1, _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f, _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Position_1_Vector3, _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Normal_2_Vector3, _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Tangent_3_Vector3);
description.Position = _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Position_1_Vector3;
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
float4x4 _Property_768bac82b0684cd0a21ed8a814d35a50_Out_0_Matrix4 = _WireframeShaderMaskData1;
float _DynamicMask_d8cbb946b52f4b01a4d3fd3bc3ea9de1_Out_3_Float;
WireframeShaderDynamicMaskCube_float(IN.WorldSpacePosition, _Property_768bac82b0684cd0a21ed8a814d35a50_Out_0_Matrix4, 0, _DynamicMask_d8cbb946b52f4b01a4d3fd3bc3ea9de1_Out_3_Float);
float4x4 _Property_39e6a912ee0647ed8335e7ab63cd4bed_Out_0_Matrix4 = _WireframeShaderMaskData2;
float _DynamicMask_e413c723ed49470ba4eca3bcf6362548_Out_3_Float;
WireframeShaderDynamicMaskSphere_float(IN.WorldSpacePosition, _Property_39e6a912ee0647ed8335e7ab63cd4bed_Out_0_Matrix4, 0, _DynamicMask_e413c723ed49470ba4eca3bcf6362548_Out_3_Float);
float _Add_c3b10d55feaf4b9baefa4948a8eaed75_Out_2_Float;
Unity_Add_float(_DynamicMask_d8cbb946b52f4b01a4d3fd3bc3ea9de1_Out_3_Float, _DynamicMask_e413c723ed49470ba4eca3bcf6362548_Out_3_Float, _Add_c3b10d55feaf4b9baefa4948a8eaed75_Out_2_Float);
float _Saturate_62dc9cf6a37b4fab9407e114176db70f_Out_1_Float;
Unity_Saturate_float(_Add_c3b10d55feaf4b9baefa4948a8eaed75_Out_2_Float, _Saturate_62dc9cf6a37b4fab9407e114176db70f_Out_1_Float);
float _Step_0f4fbf717a47479eaa1a77f0d38201d7_Out_2_Float;
Unity_Step_float(0.05, _Saturate_62dc9cf6a37b4fab9407e114176db70f_Out_1_Float, _Step_0f4fbf717a47479eaa1a77f0d38201d7_Out_2_Float);
surface.Alpha = _Step_0f4fbf717a47479eaa1a77f0d38201d7_Out_2_Float;
surface.AlphaClipThreshold = 0.5;
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
    output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
    output.TimeParameters =                             _TimeParameters.xyz;

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
#define VARYINGS_NEED_POSITION_WS
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_DEPTHONLY
#define _ALPHATEST_ON 1
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
 float3 positionWS;
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
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
 float3 WorldSpacePosition;
 float3 TimeParameters;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
 float3 positionWS : INTERP0;
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
float _Wireframe_Thickness;
float _Wireframe_Anti_aliasing;
float4 _Blade_Color_2;
float4 _Blade_Color_1;
float _Metallic;
float _Smoothness;
float _Wind_Speed;
CBUFFER_END


// Object and Global properties
float4x4 _WireframeShaderMaskData1;
float4x4 _WireframeShaderMaskData2;

// Graph Includes
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"

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

void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
{
Out = A * B;
}

void Unity_Fraction_float3(float3 In, out float3 Out)
{
    Out = frac(In);
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Multiply_float_float(float A, float B, out float Out)
{
Out = A * B;
}

void Unity_Sine_float(float In, out float Out)
{
    Out = sin(In);
}

void Unity_DegreesToRadians_float(float In, out float Out)
{
    Out = radians(In);
}

void Unity_Rotate_Radians_float(float2 UV, float2 Center, float Rotation, out float2 Out)
{
    //rotation matrix
    UV -= Center;
    float s = sin(Rotation);
    float c = cos(Rotation);

    //center rotation matrix
    float2x2 rMatrix = float2x2(c, -s, s, c);
    rMatrix *= 0.5;
    rMatrix += 0.5;
    rMatrix = rMatrix*2 - 1;

    //multiply the UVs by the rotation matrix
    UV.xy = mul(UV.xy, rMatrix);
    UV += Center;

    Out = UV;
}

void Unity_Cosine_float(float In, out float Out)
{
    Out = cos(In);
}

void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
{
    RGBA = float4(R, G, B, A);
    RGB = float3(R, G, B);
    RG = float2(R, G);
}

void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
{
Out = A * B;
}

void Unity_DotProduct_float2(float2 A, float2 B, out float Out)
{
    Out = dot(A, B);
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
    Out = A + B;
}

void Unity_Negate_float(float In, out float Out)
{
    Out = -1 * In;
}

float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
{
float x; Hash_Tchou_2_1_float(p, x);
return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
{
float2 p = UV * Scale.xy;
float2 ip = floor(p);
float2 fp = frac(p);
float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
    Out = smoothstep(Edge1, Edge2, In);
}

void Unity_Saturate_float(float In, out float Out)
{
    Out = saturate(In);
}

void Unity_Lerp_float2(float2 A, float2 B, float2 T, out float2 Out)
{
    Out = lerp(A, B, T);
}

void Unity_SquareRoot_float(float In, out float Out)
{
    Out = sqrt(In);
}

void Unity_Maximum_float(float A, float B, out float Out)
{
    Out = max(A, B);
}

void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
{
    Out = A / B;
}

void Unity_Lerp_float(float A, float B, float T, out float Out)
{
    Out = lerp(A, B, T);
}

struct Bindings_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float
{
float3 TimeParameters;
};

void SG_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float(float _WindDirection, float _WindSpeed, float _WindDirectionVariation, float _PerBladeRandomTimeOffset, float _PerBladeWindIntensityVariation, float _WindIntensity, Bindings_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float IN, out float2 WindDirection_1, out float WindIntensity_2, out float3 Random_3)
{
float2 _Vector2_42921bc8d43346a4bbad7aa650d15962_Out_0_Vector2 = float2(1, 0);
float3 _Multiply_b6ed4cc094134c21943e217e6e271dae_Out_2_Vector3;
Unity_Multiply_float3_float3(SHADERGRAPH_OBJECT_POSITION, float3(37, 190, 29), _Multiply_b6ed4cc094134c21943e217e6e271dae_Out_2_Vector3);
float3 _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3;
Unity_Fraction_float3(_Multiply_b6ed4cc094134c21943e217e6e271dae_Out_2_Vector3, _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3);
float _Split_3967427c51c24bb79cef645976364a55_R_1_Float = _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3[0];
float _Split_3967427c51c24bb79cef645976364a55_G_2_Float = _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3[1];
float _Split_3967427c51c24bb79cef645976364a55_B_3_Float = _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3[2];
float _Split_3967427c51c24bb79cef645976364a55_A_4_Float = 0;
float _Add_ffd28ed6ff854810bd439fbdfc4b2cc2_Out_2_Float;
Unity_Add_float(IN.TimeParameters.x, _Split_3967427c51c24bb79cef645976364a55_B_3_Float, _Add_ffd28ed6ff854810bd439fbdfc4b2cc2_Out_2_Float);
float _Multiply_1185303c6c5d481190d5375ac379cab8_Out_2_Float;
Unity_Multiply_float_float(_Add_ffd28ed6ff854810bd439fbdfc4b2cc2_Out_2_Float, 3, _Multiply_1185303c6c5d481190d5375ac379cab8_Out_2_Float);
float _Sine_c919089f2f34401face2dd9897c9725c_Out_1_Float;
Unity_Sine_float(_Multiply_1185303c6c5d481190d5375ac379cab8_Out_2_Float, _Sine_c919089f2f34401face2dd9897c9725c_Out_1_Float);
float _Property_40290747561641a1bdf5517e6a93430d_Out_0_Float = _WindDirectionVariation;
float _DegreesToRadians_a7fe82a177484cd0af99b4027bc4e3bc_Out_1_Float;
Unity_DegreesToRadians_float(_Property_40290747561641a1bdf5517e6a93430d_Out_0_Float, _DegreesToRadians_a7fe82a177484cd0af99b4027bc4e3bc_Out_1_Float);
float _Multiply_c6dbf243e66746b490b03900b2b27467_Out_2_Float;
Unity_Multiply_float_float(_Sine_c919089f2f34401face2dd9897c9725c_Out_1_Float, _DegreesToRadians_a7fe82a177484cd0af99b4027bc4e3bc_Out_1_Float, _Multiply_c6dbf243e66746b490b03900b2b27467_Out_2_Float);
float2 _Rotate_cf73d535c5fb437aa68912dc0e09ba2f_Out_3_Vector2;
Unity_Rotate_Radians_float(_Vector2_42921bc8d43346a4bbad7aa650d15962_Out_0_Vector2, float2 (0, 0), _Multiply_c6dbf243e66746b490b03900b2b27467_Out_2_Float, _Rotate_cf73d535c5fb437aa68912dc0e09ba2f_Out_3_Vector2);
float _Property_df02aaa16377442d91f0c6be7d036d51_Out_0_Float = _WindDirection;
float _DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float;
Unity_DegreesToRadians_float(_Property_df02aaa16377442d91f0c6be7d036d51_Out_0_Float, _DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float);
float _Add_b051e3fa11c048dd978791daff07720d_Out_2_Float;
Unity_Add_float(_Multiply_c6dbf243e66746b490b03900b2b27467_Out_2_Float, _DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float, _Add_b051e3fa11c048dd978791daff07720d_Out_2_Float);
float _Cosine_0847069386bc4c12a90e1fe3eb1eee73_Out_1_Float;
Unity_Cosine_float(_Add_b051e3fa11c048dd978791daff07720d_Out_2_Float, _Cosine_0847069386bc4c12a90e1fe3eb1eee73_Out_1_Float);
float _Sine_379c87a4cd3c419293869dee73c52de0_Out_1_Float;
Unity_Sine_float(_Add_b051e3fa11c048dd978791daff07720d_Out_2_Float, _Sine_379c87a4cd3c419293869dee73c52de0_Out_1_Float);
float4 _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RGBA_4_Vector4;
float3 _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RGB_5_Vector3;
float2 _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RG_6_Vector2;
Unity_Combine_float(_Cosine_0847069386bc4c12a90e1fe3eb1eee73_Out_1_Float, _Sine_379c87a4cd3c419293869dee73c52de0_Out_1_Float, 0, 0, _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RGBA_4_Vector4, _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RGB_5_Vector3, _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RG_6_Vector2);
float2 _Swizzle_db678fc97ec448fda50408084410c787_Out_1_Vector2 = SHADERGRAPH_OBJECT_POSITION.xz;
float2 _Multiply_5833218c1a7c4d9586d5e8c69ddaabac_Out_2_Vector2;
Unity_Multiply_float2_float2(_Swizzle_db678fc97ec448fda50408084410c787_Out_1_Vector2, float2(0.5, 0.5), _Multiply_5833218c1a7c4d9586d5e8c69ddaabac_Out_2_Vector2);
float _Cosine_3388e8245f6647ca98f5aa9339130c65_Out_1_Float;
Unity_Cosine_float(_DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float, _Cosine_3388e8245f6647ca98f5aa9339130c65_Out_1_Float);
float _Sine_0b39f9f73b2c4016a046ad8da4b84c11_Out_1_Float;
Unity_Sine_float(_DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float, _Sine_0b39f9f73b2c4016a046ad8da4b84c11_Out_1_Float);
float4 _Combine_7f78efe98e4641c1981d47da9bbbe70f_RGBA_4_Vector4;
float3 _Combine_7f78efe98e4641c1981d47da9bbbe70f_RGB_5_Vector3;
float2 _Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2;
Unity_Combine_float(_Cosine_3388e8245f6647ca98f5aa9339130c65_Out_1_Float, _Sine_0b39f9f73b2c4016a046ad8da4b84c11_Out_1_Float, 0, 0, _Combine_7f78efe98e4641c1981d47da9bbbe70f_RGBA_4_Vector4, _Combine_7f78efe98e4641c1981d47da9bbbe70f_RGB_5_Vector3, _Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2);
float _DotProduct_27327ffeb11d404c96d6820c42272ca8_Out_2_Float;
Unity_DotProduct_float2(_Multiply_5833218c1a7c4d9586d5e8c69ddaabac_Out_2_Vector2, _Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2, _DotProduct_27327ffeb11d404c96d6820c42272ca8_Out_2_Float);
float _Multiply_8dc73d49a3b547a19bf5c0d8a4a09920_Out_2_Float;
Unity_Multiply_float_float(_DotProduct_27327ffeb11d404c96d6820c42272ca8_Out_2_Float, 0.7, _Multiply_8dc73d49a3b547a19bf5c0d8a4a09920_Out_2_Float);
float2 _Multiply_c8e01038fa74488a86a9759343a555f5_Out_2_Vector2;
Unity_Multiply_float2_float2((_Multiply_8dc73d49a3b547a19bf5c0d8a4a09920_Out_2_Float.xx), _Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2, _Multiply_c8e01038fa74488a86a9759343a555f5_Out_2_Vector2);
float _Multiply_69e2c5b6e72c4faf8d83ead16a5c0cd6_Out_2_Float;
Unity_Multiply_float_float(_Cosine_3388e8245f6647ca98f5aa9339130c65_Out_1_Float, -1.5708, _Multiply_69e2c5b6e72c4faf8d83ead16a5c0cd6_Out_2_Float);
float4 _Combine_2f7388d585a24290a659f20482d78d94_RGBA_4_Vector4;
float3 _Combine_2f7388d585a24290a659f20482d78d94_RGB_5_Vector3;
float2 _Combine_2f7388d585a24290a659f20482d78d94_RG_6_Vector2;
Unity_Combine_float(_Sine_0b39f9f73b2c4016a046ad8da4b84c11_Out_1_Float, _Multiply_69e2c5b6e72c4faf8d83ead16a5c0cd6_Out_2_Float, 0, 0, _Combine_2f7388d585a24290a659f20482d78d94_RGBA_4_Vector4, _Combine_2f7388d585a24290a659f20482d78d94_RGB_5_Vector3, _Combine_2f7388d585a24290a659f20482d78d94_RG_6_Vector2);
float _DotProduct_e3247c7835f0404893730bc5dcd240a0_Out_2_Float;
Unity_DotProduct_float2(_Multiply_5833218c1a7c4d9586d5e8c69ddaabac_Out_2_Vector2, _Combine_2f7388d585a24290a659f20482d78d94_RG_6_Vector2, _DotProduct_e3247c7835f0404893730bc5dcd240a0_Out_2_Float);
float2 _Multiply_ed7373e7bd6347f89e44dacc83ccf8c1_Out_2_Vector2;
Unity_Multiply_float2_float2((_DotProduct_e3247c7835f0404893730bc5dcd240a0_Out_2_Float.xx), _Combine_2f7388d585a24290a659f20482d78d94_RG_6_Vector2, _Multiply_ed7373e7bd6347f89e44dacc83ccf8c1_Out_2_Vector2);
float2 _Add_f950bfd74ec2464b89d972d5f43aa5b7_Out_2_Vector2;
Unity_Add_float2(_Multiply_c8e01038fa74488a86a9759343a555f5_Out_2_Vector2, _Multiply_ed7373e7bd6347f89e44dacc83ccf8c1_Out_2_Vector2, _Add_f950bfd74ec2464b89d972d5f43aa5b7_Out_2_Vector2);
float _Property_8c38f0ae55594c8787ad0a52af13731b_Out_0_Float = _WindSpeed;
float _Negate_47564bc9ce9645a5916ebc05fb9d63df_Out_1_Float;
Unity_Negate_float(_Property_8c38f0ae55594c8787ad0a52af13731b_Out_0_Float, _Negate_47564bc9ce9645a5916ebc05fb9d63df_Out_1_Float);
float _Multiply_e311852a737c422594c328d00e16414c_Out_2_Float;
Unity_Multiply_float_float(IN.TimeParameters.x, _Negate_47564bc9ce9645a5916ebc05fb9d63df_Out_1_Float, _Multiply_e311852a737c422594c328d00e16414c_Out_2_Float);
float _Property_347528760e804b2ab165732f176f3e97_Out_0_Float = _PerBladeRandomTimeOffset;
float _Multiply_0657e69a5c9b4cb783a0d4021b58a9b1_Out_2_Float;
Unity_Multiply_float_float(_Split_3967427c51c24bb79cef645976364a55_R_1_Float, _Property_347528760e804b2ab165732f176f3e97_Out_0_Float, _Multiply_0657e69a5c9b4cb783a0d4021b58a9b1_Out_2_Float);
float _Add_8e1a8d342102407f97ee7c7b88271e7d_Out_2_Float;
Unity_Add_float(_Multiply_e311852a737c422594c328d00e16414c_Out_2_Float, _Multiply_0657e69a5c9b4cb783a0d4021b58a9b1_Out_2_Float, _Add_8e1a8d342102407f97ee7c7b88271e7d_Out_2_Float);
float2 _Multiply_e39ee6e978424683b1858114ff959110_Out_2_Vector2;
Unity_Multiply_float2_float2(_Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2, (_Add_8e1a8d342102407f97ee7c7b88271e7d_Out_2_Float.xx), _Multiply_e39ee6e978424683b1858114ff959110_Out_2_Vector2);
float2 _Add_302cec4f55d64a65bf1160e9d23f9b71_Out_2_Vector2;
Unity_Add_float2(_Add_f950bfd74ec2464b89d972d5f43aa5b7_Out_2_Vector2, _Multiply_e39ee6e978424683b1858114ff959110_Out_2_Vector2, _Add_302cec4f55d64a65bf1160e9d23f9b71_Out_2_Vector2);
float _GradientNoise_f0d0f1452f814e03824cb2ceb16d6ad2_Out_2_Float;
Unity_GradientNoise_Deterministic_float(_Add_302cec4f55d64a65bf1160e9d23f9b71_Out_2_Vector2, 0.8, _GradientNoise_f0d0f1452f814e03824cb2ceb16d6ad2_Out_2_Float);
float _Smoothstep_4ca6b3a56ada4447bcfcabe8e1a6ee2b_Out_3_Float;
Unity_Smoothstep_float(-0.5, 1.5, _GradientNoise_f0d0f1452f814e03824cb2ceb16d6ad2_Out_2_Float, _Smoothstep_4ca6b3a56ada4447bcfcabe8e1a6ee2b_Out_3_Float);
float _Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float;
Unity_Saturate_float(_Smoothstep_4ca6b3a56ada4447bcfcabe8e1a6ee2b_Out_3_Float, _Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float);
float2 _Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2;
Unity_Lerp_float2(_Rotate_cf73d535c5fb437aa68912dc0e09ba2f_Out_3_Vector2, _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RG_6_Vector2, (_Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float.xx), _Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2);
float _DotProduct_b6d4ff1e79f54760a1f13bc5172c426b_Out_2_Float;
Unity_DotProduct_float2(_Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2, _Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2, _DotProduct_b6d4ff1e79f54760a1f13bc5172c426b_Out_2_Float);
float _SquareRoot_ec802f46201b45ac867b479ae083b1ee_Out_1_Float;
Unity_SquareRoot_float(_DotProduct_b6d4ff1e79f54760a1f13bc5172c426b_Out_2_Float, _SquareRoot_ec802f46201b45ac867b479ae083b1ee_Out_1_Float);
float _Maximum_56d7bd23f19a4866b35324380205c891_Out_2_Float;
Unity_Maximum_float(_SquareRoot_ec802f46201b45ac867b479ae083b1ee_Out_1_Float, 1E-05, _Maximum_56d7bd23f19a4866b35324380205c891_Out_2_Float);
float2 _Divide_bfbaafc2be014557bf2a163156a11a26_Out_2_Vector2;
Unity_Divide_float2(_Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2, (_Maximum_56d7bd23f19a4866b35324380205c891_Out_2_Float.xx), _Divide_bfbaafc2be014557bf2a163156a11a26_Out_2_Vector2);
float _Property_f1f58df30464478cb038a178d9e83682_Out_0_Float = _WindIntensity;
float _Add_ed2907c2a73440cc83d0b31366c5c7ae_Out_2_Float;
Unity_Add_float(IN.TimeParameters.x, _Split_3967427c51c24bb79cef645976364a55_B_3_Float, _Add_ed2907c2a73440cc83d0b31366c5c7ae_Out_2_Float);
float _Multiply_f0258532eb174f5393420713f84f6c8e_Out_2_Float;
Unity_Multiply_float_float(_Add_ed2907c2a73440cc83d0b31366c5c7ae_Out_2_Float, 2, _Multiply_f0258532eb174f5393420713f84f6c8e_Out_2_Float);
float _Sine_17bbe1505e754bbd9eedc59d0757132f_Out_1_Float;
Unity_Sine_float(_Multiply_f0258532eb174f5393420713f84f6c8e_Out_2_Float, _Sine_17bbe1505e754bbd9eedc59d0757132f_Out_1_Float);
float _Multiply_bfdbccbbf3584e1eb7d34b97e3a771c5_Out_2_Float;
Unity_Multiply_float_float(_Add_ed2907c2a73440cc83d0b31366c5c7ae_Out_2_Float, 3, _Multiply_bfdbccbbf3584e1eb7d34b97e3a771c5_Out_2_Float);
float _Sine_775bcfb1287e450094240576942d7a07_Out_1_Float;
Unity_Sine_float(_Multiply_bfdbccbbf3584e1eb7d34b97e3a771c5_Out_2_Float, _Sine_775bcfb1287e450094240576942d7a07_Out_1_Float);
float _Lerp_3cef0baddeb24a408278d7e18640ec45_Out_3_Float;
Unity_Lerp_float(_Sine_17bbe1505e754bbd9eedc59d0757132f_Out_1_Float, _Sine_775bcfb1287e450094240576942d7a07_Out_1_Float, _Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float, _Lerp_3cef0baddeb24a408278d7e18640ec45_Out_3_Float);
float _Property_59edf586db864b7a9b70a1acca2de692_Out_0_Float = _PerBladeWindIntensityVariation;
float _Multiply_13aa0e7d9b29467fa9ca1e4db82d023c_Out_2_Float;
Unity_Multiply_float_float(_Lerp_3cef0baddeb24a408278d7e18640ec45_Out_3_Float, _Property_59edf586db864b7a9b70a1acca2de692_Out_0_Float, _Multiply_13aa0e7d9b29467fa9ca1e4db82d023c_Out_2_Float);
float _Add_5a191ec83e8345689f15b7e3b2da0e21_Out_2_Float;
Unity_Add_float(_Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float, _Multiply_13aa0e7d9b29467fa9ca1e4db82d023c_Out_2_Float, _Add_5a191ec83e8345689f15b7e3b2da0e21_Out_2_Float);
float _Lerp_fb2e17ff05c44b1b8daaa248df6af035_Out_3_Float;
Unity_Lerp_float(0, _Property_f1f58df30464478cb038a178d9e83682_Out_0_Float, _Add_5a191ec83e8345689f15b7e3b2da0e21_Out_2_Float, _Lerp_fb2e17ff05c44b1b8daaa248df6af035_Out_3_Float);
float _Multiply_1565a94cae5148adaa4ad80e978368c6_Out_2_Float;
Unity_Multiply_float_float(_SquareRoot_ec802f46201b45ac867b479ae083b1ee_Out_1_Float, _Lerp_fb2e17ff05c44b1b8daaa248df6af035_Out_3_Float, _Multiply_1565a94cae5148adaa4ad80e978368c6_Out_2_Float);
WindDirection_1 = _Divide_bfbaafc2be014557bf2a163156a11a26_Out_2_Vector2;
WindIntensity_2 = _Multiply_1565a94cae5148adaa4ad80e978368c6_Out_2_Float;
Random_3 = _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3;
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

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_MatrixConstruction_Row_float (float4 M0, float4 M1, float4 M2, float4 M3, out float4x4 Out4x4, out float3x3 Out3x3, out float2x2 Out2x2)
{
Out4x4 = float4x4(M0.x, M0.y, M0.z, M0.w, M1.x, M1.y, M1.z, M1.w, M2.x, M2.y, M2.z, M2.w, M3.x, M3.y, M3.z, M3.w);
Out3x3 = float3x3(M0.x, M0.y, M0.z, M1.x, M1.y, M1.z, M2.x, M2.y, M2.z);
Out2x2 = float2x2(M0.x, M0.y, M1.x, M1.y);
}

void Unity_Multiply_float4x4_float4(float4x4 A, float4 B, out float4 Out)
{
Out = mul(A, B);
}

void Unity_Add_float3(float3 A, float3 B, out float3 Out)
{
    Out = A + B;
}

struct Bindings_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float
{
float3 ObjectSpaceNormal;
float3 ObjectSpaceTangent;
float3 ObjectSpacePosition;
};

void SG_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float(float3 _PositionOS, bool _PositionOS_3016357c5e324f0e825ebc4f84f71f27_IsConnected, float3 _NormalOS, bool _NormalOS_6443e352350b4de9ae048680d0b154e4_IsConnected, float3 _TangentOS, bool _TangentOS_307e55ce70df463b90fe1b65f35443d9_IsConnected, float3 _PivotOffset, float3 _AxisOrientation, float4 _PivotAxis, int _OutputSpace, Bindings_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float IN, out float3 Position_1, out float3 Normal_2, out float3 Tangent_3)
{
float4 _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M0_1_Vector4 = UNITY_MATRIX_I_V[0];
float4 _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M1_2_Vector4 = UNITY_MATRIX_I_V[1];
float4 _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M2_3_Vector4 = UNITY_MATRIX_I_V[2];
float4 _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M3_4_Vector4 = UNITY_MATRIX_I_V[3];
float4 _Property_ecb1ace83c9743d78d86f543dfba0991_Out_0_Vector4 = _PivotAxis;
float4x4 _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4;
float3x3 _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var3x3_5_Matrix3;
float2x2 _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var2x2_6_Matrix2;
Unity_MatrixConstruction_Row_float(_MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M0_1_Vector4, _Property_ecb1ace83c9743d78d86f543dfba0991_Out_0_Vector4, _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M2_3_Vector4, _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M3_4_Vector4, _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4, _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var3x3_5_Matrix3, _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var2x2_6_Matrix2);
float3 _Property_41894a58127942aaae689326334e61fc_Out_0_Vector3 = _PositionOS;
bool _Property_41894a58127942aaae689326334e61fc_Out_0_Vector3_IsConnected = _PositionOS_3016357c5e324f0e825ebc4f84f71f27_IsConnected;
float3 _BranchOnInputConnection_9706ae1834c64f399a8f850ec2dbbb55_Out_3_Vector3 = _Property_41894a58127942aaae689326334e61fc_Out_0_Vector3_IsConnected ? _Property_41894a58127942aaae689326334e61fc_Out_0_Vector3 : IN.ObjectSpacePosition;
float3 _Multiply_cc7f14533a6c433b98a087240efbf8f8_Out_2_Vector3;
Unity_Multiply_float3_float3(_BranchOnInputConnection_9706ae1834c64f399a8f850ec2dbbb55_Out_3_Vector3, float3(length(float3(UNITY_MATRIX_M[0].x, UNITY_MATRIX_M[1].x, UNITY_MATRIX_M[2].x)),
                             length(float3(UNITY_MATRIX_M[0].y, UNITY_MATRIX_M[1].y, UNITY_MATRIX_M[2].y)),
                             length(float3(UNITY_MATRIX_M[0].z, UNITY_MATRIX_M[1].z, UNITY_MATRIX_M[2].z))), _Multiply_cc7f14533a6c433b98a087240efbf8f8_Out_2_Vector3);
float3 _Property_5affae77929448b994beb6b8ffca0b9a_Out_0_Vector3 = _AxisOrientation;
float3 _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3;
Unity_Multiply_float3_float3(_Multiply_cc7f14533a6c433b98a087240efbf8f8_Out_2_Vector3, _Property_5affae77929448b994beb6b8ffca0b9a_Out_0_Vector3, _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3);
float _Split_d13fd31126ee4b94b419613a1463bb24_R_1_Float = _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3[0];
float _Split_d13fd31126ee4b94b419613a1463bb24_G_2_Float = _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3[1];
float _Split_d13fd31126ee4b94b419613a1463bb24_B_3_Float = _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3[2];
float _Split_d13fd31126ee4b94b419613a1463bb24_A_4_Float = 0;
float4 _Combine_3e277c5566fd4af089d839ecf52390f8_RGBA_4_Vector4;
float3 _Combine_3e277c5566fd4af089d839ecf52390f8_RGB_5_Vector3;
float2 _Combine_3e277c5566fd4af089d839ecf52390f8_RG_6_Vector2;
Unity_Combine_float(_Split_d13fd31126ee4b94b419613a1463bb24_R_1_Float, _Split_d13fd31126ee4b94b419613a1463bb24_G_2_Float, _Split_d13fd31126ee4b94b419613a1463bb24_B_3_Float, 0, _Combine_3e277c5566fd4af089d839ecf52390f8_RGBA_4_Vector4, _Combine_3e277c5566fd4af089d839ecf52390f8_RGB_5_Vector3, _Combine_3e277c5566fd4af089d839ecf52390f8_RG_6_Vector2);
float4 _Multiply_b71678c838b541ce80f71613338319bb_Out_2_Vector4;
Unity_Multiply_float4x4_float4(_MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4, _Combine_3e277c5566fd4af089d839ecf52390f8_RGBA_4_Vector4, _Multiply_b71678c838b541ce80f71613338319bb_Out_2_Vector4);
float3 _Swizzle_533fdda21ca44bb783d1af6880283be8_Out_1_Vector3 = _Multiply_b71678c838b541ce80f71613338319bb_Out_2_Vector4.xyz;
float3 _Add_10d54894eefd4263a31339a71dc6a555_Out_2_Vector3;
Unity_Add_float3(_Swizzle_533fdda21ca44bb783d1af6880283be8_Out_1_Vector3, SHADERGRAPH_OBJECT_POSITION, _Add_10d54894eefd4263a31339a71dc6a555_Out_2_Vector3);
float3 _Property_3e2f21cb09ef4a95a3da553bc8c93907_Out_0_Vector3 = _PivotOffset;
float3 _Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3;
Unity_Add_float3(_Add_10d54894eefd4263a31339a71dc6a555_Out_2_Vector3, _Property_3e2f21cb09ef4a95a3da553bc8c93907_Out_0_Vector3, _Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3);
float3 _Transform_c7b91c9bd5a24cbba16a486b2128d2ff_Out_1_Vector3;
{
// Converting Position from AbsoluteWorld to Object via world space
float3 world;
world = GetCameraRelativePositionWS(_Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3.xyz);
_Transform_c7b91c9bd5a24cbba16a486b2128d2ff_Out_1_Vector3 = TransformWorldToObject(world);
}
float3 _OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3;
if (_OutputSpace == 0)
{
_OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3 = _Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3;
}
else if (_OutputSpace == 1)
{
_OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3 = _Transform_c7b91c9bd5a24cbba16a486b2128d2ff_Out_1_Vector3;
}
else
{
_OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3 = _Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3;
}
float3 _Property_6e320129056e479593a9673a6404c2a3_Out_0_Vector3 = _NormalOS;
bool _Property_6e320129056e479593a9673a6404c2a3_Out_0_Vector3_IsConnected = _NormalOS_6443e352350b4de9ae048680d0b154e4_IsConnected;
float3 _BranchOnInputConnection_cdbf96fcdcc94bbc8e16e41d2064eac0_Out_3_Vector3 = _Property_6e320129056e479593a9673a6404c2a3_Out_0_Vector3_IsConnected ? _Property_6e320129056e479593a9673a6404c2a3_Out_0_Vector3 : IN.ObjectSpaceNormal;
float _Split_9df7389f2a034b16b14e80d7ea3cc9eb_R_1_Float = _BranchOnInputConnection_cdbf96fcdcc94bbc8e16e41d2064eac0_Out_3_Vector3[0];
float _Split_9df7389f2a034b16b14e80d7ea3cc9eb_G_2_Float = _BranchOnInputConnection_cdbf96fcdcc94bbc8e16e41d2064eac0_Out_3_Vector3[1];
float _Split_9df7389f2a034b16b14e80d7ea3cc9eb_B_3_Float = _BranchOnInputConnection_cdbf96fcdcc94bbc8e16e41d2064eac0_Out_3_Vector3[2];
float _Split_9df7389f2a034b16b14e80d7ea3cc9eb_A_4_Float = 0;
float4 _Combine_45448fd8d869482ba046251ea2a4986d_RGBA_4_Vector4;
float3 _Combine_45448fd8d869482ba046251ea2a4986d_RGB_5_Vector3;
float2 _Combine_45448fd8d869482ba046251ea2a4986d_RG_6_Vector2;
Unity_Combine_float(_Split_9df7389f2a034b16b14e80d7ea3cc9eb_R_1_Float, _Split_9df7389f2a034b16b14e80d7ea3cc9eb_G_2_Float, _Split_9df7389f2a034b16b14e80d7ea3cc9eb_B_3_Float, 0, _Combine_45448fd8d869482ba046251ea2a4986d_RGBA_4_Vector4, _Combine_45448fd8d869482ba046251ea2a4986d_RGB_5_Vector3, _Combine_45448fd8d869482ba046251ea2a4986d_RG_6_Vector2);
float4 _Multiply_fa8c745148884874b6bda6c5b00b1faf_Out_2_Vector4;
Unity_Multiply_float4x4_float4(_MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4, _Combine_45448fd8d869482ba046251ea2a4986d_RGBA_4_Vector4, _Multiply_fa8c745148884874b6bda6c5b00b1faf_Out_2_Vector4);
float3 _Swizzle_aac6fdf714634855bbb2102e1f03176a_Out_1_Vector3 = _Multiply_fa8c745148884874b6bda6c5b00b1faf_Out_2_Vector4.xyz;
float3 _Transform_ca9dd6096e414ef1aab3fc9c46b8a751_Out_1_Vector3;
{
// Converting Normal from AbsoluteWorld to Object via world space
float3 world;
world = _Swizzle_aac6fdf714634855bbb2102e1f03176a_Out_1_Vector3.xyz;
_Transform_ca9dd6096e414ef1aab3fc9c46b8a751_Out_1_Vector3 = TransformWorldToObjectNormal(world, true);
}
float3 _OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3;
if (_OutputSpace == 0)
{
_OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3 = _Swizzle_aac6fdf714634855bbb2102e1f03176a_Out_1_Vector3;
}
else if (_OutputSpace == 1)
{
_OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3 = _Transform_ca9dd6096e414ef1aab3fc9c46b8a751_Out_1_Vector3;
}
else
{
_OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3 = _Swizzle_aac6fdf714634855bbb2102e1f03176a_Out_1_Vector3;
}
float3 _Property_1caa087de4794f53880c4f3b725272b1_Out_0_Vector3 = _TangentOS;
bool _Property_1caa087de4794f53880c4f3b725272b1_Out_0_Vector3_IsConnected = _TangentOS_307e55ce70df463b90fe1b65f35443d9_IsConnected;
float3 _BranchOnInputConnection_49631555af044120aade11fe1ef46744_Out_3_Vector3 = _Property_1caa087de4794f53880c4f3b725272b1_Out_0_Vector3_IsConnected ? _Property_1caa087de4794f53880c4f3b725272b1_Out_0_Vector3 : IN.ObjectSpaceTangent;
float _Split_38da75d926c34146b97327ecc7d7d0e3_R_1_Float = _BranchOnInputConnection_49631555af044120aade11fe1ef46744_Out_3_Vector3[0];
float _Split_38da75d926c34146b97327ecc7d7d0e3_G_2_Float = _BranchOnInputConnection_49631555af044120aade11fe1ef46744_Out_3_Vector3[1];
float _Split_38da75d926c34146b97327ecc7d7d0e3_B_3_Float = _BranchOnInputConnection_49631555af044120aade11fe1ef46744_Out_3_Vector3[2];
float _Split_38da75d926c34146b97327ecc7d7d0e3_A_4_Float = 0;
float4 _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGBA_4_Vector4;
float3 _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGB_5_Vector3;
float2 _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RG_6_Vector2;
Unity_Combine_float(_Split_38da75d926c34146b97327ecc7d7d0e3_R_1_Float, _Split_38da75d926c34146b97327ecc7d7d0e3_G_2_Float, _Split_38da75d926c34146b97327ecc7d7d0e3_B_3_Float, 0, _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGBA_4_Vector4, _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGB_5_Vector3, _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RG_6_Vector2);
float4 _Multiply_88c2defdee7945aabfad7d073ac15b3c_Out_2_Vector4;
Unity_Multiply_float4x4_float4(_MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4, _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGBA_4_Vector4, _Multiply_88c2defdee7945aabfad7d073ac15b3c_Out_2_Vector4);
float3 _Swizzle_dadec3efd6244574a802fd3e0ab56bb5_Out_1_Vector3 = _Multiply_88c2defdee7945aabfad7d073ac15b3c_Out_2_Vector4.xyz;
float3 _Transform_8906312bacad44698b5e2899041600be_Out_1_Vector3;
{
// Converting Normal from AbsoluteWorld to Object via world space
float3 world;
world = _Swizzle_dadec3efd6244574a802fd3e0ab56bb5_Out_1_Vector3.xyz;
_Transform_8906312bacad44698b5e2899041600be_Out_1_Vector3 = TransformWorldToObjectNormal(world, true);
}
float3 _OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3;
if (_OutputSpace == 0)
{
_OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3 = _Swizzle_dadec3efd6244574a802fd3e0ab56bb5_Out_1_Vector3;
}
else if (_OutputSpace == 1)
{
_OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3 = _Transform_8906312bacad44698b5e2899041600be_Out_1_Vector3;
}
else
{
_OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3 = _Swizzle_dadec3efd6244574a802fd3e0ab56bb5_Out_1_Vector3;
}
Position_1 = _OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3;
Normal_2 = _OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3;
Tangent_3 = _OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3;
}

void Unity_Step_float(float Edge, float In, out float Out)
{
    Out = step(Edge, In);
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
float _Property_dbcc12976b2c4eb4a63c1284e5f1d305_Out_0_Float = _Wind_Speed;
Bindings_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba;
_FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba.TimeParameters = IN.TimeParameters;
float2 _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindDirection_1_Vector2;
float _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindIntensity_2_Float;
float3 _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_Random_3_Vector3;
SG_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float(124, _Property_dbcc12976b2c4eb4a63c1284e5f1d305_Out_0_Float, 0.01, 0.2, 0.1, 0.2, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindDirection_1_Vector2, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindIntensity_2_Float, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_Random_3_Vector3);
float4x4 _Property_e6333f42f10045b8874ca797f7698f1d_Out_0_Matrix4 = _WireframeShaderMaskData1;
float _DynamicMask_50b2c29949db4c9087fc753d984c4250_Out_3_Float;
WireframeShaderDynamicMaskCube_float(IN.WorldSpacePosition, _Property_e6333f42f10045b8874ca797f7698f1d_Out_0_Matrix4, 0, _DynamicMask_50b2c29949db4c9087fc753d984c4250_Out_3_Float);
float4x4 _Property_37070fbe8a4e4576a732a3a352dec45e_Out_0_Matrix4 = _WireframeShaderMaskData2;
float _DynamicMask_0c15310c869f45a5bb095f810944777b_Out_3_Float;
WireframeShaderDynamicMaskSphere_float(IN.WorldSpacePosition, _Property_37070fbe8a4e4576a732a3a352dec45e_Out_0_Matrix4, 0, _DynamicMask_0c15310c869f45a5bb095f810944777b_Out_3_Float);
float _Add_4e24bc1118f94bdb89aeba5ac3067e43_Out_2_Float;
Unity_Add_float(_DynamicMask_50b2c29949db4c9087fc753d984c4250_Out_3_Float, _DynamicMask_0c15310c869f45a5bb095f810944777b_Out_3_Float, _Add_4e24bc1118f94bdb89aeba5ac3067e43_Out_2_Float);
float _Saturate_b1a2ecfe1d1842778d5653a46a7b1782_Out_1_Float;
Unity_Saturate_float(_Add_4e24bc1118f94bdb89aeba5ac3067e43_Out_2_Float, _Saturate_b1a2ecfe1d1842778d5653a46a7b1782_Out_1_Float);
float _OneMinus_153cdd2db72f462c97a7c55eccd49567_Out_1_Float;
Unity_OneMinus_float(_Saturate_b1a2ecfe1d1842778d5653a46a7b1782_Out_1_Float, _OneMinus_153cdd2db72f462c97a7c55eccd49567_Out_1_Float);
float _Multiply_cff561f8195f49188db426fdc084a6ce_Out_2_Float;
Unity_Multiply_float_float(_OneMinus_153cdd2db72f462c97a7c55eccd49567_Out_1_Float, -1, _Multiply_cff561f8195f49188db426fdc084a6ce_Out_2_Float);
float3 _Vector3_2dea481cbff74205a7cee900960a51a9_Out_0_Vector3 = float3(_FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindIntensity_2_Float, _Multiply_cff561f8195f49188db426fdc084a6ce_Out_2_Float, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindIntensity_2_Float);
Bindings_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f;
_BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f.ObjectSpaceNormal = IN.ObjectSpaceNormal;
_BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f.ObjectSpaceTangent = IN.ObjectSpaceTangent;
_BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f.ObjectSpacePosition = IN.ObjectSpacePosition;
float3 _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Position_1_Vector3;
float3 _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Normal_2_Vector3;
float3 _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Tangent_3_Vector3;
SG_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float(float3 (0, 0, 0), false, float3 (0, 0, 0), false, float3 (0, 0, 0), false, _Vector3_2dea481cbff74205a7cee900960a51a9_Out_0_Vector3, float3 (-1, 1, 1), float4 (0, 1, 0, 0), 1, _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f, _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Position_1_Vector3, _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Normal_2_Vector3, _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Tangent_3_Vector3);
description.Position = _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Position_1_Vector3;
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
float4x4 _Property_768bac82b0684cd0a21ed8a814d35a50_Out_0_Matrix4 = _WireframeShaderMaskData1;
float _DynamicMask_d8cbb946b52f4b01a4d3fd3bc3ea9de1_Out_3_Float;
WireframeShaderDynamicMaskCube_float(IN.WorldSpacePosition, _Property_768bac82b0684cd0a21ed8a814d35a50_Out_0_Matrix4, 0, _DynamicMask_d8cbb946b52f4b01a4d3fd3bc3ea9de1_Out_3_Float);
float4x4 _Property_39e6a912ee0647ed8335e7ab63cd4bed_Out_0_Matrix4 = _WireframeShaderMaskData2;
float _DynamicMask_e413c723ed49470ba4eca3bcf6362548_Out_3_Float;
WireframeShaderDynamicMaskSphere_float(IN.WorldSpacePosition, _Property_39e6a912ee0647ed8335e7ab63cd4bed_Out_0_Matrix4, 0, _DynamicMask_e413c723ed49470ba4eca3bcf6362548_Out_3_Float);
float _Add_c3b10d55feaf4b9baefa4948a8eaed75_Out_2_Float;
Unity_Add_float(_DynamicMask_d8cbb946b52f4b01a4d3fd3bc3ea9de1_Out_3_Float, _DynamicMask_e413c723ed49470ba4eca3bcf6362548_Out_3_Float, _Add_c3b10d55feaf4b9baefa4948a8eaed75_Out_2_Float);
float _Saturate_62dc9cf6a37b4fab9407e114176db70f_Out_1_Float;
Unity_Saturate_float(_Add_c3b10d55feaf4b9baefa4948a8eaed75_Out_2_Float, _Saturate_62dc9cf6a37b4fab9407e114176db70f_Out_1_Float);
float _Step_0f4fbf717a47479eaa1a77f0d38201d7_Out_2_Float;
Unity_Step_float(0.05, _Saturate_62dc9cf6a37b4fab9407e114176db70f_Out_1_Float, _Step_0f4fbf717a47479eaa1a77f0d38201d7_Out_2_Float);
surface.Alpha = _Step_0f4fbf717a47479eaa1a77f0d38201d7_Out_2_Float;
surface.AlphaClipThreshold = 0.5;
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
    output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
    output.TimeParameters =                             _TimeParameters.xyz;

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
#define ATTRIBUTES_NEED_TEXCOORD1
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define VARYINGS_NEED_TANGENT_WS
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_DEPTHNORMALS
#define _ALPHATEST_ON 1
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
 float4 uv1 : TEXCOORD1;
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
 float3 WorldSpacePosition;
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
 float3 WorldSpacePosition;
 float3 TimeParameters;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
 float4 tangentWS : INTERP0;
 float3 positionWS : INTERP1;
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
return output;
}

Varyings UnpackVaryings (PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
output.tangentWS = input.tangentWS.xyzw;
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
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)
float _Wireframe_Thickness;
float _Wireframe_Anti_aliasing;
float4 _Blade_Color_2;
float4 _Blade_Color_1;
float _Metallic;
float _Smoothness;
float _Wind_Speed;
CBUFFER_END


// Object and Global properties
float4x4 _WireframeShaderMaskData1;
float4x4 _WireframeShaderMaskData2;

// Graph Includes
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"

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

void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
{
Out = A * B;
}

void Unity_Fraction_float3(float3 In, out float3 Out)
{
    Out = frac(In);
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Multiply_float_float(float A, float B, out float Out)
{
Out = A * B;
}

void Unity_Sine_float(float In, out float Out)
{
    Out = sin(In);
}

void Unity_DegreesToRadians_float(float In, out float Out)
{
    Out = radians(In);
}

void Unity_Rotate_Radians_float(float2 UV, float2 Center, float Rotation, out float2 Out)
{
    //rotation matrix
    UV -= Center;
    float s = sin(Rotation);
    float c = cos(Rotation);

    //center rotation matrix
    float2x2 rMatrix = float2x2(c, -s, s, c);
    rMatrix *= 0.5;
    rMatrix += 0.5;
    rMatrix = rMatrix*2 - 1;

    //multiply the UVs by the rotation matrix
    UV.xy = mul(UV.xy, rMatrix);
    UV += Center;

    Out = UV;
}

void Unity_Cosine_float(float In, out float Out)
{
    Out = cos(In);
}

void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
{
    RGBA = float4(R, G, B, A);
    RGB = float3(R, G, B);
    RG = float2(R, G);
}

void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
{
Out = A * B;
}

void Unity_DotProduct_float2(float2 A, float2 B, out float Out)
{
    Out = dot(A, B);
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
    Out = A + B;
}

void Unity_Negate_float(float In, out float Out)
{
    Out = -1 * In;
}

float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
{
float x; Hash_Tchou_2_1_float(p, x);
return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
{
float2 p = UV * Scale.xy;
float2 ip = floor(p);
float2 fp = frac(p);
float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
    Out = smoothstep(Edge1, Edge2, In);
}

void Unity_Saturate_float(float In, out float Out)
{
    Out = saturate(In);
}

void Unity_Lerp_float2(float2 A, float2 B, float2 T, out float2 Out)
{
    Out = lerp(A, B, T);
}

void Unity_SquareRoot_float(float In, out float Out)
{
    Out = sqrt(In);
}

void Unity_Maximum_float(float A, float B, out float Out)
{
    Out = max(A, B);
}

void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
{
    Out = A / B;
}

void Unity_Lerp_float(float A, float B, float T, out float Out)
{
    Out = lerp(A, B, T);
}

struct Bindings_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float
{
float3 TimeParameters;
};

void SG_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float(float _WindDirection, float _WindSpeed, float _WindDirectionVariation, float _PerBladeRandomTimeOffset, float _PerBladeWindIntensityVariation, float _WindIntensity, Bindings_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float IN, out float2 WindDirection_1, out float WindIntensity_2, out float3 Random_3)
{
float2 _Vector2_42921bc8d43346a4bbad7aa650d15962_Out_0_Vector2 = float2(1, 0);
float3 _Multiply_b6ed4cc094134c21943e217e6e271dae_Out_2_Vector3;
Unity_Multiply_float3_float3(SHADERGRAPH_OBJECT_POSITION, float3(37, 190, 29), _Multiply_b6ed4cc094134c21943e217e6e271dae_Out_2_Vector3);
float3 _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3;
Unity_Fraction_float3(_Multiply_b6ed4cc094134c21943e217e6e271dae_Out_2_Vector3, _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3);
float _Split_3967427c51c24bb79cef645976364a55_R_1_Float = _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3[0];
float _Split_3967427c51c24bb79cef645976364a55_G_2_Float = _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3[1];
float _Split_3967427c51c24bb79cef645976364a55_B_3_Float = _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3[2];
float _Split_3967427c51c24bb79cef645976364a55_A_4_Float = 0;
float _Add_ffd28ed6ff854810bd439fbdfc4b2cc2_Out_2_Float;
Unity_Add_float(IN.TimeParameters.x, _Split_3967427c51c24bb79cef645976364a55_B_3_Float, _Add_ffd28ed6ff854810bd439fbdfc4b2cc2_Out_2_Float);
float _Multiply_1185303c6c5d481190d5375ac379cab8_Out_2_Float;
Unity_Multiply_float_float(_Add_ffd28ed6ff854810bd439fbdfc4b2cc2_Out_2_Float, 3, _Multiply_1185303c6c5d481190d5375ac379cab8_Out_2_Float);
float _Sine_c919089f2f34401face2dd9897c9725c_Out_1_Float;
Unity_Sine_float(_Multiply_1185303c6c5d481190d5375ac379cab8_Out_2_Float, _Sine_c919089f2f34401face2dd9897c9725c_Out_1_Float);
float _Property_40290747561641a1bdf5517e6a93430d_Out_0_Float = _WindDirectionVariation;
float _DegreesToRadians_a7fe82a177484cd0af99b4027bc4e3bc_Out_1_Float;
Unity_DegreesToRadians_float(_Property_40290747561641a1bdf5517e6a93430d_Out_0_Float, _DegreesToRadians_a7fe82a177484cd0af99b4027bc4e3bc_Out_1_Float);
float _Multiply_c6dbf243e66746b490b03900b2b27467_Out_2_Float;
Unity_Multiply_float_float(_Sine_c919089f2f34401face2dd9897c9725c_Out_1_Float, _DegreesToRadians_a7fe82a177484cd0af99b4027bc4e3bc_Out_1_Float, _Multiply_c6dbf243e66746b490b03900b2b27467_Out_2_Float);
float2 _Rotate_cf73d535c5fb437aa68912dc0e09ba2f_Out_3_Vector2;
Unity_Rotate_Radians_float(_Vector2_42921bc8d43346a4bbad7aa650d15962_Out_0_Vector2, float2 (0, 0), _Multiply_c6dbf243e66746b490b03900b2b27467_Out_2_Float, _Rotate_cf73d535c5fb437aa68912dc0e09ba2f_Out_3_Vector2);
float _Property_df02aaa16377442d91f0c6be7d036d51_Out_0_Float = _WindDirection;
float _DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float;
Unity_DegreesToRadians_float(_Property_df02aaa16377442d91f0c6be7d036d51_Out_0_Float, _DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float);
float _Add_b051e3fa11c048dd978791daff07720d_Out_2_Float;
Unity_Add_float(_Multiply_c6dbf243e66746b490b03900b2b27467_Out_2_Float, _DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float, _Add_b051e3fa11c048dd978791daff07720d_Out_2_Float);
float _Cosine_0847069386bc4c12a90e1fe3eb1eee73_Out_1_Float;
Unity_Cosine_float(_Add_b051e3fa11c048dd978791daff07720d_Out_2_Float, _Cosine_0847069386bc4c12a90e1fe3eb1eee73_Out_1_Float);
float _Sine_379c87a4cd3c419293869dee73c52de0_Out_1_Float;
Unity_Sine_float(_Add_b051e3fa11c048dd978791daff07720d_Out_2_Float, _Sine_379c87a4cd3c419293869dee73c52de0_Out_1_Float);
float4 _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RGBA_4_Vector4;
float3 _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RGB_5_Vector3;
float2 _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RG_6_Vector2;
Unity_Combine_float(_Cosine_0847069386bc4c12a90e1fe3eb1eee73_Out_1_Float, _Sine_379c87a4cd3c419293869dee73c52de0_Out_1_Float, 0, 0, _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RGBA_4_Vector4, _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RGB_5_Vector3, _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RG_6_Vector2);
float2 _Swizzle_db678fc97ec448fda50408084410c787_Out_1_Vector2 = SHADERGRAPH_OBJECT_POSITION.xz;
float2 _Multiply_5833218c1a7c4d9586d5e8c69ddaabac_Out_2_Vector2;
Unity_Multiply_float2_float2(_Swizzle_db678fc97ec448fda50408084410c787_Out_1_Vector2, float2(0.5, 0.5), _Multiply_5833218c1a7c4d9586d5e8c69ddaabac_Out_2_Vector2);
float _Cosine_3388e8245f6647ca98f5aa9339130c65_Out_1_Float;
Unity_Cosine_float(_DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float, _Cosine_3388e8245f6647ca98f5aa9339130c65_Out_1_Float);
float _Sine_0b39f9f73b2c4016a046ad8da4b84c11_Out_1_Float;
Unity_Sine_float(_DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float, _Sine_0b39f9f73b2c4016a046ad8da4b84c11_Out_1_Float);
float4 _Combine_7f78efe98e4641c1981d47da9bbbe70f_RGBA_4_Vector4;
float3 _Combine_7f78efe98e4641c1981d47da9bbbe70f_RGB_5_Vector3;
float2 _Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2;
Unity_Combine_float(_Cosine_3388e8245f6647ca98f5aa9339130c65_Out_1_Float, _Sine_0b39f9f73b2c4016a046ad8da4b84c11_Out_1_Float, 0, 0, _Combine_7f78efe98e4641c1981d47da9bbbe70f_RGBA_4_Vector4, _Combine_7f78efe98e4641c1981d47da9bbbe70f_RGB_5_Vector3, _Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2);
float _DotProduct_27327ffeb11d404c96d6820c42272ca8_Out_2_Float;
Unity_DotProduct_float2(_Multiply_5833218c1a7c4d9586d5e8c69ddaabac_Out_2_Vector2, _Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2, _DotProduct_27327ffeb11d404c96d6820c42272ca8_Out_2_Float);
float _Multiply_8dc73d49a3b547a19bf5c0d8a4a09920_Out_2_Float;
Unity_Multiply_float_float(_DotProduct_27327ffeb11d404c96d6820c42272ca8_Out_2_Float, 0.7, _Multiply_8dc73d49a3b547a19bf5c0d8a4a09920_Out_2_Float);
float2 _Multiply_c8e01038fa74488a86a9759343a555f5_Out_2_Vector2;
Unity_Multiply_float2_float2((_Multiply_8dc73d49a3b547a19bf5c0d8a4a09920_Out_2_Float.xx), _Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2, _Multiply_c8e01038fa74488a86a9759343a555f5_Out_2_Vector2);
float _Multiply_69e2c5b6e72c4faf8d83ead16a5c0cd6_Out_2_Float;
Unity_Multiply_float_float(_Cosine_3388e8245f6647ca98f5aa9339130c65_Out_1_Float, -1.5708, _Multiply_69e2c5b6e72c4faf8d83ead16a5c0cd6_Out_2_Float);
float4 _Combine_2f7388d585a24290a659f20482d78d94_RGBA_4_Vector4;
float3 _Combine_2f7388d585a24290a659f20482d78d94_RGB_5_Vector3;
float2 _Combine_2f7388d585a24290a659f20482d78d94_RG_6_Vector2;
Unity_Combine_float(_Sine_0b39f9f73b2c4016a046ad8da4b84c11_Out_1_Float, _Multiply_69e2c5b6e72c4faf8d83ead16a5c0cd6_Out_2_Float, 0, 0, _Combine_2f7388d585a24290a659f20482d78d94_RGBA_4_Vector4, _Combine_2f7388d585a24290a659f20482d78d94_RGB_5_Vector3, _Combine_2f7388d585a24290a659f20482d78d94_RG_6_Vector2);
float _DotProduct_e3247c7835f0404893730bc5dcd240a0_Out_2_Float;
Unity_DotProduct_float2(_Multiply_5833218c1a7c4d9586d5e8c69ddaabac_Out_2_Vector2, _Combine_2f7388d585a24290a659f20482d78d94_RG_6_Vector2, _DotProduct_e3247c7835f0404893730bc5dcd240a0_Out_2_Float);
float2 _Multiply_ed7373e7bd6347f89e44dacc83ccf8c1_Out_2_Vector2;
Unity_Multiply_float2_float2((_DotProduct_e3247c7835f0404893730bc5dcd240a0_Out_2_Float.xx), _Combine_2f7388d585a24290a659f20482d78d94_RG_6_Vector2, _Multiply_ed7373e7bd6347f89e44dacc83ccf8c1_Out_2_Vector2);
float2 _Add_f950bfd74ec2464b89d972d5f43aa5b7_Out_2_Vector2;
Unity_Add_float2(_Multiply_c8e01038fa74488a86a9759343a555f5_Out_2_Vector2, _Multiply_ed7373e7bd6347f89e44dacc83ccf8c1_Out_2_Vector2, _Add_f950bfd74ec2464b89d972d5f43aa5b7_Out_2_Vector2);
float _Property_8c38f0ae55594c8787ad0a52af13731b_Out_0_Float = _WindSpeed;
float _Negate_47564bc9ce9645a5916ebc05fb9d63df_Out_1_Float;
Unity_Negate_float(_Property_8c38f0ae55594c8787ad0a52af13731b_Out_0_Float, _Negate_47564bc9ce9645a5916ebc05fb9d63df_Out_1_Float);
float _Multiply_e311852a737c422594c328d00e16414c_Out_2_Float;
Unity_Multiply_float_float(IN.TimeParameters.x, _Negate_47564bc9ce9645a5916ebc05fb9d63df_Out_1_Float, _Multiply_e311852a737c422594c328d00e16414c_Out_2_Float);
float _Property_347528760e804b2ab165732f176f3e97_Out_0_Float = _PerBladeRandomTimeOffset;
float _Multiply_0657e69a5c9b4cb783a0d4021b58a9b1_Out_2_Float;
Unity_Multiply_float_float(_Split_3967427c51c24bb79cef645976364a55_R_1_Float, _Property_347528760e804b2ab165732f176f3e97_Out_0_Float, _Multiply_0657e69a5c9b4cb783a0d4021b58a9b1_Out_2_Float);
float _Add_8e1a8d342102407f97ee7c7b88271e7d_Out_2_Float;
Unity_Add_float(_Multiply_e311852a737c422594c328d00e16414c_Out_2_Float, _Multiply_0657e69a5c9b4cb783a0d4021b58a9b1_Out_2_Float, _Add_8e1a8d342102407f97ee7c7b88271e7d_Out_2_Float);
float2 _Multiply_e39ee6e978424683b1858114ff959110_Out_2_Vector2;
Unity_Multiply_float2_float2(_Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2, (_Add_8e1a8d342102407f97ee7c7b88271e7d_Out_2_Float.xx), _Multiply_e39ee6e978424683b1858114ff959110_Out_2_Vector2);
float2 _Add_302cec4f55d64a65bf1160e9d23f9b71_Out_2_Vector2;
Unity_Add_float2(_Add_f950bfd74ec2464b89d972d5f43aa5b7_Out_2_Vector2, _Multiply_e39ee6e978424683b1858114ff959110_Out_2_Vector2, _Add_302cec4f55d64a65bf1160e9d23f9b71_Out_2_Vector2);
float _GradientNoise_f0d0f1452f814e03824cb2ceb16d6ad2_Out_2_Float;
Unity_GradientNoise_Deterministic_float(_Add_302cec4f55d64a65bf1160e9d23f9b71_Out_2_Vector2, 0.8, _GradientNoise_f0d0f1452f814e03824cb2ceb16d6ad2_Out_2_Float);
float _Smoothstep_4ca6b3a56ada4447bcfcabe8e1a6ee2b_Out_3_Float;
Unity_Smoothstep_float(-0.5, 1.5, _GradientNoise_f0d0f1452f814e03824cb2ceb16d6ad2_Out_2_Float, _Smoothstep_4ca6b3a56ada4447bcfcabe8e1a6ee2b_Out_3_Float);
float _Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float;
Unity_Saturate_float(_Smoothstep_4ca6b3a56ada4447bcfcabe8e1a6ee2b_Out_3_Float, _Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float);
float2 _Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2;
Unity_Lerp_float2(_Rotate_cf73d535c5fb437aa68912dc0e09ba2f_Out_3_Vector2, _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RG_6_Vector2, (_Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float.xx), _Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2);
float _DotProduct_b6d4ff1e79f54760a1f13bc5172c426b_Out_2_Float;
Unity_DotProduct_float2(_Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2, _Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2, _DotProduct_b6d4ff1e79f54760a1f13bc5172c426b_Out_2_Float);
float _SquareRoot_ec802f46201b45ac867b479ae083b1ee_Out_1_Float;
Unity_SquareRoot_float(_DotProduct_b6d4ff1e79f54760a1f13bc5172c426b_Out_2_Float, _SquareRoot_ec802f46201b45ac867b479ae083b1ee_Out_1_Float);
float _Maximum_56d7bd23f19a4866b35324380205c891_Out_2_Float;
Unity_Maximum_float(_SquareRoot_ec802f46201b45ac867b479ae083b1ee_Out_1_Float, 1E-05, _Maximum_56d7bd23f19a4866b35324380205c891_Out_2_Float);
float2 _Divide_bfbaafc2be014557bf2a163156a11a26_Out_2_Vector2;
Unity_Divide_float2(_Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2, (_Maximum_56d7bd23f19a4866b35324380205c891_Out_2_Float.xx), _Divide_bfbaafc2be014557bf2a163156a11a26_Out_2_Vector2);
float _Property_f1f58df30464478cb038a178d9e83682_Out_0_Float = _WindIntensity;
float _Add_ed2907c2a73440cc83d0b31366c5c7ae_Out_2_Float;
Unity_Add_float(IN.TimeParameters.x, _Split_3967427c51c24bb79cef645976364a55_B_3_Float, _Add_ed2907c2a73440cc83d0b31366c5c7ae_Out_2_Float);
float _Multiply_f0258532eb174f5393420713f84f6c8e_Out_2_Float;
Unity_Multiply_float_float(_Add_ed2907c2a73440cc83d0b31366c5c7ae_Out_2_Float, 2, _Multiply_f0258532eb174f5393420713f84f6c8e_Out_2_Float);
float _Sine_17bbe1505e754bbd9eedc59d0757132f_Out_1_Float;
Unity_Sine_float(_Multiply_f0258532eb174f5393420713f84f6c8e_Out_2_Float, _Sine_17bbe1505e754bbd9eedc59d0757132f_Out_1_Float);
float _Multiply_bfdbccbbf3584e1eb7d34b97e3a771c5_Out_2_Float;
Unity_Multiply_float_float(_Add_ed2907c2a73440cc83d0b31366c5c7ae_Out_2_Float, 3, _Multiply_bfdbccbbf3584e1eb7d34b97e3a771c5_Out_2_Float);
float _Sine_775bcfb1287e450094240576942d7a07_Out_1_Float;
Unity_Sine_float(_Multiply_bfdbccbbf3584e1eb7d34b97e3a771c5_Out_2_Float, _Sine_775bcfb1287e450094240576942d7a07_Out_1_Float);
float _Lerp_3cef0baddeb24a408278d7e18640ec45_Out_3_Float;
Unity_Lerp_float(_Sine_17bbe1505e754bbd9eedc59d0757132f_Out_1_Float, _Sine_775bcfb1287e450094240576942d7a07_Out_1_Float, _Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float, _Lerp_3cef0baddeb24a408278d7e18640ec45_Out_3_Float);
float _Property_59edf586db864b7a9b70a1acca2de692_Out_0_Float = _PerBladeWindIntensityVariation;
float _Multiply_13aa0e7d9b29467fa9ca1e4db82d023c_Out_2_Float;
Unity_Multiply_float_float(_Lerp_3cef0baddeb24a408278d7e18640ec45_Out_3_Float, _Property_59edf586db864b7a9b70a1acca2de692_Out_0_Float, _Multiply_13aa0e7d9b29467fa9ca1e4db82d023c_Out_2_Float);
float _Add_5a191ec83e8345689f15b7e3b2da0e21_Out_2_Float;
Unity_Add_float(_Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float, _Multiply_13aa0e7d9b29467fa9ca1e4db82d023c_Out_2_Float, _Add_5a191ec83e8345689f15b7e3b2da0e21_Out_2_Float);
float _Lerp_fb2e17ff05c44b1b8daaa248df6af035_Out_3_Float;
Unity_Lerp_float(0, _Property_f1f58df30464478cb038a178d9e83682_Out_0_Float, _Add_5a191ec83e8345689f15b7e3b2da0e21_Out_2_Float, _Lerp_fb2e17ff05c44b1b8daaa248df6af035_Out_3_Float);
float _Multiply_1565a94cae5148adaa4ad80e978368c6_Out_2_Float;
Unity_Multiply_float_float(_SquareRoot_ec802f46201b45ac867b479ae083b1ee_Out_1_Float, _Lerp_fb2e17ff05c44b1b8daaa248df6af035_Out_3_Float, _Multiply_1565a94cae5148adaa4ad80e978368c6_Out_2_Float);
WindDirection_1 = _Divide_bfbaafc2be014557bf2a163156a11a26_Out_2_Vector2;
WindIntensity_2 = _Multiply_1565a94cae5148adaa4ad80e978368c6_Out_2_Float;
Random_3 = _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3;
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

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_MatrixConstruction_Row_float (float4 M0, float4 M1, float4 M2, float4 M3, out float4x4 Out4x4, out float3x3 Out3x3, out float2x2 Out2x2)
{
Out4x4 = float4x4(M0.x, M0.y, M0.z, M0.w, M1.x, M1.y, M1.z, M1.w, M2.x, M2.y, M2.z, M2.w, M3.x, M3.y, M3.z, M3.w);
Out3x3 = float3x3(M0.x, M0.y, M0.z, M1.x, M1.y, M1.z, M2.x, M2.y, M2.z);
Out2x2 = float2x2(M0.x, M0.y, M1.x, M1.y);
}

void Unity_Multiply_float4x4_float4(float4x4 A, float4 B, out float4 Out)
{
Out = mul(A, B);
}

void Unity_Add_float3(float3 A, float3 B, out float3 Out)
{
    Out = A + B;
}

struct Bindings_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float
{
float3 ObjectSpaceNormal;
float3 ObjectSpaceTangent;
float3 ObjectSpacePosition;
};

void SG_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float(float3 _PositionOS, bool _PositionOS_3016357c5e324f0e825ebc4f84f71f27_IsConnected, float3 _NormalOS, bool _NormalOS_6443e352350b4de9ae048680d0b154e4_IsConnected, float3 _TangentOS, bool _TangentOS_307e55ce70df463b90fe1b65f35443d9_IsConnected, float3 _PivotOffset, float3 _AxisOrientation, float4 _PivotAxis, int _OutputSpace, Bindings_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float IN, out float3 Position_1, out float3 Normal_2, out float3 Tangent_3)
{
float4 _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M0_1_Vector4 = UNITY_MATRIX_I_V[0];
float4 _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M1_2_Vector4 = UNITY_MATRIX_I_V[1];
float4 _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M2_3_Vector4 = UNITY_MATRIX_I_V[2];
float4 _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M3_4_Vector4 = UNITY_MATRIX_I_V[3];
float4 _Property_ecb1ace83c9743d78d86f543dfba0991_Out_0_Vector4 = _PivotAxis;
float4x4 _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4;
float3x3 _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var3x3_5_Matrix3;
float2x2 _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var2x2_6_Matrix2;
Unity_MatrixConstruction_Row_float(_MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M0_1_Vector4, _Property_ecb1ace83c9743d78d86f543dfba0991_Out_0_Vector4, _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M2_3_Vector4, _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M3_4_Vector4, _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4, _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var3x3_5_Matrix3, _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var2x2_6_Matrix2);
float3 _Property_41894a58127942aaae689326334e61fc_Out_0_Vector3 = _PositionOS;
bool _Property_41894a58127942aaae689326334e61fc_Out_0_Vector3_IsConnected = _PositionOS_3016357c5e324f0e825ebc4f84f71f27_IsConnected;
float3 _BranchOnInputConnection_9706ae1834c64f399a8f850ec2dbbb55_Out_3_Vector3 = _Property_41894a58127942aaae689326334e61fc_Out_0_Vector3_IsConnected ? _Property_41894a58127942aaae689326334e61fc_Out_0_Vector3 : IN.ObjectSpacePosition;
float3 _Multiply_cc7f14533a6c433b98a087240efbf8f8_Out_2_Vector3;
Unity_Multiply_float3_float3(_BranchOnInputConnection_9706ae1834c64f399a8f850ec2dbbb55_Out_3_Vector3, float3(length(float3(UNITY_MATRIX_M[0].x, UNITY_MATRIX_M[1].x, UNITY_MATRIX_M[2].x)),
                             length(float3(UNITY_MATRIX_M[0].y, UNITY_MATRIX_M[1].y, UNITY_MATRIX_M[2].y)),
                             length(float3(UNITY_MATRIX_M[0].z, UNITY_MATRIX_M[1].z, UNITY_MATRIX_M[2].z))), _Multiply_cc7f14533a6c433b98a087240efbf8f8_Out_2_Vector3);
float3 _Property_5affae77929448b994beb6b8ffca0b9a_Out_0_Vector3 = _AxisOrientation;
float3 _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3;
Unity_Multiply_float3_float3(_Multiply_cc7f14533a6c433b98a087240efbf8f8_Out_2_Vector3, _Property_5affae77929448b994beb6b8ffca0b9a_Out_0_Vector3, _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3);
float _Split_d13fd31126ee4b94b419613a1463bb24_R_1_Float = _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3[0];
float _Split_d13fd31126ee4b94b419613a1463bb24_G_2_Float = _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3[1];
float _Split_d13fd31126ee4b94b419613a1463bb24_B_3_Float = _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3[2];
float _Split_d13fd31126ee4b94b419613a1463bb24_A_4_Float = 0;
float4 _Combine_3e277c5566fd4af089d839ecf52390f8_RGBA_4_Vector4;
float3 _Combine_3e277c5566fd4af089d839ecf52390f8_RGB_5_Vector3;
float2 _Combine_3e277c5566fd4af089d839ecf52390f8_RG_6_Vector2;
Unity_Combine_float(_Split_d13fd31126ee4b94b419613a1463bb24_R_1_Float, _Split_d13fd31126ee4b94b419613a1463bb24_G_2_Float, _Split_d13fd31126ee4b94b419613a1463bb24_B_3_Float, 0, _Combine_3e277c5566fd4af089d839ecf52390f8_RGBA_4_Vector4, _Combine_3e277c5566fd4af089d839ecf52390f8_RGB_5_Vector3, _Combine_3e277c5566fd4af089d839ecf52390f8_RG_6_Vector2);
float4 _Multiply_b71678c838b541ce80f71613338319bb_Out_2_Vector4;
Unity_Multiply_float4x4_float4(_MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4, _Combine_3e277c5566fd4af089d839ecf52390f8_RGBA_4_Vector4, _Multiply_b71678c838b541ce80f71613338319bb_Out_2_Vector4);
float3 _Swizzle_533fdda21ca44bb783d1af6880283be8_Out_1_Vector3 = _Multiply_b71678c838b541ce80f71613338319bb_Out_2_Vector4.xyz;
float3 _Add_10d54894eefd4263a31339a71dc6a555_Out_2_Vector3;
Unity_Add_float3(_Swizzle_533fdda21ca44bb783d1af6880283be8_Out_1_Vector3, SHADERGRAPH_OBJECT_POSITION, _Add_10d54894eefd4263a31339a71dc6a555_Out_2_Vector3);
float3 _Property_3e2f21cb09ef4a95a3da553bc8c93907_Out_0_Vector3 = _PivotOffset;
float3 _Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3;
Unity_Add_float3(_Add_10d54894eefd4263a31339a71dc6a555_Out_2_Vector3, _Property_3e2f21cb09ef4a95a3da553bc8c93907_Out_0_Vector3, _Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3);
float3 _Transform_c7b91c9bd5a24cbba16a486b2128d2ff_Out_1_Vector3;
{
// Converting Position from AbsoluteWorld to Object via world space
float3 world;
world = GetCameraRelativePositionWS(_Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3.xyz);
_Transform_c7b91c9bd5a24cbba16a486b2128d2ff_Out_1_Vector3 = TransformWorldToObject(world);
}
float3 _OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3;
if (_OutputSpace == 0)
{
_OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3 = _Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3;
}
else if (_OutputSpace == 1)
{
_OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3 = _Transform_c7b91c9bd5a24cbba16a486b2128d2ff_Out_1_Vector3;
}
else
{
_OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3 = _Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3;
}
float3 _Property_6e320129056e479593a9673a6404c2a3_Out_0_Vector3 = _NormalOS;
bool _Property_6e320129056e479593a9673a6404c2a3_Out_0_Vector3_IsConnected = _NormalOS_6443e352350b4de9ae048680d0b154e4_IsConnected;
float3 _BranchOnInputConnection_cdbf96fcdcc94bbc8e16e41d2064eac0_Out_3_Vector3 = _Property_6e320129056e479593a9673a6404c2a3_Out_0_Vector3_IsConnected ? _Property_6e320129056e479593a9673a6404c2a3_Out_0_Vector3 : IN.ObjectSpaceNormal;
float _Split_9df7389f2a034b16b14e80d7ea3cc9eb_R_1_Float = _BranchOnInputConnection_cdbf96fcdcc94bbc8e16e41d2064eac0_Out_3_Vector3[0];
float _Split_9df7389f2a034b16b14e80d7ea3cc9eb_G_2_Float = _BranchOnInputConnection_cdbf96fcdcc94bbc8e16e41d2064eac0_Out_3_Vector3[1];
float _Split_9df7389f2a034b16b14e80d7ea3cc9eb_B_3_Float = _BranchOnInputConnection_cdbf96fcdcc94bbc8e16e41d2064eac0_Out_3_Vector3[2];
float _Split_9df7389f2a034b16b14e80d7ea3cc9eb_A_4_Float = 0;
float4 _Combine_45448fd8d869482ba046251ea2a4986d_RGBA_4_Vector4;
float3 _Combine_45448fd8d869482ba046251ea2a4986d_RGB_5_Vector3;
float2 _Combine_45448fd8d869482ba046251ea2a4986d_RG_6_Vector2;
Unity_Combine_float(_Split_9df7389f2a034b16b14e80d7ea3cc9eb_R_1_Float, _Split_9df7389f2a034b16b14e80d7ea3cc9eb_G_2_Float, _Split_9df7389f2a034b16b14e80d7ea3cc9eb_B_3_Float, 0, _Combine_45448fd8d869482ba046251ea2a4986d_RGBA_4_Vector4, _Combine_45448fd8d869482ba046251ea2a4986d_RGB_5_Vector3, _Combine_45448fd8d869482ba046251ea2a4986d_RG_6_Vector2);
float4 _Multiply_fa8c745148884874b6bda6c5b00b1faf_Out_2_Vector4;
Unity_Multiply_float4x4_float4(_MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4, _Combine_45448fd8d869482ba046251ea2a4986d_RGBA_4_Vector4, _Multiply_fa8c745148884874b6bda6c5b00b1faf_Out_2_Vector4);
float3 _Swizzle_aac6fdf714634855bbb2102e1f03176a_Out_1_Vector3 = _Multiply_fa8c745148884874b6bda6c5b00b1faf_Out_2_Vector4.xyz;
float3 _Transform_ca9dd6096e414ef1aab3fc9c46b8a751_Out_1_Vector3;
{
// Converting Normal from AbsoluteWorld to Object via world space
float3 world;
world = _Swizzle_aac6fdf714634855bbb2102e1f03176a_Out_1_Vector3.xyz;
_Transform_ca9dd6096e414ef1aab3fc9c46b8a751_Out_1_Vector3 = TransformWorldToObjectNormal(world, true);
}
float3 _OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3;
if (_OutputSpace == 0)
{
_OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3 = _Swizzle_aac6fdf714634855bbb2102e1f03176a_Out_1_Vector3;
}
else if (_OutputSpace == 1)
{
_OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3 = _Transform_ca9dd6096e414ef1aab3fc9c46b8a751_Out_1_Vector3;
}
else
{
_OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3 = _Swizzle_aac6fdf714634855bbb2102e1f03176a_Out_1_Vector3;
}
float3 _Property_1caa087de4794f53880c4f3b725272b1_Out_0_Vector3 = _TangentOS;
bool _Property_1caa087de4794f53880c4f3b725272b1_Out_0_Vector3_IsConnected = _TangentOS_307e55ce70df463b90fe1b65f35443d9_IsConnected;
float3 _BranchOnInputConnection_49631555af044120aade11fe1ef46744_Out_3_Vector3 = _Property_1caa087de4794f53880c4f3b725272b1_Out_0_Vector3_IsConnected ? _Property_1caa087de4794f53880c4f3b725272b1_Out_0_Vector3 : IN.ObjectSpaceTangent;
float _Split_38da75d926c34146b97327ecc7d7d0e3_R_1_Float = _BranchOnInputConnection_49631555af044120aade11fe1ef46744_Out_3_Vector3[0];
float _Split_38da75d926c34146b97327ecc7d7d0e3_G_2_Float = _BranchOnInputConnection_49631555af044120aade11fe1ef46744_Out_3_Vector3[1];
float _Split_38da75d926c34146b97327ecc7d7d0e3_B_3_Float = _BranchOnInputConnection_49631555af044120aade11fe1ef46744_Out_3_Vector3[2];
float _Split_38da75d926c34146b97327ecc7d7d0e3_A_4_Float = 0;
float4 _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGBA_4_Vector4;
float3 _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGB_5_Vector3;
float2 _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RG_6_Vector2;
Unity_Combine_float(_Split_38da75d926c34146b97327ecc7d7d0e3_R_1_Float, _Split_38da75d926c34146b97327ecc7d7d0e3_G_2_Float, _Split_38da75d926c34146b97327ecc7d7d0e3_B_3_Float, 0, _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGBA_4_Vector4, _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGB_5_Vector3, _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RG_6_Vector2);
float4 _Multiply_88c2defdee7945aabfad7d073ac15b3c_Out_2_Vector4;
Unity_Multiply_float4x4_float4(_MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4, _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGBA_4_Vector4, _Multiply_88c2defdee7945aabfad7d073ac15b3c_Out_2_Vector4);
float3 _Swizzle_dadec3efd6244574a802fd3e0ab56bb5_Out_1_Vector3 = _Multiply_88c2defdee7945aabfad7d073ac15b3c_Out_2_Vector4.xyz;
float3 _Transform_8906312bacad44698b5e2899041600be_Out_1_Vector3;
{
// Converting Normal from AbsoluteWorld to Object via world space
float3 world;
world = _Swizzle_dadec3efd6244574a802fd3e0ab56bb5_Out_1_Vector3.xyz;
_Transform_8906312bacad44698b5e2899041600be_Out_1_Vector3 = TransformWorldToObjectNormal(world, true);
}
float3 _OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3;
if (_OutputSpace == 0)
{
_OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3 = _Swizzle_dadec3efd6244574a802fd3e0ab56bb5_Out_1_Vector3;
}
else if (_OutputSpace == 1)
{
_OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3 = _Transform_8906312bacad44698b5e2899041600be_Out_1_Vector3;
}
else
{
_OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3 = _Swizzle_dadec3efd6244574a802fd3e0ab56bb5_Out_1_Vector3;
}
Position_1 = _OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3;
Normal_2 = _OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3;
Tangent_3 = _OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3;
}

void Unity_Step_float(float Edge, float In, out float Out)
{
    Out = step(Edge, In);
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
float _Property_dbcc12976b2c4eb4a63c1284e5f1d305_Out_0_Float = _Wind_Speed;
Bindings_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba;
_FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba.TimeParameters = IN.TimeParameters;
float2 _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindDirection_1_Vector2;
float _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindIntensity_2_Float;
float3 _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_Random_3_Vector3;
SG_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float(124, _Property_dbcc12976b2c4eb4a63c1284e5f1d305_Out_0_Float, 0.01, 0.2, 0.1, 0.2, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindDirection_1_Vector2, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindIntensity_2_Float, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_Random_3_Vector3);
float4x4 _Property_e6333f42f10045b8874ca797f7698f1d_Out_0_Matrix4 = _WireframeShaderMaskData1;
float _DynamicMask_50b2c29949db4c9087fc753d984c4250_Out_3_Float;
WireframeShaderDynamicMaskCube_float(IN.WorldSpacePosition, _Property_e6333f42f10045b8874ca797f7698f1d_Out_0_Matrix4, 0, _DynamicMask_50b2c29949db4c9087fc753d984c4250_Out_3_Float);
float4x4 _Property_37070fbe8a4e4576a732a3a352dec45e_Out_0_Matrix4 = _WireframeShaderMaskData2;
float _DynamicMask_0c15310c869f45a5bb095f810944777b_Out_3_Float;
WireframeShaderDynamicMaskSphere_float(IN.WorldSpacePosition, _Property_37070fbe8a4e4576a732a3a352dec45e_Out_0_Matrix4, 0, _DynamicMask_0c15310c869f45a5bb095f810944777b_Out_3_Float);
float _Add_4e24bc1118f94bdb89aeba5ac3067e43_Out_2_Float;
Unity_Add_float(_DynamicMask_50b2c29949db4c9087fc753d984c4250_Out_3_Float, _DynamicMask_0c15310c869f45a5bb095f810944777b_Out_3_Float, _Add_4e24bc1118f94bdb89aeba5ac3067e43_Out_2_Float);
float _Saturate_b1a2ecfe1d1842778d5653a46a7b1782_Out_1_Float;
Unity_Saturate_float(_Add_4e24bc1118f94bdb89aeba5ac3067e43_Out_2_Float, _Saturate_b1a2ecfe1d1842778d5653a46a7b1782_Out_1_Float);
float _OneMinus_153cdd2db72f462c97a7c55eccd49567_Out_1_Float;
Unity_OneMinus_float(_Saturate_b1a2ecfe1d1842778d5653a46a7b1782_Out_1_Float, _OneMinus_153cdd2db72f462c97a7c55eccd49567_Out_1_Float);
float _Multiply_cff561f8195f49188db426fdc084a6ce_Out_2_Float;
Unity_Multiply_float_float(_OneMinus_153cdd2db72f462c97a7c55eccd49567_Out_1_Float, -1, _Multiply_cff561f8195f49188db426fdc084a6ce_Out_2_Float);
float3 _Vector3_2dea481cbff74205a7cee900960a51a9_Out_0_Vector3 = float3(_FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindIntensity_2_Float, _Multiply_cff561f8195f49188db426fdc084a6ce_Out_2_Float, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindIntensity_2_Float);
Bindings_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f;
_BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f.ObjectSpaceNormal = IN.ObjectSpaceNormal;
_BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f.ObjectSpaceTangent = IN.ObjectSpaceTangent;
_BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f.ObjectSpacePosition = IN.ObjectSpacePosition;
float3 _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Position_1_Vector3;
float3 _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Normal_2_Vector3;
float3 _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Tangent_3_Vector3;
SG_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float(float3 (0, 0, 0), false, float3 (0, 0, 0), false, float3 (0, 0, 0), false, _Vector3_2dea481cbff74205a7cee900960a51a9_Out_0_Vector3, float3 (-1, 1, 1), float4 (0, 1, 0, 0), 1, _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f, _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Position_1_Vector3, _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Normal_2_Vector3, _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Tangent_3_Vector3);
description.Position = _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Position_1_Vector3;
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
float4x4 _Property_768bac82b0684cd0a21ed8a814d35a50_Out_0_Matrix4 = _WireframeShaderMaskData1;
float _DynamicMask_d8cbb946b52f4b01a4d3fd3bc3ea9de1_Out_3_Float;
WireframeShaderDynamicMaskCube_float(IN.WorldSpacePosition, _Property_768bac82b0684cd0a21ed8a814d35a50_Out_0_Matrix4, 0, _DynamicMask_d8cbb946b52f4b01a4d3fd3bc3ea9de1_Out_3_Float);
float4x4 _Property_39e6a912ee0647ed8335e7ab63cd4bed_Out_0_Matrix4 = _WireframeShaderMaskData2;
float _DynamicMask_e413c723ed49470ba4eca3bcf6362548_Out_3_Float;
WireframeShaderDynamicMaskSphere_float(IN.WorldSpacePosition, _Property_39e6a912ee0647ed8335e7ab63cd4bed_Out_0_Matrix4, 0, _DynamicMask_e413c723ed49470ba4eca3bcf6362548_Out_3_Float);
float _Add_c3b10d55feaf4b9baefa4948a8eaed75_Out_2_Float;
Unity_Add_float(_DynamicMask_d8cbb946b52f4b01a4d3fd3bc3ea9de1_Out_3_Float, _DynamicMask_e413c723ed49470ba4eca3bcf6362548_Out_3_Float, _Add_c3b10d55feaf4b9baefa4948a8eaed75_Out_2_Float);
float _Saturate_62dc9cf6a37b4fab9407e114176db70f_Out_1_Float;
Unity_Saturate_float(_Add_c3b10d55feaf4b9baefa4948a8eaed75_Out_2_Float, _Saturate_62dc9cf6a37b4fab9407e114176db70f_Out_1_Float);
float _Step_0f4fbf717a47479eaa1a77f0d38201d7_Out_2_Float;
Unity_Step_float(0.05, _Saturate_62dc9cf6a37b4fab9407e114176db70f_Out_1_Float, _Step_0f4fbf717a47479eaa1a77f0d38201d7_Out_2_Float);
surface.NormalTS = IN.TangentSpaceNormal;
surface.Alpha = _Step_0f4fbf717a47479eaa1a77f0d38201d7_Out_2_Float;
surface.AlphaClipThreshold = 0.5;
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
    output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
    output.TimeParameters =                             _TimeParameters.xyz;

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
#pragma target 2.0
#pragma vertex vert
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
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_TEXCOORD0
#define VARYINGS_NEED_TEXCOORD1
#define VARYINGS_NEED_TEXCOORD2
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_META
#define _FOG_FRAGMENT 1
#define _ALPHATEST_ON 1
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
 float4 Color;
};
struct SurfaceDescriptionInputs
{
 float3 WorldSpacePosition;
 float4 Color;
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
 float3 WorldSpacePosition;
 float3 TimeParameters;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
 float4 texCoord0 : INTERP0;
 float4 texCoord1 : INTERP1;
 float4 texCoord2 : INTERP2;
 float4 Color : INTERP3;
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
output.Color.xyzw = input.Color;
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
output.Color = input.Color.xyzw;
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
float _Wireframe_Thickness;
float _Wireframe_Anti_aliasing;
float4 _Blade_Color_2;
float4 _Blade_Color_1;
float _Metallic;
float _Smoothness;
float _Wind_Speed;
CBUFFER_END


// Object and Global properties
float4x4 _WireframeShaderMaskData1;
float4x4 _WireframeShaderMaskData2;

// Graph Includes
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"

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

void UnityGetInstanceID_float(out float Out)
{
#if UNITY_ANY_INSTANCING_ENABLED
    Out = unity_InstanceID;
#else
    Out = 0;
#endif
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Fraction_float(float In, out float Out)
{
    Out = frac(In);
}

void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
{
    Out = lerp(A, B, T);
}

void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
{
Out = A * B;
}

void Unity_Fraction_float3(float3 In, out float3 Out)
{
    Out = frac(In);
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Multiply_float_float(float A, float B, out float Out)
{
Out = A * B;
}

void Unity_Sine_float(float In, out float Out)
{
    Out = sin(In);
}

void Unity_DegreesToRadians_float(float In, out float Out)
{
    Out = radians(In);
}

void Unity_Rotate_Radians_float(float2 UV, float2 Center, float Rotation, out float2 Out)
{
    //rotation matrix
    UV -= Center;
    float s = sin(Rotation);
    float c = cos(Rotation);

    //center rotation matrix
    float2x2 rMatrix = float2x2(c, -s, s, c);
    rMatrix *= 0.5;
    rMatrix += 0.5;
    rMatrix = rMatrix*2 - 1;

    //multiply the UVs by the rotation matrix
    UV.xy = mul(UV.xy, rMatrix);
    UV += Center;

    Out = UV;
}

void Unity_Cosine_float(float In, out float Out)
{
    Out = cos(In);
}

void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
{
    RGBA = float4(R, G, B, A);
    RGB = float3(R, G, B);
    RG = float2(R, G);
}

void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
{
Out = A * B;
}

void Unity_DotProduct_float2(float2 A, float2 B, out float Out)
{
    Out = dot(A, B);
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
    Out = A + B;
}

void Unity_Negate_float(float In, out float Out)
{
    Out = -1 * In;
}

float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
{
float x; Hash_Tchou_2_1_float(p, x);
return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
{
float2 p = UV * Scale.xy;
float2 ip = floor(p);
float2 fp = frac(p);
float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
    Out = smoothstep(Edge1, Edge2, In);
}

void Unity_Saturate_float(float In, out float Out)
{
    Out = saturate(In);
}

void Unity_Lerp_float2(float2 A, float2 B, float2 T, out float2 Out)
{
    Out = lerp(A, B, T);
}

void Unity_SquareRoot_float(float In, out float Out)
{
    Out = sqrt(In);
}

void Unity_Maximum_float(float A, float B, out float Out)
{
    Out = max(A, B);
}

void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
{
    Out = A / B;
}

void Unity_Lerp_float(float A, float B, float T, out float Out)
{
    Out = lerp(A, B, T);
}

struct Bindings_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float
{
float3 TimeParameters;
};

void SG_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float(float _WindDirection, float _WindSpeed, float _WindDirectionVariation, float _PerBladeRandomTimeOffset, float _PerBladeWindIntensityVariation, float _WindIntensity, Bindings_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float IN, out float2 WindDirection_1, out float WindIntensity_2, out float3 Random_3)
{
float2 _Vector2_42921bc8d43346a4bbad7aa650d15962_Out_0_Vector2 = float2(1, 0);
float3 _Multiply_b6ed4cc094134c21943e217e6e271dae_Out_2_Vector3;
Unity_Multiply_float3_float3(SHADERGRAPH_OBJECT_POSITION, float3(37, 190, 29), _Multiply_b6ed4cc094134c21943e217e6e271dae_Out_2_Vector3);
float3 _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3;
Unity_Fraction_float3(_Multiply_b6ed4cc094134c21943e217e6e271dae_Out_2_Vector3, _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3);
float _Split_3967427c51c24bb79cef645976364a55_R_1_Float = _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3[0];
float _Split_3967427c51c24bb79cef645976364a55_G_2_Float = _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3[1];
float _Split_3967427c51c24bb79cef645976364a55_B_3_Float = _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3[2];
float _Split_3967427c51c24bb79cef645976364a55_A_4_Float = 0;
float _Add_ffd28ed6ff854810bd439fbdfc4b2cc2_Out_2_Float;
Unity_Add_float(IN.TimeParameters.x, _Split_3967427c51c24bb79cef645976364a55_B_3_Float, _Add_ffd28ed6ff854810bd439fbdfc4b2cc2_Out_2_Float);
float _Multiply_1185303c6c5d481190d5375ac379cab8_Out_2_Float;
Unity_Multiply_float_float(_Add_ffd28ed6ff854810bd439fbdfc4b2cc2_Out_2_Float, 3, _Multiply_1185303c6c5d481190d5375ac379cab8_Out_2_Float);
float _Sine_c919089f2f34401face2dd9897c9725c_Out_1_Float;
Unity_Sine_float(_Multiply_1185303c6c5d481190d5375ac379cab8_Out_2_Float, _Sine_c919089f2f34401face2dd9897c9725c_Out_1_Float);
float _Property_40290747561641a1bdf5517e6a93430d_Out_0_Float = _WindDirectionVariation;
float _DegreesToRadians_a7fe82a177484cd0af99b4027bc4e3bc_Out_1_Float;
Unity_DegreesToRadians_float(_Property_40290747561641a1bdf5517e6a93430d_Out_0_Float, _DegreesToRadians_a7fe82a177484cd0af99b4027bc4e3bc_Out_1_Float);
float _Multiply_c6dbf243e66746b490b03900b2b27467_Out_2_Float;
Unity_Multiply_float_float(_Sine_c919089f2f34401face2dd9897c9725c_Out_1_Float, _DegreesToRadians_a7fe82a177484cd0af99b4027bc4e3bc_Out_1_Float, _Multiply_c6dbf243e66746b490b03900b2b27467_Out_2_Float);
float2 _Rotate_cf73d535c5fb437aa68912dc0e09ba2f_Out_3_Vector2;
Unity_Rotate_Radians_float(_Vector2_42921bc8d43346a4bbad7aa650d15962_Out_0_Vector2, float2 (0, 0), _Multiply_c6dbf243e66746b490b03900b2b27467_Out_2_Float, _Rotate_cf73d535c5fb437aa68912dc0e09ba2f_Out_3_Vector2);
float _Property_df02aaa16377442d91f0c6be7d036d51_Out_0_Float = _WindDirection;
float _DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float;
Unity_DegreesToRadians_float(_Property_df02aaa16377442d91f0c6be7d036d51_Out_0_Float, _DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float);
float _Add_b051e3fa11c048dd978791daff07720d_Out_2_Float;
Unity_Add_float(_Multiply_c6dbf243e66746b490b03900b2b27467_Out_2_Float, _DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float, _Add_b051e3fa11c048dd978791daff07720d_Out_2_Float);
float _Cosine_0847069386bc4c12a90e1fe3eb1eee73_Out_1_Float;
Unity_Cosine_float(_Add_b051e3fa11c048dd978791daff07720d_Out_2_Float, _Cosine_0847069386bc4c12a90e1fe3eb1eee73_Out_1_Float);
float _Sine_379c87a4cd3c419293869dee73c52de0_Out_1_Float;
Unity_Sine_float(_Add_b051e3fa11c048dd978791daff07720d_Out_2_Float, _Sine_379c87a4cd3c419293869dee73c52de0_Out_1_Float);
float4 _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RGBA_4_Vector4;
float3 _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RGB_5_Vector3;
float2 _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RG_6_Vector2;
Unity_Combine_float(_Cosine_0847069386bc4c12a90e1fe3eb1eee73_Out_1_Float, _Sine_379c87a4cd3c419293869dee73c52de0_Out_1_Float, 0, 0, _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RGBA_4_Vector4, _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RGB_5_Vector3, _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RG_6_Vector2);
float2 _Swizzle_db678fc97ec448fda50408084410c787_Out_1_Vector2 = SHADERGRAPH_OBJECT_POSITION.xz;
float2 _Multiply_5833218c1a7c4d9586d5e8c69ddaabac_Out_2_Vector2;
Unity_Multiply_float2_float2(_Swizzle_db678fc97ec448fda50408084410c787_Out_1_Vector2, float2(0.5, 0.5), _Multiply_5833218c1a7c4d9586d5e8c69ddaabac_Out_2_Vector2);
float _Cosine_3388e8245f6647ca98f5aa9339130c65_Out_1_Float;
Unity_Cosine_float(_DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float, _Cosine_3388e8245f6647ca98f5aa9339130c65_Out_1_Float);
float _Sine_0b39f9f73b2c4016a046ad8da4b84c11_Out_1_Float;
Unity_Sine_float(_DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float, _Sine_0b39f9f73b2c4016a046ad8da4b84c11_Out_1_Float);
float4 _Combine_7f78efe98e4641c1981d47da9bbbe70f_RGBA_4_Vector4;
float3 _Combine_7f78efe98e4641c1981d47da9bbbe70f_RGB_5_Vector3;
float2 _Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2;
Unity_Combine_float(_Cosine_3388e8245f6647ca98f5aa9339130c65_Out_1_Float, _Sine_0b39f9f73b2c4016a046ad8da4b84c11_Out_1_Float, 0, 0, _Combine_7f78efe98e4641c1981d47da9bbbe70f_RGBA_4_Vector4, _Combine_7f78efe98e4641c1981d47da9bbbe70f_RGB_5_Vector3, _Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2);
float _DotProduct_27327ffeb11d404c96d6820c42272ca8_Out_2_Float;
Unity_DotProduct_float2(_Multiply_5833218c1a7c4d9586d5e8c69ddaabac_Out_2_Vector2, _Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2, _DotProduct_27327ffeb11d404c96d6820c42272ca8_Out_2_Float);
float _Multiply_8dc73d49a3b547a19bf5c0d8a4a09920_Out_2_Float;
Unity_Multiply_float_float(_DotProduct_27327ffeb11d404c96d6820c42272ca8_Out_2_Float, 0.7, _Multiply_8dc73d49a3b547a19bf5c0d8a4a09920_Out_2_Float);
float2 _Multiply_c8e01038fa74488a86a9759343a555f5_Out_2_Vector2;
Unity_Multiply_float2_float2((_Multiply_8dc73d49a3b547a19bf5c0d8a4a09920_Out_2_Float.xx), _Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2, _Multiply_c8e01038fa74488a86a9759343a555f5_Out_2_Vector2);
float _Multiply_69e2c5b6e72c4faf8d83ead16a5c0cd6_Out_2_Float;
Unity_Multiply_float_float(_Cosine_3388e8245f6647ca98f5aa9339130c65_Out_1_Float, -1.5708, _Multiply_69e2c5b6e72c4faf8d83ead16a5c0cd6_Out_2_Float);
float4 _Combine_2f7388d585a24290a659f20482d78d94_RGBA_4_Vector4;
float3 _Combine_2f7388d585a24290a659f20482d78d94_RGB_5_Vector3;
float2 _Combine_2f7388d585a24290a659f20482d78d94_RG_6_Vector2;
Unity_Combine_float(_Sine_0b39f9f73b2c4016a046ad8da4b84c11_Out_1_Float, _Multiply_69e2c5b6e72c4faf8d83ead16a5c0cd6_Out_2_Float, 0, 0, _Combine_2f7388d585a24290a659f20482d78d94_RGBA_4_Vector4, _Combine_2f7388d585a24290a659f20482d78d94_RGB_5_Vector3, _Combine_2f7388d585a24290a659f20482d78d94_RG_6_Vector2);
float _DotProduct_e3247c7835f0404893730bc5dcd240a0_Out_2_Float;
Unity_DotProduct_float2(_Multiply_5833218c1a7c4d9586d5e8c69ddaabac_Out_2_Vector2, _Combine_2f7388d585a24290a659f20482d78d94_RG_6_Vector2, _DotProduct_e3247c7835f0404893730bc5dcd240a0_Out_2_Float);
float2 _Multiply_ed7373e7bd6347f89e44dacc83ccf8c1_Out_2_Vector2;
Unity_Multiply_float2_float2((_DotProduct_e3247c7835f0404893730bc5dcd240a0_Out_2_Float.xx), _Combine_2f7388d585a24290a659f20482d78d94_RG_6_Vector2, _Multiply_ed7373e7bd6347f89e44dacc83ccf8c1_Out_2_Vector2);
float2 _Add_f950bfd74ec2464b89d972d5f43aa5b7_Out_2_Vector2;
Unity_Add_float2(_Multiply_c8e01038fa74488a86a9759343a555f5_Out_2_Vector2, _Multiply_ed7373e7bd6347f89e44dacc83ccf8c1_Out_2_Vector2, _Add_f950bfd74ec2464b89d972d5f43aa5b7_Out_2_Vector2);
float _Property_8c38f0ae55594c8787ad0a52af13731b_Out_0_Float = _WindSpeed;
float _Negate_47564bc9ce9645a5916ebc05fb9d63df_Out_1_Float;
Unity_Negate_float(_Property_8c38f0ae55594c8787ad0a52af13731b_Out_0_Float, _Negate_47564bc9ce9645a5916ebc05fb9d63df_Out_1_Float);
float _Multiply_e311852a737c422594c328d00e16414c_Out_2_Float;
Unity_Multiply_float_float(IN.TimeParameters.x, _Negate_47564bc9ce9645a5916ebc05fb9d63df_Out_1_Float, _Multiply_e311852a737c422594c328d00e16414c_Out_2_Float);
float _Property_347528760e804b2ab165732f176f3e97_Out_0_Float = _PerBladeRandomTimeOffset;
float _Multiply_0657e69a5c9b4cb783a0d4021b58a9b1_Out_2_Float;
Unity_Multiply_float_float(_Split_3967427c51c24bb79cef645976364a55_R_1_Float, _Property_347528760e804b2ab165732f176f3e97_Out_0_Float, _Multiply_0657e69a5c9b4cb783a0d4021b58a9b1_Out_2_Float);
float _Add_8e1a8d342102407f97ee7c7b88271e7d_Out_2_Float;
Unity_Add_float(_Multiply_e311852a737c422594c328d00e16414c_Out_2_Float, _Multiply_0657e69a5c9b4cb783a0d4021b58a9b1_Out_2_Float, _Add_8e1a8d342102407f97ee7c7b88271e7d_Out_2_Float);
float2 _Multiply_e39ee6e978424683b1858114ff959110_Out_2_Vector2;
Unity_Multiply_float2_float2(_Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2, (_Add_8e1a8d342102407f97ee7c7b88271e7d_Out_2_Float.xx), _Multiply_e39ee6e978424683b1858114ff959110_Out_2_Vector2);
float2 _Add_302cec4f55d64a65bf1160e9d23f9b71_Out_2_Vector2;
Unity_Add_float2(_Add_f950bfd74ec2464b89d972d5f43aa5b7_Out_2_Vector2, _Multiply_e39ee6e978424683b1858114ff959110_Out_2_Vector2, _Add_302cec4f55d64a65bf1160e9d23f9b71_Out_2_Vector2);
float _GradientNoise_f0d0f1452f814e03824cb2ceb16d6ad2_Out_2_Float;
Unity_GradientNoise_Deterministic_float(_Add_302cec4f55d64a65bf1160e9d23f9b71_Out_2_Vector2, 0.8, _GradientNoise_f0d0f1452f814e03824cb2ceb16d6ad2_Out_2_Float);
float _Smoothstep_4ca6b3a56ada4447bcfcabe8e1a6ee2b_Out_3_Float;
Unity_Smoothstep_float(-0.5, 1.5, _GradientNoise_f0d0f1452f814e03824cb2ceb16d6ad2_Out_2_Float, _Smoothstep_4ca6b3a56ada4447bcfcabe8e1a6ee2b_Out_3_Float);
float _Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float;
Unity_Saturate_float(_Smoothstep_4ca6b3a56ada4447bcfcabe8e1a6ee2b_Out_3_Float, _Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float);
float2 _Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2;
Unity_Lerp_float2(_Rotate_cf73d535c5fb437aa68912dc0e09ba2f_Out_3_Vector2, _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RG_6_Vector2, (_Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float.xx), _Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2);
float _DotProduct_b6d4ff1e79f54760a1f13bc5172c426b_Out_2_Float;
Unity_DotProduct_float2(_Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2, _Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2, _DotProduct_b6d4ff1e79f54760a1f13bc5172c426b_Out_2_Float);
float _SquareRoot_ec802f46201b45ac867b479ae083b1ee_Out_1_Float;
Unity_SquareRoot_float(_DotProduct_b6d4ff1e79f54760a1f13bc5172c426b_Out_2_Float, _SquareRoot_ec802f46201b45ac867b479ae083b1ee_Out_1_Float);
float _Maximum_56d7bd23f19a4866b35324380205c891_Out_2_Float;
Unity_Maximum_float(_SquareRoot_ec802f46201b45ac867b479ae083b1ee_Out_1_Float, 1E-05, _Maximum_56d7bd23f19a4866b35324380205c891_Out_2_Float);
float2 _Divide_bfbaafc2be014557bf2a163156a11a26_Out_2_Vector2;
Unity_Divide_float2(_Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2, (_Maximum_56d7bd23f19a4866b35324380205c891_Out_2_Float.xx), _Divide_bfbaafc2be014557bf2a163156a11a26_Out_2_Vector2);
float _Property_f1f58df30464478cb038a178d9e83682_Out_0_Float = _WindIntensity;
float _Add_ed2907c2a73440cc83d0b31366c5c7ae_Out_2_Float;
Unity_Add_float(IN.TimeParameters.x, _Split_3967427c51c24bb79cef645976364a55_B_3_Float, _Add_ed2907c2a73440cc83d0b31366c5c7ae_Out_2_Float);
float _Multiply_f0258532eb174f5393420713f84f6c8e_Out_2_Float;
Unity_Multiply_float_float(_Add_ed2907c2a73440cc83d0b31366c5c7ae_Out_2_Float, 2, _Multiply_f0258532eb174f5393420713f84f6c8e_Out_2_Float);
float _Sine_17bbe1505e754bbd9eedc59d0757132f_Out_1_Float;
Unity_Sine_float(_Multiply_f0258532eb174f5393420713f84f6c8e_Out_2_Float, _Sine_17bbe1505e754bbd9eedc59d0757132f_Out_1_Float);
float _Multiply_bfdbccbbf3584e1eb7d34b97e3a771c5_Out_2_Float;
Unity_Multiply_float_float(_Add_ed2907c2a73440cc83d0b31366c5c7ae_Out_2_Float, 3, _Multiply_bfdbccbbf3584e1eb7d34b97e3a771c5_Out_2_Float);
float _Sine_775bcfb1287e450094240576942d7a07_Out_1_Float;
Unity_Sine_float(_Multiply_bfdbccbbf3584e1eb7d34b97e3a771c5_Out_2_Float, _Sine_775bcfb1287e450094240576942d7a07_Out_1_Float);
float _Lerp_3cef0baddeb24a408278d7e18640ec45_Out_3_Float;
Unity_Lerp_float(_Sine_17bbe1505e754bbd9eedc59d0757132f_Out_1_Float, _Sine_775bcfb1287e450094240576942d7a07_Out_1_Float, _Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float, _Lerp_3cef0baddeb24a408278d7e18640ec45_Out_3_Float);
float _Property_59edf586db864b7a9b70a1acca2de692_Out_0_Float = _PerBladeWindIntensityVariation;
float _Multiply_13aa0e7d9b29467fa9ca1e4db82d023c_Out_2_Float;
Unity_Multiply_float_float(_Lerp_3cef0baddeb24a408278d7e18640ec45_Out_3_Float, _Property_59edf586db864b7a9b70a1acca2de692_Out_0_Float, _Multiply_13aa0e7d9b29467fa9ca1e4db82d023c_Out_2_Float);
float _Add_5a191ec83e8345689f15b7e3b2da0e21_Out_2_Float;
Unity_Add_float(_Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float, _Multiply_13aa0e7d9b29467fa9ca1e4db82d023c_Out_2_Float, _Add_5a191ec83e8345689f15b7e3b2da0e21_Out_2_Float);
float _Lerp_fb2e17ff05c44b1b8daaa248df6af035_Out_3_Float;
Unity_Lerp_float(0, _Property_f1f58df30464478cb038a178d9e83682_Out_0_Float, _Add_5a191ec83e8345689f15b7e3b2da0e21_Out_2_Float, _Lerp_fb2e17ff05c44b1b8daaa248df6af035_Out_3_Float);
float _Multiply_1565a94cae5148adaa4ad80e978368c6_Out_2_Float;
Unity_Multiply_float_float(_SquareRoot_ec802f46201b45ac867b479ae083b1ee_Out_1_Float, _Lerp_fb2e17ff05c44b1b8daaa248df6af035_Out_3_Float, _Multiply_1565a94cae5148adaa4ad80e978368c6_Out_2_Float);
WindDirection_1 = _Divide_bfbaafc2be014557bf2a163156a11a26_Out_2_Vector2;
WindIntensity_2 = _Multiply_1565a94cae5148adaa4ad80e978368c6_Out_2_Float;
Random_3 = _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3;
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

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_MatrixConstruction_Row_float (float4 M0, float4 M1, float4 M2, float4 M3, out float4x4 Out4x4, out float3x3 Out3x3, out float2x2 Out2x2)
{
Out4x4 = float4x4(M0.x, M0.y, M0.z, M0.w, M1.x, M1.y, M1.z, M1.w, M2.x, M2.y, M2.z, M2.w, M3.x, M3.y, M3.z, M3.w);
Out3x3 = float3x3(M0.x, M0.y, M0.z, M1.x, M1.y, M1.z, M2.x, M2.y, M2.z);
Out2x2 = float2x2(M0.x, M0.y, M1.x, M1.y);
}

void Unity_Multiply_float4x4_float4(float4x4 A, float4 B, out float4 Out)
{
Out = mul(A, B);
}

void Unity_Add_float3(float3 A, float3 B, out float3 Out)
{
    Out = A + B;
}

struct Bindings_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float
{
float3 ObjectSpaceNormal;
float3 ObjectSpaceTangent;
float3 ObjectSpacePosition;
};

void SG_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float(float3 _PositionOS, bool _PositionOS_3016357c5e324f0e825ebc4f84f71f27_IsConnected, float3 _NormalOS, bool _NormalOS_6443e352350b4de9ae048680d0b154e4_IsConnected, float3 _TangentOS, bool _TangentOS_307e55ce70df463b90fe1b65f35443d9_IsConnected, float3 _PivotOffset, float3 _AxisOrientation, float4 _PivotAxis, int _OutputSpace, Bindings_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float IN, out float3 Position_1, out float3 Normal_2, out float3 Tangent_3)
{
float4 _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M0_1_Vector4 = UNITY_MATRIX_I_V[0];
float4 _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M1_2_Vector4 = UNITY_MATRIX_I_V[1];
float4 _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M2_3_Vector4 = UNITY_MATRIX_I_V[2];
float4 _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M3_4_Vector4 = UNITY_MATRIX_I_V[3];
float4 _Property_ecb1ace83c9743d78d86f543dfba0991_Out_0_Vector4 = _PivotAxis;
float4x4 _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4;
float3x3 _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var3x3_5_Matrix3;
float2x2 _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var2x2_6_Matrix2;
Unity_MatrixConstruction_Row_float(_MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M0_1_Vector4, _Property_ecb1ace83c9743d78d86f543dfba0991_Out_0_Vector4, _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M2_3_Vector4, _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M3_4_Vector4, _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4, _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var3x3_5_Matrix3, _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var2x2_6_Matrix2);
float3 _Property_41894a58127942aaae689326334e61fc_Out_0_Vector3 = _PositionOS;
bool _Property_41894a58127942aaae689326334e61fc_Out_0_Vector3_IsConnected = _PositionOS_3016357c5e324f0e825ebc4f84f71f27_IsConnected;
float3 _BranchOnInputConnection_9706ae1834c64f399a8f850ec2dbbb55_Out_3_Vector3 = _Property_41894a58127942aaae689326334e61fc_Out_0_Vector3_IsConnected ? _Property_41894a58127942aaae689326334e61fc_Out_0_Vector3 : IN.ObjectSpacePosition;
float3 _Multiply_cc7f14533a6c433b98a087240efbf8f8_Out_2_Vector3;
Unity_Multiply_float3_float3(_BranchOnInputConnection_9706ae1834c64f399a8f850ec2dbbb55_Out_3_Vector3, float3(length(float3(UNITY_MATRIX_M[0].x, UNITY_MATRIX_M[1].x, UNITY_MATRIX_M[2].x)),
                             length(float3(UNITY_MATRIX_M[0].y, UNITY_MATRIX_M[1].y, UNITY_MATRIX_M[2].y)),
                             length(float3(UNITY_MATRIX_M[0].z, UNITY_MATRIX_M[1].z, UNITY_MATRIX_M[2].z))), _Multiply_cc7f14533a6c433b98a087240efbf8f8_Out_2_Vector3);
float3 _Property_5affae77929448b994beb6b8ffca0b9a_Out_0_Vector3 = _AxisOrientation;
float3 _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3;
Unity_Multiply_float3_float3(_Multiply_cc7f14533a6c433b98a087240efbf8f8_Out_2_Vector3, _Property_5affae77929448b994beb6b8ffca0b9a_Out_0_Vector3, _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3);
float _Split_d13fd31126ee4b94b419613a1463bb24_R_1_Float = _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3[0];
float _Split_d13fd31126ee4b94b419613a1463bb24_G_2_Float = _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3[1];
float _Split_d13fd31126ee4b94b419613a1463bb24_B_3_Float = _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3[2];
float _Split_d13fd31126ee4b94b419613a1463bb24_A_4_Float = 0;
float4 _Combine_3e277c5566fd4af089d839ecf52390f8_RGBA_4_Vector4;
float3 _Combine_3e277c5566fd4af089d839ecf52390f8_RGB_5_Vector3;
float2 _Combine_3e277c5566fd4af089d839ecf52390f8_RG_6_Vector2;
Unity_Combine_float(_Split_d13fd31126ee4b94b419613a1463bb24_R_1_Float, _Split_d13fd31126ee4b94b419613a1463bb24_G_2_Float, _Split_d13fd31126ee4b94b419613a1463bb24_B_3_Float, 0, _Combine_3e277c5566fd4af089d839ecf52390f8_RGBA_4_Vector4, _Combine_3e277c5566fd4af089d839ecf52390f8_RGB_5_Vector3, _Combine_3e277c5566fd4af089d839ecf52390f8_RG_6_Vector2);
float4 _Multiply_b71678c838b541ce80f71613338319bb_Out_2_Vector4;
Unity_Multiply_float4x4_float4(_MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4, _Combine_3e277c5566fd4af089d839ecf52390f8_RGBA_4_Vector4, _Multiply_b71678c838b541ce80f71613338319bb_Out_2_Vector4);
float3 _Swizzle_533fdda21ca44bb783d1af6880283be8_Out_1_Vector3 = _Multiply_b71678c838b541ce80f71613338319bb_Out_2_Vector4.xyz;
float3 _Add_10d54894eefd4263a31339a71dc6a555_Out_2_Vector3;
Unity_Add_float3(_Swizzle_533fdda21ca44bb783d1af6880283be8_Out_1_Vector3, SHADERGRAPH_OBJECT_POSITION, _Add_10d54894eefd4263a31339a71dc6a555_Out_2_Vector3);
float3 _Property_3e2f21cb09ef4a95a3da553bc8c93907_Out_0_Vector3 = _PivotOffset;
float3 _Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3;
Unity_Add_float3(_Add_10d54894eefd4263a31339a71dc6a555_Out_2_Vector3, _Property_3e2f21cb09ef4a95a3da553bc8c93907_Out_0_Vector3, _Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3);
float3 _Transform_c7b91c9bd5a24cbba16a486b2128d2ff_Out_1_Vector3;
{
// Converting Position from AbsoluteWorld to Object via world space
float3 world;
world = GetCameraRelativePositionWS(_Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3.xyz);
_Transform_c7b91c9bd5a24cbba16a486b2128d2ff_Out_1_Vector3 = TransformWorldToObject(world);
}
float3 _OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3;
if (_OutputSpace == 0)
{
_OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3 = _Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3;
}
else if (_OutputSpace == 1)
{
_OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3 = _Transform_c7b91c9bd5a24cbba16a486b2128d2ff_Out_1_Vector3;
}
else
{
_OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3 = _Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3;
}
float3 _Property_6e320129056e479593a9673a6404c2a3_Out_0_Vector3 = _NormalOS;
bool _Property_6e320129056e479593a9673a6404c2a3_Out_0_Vector3_IsConnected = _NormalOS_6443e352350b4de9ae048680d0b154e4_IsConnected;
float3 _BranchOnInputConnection_cdbf96fcdcc94bbc8e16e41d2064eac0_Out_3_Vector3 = _Property_6e320129056e479593a9673a6404c2a3_Out_0_Vector3_IsConnected ? _Property_6e320129056e479593a9673a6404c2a3_Out_0_Vector3 : IN.ObjectSpaceNormal;
float _Split_9df7389f2a034b16b14e80d7ea3cc9eb_R_1_Float = _BranchOnInputConnection_cdbf96fcdcc94bbc8e16e41d2064eac0_Out_3_Vector3[0];
float _Split_9df7389f2a034b16b14e80d7ea3cc9eb_G_2_Float = _BranchOnInputConnection_cdbf96fcdcc94bbc8e16e41d2064eac0_Out_3_Vector3[1];
float _Split_9df7389f2a034b16b14e80d7ea3cc9eb_B_3_Float = _BranchOnInputConnection_cdbf96fcdcc94bbc8e16e41d2064eac0_Out_3_Vector3[2];
float _Split_9df7389f2a034b16b14e80d7ea3cc9eb_A_4_Float = 0;
float4 _Combine_45448fd8d869482ba046251ea2a4986d_RGBA_4_Vector4;
float3 _Combine_45448fd8d869482ba046251ea2a4986d_RGB_5_Vector3;
float2 _Combine_45448fd8d869482ba046251ea2a4986d_RG_6_Vector2;
Unity_Combine_float(_Split_9df7389f2a034b16b14e80d7ea3cc9eb_R_1_Float, _Split_9df7389f2a034b16b14e80d7ea3cc9eb_G_2_Float, _Split_9df7389f2a034b16b14e80d7ea3cc9eb_B_3_Float, 0, _Combine_45448fd8d869482ba046251ea2a4986d_RGBA_4_Vector4, _Combine_45448fd8d869482ba046251ea2a4986d_RGB_5_Vector3, _Combine_45448fd8d869482ba046251ea2a4986d_RG_6_Vector2);
float4 _Multiply_fa8c745148884874b6bda6c5b00b1faf_Out_2_Vector4;
Unity_Multiply_float4x4_float4(_MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4, _Combine_45448fd8d869482ba046251ea2a4986d_RGBA_4_Vector4, _Multiply_fa8c745148884874b6bda6c5b00b1faf_Out_2_Vector4);
float3 _Swizzle_aac6fdf714634855bbb2102e1f03176a_Out_1_Vector3 = _Multiply_fa8c745148884874b6bda6c5b00b1faf_Out_2_Vector4.xyz;
float3 _Transform_ca9dd6096e414ef1aab3fc9c46b8a751_Out_1_Vector3;
{
// Converting Normal from AbsoluteWorld to Object via world space
float3 world;
world = _Swizzle_aac6fdf714634855bbb2102e1f03176a_Out_1_Vector3.xyz;
_Transform_ca9dd6096e414ef1aab3fc9c46b8a751_Out_1_Vector3 = TransformWorldToObjectNormal(world, true);
}
float3 _OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3;
if (_OutputSpace == 0)
{
_OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3 = _Swizzle_aac6fdf714634855bbb2102e1f03176a_Out_1_Vector3;
}
else if (_OutputSpace == 1)
{
_OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3 = _Transform_ca9dd6096e414ef1aab3fc9c46b8a751_Out_1_Vector3;
}
else
{
_OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3 = _Swizzle_aac6fdf714634855bbb2102e1f03176a_Out_1_Vector3;
}
float3 _Property_1caa087de4794f53880c4f3b725272b1_Out_0_Vector3 = _TangentOS;
bool _Property_1caa087de4794f53880c4f3b725272b1_Out_0_Vector3_IsConnected = _TangentOS_307e55ce70df463b90fe1b65f35443d9_IsConnected;
float3 _BranchOnInputConnection_49631555af044120aade11fe1ef46744_Out_3_Vector3 = _Property_1caa087de4794f53880c4f3b725272b1_Out_0_Vector3_IsConnected ? _Property_1caa087de4794f53880c4f3b725272b1_Out_0_Vector3 : IN.ObjectSpaceTangent;
float _Split_38da75d926c34146b97327ecc7d7d0e3_R_1_Float = _BranchOnInputConnection_49631555af044120aade11fe1ef46744_Out_3_Vector3[0];
float _Split_38da75d926c34146b97327ecc7d7d0e3_G_2_Float = _BranchOnInputConnection_49631555af044120aade11fe1ef46744_Out_3_Vector3[1];
float _Split_38da75d926c34146b97327ecc7d7d0e3_B_3_Float = _BranchOnInputConnection_49631555af044120aade11fe1ef46744_Out_3_Vector3[2];
float _Split_38da75d926c34146b97327ecc7d7d0e3_A_4_Float = 0;
float4 _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGBA_4_Vector4;
float3 _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGB_5_Vector3;
float2 _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RG_6_Vector2;
Unity_Combine_float(_Split_38da75d926c34146b97327ecc7d7d0e3_R_1_Float, _Split_38da75d926c34146b97327ecc7d7d0e3_G_2_Float, _Split_38da75d926c34146b97327ecc7d7d0e3_B_3_Float, 0, _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGBA_4_Vector4, _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGB_5_Vector3, _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RG_6_Vector2);
float4 _Multiply_88c2defdee7945aabfad7d073ac15b3c_Out_2_Vector4;
Unity_Multiply_float4x4_float4(_MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4, _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGBA_4_Vector4, _Multiply_88c2defdee7945aabfad7d073ac15b3c_Out_2_Vector4);
float3 _Swizzle_dadec3efd6244574a802fd3e0ab56bb5_Out_1_Vector3 = _Multiply_88c2defdee7945aabfad7d073ac15b3c_Out_2_Vector4.xyz;
float3 _Transform_8906312bacad44698b5e2899041600be_Out_1_Vector3;
{
// Converting Normal from AbsoluteWorld to Object via world space
float3 world;
world = _Swizzle_dadec3efd6244574a802fd3e0ab56bb5_Out_1_Vector3.xyz;
_Transform_8906312bacad44698b5e2899041600be_Out_1_Vector3 = TransformWorldToObjectNormal(world, true);
}
float3 _OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3;
if (_OutputSpace == 0)
{
_OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3 = _Swizzle_dadec3efd6244574a802fd3e0ab56bb5_Out_1_Vector3;
}
else if (_OutputSpace == 1)
{
_OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3 = _Transform_8906312bacad44698b5e2899041600be_Out_1_Vector3;
}
else
{
_OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3 = _Swizzle_dadec3efd6244574a802fd3e0ab56bb5_Out_1_Vector3;
}
Position_1 = _OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3;
Normal_2 = _OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3;
Tangent_3 = _OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3;
}

void Unity_Add_float4(float4 A, float4 B, out float4 Out)
{
    Out = A + B;
}

void Unity_Step_float(float Edge, float In, out float Out)
{
    Out = step(Edge, In);
}

// Custom interpolators pre vertex
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
float4 Color;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
float _InstanceID_2537a879f018425d9660432f4ea146f2_Out_0_Float;
UnityGetInstanceID_float(_InstanceID_2537a879f018425d9660432f4ea146f2_Out_0_Float);
float _Divide_63d9682156f042468629ccab8669beb8_Out_2_Float;
Unity_Divide_float(_InstanceID_2537a879f018425d9660432f4ea146f2_Out_0_Float, 37, _Divide_63d9682156f042468629ccab8669beb8_Out_2_Float);
float _Fraction_052ea01a8a0b4f83b7c6c139a0975ccc_Out_1_Float;
Unity_Fraction_float(_Divide_63d9682156f042468629ccab8669beb8_Out_2_Float, _Fraction_052ea01a8a0b4f83b7c6c139a0975ccc_Out_1_Float);
float4 _Property_19686efd1fb54b50a7d330cad1112554_Out_0_Vector4 = _Blade_Color_2;
float4 _Property_d254ba2921d340f982bfbcfaf5916ad3_Out_0_Vector4 = _Blade_Color_1;
float4 _Lerp_58d751d66dbc479a8656d14d2baf579f_Out_3_Vector4;
Unity_Lerp_float4(_Property_d254ba2921d340f982bfbcfaf5916ad3_Out_0_Vector4, _Property_19686efd1fb54b50a7d330cad1112554_Out_0_Vector4, (_Fraction_052ea01a8a0b4f83b7c6c139a0975ccc_Out_1_Float.xxxx), _Lerp_58d751d66dbc479a8656d14d2baf579f_Out_3_Vector4);
float _Property_dbcc12976b2c4eb4a63c1284e5f1d305_Out_0_Float = _Wind_Speed;
Bindings_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba;
_FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba.TimeParameters = IN.TimeParameters;
float2 _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindDirection_1_Vector2;
float _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindIntensity_2_Float;
float3 _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_Random_3_Vector3;
SG_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float(124, _Property_dbcc12976b2c4eb4a63c1284e5f1d305_Out_0_Float, 0.01, 0.2, 0.1, 0.2, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindDirection_1_Vector2, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindIntensity_2_Float, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_Random_3_Vector3);
float4x4 _Property_e6333f42f10045b8874ca797f7698f1d_Out_0_Matrix4 = _WireframeShaderMaskData1;
float _DynamicMask_50b2c29949db4c9087fc753d984c4250_Out_3_Float;
WireframeShaderDynamicMaskCube_float(IN.WorldSpacePosition, _Property_e6333f42f10045b8874ca797f7698f1d_Out_0_Matrix4, 0, _DynamicMask_50b2c29949db4c9087fc753d984c4250_Out_3_Float);
float4x4 _Property_37070fbe8a4e4576a732a3a352dec45e_Out_0_Matrix4 = _WireframeShaderMaskData2;
float _DynamicMask_0c15310c869f45a5bb095f810944777b_Out_3_Float;
WireframeShaderDynamicMaskSphere_float(IN.WorldSpacePosition, _Property_37070fbe8a4e4576a732a3a352dec45e_Out_0_Matrix4, 0, _DynamicMask_0c15310c869f45a5bb095f810944777b_Out_3_Float);
float _Add_4e24bc1118f94bdb89aeba5ac3067e43_Out_2_Float;
Unity_Add_float(_DynamicMask_50b2c29949db4c9087fc753d984c4250_Out_3_Float, _DynamicMask_0c15310c869f45a5bb095f810944777b_Out_3_Float, _Add_4e24bc1118f94bdb89aeba5ac3067e43_Out_2_Float);
float _Saturate_b1a2ecfe1d1842778d5653a46a7b1782_Out_1_Float;
Unity_Saturate_float(_Add_4e24bc1118f94bdb89aeba5ac3067e43_Out_2_Float, _Saturate_b1a2ecfe1d1842778d5653a46a7b1782_Out_1_Float);
float _OneMinus_153cdd2db72f462c97a7c55eccd49567_Out_1_Float;
Unity_OneMinus_float(_Saturate_b1a2ecfe1d1842778d5653a46a7b1782_Out_1_Float, _OneMinus_153cdd2db72f462c97a7c55eccd49567_Out_1_Float);
float _Multiply_cff561f8195f49188db426fdc084a6ce_Out_2_Float;
Unity_Multiply_float_float(_OneMinus_153cdd2db72f462c97a7c55eccd49567_Out_1_Float, -1, _Multiply_cff561f8195f49188db426fdc084a6ce_Out_2_Float);
float3 _Vector3_2dea481cbff74205a7cee900960a51a9_Out_0_Vector3 = float3(_FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindIntensity_2_Float, _Multiply_cff561f8195f49188db426fdc084a6ce_Out_2_Float, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindIntensity_2_Float);
Bindings_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f;
_BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f.ObjectSpaceNormal = IN.ObjectSpaceNormal;
_BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f.ObjectSpaceTangent = IN.ObjectSpaceTangent;
_BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f.ObjectSpacePosition = IN.ObjectSpacePosition;
float3 _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Position_1_Vector3;
float3 _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Normal_2_Vector3;
float3 _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Tangent_3_Vector3;
SG_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float(float3 (0, 0, 0), false, float3 (0, 0, 0), false, float3 (0, 0, 0), false, _Vector3_2dea481cbff74205a7cee900960a51a9_Out_0_Vector3, float3 (-1, 1, 1), float4 (0, 1, 0, 0), 1, _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f, _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Position_1_Vector3, _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Normal_2_Vector3, _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Tangent_3_Vector3);
description.Position = _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Position_1_Vector3;
description.Normal = IN.ObjectSpaceNormal;
description.Tangent = IN.ObjectSpaceTangent;
description.Color = _Lerp_58d751d66dbc479a8656d14d2baf579f_Out_3_Vector4;
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
output.Color = input.Color;
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
float _Property_a7bf99e3e3cf4540bc6bd38a6aaab41f_Out_0_Float = _Wireframe_Thickness;
float _Property_07fc055baf6a48729fd1b78fbf96db5c_Out_0_Float = _Wireframe_Anti_aliasing;
float4 _Add_c1cf3158744d4822974d88d98d719275_Out_2_Vector4;
Unity_Add_float4(IN.Color, 0, _Add_c1cf3158744d4822974d88d98d719275_Out_2_Vector4);
float4x4 _Property_768bac82b0684cd0a21ed8a814d35a50_Out_0_Matrix4 = _WireframeShaderMaskData1;
float _DynamicMask_d8cbb946b52f4b01a4d3fd3bc3ea9de1_Out_3_Float;
WireframeShaderDynamicMaskCube_float(IN.WorldSpacePosition, _Property_768bac82b0684cd0a21ed8a814d35a50_Out_0_Matrix4, 0, _DynamicMask_d8cbb946b52f4b01a4d3fd3bc3ea9de1_Out_3_Float);
float4x4 _Property_39e6a912ee0647ed8335e7ab63cd4bed_Out_0_Matrix4 = _WireframeShaderMaskData2;
float _DynamicMask_e413c723ed49470ba4eca3bcf6362548_Out_3_Float;
WireframeShaderDynamicMaskSphere_float(IN.WorldSpacePosition, _Property_39e6a912ee0647ed8335e7ab63cd4bed_Out_0_Matrix4, 0, _DynamicMask_e413c723ed49470ba4eca3bcf6362548_Out_3_Float);
float _Add_c3b10d55feaf4b9baefa4948a8eaed75_Out_2_Float;
Unity_Add_float(_DynamicMask_d8cbb946b52f4b01a4d3fd3bc3ea9de1_Out_3_Float, _DynamicMask_e413c723ed49470ba4eca3bcf6362548_Out_3_Float, _Add_c3b10d55feaf4b9baefa4948a8eaed75_Out_2_Float);
float _Saturate_62dc9cf6a37b4fab9407e114176db70f_Out_1_Float;
Unity_Saturate_float(_Add_c3b10d55feaf4b9baefa4948a8eaed75_Out_2_Float, _Saturate_62dc9cf6a37b4fab9407e114176db70f_Out_1_Float);
float _Step_0f4fbf717a47479eaa1a77f0d38201d7_Out_2_Float;
Unity_Step_float(0.05, _Saturate_62dc9cf6a37b4fab9407e114176db70f_Out_1_Float, _Step_0f4fbf717a47479eaa1a77f0d38201d7_Out_2_Float);
surface.BaseColor = (_Add_c1cf3158744d4822974d88d98d719275_Out_2_Vector4.xyz);
surface.Emission = float3(0, 0, 0);
surface.Alpha = _Step_0f4fbf717a47479eaa1a77f0d38201d7_Out_2_Float;
surface.AlphaClipThreshold = 0.5;
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
    output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
    output.TimeParameters =                             _TimeParameters.xyz;

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

    output.Color = input.Color;





    output.WorldSpacePosition = input.positionWS;

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
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

// --------------------------------------------------
// Visual Effect Vertex Invocations
#ifdef HAVE_VFX_MODIFICATION
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
#endif

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
#define VARYINGS_NEED_POSITION_WS
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_DEPTHONLY
#define SCENESELECTIONPASS 1
#define ALPHA_CLIP_THRESHOLD 1
#define _ALPHATEST_ON 1
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
 float3 positionWS;
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
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
 float3 WorldSpacePosition;
 float3 TimeParameters;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
 float3 positionWS : INTERP0;
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
float _Wireframe_Thickness;
float _Wireframe_Anti_aliasing;
float4 _Blade_Color_2;
float4 _Blade_Color_1;
float _Metallic;
float _Smoothness;
float _Wind_Speed;
CBUFFER_END


// Object and Global properties
float4x4 _WireframeShaderMaskData1;
float4x4 _WireframeShaderMaskData2;

// Graph Includes
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"

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

void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
{
Out = A * B;
}

void Unity_Fraction_float3(float3 In, out float3 Out)
{
    Out = frac(In);
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Multiply_float_float(float A, float B, out float Out)
{
Out = A * B;
}

void Unity_Sine_float(float In, out float Out)
{
    Out = sin(In);
}

void Unity_DegreesToRadians_float(float In, out float Out)
{
    Out = radians(In);
}

void Unity_Rotate_Radians_float(float2 UV, float2 Center, float Rotation, out float2 Out)
{
    //rotation matrix
    UV -= Center;
    float s = sin(Rotation);
    float c = cos(Rotation);

    //center rotation matrix
    float2x2 rMatrix = float2x2(c, -s, s, c);
    rMatrix *= 0.5;
    rMatrix += 0.5;
    rMatrix = rMatrix*2 - 1;

    //multiply the UVs by the rotation matrix
    UV.xy = mul(UV.xy, rMatrix);
    UV += Center;

    Out = UV;
}

void Unity_Cosine_float(float In, out float Out)
{
    Out = cos(In);
}

void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
{
    RGBA = float4(R, G, B, A);
    RGB = float3(R, G, B);
    RG = float2(R, G);
}

void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
{
Out = A * B;
}

void Unity_DotProduct_float2(float2 A, float2 B, out float Out)
{
    Out = dot(A, B);
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
    Out = A + B;
}

void Unity_Negate_float(float In, out float Out)
{
    Out = -1 * In;
}

float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
{
float x; Hash_Tchou_2_1_float(p, x);
return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
{
float2 p = UV * Scale.xy;
float2 ip = floor(p);
float2 fp = frac(p);
float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
    Out = smoothstep(Edge1, Edge2, In);
}

void Unity_Saturate_float(float In, out float Out)
{
    Out = saturate(In);
}

void Unity_Lerp_float2(float2 A, float2 B, float2 T, out float2 Out)
{
    Out = lerp(A, B, T);
}

void Unity_SquareRoot_float(float In, out float Out)
{
    Out = sqrt(In);
}

void Unity_Maximum_float(float A, float B, out float Out)
{
    Out = max(A, B);
}

void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
{
    Out = A / B;
}

void Unity_Lerp_float(float A, float B, float T, out float Out)
{
    Out = lerp(A, B, T);
}

struct Bindings_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float
{
float3 TimeParameters;
};

void SG_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float(float _WindDirection, float _WindSpeed, float _WindDirectionVariation, float _PerBladeRandomTimeOffset, float _PerBladeWindIntensityVariation, float _WindIntensity, Bindings_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float IN, out float2 WindDirection_1, out float WindIntensity_2, out float3 Random_3)
{
float2 _Vector2_42921bc8d43346a4bbad7aa650d15962_Out_0_Vector2 = float2(1, 0);
float3 _Multiply_b6ed4cc094134c21943e217e6e271dae_Out_2_Vector3;
Unity_Multiply_float3_float3(SHADERGRAPH_OBJECT_POSITION, float3(37, 190, 29), _Multiply_b6ed4cc094134c21943e217e6e271dae_Out_2_Vector3);
float3 _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3;
Unity_Fraction_float3(_Multiply_b6ed4cc094134c21943e217e6e271dae_Out_2_Vector3, _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3);
float _Split_3967427c51c24bb79cef645976364a55_R_1_Float = _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3[0];
float _Split_3967427c51c24bb79cef645976364a55_G_2_Float = _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3[1];
float _Split_3967427c51c24bb79cef645976364a55_B_3_Float = _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3[2];
float _Split_3967427c51c24bb79cef645976364a55_A_4_Float = 0;
float _Add_ffd28ed6ff854810bd439fbdfc4b2cc2_Out_2_Float;
Unity_Add_float(IN.TimeParameters.x, _Split_3967427c51c24bb79cef645976364a55_B_3_Float, _Add_ffd28ed6ff854810bd439fbdfc4b2cc2_Out_2_Float);
float _Multiply_1185303c6c5d481190d5375ac379cab8_Out_2_Float;
Unity_Multiply_float_float(_Add_ffd28ed6ff854810bd439fbdfc4b2cc2_Out_2_Float, 3, _Multiply_1185303c6c5d481190d5375ac379cab8_Out_2_Float);
float _Sine_c919089f2f34401face2dd9897c9725c_Out_1_Float;
Unity_Sine_float(_Multiply_1185303c6c5d481190d5375ac379cab8_Out_2_Float, _Sine_c919089f2f34401face2dd9897c9725c_Out_1_Float);
float _Property_40290747561641a1bdf5517e6a93430d_Out_0_Float = _WindDirectionVariation;
float _DegreesToRadians_a7fe82a177484cd0af99b4027bc4e3bc_Out_1_Float;
Unity_DegreesToRadians_float(_Property_40290747561641a1bdf5517e6a93430d_Out_0_Float, _DegreesToRadians_a7fe82a177484cd0af99b4027bc4e3bc_Out_1_Float);
float _Multiply_c6dbf243e66746b490b03900b2b27467_Out_2_Float;
Unity_Multiply_float_float(_Sine_c919089f2f34401face2dd9897c9725c_Out_1_Float, _DegreesToRadians_a7fe82a177484cd0af99b4027bc4e3bc_Out_1_Float, _Multiply_c6dbf243e66746b490b03900b2b27467_Out_2_Float);
float2 _Rotate_cf73d535c5fb437aa68912dc0e09ba2f_Out_3_Vector2;
Unity_Rotate_Radians_float(_Vector2_42921bc8d43346a4bbad7aa650d15962_Out_0_Vector2, float2 (0, 0), _Multiply_c6dbf243e66746b490b03900b2b27467_Out_2_Float, _Rotate_cf73d535c5fb437aa68912dc0e09ba2f_Out_3_Vector2);
float _Property_df02aaa16377442d91f0c6be7d036d51_Out_0_Float = _WindDirection;
float _DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float;
Unity_DegreesToRadians_float(_Property_df02aaa16377442d91f0c6be7d036d51_Out_0_Float, _DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float);
float _Add_b051e3fa11c048dd978791daff07720d_Out_2_Float;
Unity_Add_float(_Multiply_c6dbf243e66746b490b03900b2b27467_Out_2_Float, _DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float, _Add_b051e3fa11c048dd978791daff07720d_Out_2_Float);
float _Cosine_0847069386bc4c12a90e1fe3eb1eee73_Out_1_Float;
Unity_Cosine_float(_Add_b051e3fa11c048dd978791daff07720d_Out_2_Float, _Cosine_0847069386bc4c12a90e1fe3eb1eee73_Out_1_Float);
float _Sine_379c87a4cd3c419293869dee73c52de0_Out_1_Float;
Unity_Sine_float(_Add_b051e3fa11c048dd978791daff07720d_Out_2_Float, _Sine_379c87a4cd3c419293869dee73c52de0_Out_1_Float);
float4 _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RGBA_4_Vector4;
float3 _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RGB_5_Vector3;
float2 _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RG_6_Vector2;
Unity_Combine_float(_Cosine_0847069386bc4c12a90e1fe3eb1eee73_Out_1_Float, _Sine_379c87a4cd3c419293869dee73c52de0_Out_1_Float, 0, 0, _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RGBA_4_Vector4, _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RGB_5_Vector3, _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RG_6_Vector2);
float2 _Swizzle_db678fc97ec448fda50408084410c787_Out_1_Vector2 = SHADERGRAPH_OBJECT_POSITION.xz;
float2 _Multiply_5833218c1a7c4d9586d5e8c69ddaabac_Out_2_Vector2;
Unity_Multiply_float2_float2(_Swizzle_db678fc97ec448fda50408084410c787_Out_1_Vector2, float2(0.5, 0.5), _Multiply_5833218c1a7c4d9586d5e8c69ddaabac_Out_2_Vector2);
float _Cosine_3388e8245f6647ca98f5aa9339130c65_Out_1_Float;
Unity_Cosine_float(_DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float, _Cosine_3388e8245f6647ca98f5aa9339130c65_Out_1_Float);
float _Sine_0b39f9f73b2c4016a046ad8da4b84c11_Out_1_Float;
Unity_Sine_float(_DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float, _Sine_0b39f9f73b2c4016a046ad8da4b84c11_Out_1_Float);
float4 _Combine_7f78efe98e4641c1981d47da9bbbe70f_RGBA_4_Vector4;
float3 _Combine_7f78efe98e4641c1981d47da9bbbe70f_RGB_5_Vector3;
float2 _Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2;
Unity_Combine_float(_Cosine_3388e8245f6647ca98f5aa9339130c65_Out_1_Float, _Sine_0b39f9f73b2c4016a046ad8da4b84c11_Out_1_Float, 0, 0, _Combine_7f78efe98e4641c1981d47da9bbbe70f_RGBA_4_Vector4, _Combine_7f78efe98e4641c1981d47da9bbbe70f_RGB_5_Vector3, _Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2);
float _DotProduct_27327ffeb11d404c96d6820c42272ca8_Out_2_Float;
Unity_DotProduct_float2(_Multiply_5833218c1a7c4d9586d5e8c69ddaabac_Out_2_Vector2, _Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2, _DotProduct_27327ffeb11d404c96d6820c42272ca8_Out_2_Float);
float _Multiply_8dc73d49a3b547a19bf5c0d8a4a09920_Out_2_Float;
Unity_Multiply_float_float(_DotProduct_27327ffeb11d404c96d6820c42272ca8_Out_2_Float, 0.7, _Multiply_8dc73d49a3b547a19bf5c0d8a4a09920_Out_2_Float);
float2 _Multiply_c8e01038fa74488a86a9759343a555f5_Out_2_Vector2;
Unity_Multiply_float2_float2((_Multiply_8dc73d49a3b547a19bf5c0d8a4a09920_Out_2_Float.xx), _Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2, _Multiply_c8e01038fa74488a86a9759343a555f5_Out_2_Vector2);
float _Multiply_69e2c5b6e72c4faf8d83ead16a5c0cd6_Out_2_Float;
Unity_Multiply_float_float(_Cosine_3388e8245f6647ca98f5aa9339130c65_Out_1_Float, -1.5708, _Multiply_69e2c5b6e72c4faf8d83ead16a5c0cd6_Out_2_Float);
float4 _Combine_2f7388d585a24290a659f20482d78d94_RGBA_4_Vector4;
float3 _Combine_2f7388d585a24290a659f20482d78d94_RGB_5_Vector3;
float2 _Combine_2f7388d585a24290a659f20482d78d94_RG_6_Vector2;
Unity_Combine_float(_Sine_0b39f9f73b2c4016a046ad8da4b84c11_Out_1_Float, _Multiply_69e2c5b6e72c4faf8d83ead16a5c0cd6_Out_2_Float, 0, 0, _Combine_2f7388d585a24290a659f20482d78d94_RGBA_4_Vector4, _Combine_2f7388d585a24290a659f20482d78d94_RGB_5_Vector3, _Combine_2f7388d585a24290a659f20482d78d94_RG_6_Vector2);
float _DotProduct_e3247c7835f0404893730bc5dcd240a0_Out_2_Float;
Unity_DotProduct_float2(_Multiply_5833218c1a7c4d9586d5e8c69ddaabac_Out_2_Vector2, _Combine_2f7388d585a24290a659f20482d78d94_RG_6_Vector2, _DotProduct_e3247c7835f0404893730bc5dcd240a0_Out_2_Float);
float2 _Multiply_ed7373e7bd6347f89e44dacc83ccf8c1_Out_2_Vector2;
Unity_Multiply_float2_float2((_DotProduct_e3247c7835f0404893730bc5dcd240a0_Out_2_Float.xx), _Combine_2f7388d585a24290a659f20482d78d94_RG_6_Vector2, _Multiply_ed7373e7bd6347f89e44dacc83ccf8c1_Out_2_Vector2);
float2 _Add_f950bfd74ec2464b89d972d5f43aa5b7_Out_2_Vector2;
Unity_Add_float2(_Multiply_c8e01038fa74488a86a9759343a555f5_Out_2_Vector2, _Multiply_ed7373e7bd6347f89e44dacc83ccf8c1_Out_2_Vector2, _Add_f950bfd74ec2464b89d972d5f43aa5b7_Out_2_Vector2);
float _Property_8c38f0ae55594c8787ad0a52af13731b_Out_0_Float = _WindSpeed;
float _Negate_47564bc9ce9645a5916ebc05fb9d63df_Out_1_Float;
Unity_Negate_float(_Property_8c38f0ae55594c8787ad0a52af13731b_Out_0_Float, _Negate_47564bc9ce9645a5916ebc05fb9d63df_Out_1_Float);
float _Multiply_e311852a737c422594c328d00e16414c_Out_2_Float;
Unity_Multiply_float_float(IN.TimeParameters.x, _Negate_47564bc9ce9645a5916ebc05fb9d63df_Out_1_Float, _Multiply_e311852a737c422594c328d00e16414c_Out_2_Float);
float _Property_347528760e804b2ab165732f176f3e97_Out_0_Float = _PerBladeRandomTimeOffset;
float _Multiply_0657e69a5c9b4cb783a0d4021b58a9b1_Out_2_Float;
Unity_Multiply_float_float(_Split_3967427c51c24bb79cef645976364a55_R_1_Float, _Property_347528760e804b2ab165732f176f3e97_Out_0_Float, _Multiply_0657e69a5c9b4cb783a0d4021b58a9b1_Out_2_Float);
float _Add_8e1a8d342102407f97ee7c7b88271e7d_Out_2_Float;
Unity_Add_float(_Multiply_e311852a737c422594c328d00e16414c_Out_2_Float, _Multiply_0657e69a5c9b4cb783a0d4021b58a9b1_Out_2_Float, _Add_8e1a8d342102407f97ee7c7b88271e7d_Out_2_Float);
float2 _Multiply_e39ee6e978424683b1858114ff959110_Out_2_Vector2;
Unity_Multiply_float2_float2(_Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2, (_Add_8e1a8d342102407f97ee7c7b88271e7d_Out_2_Float.xx), _Multiply_e39ee6e978424683b1858114ff959110_Out_2_Vector2);
float2 _Add_302cec4f55d64a65bf1160e9d23f9b71_Out_2_Vector2;
Unity_Add_float2(_Add_f950bfd74ec2464b89d972d5f43aa5b7_Out_2_Vector2, _Multiply_e39ee6e978424683b1858114ff959110_Out_2_Vector2, _Add_302cec4f55d64a65bf1160e9d23f9b71_Out_2_Vector2);
float _GradientNoise_f0d0f1452f814e03824cb2ceb16d6ad2_Out_2_Float;
Unity_GradientNoise_Deterministic_float(_Add_302cec4f55d64a65bf1160e9d23f9b71_Out_2_Vector2, 0.8, _GradientNoise_f0d0f1452f814e03824cb2ceb16d6ad2_Out_2_Float);
float _Smoothstep_4ca6b3a56ada4447bcfcabe8e1a6ee2b_Out_3_Float;
Unity_Smoothstep_float(-0.5, 1.5, _GradientNoise_f0d0f1452f814e03824cb2ceb16d6ad2_Out_2_Float, _Smoothstep_4ca6b3a56ada4447bcfcabe8e1a6ee2b_Out_3_Float);
float _Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float;
Unity_Saturate_float(_Smoothstep_4ca6b3a56ada4447bcfcabe8e1a6ee2b_Out_3_Float, _Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float);
float2 _Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2;
Unity_Lerp_float2(_Rotate_cf73d535c5fb437aa68912dc0e09ba2f_Out_3_Vector2, _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RG_6_Vector2, (_Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float.xx), _Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2);
float _DotProduct_b6d4ff1e79f54760a1f13bc5172c426b_Out_2_Float;
Unity_DotProduct_float2(_Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2, _Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2, _DotProduct_b6d4ff1e79f54760a1f13bc5172c426b_Out_2_Float);
float _SquareRoot_ec802f46201b45ac867b479ae083b1ee_Out_1_Float;
Unity_SquareRoot_float(_DotProduct_b6d4ff1e79f54760a1f13bc5172c426b_Out_2_Float, _SquareRoot_ec802f46201b45ac867b479ae083b1ee_Out_1_Float);
float _Maximum_56d7bd23f19a4866b35324380205c891_Out_2_Float;
Unity_Maximum_float(_SquareRoot_ec802f46201b45ac867b479ae083b1ee_Out_1_Float, 1E-05, _Maximum_56d7bd23f19a4866b35324380205c891_Out_2_Float);
float2 _Divide_bfbaafc2be014557bf2a163156a11a26_Out_2_Vector2;
Unity_Divide_float2(_Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2, (_Maximum_56d7bd23f19a4866b35324380205c891_Out_2_Float.xx), _Divide_bfbaafc2be014557bf2a163156a11a26_Out_2_Vector2);
float _Property_f1f58df30464478cb038a178d9e83682_Out_0_Float = _WindIntensity;
float _Add_ed2907c2a73440cc83d0b31366c5c7ae_Out_2_Float;
Unity_Add_float(IN.TimeParameters.x, _Split_3967427c51c24bb79cef645976364a55_B_3_Float, _Add_ed2907c2a73440cc83d0b31366c5c7ae_Out_2_Float);
float _Multiply_f0258532eb174f5393420713f84f6c8e_Out_2_Float;
Unity_Multiply_float_float(_Add_ed2907c2a73440cc83d0b31366c5c7ae_Out_2_Float, 2, _Multiply_f0258532eb174f5393420713f84f6c8e_Out_2_Float);
float _Sine_17bbe1505e754bbd9eedc59d0757132f_Out_1_Float;
Unity_Sine_float(_Multiply_f0258532eb174f5393420713f84f6c8e_Out_2_Float, _Sine_17bbe1505e754bbd9eedc59d0757132f_Out_1_Float);
float _Multiply_bfdbccbbf3584e1eb7d34b97e3a771c5_Out_2_Float;
Unity_Multiply_float_float(_Add_ed2907c2a73440cc83d0b31366c5c7ae_Out_2_Float, 3, _Multiply_bfdbccbbf3584e1eb7d34b97e3a771c5_Out_2_Float);
float _Sine_775bcfb1287e450094240576942d7a07_Out_1_Float;
Unity_Sine_float(_Multiply_bfdbccbbf3584e1eb7d34b97e3a771c5_Out_2_Float, _Sine_775bcfb1287e450094240576942d7a07_Out_1_Float);
float _Lerp_3cef0baddeb24a408278d7e18640ec45_Out_3_Float;
Unity_Lerp_float(_Sine_17bbe1505e754bbd9eedc59d0757132f_Out_1_Float, _Sine_775bcfb1287e450094240576942d7a07_Out_1_Float, _Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float, _Lerp_3cef0baddeb24a408278d7e18640ec45_Out_3_Float);
float _Property_59edf586db864b7a9b70a1acca2de692_Out_0_Float = _PerBladeWindIntensityVariation;
float _Multiply_13aa0e7d9b29467fa9ca1e4db82d023c_Out_2_Float;
Unity_Multiply_float_float(_Lerp_3cef0baddeb24a408278d7e18640ec45_Out_3_Float, _Property_59edf586db864b7a9b70a1acca2de692_Out_0_Float, _Multiply_13aa0e7d9b29467fa9ca1e4db82d023c_Out_2_Float);
float _Add_5a191ec83e8345689f15b7e3b2da0e21_Out_2_Float;
Unity_Add_float(_Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float, _Multiply_13aa0e7d9b29467fa9ca1e4db82d023c_Out_2_Float, _Add_5a191ec83e8345689f15b7e3b2da0e21_Out_2_Float);
float _Lerp_fb2e17ff05c44b1b8daaa248df6af035_Out_3_Float;
Unity_Lerp_float(0, _Property_f1f58df30464478cb038a178d9e83682_Out_0_Float, _Add_5a191ec83e8345689f15b7e3b2da0e21_Out_2_Float, _Lerp_fb2e17ff05c44b1b8daaa248df6af035_Out_3_Float);
float _Multiply_1565a94cae5148adaa4ad80e978368c6_Out_2_Float;
Unity_Multiply_float_float(_SquareRoot_ec802f46201b45ac867b479ae083b1ee_Out_1_Float, _Lerp_fb2e17ff05c44b1b8daaa248df6af035_Out_3_Float, _Multiply_1565a94cae5148adaa4ad80e978368c6_Out_2_Float);
WindDirection_1 = _Divide_bfbaafc2be014557bf2a163156a11a26_Out_2_Vector2;
WindIntensity_2 = _Multiply_1565a94cae5148adaa4ad80e978368c6_Out_2_Float;
Random_3 = _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3;
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

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_MatrixConstruction_Row_float (float4 M0, float4 M1, float4 M2, float4 M3, out float4x4 Out4x4, out float3x3 Out3x3, out float2x2 Out2x2)
{
Out4x4 = float4x4(M0.x, M0.y, M0.z, M0.w, M1.x, M1.y, M1.z, M1.w, M2.x, M2.y, M2.z, M2.w, M3.x, M3.y, M3.z, M3.w);
Out3x3 = float3x3(M0.x, M0.y, M0.z, M1.x, M1.y, M1.z, M2.x, M2.y, M2.z);
Out2x2 = float2x2(M0.x, M0.y, M1.x, M1.y);
}

void Unity_Multiply_float4x4_float4(float4x4 A, float4 B, out float4 Out)
{
Out = mul(A, B);
}

void Unity_Add_float3(float3 A, float3 B, out float3 Out)
{
    Out = A + B;
}

struct Bindings_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float
{
float3 ObjectSpaceNormal;
float3 ObjectSpaceTangent;
float3 ObjectSpacePosition;
};

void SG_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float(float3 _PositionOS, bool _PositionOS_3016357c5e324f0e825ebc4f84f71f27_IsConnected, float3 _NormalOS, bool _NormalOS_6443e352350b4de9ae048680d0b154e4_IsConnected, float3 _TangentOS, bool _TangentOS_307e55ce70df463b90fe1b65f35443d9_IsConnected, float3 _PivotOffset, float3 _AxisOrientation, float4 _PivotAxis, int _OutputSpace, Bindings_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float IN, out float3 Position_1, out float3 Normal_2, out float3 Tangent_3)
{
float4 _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M0_1_Vector4 = UNITY_MATRIX_I_V[0];
float4 _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M1_2_Vector4 = UNITY_MATRIX_I_V[1];
float4 _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M2_3_Vector4 = UNITY_MATRIX_I_V[2];
float4 _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M3_4_Vector4 = UNITY_MATRIX_I_V[3];
float4 _Property_ecb1ace83c9743d78d86f543dfba0991_Out_0_Vector4 = _PivotAxis;
float4x4 _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4;
float3x3 _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var3x3_5_Matrix3;
float2x2 _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var2x2_6_Matrix2;
Unity_MatrixConstruction_Row_float(_MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M0_1_Vector4, _Property_ecb1ace83c9743d78d86f543dfba0991_Out_0_Vector4, _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M2_3_Vector4, _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M3_4_Vector4, _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4, _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var3x3_5_Matrix3, _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var2x2_6_Matrix2);
float3 _Property_41894a58127942aaae689326334e61fc_Out_0_Vector3 = _PositionOS;
bool _Property_41894a58127942aaae689326334e61fc_Out_0_Vector3_IsConnected = _PositionOS_3016357c5e324f0e825ebc4f84f71f27_IsConnected;
float3 _BranchOnInputConnection_9706ae1834c64f399a8f850ec2dbbb55_Out_3_Vector3 = _Property_41894a58127942aaae689326334e61fc_Out_0_Vector3_IsConnected ? _Property_41894a58127942aaae689326334e61fc_Out_0_Vector3 : IN.ObjectSpacePosition;
float3 _Multiply_cc7f14533a6c433b98a087240efbf8f8_Out_2_Vector3;
Unity_Multiply_float3_float3(_BranchOnInputConnection_9706ae1834c64f399a8f850ec2dbbb55_Out_3_Vector3, float3(length(float3(UNITY_MATRIX_M[0].x, UNITY_MATRIX_M[1].x, UNITY_MATRIX_M[2].x)),
                             length(float3(UNITY_MATRIX_M[0].y, UNITY_MATRIX_M[1].y, UNITY_MATRIX_M[2].y)),
                             length(float3(UNITY_MATRIX_M[0].z, UNITY_MATRIX_M[1].z, UNITY_MATRIX_M[2].z))), _Multiply_cc7f14533a6c433b98a087240efbf8f8_Out_2_Vector3);
float3 _Property_5affae77929448b994beb6b8ffca0b9a_Out_0_Vector3 = _AxisOrientation;
float3 _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3;
Unity_Multiply_float3_float3(_Multiply_cc7f14533a6c433b98a087240efbf8f8_Out_2_Vector3, _Property_5affae77929448b994beb6b8ffca0b9a_Out_0_Vector3, _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3);
float _Split_d13fd31126ee4b94b419613a1463bb24_R_1_Float = _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3[0];
float _Split_d13fd31126ee4b94b419613a1463bb24_G_2_Float = _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3[1];
float _Split_d13fd31126ee4b94b419613a1463bb24_B_3_Float = _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3[2];
float _Split_d13fd31126ee4b94b419613a1463bb24_A_4_Float = 0;
float4 _Combine_3e277c5566fd4af089d839ecf52390f8_RGBA_4_Vector4;
float3 _Combine_3e277c5566fd4af089d839ecf52390f8_RGB_5_Vector3;
float2 _Combine_3e277c5566fd4af089d839ecf52390f8_RG_6_Vector2;
Unity_Combine_float(_Split_d13fd31126ee4b94b419613a1463bb24_R_1_Float, _Split_d13fd31126ee4b94b419613a1463bb24_G_2_Float, _Split_d13fd31126ee4b94b419613a1463bb24_B_3_Float, 0, _Combine_3e277c5566fd4af089d839ecf52390f8_RGBA_4_Vector4, _Combine_3e277c5566fd4af089d839ecf52390f8_RGB_5_Vector3, _Combine_3e277c5566fd4af089d839ecf52390f8_RG_6_Vector2);
float4 _Multiply_b71678c838b541ce80f71613338319bb_Out_2_Vector4;
Unity_Multiply_float4x4_float4(_MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4, _Combine_3e277c5566fd4af089d839ecf52390f8_RGBA_4_Vector4, _Multiply_b71678c838b541ce80f71613338319bb_Out_2_Vector4);
float3 _Swizzle_533fdda21ca44bb783d1af6880283be8_Out_1_Vector3 = _Multiply_b71678c838b541ce80f71613338319bb_Out_2_Vector4.xyz;
float3 _Add_10d54894eefd4263a31339a71dc6a555_Out_2_Vector3;
Unity_Add_float3(_Swizzle_533fdda21ca44bb783d1af6880283be8_Out_1_Vector3, SHADERGRAPH_OBJECT_POSITION, _Add_10d54894eefd4263a31339a71dc6a555_Out_2_Vector3);
float3 _Property_3e2f21cb09ef4a95a3da553bc8c93907_Out_0_Vector3 = _PivotOffset;
float3 _Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3;
Unity_Add_float3(_Add_10d54894eefd4263a31339a71dc6a555_Out_2_Vector3, _Property_3e2f21cb09ef4a95a3da553bc8c93907_Out_0_Vector3, _Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3);
float3 _Transform_c7b91c9bd5a24cbba16a486b2128d2ff_Out_1_Vector3;
{
// Converting Position from AbsoluteWorld to Object via world space
float3 world;
world = GetCameraRelativePositionWS(_Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3.xyz);
_Transform_c7b91c9bd5a24cbba16a486b2128d2ff_Out_1_Vector3 = TransformWorldToObject(world);
}
float3 _OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3;
if (_OutputSpace == 0)
{
_OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3 = _Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3;
}
else if (_OutputSpace == 1)
{
_OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3 = _Transform_c7b91c9bd5a24cbba16a486b2128d2ff_Out_1_Vector3;
}
else
{
_OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3 = _Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3;
}
float3 _Property_6e320129056e479593a9673a6404c2a3_Out_0_Vector3 = _NormalOS;
bool _Property_6e320129056e479593a9673a6404c2a3_Out_0_Vector3_IsConnected = _NormalOS_6443e352350b4de9ae048680d0b154e4_IsConnected;
float3 _BranchOnInputConnection_cdbf96fcdcc94bbc8e16e41d2064eac0_Out_3_Vector3 = _Property_6e320129056e479593a9673a6404c2a3_Out_0_Vector3_IsConnected ? _Property_6e320129056e479593a9673a6404c2a3_Out_0_Vector3 : IN.ObjectSpaceNormal;
float _Split_9df7389f2a034b16b14e80d7ea3cc9eb_R_1_Float = _BranchOnInputConnection_cdbf96fcdcc94bbc8e16e41d2064eac0_Out_3_Vector3[0];
float _Split_9df7389f2a034b16b14e80d7ea3cc9eb_G_2_Float = _BranchOnInputConnection_cdbf96fcdcc94bbc8e16e41d2064eac0_Out_3_Vector3[1];
float _Split_9df7389f2a034b16b14e80d7ea3cc9eb_B_3_Float = _BranchOnInputConnection_cdbf96fcdcc94bbc8e16e41d2064eac0_Out_3_Vector3[2];
float _Split_9df7389f2a034b16b14e80d7ea3cc9eb_A_4_Float = 0;
float4 _Combine_45448fd8d869482ba046251ea2a4986d_RGBA_4_Vector4;
float3 _Combine_45448fd8d869482ba046251ea2a4986d_RGB_5_Vector3;
float2 _Combine_45448fd8d869482ba046251ea2a4986d_RG_6_Vector2;
Unity_Combine_float(_Split_9df7389f2a034b16b14e80d7ea3cc9eb_R_1_Float, _Split_9df7389f2a034b16b14e80d7ea3cc9eb_G_2_Float, _Split_9df7389f2a034b16b14e80d7ea3cc9eb_B_3_Float, 0, _Combine_45448fd8d869482ba046251ea2a4986d_RGBA_4_Vector4, _Combine_45448fd8d869482ba046251ea2a4986d_RGB_5_Vector3, _Combine_45448fd8d869482ba046251ea2a4986d_RG_6_Vector2);
float4 _Multiply_fa8c745148884874b6bda6c5b00b1faf_Out_2_Vector4;
Unity_Multiply_float4x4_float4(_MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4, _Combine_45448fd8d869482ba046251ea2a4986d_RGBA_4_Vector4, _Multiply_fa8c745148884874b6bda6c5b00b1faf_Out_2_Vector4);
float3 _Swizzle_aac6fdf714634855bbb2102e1f03176a_Out_1_Vector3 = _Multiply_fa8c745148884874b6bda6c5b00b1faf_Out_2_Vector4.xyz;
float3 _Transform_ca9dd6096e414ef1aab3fc9c46b8a751_Out_1_Vector3;
{
// Converting Normal from AbsoluteWorld to Object via world space
float3 world;
world = _Swizzle_aac6fdf714634855bbb2102e1f03176a_Out_1_Vector3.xyz;
_Transform_ca9dd6096e414ef1aab3fc9c46b8a751_Out_1_Vector3 = TransformWorldToObjectNormal(world, true);
}
float3 _OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3;
if (_OutputSpace == 0)
{
_OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3 = _Swizzle_aac6fdf714634855bbb2102e1f03176a_Out_1_Vector3;
}
else if (_OutputSpace == 1)
{
_OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3 = _Transform_ca9dd6096e414ef1aab3fc9c46b8a751_Out_1_Vector3;
}
else
{
_OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3 = _Swizzle_aac6fdf714634855bbb2102e1f03176a_Out_1_Vector3;
}
float3 _Property_1caa087de4794f53880c4f3b725272b1_Out_0_Vector3 = _TangentOS;
bool _Property_1caa087de4794f53880c4f3b725272b1_Out_0_Vector3_IsConnected = _TangentOS_307e55ce70df463b90fe1b65f35443d9_IsConnected;
float3 _BranchOnInputConnection_49631555af044120aade11fe1ef46744_Out_3_Vector3 = _Property_1caa087de4794f53880c4f3b725272b1_Out_0_Vector3_IsConnected ? _Property_1caa087de4794f53880c4f3b725272b1_Out_0_Vector3 : IN.ObjectSpaceTangent;
float _Split_38da75d926c34146b97327ecc7d7d0e3_R_1_Float = _BranchOnInputConnection_49631555af044120aade11fe1ef46744_Out_3_Vector3[0];
float _Split_38da75d926c34146b97327ecc7d7d0e3_G_2_Float = _BranchOnInputConnection_49631555af044120aade11fe1ef46744_Out_3_Vector3[1];
float _Split_38da75d926c34146b97327ecc7d7d0e3_B_3_Float = _BranchOnInputConnection_49631555af044120aade11fe1ef46744_Out_3_Vector3[2];
float _Split_38da75d926c34146b97327ecc7d7d0e3_A_4_Float = 0;
float4 _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGBA_4_Vector4;
float3 _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGB_5_Vector3;
float2 _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RG_6_Vector2;
Unity_Combine_float(_Split_38da75d926c34146b97327ecc7d7d0e3_R_1_Float, _Split_38da75d926c34146b97327ecc7d7d0e3_G_2_Float, _Split_38da75d926c34146b97327ecc7d7d0e3_B_3_Float, 0, _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGBA_4_Vector4, _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGB_5_Vector3, _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RG_6_Vector2);
float4 _Multiply_88c2defdee7945aabfad7d073ac15b3c_Out_2_Vector4;
Unity_Multiply_float4x4_float4(_MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4, _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGBA_4_Vector4, _Multiply_88c2defdee7945aabfad7d073ac15b3c_Out_2_Vector4);
float3 _Swizzle_dadec3efd6244574a802fd3e0ab56bb5_Out_1_Vector3 = _Multiply_88c2defdee7945aabfad7d073ac15b3c_Out_2_Vector4.xyz;
float3 _Transform_8906312bacad44698b5e2899041600be_Out_1_Vector3;
{
// Converting Normal from AbsoluteWorld to Object via world space
float3 world;
world = _Swizzle_dadec3efd6244574a802fd3e0ab56bb5_Out_1_Vector3.xyz;
_Transform_8906312bacad44698b5e2899041600be_Out_1_Vector3 = TransformWorldToObjectNormal(world, true);
}
float3 _OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3;
if (_OutputSpace == 0)
{
_OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3 = _Swizzle_dadec3efd6244574a802fd3e0ab56bb5_Out_1_Vector3;
}
else if (_OutputSpace == 1)
{
_OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3 = _Transform_8906312bacad44698b5e2899041600be_Out_1_Vector3;
}
else
{
_OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3 = _Swizzle_dadec3efd6244574a802fd3e0ab56bb5_Out_1_Vector3;
}
Position_1 = _OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3;
Normal_2 = _OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3;
Tangent_3 = _OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3;
}

void Unity_Step_float(float Edge, float In, out float Out)
{
    Out = step(Edge, In);
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
float _Property_dbcc12976b2c4eb4a63c1284e5f1d305_Out_0_Float = _Wind_Speed;
Bindings_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba;
_FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba.TimeParameters = IN.TimeParameters;
float2 _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindDirection_1_Vector2;
float _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindIntensity_2_Float;
float3 _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_Random_3_Vector3;
SG_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float(124, _Property_dbcc12976b2c4eb4a63c1284e5f1d305_Out_0_Float, 0.01, 0.2, 0.1, 0.2, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindDirection_1_Vector2, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindIntensity_2_Float, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_Random_3_Vector3);
float4x4 _Property_e6333f42f10045b8874ca797f7698f1d_Out_0_Matrix4 = _WireframeShaderMaskData1;
float _DynamicMask_50b2c29949db4c9087fc753d984c4250_Out_3_Float;
WireframeShaderDynamicMaskCube_float(IN.WorldSpacePosition, _Property_e6333f42f10045b8874ca797f7698f1d_Out_0_Matrix4, 0, _DynamicMask_50b2c29949db4c9087fc753d984c4250_Out_3_Float);
float4x4 _Property_37070fbe8a4e4576a732a3a352dec45e_Out_0_Matrix4 = _WireframeShaderMaskData2;
float _DynamicMask_0c15310c869f45a5bb095f810944777b_Out_3_Float;
WireframeShaderDynamicMaskSphere_float(IN.WorldSpacePosition, _Property_37070fbe8a4e4576a732a3a352dec45e_Out_0_Matrix4, 0, _DynamicMask_0c15310c869f45a5bb095f810944777b_Out_3_Float);
float _Add_4e24bc1118f94bdb89aeba5ac3067e43_Out_2_Float;
Unity_Add_float(_DynamicMask_50b2c29949db4c9087fc753d984c4250_Out_3_Float, _DynamicMask_0c15310c869f45a5bb095f810944777b_Out_3_Float, _Add_4e24bc1118f94bdb89aeba5ac3067e43_Out_2_Float);
float _Saturate_b1a2ecfe1d1842778d5653a46a7b1782_Out_1_Float;
Unity_Saturate_float(_Add_4e24bc1118f94bdb89aeba5ac3067e43_Out_2_Float, _Saturate_b1a2ecfe1d1842778d5653a46a7b1782_Out_1_Float);
float _OneMinus_153cdd2db72f462c97a7c55eccd49567_Out_1_Float;
Unity_OneMinus_float(_Saturate_b1a2ecfe1d1842778d5653a46a7b1782_Out_1_Float, _OneMinus_153cdd2db72f462c97a7c55eccd49567_Out_1_Float);
float _Multiply_cff561f8195f49188db426fdc084a6ce_Out_2_Float;
Unity_Multiply_float_float(_OneMinus_153cdd2db72f462c97a7c55eccd49567_Out_1_Float, -1, _Multiply_cff561f8195f49188db426fdc084a6ce_Out_2_Float);
float3 _Vector3_2dea481cbff74205a7cee900960a51a9_Out_0_Vector3 = float3(_FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindIntensity_2_Float, _Multiply_cff561f8195f49188db426fdc084a6ce_Out_2_Float, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindIntensity_2_Float);
Bindings_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f;
_BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f.ObjectSpaceNormal = IN.ObjectSpaceNormal;
_BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f.ObjectSpaceTangent = IN.ObjectSpaceTangent;
_BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f.ObjectSpacePosition = IN.ObjectSpacePosition;
float3 _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Position_1_Vector3;
float3 _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Normal_2_Vector3;
float3 _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Tangent_3_Vector3;
SG_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float(float3 (0, 0, 0), false, float3 (0, 0, 0), false, float3 (0, 0, 0), false, _Vector3_2dea481cbff74205a7cee900960a51a9_Out_0_Vector3, float3 (-1, 1, 1), float4 (0, 1, 0, 0), 1, _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f, _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Position_1_Vector3, _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Normal_2_Vector3, _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Tangent_3_Vector3);
description.Position = _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Position_1_Vector3;
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
float4x4 _Property_768bac82b0684cd0a21ed8a814d35a50_Out_0_Matrix4 = _WireframeShaderMaskData1;
float _DynamicMask_d8cbb946b52f4b01a4d3fd3bc3ea9de1_Out_3_Float;
WireframeShaderDynamicMaskCube_float(IN.WorldSpacePosition, _Property_768bac82b0684cd0a21ed8a814d35a50_Out_0_Matrix4, 0, _DynamicMask_d8cbb946b52f4b01a4d3fd3bc3ea9de1_Out_3_Float);
float4x4 _Property_39e6a912ee0647ed8335e7ab63cd4bed_Out_0_Matrix4 = _WireframeShaderMaskData2;
float _DynamicMask_e413c723ed49470ba4eca3bcf6362548_Out_3_Float;
WireframeShaderDynamicMaskSphere_float(IN.WorldSpacePosition, _Property_39e6a912ee0647ed8335e7ab63cd4bed_Out_0_Matrix4, 0, _DynamicMask_e413c723ed49470ba4eca3bcf6362548_Out_3_Float);
float _Add_c3b10d55feaf4b9baefa4948a8eaed75_Out_2_Float;
Unity_Add_float(_DynamicMask_d8cbb946b52f4b01a4d3fd3bc3ea9de1_Out_3_Float, _DynamicMask_e413c723ed49470ba4eca3bcf6362548_Out_3_Float, _Add_c3b10d55feaf4b9baefa4948a8eaed75_Out_2_Float);
float _Saturate_62dc9cf6a37b4fab9407e114176db70f_Out_1_Float;
Unity_Saturate_float(_Add_c3b10d55feaf4b9baefa4948a8eaed75_Out_2_Float, _Saturate_62dc9cf6a37b4fab9407e114176db70f_Out_1_Float);
float _Step_0f4fbf717a47479eaa1a77f0d38201d7_Out_2_Float;
Unity_Step_float(0.05, _Saturate_62dc9cf6a37b4fab9407e114176db70f_Out_1_Float, _Step_0f4fbf717a47479eaa1a77f0d38201d7_Out_2_Float);
surface.Alpha = _Step_0f4fbf717a47479eaa1a77f0d38201d7_Out_2_Float;
surface.AlphaClipThreshold = 0.5;
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
    output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
    output.TimeParameters =                             _TimeParameters.xyz;

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
#define VARYINGS_NEED_POSITION_WS
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_DEPTHONLY
#define SCENEPICKINGPASS 1
#define ALPHA_CLIP_THRESHOLD 1
#define _ALPHATEST_ON 1
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
 float3 positionWS;
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
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
 float3 WorldSpacePosition;
 float3 TimeParameters;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
 float3 positionWS : INTERP0;
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
float _Wireframe_Thickness;
float _Wireframe_Anti_aliasing;
float4 _Blade_Color_2;
float4 _Blade_Color_1;
float _Metallic;
float _Smoothness;
float _Wind_Speed;
CBUFFER_END


// Object and Global properties
float4x4 _WireframeShaderMaskData1;
float4x4 _WireframeShaderMaskData2;

// Graph Includes
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"

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

void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
{
Out = A * B;
}

void Unity_Fraction_float3(float3 In, out float3 Out)
{
    Out = frac(In);
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Multiply_float_float(float A, float B, out float Out)
{
Out = A * B;
}

void Unity_Sine_float(float In, out float Out)
{
    Out = sin(In);
}

void Unity_DegreesToRadians_float(float In, out float Out)
{
    Out = radians(In);
}

void Unity_Rotate_Radians_float(float2 UV, float2 Center, float Rotation, out float2 Out)
{
    //rotation matrix
    UV -= Center;
    float s = sin(Rotation);
    float c = cos(Rotation);

    //center rotation matrix
    float2x2 rMatrix = float2x2(c, -s, s, c);
    rMatrix *= 0.5;
    rMatrix += 0.5;
    rMatrix = rMatrix*2 - 1;

    //multiply the UVs by the rotation matrix
    UV.xy = mul(UV.xy, rMatrix);
    UV += Center;

    Out = UV;
}

void Unity_Cosine_float(float In, out float Out)
{
    Out = cos(In);
}

void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
{
    RGBA = float4(R, G, B, A);
    RGB = float3(R, G, B);
    RG = float2(R, G);
}

void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
{
Out = A * B;
}

void Unity_DotProduct_float2(float2 A, float2 B, out float Out)
{
    Out = dot(A, B);
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
    Out = A + B;
}

void Unity_Negate_float(float In, out float Out)
{
    Out = -1 * In;
}

float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
{
float x; Hash_Tchou_2_1_float(p, x);
return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
{
float2 p = UV * Scale.xy;
float2 ip = floor(p);
float2 fp = frac(p);
float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
    Out = smoothstep(Edge1, Edge2, In);
}

void Unity_Saturate_float(float In, out float Out)
{
    Out = saturate(In);
}

void Unity_Lerp_float2(float2 A, float2 B, float2 T, out float2 Out)
{
    Out = lerp(A, B, T);
}

void Unity_SquareRoot_float(float In, out float Out)
{
    Out = sqrt(In);
}

void Unity_Maximum_float(float A, float B, out float Out)
{
    Out = max(A, B);
}

void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
{
    Out = A / B;
}

void Unity_Lerp_float(float A, float B, float T, out float Out)
{
    Out = lerp(A, B, T);
}

struct Bindings_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float
{
float3 TimeParameters;
};

void SG_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float(float _WindDirection, float _WindSpeed, float _WindDirectionVariation, float _PerBladeRandomTimeOffset, float _PerBladeWindIntensityVariation, float _WindIntensity, Bindings_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float IN, out float2 WindDirection_1, out float WindIntensity_2, out float3 Random_3)
{
float2 _Vector2_42921bc8d43346a4bbad7aa650d15962_Out_0_Vector2 = float2(1, 0);
float3 _Multiply_b6ed4cc094134c21943e217e6e271dae_Out_2_Vector3;
Unity_Multiply_float3_float3(SHADERGRAPH_OBJECT_POSITION, float3(37, 190, 29), _Multiply_b6ed4cc094134c21943e217e6e271dae_Out_2_Vector3);
float3 _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3;
Unity_Fraction_float3(_Multiply_b6ed4cc094134c21943e217e6e271dae_Out_2_Vector3, _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3);
float _Split_3967427c51c24bb79cef645976364a55_R_1_Float = _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3[0];
float _Split_3967427c51c24bb79cef645976364a55_G_2_Float = _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3[1];
float _Split_3967427c51c24bb79cef645976364a55_B_3_Float = _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3[2];
float _Split_3967427c51c24bb79cef645976364a55_A_4_Float = 0;
float _Add_ffd28ed6ff854810bd439fbdfc4b2cc2_Out_2_Float;
Unity_Add_float(IN.TimeParameters.x, _Split_3967427c51c24bb79cef645976364a55_B_3_Float, _Add_ffd28ed6ff854810bd439fbdfc4b2cc2_Out_2_Float);
float _Multiply_1185303c6c5d481190d5375ac379cab8_Out_2_Float;
Unity_Multiply_float_float(_Add_ffd28ed6ff854810bd439fbdfc4b2cc2_Out_2_Float, 3, _Multiply_1185303c6c5d481190d5375ac379cab8_Out_2_Float);
float _Sine_c919089f2f34401face2dd9897c9725c_Out_1_Float;
Unity_Sine_float(_Multiply_1185303c6c5d481190d5375ac379cab8_Out_2_Float, _Sine_c919089f2f34401face2dd9897c9725c_Out_1_Float);
float _Property_40290747561641a1bdf5517e6a93430d_Out_0_Float = _WindDirectionVariation;
float _DegreesToRadians_a7fe82a177484cd0af99b4027bc4e3bc_Out_1_Float;
Unity_DegreesToRadians_float(_Property_40290747561641a1bdf5517e6a93430d_Out_0_Float, _DegreesToRadians_a7fe82a177484cd0af99b4027bc4e3bc_Out_1_Float);
float _Multiply_c6dbf243e66746b490b03900b2b27467_Out_2_Float;
Unity_Multiply_float_float(_Sine_c919089f2f34401face2dd9897c9725c_Out_1_Float, _DegreesToRadians_a7fe82a177484cd0af99b4027bc4e3bc_Out_1_Float, _Multiply_c6dbf243e66746b490b03900b2b27467_Out_2_Float);
float2 _Rotate_cf73d535c5fb437aa68912dc0e09ba2f_Out_3_Vector2;
Unity_Rotate_Radians_float(_Vector2_42921bc8d43346a4bbad7aa650d15962_Out_0_Vector2, float2 (0, 0), _Multiply_c6dbf243e66746b490b03900b2b27467_Out_2_Float, _Rotate_cf73d535c5fb437aa68912dc0e09ba2f_Out_3_Vector2);
float _Property_df02aaa16377442d91f0c6be7d036d51_Out_0_Float = _WindDirection;
float _DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float;
Unity_DegreesToRadians_float(_Property_df02aaa16377442d91f0c6be7d036d51_Out_0_Float, _DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float);
float _Add_b051e3fa11c048dd978791daff07720d_Out_2_Float;
Unity_Add_float(_Multiply_c6dbf243e66746b490b03900b2b27467_Out_2_Float, _DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float, _Add_b051e3fa11c048dd978791daff07720d_Out_2_Float);
float _Cosine_0847069386bc4c12a90e1fe3eb1eee73_Out_1_Float;
Unity_Cosine_float(_Add_b051e3fa11c048dd978791daff07720d_Out_2_Float, _Cosine_0847069386bc4c12a90e1fe3eb1eee73_Out_1_Float);
float _Sine_379c87a4cd3c419293869dee73c52de0_Out_1_Float;
Unity_Sine_float(_Add_b051e3fa11c048dd978791daff07720d_Out_2_Float, _Sine_379c87a4cd3c419293869dee73c52de0_Out_1_Float);
float4 _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RGBA_4_Vector4;
float3 _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RGB_5_Vector3;
float2 _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RG_6_Vector2;
Unity_Combine_float(_Cosine_0847069386bc4c12a90e1fe3eb1eee73_Out_1_Float, _Sine_379c87a4cd3c419293869dee73c52de0_Out_1_Float, 0, 0, _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RGBA_4_Vector4, _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RGB_5_Vector3, _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RG_6_Vector2);
float2 _Swizzle_db678fc97ec448fda50408084410c787_Out_1_Vector2 = SHADERGRAPH_OBJECT_POSITION.xz;
float2 _Multiply_5833218c1a7c4d9586d5e8c69ddaabac_Out_2_Vector2;
Unity_Multiply_float2_float2(_Swizzle_db678fc97ec448fda50408084410c787_Out_1_Vector2, float2(0.5, 0.5), _Multiply_5833218c1a7c4d9586d5e8c69ddaabac_Out_2_Vector2);
float _Cosine_3388e8245f6647ca98f5aa9339130c65_Out_1_Float;
Unity_Cosine_float(_DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float, _Cosine_3388e8245f6647ca98f5aa9339130c65_Out_1_Float);
float _Sine_0b39f9f73b2c4016a046ad8da4b84c11_Out_1_Float;
Unity_Sine_float(_DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float, _Sine_0b39f9f73b2c4016a046ad8da4b84c11_Out_1_Float);
float4 _Combine_7f78efe98e4641c1981d47da9bbbe70f_RGBA_4_Vector4;
float3 _Combine_7f78efe98e4641c1981d47da9bbbe70f_RGB_5_Vector3;
float2 _Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2;
Unity_Combine_float(_Cosine_3388e8245f6647ca98f5aa9339130c65_Out_1_Float, _Sine_0b39f9f73b2c4016a046ad8da4b84c11_Out_1_Float, 0, 0, _Combine_7f78efe98e4641c1981d47da9bbbe70f_RGBA_4_Vector4, _Combine_7f78efe98e4641c1981d47da9bbbe70f_RGB_5_Vector3, _Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2);
float _DotProduct_27327ffeb11d404c96d6820c42272ca8_Out_2_Float;
Unity_DotProduct_float2(_Multiply_5833218c1a7c4d9586d5e8c69ddaabac_Out_2_Vector2, _Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2, _DotProduct_27327ffeb11d404c96d6820c42272ca8_Out_2_Float);
float _Multiply_8dc73d49a3b547a19bf5c0d8a4a09920_Out_2_Float;
Unity_Multiply_float_float(_DotProduct_27327ffeb11d404c96d6820c42272ca8_Out_2_Float, 0.7, _Multiply_8dc73d49a3b547a19bf5c0d8a4a09920_Out_2_Float);
float2 _Multiply_c8e01038fa74488a86a9759343a555f5_Out_2_Vector2;
Unity_Multiply_float2_float2((_Multiply_8dc73d49a3b547a19bf5c0d8a4a09920_Out_2_Float.xx), _Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2, _Multiply_c8e01038fa74488a86a9759343a555f5_Out_2_Vector2);
float _Multiply_69e2c5b6e72c4faf8d83ead16a5c0cd6_Out_2_Float;
Unity_Multiply_float_float(_Cosine_3388e8245f6647ca98f5aa9339130c65_Out_1_Float, -1.5708, _Multiply_69e2c5b6e72c4faf8d83ead16a5c0cd6_Out_2_Float);
float4 _Combine_2f7388d585a24290a659f20482d78d94_RGBA_4_Vector4;
float3 _Combine_2f7388d585a24290a659f20482d78d94_RGB_5_Vector3;
float2 _Combine_2f7388d585a24290a659f20482d78d94_RG_6_Vector2;
Unity_Combine_float(_Sine_0b39f9f73b2c4016a046ad8da4b84c11_Out_1_Float, _Multiply_69e2c5b6e72c4faf8d83ead16a5c0cd6_Out_2_Float, 0, 0, _Combine_2f7388d585a24290a659f20482d78d94_RGBA_4_Vector4, _Combine_2f7388d585a24290a659f20482d78d94_RGB_5_Vector3, _Combine_2f7388d585a24290a659f20482d78d94_RG_6_Vector2);
float _DotProduct_e3247c7835f0404893730bc5dcd240a0_Out_2_Float;
Unity_DotProduct_float2(_Multiply_5833218c1a7c4d9586d5e8c69ddaabac_Out_2_Vector2, _Combine_2f7388d585a24290a659f20482d78d94_RG_6_Vector2, _DotProduct_e3247c7835f0404893730bc5dcd240a0_Out_2_Float);
float2 _Multiply_ed7373e7bd6347f89e44dacc83ccf8c1_Out_2_Vector2;
Unity_Multiply_float2_float2((_DotProduct_e3247c7835f0404893730bc5dcd240a0_Out_2_Float.xx), _Combine_2f7388d585a24290a659f20482d78d94_RG_6_Vector2, _Multiply_ed7373e7bd6347f89e44dacc83ccf8c1_Out_2_Vector2);
float2 _Add_f950bfd74ec2464b89d972d5f43aa5b7_Out_2_Vector2;
Unity_Add_float2(_Multiply_c8e01038fa74488a86a9759343a555f5_Out_2_Vector2, _Multiply_ed7373e7bd6347f89e44dacc83ccf8c1_Out_2_Vector2, _Add_f950bfd74ec2464b89d972d5f43aa5b7_Out_2_Vector2);
float _Property_8c38f0ae55594c8787ad0a52af13731b_Out_0_Float = _WindSpeed;
float _Negate_47564bc9ce9645a5916ebc05fb9d63df_Out_1_Float;
Unity_Negate_float(_Property_8c38f0ae55594c8787ad0a52af13731b_Out_0_Float, _Negate_47564bc9ce9645a5916ebc05fb9d63df_Out_1_Float);
float _Multiply_e311852a737c422594c328d00e16414c_Out_2_Float;
Unity_Multiply_float_float(IN.TimeParameters.x, _Negate_47564bc9ce9645a5916ebc05fb9d63df_Out_1_Float, _Multiply_e311852a737c422594c328d00e16414c_Out_2_Float);
float _Property_347528760e804b2ab165732f176f3e97_Out_0_Float = _PerBladeRandomTimeOffset;
float _Multiply_0657e69a5c9b4cb783a0d4021b58a9b1_Out_2_Float;
Unity_Multiply_float_float(_Split_3967427c51c24bb79cef645976364a55_R_1_Float, _Property_347528760e804b2ab165732f176f3e97_Out_0_Float, _Multiply_0657e69a5c9b4cb783a0d4021b58a9b1_Out_2_Float);
float _Add_8e1a8d342102407f97ee7c7b88271e7d_Out_2_Float;
Unity_Add_float(_Multiply_e311852a737c422594c328d00e16414c_Out_2_Float, _Multiply_0657e69a5c9b4cb783a0d4021b58a9b1_Out_2_Float, _Add_8e1a8d342102407f97ee7c7b88271e7d_Out_2_Float);
float2 _Multiply_e39ee6e978424683b1858114ff959110_Out_2_Vector2;
Unity_Multiply_float2_float2(_Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2, (_Add_8e1a8d342102407f97ee7c7b88271e7d_Out_2_Float.xx), _Multiply_e39ee6e978424683b1858114ff959110_Out_2_Vector2);
float2 _Add_302cec4f55d64a65bf1160e9d23f9b71_Out_2_Vector2;
Unity_Add_float2(_Add_f950bfd74ec2464b89d972d5f43aa5b7_Out_2_Vector2, _Multiply_e39ee6e978424683b1858114ff959110_Out_2_Vector2, _Add_302cec4f55d64a65bf1160e9d23f9b71_Out_2_Vector2);
float _GradientNoise_f0d0f1452f814e03824cb2ceb16d6ad2_Out_2_Float;
Unity_GradientNoise_Deterministic_float(_Add_302cec4f55d64a65bf1160e9d23f9b71_Out_2_Vector2, 0.8, _GradientNoise_f0d0f1452f814e03824cb2ceb16d6ad2_Out_2_Float);
float _Smoothstep_4ca6b3a56ada4447bcfcabe8e1a6ee2b_Out_3_Float;
Unity_Smoothstep_float(-0.5, 1.5, _GradientNoise_f0d0f1452f814e03824cb2ceb16d6ad2_Out_2_Float, _Smoothstep_4ca6b3a56ada4447bcfcabe8e1a6ee2b_Out_3_Float);
float _Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float;
Unity_Saturate_float(_Smoothstep_4ca6b3a56ada4447bcfcabe8e1a6ee2b_Out_3_Float, _Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float);
float2 _Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2;
Unity_Lerp_float2(_Rotate_cf73d535c5fb437aa68912dc0e09ba2f_Out_3_Vector2, _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RG_6_Vector2, (_Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float.xx), _Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2);
float _DotProduct_b6d4ff1e79f54760a1f13bc5172c426b_Out_2_Float;
Unity_DotProduct_float2(_Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2, _Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2, _DotProduct_b6d4ff1e79f54760a1f13bc5172c426b_Out_2_Float);
float _SquareRoot_ec802f46201b45ac867b479ae083b1ee_Out_1_Float;
Unity_SquareRoot_float(_DotProduct_b6d4ff1e79f54760a1f13bc5172c426b_Out_2_Float, _SquareRoot_ec802f46201b45ac867b479ae083b1ee_Out_1_Float);
float _Maximum_56d7bd23f19a4866b35324380205c891_Out_2_Float;
Unity_Maximum_float(_SquareRoot_ec802f46201b45ac867b479ae083b1ee_Out_1_Float, 1E-05, _Maximum_56d7bd23f19a4866b35324380205c891_Out_2_Float);
float2 _Divide_bfbaafc2be014557bf2a163156a11a26_Out_2_Vector2;
Unity_Divide_float2(_Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2, (_Maximum_56d7bd23f19a4866b35324380205c891_Out_2_Float.xx), _Divide_bfbaafc2be014557bf2a163156a11a26_Out_2_Vector2);
float _Property_f1f58df30464478cb038a178d9e83682_Out_0_Float = _WindIntensity;
float _Add_ed2907c2a73440cc83d0b31366c5c7ae_Out_2_Float;
Unity_Add_float(IN.TimeParameters.x, _Split_3967427c51c24bb79cef645976364a55_B_3_Float, _Add_ed2907c2a73440cc83d0b31366c5c7ae_Out_2_Float);
float _Multiply_f0258532eb174f5393420713f84f6c8e_Out_2_Float;
Unity_Multiply_float_float(_Add_ed2907c2a73440cc83d0b31366c5c7ae_Out_2_Float, 2, _Multiply_f0258532eb174f5393420713f84f6c8e_Out_2_Float);
float _Sine_17bbe1505e754bbd9eedc59d0757132f_Out_1_Float;
Unity_Sine_float(_Multiply_f0258532eb174f5393420713f84f6c8e_Out_2_Float, _Sine_17bbe1505e754bbd9eedc59d0757132f_Out_1_Float);
float _Multiply_bfdbccbbf3584e1eb7d34b97e3a771c5_Out_2_Float;
Unity_Multiply_float_float(_Add_ed2907c2a73440cc83d0b31366c5c7ae_Out_2_Float, 3, _Multiply_bfdbccbbf3584e1eb7d34b97e3a771c5_Out_2_Float);
float _Sine_775bcfb1287e450094240576942d7a07_Out_1_Float;
Unity_Sine_float(_Multiply_bfdbccbbf3584e1eb7d34b97e3a771c5_Out_2_Float, _Sine_775bcfb1287e450094240576942d7a07_Out_1_Float);
float _Lerp_3cef0baddeb24a408278d7e18640ec45_Out_3_Float;
Unity_Lerp_float(_Sine_17bbe1505e754bbd9eedc59d0757132f_Out_1_Float, _Sine_775bcfb1287e450094240576942d7a07_Out_1_Float, _Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float, _Lerp_3cef0baddeb24a408278d7e18640ec45_Out_3_Float);
float _Property_59edf586db864b7a9b70a1acca2de692_Out_0_Float = _PerBladeWindIntensityVariation;
float _Multiply_13aa0e7d9b29467fa9ca1e4db82d023c_Out_2_Float;
Unity_Multiply_float_float(_Lerp_3cef0baddeb24a408278d7e18640ec45_Out_3_Float, _Property_59edf586db864b7a9b70a1acca2de692_Out_0_Float, _Multiply_13aa0e7d9b29467fa9ca1e4db82d023c_Out_2_Float);
float _Add_5a191ec83e8345689f15b7e3b2da0e21_Out_2_Float;
Unity_Add_float(_Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float, _Multiply_13aa0e7d9b29467fa9ca1e4db82d023c_Out_2_Float, _Add_5a191ec83e8345689f15b7e3b2da0e21_Out_2_Float);
float _Lerp_fb2e17ff05c44b1b8daaa248df6af035_Out_3_Float;
Unity_Lerp_float(0, _Property_f1f58df30464478cb038a178d9e83682_Out_0_Float, _Add_5a191ec83e8345689f15b7e3b2da0e21_Out_2_Float, _Lerp_fb2e17ff05c44b1b8daaa248df6af035_Out_3_Float);
float _Multiply_1565a94cae5148adaa4ad80e978368c6_Out_2_Float;
Unity_Multiply_float_float(_SquareRoot_ec802f46201b45ac867b479ae083b1ee_Out_1_Float, _Lerp_fb2e17ff05c44b1b8daaa248df6af035_Out_3_Float, _Multiply_1565a94cae5148adaa4ad80e978368c6_Out_2_Float);
WindDirection_1 = _Divide_bfbaafc2be014557bf2a163156a11a26_Out_2_Vector2;
WindIntensity_2 = _Multiply_1565a94cae5148adaa4ad80e978368c6_Out_2_Float;
Random_3 = _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3;
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

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_MatrixConstruction_Row_float (float4 M0, float4 M1, float4 M2, float4 M3, out float4x4 Out4x4, out float3x3 Out3x3, out float2x2 Out2x2)
{
Out4x4 = float4x4(M0.x, M0.y, M0.z, M0.w, M1.x, M1.y, M1.z, M1.w, M2.x, M2.y, M2.z, M2.w, M3.x, M3.y, M3.z, M3.w);
Out3x3 = float3x3(M0.x, M0.y, M0.z, M1.x, M1.y, M1.z, M2.x, M2.y, M2.z);
Out2x2 = float2x2(M0.x, M0.y, M1.x, M1.y);
}

void Unity_Multiply_float4x4_float4(float4x4 A, float4 B, out float4 Out)
{
Out = mul(A, B);
}

void Unity_Add_float3(float3 A, float3 B, out float3 Out)
{
    Out = A + B;
}

struct Bindings_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float
{
float3 ObjectSpaceNormal;
float3 ObjectSpaceTangent;
float3 ObjectSpacePosition;
};

void SG_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float(float3 _PositionOS, bool _PositionOS_3016357c5e324f0e825ebc4f84f71f27_IsConnected, float3 _NormalOS, bool _NormalOS_6443e352350b4de9ae048680d0b154e4_IsConnected, float3 _TangentOS, bool _TangentOS_307e55ce70df463b90fe1b65f35443d9_IsConnected, float3 _PivotOffset, float3 _AxisOrientation, float4 _PivotAxis, int _OutputSpace, Bindings_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float IN, out float3 Position_1, out float3 Normal_2, out float3 Tangent_3)
{
float4 _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M0_1_Vector4 = UNITY_MATRIX_I_V[0];
float4 _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M1_2_Vector4 = UNITY_MATRIX_I_V[1];
float4 _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M2_3_Vector4 = UNITY_MATRIX_I_V[2];
float4 _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M3_4_Vector4 = UNITY_MATRIX_I_V[3];
float4 _Property_ecb1ace83c9743d78d86f543dfba0991_Out_0_Vector4 = _PivotAxis;
float4x4 _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4;
float3x3 _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var3x3_5_Matrix3;
float2x2 _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var2x2_6_Matrix2;
Unity_MatrixConstruction_Row_float(_MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M0_1_Vector4, _Property_ecb1ace83c9743d78d86f543dfba0991_Out_0_Vector4, _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M2_3_Vector4, _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M3_4_Vector4, _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4, _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var3x3_5_Matrix3, _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var2x2_6_Matrix2);
float3 _Property_41894a58127942aaae689326334e61fc_Out_0_Vector3 = _PositionOS;
bool _Property_41894a58127942aaae689326334e61fc_Out_0_Vector3_IsConnected = _PositionOS_3016357c5e324f0e825ebc4f84f71f27_IsConnected;
float3 _BranchOnInputConnection_9706ae1834c64f399a8f850ec2dbbb55_Out_3_Vector3 = _Property_41894a58127942aaae689326334e61fc_Out_0_Vector3_IsConnected ? _Property_41894a58127942aaae689326334e61fc_Out_0_Vector3 : IN.ObjectSpacePosition;
float3 _Multiply_cc7f14533a6c433b98a087240efbf8f8_Out_2_Vector3;
Unity_Multiply_float3_float3(_BranchOnInputConnection_9706ae1834c64f399a8f850ec2dbbb55_Out_3_Vector3, float3(length(float3(UNITY_MATRIX_M[0].x, UNITY_MATRIX_M[1].x, UNITY_MATRIX_M[2].x)),
                             length(float3(UNITY_MATRIX_M[0].y, UNITY_MATRIX_M[1].y, UNITY_MATRIX_M[2].y)),
                             length(float3(UNITY_MATRIX_M[0].z, UNITY_MATRIX_M[1].z, UNITY_MATRIX_M[2].z))), _Multiply_cc7f14533a6c433b98a087240efbf8f8_Out_2_Vector3);
float3 _Property_5affae77929448b994beb6b8ffca0b9a_Out_0_Vector3 = _AxisOrientation;
float3 _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3;
Unity_Multiply_float3_float3(_Multiply_cc7f14533a6c433b98a087240efbf8f8_Out_2_Vector3, _Property_5affae77929448b994beb6b8ffca0b9a_Out_0_Vector3, _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3);
float _Split_d13fd31126ee4b94b419613a1463bb24_R_1_Float = _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3[0];
float _Split_d13fd31126ee4b94b419613a1463bb24_G_2_Float = _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3[1];
float _Split_d13fd31126ee4b94b419613a1463bb24_B_3_Float = _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3[2];
float _Split_d13fd31126ee4b94b419613a1463bb24_A_4_Float = 0;
float4 _Combine_3e277c5566fd4af089d839ecf52390f8_RGBA_4_Vector4;
float3 _Combine_3e277c5566fd4af089d839ecf52390f8_RGB_5_Vector3;
float2 _Combine_3e277c5566fd4af089d839ecf52390f8_RG_6_Vector2;
Unity_Combine_float(_Split_d13fd31126ee4b94b419613a1463bb24_R_1_Float, _Split_d13fd31126ee4b94b419613a1463bb24_G_2_Float, _Split_d13fd31126ee4b94b419613a1463bb24_B_3_Float, 0, _Combine_3e277c5566fd4af089d839ecf52390f8_RGBA_4_Vector4, _Combine_3e277c5566fd4af089d839ecf52390f8_RGB_5_Vector3, _Combine_3e277c5566fd4af089d839ecf52390f8_RG_6_Vector2);
float4 _Multiply_b71678c838b541ce80f71613338319bb_Out_2_Vector4;
Unity_Multiply_float4x4_float4(_MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4, _Combine_3e277c5566fd4af089d839ecf52390f8_RGBA_4_Vector4, _Multiply_b71678c838b541ce80f71613338319bb_Out_2_Vector4);
float3 _Swizzle_533fdda21ca44bb783d1af6880283be8_Out_1_Vector3 = _Multiply_b71678c838b541ce80f71613338319bb_Out_2_Vector4.xyz;
float3 _Add_10d54894eefd4263a31339a71dc6a555_Out_2_Vector3;
Unity_Add_float3(_Swizzle_533fdda21ca44bb783d1af6880283be8_Out_1_Vector3, SHADERGRAPH_OBJECT_POSITION, _Add_10d54894eefd4263a31339a71dc6a555_Out_2_Vector3);
float3 _Property_3e2f21cb09ef4a95a3da553bc8c93907_Out_0_Vector3 = _PivotOffset;
float3 _Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3;
Unity_Add_float3(_Add_10d54894eefd4263a31339a71dc6a555_Out_2_Vector3, _Property_3e2f21cb09ef4a95a3da553bc8c93907_Out_0_Vector3, _Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3);
float3 _Transform_c7b91c9bd5a24cbba16a486b2128d2ff_Out_1_Vector3;
{
// Converting Position from AbsoluteWorld to Object via world space
float3 world;
world = GetCameraRelativePositionWS(_Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3.xyz);
_Transform_c7b91c9bd5a24cbba16a486b2128d2ff_Out_1_Vector3 = TransformWorldToObject(world);
}
float3 _OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3;
if (_OutputSpace == 0)
{
_OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3 = _Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3;
}
else if (_OutputSpace == 1)
{
_OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3 = _Transform_c7b91c9bd5a24cbba16a486b2128d2ff_Out_1_Vector3;
}
else
{
_OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3 = _Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3;
}
float3 _Property_6e320129056e479593a9673a6404c2a3_Out_0_Vector3 = _NormalOS;
bool _Property_6e320129056e479593a9673a6404c2a3_Out_0_Vector3_IsConnected = _NormalOS_6443e352350b4de9ae048680d0b154e4_IsConnected;
float3 _BranchOnInputConnection_cdbf96fcdcc94bbc8e16e41d2064eac0_Out_3_Vector3 = _Property_6e320129056e479593a9673a6404c2a3_Out_0_Vector3_IsConnected ? _Property_6e320129056e479593a9673a6404c2a3_Out_0_Vector3 : IN.ObjectSpaceNormal;
float _Split_9df7389f2a034b16b14e80d7ea3cc9eb_R_1_Float = _BranchOnInputConnection_cdbf96fcdcc94bbc8e16e41d2064eac0_Out_3_Vector3[0];
float _Split_9df7389f2a034b16b14e80d7ea3cc9eb_G_2_Float = _BranchOnInputConnection_cdbf96fcdcc94bbc8e16e41d2064eac0_Out_3_Vector3[1];
float _Split_9df7389f2a034b16b14e80d7ea3cc9eb_B_3_Float = _BranchOnInputConnection_cdbf96fcdcc94bbc8e16e41d2064eac0_Out_3_Vector3[2];
float _Split_9df7389f2a034b16b14e80d7ea3cc9eb_A_4_Float = 0;
float4 _Combine_45448fd8d869482ba046251ea2a4986d_RGBA_4_Vector4;
float3 _Combine_45448fd8d869482ba046251ea2a4986d_RGB_5_Vector3;
float2 _Combine_45448fd8d869482ba046251ea2a4986d_RG_6_Vector2;
Unity_Combine_float(_Split_9df7389f2a034b16b14e80d7ea3cc9eb_R_1_Float, _Split_9df7389f2a034b16b14e80d7ea3cc9eb_G_2_Float, _Split_9df7389f2a034b16b14e80d7ea3cc9eb_B_3_Float, 0, _Combine_45448fd8d869482ba046251ea2a4986d_RGBA_4_Vector4, _Combine_45448fd8d869482ba046251ea2a4986d_RGB_5_Vector3, _Combine_45448fd8d869482ba046251ea2a4986d_RG_6_Vector2);
float4 _Multiply_fa8c745148884874b6bda6c5b00b1faf_Out_2_Vector4;
Unity_Multiply_float4x4_float4(_MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4, _Combine_45448fd8d869482ba046251ea2a4986d_RGBA_4_Vector4, _Multiply_fa8c745148884874b6bda6c5b00b1faf_Out_2_Vector4);
float3 _Swizzle_aac6fdf714634855bbb2102e1f03176a_Out_1_Vector3 = _Multiply_fa8c745148884874b6bda6c5b00b1faf_Out_2_Vector4.xyz;
float3 _Transform_ca9dd6096e414ef1aab3fc9c46b8a751_Out_1_Vector3;
{
// Converting Normal from AbsoluteWorld to Object via world space
float3 world;
world = _Swizzle_aac6fdf714634855bbb2102e1f03176a_Out_1_Vector3.xyz;
_Transform_ca9dd6096e414ef1aab3fc9c46b8a751_Out_1_Vector3 = TransformWorldToObjectNormal(world, true);
}
float3 _OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3;
if (_OutputSpace == 0)
{
_OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3 = _Swizzle_aac6fdf714634855bbb2102e1f03176a_Out_1_Vector3;
}
else if (_OutputSpace == 1)
{
_OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3 = _Transform_ca9dd6096e414ef1aab3fc9c46b8a751_Out_1_Vector3;
}
else
{
_OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3 = _Swizzle_aac6fdf714634855bbb2102e1f03176a_Out_1_Vector3;
}
float3 _Property_1caa087de4794f53880c4f3b725272b1_Out_0_Vector3 = _TangentOS;
bool _Property_1caa087de4794f53880c4f3b725272b1_Out_0_Vector3_IsConnected = _TangentOS_307e55ce70df463b90fe1b65f35443d9_IsConnected;
float3 _BranchOnInputConnection_49631555af044120aade11fe1ef46744_Out_3_Vector3 = _Property_1caa087de4794f53880c4f3b725272b1_Out_0_Vector3_IsConnected ? _Property_1caa087de4794f53880c4f3b725272b1_Out_0_Vector3 : IN.ObjectSpaceTangent;
float _Split_38da75d926c34146b97327ecc7d7d0e3_R_1_Float = _BranchOnInputConnection_49631555af044120aade11fe1ef46744_Out_3_Vector3[0];
float _Split_38da75d926c34146b97327ecc7d7d0e3_G_2_Float = _BranchOnInputConnection_49631555af044120aade11fe1ef46744_Out_3_Vector3[1];
float _Split_38da75d926c34146b97327ecc7d7d0e3_B_3_Float = _BranchOnInputConnection_49631555af044120aade11fe1ef46744_Out_3_Vector3[2];
float _Split_38da75d926c34146b97327ecc7d7d0e3_A_4_Float = 0;
float4 _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGBA_4_Vector4;
float3 _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGB_5_Vector3;
float2 _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RG_6_Vector2;
Unity_Combine_float(_Split_38da75d926c34146b97327ecc7d7d0e3_R_1_Float, _Split_38da75d926c34146b97327ecc7d7d0e3_G_2_Float, _Split_38da75d926c34146b97327ecc7d7d0e3_B_3_Float, 0, _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGBA_4_Vector4, _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGB_5_Vector3, _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RG_6_Vector2);
float4 _Multiply_88c2defdee7945aabfad7d073ac15b3c_Out_2_Vector4;
Unity_Multiply_float4x4_float4(_MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4, _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGBA_4_Vector4, _Multiply_88c2defdee7945aabfad7d073ac15b3c_Out_2_Vector4);
float3 _Swizzle_dadec3efd6244574a802fd3e0ab56bb5_Out_1_Vector3 = _Multiply_88c2defdee7945aabfad7d073ac15b3c_Out_2_Vector4.xyz;
float3 _Transform_8906312bacad44698b5e2899041600be_Out_1_Vector3;
{
// Converting Normal from AbsoluteWorld to Object via world space
float3 world;
world = _Swizzle_dadec3efd6244574a802fd3e0ab56bb5_Out_1_Vector3.xyz;
_Transform_8906312bacad44698b5e2899041600be_Out_1_Vector3 = TransformWorldToObjectNormal(world, true);
}
float3 _OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3;
if (_OutputSpace == 0)
{
_OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3 = _Swizzle_dadec3efd6244574a802fd3e0ab56bb5_Out_1_Vector3;
}
else if (_OutputSpace == 1)
{
_OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3 = _Transform_8906312bacad44698b5e2899041600be_Out_1_Vector3;
}
else
{
_OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3 = _Swizzle_dadec3efd6244574a802fd3e0ab56bb5_Out_1_Vector3;
}
Position_1 = _OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3;
Normal_2 = _OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3;
Tangent_3 = _OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3;
}

void Unity_Step_float(float Edge, float In, out float Out)
{
    Out = step(Edge, In);
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
float _Property_dbcc12976b2c4eb4a63c1284e5f1d305_Out_0_Float = _Wind_Speed;
Bindings_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba;
_FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba.TimeParameters = IN.TimeParameters;
float2 _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindDirection_1_Vector2;
float _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindIntensity_2_Float;
float3 _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_Random_3_Vector3;
SG_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float(124, _Property_dbcc12976b2c4eb4a63c1284e5f1d305_Out_0_Float, 0.01, 0.2, 0.1, 0.2, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindDirection_1_Vector2, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindIntensity_2_Float, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_Random_3_Vector3);
float4x4 _Property_e6333f42f10045b8874ca797f7698f1d_Out_0_Matrix4 = _WireframeShaderMaskData1;
float _DynamicMask_50b2c29949db4c9087fc753d984c4250_Out_3_Float;
WireframeShaderDynamicMaskCube_float(IN.WorldSpacePosition, _Property_e6333f42f10045b8874ca797f7698f1d_Out_0_Matrix4, 0, _DynamicMask_50b2c29949db4c9087fc753d984c4250_Out_3_Float);
float4x4 _Property_37070fbe8a4e4576a732a3a352dec45e_Out_0_Matrix4 = _WireframeShaderMaskData2;
float _DynamicMask_0c15310c869f45a5bb095f810944777b_Out_3_Float;
WireframeShaderDynamicMaskSphere_float(IN.WorldSpacePosition, _Property_37070fbe8a4e4576a732a3a352dec45e_Out_0_Matrix4, 0, _DynamicMask_0c15310c869f45a5bb095f810944777b_Out_3_Float);
float _Add_4e24bc1118f94bdb89aeba5ac3067e43_Out_2_Float;
Unity_Add_float(_DynamicMask_50b2c29949db4c9087fc753d984c4250_Out_3_Float, _DynamicMask_0c15310c869f45a5bb095f810944777b_Out_3_Float, _Add_4e24bc1118f94bdb89aeba5ac3067e43_Out_2_Float);
float _Saturate_b1a2ecfe1d1842778d5653a46a7b1782_Out_1_Float;
Unity_Saturate_float(_Add_4e24bc1118f94bdb89aeba5ac3067e43_Out_2_Float, _Saturate_b1a2ecfe1d1842778d5653a46a7b1782_Out_1_Float);
float _OneMinus_153cdd2db72f462c97a7c55eccd49567_Out_1_Float;
Unity_OneMinus_float(_Saturate_b1a2ecfe1d1842778d5653a46a7b1782_Out_1_Float, _OneMinus_153cdd2db72f462c97a7c55eccd49567_Out_1_Float);
float _Multiply_cff561f8195f49188db426fdc084a6ce_Out_2_Float;
Unity_Multiply_float_float(_OneMinus_153cdd2db72f462c97a7c55eccd49567_Out_1_Float, -1, _Multiply_cff561f8195f49188db426fdc084a6ce_Out_2_Float);
float3 _Vector3_2dea481cbff74205a7cee900960a51a9_Out_0_Vector3 = float3(_FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindIntensity_2_Float, _Multiply_cff561f8195f49188db426fdc084a6ce_Out_2_Float, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindIntensity_2_Float);
Bindings_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f;
_BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f.ObjectSpaceNormal = IN.ObjectSpaceNormal;
_BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f.ObjectSpaceTangent = IN.ObjectSpaceTangent;
_BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f.ObjectSpacePosition = IN.ObjectSpacePosition;
float3 _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Position_1_Vector3;
float3 _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Normal_2_Vector3;
float3 _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Tangent_3_Vector3;
SG_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float(float3 (0, 0, 0), false, float3 (0, 0, 0), false, float3 (0, 0, 0), false, _Vector3_2dea481cbff74205a7cee900960a51a9_Out_0_Vector3, float3 (-1, 1, 1), float4 (0, 1, 0, 0), 1, _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f, _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Position_1_Vector3, _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Normal_2_Vector3, _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Tangent_3_Vector3);
description.Position = _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Position_1_Vector3;
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
float4x4 _Property_768bac82b0684cd0a21ed8a814d35a50_Out_0_Matrix4 = _WireframeShaderMaskData1;
float _DynamicMask_d8cbb946b52f4b01a4d3fd3bc3ea9de1_Out_3_Float;
WireframeShaderDynamicMaskCube_float(IN.WorldSpacePosition, _Property_768bac82b0684cd0a21ed8a814d35a50_Out_0_Matrix4, 0, _DynamicMask_d8cbb946b52f4b01a4d3fd3bc3ea9de1_Out_3_Float);
float4x4 _Property_39e6a912ee0647ed8335e7ab63cd4bed_Out_0_Matrix4 = _WireframeShaderMaskData2;
float _DynamicMask_e413c723ed49470ba4eca3bcf6362548_Out_3_Float;
WireframeShaderDynamicMaskSphere_float(IN.WorldSpacePosition, _Property_39e6a912ee0647ed8335e7ab63cd4bed_Out_0_Matrix4, 0, _DynamicMask_e413c723ed49470ba4eca3bcf6362548_Out_3_Float);
float _Add_c3b10d55feaf4b9baefa4948a8eaed75_Out_2_Float;
Unity_Add_float(_DynamicMask_d8cbb946b52f4b01a4d3fd3bc3ea9de1_Out_3_Float, _DynamicMask_e413c723ed49470ba4eca3bcf6362548_Out_3_Float, _Add_c3b10d55feaf4b9baefa4948a8eaed75_Out_2_Float);
float _Saturate_62dc9cf6a37b4fab9407e114176db70f_Out_1_Float;
Unity_Saturate_float(_Add_c3b10d55feaf4b9baefa4948a8eaed75_Out_2_Float, _Saturate_62dc9cf6a37b4fab9407e114176db70f_Out_1_Float);
float _Step_0f4fbf717a47479eaa1a77f0d38201d7_Out_2_Float;
Unity_Step_float(0.05, _Saturate_62dc9cf6a37b4fab9407e114176db70f_Out_1_Float, _Step_0f4fbf717a47479eaa1a77f0d38201d7_Out_2_Float);
surface.Alpha = _Step_0f4fbf717a47479eaa1a77f0d38201d7_Out_2_Float;
surface.AlphaClipThreshold = 0.5;
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
    output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
    output.TimeParameters =                             _TimeParameters.xyz;

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
#define VARYINGS_NEED_POSITION_WS
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_2D
#define _ALPHATEST_ON 1
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
 float3 positionWS;
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
 float4 Color;
};
struct SurfaceDescriptionInputs
{
 float3 WorldSpacePosition;
 float4 Color;
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
 float3 WorldSpacePosition;
 float3 TimeParameters;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
 float4 Color : INTERP0;
 float3 positionWS : INTERP1;
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
output.Color.xyzw = input.Color;
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
output.Color = input.Color.xyzw;
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
float _Wireframe_Thickness;
float _Wireframe_Anti_aliasing;
float4 _Blade_Color_2;
float4 _Blade_Color_1;
float _Metallic;
float _Smoothness;
float _Wind_Speed;
CBUFFER_END


// Object and Global properties
float4x4 _WireframeShaderMaskData1;
float4x4 _WireframeShaderMaskData2;

// Graph Includes
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"

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

void UnityGetInstanceID_float(out float Out)
{
#if UNITY_ANY_INSTANCING_ENABLED
    Out = unity_InstanceID;
#else
    Out = 0;
#endif
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Fraction_float(float In, out float Out)
{
    Out = frac(In);
}

void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
{
    Out = lerp(A, B, T);
}

void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
{
Out = A * B;
}

void Unity_Fraction_float3(float3 In, out float3 Out)
{
    Out = frac(In);
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Multiply_float_float(float A, float B, out float Out)
{
Out = A * B;
}

void Unity_Sine_float(float In, out float Out)
{
    Out = sin(In);
}

void Unity_DegreesToRadians_float(float In, out float Out)
{
    Out = radians(In);
}

void Unity_Rotate_Radians_float(float2 UV, float2 Center, float Rotation, out float2 Out)
{
    //rotation matrix
    UV -= Center;
    float s = sin(Rotation);
    float c = cos(Rotation);

    //center rotation matrix
    float2x2 rMatrix = float2x2(c, -s, s, c);
    rMatrix *= 0.5;
    rMatrix += 0.5;
    rMatrix = rMatrix*2 - 1;

    //multiply the UVs by the rotation matrix
    UV.xy = mul(UV.xy, rMatrix);
    UV += Center;

    Out = UV;
}

void Unity_Cosine_float(float In, out float Out)
{
    Out = cos(In);
}

void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
{
    RGBA = float4(R, G, B, A);
    RGB = float3(R, G, B);
    RG = float2(R, G);
}

void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
{
Out = A * B;
}

void Unity_DotProduct_float2(float2 A, float2 B, out float Out)
{
    Out = dot(A, B);
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
    Out = A + B;
}

void Unity_Negate_float(float In, out float Out)
{
    Out = -1 * In;
}

float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
{
float x; Hash_Tchou_2_1_float(p, x);
return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
{
float2 p = UV * Scale.xy;
float2 ip = floor(p);
float2 fp = frac(p);
float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
    Out = smoothstep(Edge1, Edge2, In);
}

void Unity_Saturate_float(float In, out float Out)
{
    Out = saturate(In);
}

void Unity_Lerp_float2(float2 A, float2 B, float2 T, out float2 Out)
{
    Out = lerp(A, B, T);
}

void Unity_SquareRoot_float(float In, out float Out)
{
    Out = sqrt(In);
}

void Unity_Maximum_float(float A, float B, out float Out)
{
    Out = max(A, B);
}

void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
{
    Out = A / B;
}

void Unity_Lerp_float(float A, float B, float T, out float Out)
{
    Out = lerp(A, B, T);
}

struct Bindings_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float
{
float3 TimeParameters;
};

void SG_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float(float _WindDirection, float _WindSpeed, float _WindDirectionVariation, float _PerBladeRandomTimeOffset, float _PerBladeWindIntensityVariation, float _WindIntensity, Bindings_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float IN, out float2 WindDirection_1, out float WindIntensity_2, out float3 Random_3)
{
float2 _Vector2_42921bc8d43346a4bbad7aa650d15962_Out_0_Vector2 = float2(1, 0);
float3 _Multiply_b6ed4cc094134c21943e217e6e271dae_Out_2_Vector3;
Unity_Multiply_float3_float3(SHADERGRAPH_OBJECT_POSITION, float3(37, 190, 29), _Multiply_b6ed4cc094134c21943e217e6e271dae_Out_2_Vector3);
float3 _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3;
Unity_Fraction_float3(_Multiply_b6ed4cc094134c21943e217e6e271dae_Out_2_Vector3, _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3);
float _Split_3967427c51c24bb79cef645976364a55_R_1_Float = _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3[0];
float _Split_3967427c51c24bb79cef645976364a55_G_2_Float = _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3[1];
float _Split_3967427c51c24bb79cef645976364a55_B_3_Float = _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3[2];
float _Split_3967427c51c24bb79cef645976364a55_A_4_Float = 0;
float _Add_ffd28ed6ff854810bd439fbdfc4b2cc2_Out_2_Float;
Unity_Add_float(IN.TimeParameters.x, _Split_3967427c51c24bb79cef645976364a55_B_3_Float, _Add_ffd28ed6ff854810bd439fbdfc4b2cc2_Out_2_Float);
float _Multiply_1185303c6c5d481190d5375ac379cab8_Out_2_Float;
Unity_Multiply_float_float(_Add_ffd28ed6ff854810bd439fbdfc4b2cc2_Out_2_Float, 3, _Multiply_1185303c6c5d481190d5375ac379cab8_Out_2_Float);
float _Sine_c919089f2f34401face2dd9897c9725c_Out_1_Float;
Unity_Sine_float(_Multiply_1185303c6c5d481190d5375ac379cab8_Out_2_Float, _Sine_c919089f2f34401face2dd9897c9725c_Out_1_Float);
float _Property_40290747561641a1bdf5517e6a93430d_Out_0_Float = _WindDirectionVariation;
float _DegreesToRadians_a7fe82a177484cd0af99b4027bc4e3bc_Out_1_Float;
Unity_DegreesToRadians_float(_Property_40290747561641a1bdf5517e6a93430d_Out_0_Float, _DegreesToRadians_a7fe82a177484cd0af99b4027bc4e3bc_Out_1_Float);
float _Multiply_c6dbf243e66746b490b03900b2b27467_Out_2_Float;
Unity_Multiply_float_float(_Sine_c919089f2f34401face2dd9897c9725c_Out_1_Float, _DegreesToRadians_a7fe82a177484cd0af99b4027bc4e3bc_Out_1_Float, _Multiply_c6dbf243e66746b490b03900b2b27467_Out_2_Float);
float2 _Rotate_cf73d535c5fb437aa68912dc0e09ba2f_Out_3_Vector2;
Unity_Rotate_Radians_float(_Vector2_42921bc8d43346a4bbad7aa650d15962_Out_0_Vector2, float2 (0, 0), _Multiply_c6dbf243e66746b490b03900b2b27467_Out_2_Float, _Rotate_cf73d535c5fb437aa68912dc0e09ba2f_Out_3_Vector2);
float _Property_df02aaa16377442d91f0c6be7d036d51_Out_0_Float = _WindDirection;
float _DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float;
Unity_DegreesToRadians_float(_Property_df02aaa16377442d91f0c6be7d036d51_Out_0_Float, _DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float);
float _Add_b051e3fa11c048dd978791daff07720d_Out_2_Float;
Unity_Add_float(_Multiply_c6dbf243e66746b490b03900b2b27467_Out_2_Float, _DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float, _Add_b051e3fa11c048dd978791daff07720d_Out_2_Float);
float _Cosine_0847069386bc4c12a90e1fe3eb1eee73_Out_1_Float;
Unity_Cosine_float(_Add_b051e3fa11c048dd978791daff07720d_Out_2_Float, _Cosine_0847069386bc4c12a90e1fe3eb1eee73_Out_1_Float);
float _Sine_379c87a4cd3c419293869dee73c52de0_Out_1_Float;
Unity_Sine_float(_Add_b051e3fa11c048dd978791daff07720d_Out_2_Float, _Sine_379c87a4cd3c419293869dee73c52de0_Out_1_Float);
float4 _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RGBA_4_Vector4;
float3 _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RGB_5_Vector3;
float2 _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RG_6_Vector2;
Unity_Combine_float(_Cosine_0847069386bc4c12a90e1fe3eb1eee73_Out_1_Float, _Sine_379c87a4cd3c419293869dee73c52de0_Out_1_Float, 0, 0, _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RGBA_4_Vector4, _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RGB_5_Vector3, _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RG_6_Vector2);
float2 _Swizzle_db678fc97ec448fda50408084410c787_Out_1_Vector2 = SHADERGRAPH_OBJECT_POSITION.xz;
float2 _Multiply_5833218c1a7c4d9586d5e8c69ddaabac_Out_2_Vector2;
Unity_Multiply_float2_float2(_Swizzle_db678fc97ec448fda50408084410c787_Out_1_Vector2, float2(0.5, 0.5), _Multiply_5833218c1a7c4d9586d5e8c69ddaabac_Out_2_Vector2);
float _Cosine_3388e8245f6647ca98f5aa9339130c65_Out_1_Float;
Unity_Cosine_float(_DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float, _Cosine_3388e8245f6647ca98f5aa9339130c65_Out_1_Float);
float _Sine_0b39f9f73b2c4016a046ad8da4b84c11_Out_1_Float;
Unity_Sine_float(_DegreesToRadians_8b5896a5d3ec42f79e06ca08e89a2acb_Out_1_Float, _Sine_0b39f9f73b2c4016a046ad8da4b84c11_Out_1_Float);
float4 _Combine_7f78efe98e4641c1981d47da9bbbe70f_RGBA_4_Vector4;
float3 _Combine_7f78efe98e4641c1981d47da9bbbe70f_RGB_5_Vector3;
float2 _Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2;
Unity_Combine_float(_Cosine_3388e8245f6647ca98f5aa9339130c65_Out_1_Float, _Sine_0b39f9f73b2c4016a046ad8da4b84c11_Out_1_Float, 0, 0, _Combine_7f78efe98e4641c1981d47da9bbbe70f_RGBA_4_Vector4, _Combine_7f78efe98e4641c1981d47da9bbbe70f_RGB_5_Vector3, _Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2);
float _DotProduct_27327ffeb11d404c96d6820c42272ca8_Out_2_Float;
Unity_DotProduct_float2(_Multiply_5833218c1a7c4d9586d5e8c69ddaabac_Out_2_Vector2, _Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2, _DotProduct_27327ffeb11d404c96d6820c42272ca8_Out_2_Float);
float _Multiply_8dc73d49a3b547a19bf5c0d8a4a09920_Out_2_Float;
Unity_Multiply_float_float(_DotProduct_27327ffeb11d404c96d6820c42272ca8_Out_2_Float, 0.7, _Multiply_8dc73d49a3b547a19bf5c0d8a4a09920_Out_2_Float);
float2 _Multiply_c8e01038fa74488a86a9759343a555f5_Out_2_Vector2;
Unity_Multiply_float2_float2((_Multiply_8dc73d49a3b547a19bf5c0d8a4a09920_Out_2_Float.xx), _Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2, _Multiply_c8e01038fa74488a86a9759343a555f5_Out_2_Vector2);
float _Multiply_69e2c5b6e72c4faf8d83ead16a5c0cd6_Out_2_Float;
Unity_Multiply_float_float(_Cosine_3388e8245f6647ca98f5aa9339130c65_Out_1_Float, -1.5708, _Multiply_69e2c5b6e72c4faf8d83ead16a5c0cd6_Out_2_Float);
float4 _Combine_2f7388d585a24290a659f20482d78d94_RGBA_4_Vector4;
float3 _Combine_2f7388d585a24290a659f20482d78d94_RGB_5_Vector3;
float2 _Combine_2f7388d585a24290a659f20482d78d94_RG_6_Vector2;
Unity_Combine_float(_Sine_0b39f9f73b2c4016a046ad8da4b84c11_Out_1_Float, _Multiply_69e2c5b6e72c4faf8d83ead16a5c0cd6_Out_2_Float, 0, 0, _Combine_2f7388d585a24290a659f20482d78d94_RGBA_4_Vector4, _Combine_2f7388d585a24290a659f20482d78d94_RGB_5_Vector3, _Combine_2f7388d585a24290a659f20482d78d94_RG_6_Vector2);
float _DotProduct_e3247c7835f0404893730bc5dcd240a0_Out_2_Float;
Unity_DotProduct_float2(_Multiply_5833218c1a7c4d9586d5e8c69ddaabac_Out_2_Vector2, _Combine_2f7388d585a24290a659f20482d78d94_RG_6_Vector2, _DotProduct_e3247c7835f0404893730bc5dcd240a0_Out_2_Float);
float2 _Multiply_ed7373e7bd6347f89e44dacc83ccf8c1_Out_2_Vector2;
Unity_Multiply_float2_float2((_DotProduct_e3247c7835f0404893730bc5dcd240a0_Out_2_Float.xx), _Combine_2f7388d585a24290a659f20482d78d94_RG_6_Vector2, _Multiply_ed7373e7bd6347f89e44dacc83ccf8c1_Out_2_Vector2);
float2 _Add_f950bfd74ec2464b89d972d5f43aa5b7_Out_2_Vector2;
Unity_Add_float2(_Multiply_c8e01038fa74488a86a9759343a555f5_Out_2_Vector2, _Multiply_ed7373e7bd6347f89e44dacc83ccf8c1_Out_2_Vector2, _Add_f950bfd74ec2464b89d972d5f43aa5b7_Out_2_Vector2);
float _Property_8c38f0ae55594c8787ad0a52af13731b_Out_0_Float = _WindSpeed;
float _Negate_47564bc9ce9645a5916ebc05fb9d63df_Out_1_Float;
Unity_Negate_float(_Property_8c38f0ae55594c8787ad0a52af13731b_Out_0_Float, _Negate_47564bc9ce9645a5916ebc05fb9d63df_Out_1_Float);
float _Multiply_e311852a737c422594c328d00e16414c_Out_2_Float;
Unity_Multiply_float_float(IN.TimeParameters.x, _Negate_47564bc9ce9645a5916ebc05fb9d63df_Out_1_Float, _Multiply_e311852a737c422594c328d00e16414c_Out_2_Float);
float _Property_347528760e804b2ab165732f176f3e97_Out_0_Float = _PerBladeRandomTimeOffset;
float _Multiply_0657e69a5c9b4cb783a0d4021b58a9b1_Out_2_Float;
Unity_Multiply_float_float(_Split_3967427c51c24bb79cef645976364a55_R_1_Float, _Property_347528760e804b2ab165732f176f3e97_Out_0_Float, _Multiply_0657e69a5c9b4cb783a0d4021b58a9b1_Out_2_Float);
float _Add_8e1a8d342102407f97ee7c7b88271e7d_Out_2_Float;
Unity_Add_float(_Multiply_e311852a737c422594c328d00e16414c_Out_2_Float, _Multiply_0657e69a5c9b4cb783a0d4021b58a9b1_Out_2_Float, _Add_8e1a8d342102407f97ee7c7b88271e7d_Out_2_Float);
float2 _Multiply_e39ee6e978424683b1858114ff959110_Out_2_Vector2;
Unity_Multiply_float2_float2(_Combine_7f78efe98e4641c1981d47da9bbbe70f_RG_6_Vector2, (_Add_8e1a8d342102407f97ee7c7b88271e7d_Out_2_Float.xx), _Multiply_e39ee6e978424683b1858114ff959110_Out_2_Vector2);
float2 _Add_302cec4f55d64a65bf1160e9d23f9b71_Out_2_Vector2;
Unity_Add_float2(_Add_f950bfd74ec2464b89d972d5f43aa5b7_Out_2_Vector2, _Multiply_e39ee6e978424683b1858114ff959110_Out_2_Vector2, _Add_302cec4f55d64a65bf1160e9d23f9b71_Out_2_Vector2);
float _GradientNoise_f0d0f1452f814e03824cb2ceb16d6ad2_Out_2_Float;
Unity_GradientNoise_Deterministic_float(_Add_302cec4f55d64a65bf1160e9d23f9b71_Out_2_Vector2, 0.8, _GradientNoise_f0d0f1452f814e03824cb2ceb16d6ad2_Out_2_Float);
float _Smoothstep_4ca6b3a56ada4447bcfcabe8e1a6ee2b_Out_3_Float;
Unity_Smoothstep_float(-0.5, 1.5, _GradientNoise_f0d0f1452f814e03824cb2ceb16d6ad2_Out_2_Float, _Smoothstep_4ca6b3a56ada4447bcfcabe8e1a6ee2b_Out_3_Float);
float _Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float;
Unity_Saturate_float(_Smoothstep_4ca6b3a56ada4447bcfcabe8e1a6ee2b_Out_3_Float, _Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float);
float2 _Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2;
Unity_Lerp_float2(_Rotate_cf73d535c5fb437aa68912dc0e09ba2f_Out_3_Vector2, _Combine_7e7757b08a7d4a65bb459dfebea0dc89_RG_6_Vector2, (_Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float.xx), _Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2);
float _DotProduct_b6d4ff1e79f54760a1f13bc5172c426b_Out_2_Float;
Unity_DotProduct_float2(_Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2, _Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2, _DotProduct_b6d4ff1e79f54760a1f13bc5172c426b_Out_2_Float);
float _SquareRoot_ec802f46201b45ac867b479ae083b1ee_Out_1_Float;
Unity_SquareRoot_float(_DotProduct_b6d4ff1e79f54760a1f13bc5172c426b_Out_2_Float, _SquareRoot_ec802f46201b45ac867b479ae083b1ee_Out_1_Float);
float _Maximum_56d7bd23f19a4866b35324380205c891_Out_2_Float;
Unity_Maximum_float(_SquareRoot_ec802f46201b45ac867b479ae083b1ee_Out_1_Float, 1E-05, _Maximum_56d7bd23f19a4866b35324380205c891_Out_2_Float);
float2 _Divide_bfbaafc2be014557bf2a163156a11a26_Out_2_Vector2;
Unity_Divide_float2(_Lerp_78bc3e08c12647f7b046d6804b22aa40_Out_3_Vector2, (_Maximum_56d7bd23f19a4866b35324380205c891_Out_2_Float.xx), _Divide_bfbaafc2be014557bf2a163156a11a26_Out_2_Vector2);
float _Property_f1f58df30464478cb038a178d9e83682_Out_0_Float = _WindIntensity;
float _Add_ed2907c2a73440cc83d0b31366c5c7ae_Out_2_Float;
Unity_Add_float(IN.TimeParameters.x, _Split_3967427c51c24bb79cef645976364a55_B_3_Float, _Add_ed2907c2a73440cc83d0b31366c5c7ae_Out_2_Float);
float _Multiply_f0258532eb174f5393420713f84f6c8e_Out_2_Float;
Unity_Multiply_float_float(_Add_ed2907c2a73440cc83d0b31366c5c7ae_Out_2_Float, 2, _Multiply_f0258532eb174f5393420713f84f6c8e_Out_2_Float);
float _Sine_17bbe1505e754bbd9eedc59d0757132f_Out_1_Float;
Unity_Sine_float(_Multiply_f0258532eb174f5393420713f84f6c8e_Out_2_Float, _Sine_17bbe1505e754bbd9eedc59d0757132f_Out_1_Float);
float _Multiply_bfdbccbbf3584e1eb7d34b97e3a771c5_Out_2_Float;
Unity_Multiply_float_float(_Add_ed2907c2a73440cc83d0b31366c5c7ae_Out_2_Float, 3, _Multiply_bfdbccbbf3584e1eb7d34b97e3a771c5_Out_2_Float);
float _Sine_775bcfb1287e450094240576942d7a07_Out_1_Float;
Unity_Sine_float(_Multiply_bfdbccbbf3584e1eb7d34b97e3a771c5_Out_2_Float, _Sine_775bcfb1287e450094240576942d7a07_Out_1_Float);
float _Lerp_3cef0baddeb24a408278d7e18640ec45_Out_3_Float;
Unity_Lerp_float(_Sine_17bbe1505e754bbd9eedc59d0757132f_Out_1_Float, _Sine_775bcfb1287e450094240576942d7a07_Out_1_Float, _Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float, _Lerp_3cef0baddeb24a408278d7e18640ec45_Out_3_Float);
float _Property_59edf586db864b7a9b70a1acca2de692_Out_0_Float = _PerBladeWindIntensityVariation;
float _Multiply_13aa0e7d9b29467fa9ca1e4db82d023c_Out_2_Float;
Unity_Multiply_float_float(_Lerp_3cef0baddeb24a408278d7e18640ec45_Out_3_Float, _Property_59edf586db864b7a9b70a1acca2de692_Out_0_Float, _Multiply_13aa0e7d9b29467fa9ca1e4db82d023c_Out_2_Float);
float _Add_5a191ec83e8345689f15b7e3b2da0e21_Out_2_Float;
Unity_Add_float(_Saturate_1db1da403ce948588029d33771e16e99_Out_1_Float, _Multiply_13aa0e7d9b29467fa9ca1e4db82d023c_Out_2_Float, _Add_5a191ec83e8345689f15b7e3b2da0e21_Out_2_Float);
float _Lerp_fb2e17ff05c44b1b8daaa248df6af035_Out_3_Float;
Unity_Lerp_float(0, _Property_f1f58df30464478cb038a178d9e83682_Out_0_Float, _Add_5a191ec83e8345689f15b7e3b2da0e21_Out_2_Float, _Lerp_fb2e17ff05c44b1b8daaa248df6af035_Out_3_Float);
float _Multiply_1565a94cae5148adaa4ad80e978368c6_Out_2_Float;
Unity_Multiply_float_float(_SquareRoot_ec802f46201b45ac867b479ae083b1ee_Out_1_Float, _Lerp_fb2e17ff05c44b1b8daaa248df6af035_Out_3_Float, _Multiply_1565a94cae5148adaa4ad80e978368c6_Out_2_Float);
WindDirection_1 = _Divide_bfbaafc2be014557bf2a163156a11a26_Out_2_Vector2;
WindIntensity_2 = _Multiply_1565a94cae5148adaa4ad80e978368c6_Out_2_Float;
Random_3 = _Fraction_d142aa84f2a948cf89ebdef4bc4171f9_Out_1_Vector3;
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

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_MatrixConstruction_Row_float (float4 M0, float4 M1, float4 M2, float4 M3, out float4x4 Out4x4, out float3x3 Out3x3, out float2x2 Out2x2)
{
Out4x4 = float4x4(M0.x, M0.y, M0.z, M0.w, M1.x, M1.y, M1.z, M1.w, M2.x, M2.y, M2.z, M2.w, M3.x, M3.y, M3.z, M3.w);
Out3x3 = float3x3(M0.x, M0.y, M0.z, M1.x, M1.y, M1.z, M2.x, M2.y, M2.z);
Out2x2 = float2x2(M0.x, M0.y, M1.x, M1.y);
}

void Unity_Multiply_float4x4_float4(float4x4 A, float4 B, out float4 Out)
{
Out = mul(A, B);
}

void Unity_Add_float3(float3 A, float3 B, out float3 Out)
{
    Out = A + B;
}

struct Bindings_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float
{
float3 ObjectSpaceNormal;
float3 ObjectSpaceTangent;
float3 ObjectSpacePosition;
};

void SG_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float(float3 _PositionOS, bool _PositionOS_3016357c5e324f0e825ebc4f84f71f27_IsConnected, float3 _NormalOS, bool _NormalOS_6443e352350b4de9ae048680d0b154e4_IsConnected, float3 _TangentOS, bool _TangentOS_307e55ce70df463b90fe1b65f35443d9_IsConnected, float3 _PivotOffset, float3 _AxisOrientation, float4 _PivotAxis, int _OutputSpace, Bindings_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float IN, out float3 Position_1, out float3 Normal_2, out float3 Tangent_3)
{
float4 _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M0_1_Vector4 = UNITY_MATRIX_I_V[0];
float4 _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M1_2_Vector4 = UNITY_MATRIX_I_V[1];
float4 _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M2_3_Vector4 = UNITY_MATRIX_I_V[2];
float4 _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M3_4_Vector4 = UNITY_MATRIX_I_V[3];
float4 _Property_ecb1ace83c9743d78d86f543dfba0991_Out_0_Vector4 = _PivotAxis;
float4x4 _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4;
float3x3 _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var3x3_5_Matrix3;
float2x2 _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var2x2_6_Matrix2;
Unity_MatrixConstruction_Row_float(_MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M0_1_Vector4, _Property_ecb1ace83c9743d78d86f543dfba0991_Out_0_Vector4, _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M2_3_Vector4, _MatrixSplit_80f543b0e670487aa23a7c6c3ef6857f_M3_4_Vector4, _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4, _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var3x3_5_Matrix3, _MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var2x2_6_Matrix2);
float3 _Property_41894a58127942aaae689326334e61fc_Out_0_Vector3 = _PositionOS;
bool _Property_41894a58127942aaae689326334e61fc_Out_0_Vector3_IsConnected = _PositionOS_3016357c5e324f0e825ebc4f84f71f27_IsConnected;
float3 _BranchOnInputConnection_9706ae1834c64f399a8f850ec2dbbb55_Out_3_Vector3 = _Property_41894a58127942aaae689326334e61fc_Out_0_Vector3_IsConnected ? _Property_41894a58127942aaae689326334e61fc_Out_0_Vector3 : IN.ObjectSpacePosition;
float3 _Multiply_cc7f14533a6c433b98a087240efbf8f8_Out_2_Vector3;
Unity_Multiply_float3_float3(_BranchOnInputConnection_9706ae1834c64f399a8f850ec2dbbb55_Out_3_Vector3, float3(length(float3(UNITY_MATRIX_M[0].x, UNITY_MATRIX_M[1].x, UNITY_MATRIX_M[2].x)),
                             length(float3(UNITY_MATRIX_M[0].y, UNITY_MATRIX_M[1].y, UNITY_MATRIX_M[2].y)),
                             length(float3(UNITY_MATRIX_M[0].z, UNITY_MATRIX_M[1].z, UNITY_MATRIX_M[2].z))), _Multiply_cc7f14533a6c433b98a087240efbf8f8_Out_2_Vector3);
float3 _Property_5affae77929448b994beb6b8ffca0b9a_Out_0_Vector3 = _AxisOrientation;
float3 _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3;
Unity_Multiply_float3_float3(_Multiply_cc7f14533a6c433b98a087240efbf8f8_Out_2_Vector3, _Property_5affae77929448b994beb6b8ffca0b9a_Out_0_Vector3, _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3);
float _Split_d13fd31126ee4b94b419613a1463bb24_R_1_Float = _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3[0];
float _Split_d13fd31126ee4b94b419613a1463bb24_G_2_Float = _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3[1];
float _Split_d13fd31126ee4b94b419613a1463bb24_B_3_Float = _Multiply_8b1c9b57b0264ef4a5b571b1043e9b0f_Out_2_Vector3[2];
float _Split_d13fd31126ee4b94b419613a1463bb24_A_4_Float = 0;
float4 _Combine_3e277c5566fd4af089d839ecf52390f8_RGBA_4_Vector4;
float3 _Combine_3e277c5566fd4af089d839ecf52390f8_RGB_5_Vector3;
float2 _Combine_3e277c5566fd4af089d839ecf52390f8_RG_6_Vector2;
Unity_Combine_float(_Split_d13fd31126ee4b94b419613a1463bb24_R_1_Float, _Split_d13fd31126ee4b94b419613a1463bb24_G_2_Float, _Split_d13fd31126ee4b94b419613a1463bb24_B_3_Float, 0, _Combine_3e277c5566fd4af089d839ecf52390f8_RGBA_4_Vector4, _Combine_3e277c5566fd4af089d839ecf52390f8_RGB_5_Vector3, _Combine_3e277c5566fd4af089d839ecf52390f8_RG_6_Vector2);
float4 _Multiply_b71678c838b541ce80f71613338319bb_Out_2_Vector4;
Unity_Multiply_float4x4_float4(_MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4, _Combine_3e277c5566fd4af089d839ecf52390f8_RGBA_4_Vector4, _Multiply_b71678c838b541ce80f71613338319bb_Out_2_Vector4);
float3 _Swizzle_533fdda21ca44bb783d1af6880283be8_Out_1_Vector3 = _Multiply_b71678c838b541ce80f71613338319bb_Out_2_Vector4.xyz;
float3 _Add_10d54894eefd4263a31339a71dc6a555_Out_2_Vector3;
Unity_Add_float3(_Swizzle_533fdda21ca44bb783d1af6880283be8_Out_1_Vector3, SHADERGRAPH_OBJECT_POSITION, _Add_10d54894eefd4263a31339a71dc6a555_Out_2_Vector3);
float3 _Property_3e2f21cb09ef4a95a3da553bc8c93907_Out_0_Vector3 = _PivotOffset;
float3 _Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3;
Unity_Add_float3(_Add_10d54894eefd4263a31339a71dc6a555_Out_2_Vector3, _Property_3e2f21cb09ef4a95a3da553bc8c93907_Out_0_Vector3, _Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3);
float3 _Transform_c7b91c9bd5a24cbba16a486b2128d2ff_Out_1_Vector3;
{
// Converting Position from AbsoluteWorld to Object via world space
float3 world;
world = GetCameraRelativePositionWS(_Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3.xyz);
_Transform_c7b91c9bd5a24cbba16a486b2128d2ff_Out_1_Vector3 = TransformWorldToObject(world);
}
float3 _OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3;
if (_OutputSpace == 0)
{
_OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3 = _Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3;
}
else if (_OutputSpace == 1)
{
_OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3 = _Transform_c7b91c9bd5a24cbba16a486b2128d2ff_Out_1_Vector3;
}
else
{
_OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3 = _Add_229eb688b51a409a94ed1985a3d55c9c_Out_2_Vector3;
}
float3 _Property_6e320129056e479593a9673a6404c2a3_Out_0_Vector3 = _NormalOS;
bool _Property_6e320129056e479593a9673a6404c2a3_Out_0_Vector3_IsConnected = _NormalOS_6443e352350b4de9ae048680d0b154e4_IsConnected;
float3 _BranchOnInputConnection_cdbf96fcdcc94bbc8e16e41d2064eac0_Out_3_Vector3 = _Property_6e320129056e479593a9673a6404c2a3_Out_0_Vector3_IsConnected ? _Property_6e320129056e479593a9673a6404c2a3_Out_0_Vector3 : IN.ObjectSpaceNormal;
float _Split_9df7389f2a034b16b14e80d7ea3cc9eb_R_1_Float = _BranchOnInputConnection_cdbf96fcdcc94bbc8e16e41d2064eac0_Out_3_Vector3[0];
float _Split_9df7389f2a034b16b14e80d7ea3cc9eb_G_2_Float = _BranchOnInputConnection_cdbf96fcdcc94bbc8e16e41d2064eac0_Out_3_Vector3[1];
float _Split_9df7389f2a034b16b14e80d7ea3cc9eb_B_3_Float = _BranchOnInputConnection_cdbf96fcdcc94bbc8e16e41d2064eac0_Out_3_Vector3[2];
float _Split_9df7389f2a034b16b14e80d7ea3cc9eb_A_4_Float = 0;
float4 _Combine_45448fd8d869482ba046251ea2a4986d_RGBA_4_Vector4;
float3 _Combine_45448fd8d869482ba046251ea2a4986d_RGB_5_Vector3;
float2 _Combine_45448fd8d869482ba046251ea2a4986d_RG_6_Vector2;
Unity_Combine_float(_Split_9df7389f2a034b16b14e80d7ea3cc9eb_R_1_Float, _Split_9df7389f2a034b16b14e80d7ea3cc9eb_G_2_Float, _Split_9df7389f2a034b16b14e80d7ea3cc9eb_B_3_Float, 0, _Combine_45448fd8d869482ba046251ea2a4986d_RGBA_4_Vector4, _Combine_45448fd8d869482ba046251ea2a4986d_RGB_5_Vector3, _Combine_45448fd8d869482ba046251ea2a4986d_RG_6_Vector2);
float4 _Multiply_fa8c745148884874b6bda6c5b00b1faf_Out_2_Vector4;
Unity_Multiply_float4x4_float4(_MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4, _Combine_45448fd8d869482ba046251ea2a4986d_RGBA_4_Vector4, _Multiply_fa8c745148884874b6bda6c5b00b1faf_Out_2_Vector4);
float3 _Swizzle_aac6fdf714634855bbb2102e1f03176a_Out_1_Vector3 = _Multiply_fa8c745148884874b6bda6c5b00b1faf_Out_2_Vector4.xyz;
float3 _Transform_ca9dd6096e414ef1aab3fc9c46b8a751_Out_1_Vector3;
{
// Converting Normal from AbsoluteWorld to Object via world space
float3 world;
world = _Swizzle_aac6fdf714634855bbb2102e1f03176a_Out_1_Vector3.xyz;
_Transform_ca9dd6096e414ef1aab3fc9c46b8a751_Out_1_Vector3 = TransformWorldToObjectNormal(world, true);
}
float3 _OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3;
if (_OutputSpace == 0)
{
_OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3 = _Swizzle_aac6fdf714634855bbb2102e1f03176a_Out_1_Vector3;
}
else if (_OutputSpace == 1)
{
_OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3 = _Transform_ca9dd6096e414ef1aab3fc9c46b8a751_Out_1_Vector3;
}
else
{
_OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3 = _Swizzle_aac6fdf714634855bbb2102e1f03176a_Out_1_Vector3;
}
float3 _Property_1caa087de4794f53880c4f3b725272b1_Out_0_Vector3 = _TangentOS;
bool _Property_1caa087de4794f53880c4f3b725272b1_Out_0_Vector3_IsConnected = _TangentOS_307e55ce70df463b90fe1b65f35443d9_IsConnected;
float3 _BranchOnInputConnection_49631555af044120aade11fe1ef46744_Out_3_Vector3 = _Property_1caa087de4794f53880c4f3b725272b1_Out_0_Vector3_IsConnected ? _Property_1caa087de4794f53880c4f3b725272b1_Out_0_Vector3 : IN.ObjectSpaceTangent;
float _Split_38da75d926c34146b97327ecc7d7d0e3_R_1_Float = _BranchOnInputConnection_49631555af044120aade11fe1ef46744_Out_3_Vector3[0];
float _Split_38da75d926c34146b97327ecc7d7d0e3_G_2_Float = _BranchOnInputConnection_49631555af044120aade11fe1ef46744_Out_3_Vector3[1];
float _Split_38da75d926c34146b97327ecc7d7d0e3_B_3_Float = _BranchOnInputConnection_49631555af044120aade11fe1ef46744_Out_3_Vector3[2];
float _Split_38da75d926c34146b97327ecc7d7d0e3_A_4_Float = 0;
float4 _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGBA_4_Vector4;
float3 _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGB_5_Vector3;
float2 _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RG_6_Vector2;
Unity_Combine_float(_Split_38da75d926c34146b97327ecc7d7d0e3_R_1_Float, _Split_38da75d926c34146b97327ecc7d7d0e3_G_2_Float, _Split_38da75d926c34146b97327ecc7d7d0e3_B_3_Float, 0, _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGBA_4_Vector4, _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGB_5_Vector3, _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RG_6_Vector2);
float4 _Multiply_88c2defdee7945aabfad7d073ac15b3c_Out_2_Vector4;
Unity_Multiply_float4x4_float4(_MatrixConstruction_f8e7a55ae71c47d68c57c0bd09c67bd5_var4x4_4_Matrix4, _Combine_e3a26f607c6a4b4ab38aeb7965e187f9_RGBA_4_Vector4, _Multiply_88c2defdee7945aabfad7d073ac15b3c_Out_2_Vector4);
float3 _Swizzle_dadec3efd6244574a802fd3e0ab56bb5_Out_1_Vector3 = _Multiply_88c2defdee7945aabfad7d073ac15b3c_Out_2_Vector4.xyz;
float3 _Transform_8906312bacad44698b5e2899041600be_Out_1_Vector3;
{
// Converting Normal from AbsoluteWorld to Object via world space
float3 world;
world = _Swizzle_dadec3efd6244574a802fd3e0ab56bb5_Out_1_Vector3.xyz;
_Transform_8906312bacad44698b5e2899041600be_Out_1_Vector3 = TransformWorldToObjectNormal(world, true);
}
float3 _OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3;
if (_OutputSpace == 0)
{
_OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3 = _Swizzle_dadec3efd6244574a802fd3e0ab56bb5_Out_1_Vector3;
}
else if (_OutputSpace == 1)
{
_OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3 = _Transform_8906312bacad44698b5e2899041600be_Out_1_Vector3;
}
else
{
_OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3 = _Swizzle_dadec3efd6244574a802fd3e0ab56bb5_Out_1_Vector3;
}
Position_1 = _OutputSpace_1a34b3c59bfa4d55a7856c32bd729958_Out_0_Vector3;
Normal_2 = _OutputSpace_05744dbf325b468594a7e1668aad1677_Out_0_Vector3;
Tangent_3 = _OutputSpace_306b0e6e0cdf4e1998771b14ce71d10c_Out_0_Vector3;
}

void Unity_Add_float4(float4 A, float4 B, out float4 Out)
{
    Out = A + B;
}

void Unity_Step_float(float Edge, float In, out float Out)
{
    Out = step(Edge, In);
}

// Custom interpolators pre vertex
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
float4 Color;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
float _InstanceID_2537a879f018425d9660432f4ea146f2_Out_0_Float;
UnityGetInstanceID_float(_InstanceID_2537a879f018425d9660432f4ea146f2_Out_0_Float);
float _Divide_63d9682156f042468629ccab8669beb8_Out_2_Float;
Unity_Divide_float(_InstanceID_2537a879f018425d9660432f4ea146f2_Out_0_Float, 37, _Divide_63d9682156f042468629ccab8669beb8_Out_2_Float);
float _Fraction_052ea01a8a0b4f83b7c6c139a0975ccc_Out_1_Float;
Unity_Fraction_float(_Divide_63d9682156f042468629ccab8669beb8_Out_2_Float, _Fraction_052ea01a8a0b4f83b7c6c139a0975ccc_Out_1_Float);
float4 _Property_19686efd1fb54b50a7d330cad1112554_Out_0_Vector4 = _Blade_Color_2;
float4 _Property_d254ba2921d340f982bfbcfaf5916ad3_Out_0_Vector4 = _Blade_Color_1;
float4 _Lerp_58d751d66dbc479a8656d14d2baf579f_Out_3_Vector4;
Unity_Lerp_float4(_Property_d254ba2921d340f982bfbcfaf5916ad3_Out_0_Vector4, _Property_19686efd1fb54b50a7d330cad1112554_Out_0_Vector4, (_Fraction_052ea01a8a0b4f83b7c6c139a0975ccc_Out_1_Float.xxxx), _Lerp_58d751d66dbc479a8656d14d2baf579f_Out_3_Vector4);
float _Property_dbcc12976b2c4eb4a63c1284e5f1d305_Out_0_Float = _Wind_Speed;
Bindings_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba;
_FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba.TimeParameters = IN.TimeParameters;
float2 _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindDirection_1_Vector2;
float _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindIntensity_2_Float;
float3 _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_Random_3_Vector3;
SG_FoliageWind_e1c04be59f2f95e458a6ce4e3a9b81cc_float(124, _Property_dbcc12976b2c4eb4a63c1284e5f1d305_Out_0_Float, 0.01, 0.2, 0.1, 0.2, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindDirection_1_Vector2, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindIntensity_2_Float, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_Random_3_Vector3);
float4x4 _Property_e6333f42f10045b8874ca797f7698f1d_Out_0_Matrix4 = _WireframeShaderMaskData1;
float _DynamicMask_50b2c29949db4c9087fc753d984c4250_Out_3_Float;
WireframeShaderDynamicMaskCube_float(IN.WorldSpacePosition, _Property_e6333f42f10045b8874ca797f7698f1d_Out_0_Matrix4, 0, _DynamicMask_50b2c29949db4c9087fc753d984c4250_Out_3_Float);
float4x4 _Property_37070fbe8a4e4576a732a3a352dec45e_Out_0_Matrix4 = _WireframeShaderMaskData2;
float _DynamicMask_0c15310c869f45a5bb095f810944777b_Out_3_Float;
WireframeShaderDynamicMaskSphere_float(IN.WorldSpacePosition, _Property_37070fbe8a4e4576a732a3a352dec45e_Out_0_Matrix4, 0, _DynamicMask_0c15310c869f45a5bb095f810944777b_Out_3_Float);
float _Add_4e24bc1118f94bdb89aeba5ac3067e43_Out_2_Float;
Unity_Add_float(_DynamicMask_50b2c29949db4c9087fc753d984c4250_Out_3_Float, _DynamicMask_0c15310c869f45a5bb095f810944777b_Out_3_Float, _Add_4e24bc1118f94bdb89aeba5ac3067e43_Out_2_Float);
float _Saturate_b1a2ecfe1d1842778d5653a46a7b1782_Out_1_Float;
Unity_Saturate_float(_Add_4e24bc1118f94bdb89aeba5ac3067e43_Out_2_Float, _Saturate_b1a2ecfe1d1842778d5653a46a7b1782_Out_1_Float);
float _OneMinus_153cdd2db72f462c97a7c55eccd49567_Out_1_Float;
Unity_OneMinus_float(_Saturate_b1a2ecfe1d1842778d5653a46a7b1782_Out_1_Float, _OneMinus_153cdd2db72f462c97a7c55eccd49567_Out_1_Float);
float _Multiply_cff561f8195f49188db426fdc084a6ce_Out_2_Float;
Unity_Multiply_float_float(_OneMinus_153cdd2db72f462c97a7c55eccd49567_Out_1_Float, -1, _Multiply_cff561f8195f49188db426fdc084a6ce_Out_2_Float);
float3 _Vector3_2dea481cbff74205a7cee900960a51a9_Out_0_Vector3 = float3(_FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindIntensity_2_Float, _Multiply_cff561f8195f49188db426fdc084a6ce_Out_2_Float, _FoliageWind_22aca33fccfd4727ac5d4eb9ab62e9ba_WindIntensity_2_Float);
Bindings_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f;
_BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f.ObjectSpaceNormal = IN.ObjectSpaceNormal;
_BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f.ObjectSpaceTangent = IN.ObjectSpaceTangent;
_BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f.ObjectSpacePosition = IN.ObjectSpacePosition;
float3 _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Position_1_Vector3;
float3 _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Normal_2_Vector3;
float3 _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Tangent_3_Vector3;
SG_BillboardCylindrical_89f890aa3ee0e19418c398fb74cb9ab9_float(float3 (0, 0, 0), false, float3 (0, 0, 0), false, float3 (0, 0, 0), false, _Vector3_2dea481cbff74205a7cee900960a51a9_Out_0_Vector3, float3 (-1, 1, 1), float4 (0, 1, 0, 0), 1, _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f, _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Position_1_Vector3, _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Normal_2_Vector3, _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Tangent_3_Vector3);
description.Position = _BillboardCylindrical_ff86d4ba056645ada8ec26ea9dfc3d6f_Position_1_Vector3;
description.Normal = IN.ObjectSpaceNormal;
description.Tangent = IN.ObjectSpaceTangent;
description.Color = _Lerp_58d751d66dbc479a8656d14d2baf579f_Out_3_Vector4;
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
output.Color = input.Color;
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
float _Property_a7bf99e3e3cf4540bc6bd38a6aaab41f_Out_0_Float = _Wireframe_Thickness;
float _Property_07fc055baf6a48729fd1b78fbf96db5c_Out_0_Float = _Wireframe_Anti_aliasing;
float4 _Add_c1cf3158744d4822974d88d98d719275_Out_2_Vector4;
Unity_Add_float4(IN.Color, 0, _Add_c1cf3158744d4822974d88d98d719275_Out_2_Vector4);
float4x4 _Property_768bac82b0684cd0a21ed8a814d35a50_Out_0_Matrix4 = _WireframeShaderMaskData1;
float _DynamicMask_d8cbb946b52f4b01a4d3fd3bc3ea9de1_Out_3_Float;
WireframeShaderDynamicMaskCube_float(IN.WorldSpacePosition, _Property_768bac82b0684cd0a21ed8a814d35a50_Out_0_Matrix4, 0, _DynamicMask_d8cbb946b52f4b01a4d3fd3bc3ea9de1_Out_3_Float);
float4x4 _Property_39e6a912ee0647ed8335e7ab63cd4bed_Out_0_Matrix4 = _WireframeShaderMaskData2;
float _DynamicMask_e413c723ed49470ba4eca3bcf6362548_Out_3_Float;
WireframeShaderDynamicMaskSphere_float(IN.WorldSpacePosition, _Property_39e6a912ee0647ed8335e7ab63cd4bed_Out_0_Matrix4, 0, _DynamicMask_e413c723ed49470ba4eca3bcf6362548_Out_3_Float);
float _Add_c3b10d55feaf4b9baefa4948a8eaed75_Out_2_Float;
Unity_Add_float(_DynamicMask_d8cbb946b52f4b01a4d3fd3bc3ea9de1_Out_3_Float, _DynamicMask_e413c723ed49470ba4eca3bcf6362548_Out_3_Float, _Add_c3b10d55feaf4b9baefa4948a8eaed75_Out_2_Float);
float _Saturate_62dc9cf6a37b4fab9407e114176db70f_Out_1_Float;
Unity_Saturate_float(_Add_c3b10d55feaf4b9baefa4948a8eaed75_Out_2_Float, _Saturate_62dc9cf6a37b4fab9407e114176db70f_Out_1_Float);
float _Step_0f4fbf717a47479eaa1a77f0d38201d7_Out_2_Float;
Unity_Step_float(0.05, _Saturate_62dc9cf6a37b4fab9407e114176db70f_Out_1_Float, _Step_0f4fbf717a47479eaa1a77f0d38201d7_Out_2_Float);
surface.BaseColor = (_Add_c1cf3158744d4822974d88d98d719275_Out_2_Vector4.xyz);
surface.Alpha = _Step_0f4fbf717a47479eaa1a77f0d38201d7_Out_2_Float;
surface.AlphaClipThreshold = 0.5;
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
    output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
    output.TimeParameters =                             _TimeParameters.xyz;

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

    output.Color = input.Color;





    output.WorldSpacePosition = input.positionWS;

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
    "m_ObjectId": "7dfa1816df0f44b0924f6eda2d603b41",
    "m_Properties": [
        {
            "m_Id": "f9844473df9245f7a0d356a51494e8f1"
        },
        {
            "m_Id": "d65c38e554c14f9c91f43ec8804b6709"
        },
        {
            "m_Id": "e4b36eccf88744c4b9d4bf909634b12d"
        },
        {
            "m_Id": "3a65920d710b4cde9d51d6564dad0460"
        },
        {
            "m_Id": "873a9506b4754285860a03988e3f7be5"
        },
        {
            "m_Id": "048a03ba0e924ceabb4ab1404303cdf4"
        },
        {
            "m_Id": "67ebfaffaee14928a711b29a096d8558"
        },
        {
            "m_Id": "d36e0a88c81b4f669c4bc6d70b857cbc"
        },
        {
            "m_Id": "6c282f577aa64346b52e0035a910fc51"
        }
    ],
    "m_Keywords": [],
    "m_Dropdowns": [],
    "m_CategoryData": [
        {
            "m_Id": "dee1883a50ff4c19bb6dceceb2a6b1d9"
        },
        {
            "m_Id": "91406763260744f290cdc3f1b7c11881"
        },
        {
            "m_Id": "c2511a21eac34868b221b392d5ad3a5a"
        },
        {
            "m_Id": "176c623db70249c2a3c3ae56b4b74376"
        }
    ],
    "m_Nodes": [
        {
            "m_Id": "9a28b2925e794fcfb3decb80d854bd3b"
        },
        {
            "m_Id": "0c959a4ef1a044aba669de653cd758aa"
        },
        {
            "m_Id": "54ec4b8adf3c4753b2b238a4c6b8e0db"
        },
        {
            "m_Id": "e740624f4f8942db89b2489b1391ba05"
        },
        {
            "m_Id": "22aca33fccfd4727ac5d4eb9ab62e9ba"
        },
        {
            "m_Id": "2537a879f018425d9660432f4ea146f2"
        },
        {
            "m_Id": "63d9682156f042468629ccab8669beb8"
        },
        {
            "m_Id": "052ea01a8a0b4f83b7c6c139a0975ccc"
        },
        {
            "m_Id": "58d751d66dbc479a8656d14d2baf579f"
        },
        {
            "m_Id": "c867716e88ef40509e68b8b666236234"
        },
        {
            "m_Id": "5af825dd918d42498b41a6d5b08d1afe"
        },
        {
            "m_Id": "ff86d4ba056645ada8ec26ea9dfc3d6f"
        },
        {
            "m_Id": "2dea481cbff74205a7cee900960a51a9"
        },
        {
            "m_Id": "153cdd2db72f462c97a7c55eccd49567"
        },
        {
            "m_Id": "cff561f8195f49188db426fdc084a6ce"
        },
        {
            "m_Id": "d254ba2921d340f982bfbcfaf5916ad3"
        },
        {
            "m_Id": "19686efd1fb54b50a7d330cad1112554"
        },
        {
            "m_Id": "4688972c65be441aa92fdbbcf5d9938e"
        },
        {
            "m_Id": "b17d9045f0a44cc8ba01c677192340fe"
        },
        {
            "m_Id": "dbcc12976b2c4eb4a63c1284e5f1d305"
        },
        {
            "m_Id": "37affc5122be4fc997ce4a884794c23d"
        },
        {
            "m_Id": "0f4fbf717a47479eaa1a77f0d38201d7"
        },
        {
            "m_Id": "e9a775fd60fa4b0791559409a707b984"
        },
        {
            "m_Id": "c1cf3158744d4822974d88d98d719275"
        },
        {
            "m_Id": "a7bf99e3e3cf4540bc6bd38a6aaab41f"
        },
        {
            "m_Id": "07fc055baf6a48729fd1b78fbf96db5c"
        },
        {
            "m_Id": "2d5970f9fa694af8910a384a340812b3"
        },
        {
            "m_Id": "0b86aaff47f7461e857907ea5c675348"
        },
        {
            "m_Id": "514b8c6efc3e47fd902bca474d0cc1db"
        },
        {
            "m_Id": "3c880ea743bf4b40bd649f8d3172c5b3"
        },
        {
            "m_Id": "f8a3807160984bb6832806d5ffa9756e"
        },
        {
            "m_Id": "3dfd7f0042a84c849cb51051e594d3f5"
        },
        {
            "m_Id": "768bac82b0684cd0a21ed8a814d35a50"
        },
        {
            "m_Id": "39e6a912ee0647ed8335e7ab63cd4bed"
        },
        {
            "m_Id": "c3b10d55feaf4b9baefa4948a8eaed75"
        },
        {
            "m_Id": "62dc9cf6a37b4fab9407e114176db70f"
        },
        {
            "m_Id": "d8cbb946b52f4b01a4d3fd3bc3ea9de1"
        },
        {
            "m_Id": "e413c723ed49470ba4eca3bcf6362548"
        },
        {
            "m_Id": "e6333f42f10045b8874ca797f7698f1d"
        },
        {
            "m_Id": "37070fbe8a4e4576a732a3a352dec45e"
        },
        {
            "m_Id": "4e24bc1118f94bdb89aeba5ac3067e43"
        },
        {
            "m_Id": "b1a2ecfe1d1842778d5653a46a7b1782"
        },
        {
            "m_Id": "50b2c29949db4c9087fc753d984c4250"
        },
        {
            "m_Id": "0c15310c869f45a5bb095f810944777b"
        }
    ],
    "m_GroupDatas": [
        {
            "m_Id": "4b5bf0081971482b921a80ea00172eec"
        },
        {
            "m_Id": "f3a763e910514d8eac4f8ba6f44f173d"
        },
        {
            "m_Id": "13f65a2ff0a44e2a8ddfd5645da51286"
        },
        {
            "m_Id": "3da395f03a48462e987588841533f628"
        }
    ],
    "m_StickyNoteDatas": [],
    "m_Edges": [
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "052ea01a8a0b4f83b7c6c139a0975ccc"
                },
                "m_SlotId": 1
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "58d751d66dbc479a8656d14d2baf579f"
                },
                "m_SlotId": 2
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "07fc055baf6a48729fd1b78fbf96db5c"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "e9a775fd60fa4b0791559409a707b984"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "0c15310c869f45a5bb095f810944777b"
                },
                "m_SlotId": 3
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "4e24bc1118f94bdb89aeba5ac3067e43"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "0f4fbf717a47479eaa1a77f0d38201d7"
                },
                "m_SlotId": 2
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "37affc5122be4fc997ce4a884794c23d"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "153cdd2db72f462c97a7c55eccd49567"
                },
                "m_SlotId": 1
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "cff561f8195f49188db426fdc084a6ce"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "19686efd1fb54b50a7d330cad1112554"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "58d751d66dbc479a8656d14d2baf579f"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "22aca33fccfd4727ac5d4eb9ab62e9ba"
                },
                "m_SlotId": 2
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "2dea481cbff74205a7cee900960a51a9"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "22aca33fccfd4727ac5d4eb9ab62e9ba"
                },
                "m_SlotId": 2
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "2dea481cbff74205a7cee900960a51a9"
                },
                "m_SlotId": 3
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "2537a879f018425d9660432f4ea146f2"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "63d9682156f042468629ccab8669beb8"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "2dea481cbff74205a7cee900960a51a9"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "ff86d4ba056645ada8ec26ea9dfc3d6f"
                },
                "m_SlotId": 1244964050
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "37070fbe8a4e4576a732a3a352dec45e"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "0c15310c869f45a5bb095f810944777b"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "39e6a912ee0647ed8335e7ab63cd4bed"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "e413c723ed49470ba4eca3bcf6362548"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "4688972c65be441aa92fdbbcf5d9938e"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "e740624f4f8942db89b2489b1391ba05"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "4e24bc1118f94bdb89aeba5ac3067e43"
                },
                "m_SlotId": 2
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "b1a2ecfe1d1842778d5653a46a7b1782"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "50b2c29949db4c9087fc753d984c4250"
                },
                "m_SlotId": 3
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "4e24bc1118f94bdb89aeba5ac3067e43"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "58d751d66dbc479a8656d14d2baf579f"
                },
                "m_SlotId": 3
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "c867716e88ef40509e68b8b666236234"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "5af825dd918d42498b41a6d5b08d1afe"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "c1cf3158744d4822974d88d98d719275"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "62dc9cf6a37b4fab9407e114176db70f"
                },
                "m_SlotId": 1
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "0f4fbf717a47479eaa1a77f0d38201d7"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "63d9682156f042468629ccab8669beb8"
                },
                "m_SlotId": 2
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "052ea01a8a0b4f83b7c6c139a0975ccc"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "768bac82b0684cd0a21ed8a814d35a50"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "d8cbb946b52f4b01a4d3fd3bc3ea9de1"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "a7bf99e3e3cf4540bc6bd38a6aaab41f"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "e9a775fd60fa4b0791559409a707b984"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "b17d9045f0a44cc8ba01c677192340fe"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "54ec4b8adf3c4753b2b238a4c6b8e0db"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "b1a2ecfe1d1842778d5653a46a7b1782"
                },
                "m_SlotId": 1
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "153cdd2db72f462c97a7c55eccd49567"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "c1cf3158744d4822974d88d98d719275"
                },
                "m_SlotId": 2
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "0c959a4ef1a044aba669de653cd758aa"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "c3b10d55feaf4b9baefa4948a8eaed75"
                },
                "m_SlotId": 2
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "62dc9cf6a37b4fab9407e114176db70f"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "cff561f8195f49188db426fdc084a6ce"
                },
                "m_SlotId": 2
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "2dea481cbff74205a7cee900960a51a9"
                },
                "m_SlotId": 2
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "d254ba2921d340f982bfbcfaf5916ad3"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "58d751d66dbc479a8656d14d2baf579f"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "d8cbb946b52f4b01a4d3fd3bc3ea9de1"
                },
                "m_SlotId": 3
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "c3b10d55feaf4b9baefa4948a8eaed75"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "dbcc12976b2c4eb4a63c1284e5f1d305"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "22aca33fccfd4727ac5d4eb9ab62e9ba"
                },
                "m_SlotId": -1955643226
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "e413c723ed49470ba4eca3bcf6362548"
                },
                "m_SlotId": 3
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "c3b10d55feaf4b9baefa4948a8eaed75"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "e6333f42f10045b8874ca797f7698f1d"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "50b2c29949db4c9087fc753d984c4250"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "e9a775fd60fa4b0791559409a707b984"
                },
                "m_SlotId": 3
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "c1cf3158744d4822974d88d98d719275"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "ff86d4ba056645ada8ec26ea9dfc3d6f"
                },
                "m_SlotId": 1
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "9a28b2925e794fcfb3decb80d854bd3b"
                },
                "m_SlotId": 0
            }
        }
    ],
    "m_VertexContext": {
        "m_Position": {
            "x": -0.000009298324584960938,
            "y": -780.4999389648438
        },
        "m_Blocks": [
            {
                "m_Id": "9a28b2925e794fcfb3decb80d854bd3b"
            },
            {
                "m_Id": "c867716e88ef40509e68b8b666236234"
            },
            {
                "m_Id": "2d5970f9fa694af8910a384a340812b3"
            },
            {
                "m_Id": "0b86aaff47f7461e857907ea5c675348"
            }
        ]
    },
    "m_FragmentContext": {
        "m_Position": {
            "x": -0.00004373420961201191,
            "y": -136.14535522460938
        },
        "m_Blocks": [
            {
                "m_Id": "0c959a4ef1a044aba669de653cd758aa"
            },
            {
                "m_Id": "54ec4b8adf3c4753b2b238a4c6b8e0db"
            },
            {
                "m_Id": "e740624f4f8942db89b2489b1391ba05"
            },
            {
                "m_Id": "514b8c6efc3e47fd902bca474d0cc1db"
            },
            {
                "m_Id": "3c880ea743bf4b40bd649f8d3172c5b3"
            },
            {
                "m_Id": "f8a3807160984bb6832806d5ffa9756e"
            },
            {
                "m_Id": "3dfd7f0042a84c849cb51051e594d3f5"
            },
            {
                "m_Id": "37affc5122be4fc997ce4a884794c23d"
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
            "m_Id": "219bc787d2474e3d8bd18dc3414c84d2"
        }
    ]
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "00a1532674474ae0a6ff75e6f41477cd",
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
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "00b0b14086b34ff39e8b6441721d8266",
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
    "m_Type": "UnityEditor.Rendering.HighDefinition.ShaderGraph.BuiltinData",
    "m_ObjectId": "01fb76bd58154edf8e854b7bba77588f",
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
    "m_Type": "UnityEditor.ShaderGraph.BooleanMaterialSlot",
    "m_ObjectId": "0379e02c8d1d4907b3514185f10db02c",
    "m_Id": 2,
    "m_DisplayName": "Render In Screen Space",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "Render In Screen Space",
    "m_StageCapability": 3,
    "m_Value": false,
    "m_DefaultValue": false
}

{
    "m_SGVersion": 3,
    "m_Type": "UnityEditor.ShaderGraph.Internal.ColorShaderProperty",
    "m_ObjectId": "048a03ba0e924ceabb4ab1404303cdf4",
    "m_Guid": {
        "m_GuidSerialized": "40a43e1c-2f05-4e77-afd2-43740a30c081"
    },
    "m_Name": "Blade Color #1",
    "m_DefaultRefNameVersion": 1,
    "m_RefNameGeneratedByDisplayName": "Blade Color #1",
    "m_DefaultReferenceName": "_Blade_Color_1",
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
        "r": 0.23536323010921479,
        "g": 0.5283018946647644,
        "b": 0.06728373467922211,
        "a": 1.0
    },
    "isMainColor": false,
    "m_ColorMode": 0
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "05293329dd0d4c71bef05e310f3acd3b",
    "m_Id": 0,
    "m_DisplayName": "Wind Speed",
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
    "m_Type": "UnityEditor.ShaderGraph.FractionNode",
    "m_ObjectId": "052ea01a8a0b4f83b7c6c139a0975ccc",
    "m_Group": {
        "m_Id": "f3a763e910514d8eac4f8ba6f44f173d"
    },
    "m_Name": "Fraction",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -931.1997680664063,
            "y": -688.5817260742188,
            "width": 130.9090576171875,
            "height": 93.38177490234375
        }
    },
    "m_Slots": [
        {
            "m_Id": "c30648de1c6448c483c4e75f57c6178b"
        },
        {
            "m_Id": "7531f2ce3e9c453fb8a1a898c34e14d4"
        }
    ],
    "synonyms": [
        "remainder"
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
    "m_Type": "UnityEditor.ShaderGraph.Vector4MaterialSlot",
    "m_ObjectId": "05d8b7fe7fce4429ab506648945e2a4c",
    "m_Id": 0,
    "m_DisplayName": "Out",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "Out",
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
    "m_Type": "UnityEditor.ShaderGraph.PropertyNode",
    "m_ObjectId": "07fc055baf6a48729fd1b78fbf96db5c",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "Property",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1298.6180419921875,
            "y": -34.0362548828125,
            "width": 198.981689453125,
            "height": 33.16362380981445
        }
    },
    "m_Slots": [
        {
            "m_Id": "9a9dbc24b1af43f0bcc75fb7df12e0e7"
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
        "m_Id": "d65c38e554c14f9c91f43ec8804b6709"
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.PositionMaterialSlot",
    "m_ObjectId": "0892f95b1fe940f6a4a3131798064ec7",
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "0aafc71f211c4de180ebfd11069ac310",
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
    "m_Type": "UnityEditor.ShaderGraph.BlockNode",
    "m_ObjectId": "0b86aaff47f7461e857907ea5c675348",
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
            "m_Id": "8f99e12eba1c47c1981d1e4d3cfbfcfd"
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
    "m_ObjectId": "0c15310c869f45a5bb095f810944777b",
    "m_Group": {
        "m_Id": "3da395f03a48462e987588841533f628"
    },
    "m_Name": "Dynamic Mask",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -2367.708984375,
            "y": -1137.1636962890625,
            "width": 223.41796875,
            "height": 152.72723388671876
        }
    },
    "m_Slots": [
        {
            "m_Id": "58be808f21b54e7aa8d1bd3fbeca57d3"
        },
        {
            "m_Id": "91c6f8489d8c4b9f974600e229997c36"
        },
        {
            "m_Id": "c22d6a90c6f3411e8d024ee4197765d2"
        },
        {
            "m_Id": "e3bbbbed776c4efd8a09b351c4252a63"
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
    "m_Type": "UnityEditor.ShaderGraph.BlockNode",
    "m_ObjectId": "0c959a4ef1a044aba669de653cd758aa",
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
            "m_Id": "2dfc9501311942518cec6f0746bd605d"
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
    "m_Type": "UnityEditor.ShaderGraph.StepNode",
    "m_ObjectId": "0f4fbf717a47479eaa1a77f0d38201d7",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "Step",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1343.127197265625,
            "y": 152.7272491455078,
            "width": 148.3636474609375,
            "height": 117.81816101074219
        }
    },
    "m_Slots": [
        {
            "m_Id": "6f31cc5390f547cb8cae453527696ecc"
        },
        {
            "m_Id": "6d12e79e6bf146c0bb8042b4e1ebb639"
        },
        {
            "m_Id": "a6bd0e82aa3a4e4186c35d0395125897"
        }
    ],
    "synonyms": [],
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
    "m_Type": "UnityEditor.ShaderGraph.GroupData",
    "m_ObjectId": "13f65a2ff0a44e2a8ddfd5645da51286",
    "m_Title": "Dynamic Masks",
    "m_Position": {
        "x": -2543.126953125,
        "y": 26.18181610107422
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.OneMinusNode",
    "m_ObjectId": "153cdd2db72f462c97a7c55eccd49567",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "One Minus",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1467.0543212890625,
            "y": -1251.49072265625,
            "width": 130.9090576171875,
            "height": 93.3817138671875
        }
    },
    "m_Slots": [
        {
            "m_Id": "b2fd31004c2b42efa41249d113092392"
        },
        {
            "m_Id": "20df86e2ce624c599426df26251fc79e"
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
    "m_Type": "UnityEditor.ShaderGraph.CategoryData",
    "m_ObjectId": "176c623db70249c2a3c3ae56b4b74376",
    "m_Name": "Wind",
    "m_ChildObjectList": [
        {
            "m_Id": "6c282f577aa64346b52e0035a910fc51"
        }
    ]
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "1914dbe33444466b9af43f0bd7062d85",
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
    "m_Type": "UnityEditor.ShaderGraph.PropertyNode",
    "m_ObjectId": "19686efd1fb54b50a7d330cad1112554",
    "m_Group": {
        "m_Id": "f3a763e910514d8eac4f8ba6f44f173d"
    },
    "m_Name": "Property",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -957.3817138671875,
            "y": -736.5817260742188,
            "width": 156.2181396484375,
            "height": 33.16363525390625
        }
    },
    "m_Slots": [
        {
            "m_Id": "c6ea6534473649d4a6aa2da354caa25f"
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
        "m_Id": "873a9506b4754285860a03988e3f7be5"
    }
}

{
    "m_SGVersion": 2,
    "m_Type": "UnityEditor.Rendering.Universal.ShaderGraph.UniversalLitSubTarget",
    "m_ObjectId": "19ed722d92ab420d932dd8126e428a42",
    "m_WorkflowMode": 1,
    "m_NormalDropOffSpace": 0,
    "m_ClearCoat": false,
    "m_BlendModePreserveSpecular": true
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "1c2928d582c44cbca053cc0841850bf1",
    "m_Id": 1,
    "m_DisplayName": "B",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "B",
    "m_StageCapability": 3,
    "m_Value": {
        "e00": -1.0,
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
    "m_ObjectId": "20df86e2ce624c599426df26251fc79e",
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
    "m_SGVersion": 1,
    "m_Type": "UnityEditor.Rendering.Universal.ShaderGraph.UniversalTarget",
    "m_ObjectId": "219bc787d2474e3d8bd18dc3414c84d2",
    "m_Datas": [],
    "m_ActiveSubTarget": {
        "m_Id": "19ed722d92ab420d932dd8126e428a42"
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
    "m_Type": "UnityEditor.ShaderGraph.SubGraphNode",
    "m_ObjectId": "22aca33fccfd4727ac5d4eb9ab62e9ba",
    "m_Group": {
        "m_Id": "4b5bf0081971482b921a80ea00172eec"
    },
    "m_Name": "FoliageWind",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1577.8907470703125,
            "y": -1671.2725830078125,
            "width": 341.2362060546875,
            "height": 212.9453125
        }
    },
    "m_Slots": [
        {
            "m_Id": "b209ffc21b8944e2841ddb2a15fa3d49"
        },
        {
            "m_Id": "f562379bfa2940fda3f595284919991f"
        },
        {
            "m_Id": "5dc6e70bb6f743ff85c004c9ec314439"
        },
        {
            "m_Id": "4956cf396a164bed82907a2de1137446"
        },
        {
            "m_Id": "fe96e00d2ad64904bc055f5c5d6f49de"
        },
        {
            "m_Id": "c8f948178fa1428792cc8f18b327f407"
        },
        {
            "m_Id": "a9b18ea29b234501bacc0e475dceff58"
        },
        {
            "m_Id": "3a38d7ef67dc4defb32ccf6386df8dda"
        },
        {
            "m_Id": "5e0ce1aad513427bb8bfb6bb0f5fc7d2"
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
    "m_SerializedSubGraph": "{\n    \"subGraph\": {\n        \"fileID\": -5475051401550479605,\n        \"guid\": \"e1c04be59f2f95e458a6ce4e3a9b81cc\",\n        \"type\": 3\n    }\n}",
    "m_PropertyGuids": [
        "4c46f584-6c57-4792-a84f-03eca5a06ea3",
        "c625a5ab-5c73-4be5-9785-9fb8e93c30be",
        "6e9d23c8-ba08-4bf7-a13a-d2a1972cc5b4",
        "0ec75098-3256-4282-a5ae-791a048388f0",
        "b49447d7-a4e2-4e57-a098-379a8bef55a8",
        "81c08dcc-de2f-4e68-89ae-cdd3e8a3c01a"
    ],
    "m_PropertyIds": [
        1153005278,
        -1955643226,
        813535222,
        -1498132625,
        -928934882,
        111500930
    ],
    "m_Dropdowns": [],
    "m_DropdownSelectedEntries": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector2MaterialSlot",
    "m_ObjectId": "236ce2f67e574255b1a7c2dab57e6981",
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
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "24079fed768340df9d2fb73d801a70e9",
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
    "m_Type": "UnityEditor.ShaderGraph.InstanceIDNode",
    "m_ObjectId": "2537a879f018425d9660432f4ea146f2",
    "m_Group": {
        "m_Id": "f3a763e910514d8eac4f8ba6f44f173d"
    },
    "m_Name": "Instance ID",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1162.472412109375,
            "y": -688.5817260742188,
            "width": 108.218017578125,
            "height": 76.79998779296875
        }
    },
    "m_Slots": [
        {
            "m_Id": "5b970fe051ae4990a94e5d2351d77dc0"
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
    "m_ObjectId": "2d5970f9fa694af8910a384a340812b3",
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
            "m_Id": "8aa77bb58f764b6c84db6fab9876f027"
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
    "m_Type": "UnityEditor.ShaderGraph.Vector3Node",
    "m_ObjectId": "2dea481cbff74205a7cee900960a51a9",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "Vector 3",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -916.363525390625,
            "y": -1405.0908203125,
            "width": 130.9090576171875,
            "height": 123.92724609375
        }
    },
    "m_Slots": [
        {
            "m_Id": "e3284561089540dab3269b6daf80829f"
        },
        {
            "m_Id": "00a1532674474ae0a6ff75e6f41477cd"
        },
        {
            "m_Id": "4969e579121c4b73976ce95aafe493db"
        },
        {
            "m_Id": "810edd91a9594e75803e095347e29386"
        }
    ],
    "synonyms": [
        "3",
        "v3",
        "vec3",
        "float3"
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
        "z": 0.0
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.ColorRGBMaterialSlot",
    "m_ObjectId": "2dfc9501311942518cec6f0746bd605d",
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
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "309f27ef831b49588b8ea1010b3dfb0c",
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "30c98038f67f46af99cd1771c72f1180",
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
    "m_Type": "UnityEditor.ShaderGraph.Matrix4MaterialSlot",
    "m_ObjectId": "31484899120d4ac0a3b0fdbd4989d7b8",
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
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "33e5700e48444a8b96640f2d41a1d697",
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "3599b61ddf444a73bef1bf92c403c8d2",
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
    "m_ObjectId": "37070fbe8a4e4576a732a3a352dec45e",
    "m_Group": {
        "m_Id": "3da395f03a48462e987588841533f628"
    },
    "m_Name": "Property",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -2709.818115234375,
            "y": -1092.6546630859375,
            "width": 231.272705078125,
            "height": 32.291015625
        }
    },
    "m_Slots": [
        {
            "m_Id": "e4b8b3642a804c5ca0b9b71a92b5d539"
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
        "m_Id": "3a65920d710b4cde9d51d6564dad0460"
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "376ed0e33708456c9ef56cd463308672",
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
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector4MaterialSlot",
    "m_ObjectId": "379a2ba4fddc4e9f851bf0666afa8a7e",
    "m_Id": -555998685,
    "m_DisplayName": "PivotAxis",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "_PivotAxis",
    "m_StageCapability": 3,
    "m_Value": {
        "x": 0.0,
        "y": 1.0,
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
    "m_Type": "UnityEditor.ShaderGraph.BlockNode",
    "m_ObjectId": "37affc5122be4fc997ce4a884794c23d",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "SurfaceDescription.Alpha",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": 12.218152046203614,
            "y": 177.1636199951172,
            "width": 199.8545379638672,
            "height": 40.14549255371094
        }
    },
    "m_Slots": [
        {
            "m_Id": "f3bbaa9daeba4f8ea6d3436447744e6f"
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
    "m_Type": "UnityEditor.ShaderGraph.PropertyNode",
    "m_ObjectId": "39e6a912ee0647ed8335e7ab63cd4bed",
    "m_Group": {
        "m_Id": "13f65a2ff0a44e2a8ddfd5645da51286"
    },
    "m_Name": "Property",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -2518.690673828125,
            "y": 342.9818420410156,
            "width": 231.272705078125,
            "height": 32.290863037109378
        }
    },
    "m_Slots": [
        {
            "m_Id": "31484899120d4ac0a3b0fdbd4989d7b8"
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
        "m_Id": "3a65920d710b4cde9d51d6564dad0460"
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "3a38d7ef67dc4defb32ccf6386df8dda",
    "m_Id": 2,
    "m_DisplayName": "WindIntensity",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "WindIntensity",
    "m_StageCapability": 3,
    "m_Value": 0.0,
    "m_DefaultValue": 0.0,
    "m_Labels": []
}

{
    "m_SGVersion": 1,
    "m_Type": "UnityEditor.ShaderGraph.Matrix4ShaderProperty",
    "m_ObjectId": "3a65920d710b4cde9d51d6564dad0460",
    "m_Guid": {
        "m_GuidSerialized": "e367ca0d-9b6d-41e2-8fa3-4d7e77481b7d"
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
    "m_Type": "UnityEditor.ShaderGraph.BlockNode",
    "m_ObjectId": "3c880ea743bf4b40bd649f8d3172c5b3",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "SurfaceDescription.Emission",
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
            "m_Id": "9c0bf51598424587a0daf9152d87af99"
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
    "m_Type": "UnityEditor.ShaderGraph.GroupData",
    "m_ObjectId": "3da395f03a48462e987588841533f628",
    "m_Title": "Dynamic Masks",
    "m_Position": {
        "x": -2734.25439453125,
        "y": -1409.45458984375
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.BlockNode",
    "m_ObjectId": "3dfd7f0042a84c849cb51051e594d3f5",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "SurfaceDescription.AlphaClipThreshold",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": 12.218254089355469,
            "y": 124.80000305175781,
            "width": 199.85452270507813,
            "height": 40.145477294921878
        }
    },
    "m_Slots": [
        {
            "m_Id": "cd62d0a238024113b49b6b28a5669972"
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "400adac3a76b47599a2b71fa078943c1",
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
    "m_Type": "UnityEditor.ShaderGraph.Vector3MaterialSlot",
    "m_ObjectId": "42191fa9071b49cf9349b7232368202c",
    "m_Id": 2,
    "m_DisplayName": "Normal",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "Normal",
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
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.PropertyNode",
    "m_ObjectId": "4688972c65be441aa92fdbbcf5d9938e",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "Property",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -232.14559936523438,
            "y": -26.181846618652345,
            "width": 141.38197326660157,
            "height": 33.16362380981445
        }
    },
    "m_Slots": [
        {
            "m_Id": "60514e366d1045aebb0adedbd718c544"
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
        "m_Id": "d36e0a88c81b4f669c4bc6d70b857cbc"
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "47ebd890bf8440889bad5f9ce0c7529d",
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
    "m_ObjectId": "4956cf396a164bed82907a2de1137446",
    "m_Id": -1498132625,
    "m_DisplayName": "PerBladeRandomTimeOffset",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "_PerBladeRandomTimeOffset",
    "m_StageCapability": 3,
    "m_Value": 0.20000000298023225,
    "m_DefaultValue": 0.0,
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "4969e579121c4b73976ce95aafe493db",
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
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "49e6efd265f34169bd778ff3c0f7850e",
    "m_Id": 0,
    "m_DisplayName": "Thickness",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "Thickness",
    "m_StageCapability": 3,
    "m_Value": 0.05000000074505806,
    "m_DefaultValue": 0.009999999776482582,
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.GroupData",
    "m_ObjectId": "4b5bf0081971482b921a80ea00172eec",
    "m_Title": "Wind and wind response",
    "m_Position": {
        "x": -1602.3271484375,
        "y": -1728.8724365234375
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.AddNode",
    "m_ObjectId": "4e24bc1118f94bdb89aeba5ac3067e43",
    "m_Group": {
        "m_Id": "3da395f03a48462e987588841533f628"
    },
    "m_Name": "Add",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -2074.47265625,
            "y": -1254.1092529296875,
            "width": 129.1634521484375,
            "height": 116.945556640625
        }
    },
    "m_Slots": [
        {
            "m_Id": "a6ce88cdd7374778bc742b3e746ebd84"
        },
        {
            "m_Id": "e5bff04c2f1b4bcbb95d3f751956d596"
        },
        {
            "m_Id": "1914dbe33444466b9af43f0bd7062d85"
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
    "m_Type": "AmazingAssets.DynamicWireframeShaderGenerator.Editor.DynamicMaskNode",
    "m_ObjectId": "50b2c29949db4c9087fc753d984c4250",
    "m_Group": {
        "m_Id": "3da395f03a48462e987588841533f628"
    },
    "m_Name": "Dynamic Mask",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -2367.708984375,
            "y": -1351.8546142578125,
            "width": 223.41796875,
            "height": 152.7271728515625
        }
    },
    "m_Slots": [
        {
            "m_Id": "de485ad92c0b44a6a9d022a707c5b7df"
        },
        {
            "m_Id": "8f97be7ae6f443e8aec425d7b74acccc"
        },
        {
            "m_Id": "d2c70755685b411c83f3e0529cadcd08"
        },
        {
            "m_Id": "309f27ef831b49588b8ea1010b3dfb0c"
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
    "m_Type": "UnityEditor.ShaderGraph.BlockNode",
    "m_ObjectId": "514b8c6efc3e47fd902bca474d0cc1db",
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
            "m_Id": "cf013f2a6aae41a58ffe8f46d78fa164"
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
    "m_Type": "UnityEditor.Rendering.HighDefinition.ShaderGraph.SystemData",
    "m_ObjectId": "546b08f044a24526866df42794b9fbce",
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
    "inspectorFoldoutMask": 1
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.BlockNode",
    "m_ObjectId": "54ec4b8adf3c4753b2b238a4c6b8e0db",
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
            "m_Id": "a7550ff8e6144c26a84148327b96ebfe"
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "5654f95944614cbba01ad63d73ae3704",
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
    "m_Type": "UnityEditor.ShaderGraph.PositionMaterialSlot",
    "m_ObjectId": "58be808f21b54e7aa8d1bd3fbeca57d3",
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
    "m_Type": "UnityEditor.ShaderGraph.Vector3MaterialSlot",
    "m_ObjectId": "58d6922c3a9e4842bcf940af53b40f2e",
    "m_Id": 3,
    "m_DisplayName": "Tangent",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "Tangent",
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
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.LerpNode",
    "m_ObjectId": "58d751d66dbc479a8656d14d2baf579f",
    "m_Group": {
        "m_Id": "f3a763e910514d8eac4f8ba6f44f173d"
    },
    "m_Name": "Lerp",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -754.908935546875,
            "y": -736.5817260742188,
            "width": 132.654541015625,
            "height": 141.38177490234376
        }
    },
    "m_Slots": [
        {
            "m_Id": "30c98038f67f46af99cd1771c72f1180"
        },
        {
            "m_Id": "6c0efbe02b06452d843c01a2735bd539"
        },
        {
            "m_Id": "bc65fbf9379248bbb4dfd7249800afa4"
        },
        {
            "m_Id": "9f3af0d7b9604101a9982234f5175102"
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
    "m_Type": "UnityEditor.ShaderGraph.CustomInterpolatorNode",
    "m_ObjectId": "5af825dd918d42498b41a6d5b08d1afe",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "Color (Custom Interpolator)",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -914.6181030273438,
            "y": -247.8545684814453,
            "width": 200.727294921875,
            "height": 93.38198852539063
        }
    },
    "m_Slots": [
        {
            "m_Id": "05d8b7fe7fce4429ab506648945e2a4c"
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
    "customBlockNodeName": "Color",
    "serializedType": 4
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "5b970fe051ae4990a94e5d2351d77dc0",
    "m_Id": 0,
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "5cba05cf77414ca292da1fccaf3069d0",
    "m_Id": 1,
    "m_DisplayName": "B",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "B",
    "m_StageCapability": 3,
    "m_Value": {
        "x": 37.0,
        "y": 2.0,
        "z": 2.0,
        "w": 2.0
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
    "m_ObjectId": "5d69964f9d694dec91748b1adb3db86e",
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
    "m_ObjectId": "5dc6e70bb6f743ff85c004c9ec314439",
    "m_Id": 813535222,
    "m_DisplayName": "WindDirectionVariation",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "_WindDirectionVariation",
    "m_StageCapability": 3,
    "m_Value": 0.009999999776482582,
    "m_DefaultValue": 0.0,
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector3MaterialSlot",
    "m_ObjectId": "5e0ce1aad513427bb8bfb6bb0f5fc7d2",
    "m_Id": 3,
    "m_DisplayName": "Random",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "Random",
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
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "60514e366d1045aebb0adedbd718c544",
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
    "m_ObjectId": "61bc74541b9b45068ce68b89f4f8da38",
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
    "m_Type": "UnityEditor.ShaderGraph.SaturateNode",
    "m_ObjectId": "62dc9cf6a37b4fab9407e114176db70f",
    "m_Group": {
        "m_Id": "13f65a2ff0a44e2a8ddfd5645da51286"
    },
    "m_Name": "Saturate",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1714.90869140625,
            "y": 181.52723693847657,
            "width": 130.908935546875,
            "height": 93.38182067871094
        }
    },
    "m_Slots": [
        {
            "m_Id": "ab1d82bfa748496cae79b5360be4a864"
        },
        {
            "m_Id": "70ff08d89cee42d38e8a7f50121943b3"
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
    "m_Type": "UnityEditor.ShaderGraph.DivideNode",
    "m_ObjectId": "63d9682156f042468629ccab8669beb8",
    "m_Group": {
        "m_Id": "f3a763e910514d8eac4f8ba6f44f173d"
    },
    "m_Name": "Divide",
    "m_DrawState": {
        "m_Expanded": false,
        "m_Position": {
            "serializedVersion": "2",
            "x": -930.3270874023438,
            "y": -688.5817260742188,
            "width": 129.16351318359376,
            "height": 93.38177490234375
        }
    },
    "m_Slots": [
        {
            "m_Id": "8ff5febd6fa64e39bf4a800454d3828f"
        },
        {
            "m_Id": "5cba05cf77414ca292da1fccaf3069d0"
        },
        {
            "m_Id": "400adac3a76b47599a2b71fa078943c1"
        }
    ],
    "synonyms": [
        "division",
        "divided by"
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
    "m_SGVersion": 1,
    "m_Type": "UnityEditor.ShaderGraph.Internal.Vector1ShaderProperty",
    "m_ObjectId": "67ebfaffaee14928a711b29a096d8558",
    "m_Guid": {
        "m_GuidSerialized": "5406b404-220e-4a33-aa28-daf1195a1ca2"
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "6c0efbe02b06452d843c01a2735bd539",
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
    "m_SGVersion": 1,
    "m_Type": "UnityEditor.ShaderGraph.Internal.Vector1ShaderProperty",
    "m_ObjectId": "6c282f577aa64346b52e0035a910fc51",
    "m_Guid": {
        "m_GuidSerialized": "06dbd823-78b8-4b7c-9fd2-fb0510ed5ada"
    },
    "m_Name": "Wind Speed",
    "m_DefaultRefNameVersion": 1,
    "m_RefNameGeneratedByDisplayName": "Wind Speed",
    "m_DefaultReferenceName": "_Wind_Speed",
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
    "m_ObjectId": "6ce88dfc77204db194593f5fd7fc3ddf",
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "6d12e79e6bf146c0bb8042b4e1ebb639",
    "m_Id": 1,
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
    "m_ObjectId": "6f31cc5390f547cb8cae453527696ecc",
    "m_Id": 0,
    "m_DisplayName": "Edge",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "Edge",
    "m_StageCapability": 3,
    "m_Value": {
        "x": 0.05000000074505806,
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
    "m_Type": "UnityEditor.ShaderGraph.Vector3MaterialSlot",
    "m_ObjectId": "6f749dcae2384a50b345ad2b62c331ee",
    "m_Id": 866022913,
    "m_DisplayName": "TangentOS",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "_TangentOS",
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
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector3MaterialSlot",
    "m_ObjectId": "70965f904de243aba56cd0db72a78e26",
    "m_Id": -230761967,
    "m_DisplayName": "PositionOS",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "_PositionOS",
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
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "70ff08d89cee42d38e8a7f50121943b3",
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
    "m_Type": "UnityEditor.Rendering.HighDefinition.ShaderGraph.LightingData",
    "m_ObjectId": "72db6e234fec4e18a6a18d25e3cf6084",
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "7531f2ce3e9c453fb8a1a898c34e14d4",
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
    "m_Type": "UnityEditor.ShaderGraph.Vector3MaterialSlot",
    "m_ObjectId": "765690efa6f645869b732679bb87932c",
    "m_Id": 1759488296,
    "m_DisplayName": "NormalOS",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "_NormalOS",
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
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Matrix4MaterialSlot",
    "m_ObjectId": "76619a9c030e4cfb9a8aabd21c1079ce",
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
    "m_ObjectId": "768bac82b0684cd0a21ed8a814d35a50",
    "m_Group": {
        "m_Id": "13f65a2ff0a44e2a8ddfd5645da51286"
    },
    "m_Name": "Property",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -2516.9453125,
            "y": 128.29090881347657,
            "width": 229.52734375,
            "height": 32.29084777832031
        }
    },
    "m_Slots": [
        {
            "m_Id": "a668401eff8541d99e1fd794ca4ec56a"
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
        "m_Id": "e4b36eccf88744c4b9d4bf909634b12d"
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "7c05ed3125bb4196ab4d6dae9bc2aba9",
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
    "m_Type": "UnityEditor.ShaderGraph.Vector3MaterialSlot",
    "m_ObjectId": "7d6809f64ea04ae4aca8fe8f66e34ac9",
    "m_Id": 1244964050,
    "m_DisplayName": "PivotOffset",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "_PivotOffset",
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
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector3MaterialSlot",
    "m_ObjectId": "810edd91a9594e75803e095347e29386",
    "m_Id": 0,
    "m_DisplayName": "Out",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "Out",
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
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.Rendering.HighDefinition.ShaderGraph.HDLitData",
    "m_ObjectId": "8465d577c7804929a8b8170a5eed0502",
    "m_RayTracing": false,
    "m_MaterialType": 0,
    "m_RefractionModel": 0,
    "m_SSSTransmission": true,
    "m_EnergyConservingSpecular": true,
    "m_ClearCoat": false
}

{
    "m_SGVersion": 3,
    "m_Type": "UnityEditor.ShaderGraph.Internal.ColorShaderProperty",
    "m_ObjectId": "873a9506b4754285860a03988e3f7be5",
    "m_Guid": {
        "m_GuidSerialized": "77d57b83-6370-4e17-bd47-72a48b40b300"
    },
    "m_Name": "Blade Color #2",
    "m_DefaultRefNameVersion": 1,
    "m_RefNameGeneratedByDisplayName": "Blade Color #2",
    "m_DefaultReferenceName": "_Blade_Color_2",
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
        "r": 0.4630799889564514,
        "g": 0.7169811725616455,
        "b": 0.09131364524364472,
        "a": 1.0
    },
    "isMainColor": false,
    "m_ColorMode": 0
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.NormalMaterialSlot",
    "m_ObjectId": "8aa77bb58f764b6c84db6fab9876f027",
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
    "m_Type": "UnityEditor.ShaderGraph.Matrix4MaterialSlot",
    "m_ObjectId": "8f97be7ae6f443e8aec425d7b74acccc",
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
    "m_Type": "UnityEditor.ShaderGraph.TangentMaterialSlot",
    "m_ObjectId": "8f99e12eba1c47c1981d1e4d3cfbfcfd",
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
    "m_ObjectId": "8ff5febd6fa64e39bf4a800454d3828f",
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
    "m_Type": "UnityEditor.ShaderGraph.CategoryData",
    "m_ObjectId": "91406763260744f290cdc3f1b7c11881",
    "m_Name": "Mask",
    "m_ChildObjectList": [
        {
            "m_Id": "f9844473df9245f7a0d356a51494e8f1"
        },
        {
            "m_Id": "d65c38e554c14f9c91f43ec8804b6709"
        },
        {
            "m_Id": "e4b36eccf88744c4b9d4bf909634b12d"
        },
        {
            "m_Id": "3a65920d710b4cde9d51d6564dad0460"
        }
    ]
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Matrix4MaterialSlot",
    "m_ObjectId": "91c6f8489d8c4b9f974600e229997c36",
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
    "m_Type": "UnityEditor.ShaderGraph.BlockNode",
    "m_ObjectId": "9a28b2925e794fcfb3decb80d854bd3b",
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
            "m_Id": "61bc74541b9b45068ce68b89f4f8da38"
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
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "9a9dbc24b1af43f0bcc75fb7df12e0e7",
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
    "m_Type": "UnityEditor.ShaderGraph.ColorRGBMaterialSlot",
    "m_ObjectId": "9c0bf51598424587a0daf9152d87af99",
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
    "m_ObjectId": "9cce27f1b32a4343813f8e5777b7e9a3",
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
    "m_Type": "UnityEditor.ShaderGraph.Vector3MaterialSlot",
    "m_ObjectId": "9ec5c0a54c404304b01233b11418bc43",
    "m_Id": 1,
    "m_DisplayName": "Position",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "Position",
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
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "9f3af0d7b9604101a9982234f5175102",
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
    "m_ObjectId": "a629abe92aed4420a4da45aaf76fabb1",
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
    "m_Type": "UnityEditor.ShaderGraph.Matrix4MaterialSlot",
    "m_ObjectId": "a668401eff8541d99e1fd794ca4ec56a",
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "a6bd0e82aa3a4e4186c35d0395125897",
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "a6ce88cdd7374778bc742b3e746ebd84",
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
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "a7550ff8e6144c26a84148327b96ebfe",
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
    "m_Type": "UnityEditor.ShaderGraph.PropertyNode",
    "m_ObjectId": "a7bf99e3e3cf4540bc6bd38a6aaab41f",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "Property",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1286.3997802734375,
            "y": -72.43628692626953,
            "width": 186.763427734375,
            "height": 33.16361999511719
        }
    },
    "m_Slots": [
        {
            "m_Id": "e471523890274b85ae65428ed3bea18c"
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
        "m_Id": "f9844473df9245f7a0d356a51494e8f1"
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector2MaterialSlot",
    "m_ObjectId": "a9b18ea29b234501bacc0e475dceff58",
    "m_Id": 1,
    "m_DisplayName": "WindDirection",
    "m_SlotType": 1,
    "m_Hidden": false,
    "m_ShaderOutputName": "WindDirection",
    "m_StageCapability": 3,
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
    "m_ObjectId": "ab1d82bfa748496cae79b5360be4a864",
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
    "m_Type": "UnityEditor.ShaderGraph.PropertyNode",
    "m_ObjectId": "b17d9045f0a44cc8ba01c677192340fe",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "Property",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -208.58193969726563,
            "y": -59.3454704284668,
            "width": 117.81831359863281,
            "height": 33.16362380981445
        }
    },
    "m_Slots": [
        {
            "m_Id": "00b0b14086b34ff39e8b6441721d8266"
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
        "m_Id": "67ebfaffaee14928a711b29a096d8558"
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.SaturateNode",
    "m_ObjectId": "b1a2ecfe1d1842778d5653a46a7b1782",
    "m_Group": {
        "m_Id": "3da395f03a48462e987588841533f628"
    },
    "m_Name": "Saturate",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1906.036376953125,
            "y": -1254.1092529296875,
            "width": 130.9091796875,
            "height": 93.3819580078125
        }
    },
    "m_Slots": [
        {
            "m_Id": "9cce27f1b32a4343813f8e5777b7e9a3"
        },
        {
            "m_Id": "bfffdb4bbc68497e88040251b5b9a9da"
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
    "m_ObjectId": "b209ffc21b8944e2841ddb2a15fa3d49",
    "m_Id": 1153005278,
    "m_DisplayName": "WindDirection",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "_WindDirection",
    "m_StageCapability": 3,
    "m_Value": 124.0,
    "m_DefaultValue": 0.0,
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "b2fd31004c2b42efa41249d113092392",
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "b8022e687420497a9c7ef889d7613402",
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "bc65fbf9379248bbb4dfd7249800afa4",
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "bfffdb4bbc68497e88040251b5b9a9da",
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
    "m_ObjectId": "c00b3da43c8443a9a80df8475d4de032",
    "m_Id": 0,
    "m_DisplayName": "Smoothness",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "Smoothness",
    "m_StageCapability": 2,
    "m_Value": 0.0,
    "m_DefaultValue": 0.5,
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.AddNode",
    "m_ObjectId": "c1cf3158744d4822974d88d98d719275",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "Add",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -623.9999389648438,
            "y": -136.1453399658203,
            "width": 132.654541015625,
            "height": 117.81813049316406
        }
    },
    "m_Slots": [
        {
            "m_Id": "5654f95944614cbba01ad63d73ae3704"
        },
        {
            "m_Id": "7c05ed3125bb4196ab4d6dae9bc2aba9"
        },
        {
            "m_Id": "f038c28cf427479595b014b792de669c"
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
    "m_ObjectId": "c22d6a90c6f3411e8d024ee4197765d2",
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
    "m_Type": "UnityEditor.ShaderGraph.CategoryData",
    "m_ObjectId": "c2511a21eac34868b221b392d5ad3a5a",
    "m_Name": "Base",
    "m_ChildObjectList": [
        {
            "m_Id": "048a03ba0e924ceabb4ab1404303cdf4"
        },
        {
            "m_Id": "873a9506b4754285860a03988e3f7be5"
        },
        {
            "m_Id": "67ebfaffaee14928a711b29a096d8558"
        },
        {
            "m_Id": "d36e0a88c81b4f669c4bc6d70b857cbc"
        }
    ]
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "c30648de1c6448c483c4e75f57c6178b",
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
    "m_Type": "UnityEditor.ShaderGraph.AddNode",
    "m_ObjectId": "c3b10d55feaf4b9baefa4948a8eaed75",
    "m_Group": {
        "m_Id": "13f65a2ff0a44e2a8ddfd5645da51286"
    },
    "m_Name": "Add",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1883.34521484375,
            "y": 181.52723693847657,
            "width": 129.16357421875,
            "height": 117.81825256347656
        }
    },
    "m_Slots": [
        {
            "m_Id": "3599b61ddf444a73bef1bf92c403c8d2"
        },
        {
            "m_Id": "0aafc71f211c4de180ebfd11069ac310"
        },
        {
            "m_Id": "b8022e687420497a9c7ef889d7613402"
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "c631b52e3abe4ad98e68acbc81f8e391",
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
    "m_Type": "UnityEditor.ShaderGraph.Vector4MaterialSlot",
    "m_ObjectId": "c6ea6534473649d4a6aa2da354caa25f",
    "m_Id": 0,
    "m_DisplayName": "Blade Color #2",
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
    "m_Type": "UnityEditor.ShaderGraph.BlockNode",
    "m_ObjectId": "c867716e88ef40509e68b8b666236234",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "VertexDescription.CustomInterpolator",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -322.0364074707031,
            "y": -170.18182373046876,
            "width": 199.85447692871095,
            "height": 41.01817321777344
        }
    },
    "m_Slots": [
        {
            "m_Id": "e14bbd69f51f4d6ab549ffc2b0a1c5e1"
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
    "m_SerializedDescriptor": "VertexDescription.Color#4"
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "c8f948178fa1428792cc8f18b327f407",
    "m_Id": 111500930,
    "m_DisplayName": "WindIntensity",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "_WindIntensity",
    "m_StageCapability": 3,
    "m_Value": 0.20000000298023225,
    "m_DefaultValue": 0.0,
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "cd62d0a238024113b49b6b28a5669972",
    "m_Id": 0,
    "m_DisplayName": "Alpha Clip Threshold",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "AlphaClipThreshold",
    "m_StageCapability": 2,
    "m_Value": 0.5,
    "m_DefaultValue": 0.5,
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.NormalMaterialSlot",
    "m_ObjectId": "cf013f2a6aae41a58ffe8f46d78fa164",
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
    "m_Type": "UnityEditor.ShaderGraph.MultiplyNode",
    "m_ObjectId": "cff561f8195f49188db426fdc084a6ce",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "Multiply",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1219.1998291015625,
            "y": -1251.49072265625,
            "width": 129.16357421875,
            "height": 117.8182373046875
        }
    },
    "m_Slots": [
        {
            "m_Id": "c631b52e3abe4ad98e68acbc81f8e391"
        },
        {
            "m_Id": "1c2928d582c44cbca053cc0841850bf1"
        },
        {
            "m_Id": "5d69964f9d694dec91748b1adb3db86e"
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
    "m_Type": "UnityEditor.ShaderGraph.PropertyNode",
    "m_ObjectId": "d254ba2921d340f982bfbcfaf5916ad3",
    "m_Group": {
        "m_Id": "f3a763e910514d8eac4f8ba6f44f173d"
    },
    "m_Name": "Property",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -955.63623046875,
            "y": -802.9089965820313,
            "width": 154.47265625,
            "height": 33.16363525390625
        }
    },
    "m_Slots": [
        {
            "m_Id": "ecf905369369401e90b146c9b364babf"
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
        "m_Id": "048a03ba0e924ceabb4ab1404303cdf4"
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "d2c70755685b411c83f3e0529cadcd08",
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
    "m_SGVersion": 1,
    "m_Type": "UnityEditor.ShaderGraph.Internal.Vector1ShaderProperty",
    "m_ObjectId": "d36e0a88c81b4f669c4bc6d70b857cbc",
    "m_Guid": {
        "m_GuidSerialized": "8b1c5fa8-0006-42bb-aafc-24f3bba2ae55"
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
    "m_SGVersion": 1,
    "m_Type": "UnityEditor.ShaderGraph.Internal.Vector1ShaderProperty",
    "m_ObjectId": "d65c38e554c14f9c91f43ec8804b6709",
    "m_Guid": {
        "m_GuidSerialized": "8170f973-cf1a-49a5-b784-c09d7571ab24"
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
    "m_Type": "AmazingAssets.DynamicWireframeShaderGenerator.Editor.DynamicMaskNode",
    "m_ObjectId": "d8cbb946b52f4b01a4d3fd3bc3ea9de1",
    "m_Group": {
        "m_Id": "13f65a2ff0a44e2a8ddfd5645da51286"
    },
    "m_Name": "Dynamic Mask",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -2176.58154296875,
            "y": 83.78182983398438,
            "width": 223.41796875,
            "height": 153.59991455078126
        }
    },
    "m_Slots": [
        {
            "m_Id": "0892f95b1fe940f6a4a3131798064ec7"
        },
        {
            "m_Id": "76619a9c030e4cfb9a8aabd21c1079ce"
        },
        {
            "m_Id": "6ce88dfc77204db194593f5fd7fc3ddf"
        },
        {
            "m_Id": "47ebd890bf8440889bad5f9ce0c7529d"
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
    "m_ObjectId": "dbcc12976b2c4eb4a63c1284e5f1d305",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "Property",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1826.6181640625,
            "y": -1608.4364013671875,
            "width": 139.6363525390625,
            "height": 32.2908935546875
        }
    },
    "m_Slots": [
        {
            "m_Id": "05293329dd0d4c71bef05e310f3acd3b"
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
        "m_Id": "6c282f577aa64346b52e0035a910fc51"
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.PositionMaterialSlot",
    "m_ObjectId": "de485ad92c0b44a6a9d022a707c5b7df",
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
    "m_Type": "UnityEditor.ShaderGraph.CategoryData",
    "m_ObjectId": "dee1883a50ff4c19bb6dceceb2a6b1d9",
    "m_Name": "",
    "m_ChildObjectList": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector4MaterialSlot",
    "m_ObjectId": "e14bbd69f51f4d6ab549ffc2b0a1c5e1",
    "m_Id": 0,
    "m_DisplayName": "Color",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "Color",
    "m_StageCapability": 1,
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
    "m_Type": "UnityEditor.ShaderGraph.Matrix4MaterialSlot",
    "m_ObjectId": "e3153be5e2a749f3b1b7ffd73fa89d0a",
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
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "e3284561089540dab3269b6daf80829f",
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
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "e3bbbbed776c4efd8a09b351c4252a63",
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
    "m_Type": "AmazingAssets.DynamicWireframeShaderGenerator.Editor.DynamicMaskNode",
    "m_ObjectId": "e413c723ed49470ba4eca3bcf6362548",
    "m_Group": {
        "m_Id": "13f65a2ff0a44e2a8ddfd5645da51286"
    },
    "m_Name": "Dynamic Mask",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -2176.58154296875,
            "y": 298.47271728515627,
            "width": 223.41796875,
            "height": 153.5999755859375
        }
    },
    "m_Slots": [
        {
            "m_Id": "f05e342e67b94469bf34c6a97daf04fe"
        },
        {
            "m_Id": "f47b8aa689a74e36ab9ca6618474d8db"
        },
        {
            "m_Id": "e5c11654c23642a78ee472b74d4a8add"
        },
        {
            "m_Id": "33e5700e48444a8b96640f2d41a1d697"
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
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "e471523890274b85ae65428ed3bea18c",
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
    "m_SGVersion": 1,
    "m_Type": "UnityEditor.ShaderGraph.Matrix4ShaderProperty",
    "m_ObjectId": "e4b36eccf88744c4b9d4bf909634b12d",
    "m_Guid": {
        "m_GuidSerialized": "1274da01-6d8e-466d-a22a-8067074e5f80"
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
    "m_Type": "UnityEditor.ShaderGraph.Matrix4MaterialSlot",
    "m_ObjectId": "e4b8b3642a804c5ca0b9b71a92b5d539",
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "e5bff04c2f1b4bcbb95d3f751956d596",
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
    "m_ObjectId": "e5c11654c23642a78ee472b74d4a8add",
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
    "m_ObjectId": "e6333f42f10045b8874ca797f7698f1d",
    "m_Group": {
        "m_Id": "3da395f03a48462e987588841533f628"
    },
    "m_Name": "Property",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -2708.07275390625,
            "y": -1307.345458984375,
            "width": 229.52734375,
            "height": 32.2908935546875
        }
    },
    "m_Slots": [
        {
            "m_Id": "e3153be5e2a749f3b1b7ffd73fa89d0a"
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
        "m_Id": "e4b36eccf88744c4b9d4bf909634b12d"
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.BlockNode",
    "m_ObjectId": "e740624f4f8942db89b2489b1391ba05",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "SurfaceDescription.Smoothness",
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
            "m_Id": "c00b3da43c8443a9a80df8475d4de032"
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
    "m_Type": "AmazingAssets.WireframeShaderGenerator.Editor.WireframeRendererNode",
    "m_ObjectId": "e9a775fd60fa4b0791559409a707b984",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "Wireframe Renderer",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1013.236328125,
            "y": -110.8363265991211,
            "width": 315.92724609375,
            "height": 267.9272155761719
        }
    },
    "m_Slots": [
        {
            "m_Id": "49e6efd265f34169bd778ff3c0f7850e"
        },
        {
            "m_Id": "24079fed768340df9d2fb73d801a70e9"
        },
        {
            "m_Id": "0379e02c8d1d4907b3514185f10db02c"
        },
        {
            "m_Id": "a629abe92aed4420a4da45aaf76fabb1"
        },
        {
            "m_Id": "236ce2f67e574255b1a7c2dab57e6981"
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
    "m_AntiAliasing": 0.20000000298023225,
    "m_RenderInScreenSpace": false,
    "m_readFrom": 3
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector4MaterialSlot",
    "m_ObjectId": "ecf905369369401e90b146c9b364babf",
    "m_Id": 0,
    "m_DisplayName": "Blade Color #1",
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
    "m_Type": "UnityEditor.Rendering.HighDefinition.ShaderGraph.HDLitSubTarget",
    "m_ObjectId": "ed7b87d44abc4d899259f588cbb4b596"
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "f038c28cf427479595b014b792de669c",
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
    "m_Type": "UnityEditor.ShaderGraph.PositionMaterialSlot",
    "m_ObjectId": "f05e342e67b94469bf34c6a97daf04fe",
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
    "m_Type": "UnityEditor.ShaderGraph.GroupData",
    "m_ObjectId": "f3a763e910514d8eac4f8ba6f44f173d",
    "m_Title": "Blade Color Variation",
    "m_Position": {
        "x": -1186.9088134765625,
        "y": -860.5089111328125
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "f3bbaa9daeba4f8ea6d3436447744e6f",
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
    "m_Type": "UnityEditor.ShaderGraph.Matrix4MaterialSlot",
    "m_ObjectId": "f47b8aa689a74e36ab9ca6618474d8db",
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
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "f562379bfa2940fda3f595284919991f",
    "m_Id": -1955643226,
    "m_DisplayName": "WindSpeed",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "_WindSpeed",
    "m_StageCapability": 3,
    "m_Value": 5.0,
    "m_DefaultValue": 0.0,
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.BlockNode",
    "m_ObjectId": "f8a3807160984bb6832806d5ffa9756e",
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
            "m_Id": "376ed0e33708456c9ef56cd463308672"
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
    "m_Type": "UnityEditor.ShaderGraph.Internal.Vector1ShaderProperty",
    "m_ObjectId": "f9844473df9245f7a0d356a51494e8f1",
    "m_Guid": {
        "m_GuidSerialized": "f52fd3ba-01f7-4cca-8423-a282223f42c6"
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
    "m_Type": "UnityEditor.ShaderGraph.Vector3MaterialSlot",
    "m_ObjectId": "fc2e5e8109c2478a943d851cb7068c41",
    "m_Id": 408528608,
    "m_DisplayName": "AxisOrientation",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "_AxisOrientation",
    "m_StageCapability": 3,
    "m_Value": {
        "x": -1.0,
        "y": 1.0,
        "z": 1.0
    },
    "m_DefaultValue": {
        "x": 0.0,
        "y": 0.0,
        "z": 0.0
    },
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "fe96e00d2ad64904bc055f5c5d6f49de",
    "m_Id": -928934882,
    "m_DisplayName": "PerBladeWindIntensityVariation",
    "m_SlotType": 0,
    "m_Hidden": false,
    "m_ShaderOutputName": "_PerBladeWindIntensityVariation",
    "m_StageCapability": 3,
    "m_Value": 0.10000000149011612,
    "m_DefaultValue": 0.0,
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.SubGraphNode",
    "m_ObjectId": "ff86d4ba056645ada8ec26ea9dfc3d6f",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "BillboardCylindrical",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -555.0543823242188,
            "y": -1475.7818603515625,
            "width": 229.5272216796875,
            "height": 233.018310546875
        }
    },
    "m_Slots": [
        {
            "m_Id": "70965f904de243aba56cd0db72a78e26"
        },
        {
            "m_Id": "765690efa6f645869b732679bb87932c"
        },
        {
            "m_Id": "6f749dcae2384a50b345ad2b62c331ee"
        },
        {
            "m_Id": "7d6809f64ea04ae4aca8fe8f66e34ac9"
        },
        {
            "m_Id": "fc2e5e8109c2478a943d851cb7068c41"
        },
        {
            "m_Id": "379a2ba4fddc4e9f851bf0666afa8a7e"
        },
        {
            "m_Id": "9ec5c0a54c404304b01233b11418bc43"
        },
        {
            "m_Id": "42191fa9071b49cf9349b7232368202c"
        },
        {
            "m_Id": "58d6922c3a9e4842bcf940af53b40f2e"
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
    "m_SerializedSubGraph": "{\n    \"subGraph\": {\n        \"fileID\": -5475051401550479605,\n        \"guid\": \"89f890aa3ee0e19418c398fb74cb9ab9\",\n        \"type\": 3\n    }\n}",
    "m_PropertyGuids": [
        "5694f6a4-af03-47a1-90cd-c3f6264ec815",
        "248f25b0-3d6a-477d-8929-ea007b98c70b",
        "f55b78d5-1032-4df6-9709-e7657117d4ee",
        "1e0ebe26-ea4a-459f-a490-c6a31a6063b2",
        "002f068e-6b3b-4e7d-af63-deb2faa8d5e4",
        "dd391417-04e7-4649-86d1-e42155e34864"
    ],
    "m_PropertyIds": [
        -230761967,
        1759488296,
        866022913,
        1244964050,
        408528608,
        -555998685
    ],
    "m_Dropdowns": [
        "_OutputSpace"
    ],
    "m_DropdownSelectedEntries": [
        "Object"
    ]
}


ShaderGraphBody_End*/

// Dynamic Wireframe Shader <https://u3d.as/3WyY>
// Copyright (c) Amazing Assets <https://amazingassets.world>

Shader "Amazing Assets/Dynamic Wireframe Shader/Examples/Scanner/Grid (Dynamic Wireframe)"
{
Properties
{
[KeywordEnum(Triangle, Quad)] _Wireframe_Shader_Shape("Wireframe Shape", int) = 0
[KeywordEnum(Default, Normalized, Screen Space)] _Wireframe_Shader_Style("Wireframe Style", int) = 0

_Wireframe_Thickness("Wireframe Thickness", Range(0, 1)) = 0.01
_Wireframe_Anti_aliasing("Wireframe Anti-aliasing", Range(0, 1)) = 0.2
[HDR]_Wireframe_Color("Wireframe Color", Color) = (1, 1, 1, 1)
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
    Name "Universal Forward"
    Tags
    {
        "LightMode" = "UniversalForward"
    }

// Render State
Cull Off
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
float4x4 _WireframeShaderMaskData;
float4 _Wireframe_Color;
float4 _Scanner_Glow_Color;
float _Wireframe_Thickness;
float _Wireframe_Anti_aliasing;
float _Scanner_Glow_Emission;
CBUFFER_END


// Object and Global properties

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

void Unity_Multiply_float_float(float A, float B, out float Out)
{
Out = A * B;
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

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
{
Out = A * B;
}

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
float4 _Property_f516815bafdc4179b6acf74539139f7e_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Wireframe_Color) : _Wireframe_Color;
float4 _Property_26ccfbc457ff4bfcb70ae50522fe92cd_Out_0_Vector4 = _Scanner_Glow_Color;
float _Property_a6b8ca586ad44ca0a6b852fcbe20d2d4_Out_0_Float = _Scanner_Glow_Emission;
float _Multiply_6929e6947fe04329b8ffedc394efb941_Out_2_Float;
Unity_Multiply_float_float(_Property_a6b8ca586ad44ca0a6b852fcbe20d2d4_Out_0_Float, _Property_a6b8ca586ad44ca0a6b852fcbe20d2d4_Out_0_Float, _Multiply_6929e6947fe04329b8ffedc394efb941_Out_2_Float);
float4x4 _Property_c2fcbed1c8b9408fb9e6665d295dd052_Out_0_Matrix4 = _WireframeShaderMaskData;
float _DynamicMask_a54489dc94d7460e85cc740e45ba413a_Out_3_Float;
WireframeShaderDynamicMaskPlane_float(IN.WorldSpacePosition, _Property_c2fcbed1c8b9408fb9e6665d295dd052_Out_0_Matrix4, 0, _DynamicMask_a54489dc94d7460e85cc740e45ba413a_Out_3_Float);
float _OneMinus_cdea28730e414b8d9de9b1a9bcc87cd4_Out_1_Float;
Unity_OneMinus_float(_DynamicMask_a54489dc94d7460e85cc740e45ba413a_Out_3_Float, _OneMinus_cdea28730e414b8d9de9b1a9bcc87cd4_Out_1_Float);
float _Multiply_85529825e2b241e89d7701edfbd37a4f_Out_2_Float;
Unity_Multiply_float_float(_DynamicMask_a54489dc94d7460e85cc740e45ba413a_Out_3_Float, _OneMinus_cdea28730e414b8d9de9b1a9bcc87cd4_Out_1_Float, _Multiply_85529825e2b241e89d7701edfbd37a4f_Out_2_Float);
float _Multiply_62b70451cfcf4bf081790341501fab0a_Out_2_Float;
Unity_Multiply_float_float(_Multiply_85529825e2b241e89d7701edfbd37a4f_Out_2_Float, _Multiply_85529825e2b241e89d7701edfbd37a4f_Out_2_Float, _Multiply_62b70451cfcf4bf081790341501fab0a_Out_2_Float);
float _Multiply_e3cd280f83414d31ba19fc780c18abc9_Out_2_Float;
Unity_Multiply_float_float(_Multiply_6929e6947fe04329b8ffedc394efb941_Out_2_Float, _Multiply_62b70451cfcf4bf081790341501fab0a_Out_2_Float, _Multiply_e3cd280f83414d31ba19fc780c18abc9_Out_2_Float);
float4 _Multiply_1460998fb88549c8b11189ec8d393414_Out_2_Vector4;
Unity_Multiply_float4_float4(_Property_26ccfbc457ff4bfcb70ae50522fe92cd_Out_0_Vector4, (_Multiply_e3cd280f83414d31ba19fc780c18abc9_Out_2_Float.xxxx), _Multiply_1460998fb88549c8b11189ec8d393414_Out_2_Vector4);
float4 _Property_3f2bd1c27f3e48a5afce56efb01d29df_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Wireframe_Color) : _Wireframe_Color;
float _Property_1dc4788b9eca4069baa399efa4413298_Out_0_Float = _Wireframe_Thickness;
float _Property_8b57c7d9cbef4037966ba71e85a6a06c_Out_0_Float = _Wireframe_Anti_aliasing;
float _WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_Wireframe_3_Float;
float2 _WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_BarycentricUV_4_Vector2;
WireframeRenderer_float(IN.barycentric.xyz, max(0, _Property_1dc4788b9eca4069baa399efa4413298_Out_0_Float), max(0, _Property_8b57c7d9cbef4037966ba71e85a6a06c_Out_0_Float), 0, _WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_Wireframe_3_Float, _WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_BarycentricUV_4_Vector2);
float _Multiply_0cf02108ee5e4f618fd9a5042251110e_Out_2_Float;
Unity_Multiply_float_float(_WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_Wireframe_3_Float, _DynamicMask_a54489dc94d7460e85cc740e45ba413a_Out_3_Float, _Multiply_0cf02108ee5e4f618fd9a5042251110e_Out_2_Float);
float4 _Lerp_2740b953228343e3b052c6064772bba3_Out_3_Vector4;
Unity_Lerp_float4(_Multiply_1460998fb88549c8b11189ec8d393414_Out_2_Vector4, _Property_3f2bd1c27f3e48a5afce56efb01d29df_Out_0_Vector4, (_Multiply_0cf02108ee5e4f618fd9a5042251110e_Out_2_Float.xxxx), _Lerp_2740b953228343e3b052c6064772bba3_Out_3_Vector4);
surface.BaseColor = (_Property_f516815bafdc4179b6acf74539139f7e_Out_0_Vector4.xyz);
surface.NormalTS = IN.TangentSpaceNormal;
surface.Emission = (_Lerp_2740b953228343e3b052c6064772bba3_Out_3_Vector4.xyz);
surface.Metallic = 0;
surface.Smoothness = 0.1;
surface.Occlusion = 1;
surface.Alpha = _Multiply_0cf02108ee5e4f618fd9a5042251110e_Out_2_Float;
surface.AlphaClipThreshold = 0.01;
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
Cull Off
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
float4x4 _WireframeShaderMaskData;
float4 _Wireframe_Color;
float4 _Scanner_Glow_Color;
float _Wireframe_Thickness;
float _Wireframe_Anti_aliasing;
float _Scanner_Glow_Emission;
CBUFFER_END


// Object and Global properties

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

void Unity_Multiply_float_float(float A, float B, out float Out)
{
Out = A * B;
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

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
{
Out = A * B;
}

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
float4 _Property_f516815bafdc4179b6acf74539139f7e_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Wireframe_Color) : _Wireframe_Color;
float4 _Property_26ccfbc457ff4bfcb70ae50522fe92cd_Out_0_Vector4 = _Scanner_Glow_Color;
float _Property_a6b8ca586ad44ca0a6b852fcbe20d2d4_Out_0_Float = _Scanner_Glow_Emission;
float _Multiply_6929e6947fe04329b8ffedc394efb941_Out_2_Float;
Unity_Multiply_float_float(_Property_a6b8ca586ad44ca0a6b852fcbe20d2d4_Out_0_Float, _Property_a6b8ca586ad44ca0a6b852fcbe20d2d4_Out_0_Float, _Multiply_6929e6947fe04329b8ffedc394efb941_Out_2_Float);
float4x4 _Property_c2fcbed1c8b9408fb9e6665d295dd052_Out_0_Matrix4 = _WireframeShaderMaskData;
float _DynamicMask_a54489dc94d7460e85cc740e45ba413a_Out_3_Float;
WireframeShaderDynamicMaskPlane_float(IN.WorldSpacePosition, _Property_c2fcbed1c8b9408fb9e6665d295dd052_Out_0_Matrix4, 0, _DynamicMask_a54489dc94d7460e85cc740e45ba413a_Out_3_Float);
float _OneMinus_cdea28730e414b8d9de9b1a9bcc87cd4_Out_1_Float;
Unity_OneMinus_float(_DynamicMask_a54489dc94d7460e85cc740e45ba413a_Out_3_Float, _OneMinus_cdea28730e414b8d9de9b1a9bcc87cd4_Out_1_Float);
float _Multiply_85529825e2b241e89d7701edfbd37a4f_Out_2_Float;
Unity_Multiply_float_float(_DynamicMask_a54489dc94d7460e85cc740e45ba413a_Out_3_Float, _OneMinus_cdea28730e414b8d9de9b1a9bcc87cd4_Out_1_Float, _Multiply_85529825e2b241e89d7701edfbd37a4f_Out_2_Float);
float _Multiply_62b70451cfcf4bf081790341501fab0a_Out_2_Float;
Unity_Multiply_float_float(_Multiply_85529825e2b241e89d7701edfbd37a4f_Out_2_Float, _Multiply_85529825e2b241e89d7701edfbd37a4f_Out_2_Float, _Multiply_62b70451cfcf4bf081790341501fab0a_Out_2_Float);
float _Multiply_e3cd280f83414d31ba19fc780c18abc9_Out_2_Float;
Unity_Multiply_float_float(_Multiply_6929e6947fe04329b8ffedc394efb941_Out_2_Float, _Multiply_62b70451cfcf4bf081790341501fab0a_Out_2_Float, _Multiply_e3cd280f83414d31ba19fc780c18abc9_Out_2_Float);
float4 _Multiply_1460998fb88549c8b11189ec8d393414_Out_2_Vector4;
Unity_Multiply_float4_float4(_Property_26ccfbc457ff4bfcb70ae50522fe92cd_Out_0_Vector4, (_Multiply_e3cd280f83414d31ba19fc780c18abc9_Out_2_Float.xxxx), _Multiply_1460998fb88549c8b11189ec8d393414_Out_2_Vector4);
float4 _Property_3f2bd1c27f3e48a5afce56efb01d29df_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Wireframe_Color) : _Wireframe_Color;
float _Property_1dc4788b9eca4069baa399efa4413298_Out_0_Float = _Wireframe_Thickness;
float _Property_8b57c7d9cbef4037966ba71e85a6a06c_Out_0_Float = _Wireframe_Anti_aliasing;
float _WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_Wireframe_3_Float;
float2 _WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_BarycentricUV_4_Vector2;
WireframeRenderer_float(IN.barycentric.xyz, max(0, _Property_1dc4788b9eca4069baa399efa4413298_Out_0_Float), max(0, _Property_8b57c7d9cbef4037966ba71e85a6a06c_Out_0_Float), 0, _WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_Wireframe_3_Float, _WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_BarycentricUV_4_Vector2);
float _Multiply_0cf02108ee5e4f618fd9a5042251110e_Out_2_Float;
Unity_Multiply_float_float(_WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_Wireframe_3_Float, _DynamicMask_a54489dc94d7460e85cc740e45ba413a_Out_3_Float, _Multiply_0cf02108ee5e4f618fd9a5042251110e_Out_2_Float);
float4 _Lerp_2740b953228343e3b052c6064772bba3_Out_3_Vector4;
Unity_Lerp_float4(_Multiply_1460998fb88549c8b11189ec8d393414_Out_2_Vector4, _Property_3f2bd1c27f3e48a5afce56efb01d29df_Out_0_Vector4, (_Multiply_0cf02108ee5e4f618fd9a5042251110e_Out_2_Float.xxxx), _Lerp_2740b953228343e3b052c6064772bba3_Out_3_Vector4);
surface.BaseColor = (_Property_f516815bafdc4179b6acf74539139f7e_Out_0_Vector4.xyz);
surface.NormalTS = IN.TangentSpaceNormal;
surface.Emission = (_Lerp_2740b953228343e3b052c6064772bba3_Out_3_Vector4.xyz);
surface.Metallic = 0;
surface.Smoothness = 0.1;
surface.Occlusion = 1;
surface.Alpha = _Multiply_0cf02108ee5e4f618fd9a5042251110e_Out_2_Float;
surface.AlphaClipThreshold = 0.01;
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
#pragma target 5.0
#pragma multi_compile_instancing
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
#pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
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
#define VARYINGS_NEED_TEXCOORD0
#define VARYINGS_NEED_TEXCOORD1
#define VARYINGS_NEED_TEXCOORD2
#define VARYINGS_NEED_TEXCOORD3
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
float3 barycentric : INTERP6;
 float4 positionCS : SV_POSITION;
 float4 texCoord0 : INTERP0;
 float4 texCoord1 : INTERP1;
 float4 texCoord2 : INTERP2;
 float4 texCoord3 : INTERP3;
 float3 positionWS : INTERP4;
 float3 normalWS : INTERP5;
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
output.texCoord0 = input.texCoord0.xyzw;
output.texCoord1 = input.texCoord1.xyzw;
output.texCoord2 = input.texCoord2.xyzw;
output.texCoord3 = input.texCoord3.xyzw;
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
float4x4 _WireframeShaderMaskData;
float4 _Wireframe_Color;
float4 _Scanner_Glow_Color;
float _Wireframe_Thickness;
float _Wireframe_Anti_aliasing;
float _Scanner_Glow_Emission;
CBUFFER_END


// Object and Global properties

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
float _Property_1dc4788b9eca4069baa399efa4413298_Out_0_Float = _Wireframe_Thickness;
float _Property_8b57c7d9cbef4037966ba71e85a6a06c_Out_0_Float = _Wireframe_Anti_aliasing;
float _WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_Wireframe_3_Float;
float2 _WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_BarycentricUV_4_Vector2;
WireframeRenderer_float(IN.barycentric.xyz, max(0, _Property_1dc4788b9eca4069baa399efa4413298_Out_0_Float), max(0, _Property_8b57c7d9cbef4037966ba71e85a6a06c_Out_0_Float), 0, _WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_Wireframe_3_Float, _WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_BarycentricUV_4_Vector2);
float4x4 _Property_c2fcbed1c8b9408fb9e6665d295dd052_Out_0_Matrix4 = _WireframeShaderMaskData;
float _DynamicMask_a54489dc94d7460e85cc740e45ba413a_Out_3_Float;
WireframeShaderDynamicMaskPlane_float(IN.WorldSpacePosition, _Property_c2fcbed1c8b9408fb9e6665d295dd052_Out_0_Matrix4, 0, _DynamicMask_a54489dc94d7460e85cc740e45ba413a_Out_3_Float);
float _Multiply_0cf02108ee5e4f618fd9a5042251110e_Out_2_Float;
Unity_Multiply_float_float(_WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_Wireframe_3_Float, _DynamicMask_a54489dc94d7460e85cc740e45ba413a_Out_3_Float, _Multiply_0cf02108ee5e4f618fd9a5042251110e_Out_2_Float);
surface.Alpha = _Multiply_0cf02108ee5e4f618fd9a5042251110e_Out_2_Float;
surface.AlphaClipThreshold = 0.01;
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
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

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
    Name "DepthOnly"
    Tags
    {
        "LightMode" = "DepthOnly"
    }

// Render State
Cull Off
ZTest LEqual
ZWrite On
ColorMask R

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM

// Pragmas
#pragma target 5.0
#pragma multi_compile_instancing
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
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_TEXCOORD0
#define VARYINGS_NEED_TEXCOORD1
#define VARYINGS_NEED_TEXCOORD2
#define VARYINGS_NEED_TEXCOORD3
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
float4x4 _WireframeShaderMaskData;
float4 _Wireframe_Color;
float4 _Scanner_Glow_Color;
float _Wireframe_Thickness;
float _Wireframe_Anti_aliasing;
float _Scanner_Glow_Emission;
CBUFFER_END


// Object and Global properties

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
float _Property_1dc4788b9eca4069baa399efa4413298_Out_0_Float = _Wireframe_Thickness;
float _Property_8b57c7d9cbef4037966ba71e85a6a06c_Out_0_Float = _Wireframe_Anti_aliasing;
float _WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_Wireframe_3_Float;
float2 _WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_BarycentricUV_4_Vector2;
WireframeRenderer_float(IN.barycentric.xyz, max(0, _Property_1dc4788b9eca4069baa399efa4413298_Out_0_Float), max(0, _Property_8b57c7d9cbef4037966ba71e85a6a06c_Out_0_Float), 0, _WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_Wireframe_3_Float, _WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_BarycentricUV_4_Vector2);
float4x4 _Property_c2fcbed1c8b9408fb9e6665d295dd052_Out_0_Matrix4 = _WireframeShaderMaskData;
float _DynamicMask_a54489dc94d7460e85cc740e45ba413a_Out_3_Float;
WireframeShaderDynamicMaskPlane_float(IN.WorldSpacePosition, _Property_c2fcbed1c8b9408fb9e6665d295dd052_Out_0_Matrix4, 0, _DynamicMask_a54489dc94d7460e85cc740e45ba413a_Out_3_Float);
float _Multiply_0cf02108ee5e4f618fd9a5042251110e_Out_2_Float;
Unity_Multiply_float_float(_WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_Wireframe_3_Float, _DynamicMask_a54489dc94d7460e85cc740e45ba413a_Out_3_Float, _Multiply_0cf02108ee5e4f618fd9a5042251110e_Out_2_Float);
surface.Alpha = _Multiply_0cf02108ee5e4f618fd9a5042251110e_Out_2_Float;
surface.AlphaClipThreshold = 0.01;
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
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

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
    Name "DepthNormals"
    Tags
    {
        "LightMode" = "DepthNormals"
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
#pragma target 5.0
#pragma multi_compile_instancing
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
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define VARYINGS_NEED_TANGENT_WS
#define VARYINGS_NEED_TEXCOORD0
#define VARYINGS_NEED_TEXCOORD1
#define VARYINGS_NEED_TEXCOORD2
#define VARYINGS_NEED_TEXCOORD3
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
float3 barycentric : INTERP7;
 float4 positionCS : SV_POSITION;
 float4 tangentWS : INTERP0;
 float4 texCoord0 : INTERP1;
 float4 texCoord1 : INTERP2;
 float4 texCoord2 : INTERP3;
 float4 texCoord3 : INTERP4;
 float3 positionWS : INTERP5;
 float3 normalWS : INTERP6;
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
output.texCoord1.xyzw = input.texCoord1;
output.texCoord2.xyzw = input.texCoord2;
output.texCoord3.xyzw = input.texCoord3;
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
output.tangentWS = input.tangentWS.xyzw;
output.texCoord0 = input.texCoord0.xyzw;
output.texCoord1 = input.texCoord1.xyzw;
output.texCoord2 = input.texCoord2.xyzw;
output.texCoord3 = input.texCoord3.xyzw;
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
float4x4 _WireframeShaderMaskData;
float4 _Wireframe_Color;
float4 _Scanner_Glow_Color;
float _Wireframe_Thickness;
float _Wireframe_Anti_aliasing;
float _Scanner_Glow_Emission;
CBUFFER_END


// Object and Global properties

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
float _Property_1dc4788b9eca4069baa399efa4413298_Out_0_Float = _Wireframe_Thickness;
float _Property_8b57c7d9cbef4037966ba71e85a6a06c_Out_0_Float = _Wireframe_Anti_aliasing;
float _WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_Wireframe_3_Float;
float2 _WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_BarycentricUV_4_Vector2;
WireframeRenderer_float(IN.barycentric.xyz, max(0, _Property_1dc4788b9eca4069baa399efa4413298_Out_0_Float), max(0, _Property_8b57c7d9cbef4037966ba71e85a6a06c_Out_0_Float), 0, _WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_Wireframe_3_Float, _WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_BarycentricUV_4_Vector2);
float4x4 _Property_c2fcbed1c8b9408fb9e6665d295dd052_Out_0_Matrix4 = _WireframeShaderMaskData;
float _DynamicMask_a54489dc94d7460e85cc740e45ba413a_Out_3_Float;
WireframeShaderDynamicMaskPlane_float(IN.WorldSpacePosition, _Property_c2fcbed1c8b9408fb9e6665d295dd052_Out_0_Matrix4, 0, _DynamicMask_a54489dc94d7460e85cc740e45ba413a_Out_3_Float);
float _Multiply_0cf02108ee5e4f618fd9a5042251110e_Out_2_Float;
Unity_Multiply_float_float(_WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_Wireframe_3_Float, _DynamicMask_a54489dc94d7460e85cc740e45ba413a_Out_3_Float, _Multiply_0cf02108ee5e4f618fd9a5042251110e_Out_2_Float);
surface.NormalTS = IN.TangentSpaceNormal;
surface.Alpha = _Multiply_0cf02108ee5e4f618fd9a5042251110e_Out_2_Float;
surface.AlphaClipThreshold = 0.01;
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
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

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
float4x4 _WireframeShaderMaskData;
float4 _Wireframe_Color;
float4 _Scanner_Glow_Color;
float _Wireframe_Thickness;
float _Wireframe_Anti_aliasing;
float _Scanner_Glow_Emission;
CBUFFER_END


// Object and Global properties

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

void Unity_Multiply_float_float(float A, float B, out float Out)
{
Out = A * B;
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

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
{
Out = A * B;
}

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
float Alpha;
float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
float4 _Property_f516815bafdc4179b6acf74539139f7e_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Wireframe_Color) : _Wireframe_Color;
float4 _Property_26ccfbc457ff4bfcb70ae50522fe92cd_Out_0_Vector4 = _Scanner_Glow_Color;
float _Property_a6b8ca586ad44ca0a6b852fcbe20d2d4_Out_0_Float = _Scanner_Glow_Emission;
float _Multiply_6929e6947fe04329b8ffedc394efb941_Out_2_Float;
Unity_Multiply_float_float(_Property_a6b8ca586ad44ca0a6b852fcbe20d2d4_Out_0_Float, _Property_a6b8ca586ad44ca0a6b852fcbe20d2d4_Out_0_Float, _Multiply_6929e6947fe04329b8ffedc394efb941_Out_2_Float);
float4x4 _Property_c2fcbed1c8b9408fb9e6665d295dd052_Out_0_Matrix4 = _WireframeShaderMaskData;
float _DynamicMask_a54489dc94d7460e85cc740e45ba413a_Out_3_Float;
WireframeShaderDynamicMaskPlane_float(IN.WorldSpacePosition, _Property_c2fcbed1c8b9408fb9e6665d295dd052_Out_0_Matrix4, 0, _DynamicMask_a54489dc94d7460e85cc740e45ba413a_Out_3_Float);
float _OneMinus_cdea28730e414b8d9de9b1a9bcc87cd4_Out_1_Float;
Unity_OneMinus_float(_DynamicMask_a54489dc94d7460e85cc740e45ba413a_Out_3_Float, _OneMinus_cdea28730e414b8d9de9b1a9bcc87cd4_Out_1_Float);
float _Multiply_85529825e2b241e89d7701edfbd37a4f_Out_2_Float;
Unity_Multiply_float_float(_DynamicMask_a54489dc94d7460e85cc740e45ba413a_Out_3_Float, _OneMinus_cdea28730e414b8d9de9b1a9bcc87cd4_Out_1_Float, _Multiply_85529825e2b241e89d7701edfbd37a4f_Out_2_Float);
float _Multiply_62b70451cfcf4bf081790341501fab0a_Out_2_Float;
Unity_Multiply_float_float(_Multiply_85529825e2b241e89d7701edfbd37a4f_Out_2_Float, _Multiply_85529825e2b241e89d7701edfbd37a4f_Out_2_Float, _Multiply_62b70451cfcf4bf081790341501fab0a_Out_2_Float);
float _Multiply_e3cd280f83414d31ba19fc780c18abc9_Out_2_Float;
Unity_Multiply_float_float(_Multiply_6929e6947fe04329b8ffedc394efb941_Out_2_Float, _Multiply_62b70451cfcf4bf081790341501fab0a_Out_2_Float, _Multiply_e3cd280f83414d31ba19fc780c18abc9_Out_2_Float);
float4 _Multiply_1460998fb88549c8b11189ec8d393414_Out_2_Vector4;
Unity_Multiply_float4_float4(_Property_26ccfbc457ff4bfcb70ae50522fe92cd_Out_0_Vector4, (_Multiply_e3cd280f83414d31ba19fc780c18abc9_Out_2_Float.xxxx), _Multiply_1460998fb88549c8b11189ec8d393414_Out_2_Vector4);
float4 _Property_3f2bd1c27f3e48a5afce56efb01d29df_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Wireframe_Color) : _Wireframe_Color;
float _Property_1dc4788b9eca4069baa399efa4413298_Out_0_Float = _Wireframe_Thickness;
float _Property_8b57c7d9cbef4037966ba71e85a6a06c_Out_0_Float = _Wireframe_Anti_aliasing;
float _WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_Wireframe_3_Float;
float2 _WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_BarycentricUV_4_Vector2;
WireframeRenderer_float(IN.barycentric.xyz, max(0, _Property_1dc4788b9eca4069baa399efa4413298_Out_0_Float), max(0, _Property_8b57c7d9cbef4037966ba71e85a6a06c_Out_0_Float), 0, _WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_Wireframe_3_Float, _WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_BarycentricUV_4_Vector2);
float _Multiply_0cf02108ee5e4f618fd9a5042251110e_Out_2_Float;
Unity_Multiply_float_float(_WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_Wireframe_3_Float, _DynamicMask_a54489dc94d7460e85cc740e45ba413a_Out_3_Float, _Multiply_0cf02108ee5e4f618fd9a5042251110e_Out_2_Float);
float4 _Lerp_2740b953228343e3b052c6064772bba3_Out_3_Vector4;
Unity_Lerp_float4(_Multiply_1460998fb88549c8b11189ec8d393414_Out_2_Vector4, _Property_3f2bd1c27f3e48a5afce56efb01d29df_Out_0_Vector4, (_Multiply_0cf02108ee5e4f618fd9a5042251110e_Out_2_Float.xxxx), _Lerp_2740b953228343e3b052c6064772bba3_Out_3_Vector4);
surface.BaseColor = (_Property_f516815bafdc4179b6acf74539139f7e_Out_0_Vector4.xyz);
surface.Emission = (_Lerp_2740b953228343e3b052c6064772bba3_Out_3_Vector4.xyz);
surface.Alpha = _Multiply_0cf02108ee5e4f618fd9a5042251110e_Out_2_Float;
surface.AlphaClipThreshold = 0.01;
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
float4x4 _WireframeShaderMaskData;
float4 _Wireframe_Color;
float4 _Scanner_Glow_Color;
float _Wireframe_Thickness;
float _Wireframe_Anti_aliasing;
float _Scanner_Glow_Emission;
CBUFFER_END


// Object and Global properties

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
float _Property_1dc4788b9eca4069baa399efa4413298_Out_0_Float = _Wireframe_Thickness;
float _Property_8b57c7d9cbef4037966ba71e85a6a06c_Out_0_Float = _Wireframe_Anti_aliasing;
float _WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_Wireframe_3_Float;
float2 _WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_BarycentricUV_4_Vector2;
WireframeRenderer_float(IN.barycentric.xyz, max(0, _Property_1dc4788b9eca4069baa399efa4413298_Out_0_Float), max(0, _Property_8b57c7d9cbef4037966ba71e85a6a06c_Out_0_Float), 0, _WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_Wireframe_3_Float, _WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_BarycentricUV_4_Vector2);
float4x4 _Property_c2fcbed1c8b9408fb9e6665d295dd052_Out_0_Matrix4 = _WireframeShaderMaskData;
float _DynamicMask_a54489dc94d7460e85cc740e45ba413a_Out_3_Float;
WireframeShaderDynamicMaskPlane_float(IN.WorldSpacePosition, _Property_c2fcbed1c8b9408fb9e6665d295dd052_Out_0_Matrix4, 0, _DynamicMask_a54489dc94d7460e85cc740e45ba413a_Out_3_Float);
float _Multiply_0cf02108ee5e4f618fd9a5042251110e_Out_2_Float;
Unity_Multiply_float_float(_WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_Wireframe_3_Float, _DynamicMask_a54489dc94d7460e85cc740e45ba413a_Out_3_Float, _Multiply_0cf02108ee5e4f618fd9a5042251110e_Out_2_Float);
surface.Alpha = _Multiply_0cf02108ee5e4f618fd9a5042251110e_Out_2_Float;
surface.AlphaClipThreshold = 0.01;
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
float4x4 _WireframeShaderMaskData;
float4 _Wireframe_Color;
float4 _Scanner_Glow_Color;
float _Wireframe_Thickness;
float _Wireframe_Anti_aliasing;
float _Scanner_Glow_Emission;
CBUFFER_END


// Object and Global properties

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
float _Property_1dc4788b9eca4069baa399efa4413298_Out_0_Float = _Wireframe_Thickness;
float _Property_8b57c7d9cbef4037966ba71e85a6a06c_Out_0_Float = _Wireframe_Anti_aliasing;
float _WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_Wireframe_3_Float;
float2 _WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_BarycentricUV_4_Vector2;
WireframeRenderer_float(IN.barycentric.xyz, max(0, _Property_1dc4788b9eca4069baa399efa4413298_Out_0_Float), max(0, _Property_8b57c7d9cbef4037966ba71e85a6a06c_Out_0_Float), 0, _WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_Wireframe_3_Float, _WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_BarycentricUV_4_Vector2);
float4x4 _Property_c2fcbed1c8b9408fb9e6665d295dd052_Out_0_Matrix4 = _WireframeShaderMaskData;
float _DynamicMask_a54489dc94d7460e85cc740e45ba413a_Out_3_Float;
WireframeShaderDynamicMaskPlane_float(IN.WorldSpacePosition, _Property_c2fcbed1c8b9408fb9e6665d295dd052_Out_0_Matrix4, 0, _DynamicMask_a54489dc94d7460e85cc740e45ba413a_Out_3_Float);
float _Multiply_0cf02108ee5e4f618fd9a5042251110e_Out_2_Float;
Unity_Multiply_float_float(_WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_Wireframe_3_Float, _DynamicMask_a54489dc94d7460e85cc740e45ba413a_Out_3_Float, _Multiply_0cf02108ee5e4f618fd9a5042251110e_Out_2_Float);
surface.Alpha = _Multiply_0cf02108ee5e4f618fd9a5042251110e_Out_2_Float;
surface.AlphaClipThreshold = 0.01;
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
    // Name: <None>
    Tags
    {
        "LightMode" = "Universal2D"
    }

// Render State
Cull Off
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
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_TEXCOORD0
#define VARYINGS_NEED_TEXCOORD1
#define VARYINGS_NEED_TEXCOORD2
#define VARYINGS_NEED_TEXCOORD3
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
float4x4 _WireframeShaderMaskData;
float4 _Wireframe_Color;
float4 _Scanner_Glow_Color;
float _Wireframe_Thickness;
float _Wireframe_Anti_aliasing;
float _Scanner_Glow_Emission;
CBUFFER_END


// Object and Global properties

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
float4 _Property_f516815bafdc4179b6acf74539139f7e_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Wireframe_Color) : _Wireframe_Color;
float _Property_1dc4788b9eca4069baa399efa4413298_Out_0_Float = _Wireframe_Thickness;
float _Property_8b57c7d9cbef4037966ba71e85a6a06c_Out_0_Float = _Wireframe_Anti_aliasing;
float _WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_Wireframe_3_Float;
float2 _WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_BarycentricUV_4_Vector2;
WireframeRenderer_float(IN.barycentric.xyz, max(0, _Property_1dc4788b9eca4069baa399efa4413298_Out_0_Float), max(0, _Property_8b57c7d9cbef4037966ba71e85a6a06c_Out_0_Float), 0, _WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_Wireframe_3_Float, _WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_BarycentricUV_4_Vector2);
float4x4 _Property_c2fcbed1c8b9408fb9e6665d295dd052_Out_0_Matrix4 = _WireframeShaderMaskData;
float _DynamicMask_a54489dc94d7460e85cc740e45ba413a_Out_3_Float;
WireframeShaderDynamicMaskPlane_float(IN.WorldSpacePosition, _Property_c2fcbed1c8b9408fb9e6665d295dd052_Out_0_Matrix4, 0, _DynamicMask_a54489dc94d7460e85cc740e45ba413a_Out_3_Float);
float _Multiply_0cf02108ee5e4f618fd9a5042251110e_Out_2_Float;
Unity_Multiply_float_float(_WireframeRenderer_5353d4d4d2584c44ba10b958257ad707_Wireframe_3_Float, _DynamicMask_a54489dc94d7460e85cc740e45ba413a_Out_3_Float, _Multiply_0cf02108ee5e4f618fd9a5042251110e_Out_2_Float);
surface.BaseColor = (_Property_f516815bafdc4179b6acf74539139f7e_Out_0_Vector4.xyz);
surface.Alpha = _Multiply_0cf02108ee5e4f618fd9a5042251110e_Out_2_Float;
surface.AlphaClipThreshold = 0.01;
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
            "m_Id": "a447ae0cd4b24cc39f3d69714f68a054"
        },
        {
            "m_Id": "219f3a903fa043dfa4bf465dcb389cf4"
        },
        {
            "m_Id": "fa96b8e4c3cf4ba39c8692064c29b868"
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
            "m_Id": "1dc4788b9eca4069baa399efa4413298"
        },
        {
            "m_Id": "8b57c7d9cbef4037966ba71e85a6a06c"
        },
        {
            "m_Id": "c2fcbed1c8b9408fb9e6665d295dd052"
        },
        {
            "m_Id": "86722a7582584325b1881f836abb0852"
        },
        {
            "m_Id": "f516815bafdc4179b6acf74539139f7e"
        },
        {
            "m_Id": "0cf02108ee5e4f618fd9a5042251110e"
        },
        {
            "m_Id": "26ccfbc457ff4bfcb70ae50522fe92cd"
        },
        {
            "m_Id": "1460998fb88549c8b11189ec8d393414"
        },
        {
            "m_Id": "a6b8ca586ad44ca0a6b852fcbe20d2d4"
        },
        {
            "m_Id": "6929e6947fe04329b8ffedc394efb941"
        },
        {
            "m_Id": "e3cd280f83414d31ba19fc780c18abc9"
        },
        {
            "m_Id": "2740b953228343e3b052c6064772bba3"
        },
        {
            "m_Id": "3f2bd1c27f3e48a5afce56efb01d29df"
        },
        {
            "m_Id": "85529825e2b241e89d7701edfbd37a4f"
        },
        {
            "m_Id": "cdea28730e414b8d9de9b1a9bcc87cd4"
        },
        {
            "m_Id": "62b70451cfcf4bf081790341501fab0a"
        },
        {
            "m_Id": "a72f9612da5d44548653a9ccea306d25"
        },
        {
            "m_Id": "a54489dc94d7460e85cc740e45ba413a"
        },
        {
            "m_Id": "5353d4d4d2584c44ba10b958257ad707"
        }
    ],
    "m_GroupDatas": [
        {
            "m_Id": "5d1b0a9b79bb4867b867f19fef38c9bb"
        },
        {
            "m_Id": "92f9e7be2af64973a3cf2575963dcca2"
        }
    ],
    "m_StickyNoteDatas": [],
    "m_Edges": [
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "0cf02108ee5e4f618fd9a5042251110e"
                },
                "m_SlotId": 2
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "2740b953228343e3b052c6064772bba3"
                },
                "m_SlotId": 2
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "0cf02108ee5e4f618fd9a5042251110e"
                },
                "m_SlotId": 2
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
                    "m_Id": "1460998fb88549c8b11189ec8d393414"
                },
                "m_SlotId": 2
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "2740b953228343e3b052c6064772bba3"
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
                    "m_Id": "5353d4d4d2584c44ba10b958257ad707"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "26ccfbc457ff4bfcb70ae50522fe92cd"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "1460998fb88549c8b11189ec8d393414"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "2740b953228343e3b052c6064772bba3"
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
                    "m_Id": "3f2bd1c27f3e48a5afce56efb01d29df"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "2740b953228343e3b052c6064772bba3"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "5353d4d4d2584c44ba10b958257ad707"
                },
                "m_SlotId": 3
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "0cf02108ee5e4f618fd9a5042251110e"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "62b70451cfcf4bf081790341501fab0a"
                },
                "m_SlotId": 2
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "e3cd280f83414d31ba19fc780c18abc9"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "6929e6947fe04329b8ffedc394efb941"
                },
                "m_SlotId": 2
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "e3cd280f83414d31ba19fc780c18abc9"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "85529825e2b241e89d7701edfbd37a4f"
                },
                "m_SlotId": 2
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "62b70451cfcf4bf081790341501fab0a"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "85529825e2b241e89d7701edfbd37a4f"
                },
                "m_SlotId": 2
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "62b70451cfcf4bf081790341501fab0a"
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
                    "m_Id": "5353d4d4d2584c44ba10b958257ad707"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "a54489dc94d7460e85cc740e45ba413a"
                },
                "m_SlotId": 3
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "0cf02108ee5e4f618fd9a5042251110e"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "a54489dc94d7460e85cc740e45ba413a"
                },
                "m_SlotId": 3
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "a72f9612da5d44548653a9ccea306d25"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "a6b8ca586ad44ca0a6b852fcbe20d2d4"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "6929e6947fe04329b8ffedc394efb941"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "a6b8ca586ad44ca0a6b852fcbe20d2d4"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "6929e6947fe04329b8ffedc394efb941"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "a72f9612da5d44548653a9ccea306d25"
                },
                "m_SlotId": 1
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "85529825e2b241e89d7701edfbd37a4f"
                },
                "m_SlotId": 0
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "a72f9612da5d44548653a9ccea306d25"
                },
                "m_SlotId": 1
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "cdea28730e414b8d9de9b1a9bcc87cd4"
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
                    "m_Id": "a54489dc94d7460e85cc740e45ba413a"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "cdea28730e414b8d9de9b1a9bcc87cd4"
                },
                "m_SlotId": 1
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "85529825e2b241e89d7701edfbd37a4f"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "e3cd280f83414d31ba19fc780c18abc9"
                },
                "m_SlotId": 2
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "1460998fb88549c8b11189ec8d393414"
                },
                "m_SlotId": 1
            }
        },
        {
            "m_OutputSlot": {
                "m_Node": {
                    "m_Id": "f516815bafdc4179b6acf74539139f7e"
                },
                "m_SlotId": 0
            },
            "m_InputSlot": {
                "m_Node": {
                    "m_Id": "a0ff7a5655a241a693febc2166745dd3"
                },
                "m_SlotId": 0
            }
        }
    ],
    "m_VertexContext": {
        "m_Position": {
            "x": 424.1454162597656,
            "y": -117.81816864013672
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
            "x": 424.1454162597656,
            "y": 212.07272338867188
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
            "m_Id": "afaee2ba449441d3a102dfaf0ec1eabd"
        }
    ]
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "01b150fe9ab74f64b83654f4765eae6a",
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
    "m_Type": "UnityEditor.ShaderGraph.MultiplyNode",
    "m_ObjectId": "0cf02108ee5e4f618fd9a5042251110e",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "Multiply",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -569.8908081054688,
            "y": 1045.5272216796875,
            "width": 129.16351318359376,
            "height": 117.818359375
        }
    },
    "m_Slots": [
        {
            "m_Id": "651af1f8db6a441db87db83e5b8e6355"
        },
        {
            "m_Id": "b8b12d4812614931ab74e1cd9e8cdb86"
        },
        {
            "m_Id": "5a7507c779224f158b35b6ba2cc98bfe"
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
    "m_ObjectId": "0e085324dbc745709e963cf1743f087a",
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
    "m_Type": "UnityEditor.ShaderGraph.MultiplyNode",
    "m_ObjectId": "1460998fb88549c8b11189ec8d393414",
    "m_Group": {
        "m_Id": "92f9e7be2af64973a3cf2575963dcca2"
    },
    "m_Name": "Multiply",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -802.9091186523438,
            "y": 284.5091247558594,
            "width": 132.654541015625,
            "height": 116.94546508789063
        }
    },
    "m_Slots": [
        {
            "m_Id": "fb485e80dd234693979f9c448c13c31c"
        },
        {
            "m_Id": "01b150fe9ab74f64b83654f4765eae6a"
        },
        {
            "m_Id": "f6773d4eaea2400990dc22aa96167f72"
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
    "m_SGVersion": 2,
    "m_Type": "UnityEditor.Rendering.Universal.ShaderGraph.UniversalLitSubTarget",
    "m_ObjectId": "1c2d32bdceb34514aed37ea2a900a892",
    "m_WorkflowMode": 1,
    "m_NormalDropOffSpace": 0,
    "m_ClearCoat": false,
    "m_BlendModePreserveSpecular": true
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "1c31d9946dc140559e1cae8bb3f7d42b",
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
    "m_ObjectId": "1dc4788b9eca4069baa399efa4413298",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "Property",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1254.9818115234375,
            "y": 898.0364379882813,
            "width": 186.763671875,
            "height": 33.16357421875
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "218bd466eea44b84acd99c81bca61aab",
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
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "25d777744de54a41911a3f6254f7a46f",
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
    "m_ObjectId": "26ccfbc457ff4bfcb70ae50522fe92cd",
    "m_Group": {
        "m_Id": "92f9e7be2af64973a3cf2575963dcca2"
    },
    "m_Name": "Property",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1028.9454345703125,
            "y": 231.27272033691407,
            "width": 182.4000244140625,
            "height": 32.29093933105469
        }
    },
    "m_Slots": [
        {
            "m_Id": "2aa072a82a95481783267f189061ce48"
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
    "m_Type": "UnityEditor.ShaderGraph.LerpNode",
    "m_ObjectId": "2740b953228343e3b052c6064772bba3",
    "m_Group": {
        "m_Id": "92f9e7be2af64973a3cf2575963dcca2"
    },
    "m_Name": "Lerp",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -336.8727722167969,
            "y": 284.5091247558594,
            "width": 132.65455627441407,
            "height": 141.3818359375
        }
    },
    "m_Slots": [
        {
            "m_Id": "2a1f5bd6f5cd46099a977055128e1b0c"
        },
        {
            "m_Id": "cd8f02ba15294707ba004186ffae43fd"
        },
        {
            "m_Id": "b34d1eab72a6488d826f4f75fcd6274d"
        },
        {
            "m_Id": "7b3960b90a0946108d333fbe806febfd"
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
    "m_ObjectId": "29b2b4e9fccf4d24bb7ac698795ed97d",
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "2a1f5bd6f5cd46099a977055128e1b0c",
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
    "m_ObjectId": "2aa072a82a95481783267f189061ce48",
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "3278d2fa44f94dc29634edca2f6407fd",
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
    "m_Type": "UnityEditor.Rendering.HighDefinition.ShaderGraph.HDUnlitData",
    "m_ObjectId": "340a8f7201bb4a1e9cfdda0cf39ddd5e",
    "m_EnableShadowMatte": false,
    "m_DistortionOnly": false
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector2MaterialSlot",
    "m_ObjectId": "359a1b1ee2e94c5582e9c3fea2a265c5",
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "387c839d1ef947c395d01ffd3d6320b6",
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
    "m_Type": "UnityEditor.Rendering.HighDefinition.ShaderGraph.HDUnlitSubTarget",
    "m_ObjectId": "39581a4de0354281aaa86ee401b6cfb4"
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.PropertyNode",
    "m_ObjectId": "3f2bd1c27f3e48a5afce56efb01d29df",
    "m_Group": {
        "m_Id": "92f9e7be2af64973a3cf2575963dcca2"
    },
    "m_Name": "Property",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -569.8908081054688,
            "y": 348.21820068359377,
            "width": 164.07260131835938,
            "height": 32.290924072265628
        }
    },
    "m_Slots": [
        {
            "m_Id": "57f600cebb0d43ee93161e0cf64acc6d"
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
        "m_Id": "a447ae0cd4b24cc39f3d69714f68a054"
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
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "438a10fdf4484bcd97097141240750d9",
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
    "m_ObjectId": "48b3252a40814b988a2bde9836e500b4",
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
    "m_Type": "AmazingAssets.DynamicWireframeShaderGenerator.Editor.WireframeRendererNode",
    "m_ObjectId": "5353d4d4d2584c44ba10b958257ad707",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "Wireframe Renderer",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1022.8363037109375,
            "y": 861.3817749023438,
            "width": 315.92724609375,
            "height": 164.94537353515626
        }
    },
    "m_Slots": [
        {
            "m_Id": "71b5b62b32cb4d67a5f12502a5ac8874"
        },
        {
            "m_Id": "cb6008ba06da4e0b94c7eda10ed9bbad"
        },
        {
            "m_Id": "29b2b4e9fccf4d24bb7ac698795ed97d"
        },
        {
            "m_Id": "359a1b1ee2e94c5582e9c3fea2a265c5"
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
    "m_ObjectId": "57f600cebb0d43ee93161e0cf64acc6d",
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "5a7507c779224f158b35b6ba2cc98bfe",
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
    "m_ObjectId": "5c05304bb99d4f8d91030fcfcaaded0b",
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
    "m_Type": "UnityEditor.ShaderGraph.GroupData",
    "m_ObjectId": "5d1b0a9b79bb4867b867f19fef38c9bb",
    "m_Title": "Dynamic Mask",
    "m_Position": {
        "x": -2509.963623046875,
        "y": 861.3817138671875
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "5dc4d3bfed0b4d9785943e15ab06e97f",
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
    "m_Type": "UnityEditor.ShaderGraph.MultiplyNode",
    "m_ObjectId": "62b70451cfcf4bf081790341501fab0a",
    "m_Group": {
        "m_Id": "92f9e7be2af64973a3cf2575963dcca2"
    },
    "m_Name": "Multiply",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1152.0,
            "y": 479.9999694824219,
            "width": 129.16375732421876,
            "height": 116.94552612304688
        }
    },
    "m_Slots": [
        {
            "m_Id": "218bd466eea44b84acd99c81bca61aab"
        },
        {
            "m_Id": "48b3252a40814b988a2bde9836e500b4"
        },
        {
            "m_Id": "fc600208c9b84b03b7ea6826a698e805"
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
    "m_ObjectId": "651af1f8db6a441db87db83e5b8e6355",
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
    "m_Type": "UnityEditor.ShaderGraph.CategoryData",
    "m_ObjectId": "65a435a0d253424193b7973c27a3a3a3",
    "m_Name": "Base",
    "m_ChildObjectList": [
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
    "m_Type": "UnityEditor.ShaderGraph.MultiplyNode",
    "m_ObjectId": "6929e6947fe04329b8ffedc394efb941",
    "m_Group": {
        "m_Id": "92f9e7be2af64973a3cf2575963dcca2"
    },
    "m_Name": "Multiply",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1152.0,
            "y": 298.4727783203125,
            "width": 129.16375732421876,
            "height": 116.94546508789063
        }
    },
    "m_Slots": [
        {
            "m_Id": "387c839d1ef947c395d01ffd3d6320b6"
        },
        {
            "m_Id": "5c05304bb99d4f8d91030fcfcaaded0b"
        },
        {
            "m_Id": "1c31d9946dc140559e1cae8bb3f7d42b"
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
    "m_ObjectId": "71b5b62b32cb4d67a5f12502a5ac8874",
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
    "m_ObjectId": "7b3960b90a0946108d333fbe806febfd",
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
    "m_ObjectId": "7e32b7a43d2b425f912491fc24d0ffd3",
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
    "m_Type": "UnityEditor.ShaderGraph.MultiplyNode",
    "m_ObjectId": "85529825e2b241e89d7701edfbd37a4f",
    "m_Group": {
        "m_Id": "92f9e7be2af64973a3cf2575963dcca2"
    },
    "m_Name": "Multiply",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1332.654541015625,
            "y": 490.47271728515627,
            "width": 129.163818359375,
            "height": 116.945556640625
        }
    },
    "m_Slots": [
        {
            "m_Id": "d5942511904c4f3280dd0f5f0d275d0b"
        },
        {
            "m_Id": "f5fb715da9de435781368c1f84965fa0"
        },
        {
            "m_Id": "25d777744de54a41911a3f6254f7a46f"
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
            "x": -1267.199951171875,
            "y": 944.2908935546875,
            "width": 198.9818115234375,
            "height": 33.1636962890625
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
    "m_Value": 0.10000000149011612,
    "m_DefaultValue": 0.5,
    "m_Labels": []
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "8f80fd1df17445989d21e7d4992a55d7",
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
    "m_Type": "UnityEditor.ShaderGraph.GroupData",
    "m_ObjectId": "92f9e7be2af64973a3cf2575963dcca2",
    "m_Title": "Emission",
    "m_Position": {
        "x": -1597.9635009765625,
        "y": 173.6727294921875
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "a1553dc90f30458bae748d1bd8a872a8",
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
    "m_SGVersion": 3,
    "m_Type": "UnityEditor.ShaderGraph.Internal.ColorShaderProperty",
    "m_ObjectId": "a447ae0cd4b24cc39f3d69714f68a054",
    "m_Guid": {
        "m_GuidSerialized": "edcc934d-27a3-4b4a-bfa3-c0ef5686796f"
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
    "m_Type": "AmazingAssets.DynamicWireframeShaderGenerator.Editor.DynamicMaskNode",
    "m_ObjectId": "a54489dc94d7460e85cc740e45ba413a",
    "m_Group": {
        "m_Id": "5d1b0a9b79bb4867b867f19fef38c9bb"
    },
    "m_Name": "Dynamic Mask",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -2187.92724609375,
            "y": 1085.672607421875,
            "width": 223.4180908203125,
            "height": 152.727294921875
        }
    },
    "m_Slots": [
        {
            "m_Id": "fc2133dee32847c5b0a198b7cafe5ce9"
        },
        {
            "m_Id": "a5aa210a941b474d802b0ab4e66e55f9"
        },
        {
            "m_Id": "8f80fd1df17445989d21e7d4992a55d7"
        },
        {
            "m_Id": "a5e86fc460264703bc32ee816f6fa425"
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
    "m_Type": "UnityEditor.ShaderGraph.Matrix4MaterialSlot",
    "m_ObjectId": "a5aa210a941b474d802b0ab4e66e55f9",
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "a5b580d6715a4018862dede98ee48658",
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
    "m_ObjectId": "a5e86fc460264703bc32ee816f6fa425",
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
    "m_Type": "UnityEditor.ShaderGraph.PropertyNode",
    "m_ObjectId": "a6b8ca586ad44ca0a6b852fcbe20d2d4",
    "m_Group": {
        "m_Id": "92f9e7be2af64973a3cf2575963dcca2"
    },
    "m_Name": "Property",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1356.2181396484375,
            "y": 349.0909423828125,
            "width": 198.109130859375,
            "height": 32.2908935546875
        }
    },
    "m_Slots": [
        {
            "m_Id": "438a10fdf4484bcd97097141240750d9"
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
    "m_Type": "UnityEditor.ShaderGraph.RedirectNodeData",
    "m_ObjectId": "a72f9612da5d44548653a9ccea306d25",
    "m_Group": {
        "m_Id": "92f9e7be2af64973a3cf2575963dcca2"
    },
    "m_Name": "Redirect Node",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1573.5272216796875,
            "y": 535.8545532226563,
            "width": 55.8544921875,
            "height": 23.5635986328125
        }
    },
    "m_Slots": [
        {
            "m_Id": "7e32b7a43d2b425f912491fc24d0ffd3"
        },
        {
            "m_Id": "a5b580d6715a4018862dede98ee48658"
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
    "m_SGVersion": 1,
    "m_Type": "UnityEditor.Rendering.Universal.ShaderGraph.UniversalTarget",
    "m_ObjectId": "afaee2ba449441d3a102dfaf0ec1eabd",
    "m_Datas": [],
    "m_ActiveSubTarget": {
        "m_Id": "1c2d32bdceb34514aed37ea2a900a892"
    },
    "m_AllowMaterialOverride": false,
    "m_SurfaceType": 0,
    "m_ZTestMode": 4,
    "m_ZWriteControl": 0,
    "m_AlphaMode": 0,
    "m_RenderFace": 0,
    "m_AlphaClip": true,
    "m_CastShadows": true,
    "m_ReceiveShadows": true,
    "m_SupportsLODCrossFade": false,
    "m_CustomEditorGUI": "",
    "m_SupportVFX": false
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "b34d1eab72a6488d826f4f75fcd6274d",
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "b8b12d4812614931ab74e1cd9e8cdb86",
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
            "x": -2485.52734375,
            "y": 1130.1817626953125,
            "width": 224.290771484375,
            "height": 33.16357421875
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
    "m_Type": "UnityEditor.ShaderGraph.Vector1MaterialSlot",
    "m_ObjectId": "cb6008ba06da4e0b94c7eda10ed9bbad",
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
    "m_Type": "UnityEditor.ShaderGraph.Vector4MaterialSlot",
    "m_ObjectId": "cbbc4c26f7ec425b8ed6a0d91c875e82",
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicVectorMaterialSlot",
    "m_ObjectId": "cd8f02ba15294707ba004186ffae43fd",
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
    "m_Type": "UnityEditor.ShaderGraph.OneMinusNode",
    "m_ObjectId": "cdea28730e414b8d9de9b1a9bcc87cd4",
    "m_Group": {
        "m_Id": "92f9e7be2af64973a3cf2575963dcca2"
    },
    "m_Name": "One Minus",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -1487.127197265625,
            "y": 587.3453979492188,
            "width": 130.9090576171875,
            "height": 93.3819580078125
        }
    },
    "m_Slots": [
        {
            "m_Id": "5dc4d3bfed0b4d9785943e15ab06e97f"
        },
        {
            "m_Id": "3278d2fa44f94dc29634edca2f6407fd"
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
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "d5942511904c4f3280dd0f5f0d275d0b",
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
    "inspectorFoldoutMask": 1
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
    "m_Type": "UnityEditor.ShaderGraph.MultiplyNode",
    "m_ObjectId": "e3cd280f83414d31ba19fc780c18abc9",
    "m_Group": {
        "m_Id": "92f9e7be2af64973a3cf2575963dcca2"
    },
    "m_Name": "Multiply",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": -976.581787109375,
            "y": 381.3818359375,
            "width": 129.16363525390626,
            "height": 116.94546508789063
        }
    },
    "m_Slots": [
        {
            "m_Id": "a1553dc90f30458bae748d1bd8a872a8"
        },
        {
            "m_Id": "0e085324dbc745709e963cf1743f087a"
        },
        {
            "m_Id": "e7e89ba669904fc89085b6925e9fb41f"
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
    "m_Type": "UnityEditor.Rendering.HighDefinition.ShaderGraph.HDLitSubTarget",
    "m_ObjectId": "e4335c2878f04db5af0adb530304d760"
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "e7e89ba669904fc89085b6925e9fb41f",
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
    "m_Type": "UnityEditor.ShaderGraph.PropertyNode",
    "m_ObjectId": "f516815bafdc4179b6acf74539139f7e",
    "m_Group": {
        "m_Id": ""
    },
    "m_Name": "Property",
    "m_DrawState": {
        "m_Expanded": true,
        "m_Position": {
            "serializedVersion": "2",
            "x": 58.4727783203125,
            "y": 253.0908966064453,
            "width": 164.07273864746095,
            "height": 33.16368103027344
        }
    },
    "m_Slots": [
        {
            "m_Id": "cbbc4c26f7ec425b8ed6a0d91c875e82"
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
        "m_Id": "a447ae0cd4b24cc39f3d69714f68a054"
    }
}

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "f5fb715da9de435781368c1f84965fa0",
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
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "f6773d4eaea2400990dc22aa96167f72",
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
            "m_Id": "a447ae0cd4b24cc39f3d69714f68a054"
        },
        {
            "m_Id": "937f028802f64a58a20c076445e50f2e"
        }
    ]
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

{
    "m_SGVersion": 0,
    "m_Type": "UnityEditor.ShaderGraph.DynamicValueMaterialSlot",
    "m_ObjectId": "fb485e80dd234693979f9c448c13c31c",
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
    "m_Type": "UnityEditor.ShaderGraph.PositionMaterialSlot",
    "m_ObjectId": "fc2133dee32847c5b0a198b7cafe5ce9",
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
    "m_ObjectId": "fc600208c9b84b03b7ea6826a698e805",
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


ShaderGraphBody_End*/

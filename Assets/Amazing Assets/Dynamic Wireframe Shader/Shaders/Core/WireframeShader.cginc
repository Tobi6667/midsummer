// Dynamic Wireframe Shader <https://u3d.as/3WyY>
// Copyright (c) Amazing Assets <https://amazingassets.world>

#ifndef WIREFRAME_SHADER_CGINC
#define WIREFRAME_SHADER_CGINC


float WireframeShaderRenderWireframe(float3 barycentric, float thickness, float antiAliasing, int renderInScreenSpace)
{
	float3 fw = fwidth(barycentric);

	float3 t = thickness.xxx * lerp(1, fw * 5, saturate(renderInScreenSpace));

	float3 df = barycentric - t;
	df /= fw * antiAliasing * 10 + 1e-6;
	float e = min(df.x, min(df.y, df.z));

	return 1 - smoothstep(0.0, 1.0, e + 0.5);
}

float WireframeShaderRenderWireframe(float3 barycentric, float thickness, float antiAliasing, int renderInScreenSpace, out float2 OutBarycentricUV)
{
	float3 df = barycentric / thickness.xxx;
	float e = min(df.x, min(df.y, df.z));
	OutBarycentricUV = float2(saturate(e), 0.5);

	return WireframeShaderRenderWireframe(barycentric, thickness, antiAliasing, renderInScreenSpace);
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

float WireframeShaderDynamicMaskPlane(float3 vertexPositionWS, float4x4 shaderData, float noise)
{
	float3 planePosition = shaderData[0].xyz;
	float3 planeNormal   = shaderData[1].xyz;
	float fallOff        = shaderData[3].x;
	float intensity      = shaderData[3].y;


	float mask = dot(planeNormal, (vertexPositionWS - planePosition)) - noise;

	mask = saturate(mask / fallOff);

    return mask * intensity;
}

float WireframeShaderDynamicMaskSphere(float3 vertexPositionWS, float4x4 shaderData, float noise)
{
	float3 spherePosition = shaderData[0].xyz;
	float sphereRadius    = shaderData[0].w;
	float fallOff         = shaderData[3].x;
	float intensity       = shaderData[3].y;


	float d = distance(vertexPositionWS, spherePosition);

    float mask = 1 - saturate(max(0, d - noise - sphereRadius + fallOff) / fallOff);

    return mask * intensity;
}

float WireframeShaderDynamicMaskCube(float3 vertexPositionWS, float4x4 shaderData, float noise)
{
	float3 cubePosition = shaderData[0].xyz;
	float4 cubeRotation = shaderData[1].xyzw;
	float3 cubeScale    = shaderData[2].xyz;
	float fallOff       = shaderData[3].x;
	float intensity     = shaderData[3].y;


	float3 v = vertexPositionWS - cubePosition;
	float3 u = cubeRotation.xyz;
    float w = -cubeRotation.w;
    float3 position =  2.0f * dot(u, v) * u + (w * w - dot(u, u)) * v +  2.0f * w * cross(u, v);

	float3 boundsMax = cubeScale * 0.5 + noise;
	float3 boundsMin = -boundsMax;  

	float3 s = smoothstep(boundsMin, boundsMin + fallOff, position) - 
	           smoothstep(boundsMax - fallOff, boundsMax, position);

	float mask = saturate(s.x * s.y * s.z);

	return mask * intensity;
}

float WireframeShaderDynamicMaskCapsule(float3 vertexPositionWS, float4x4 shaderData, float noise)
{
	float3 capsulePosition = shaderData[0].xyz;
	float capsuleHeight    = shaderData[0].w;
	float3 capsuleNormal   = shaderData[1].xyz;	
	float capsuleRadius    = shaderData[1].w;
	float fallOff          = shaderData[3].x;
	float intensity        = shaderData[3].y;


	float t = saturate(dot(vertexPositionWS - capsulePosition, capsuleNormal) / capsuleHeight);       
	float3 projection = capsulePosition + t * capsuleNormal * capsuleHeight;

	float d = distance(vertexPositionWS, projection);

	float mask = 1 - saturate(max(0, d - noise - capsuleRadius + fallOff) / fallOff);

    return mask * intensity;
}

float WireframeShaderDynamicMaskCone(float3 vertexPositionWS, float4x4 shaderData, float noise)
{
	float3 conePosition = shaderData[0].xyz;
	float coneHeight    = shaderData[0].w;
	float3 coneNormal   = shaderData[1].xyz;	
	float coneRadius    = shaderData[1].w;
	float fallOff       = shaderData[3].x;
	float intensity     = shaderData[3].y;


	float t = saturate(dot(vertexPositionWS - conePosition, coneNormal) / coneHeight);    
	float3 projectPosition = conePosition + t * coneNormal * coneHeight;

	float d = distance(vertexPositionWS, projectPosition);

	float radius = lerp(0, coneRadius, t);

	float mask = 1 - saturate(max(0, d - noise - radius + fallOff) / fallOff);

    return mask * intensity;
}

float WireframeShaderDistanceFade(float3 vertexPositionWS, float3 cameraPositionWS, float nearDistance, float farDistance)
{
	float distanceToCamera = distance(cameraPositionWS, vertexPositionWS);

	float distanceFade = (farDistance - distanceToCamera) / (farDistance - nearDistance); 

	return saturate(distanceFade);
}


//Unity Shader Graph///////////////////////////////////////////////////////////////////////////////////
void WireframeShaderRenderWireframe_float(float3 barycentric, float thickness, float antiAliasing, float renderInScreenSpace, out float OutWireframe, out float2 OutBarycentricUV)
{	
	OutWireframe = WireframeShaderRenderWireframe(barycentric, thickness, antiAliasing, renderInScreenSpace, OutBarycentricUV);	
}

void WireframeShaderRenderWireframe_half(half3 barycentric,  half thickness, half antiAliasing, half renderInScreenSpace, out half OutWireframe, out half2 OutBarycentricUV)
{
	OutWireframe = WireframeShaderRenderWireframe(barycentric, thickness, antiAliasing, renderInScreenSpace, OutBarycentricUV);
}

void WireframeShaderDynamicMaskPlane_float(float3 vertexPositionWS, float4x4 shaderData, float noise, out float value)
{
	value = WireframeShaderDynamicMaskPlane(vertexPositionWS, shaderData, noise);
}

void WireframeShaderDynamicMaskPlane_half(half3 vertexPositionWS, half4x4 shaderData, float noise, out half value)
{
	value = WireframeShaderDynamicMaskPlane(vertexPositionWS, shaderData, noise);
}

void WireframeShaderDynamicMaskSphere_float(float3 vertexPositionWS, float4x4 shaderData, float noise, out float value)
{
	value = WireframeShaderDynamicMaskSphere(vertexPositionWS, shaderData, noise);
}

void WireframeShaderDynamicMaskSphere_half(half3 vertexPositionWS, half4x4 shaderData, float noise, out half value)
{
	value = WireframeShaderDynamicMaskSphere(vertexPositionWS, shaderData, noise);
}

void WireframeShaderDynamicMaskCube_float(float3 vertexPositionWS, float4x4 shaderData, float noise, out float value)
{
	value = WireframeShaderDynamicMaskCube(vertexPositionWS, shaderData, noise);
}

void WireframeShaderDynamicMaskCube_half(half3 vertexPositionWS, half4x4 shaderData, float noise, out half value)
{
	value = WireframeShaderDynamicMaskCube(vertexPositionWS, shaderData, noise);
}

void WireframeShaderDynamicMaskCapsule_float(float3 vertexPositionWS, float4x4 shaderData, float noise, out float value)
{
	value = WireframeShaderDynamicMaskCapsule(vertexPositionWS, shaderData, noise);
}

void WireframeShaderDynamicMaskCapsule_half(half3 vertexPositionWS, half4x4 shaderData, float noise, out half value)
{
	value = WireframeShaderDynamicMaskCapsule(vertexPositionWS, shaderData, noise);
}

void WireframeShaderDynamicMaskCone_float(float3 vertexPositionWS, float4x4 shaderData, float noise, out float value)
{
	value = WireframeShaderDynamicMaskCone(vertexPositionWS, shaderData, noise);
}

void WireframeShaderDynamicMaskCone_half(half3 vertexPositionWS, half4x4 shaderData, float noise, out half value)
{
	value = WireframeShaderDynamicMaskCone(vertexPositionWS, shaderData, noise);
}

void WireframeShaderDistanceFade_float(float3 vertexPositionWS, float3 cameraPositionWS, float nearDistance, float farDistance, out float value)
{
	value = WireframeShaderDistanceFade(vertexPositionWS, cameraPositionWS, nearDistance, farDistance);
}

void WireframeShaderDistanceFade_half(half3 vertexPositionWS, half3 cameraPositionWS, half nearDistance, half farDistance, out half value)
{
	value = WireframeShaderDistanceFade(vertexPositionWS, cameraPositionWS, nearDistance, farDistance);
}

#endif

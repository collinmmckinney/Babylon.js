﻿precision highp float;

// Constants
uniform vec4 vEyePosition;

// Gradient variables
uniform vec4 topColor;
uniform vec4 bottomColor;
uniform float offset;
uniform float scale;
uniform float smoothness;

// Input
varying vec3 vPositionW;
varying vec3 vPosition;

#ifdef NORMAL
varying vec3 vNormalW;
#endif

#ifdef VERTEXCOLOR
varying vec4 vColor;
#endif

// Helper functions
#include<helperFunctions>

// Lights
#include<__decl__lightFragment>[0]
#include<__decl__lightFragment>[1]
#include<__decl__lightFragment>[2]
#include<__decl__lightFragment>[3]


#include<lightsFragmentFunctions>
#include<shadowsFragmentFunctions>

#include<clipPlaneFragmentDeclaration>

// Fog
#include<fogFragmentDeclaration>


#define CUSTOM_FRAGMENT_DEFINITIONS

void main(void) {

#define CUSTOM_FRAGMENT_MAIN_BEGIN

#include<clipPlaneFragment>

	vec3 viewDirectionW = normalize(vEyePosition.xyz - vPositionW);

    float h = vPosition.y * scale + offset;
    float mysmoothness = clamp(smoothness, 0.01, max(smoothness, 10.));

    vec4 baseColor = mix(bottomColor, topColor, max(pow(max(h, 0.0), mysmoothness), 0.0));

	// Base color
	vec3 diffuseColor = baseColor.rgb;

	// Alpha
	float alpha = baseColor.a;


#ifdef ALPHATEST
	if (baseColor.a < 0.4)
		discard;
#endif

#include<depthPrePass>

#ifdef VERTEXCOLOR
	baseColor.rgb *= vColor.rgb;
#endif

	// Bump
#ifdef NORMAL
	vec3 normalW = normalize(vNormalW);
#else
	vec3 normalW = vec3(1.0, 1.0, 1.0);
#endif

	// Lighting
#ifdef EMISSIVE
	vec3 diffuseBase = baseColor.rgb;
#else
	vec3 diffuseBase = vec3(0., 0., 0.);
#endif
    lightingInfo info;
	float shadow = 1.;
    float glossiness = 0.;
    
#include<lightFragment>[0..maxSimultaneousLights]

#if defined(VERTEXALPHA) || defined(INSTANCESCOLOR) && defined(INSTANCES)
	alpha *= vColor.a;
#endif

	vec3 finalDiffuse = clamp(diffuseBase * diffuseColor, 0.0, 1.0) * baseColor.rgb;

	// Composition
	vec4 color = vec4(finalDiffuse, alpha);

#include<fogFragment>

	gl_FragColor = color;

#include<imageProcessingCompatibility>

#define CUSTOM_FRAGMENT_MAIN_END
}

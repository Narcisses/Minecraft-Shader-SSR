#version 120
#include "/lib/common.glsl"
#include "/lib/water.glsl"

uniform sampler2D gcolor;

varying vec2 texcoord;

vec4 waterColor(vec3 color, vec2 texcoord) {
	vec4 finalColor = vec4(color, 1.0);

	float depth = getDepth(texcoord);
	vec3 position = getWorldPosition(texcoord, depth);
	vec3 normal = WATER_NORMAL;
	vec3 viewDir = normalize(position);
	vec3 reflectedDir = normalize(reflect(viewDir, normal));

	vec2 reflectionUV = raytrace(position, reflectedDir);
	if (reflectionUV.x > 0.0) {
		if (texture2D(colortex6, reflectionUV).r < 0.1) { // remove clouds
			vec3 reflectionColor = texture2D(gcolor, reflectionUV).rgb;
			finalColor = mix(vec4(reflectionColor, 1.0), finalColor, 0.4);
		}
	}

	return finalColor;
}

void main() {
	vec3 color = texture2D(gcolor, texcoord).rgb;

	vec4 outColor = vec4(color, 1.0);
	if (isWater(texcoord) && isEyeInWater == 0)
		outColor = waterColor(color, texcoord);

	/* DRAWBUFFERS:0 */
	gl_FragData[0] = outColor; //gcolor
}
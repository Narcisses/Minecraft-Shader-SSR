#version 120
#include "/lib/water.glsl"

uniform sampler2D lightmap;
uniform sampler2D texture;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;

void main() {
	// texture2D(texture, texcoord) * glcolor;
	vec4 color = WATER_COLOR;
	color *= texture2D(lightmap, lmcoord);

	/* DRAWBUFFERS:056 */
	gl_FragData[0] = color; //gcolor
	gl_FragData[1] = vec4(vec3(gl_FragCoord.z), 1.0);
}
#version 120

uniform sampler2D texture;

varying vec2 texcoord;
varying vec4 glcolor;

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;

/* RENDERTARGETS:0,6 */
	gl_FragData[0] = color; //gcolor
	gl_FragData[1] = vec4(1.0); //clouds mask
}
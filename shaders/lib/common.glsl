uniform float near;
uniform float far;
uniform int isEyeInWater;

uniform vec3 cameraPosition;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;

// Reserved samplers
uniform sampler2D depthtex0;

// Free samplers
uniform sampler2D colortex5;
uniform sampler2D colortex6;
uniform sampler2D colortex7;
uniform sampler2D colortex8;
uniform sampler2D colortex9;

// Functions
float linearizeDepth(float depth) 
{
    float z = depth * 2.0 - 1.0; // back to NDC 
    return ((2.0 * near * far) / (far + near - z * (far - near))) / far;	
}

float getDepth(vec2 texcoord) {
    return texture2D(depthtex0, texcoord).r;
}

bool isOutOfTexture(vec2 texcoord) {
    return (texcoord.x < 0.0 || texcoord.x > 1.0 || texcoord.y < 0.0 || texcoord.y > 1.0);
}

bool isWater(vec2 uv) {
    // Water mask in colortex5
    return texture2D(colortex5, uv).a > 0.5;
}

vec3 getWorldPosition(vec2 texcoord, float depth) {
    vec3 clipSpace = vec3(texcoord, depth) * 2.0 - 1.0;
    vec4 viewW = gbufferProjectionInverse * vec4(clipSpace, 1.0);
    vec3 viewSpace = viewW.xyz / viewW.w;
    vec4 world = gbufferModelViewInverse * vec4(viewSpace, 1.0);

    return world.xyz;
}

vec3 getUVFromPosition(vec3 position) {
    vec4 projection = gbufferProjection * gbufferModelView * vec4(position, 1.0);
    projection.xyz /= projection.w;
    vec3 clipSpace = projection.xyz * 0.5 + 0.5;

    return clipSpace.xyz;
}

float random01(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

vec2 raytrace(vec3 startPosition, vec3 reflectionDir) {
    vec3 currPos = vec3(0.0);
    vec3 currUV = vec3(0.0);
    float currLength = 10.0;
    int maxIter = 100;
    float bias = 0.00001;

    for (int i = 0; i < maxIter; i++) {
        // Get ray position
        currPos = startPosition + reflectionDir * currLength;
        // Get UV coordinates of ray
        currUV = getUVFromPosition(currPos);
        // Get depth of ray
        float currDepth = getDepth(currUV.xy);

        if (isOutOfTexture(currUV.xy)) {
            return vec2(-1);
        }

        if (abs(currUV.z - currDepth) < bias) {
            if (currDepth < 1.0)
                return currUV.xy;
            else
                return vec2(-1);
        }

        // March along ray
        vec3 newPos = getWorldPosition(currUV.xy, currDepth);
        currLength = length(newPos - startPosition);
    }

    return vec2(-2);
}

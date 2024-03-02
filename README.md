# Minecraft Water Shader with SSR

This repository illustrates how to implement screen space reflections for water in Minecraft using the Optifine/Iris pipeline. This demonstration is implemented as a Minecraft shader, however, it works on regular OpenGL/rasterization pipelines.

## Screenshots

<p float="middle">
  <img src="screenshots/shot0.png" width="49%"/>
  <img src="screenshots/shot1.png" width="49%"/>
  <img src="screenshots/shot2.png" width="49%"/>
  <img src="screenshots/shot5.png" width="49%"/>
  <img src="screenshots/shot3.png" width="49%"/>
  <img src="screenshots/shot4.png" width="49%"/>
</p>

## Method

Screen space tracing uses screen data to calculate reflections. It uses a ray marching algorithm. A ray is cast into the scene for each visible water fragment. Next, we reflect this ray on the water surface (mirror-like reflection). Finally, we trace the ray through the scene to find which fragment it collides with (if it does). The ray is cast in world space. To check whether a ray hit something, we use the depth map of the scene. We transform the world space coordinates of the current ray position into uv space coordinates using the current depth of the ray. We just check if the ray is close enough to the fragment. If the ray goes outside the texture
, or we find a cloud, we stop and discard the color.

## Algorithm

The trace function advances the ray in the scene. As the ray is cast in world space, the goal is to find where on the depth map the ray is located at. So we can verify if it hit something. Because the hit point is never going to be exact, we calculate a small interval assuming it is small enough to capture an accurate collision.

```glsl:

vec2 trace(vec3 startPos, vec3 reflecDir, float bias, int maxIter) {
    vec3 currPos = vec3(0.0);
    vec3 currUV = vec3(0.0);
    float currLength = 1.0;

    for (int i = 0; i < maxIter; i++) {
        currPos = getRayWorldSpacePosition(startPosition, reflectionDir, currLength);
        currUV = getUVFromPosition(currPos);
        float currDepth = getRayDepth(currUV.xy);
        
        // Check
        if (isOutOfTexture(currUV.xy))
            return vec2(-1);

        if (abs(currUV.z - currDepth) < bias)
                return currUV.xy;

        // March along ray (update)
        vec3 newPos = getWorldPosition(currUV.xy, currDepth);
        currLength = length(newPos - startPosition);
    }

    return vec2(-1);
}

vec3 startPos = getWaterFragmentPos(uv);
vec3 reflecDir = reflect(viewDir, waterNormal);
vec2 newUV = trace(startPos, reflecDir, 0.0001, 100);
```

One question that might arise when doing this is: Why don't we use ray tracing instead? Wy not directly calculate the hit point between the ray and the object in place of iteratively searching a hit?
Here, we use ray marching because we only have access to the nearest fragments of the scene (depth field). The depth map can be seen as a distance field. There is no concept of geometry in the fragments. We only know for each fragment, how far away from us they happen to be. We could use a hybrid ray tracing technique where we are given the geometry of the scene, and we can use it to raytrace directly. However, this involves having stored in GPU memory the entire scene.

## Thoughs

Screen space reflection is a fast and easy-to-implement way to add reflections. It is independant of the scene geometry, but suffers visible artifacts because it only uses screen data to compute reflections. Any object partly or completely outside the screen will by clipped. For example, when the player looks at his feet, the objects in front of him will vanish from the water. However, Minecraft being a game with random terrains, it exploits this technique very well. Each water block will get reflections no matter what location they are unlike for the Planer reflection technique where y-location of the water block does matter.

## Requirements

- Minecraft 1.19.4
- Optifine or Iris

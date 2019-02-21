# Unity-Shaders
Shaders I made for use in VRchat/Unity


## Dafirex's Toon Shader

Release [here](https://github.com/Dafirex/Unity-Shaders/releases)

Stuff it has
- Two variants in shading: Regular darkening and Hue shifting.
- Two styles: Toon ramp or a dithering effect
- Transitions from Realtime and Baked Lighting
- Static Light can either rotate with world or vertex normals
- Outlines only the border of the mesh

**Preview**
[![Video](https://puu.sh/BFYaY/f601dc85c4.jpg)](https://streamable.com/qmk2q)

## Triplanar Coverage 
- Triplanar Textures and Normals
- Variant that has only has the triplanar cover
- Added a variant that takes a heightmap for planes
[![Video](https://puu.sh/BMUBN/96cadbb3b6.jpg)](https://streamable.com/17yx1)


## Slime Shader
- Can set the "floor" of a mesh for the mesh to melt 
- Basic Specular lighting
- Can use a custom cubemap instead of taking in unity environment reflections
- Distorts with a distortion texture and a grabpass texture
[![Video](http://puu.sh/BT8pC/4d3b2679c8.jpg)](https://streamable.com/s76s0)

## Retro Shader
- Pixelates the grabpass texture
- Posterizes and limits palette
[![Video](http://puu.sh/BXVBr/19a38bc37c.jpg)](https://streamable.com/gqe9s)


## Depth Intersection Shader
- Creates an outline when another mesh intersects with it
- Uses depth blending

[![Video](http://dafire.xyz/p181n2.png)](https://streamable.com/18ms1)


## Kinda-Volumetric Shader (Pseudo-Volumetric?)
- **Requires the Depth Buffer**
- In terms of VRchat this can be achived by adding a real time light with shadows
- You can have the light affect a layer that doesn't light anything up to save some drawcalls 
- Uses Fresnel and Depth-fading for edge softness

[![Video](http://dafire.xyz/nG9C27.png)](https://streamable.com/j3tsx)

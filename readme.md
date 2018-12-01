# Final image competition: cel shading

## Introduction

In CSC418, the topic I am interested the most is the shader part. As a video game fan, I realized how shader could play an important role in the visual. After studying the basic shader knowledge with GLSL, I plan to create some decent effect with shader written by my own. In detail, I would like to try to create an effect of the latest Zelda game -- Breath of the wild, especially how their characters looks. Please refer to the image I 

![botw_img](http://static.gosunoob.com/img/1/2017/03/zelda-breath-of-the-wild-guides-2.jpg)
![botw_img2](https://nintendosoup.com/wp-content/uploads/2017/06/legendofzelda_botw_ss_3-1038x576.jpg)

All characters in the game are with really sharp texture and simple shadow, either bright or shaded and the overall tone has a bright color. These combined together create a really gorgerous cartoonic style. After some research, I found the visual effect is closest to the terminology called cel shading or toon shading. 

## Cel shading introduction (https://en.wikipedia.org/wiki/Cel_shading)

Cel shading is actually a type of non-photorealistic rendering technique, which uses less shading color instead of a shade gradient or tints and shades. On a more technical side, a typical cel shading is achieved two main components: shade and outlines. Shade part is done by comparing the light direction and surface normal's direction. If the relative consine is smaller than certain threshold we get a brighter and if the angle between two directions are quite large we get a shade. The outline could be done by postprocessed with edge detection techniques such as sobel filter.

## Environment - Unity Game Engine

In order to focus on the shader part rather than build everything from scratch, I use Unity game engine to help me deal with all other things except shader. Unity is a professional game engine which could handle almost all aspects relate to the game. With the help of unity, I could import the model and build the scene really quickly and decently as this is not my focus. I could also write some scripts to move the camera based on user's input, so that the demo is more interactive. Lastly, **Unity has its own shader programming language called "ShaderLab" and the actual shader code is written in a variant of HLSL language.** This enables me to customize the shader to the effect I would like to use.

## Syntax of the "shaderLab" programming language

Original source: https://docs.unity3d.com/Manual/SL-Shader.html
Although I had some expierence on shader language while doing Assignment 6. Unity's shaderlab programming language still has a very different syntax. Here are some notes containing important components of the shaderlab language when I studied its programming. Unity provides complete manual on all of its API, I also searched a lot of tutorials online:

<pre>
In unity -> shader ->  root command of a shader file. Each file must define one (and only one) Shader. It specifies how any objects whose material uses this shader are rendered.
	surface shader -> vertex plus fragment shader
	unlit shader -> empty shader?
	image effect shader -> more close to full screen effect

Shader structure:

Shader
	property
	subshader
		pass
		pass
	subshader
		…
	subshader
		…
	fallback
</pre>pre>


## Cel shading implementation in detail



// reference: https://blog.csdn.net/wolf96/article/details/43019719

Shader "Custom/CelShader" {
	Properties {
		
		_Outline("Thick of Outline",range(0,0.1)) = 0.02	
		// texture
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_ToonEffect("Toon Effect",range(0,1)) = 0.5	
		// num of layers
		_Steps("Steps of toon",range(0,9)) = 3
		// rim is the highlight on the edge
		_RimPower("RimPower",range(0,2)) = 0.5
		// num of layers of the rim
		_ToonRimStep("Steps of ToonRim",range(0,9)) = 3
	}


	SubShader{
		// 
		pass {
			Tags{ "LightMode" = "Always" }
			// Don’t render polygons facing towards the viewer.
			Cull Front
			// Controls whether pixels from this object are written to the depth buffer
			ZWrite On
			
			CGPROGRAM
			// claim vertex shader name
			#pragma vertex vert
			// claim fragment shader name
			#pragma fragment frag
			// Built-in shader include files
			#include "UnityCG.cginc"
			float _Outline;
			struct v2f {
				// SV_POSITION -> tell the engine how to move data through the graphics pipeline
				float4 pos:SV_POSITION;
			};

			// vertex shader for outline
			v2f vert(appdata_full v) {
				v2f o;
				float3 dir = normalize(v.vertex.xyz);
				float3 vnormal = v.normal;
				float D = dot(dir,vnormal);
				// find the positive or negative for the direction
				dir = dir*sign(D);
				dir = dir*0.5 + vnormal*(1 - 0.5);
				v.vertex.xyz += dir*_Outline;
				// UnityObjectToClipPos -> Transforms a point from object space to the camera's clip space in homogeneous coordinates
				o.pos = UnityObjectToClipPos(v.vertex);
				return o;
			}

			// fragment shader
			float4 frag(v2f i) :COLOR
			{
				float4 c = 0;
				return c;
			}
			ENDCG
		}

		// first pass, outline, diffuse and rim
		pass {
			Tags{ "LightMode" = "ForwardBase" }
			Cull Back
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			float4 _LightColor0;
			float _Steps;
			float _ToonEffect;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _RimPower;
			float _ToonRimStep;

			struct v2f {
				float4 pos:SV_POSITION;
				//  first UV coordinate
				float3 lightDir:TEXCOORD0;
				float3 viewDir:TEXCOORD1;
				float3 normal:TEXCOORD2;
				float2 uv:TEXCOORD3;
			};

			// initialize variables like position, normal, light direction and view direction based on basic vertex information and shader api
			v2f vert(appdata_full v) {
				v2f o;
				// world coordination
				o.pos = UnityObjectToClipPos(v.vertex);
				o.normal = v.normal;
				// ObjSpaceLightDir -> object space direction (not normalized) to light, given object space vertex position.
				o.lightDir = ObjSpaceLightDir(v.vertex);
				// ObjSpaceViewDir -> object space direction (not normalized) from given object space vertex position towards the camera.
				o.viewDir = ObjSpaceViewDir(v.vertex);
				// macro, scales and offsets texture coordinates.
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

				return o;
			}
			float4 frag(v2f i) :COLOR
			{
				float4 c = tex2D(_MainTex, i.uv);
				float3 N = normalize(i.normal);
				float3 viewDir = normalize(i.viewDir);
				float3 lightDir = normalize(i.lightDir);
				// get the diffuse
				float diffuse = max(0,dot(N,i.lightDir));
				// give diffuse light a base, to provide ambient light effect
				diffuse = (diffuse + 1) / 2;
				// smooth it to range 0 -1
				diffuse = smoothstep(0,1,diffuse);
				// change the toon to x steps
				float toon = floor(diffuse*_Steps) / _Steps;
				// lerp bthe toon effect
				diffuse = lerp(diffuse,toon,_ToonEffect);

				// rim light, saturate same as clamp
				float rim = 1.0 - saturate(dot(N, normalize(viewDir)));
				rim = rim + 1;
				// size of the edge of the tim
				rim = pow(rim, _RimPower);
				float toonRim = floor(rim * _ToonRimStep) / _ToonRimStep;
				rim = lerp(rim, toonRim, _ToonEffect);
				// mix the color
				c = c*_LightColor0*diffuse*rim;
				return c;
			}
				ENDCG
		}

		pass {
			Tags{ "LightMode" = "ForwardAdd" }
			Blend One One
			Cull Back
			ZWrite Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			float4 _LightColor0;
			float _Steps;
			float _ToonEffect;
			sampler2D _MainTex;
			float4 _MainTex_ST;

			struct v2f {
				float4 pos:SV_POSITION;
				float3 lightDir:TEXCOORD0;
				float3 viewDir:TEXCOORD1;
				float3 normal:TEXCOORD2;
				float2 uv:TEXCOORD3;
			};

			v2f vert(appdata_full v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.normal = v.normal;
				o.lightDir = ObjSpaceLightDir(v.vertex);
				o.viewDir = ObjSpaceViewDir(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

				return o;
			}
			float4 frag(v2f i) :COLOR
			{
				// load the texture
				float4 c = tex2D(_MainTex, i.uv);
				float3 N = normalize(i.normal);
				float3 viewDir = normalize(i.viewDir);
				float dist = length(i.lightDir);
				float3 lightDir = normalize(i.lightDir);
				float diffuse = max(0,dot(N,i.lightDir));
				diffuse = (diffuse + 1) / 2;
				diffuse = smoothstep(0,1,diffuse);
				float atten = 1 / (dist);
				float toon = floor(diffuse*atten*_Steps) / _Steps;
				diffuse = lerp(diffuse,toon,_ToonEffect);

				half3 h = normalize(lightDir + viewDir);
				// half vector
				float nh = max(0, dot(N, h));
				// specular light
				float specular = pow(nh, 32.0);
				float toonSpec = floor(specular*atten * 2) / 2;
				specular = lerp(specular,toonSpec,_ToonEffect);

				c = c*_LightColor0*(diffuse + specular);
				return c;
			}
				ENDCG
		}

		// shadow
		Pass{	
		Tags{ "LightMode" = "ShadowCaster" }
		CGPROGRAM
		#pragma vertex vert  
		#pragma fragment frag  
		#pragma multi_compile_shadowcaster  
		#include "UnityCG.cginc"  
		sampler2D _Shadow;

		struct v2f
		{
			V2F_SHADOW_CASTER;
		};

		v2f vert(appdata_base v)
		{
			v2f o;
			TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);
			return o;
		}

		float4 frag(v2f i) : SV_Target
		{ 
			SHADOW_CASTER_FRAGMENT(i)
		}
			ENDCG
		}
	}
}
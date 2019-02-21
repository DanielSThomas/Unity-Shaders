Shader "Dafirex/Kinda-Volumetric/LightShader v2"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		[HDR]
		_LightColor ("Light Color", Color) = (1, 1, 1, 1)
		_LightRamp ("Light Ramp", Range(-1, 1)) = .5
		_Intensity ("Ramp Intensity", Float) = 1
		_Softness ("Light Softness", Float) = 1
		_Density ("Light Density", Range(0, 1)) = .1
		_DepthBlend ("Intersection Softness", Float) = 1
		_Falloff ("Fall Off", Range(-1, 1)) = 1
	}
	SubShader
	{
		Tags { 
			"RenderType" = "Transparent" 
			"Queue" = "Transparent+1"
			"IgnoreProjector" = "True"
			}
		LOD 100
		Cull Off
		Zwrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"


			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				fixed lightRamp : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
				float4 screenPos : TEXCOORD3;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			sampler2D _CameraDepthTexture;

			fixed4 _LightColor;

			fixed _LightRamp;
			fixed _Intensity;
			fixed _Softness;
			fixed _DepthBlend;
			fixed _Falloff;
			fixed _Density;
			UNITY_INSTANCING_BUFFER_START(Props)
			UNITY_INSTANCING_BUFFER_END(Props)
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv += _Time.x * 2;
				o.lightRamp = saturate(pow(saturate(v.uv.y + _LightRamp), _Intensity));
				o.normal = v.normal;
				o.viewDir = ObjSpaceViewDir(v.vertex);
				o.screenPos = ComputeScreenPos(o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i, fixed facing : VFACE) : SV_Target
			{
				i.uv.x *= facing;
				fixed tex  = tex2D(_MainTex, i.uv);
				fixed4 col = _LightColor;
				fixed fresnel = pow(dot(normalize(i.normal * facing), normalize(i.viewDir)), _Softness) * _Density;

				//Depth Blend
				fixed4 screenPosition = float4(i.screenPos.xyz, i.screenPos.w + 0.00000000001);
				fixed4 screenNormal = screenPosition / screenPosition.w;
				fixed screenDepth = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD(screenPosition))));
				fixed distDepth = abs((screenDepth - LinearEyeDepth(screenNormal.z))) * _DepthBlend;

				i.lightRamp = lerp(tex * i.lightRamp, i.lightRamp, saturate(i.lightRamp + _Falloff));

				col.a = i.lightRamp * saturate(distDepth) * fresnel;
				//col.a = lerp(tex * col.a, col.a, saturate(col.a  +  _Falloff));


				return clamp(col, 0, 10);
			}
			ENDCG
		}
	}
}

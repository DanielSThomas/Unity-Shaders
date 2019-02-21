Shader "Dafirex/Kinda-Volumetric/Particle DepthFade"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		[HDR]
		_Color("Color", Color) = (1, 1, 1, 1)
		_Density ("Density", Float) = 1
		_DepthBlend("Blend", Range(0, 1)) = 1
		_Softness("Softness", Float) = 1

	}
	SubShader
	{
		Tags { 
			"RenderType"="Transparent"
			"Queue" = "Transparent+1"
			"IgnoreProjector"="True"
			}
		LOD 100
		ZWrite Off

		Blend SrcAlpha One
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
				float2 uv : TEXCOORD0;
				fixed4 color : COLOR;
				float3 normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
				float3 normal : NORMAL;
				fixed4 screenPos : TEXCOORD1;
				fixed4 worldPos : TEXCOORD2;
				fixed3 viewDir : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			sampler2D _MainTex;
			sampler2D _CameraDepthTexture;
			fixed4 _MainTex_ST;
			fixed _DepthBlend;
			//fixed _Density;
			fixed _Softness;
			fixed4 _Color;

			UNITY_INSTANCING_BUFFER_START(Props)
                UNITY_DEFINE_INSTANCED_PROP(fixed, _Density)
            UNITY_INSTANCING_BUFFER_END(Props)


			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.screenPos = ComputeScreenPos(o.vertex);
				o.color = v.color;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.viewDir =  ObjSpaceViewDir(v.vertex);
				o.normal = v.normal;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv) * i.color;
				fixed fresnel = pow(dot(i.normal, normalize(i.viewDir)), _Softness);

				//Depth Fade
				fixed4 screenPosition = float4(i.screenPos.xyz, i.screenPos.w + 0.00000000001);
				fixed4 screenNormal = screenPosition / screenPosition.w;
				fixed screenDepth = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD(screenPosition))));
				fixed distDepth = abs((screenDepth - LinearEyeDepth(screenNormal.z))) * _DepthBlend;
				
				fixed dist = distance(i.worldPos, _WorldSpaceCameraPos) * _DepthBlend * fresnel;

				col.a *= saturate(distDepth * dist);
				col.rgb *= _Density;
				return saturate(col) * _Color;
			}
			ENDCG
		}
	}
}

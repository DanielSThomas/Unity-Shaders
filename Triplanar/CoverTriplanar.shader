//Reference for Triplanar Blending http://www.martinpalko.com/triplanar-mapping/

Shader "Dafirex/Triplanar/Cover" {
	Properties {
		_Color ("Base Color", Color) = (1, 1, 1, 1)
		_MainTex ("Base Texture", 2D) = "white" {}

		_CoverColor("Cover Color", Color) = (1, 1, 1, 1)
		_CoverTex("Cover Texture", 2D) = "black" {}

		[Normal]
		_NormalTex("Normal Map", 2D) = "black" {}
		_NormalIntensity("Normal Intensity", Float) = 1
		_Blending("Triplanar Blending", Range(0.1, 10)) = 1
		_Coverage("Coverage", Range(0, 5)) = 0
		_CoverRamp("Coverage Ramp", Range(0.1, 3)) = 1
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _CoverTex;
		sampler2D _NormalTex;

		struct Input {
			float2 uv_MainTex;
			float2 uv_CoverTex;
			float2 uv_NormalTex;
			float3 worldNormal; INTERNAL_DATA
			float3 worldPos;

		};

		fixed4 _Color;
		fixed4 _CoverColor;
		fixed _Coverage;
		fixed _CoverRamp;

		fixed4 _CoverTex_ST;

		half _Blending;
		half _NormalIntensity;


		UNITY_INSTANCING_CBUFFER_START(Props)
		UNITY_INSTANCING_CBUFFER_END

		void surf (Input IN, inout SurfaceOutputStandard o) {
			//UVs from the projection at that axis
			fixed2 xUV = IN.worldPos.zy;
			fixed2 yUV = IN.worldPos.xz;
			fixed2 zUV = IN.worldPos.xy;

			fixed3 xCover = tex2D(_CoverTex, xUV * _CoverTex_ST.xy + _CoverTex_ST.zw);
			fixed3 yCover = tex2D(_CoverTex, yUV * _CoverTex_ST.xy + _CoverTex_ST.zw);
			fixed3 zCover = tex2D(_CoverTex, zUV * _CoverTex_ST.xy + _CoverTex_ST.zw);
			fixed3 mainDiff = _Color * tex2D(_MainTex, IN.uv_MainTex);

			o.Normal = UnpackNormal(tex2D(_NormalTex, IN.uv_NormalTex));
			float3 myWorldNormal = WorldNormalVector(IN, o.Normal);

			half3 blending = pow(abs(myWorldNormal), _Blending);
			blending = blending/(blending.x + blending.y + blending.z);
			fixed3 coverDiff = xCover * blending.x + yCover * blending.y + zCover * blending.z;

			coverDiff = _CoverColor * coverDiff;

			half coverVal = pow(clamp(myWorldNormal.y, 0, 1) * _Coverage, _CoverRamp);

			o.Albedo = clamp(lerp(mainDiff, coverDiff, clamp(coverVal, 0, 1)), 0, 1);

			o.Normal.xy *= _NormalIntensity;
			o.Normal = clamp(o.Normal, -1, 1);
			

		}
		ENDCG
	}
	FallBack "Diffuse"
}

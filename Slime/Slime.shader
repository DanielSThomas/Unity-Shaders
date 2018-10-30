// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Dafirex/Slime/Slime"
{
	Properties
	{
		_Color ("Color", Color) = (1, 1, 1, 1)
		_RimColor("Rim Color", Color) = (0, 0, 0, 0)
		_RimIntensity("Rim Intensity", Range(0, 5)) = 1
		_mySpecColor("Specular Color", Color) = (1, 1, 1, 1)
		_SpecInt("Specular Itensity", Float) = 1
		_SpecSmooth("Smoothness", Float) = 1
		_Bounce("Bounce", Float) = 1
		_DistortTex ("Texture", 2D) = "white" {}
		_DistortIntensity("Distort Intensity", Range(0, 5)) = 1
		_Speed ("Distort Speed", Float) = 1
		_SkyDistort("Distort Reflection", Float) = 5
		_SkyWeight("Reflective", Range(0, 1)) = .5
		_Banding("Banding", Float) = 1
		_BandingWeight("Banding Weight", Range(0, 1)) = .5
		_MeltVal("Melt", Float) = 0
		_MeshFloor("Floor (Feet)", Float) = 0
		_Adjustment1("Adjust 1", Float) = 0
		_Adjustment2("Adjust 2", Float) = 0

	}
	SubShader
	{
		Tags { 
			"RenderType"="Transparent"
			"Queue" = "Transparent"
			"LightMode" = "ForwardBase"}
		LOD 100

		Cull Off

		GrabPass{
			"_GrabTex"
		}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "UnityLightingCommon.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 uvGrab : TEXCOORD1;
				half3 worldRefl : TEXCOORD2;
				float2 uvVert : TEXCOORD3;
				float3 worldView : TEXCOORD4;
				float3 normal : NORMAL;
				float4 vertex : SV_POSITION;
				fixed4 diffuse : COLOR;
			};

			sampler2D _DistortTex;
			fixed4 _DistortTex_ST;
			
			sampler2D _GrabTex;

			fixed4 _Color;
			fixed4 _RimColor;
			fixed4 _mySpecColor;

			fixed _Bounce;

			fixed _RimIntensity;

			fixed _DistortIntensity;
			fixed _Speed;

			fixed _SpecInt;
			fixed _SpecSmooth;

			fixed _SkyDistort;
			fixed _SkyWeight;
			fixed _Banding;
			fixed _BandingWeight;

			fixed _MeltVal;
			fixed _MeshFloor;

			fixed _Adjustment1;
			fixed _Adjustment2;

			v2f vert (appdata v)
			{
				v2f o;

				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				//Vertex Deform
				v.vertex.y += (v.vertex.y + 1) * sin(_Time.y) * _Bounce/100;
				v.vertex.xz -= v.vertex.xz * cos(_Time.y) * _Bounce/100;

				//Height of where the vertex will start "melting"
				float melt = ( (v.vertex.y - _MeshFloor) - _MeltVal) * 20;
				melt = max(0, 1 - melt);

				//Not a very elegant solution but it works for now
				v.vertex.y -= _MeltVal;
				if(v.vertex.y < _MeshFloor)
					v.vertex.y = _MeshFloor * (1 - v.vertex.y) * _Adjustment1 - _Adjustment2;
				v.vertex.xz += (v.normal.xz * .002) * melt;

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;

				//GrabPass UVs
				o.uvGrab = ComputeScreenPos(o.vertex);
				COMPUTE_EYEDEPTH(o.uvGrab.z);

				//Lighting

				half nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
				o.diffuse = saturate((nl * _LightColor0) + .5);

				//World Reflection
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				fixed4 rim = 1 - saturate(dot(normalize(worldViewDir), worldNormal));
				o.worldRefl = reflect(-worldViewDir, worldNormal);


				rim = pow(rim, 2) * _RimIntensity * _RimColor;

				o.normal = worldNormal;
				o.uvVert = v.vertex.y;
				o.diffuse += clamp(0, 5, rim);
				o.worldView = worldViewDir;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				half time = _Time.x * _Speed;
				float2 sceneUVs = (i.uvGrab.xy / i.uvGrab.w);
				fixed distort = tex2D(_DistortTex, float2(i.uv.x, i.uv.y + time) * _DistortTex_ST.xy + _DistortTex_ST.zw) * (_DistortIntensity / 100);

				fixed3 h = normalize(_WorldSpaceLightPos0.xyz + i.worldView);
				fixed nh = max(0, dot(i.normal, h));
				fixed4 spec = saturate(pow(nh, _SpecInt * 20) * _SpecSmooth) * _mySpecColor;


				fixed4 c = tex2D(_GrabTex, sceneUVs + distort) * _Color * i.diffuse * max(.4, unity_AmbientSky);
				half4 skyData = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, i.worldRefl + distort * _SkyDistort);
				half3 skyColor = DecodeHDR (skyData, unity_SpecCube0_HDR) * _SkyWeight;

				fixed banding = tex2D(_DistortTex, i.uvVert  + distort * _Banding + time);
				banding = saturate(banding + (1 - _BandingWeight));
				c.rgb += skyColor + spec;
				c.rgb *= banding;
				return saturate(c);
			}
			ENDCG
		}
	}
}

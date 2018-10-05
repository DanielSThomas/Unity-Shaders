// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Dafirex/No Silhouette/Dafirex HSL"
{
	Properties
	{
		_MainTex("_MainTex", 2D) = "white" {}
		_Color("_Color", Color) = (1,1,1,0)
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_EmissionMap("Emission Map", 2D) = "black" {}
		_EmisionColor("Emision Color", Color) = (0,0,0,0)
		_EmissionIntensity("Emission Intensity", Float) = 1
		_Ramp("_Ramp", 2D) = "white" {}
		_RampAdjust("Ramp Adjust", Range( 0 , 2)) = 1
		_Saturation("Saturation", Range( 0 , 2)) = 1
		_ShadeSaturation("Shade Saturation", Range( 0 , 3)) = 0.3
		_ShadeIntensity("Shade Intensity", Range( 0 , 1)) = 1
		[Toggle]_WarmCold("Warm/Cold", Float) = 0
		[Toggle]_StaticLightRotate("Static Light Rotate", Float) = 0
		_StaticLightX("Static Light X", Range( -1 , 1)) = 0.5
		_StaticLightY("Static Light Y", Range( -1 , 1)) = 0.5
		_StaticLightZ("Static Light Z", Range( -1 , 1)) = 0.8
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Off
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 5.0
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform sampler2D _EmissionMap;
		uniform float4 _EmissionMap_ST;
		uniform float4 _EmisionColor;
		uniform float _EmissionIntensity;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float _WarmCold;
		uniform float4 _Color;
		uniform float _ShadeIntensity;
		uniform sampler2D _Ramp;
		uniform float _StaticLightX;
		uniform float _StaticLightY;
		uniform float _StaticLightZ;
		uniform float _StaticLightRotate;
		uniform float _RampAdjust;
		uniform float _ShadeSaturation;
		uniform float _Saturation;
		uniform float _Cutoff = 0.5;


		float3 HSVToRGB( float3 c )
		{
			float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
			float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
			return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
		}


		float3 RGBToHSV(float3 c)
		{
			float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
			float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
			float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
			float d = q.x - min( q.w, q.y );
			float e = 1.0e-10;
			return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
		}

		float3 somehowgivesbakedlightscolorsidklmao234( float3 x )
		{
			return ShadeSH9(half4(x, 1));
		}


		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode10 = tex2D( _MainTex, uv_MainTex );
			float3 hsvTorgb83 = RGBToHSV( ( tex2DNode10 * _Color ).rgb );
			float4 temp_cast_3 = (hsvTorgb83.x).xxxx;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 appendResult248 = (float3(_StaticLightX , _StaticLightY , _StaticLightZ));
			float3 ase_worldNormal = i.worldNormal;
			float3 ase_normWorldNormal = normalize( ase_worldNormal );
			float3 ase_vertexNormal = mul( unity_WorldToObject, float4( ase_worldNormal, 0 ) );
			float dotResult5 = dot( (( ase_lightColor.rgb > float4( 0,0,0,0 ) ) ? ase_worldlightDir :  appendResult248 ) , lerp(ase_normWorldNormal,ase_vertexNormal,_StaticLightRotate) );
			float temp_output_55_0 = ( dotResult5 * _RampAdjust * (( ase_lightColor.r > float4( 0,0,0,0 ) ) ? (( ase_lightAtten < 1.0 ) ? ase_lightAtten :  1.0 ) :  1.0 ) );
			float4 appendResult73 = (float4(temp_output_55_0 , temp_output_55_0 , 0.0 , 0.0));
			float4 clampResult30 = clamp( tex2D( _Ramp, appendResult73.xy ) , float4( 0,0,0,0 ) , float4( 0.7843137,0.7843137,0.7843137,0 ) );
			float4 temp_output_106_0 = ( 1.0 - clampResult30 );
			float4 temp_output_111_0 = ( _ShadeIntensity * float4( 0.05,0,0,0 ) * temp_output_106_0 );
			float3 hsvTorgb85 = HSVToRGB( float3(lerp(( temp_cast_3 - temp_output_111_0 ),( hsvTorgb83.x + temp_output_111_0 ),_WarmCold).r,( ( hsvTorgb83.y + ( _ShadeIntensity * _ShadeSaturation * temp_output_106_0 ) ) * _Saturation ).r,hsvTorgb83.z) );
			float3 clampResult164 = clamp( hsvTorgb85 , float3( 0,0,0 ) , float3( 1,1,1 ) );
			float4 appendResult300 = (float4(ase_lightAtten , ase_lightAtten , 0.0 , 0.0));
			float3 x234 = float3( 0,1,0.5 );
			float3 localsomehowgivesbakedlightscolorsidklmao234 = somehowgivesbakedlightscolorsidklmao234( x234 );
			float4 clampResult309 = clamp( ( ( ase_lightColor * tex2D( _Ramp, appendResult300.xy ) ) + float4( localsomehowgivesbakedlightscolorsidklmao234 , 0.0 ) ) , float4( 0,0,0,0 ) , float4( 1,1,1,0 ) );
			c.rgb = ( float4( clampResult164 , 0.0 ) * clampResult309 ).rgb;
			c.a = 1;
			clip( tex2DNode10.a - _Cutoff );
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			float2 uv_EmissionMap = i.uv_texcoord * _EmissionMap_ST.xy + _EmissionMap_ST.zw;
			float4 temp_cast_0 = (3.0).xxxx;
			float4 clampResult303 = clamp( ( tex2D( _EmissionMap, uv_EmissionMap ) * _EmisionColor * _EmissionIntensity ) , float4( 0,0,0,0 ) , temp_cast_0 );
			o.Emission = clampResult303.rgb;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows exclude_path:deferred 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 5.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT( UnityGI, gi );
				o.Alpha = LightingStandardCustomLighting( o, worldViewDir, gi ).a;
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15401
48;166;1343;727;837.9338;-178.1826;1.302511;True;False
Node;AmplifyShaderEditor.CommentaryNode;281;-3531.962,-687.9551;Float;False;995.3269;488.7777;Uses realtime light or uses the static light direction;7;249;251;252;248;280;277;3;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;249;-3488.358,-635.4621;Float;False;Property;_StaticLightX;Static Light X;13;0;Create;True;0;0;False;0;0.5;0.5;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;252;-3485.074,-444.588;Float;False;Property;_StaticLightZ;Static Light Z;15;0;Create;True;0;0;False;0;0.8;0.8;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;251;-3489.053,-554.3785;Float;False;Property;_StaticLightY;Static Light Y;14;0;Create;True;0;0;False;0;0.5;0.5;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;248;-3138.694,-649.634;Float;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LightAttenuation;285;-2705.844,172.934;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;277;-3089.41,-325.862;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;3;-3179.909,-493.2264;Float;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalVertexDataNode;262;-3009.006,76.17512;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;261;-3011.997,-69.89998;Float;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LightColorNode;289;-2414.316,415.6767;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.TFHCCompareGreater;280;-2825.636,-544.7672;Float;False;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ToggleSwitchNode;263;-2775.9,17.61696;Float;False;Property;_StaticLightRotate;Static Light Rotate;12;0;Create;True;0;0;False;0;0;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TFHCCompareLower;288;-2462.415,206.4895;Float;False;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCCompareGreater;290;-2191.636,267.7879;Float;False;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;5;-2456.165,-168.0968;Float;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;149;-2522.504,66.37428;Float;False;Property;_RampAdjust;Ramp Adjust;7;0;Create;True;0;0;False;0;1;0.9;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-2141.293,-57.01952;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;73;-1829.736,55.9029;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;32;-1993.803,324.1268;Float;True;Property;_Ramp;_Ramp;6;0;Create;True;0;0;False;0;None;8488b3eee1dc36142b1551f6aaa3ee17;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;30;-1419.72,631.4575;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0.7843137,0.7843137,0.7843137,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;239;-1263.853,-131.829;Float;False;1328.867;582.1025;Comment;11;299;294;302;301;300;199;237;258;234;225;309;Lighting Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.WireNode;118;-1611.797,134.9485;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightAttenuation;294;-1225.886,-27.89556;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;10;-1655.432,-1239.011;Float;True;Property;_MainTex;_MainTex;0;0;Create;True;0;0;False;0;None;defe16a92b392a343bdc030ab7160854;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;18;-1637.971,-905.2185;Float;False;Property;_Color;_Color;1;0;Create;True;0;0;False;0;1,1,1,0;1,1,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;106;-1551.366,79.22308;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;300;-1014.009,-47.23818;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;162;-1898.775,-444.8342;Float;False;Property;_ShadeSaturation;Shade Saturation;9;0;Create;True;0;0;False;0;0.3;0.25;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-1333.638,-1210.018;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;96;-1898.734,-627.2397;Float;False;Property;_ShadeIntensity;Shade Intensity;10;0;Create;True;0;0;False;0;1;0.87;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;115;-1634.929,-55.87708;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;301;-895.6475,121.5931;Float;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;131;-1569.659,-449.0263;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0.7;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RGBToHSVNode;83;-1295.033,-861.3649;Float;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;111;-1568.147,-598.5816;Float;False;3;3;0;FLOAT;0;False;1;COLOR;0.05,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;302;-1207.641,75.37742;Float;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;102;-1241.99,-601.6577;Float;False;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;109;-1223.423,-492.4377;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;100;-1279.755,-376.4352;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;103;-1483.232,-267.9441;Float;False;Property;_Saturation;Saturation;8;0;Create;True;0;0;False;0;1;1.5;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;225;-762.7206,-6.430265;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;299;-1222.378,148.2296;Float;True;Property;_TextureSample0;Texture Sample 0;6;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Instance;32;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ToggleSwitchNode;148;-967.4579,-529.7657;Float;False;Property;_WarmCold;Warm/Cold;11;0;Create;True;0;0;False;0;0;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;94;-1069.7,-350.9566;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CustomExpressionNode;234;-828.1705,266.4975;Float;False;return ShadeSH9(half4(x, 1))@;3;False;1;True;x;FLOAT3;0,1,0.5;In;;somehow gives baked lights colors idk lmao;True;False;1;0;FLOAT3;0,1,0.5;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;258;-508.0536,62.93106;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;306;-118.907,-516.5845;Float;False;Property;_EmissionIntensity;Emission Intensity;5;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;85;-715.6327,-560.3672;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;305;-187.7556,-872.4777;Float;True;Property;_EmissionMap;Emission Map;3;0;Create;True;0;0;False;0;None;a0b97067a1b24724e8bcb35f53810690;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;237;-439.0132,175.6135;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;304;-105.2025,-685.778;Float;False;Property;_EmisionColor;Emision Color;4;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;307;184.4433,-595.6995;Float;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;164;-284.4155,-395.9519;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;1,1,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;309;-225.7537,255.0309;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;308;-40.16985,-389.7115;Float;False;Constant;_MaxHDRValue;Max HDR Value;18;0;Create;True;0;0;False;0;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;199;-134.1543,88.26037;Float;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;303;206.4301,-309.5114;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;9;268.4092,-126.992;Float;False;True;7;Float;ASEMaterialInspector;0;0;CustomLighting;Dafirex/No Silhouette/Dafirex HSL;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;TransparentCutout;;Geometry;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;-1;False;-1;-1;False;-1;0;False;0.04;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;2;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;248;0;249;0
WireConnection;248;1;251;0
WireConnection;248;2;252;0
WireConnection;280;0;277;0
WireConnection;280;2;3;0
WireConnection;280;3;248;0
WireConnection;263;0;261;0
WireConnection;263;1;262;0
WireConnection;288;0;285;0
WireConnection;288;2;285;0
WireConnection;290;0;289;0
WireConnection;290;2;288;0
WireConnection;5;0;280;0
WireConnection;5;1;263;0
WireConnection;55;0;5;0
WireConnection;55;1;149;0
WireConnection;55;2;290;0
WireConnection;73;0;55;0
WireConnection;73;1;55;0
WireConnection;32;1;73;0
WireConnection;30;0;32;0
WireConnection;118;0;30;0
WireConnection;106;0;118;0
WireConnection;300;0;294;0
WireConnection;300;1;294;0
WireConnection;19;0;10;0
WireConnection;19;1;18;0
WireConnection;115;0;106;0
WireConnection;301;0;300;0
WireConnection;131;0;96;0
WireConnection;131;1;162;0
WireConnection;131;2;106;0
WireConnection;83;0;19;0
WireConnection;111;0;96;0
WireConnection;111;2;115;0
WireConnection;302;0;301;0
WireConnection;102;0;83;1
WireConnection;102;1;111;0
WireConnection;109;0;83;1
WireConnection;109;1;111;0
WireConnection;100;0;83;2
WireConnection;100;1;131;0
WireConnection;299;1;302;0
WireConnection;148;0;102;0
WireConnection;148;1;109;0
WireConnection;94;0;100;0
WireConnection;94;1;103;0
WireConnection;258;0;225;0
WireConnection;258;1;299;0
WireConnection;85;0;148;0
WireConnection;85;1;94;0
WireConnection;85;2;83;3
WireConnection;237;0;258;0
WireConnection;237;1;234;0
WireConnection;307;0;305;0
WireConnection;307;1;304;0
WireConnection;307;2;306;0
WireConnection;164;0;85;0
WireConnection;309;0;237;0
WireConnection;199;0;164;0
WireConnection;199;1;309;0
WireConnection;303;0;307;0
WireConnection;303;2;308;0
WireConnection;9;2;303;0
WireConnection;9;10;10;4
WireConnection;9;13;199;0
ASEEND*/
//CHKSM=A687DB75C2D7FF656A373888795896F0FEF63696
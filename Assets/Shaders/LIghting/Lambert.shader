Shader "Unlit/Lambert"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            //float 32 bit
            //half  16 bit
            //fixed -2 to 2
            fixed4 frag (v2f i) : SV_Target
            {
                float3 N = normalize(i.normal);
                //_WorldSpaceLightPos0 says its a position, but its actually a direction
                float3 L = _WorldSpaceLightPos0.xyz;
                float3 lambert = max(float3(0.01,0.01,0.03), dot(N,L));
                //saturate(dot(N,L));

                fixed4 col = tex2D(_MainTex, i.uv); //fixed4(0.1,0.2,0.1,1);
                
                float3 diffuseLight = lambert * _LightColor0.xyz * col;

                return float4(diffuseLight, 1);
            }
            ENDCG
        }
    }
}

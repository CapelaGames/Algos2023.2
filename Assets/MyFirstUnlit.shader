Shader "Unlit/MyFirstUnlit"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        _healthBarColorFull ("HealthBar Full", Color) = (0,1,0,1)
        _healthBarColorEmpty ("HealthBar Empty", Color) = (1,0,0,1)
        _healthBarColorBackground ("HealthBar Background", Color) = (0.1,0.1,0.1,1)
        
        _health ("Health", Range(0,1)) = 1
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

            struct appdata //mesh data
            {
                float4 vertex : POSITION; // Vertex Position
                float2 uv : TEXCOORD0; //uv0 coordinates
                float2 uv1 : TEXCOORD1; //uv1 coordinates, usually lighting
                float3 normal : NORMAL;
                float3 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _healthBarColorFull;
            float4 _healthBarColorEmpty;
            float4 _healthBarColorBackground;
            float _health;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.vertex.y += ( 1 - _health) * (cos(_Time.y * 10 ) * 0.005) * (_health < 0.2);
                o.uv = v.uv; //TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = normalize(mul((float3x3) unity_ObjectToWorld,v.normal));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                

                
                //Changes colours based on health
                float4 healthBarColor = lerp(_healthBarColorEmpty,_healthBarColorFull, _health);
                
                //Creates the bar based on uvs
                bool t = _health > i.uv.x;
                //healthBarSteps
                float healthBarSteps = _health > floor(i.uv.x * 8)/8;
                
                float4 outColor = lerp(_healthBarColorBackground, healthBarColor , t);
                
                return outColor;
            }
            
            ENDCG
        }
    }
}

Shader "Unlit/Stripes"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Slider ("Slider Value", Range(0,10)) = 0.5
        _ColorA("ColorA", Color) = (0,0,0,1)
        _ColorB("ColorB", Color) = (1,1,1,1)
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

            //#define TAU         6.283185307179586
            #define TAU         UNITY_TWO_PI
            #define HALF_TAU    TAU * 0.5
           

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 worldPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Slider;
            float4 _ColorA;
            float4 _ColorB;

            float4 candy_stripes(float x)
            {
                float t = cos(x * TAU * 10) * 0.5 + 0.5;
                float4 out_color = lerp(_ColorA, _ColorB, t );
                return out_color;
            }

            /*float chess_board(float x)//float y
            {
               // floor(x);

               // return chess_board;
            }*/
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float chess_board = floor(i.worldPos.x * _Slider) + floor(i.worldPos.y * _Slider) + floor(i.worldPos.z * _Slider);
                chess_board = frac(chess_board * 0.5);
                chess_board *= 2;
                return chess_board.xxxx;

                
                //return candy_stripes(i.uv.x);
                
                // fixed4 col = tex2D(_MainTex, i.uv);
                // return col;
            }
            ENDCG
        }
    }
}

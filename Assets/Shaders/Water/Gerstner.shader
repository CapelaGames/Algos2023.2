Shader "Custom/Gerstner"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        //_Amplitude ("Amplitude", Float) = 1
        //_Steepness ("Steepness", Range(0,1)) = 0.5
       // _Wavelength ("Wavelength", Float) = 10
        _Speed ("Speed", Float) = 1
        //_Direction ("Direction (2D)", Vector) = ( 1,0,0,0)
        
        _WaveA("Wave A (dir, steepness, wavelength)", Vector ) = (1, 0, 0.5 , 10)
        _WaveB("Wave B (dir, steepness, wavelength)", Vector ) = (0, 1, 0.25 , 20)
        _WaveC("Wave C (dir, steepness, wavelength)", Vector ) = (1, 1, 0.15 , 10)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert addshadow

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float _Speed;//_Steepness, _Wavelength, 
        float4 _WaveA, _WaveB, _WaveC;
        //float2 _Direction;
        //_WaveA("Wave A (dir, steepness, wavelength)", Vector ) = (1, 0, 0.5 , 10)
        //_WaveB("Wave B (dir, steepness, wavelength)", Vector ) = (0, 1, 0.25 , 20)
        //_WaveC("Wave C (dir, steepness, wavelength)", Vector ) = (1, 1, 0.15 , 10)

        float3 GerstnerWave(float4 wave, float3 position, inout float3 tangent, inout float3 binormal)
        {
            float steepness = wave.z;
            float wavelength = 2 * UNITY_PI / wave.w;
            float speed = sqrt(9.8/wavelength) * _Speed;
            float2 direction = normalize(wave.xy);
            float f = wavelength * (dot(direction, position.xz) - speed * _Time.y);
            float amplitude = steepness / wavelength;
            /*position.x += direction.x * amplitude * cos(f);
            position.y = amplitude * sin(f);
            position.z += direction.y * (amplitude * cos(f));*/
            
            tangent += float3(
                    -direction.x * direction.x * (steepness * sin(f)),
                    direction.x * (steepness * cos(f)),
                    -direction.x * direction.y * (steepness * sin(f))
                );

            binormal += float3(
                    -direction.x * direction.y * (steepness * sin(f)),
                    direction.y * (steepness * cos(f)),
                    -direction.y * direction.y * (steepness * sin(f))
                );
            
            return float3(
                direction.x * amplitude * cos(f),
                amplitude * sin(f),
                direction.y * (amplitude * cos(f))
                );
        }

        
        void vert(inout appdata_full vertexData)
        {
            float3 position = vertexData.vertex.xyz;
            float3 tangent = float3(1,0,0);
            float3 binormal = float3(0,0,1);
            float3 superPosition = position;
            
            superPosition += GerstnerWave(_WaveA, position, tangent, binormal);
            superPosition += GerstnerWave(_WaveB, position, tangent, binormal);
            superPosition += GerstnerWave(_WaveC, position, tangent, binormal);
            
            float3 normal = normalize(cross(binormal,tangent));
            
            vertexData.vertex.xyz = superPosition;
            vertexData.normal = normal;
            
        }
        
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}

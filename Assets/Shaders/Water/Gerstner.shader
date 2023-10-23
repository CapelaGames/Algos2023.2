Shader "Custom/Gerstner"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        //_Amplitude ("Amplitude", Float) = 1
        _Steepness ("Steepness", Range(0,1)) = 0.5
        _Wavelength ("Wavelength", Float) = 10
        _Speed ("Speed", Float) = 1
        _Direction ("Direction (2D)", Vector) = ( 1,0,0,0)
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
        float _Steepness, _Wavelength, _Speed;
        
        float2 _Direction;
        //_Direction ("Direction (2D)", Vector) = ( 1,0,0,0)
        
        void vert(inout appdata_full vertexData)
        {
            float3 position = vertexData.vertex.xyz;

            float wavelength = 2 * UNITY_PI / _Wavelength;
            float speed = sqrt(9.8/wavelength) * _Speed;
            float2 direction = normalize(_Direction);
            float f = wavelength * (dot(direction, position.xz) - speed * _Time.y);
            float amplitude = _Steepness / wavelength;
            position.x += direction * amplitude * cos(f);
            position.y = amplitude * sin(f);
            position.z += direction.y * (amplitude * cos(f));
            
            float3 tangent = float3(
                    1 - direction.x * direction.x * (_Steepness * sin(f)),
                    direction.x * (_Steepness * cos(f)),
                    -direction.x * direction.y * (_Steepness * sin(f))
                );

            float3 binormal = float3(
                    -direction.x * direction.y * (_Steepness * sin(f)),
                    direction.y * (_Steepness * cos(f)),
                    1 - direction.y * direction.y * (_Steepness * sin(f))
                );
            
            float3 normal = normalize(cross(binormal,tangent));
            
            vertexData.vertex.xyz = position;
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

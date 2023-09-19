Shader "Unlit/MultiLight"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Gloss ("Gloss", Range(0,1)) = 1
        _Color ("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue" = "Geometry" }

        //Base pass
        Pass
        {
            Tags {"LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "IncLighting.cginc"
            ENDCG
        }
        //Additional pass
        Pass
        {
            Blend One One
            Tags {"LightMode" = "ForwardAdd"}
            CGPROGRAM
            #pragma multi_compile_fwdadd
            #pragma vertex vert
            #pragma fragment frag
            #include "IncLighting.cginc"
            ENDCG
        }
    }
}

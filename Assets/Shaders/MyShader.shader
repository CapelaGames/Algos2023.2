Shader "ShaderMan/MyShader"
{
    Properties {}
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent" "Queue" = "Transparent"
        }
        Pass
        {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"


            float4 vec4(float x, float y, float z, float w) { return float4(x, y, z, w); }
            float4 vec4(float x) { return float4(x, x, x, x); }
            float4 vec4(float2 x, float2 y) { return float4(float2(x.x, x.y), float2(y.x, y.y)); }
            float4 vec4(float3 x, float y) { return float4(float3(x.x, x.y, x.z), y); }


            float3 vec3(float x, float y, float z) { return float3(x, y, z); }
            float3 vec3(float x) { return float3(x, x, x); }
            float3 vec3(float2 x, float y) { return float3(float2(x.x, x.y), y); }

            float2 vec2(float x, float y) { return float2(x, y); }
            float2 vec2(float x) { return float2(x, x); }

            float vec(float x) { return float(x); }


            struct VertexInput
            {
                float4 vertex : POSITION;
                float2 uv:TEXCOORD0;
                float4 tangent : TANGENT;
                float3 normal : NORMAL;
                //VertexInput
            };

            struct VertexOutput
            {
                float4 pos : SV_POSITION;
                float2 uv:TEXCOORD0;
                //VertexOutput
            };


            VertexOutput vert(VertexInput v)
            {
                VertexOutput o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                //VertexFactory
                return o;
            }

            /*
         * "Seascape" by Alexander Alekseev aka TDM - 2014
         * License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
         * Contact: tdmaav@gmail.com
         */

            const int NUM_STEPS = 8;
            const float PI = 3.141592;
            const float EPSILON = 1e-3;
            #define EPSILON_NRM (0.1 / 1)
            #define AA

            // sea
            const int ITER_GEOMETRY = 3;
            const int ITER_FRAGMENT = 5;
            const float SEA_HEIGHT = 0.6;
            const float SEA_CHOPPY = 4.0;
            const float SEA_SPEED = 0.8;
            const float SEA_FREQ = 0.16;
            const float3 SEA_BASE = (0.0, 0.09, 0.18);
            const float3 SEA_WATER_COLOR = (0.8, 0.9, 0.6) * 0.6;
            #define SEA_TIME (1.0 + _Time.y * SEA_SPEED)
            const float4x4 octave_m = (1.6, 1.2, -1.2, 1.6);

            // math
            float3x3 fromEuler(float3 ang)
            {
                float2 a1 = vec2(sin(ang.x), cos(ang.x));
                float2 a2 = vec2(sin(ang.y), cos(ang.y));
                float2 a3 = vec2(sin(ang.z), cos(ang.z));
                float3x3 m;
                m[0] = vec3(a1.y * a3.y + a1.x * a2.x * a3.x, a1.y * a2.x * a3.x + a3.y * a1.x, -a2.y * a3.x);
                m[1] = vec3(-a2.y * a1.x, a1.y * a2.y, a2.x);
                m[2] = vec3(a3.y * a1.x * a2.x + a1.y * a3.x, a1.x * a3.x - a1.y * a3.y * a2.x, a2.y * a3.y);
                return m;
            }

            float hash(float2 p)
            {
                float h = dot(p, vec2(127.1, 311.7));
                return frac(sin(h) * 43758.5453123);
            }

            float noise(in float2 p)
            {
                float2 i = floor(p);
                float2 f = frac(p);
                float2 u = f * f * (3.0 - 2.0 * f);
                return -1.0 + 2.0 * lerp(lerp(hash(i + vec2(0.0, 0.0)),
                                              hash(i + vec2(1.0, 0.0)), u.x),
                                         lerp(hash(i + vec2(0.0, 1.0)),
                                              hash(i + vec2(1.0, 1.0)), u.x), u.y);
            }

            // lighting
            float diffuse(float3 n, float3 l, float p)
            {
                return pow(dot(n, l) * 0.4 + 0.6, p);
            }

            float specular(float3 n, float3 l, float3 e, float s)
            {
                float nrm = (s + 8.0) / (PI * 8.0);
                return pow(max(dot(reflect(e, n), l), 0.0), s) * nrm;
            }

            // sky
            float3 getSkyColor(float3 e)
            {
                e.y = (max(e.y, 0.0) * 0.8 + 0.2) * 0.8;
                return vec3(pow(1.0 - e.y, 2.0), 1.0 - e.y, 0.6 + (1.0 - e.y) * 0.4) * 1.1;
            }

            // sea
            float sea_octave(float2 uv, float choppy)
            {
                uv += noise(uv);
                float2 wv = 1.0 - abs(sin(uv));
                float2 swv = abs(cos(uv));
                wv = lerp(wv, swv, wv);
                return pow(1.0 - pow(wv.x * wv.y, 0.65), choppy);
            }

            float map(float3 p)
            {
                float freq = SEA_FREQ;
                float amp = SEA_HEIGHT;
                float choppy = SEA_CHOPPY;
                float2 uv = p.xz;
                uv.x *= 0.75;

                float d, h = 0.0;
                [unroll(100)]
                for (int i = 0; i < ITER_GEOMETRY; i++)
                {
                    d = sea_octave((uv + SEA_TIME) * freq, choppy);
                    d += sea_octave((uv - SEA_TIME) * freq, choppy);
                    h += d * amp;
                    uv = mul(octave_m, uv);
                    freq *= 1.9;
                    amp *= 0.22;
                    choppy = lerp(choppy, 1.0, 0.2);
                }
                return p.y - h;
            }

            float map_detailed(float3 p)
            {
                float freq = SEA_FREQ;
                float amp = SEA_HEIGHT;
                float choppy = SEA_CHOPPY;
                float2 uv = p.xz;
                uv.x *= 0.75;

                float d, h = 0.0;
                [unroll(100)]
                for (int i = 0; i < ITER_FRAGMENT; i++)
                {
                    d = sea_octave((uv + SEA_TIME) * freq, choppy);
                    d += sea_octave((uv - SEA_TIME) * freq, choppy);
                    h += d * amp;
                    uv = mul(octave_m, uv);
                    freq *= 1.9;
                    amp *= 0.22;
                    choppy = lerp(choppy, 1.0, 0.2);
                }
                return p.y - h;
            }

            float3 getSeaColor(float3 p, float3 n, float3 l, float3 eye, float3 dist)
            {
                float fresnel = clamp(1.0 - dot(n, -eye), 0.0, 1.0);
                fresnel = min(pow(fresnel, 3.0), 0.5);

                float3 reflected = getSkyColor(reflect(eye, n));
                float3 refracted = SEA_BASE + diffuse(n, l, 80.0) * SEA_WATER_COLOR * 0.12;

                float3 color = lerp(refracted, reflected, fresnel);

                float atten = max(1.0 - dot(dist, dist) * 0.001, 0.0);
                color += SEA_WATER_COLOR * (p.y - SEA_HEIGHT) * 0.18 * atten;

                color += vec3(specular(n, l, eye, 60.0));

                return color;
            }

            // tracing
            float3 getNormal(float3 p, float eps)
            {
                float3 n;
                n.y = map_detailed(p);
                n.x = map_detailed(vec3(p.x + eps, p.y, p.z)) - n.y;
                n.z = map_detailed(vec3(p.x, p.y, p.z + eps)) - n.y;
                n.y = eps;
                return normalize(n);
            }

            float heightMapTracing(float3 ori, float3 dir, out float3 p)
            {
                float tm = 0.0;
                float tx = 1000.0;
                float hx = map(ori + dir * tx);
                if (hx > 0.0)
                {
                    p = ori + dir * tx;
                    return tx;
                }
                float hm = map(ori + dir * tm);
                float tmid = 0.0;
                [unroll(100)]
                for (int i = 0; i < NUM_STEPS; i++)
                {
                    tmid = lerp(tm, tx, hm / (hm - hx));
                    p = ori + dir * tmid;
                    float hmid = map(p);
                    if (hmid < 0.0)
                    {
                        tx = tmid;
                        hx = hmid;
                    }
                    else
                    {
                        tm = tmid;
                        hm = hmid;
                    }
                }
                return tmid;
            }

            float3 getPixel(in float2 coord, float time)
            {
                float2 uv = coord / 1;
                uv = uv * 2.0 - 1.0;
                uv.x *= 1 / 1;

                // ray
                float3 ang = vec3(sin(time * 3.0) * 0.1, sin(time) * 0.2 + 0.3, time);
                float3 ori = vec3(0.0, 3.5, time * 5.0);
                float3 dir = normalize(vec3(uv.xy, -2.0));
                dir.z += length(uv) * 0.14;
                dir = mul( normalize(dir) , fromEuler(ang));

                // tracing
                float3 p;
                heightMapTracing(ori, dir, p);
                float3 dist = p - ori;
                float3 n = getNormal(p, dot(dist, dist) * EPSILON_NRM);
                float3 light = normalize(vec3(0.0, 1.0, 0.8));

                // color
                return lerp(
                    getSkyColor(dir),
                    getSeaColor(p, n, light, dir, dist),
                    pow(smoothstep(0.0, -0.02, dir.y), 0.2));
            }

            // main


            fixed4 frag(VertexOutput vertex_output) : SV_Target
            {
                float time = _Time.y * 0.3;

                #ifdef AA
                float3 color = vec3(0.0);
                [unroll(100)]
                for (int i = -1; i <= 1; i++)
                {
                    [unroll(100)]
                    for (int j = -1; j <= 1; j++)
                    {
                        float2 uv = vertex_output.uv + vec2(i, j) / 3.0;
                        color += getPixel(uv, time);
                    }
                }
                color /= 9.0;
                #else
    float3 color = getPixel(vertex_output.uv, time);
                #endif

                // post
                return vec4(pow(color, vec3(0.65)), 1.0);
            }
            ENDCG
        }
    }
}
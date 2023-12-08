Shader "Universal Render Pipeline/ScreenSpaceBoolean/Mask"
{

    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline" "Queue"="Geometry"
        }

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"


        struct input
        {
            float4 vertex : POSITION;
        };

        struct output
        {
            float4 vertex : SV_POSITION;
            float4 spos : TEXCOORD0;
        };

        TEXTURE2D(_SubtracteeBackDepth);
        SAMPLER(sampler_SubtracteeBackDepth);

        float ComputeDepth(float4 spos)
        {
            #if defined(UNITY_UV_STARTS_AT_TOP)
            return (spos.z / spos.w);
            #else
                return (spos.z / spos.w) * 0.5 + 0.5;
            #endif
        }

        output vert(input v)
        {
            output o;
            o.vertex = TransformObjectToHClip(v.vertex);
            o.spos = ComputeScreenPos(o.vertex);
            return o;
        }

        float4 frag(output i) : SV_Target
        {
            return ComputeDepth(i.spos);
        }

        float depth(output i) : SV_Target
        {
            float2 uv = i.spos.xy / i.spos.w;
            float subtracteeBackDepth = SAMPLE_TEXTURE2D(_SubtracteeBackDepth, sampler_SubtracteeBackDepth, uv);
            float subtractorBackDepth = ComputeDepth(i.spos);

            #if defined(UNITY_REVERSED_Z)
            if (subtractorBackDepth >= subtracteeBackDepth) discard;
            return 0;
            #else
                if (subtractorBackDepth <= subtracteeBackDepth) discard;
                    return 1;
            #endif

            return 0;
        }
        ENDHLSL

        Pass
        {
            Stencil
            {
                Ref 1
                Comp Always
                Pass Replace
            }

            Cull Back
            ZTest Less
            ZWrite Off
            ColorMask 0

            HLSLPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            ENDHLSL
        }

        Pass
        {
            Stencil
            {
                Ref 1
                Comp Equal
            }

            Cull Front
            ZTest Greater
            ZWrite On

            HLSLPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            ENDHLSL
        }

        Pass
        {
            Stencil
            {
                Ref 1
                Comp Equal
            }

            Cull Front
            ZTest Greater
            ZWrite On

            HLSLPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment depth
            ENDHLSL
        }

        Pass
        {
            Stencil
            {
                Ref 0
                Comp Always
                Pass Replace
            }

            Cull Back
            ZTest Always
            ZWrite Off
            ColorMask 0

            HLSLPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            ENDHLSL
        }

    }
}
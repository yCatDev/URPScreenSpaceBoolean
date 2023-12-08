Shader "Universal Render Pipeline/ScreenSpaceBoolean/CompositeSubtraction"
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

        TEXTURE2D(_SubtractionDepth);
        SAMPLER(sampler_SubtractionDepth);


        output vert(input v)
        {
            output o;
            o.vertex = o.spos = v.vertex;
            o.spos.y *= _ProjectionParams.x;
            return o;
        }
        

        float depth(output i) : SV_Target
        {
            float2 uv = i.spos.xy * 0.5 + 0.5;

            float d = SAMPLE_TEXTURE2D(_SubtractionDepth, sampler_SubtractionDepth, uv).x;
            if (d == 1.0) discard;

            return d;
        }
        ENDHLSL

        Pass
        {
            Cull Off
            ZTest LEqual
            ZWrite On
            ColorMask 0

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment depth
            ENDHLSL
        }

    }
}
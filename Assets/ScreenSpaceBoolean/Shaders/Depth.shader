Shader "Universal Render Pipeline/ScreenSpaceBoolean/Depth"
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
        ENDHLSL

        Pass
        {
            Cull Back
            ZTest Less
            ZWrite On

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDHLSL
        }

        Pass
        {
            Cull Front
            ZTest Greater
            ZWrite On

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDHLSL
        }

    }
}
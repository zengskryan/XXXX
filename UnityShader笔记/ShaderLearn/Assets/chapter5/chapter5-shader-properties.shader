// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/chapter5-shader-material"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
    }
    SubShader{
        Pass{
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            //CG中定一个与属性名称和类型都匹配的变量
            fixed4 _Color;

            struct a2v {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float4 texcoord:TEXCOORD0;
            };

            struct v2f {
                float4 pos:SV_POSITION;
                fixed3 color : COLOR0;
            };

            v2f vert(a2v v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.color = v.normal * 0.5 + fixed3(0.5, 0.5, 0.5);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target{
                fixed3 c = i.color;
                //使用_Color属性来控制输出颜色
                c *= _Color.rgb;
                return fixed4(c,1.0);
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}

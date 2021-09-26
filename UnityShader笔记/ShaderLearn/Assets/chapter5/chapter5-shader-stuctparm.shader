// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/chapter5-shader-structparm"
{
    //Properties
    //{
        //_Color ("Color", Color) = (1,1,1,1)
        //_MainTex ("Albedo (RGB)", 2D) = "white" {}
        //_Glossiness("Smoothness", Range(0,1)) = 0.5
        //_Metallic("Metallic", Range(0,1)) = 0.0
    //}
    SubShader{
        Pass{
            CGPROGRAM
            //这个是告诉Unity哪个函数包含了顶点着色器的代码，哪个函数包含了片元着色器的代码
            #pragma vertex vert
            #pragma fragment frag
        
            //结构体定义输入
            struct a2v {
                //POSITION定义使用模型空间顶点填充vertex变量
                float4 vertex:POSITION;
                //NORMAL语义定义使用模型空间的法线方向填充normal变量
                //法线方向范围在[-1.0,1.0]
                float3 normal:NORMAL;
                //TEXCOORD0语义定义使用模型的第一套纹理坐标填充texcoord变量
                float4 texcoord:TEXCOORD0;
            };

            //定义顶点着色器的输出与片元着色器的输入
            //必须包含SV_POSITION，否则渲染器将无法得到裁剪空间的坐标
            struct v2f {
                //SV_POSITION语义定义pos包含了顶点在裁剪空间中的位置信息
                float4 pos:SV_POSITION;
                //定义可以用于存储颜色信息.类似的还有COLOR1等
                fixed3 color : COLOR0;
            };

            v2f vert(a2v v){
                //mul(UNITY_MATRIX_MVP,v.vertex)表示把顶点坐标从模型空间转换到裁剪空间
                // UNITY_MATRIX_MVP就是Unity内置的模型.观察.投影矩阵
                //使用v.vertex 来访问模型空间顶点
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                //将法线分量的范围映射到了[0.0,1.0],存储到0.color传递给片元着色器
                o.color = v.normal * 0.5 + fixed3(0.5, 0.5, 0.5);
                return o;
            }


            //SV_Target是HLSL的一个系统语义，等同于告诉渲染器，把用户的输出颜色存储到一个渲染目标中，这里将输出到默认的帧缓冲中。
            fixed4 frag(v2f i) : SV_Target{
                return fixed4(i.color,1.0);
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}

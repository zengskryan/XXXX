// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/chapter5-shader"
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
        
            //shader方法需要通过语义告诉Unity需要哪些输入值以及输出是什么，unity调用函数时才知道拿什么来填充以及拿到结果后做什么
            //Unity支持的语义有：POSITION,TANGENT,NORMAL,TEXCOORD0,TEXCOORD1,TEXCOORD2,COLOR等。
            //POSITION SV_POSITION都是CG/HLSL的语言
            //POSITION来限定输入V为模型的顶点坐标。
            //SV_POSITION来指定输出为裁剪空间中的顶点坐标。
            float4 vert(float4 v : POSITION) :SV_POSITION{
                //这里就是把顶点坐标从模型空间转换到裁剪空间
                //mul(UNITY_MATRIX_MVP,v) UNITY_MATRIX_MVP就是Unity内置的模型.观察.投影矩阵
                return UnityObjectToClipPos(v);
            }

            //SV_Target是HLSL的一个系统语义，等同于告诉渲染器，把用户的输出颜色存储到一个渲染目标中，这里将输出到默认的帧缓冲中。
            fixed4 frag() : SV_Target{
                return fixed4(1.0,1.0,1.0,1.0);
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}

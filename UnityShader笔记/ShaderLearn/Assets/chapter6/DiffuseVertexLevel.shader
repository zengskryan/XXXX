// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

//Unity 中实现漫反射光照模型

Shader "Unity Shader Book/chapter 6/Diffuse-VertexLevel"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1,1,1,1)
    }
    SubShader
    {
        Pass
        {
            //LightMode用于定义该Pass在光照流水线中的角色
            Tags{"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            fixed4 _Diffuse;

            struct a2v
            {
                float4 vertex : POSITION;
                //模型顶点的法线信息
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 color:COLOR;
            };


            v2f vert (a2v v)
            {
                v2f o;
                //顶点着色器的基本任务：把顶点位置从模型空间转换到裁剪空间中。
                o.pos = UnityObjectToClipPos(v.vertex);
                
                //通过Unity内置变量获取环境光部分
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                //将法线方向从模型空间转换到世界空间
                //unity_WorldToObject是世界至模型，交换在mul函数中的位置，得到相反的效果。4-7学到的。
                //3x3是因为法线是三维矢量，只需要截取矩阵的前三行前三列即可。
                fixed worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));

                //获取世界空间的光照方向
                //光源方向直接使用_WorldSpaceLightPos0来得到，
                //但这里的光源计算不具有通用性，因为假设场景中只有一个光源且是平行光
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

                //计算漫反射 公式
                //_LightColor0:Unity的内置变量，用来访问该Pass处理的光源的颜色和强度信息。
                //_Diffuse:漫反射系数
                //worldNormal：法线方向在世界空间的表示
                //worldLight:光照方向在世界空间的表示
                //fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));

                //半兰伯特模型计算漫反射
                //差异是不使用max，而是把点积乘以一个缩放，再加上一个偏移值，这两个值的大小可以调整。绝大多数情况都是0.5
                //通过这个计算，把dot(worldNormal, worldLight) 的值由[-1,1]映射到[0,1]
                fixed halfLambert = dot(worldNormal, worldLight) * 0.5 + 0.3;
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * halfLambert;

                //将漫反射光和环境光相加。
                o.color = ambient + diffuse;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return fixed4(i.color,1.0);
            }
            ENDCG
        }
    }
}

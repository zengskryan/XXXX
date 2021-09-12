// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

//Unity 单张纹理映射

Shader "Unity Shader Book/chapter 7/SingleTexture2"
{
    Properties
    {
        _MainTex("MainTex", 2D) = "white"{}
        _Color("Color Tint", Color) = (1,1,1,1)
        _Specular ("Specular", Color) = (1,1,1,1)
        _Gloss ("Gloss", Range(8.0,255)) = 20
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
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            fixed4 _Specular;
            float _Gloss;
            //Unity中声明这个变量，可以得到第一组纹理的缩放(xy)和偏移(zw)
            float4 _MainTex_ST;

            struct a2v
            {
                float4 vertex : POSITION;
                //模型顶点的法线信息
                float3 normal : NORMAL;
                //模型的第一组纹理坐标，应该是该顶点的的第一组纹理的纹理坐标
                float4 texcoord:TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal:TEXCOORD0;
                float3 worldPos:TEXCOORD1;
                float2 uv:TEXCOORD2;
            };


            v2f vert (a2v v)
            {
                v2f o;
                //顶点着色器的基本任务：把顶点位置从模型空间转换到裁剪空间中。
                o.pos = UnityObjectToClipPos(v.vertex);
               
                //将法线方向从模型空间转换到世界空间
                //unity_WorldToObject是世界至模型，交换在mul函数中的位置，得到相反的效果。4-7学到的。
                //3x3是因为法线是三维矢量，只需要截取矩阵的前三行前三列即可。
                o.worldNormal = UnityObjectToWorldNormal(v.normal);

                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                //o.uv = v.texcoord * _MainTex.xy + _MainTex.zw  计算纹理坐标缩放和偏移，得到纹理采样的uv坐标
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
               
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //获取世界空间的光照方向
                //光源方向直接使用_WorldSpaceLightPos0来得到，
                //但这里的光源计算不具有通用性，因为假设场景中只有一个光源且是平行光
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                //float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                float3 worldNormal = normalize(i.worldNormal);

                //使用_Maintex采样获得漫反射颜色
                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;

                //通过Unity内置变量获取环境光部分
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                //计算漫反射 公式
                //_LightColor0:Unity的内置变量，用来访问该Pass处理的光源的颜色和强度信息。
                //_Diffuse:漫反射系数
                //worldNormal：法线方向在世界空间的表示
                //worldLight:光照方向在世界空间的表示
                float3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal, worldLightDir));

                float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 halfDir = normalize(worldLightDir + viewDir);
                float3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

                return fixed4(diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
}

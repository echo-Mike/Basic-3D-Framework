simple = {
    vertex = [[
        uniform mat4 modelViewProjection;
        attribute vec4 position;
        attribute vec4 color;
        attribute vec3 normal;
        varying lowp vec4 vColor;
        varying highp vec3 vNormal;
        void main()
        {
            vColor = color;
            vNormal = normal;
            gl_Position = modelViewProjection * position;
        }
    ]],
    fragment = [[
        precision highp float;
        uniform mat4 modelViewProjection;
        varying lowp vec4 vColor;
        varying highp vec3 vNormal;
        uniform lowp sampler2D texture;
        uniform highp vec3 camlook;
        uniform highp float defuse;
        uniform highp float ambient; 
        uniform highp float specular;
        const float PI = 3.1415926535897932384626433832795;
        uniform highp float deang;
        void main()
        {
            lowp vec4 col = vColor;
            highp float a = acos(-dot(vNormal, cl)/(length(vNormal)*length(cl)));
            col.xyz *= clamp(exp(-a*defuse)+ambient, 0., 1.);
            col.xyz = mix(col.xyz, vec3(1.,1.,1.), exp(-a*specular));
            if(!gl_FrontFacing) discard;
            gl_FragColor = col;
        }
    ]]
}
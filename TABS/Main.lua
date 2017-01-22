function setup()
    displayMode(OVERLAY)
    cam = camera3d()
    shared_shader = shader(simple.vertex, simple.fragment)
    main = model{
        meshes={
            uvSphere(150, 20,20),
            cubeSphere(150,20),
            cylinder(50, 300, 20),
            surface(vec3(0,0,0), 300),
            cube(300),
            octahedron(150),
            tetrahedron(150),
            icosahedron(150),
            torus(300,100,15)
        },
        mesh_transform_matrix_array={
            matrix():translate(0,200,200),
            matrix():translate(0,200,0),
            matrix():translate(0,200,-200),
            matrix():rotate(45, 0,0,1):translate(0,0,200),
            matrix(),
            matrix():translate(0,0,-200),
            matrix():translate(0,-200,200),
            matrix():translate(0,-200,0),
            matrix():rotate(45, 0,0,1):translate(0,-200,-200)
        }
    }
    for i = 1,9 do
        set_rgb_colors(main.meshes[i])
        main.meshes[i].shader = shared_shader
    end
    parameter.number("s_ambient",  0,  1, 0.1, function() main.meshes[1].shader.ambient = s_ambient end)
    parameter.number("s_defuse",   0, 10,   2, function() main.meshes[1].shader.defuse = s_defuse end)
    parameter.number("s_specular", 0, 10,   8, function() main.meshes[1].shader.specular = s_specular end)
    parameter.number("dist", 100, 1500, 1000,  function() dist = math.floor(dist/100)*100 end)
end

function draw()
    background(29, 125, 130, 255)
    perspective(100,WIDTH/HEIGHT, 0.1, 10000)
    cam:camera()
    main:v_moveto(cam.look*dist)
    main.meshes[1].shader.cl = cam.look
    main:draw()
end

function touched(touch)
    cam:control_view(touch.deltaX*4/WIDTH, touch.deltaY*4/HEIGHT)
end
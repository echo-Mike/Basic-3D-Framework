function setup()
    deleteInvisibleSurface.shader = shader(deleteInvisibleSurface.vs, deleteInvisibleSurface.fs)
    displayMode(OVERLAY)
    cam = camera3d()
    createSkyBox()
    createViewPoint()
    createFloor()
    test = model({makecube(100), makecube(100)})
    test:setColors(255,255,255)
    set_box_texture(test.meshes[1], readImage("Cargo Bot:Crate Blue 2"))
    set_box_texture(test.meshes[2], readImage("Cargo Bot:Crate Green 2"))
    test:v_moveto(cam.look/2)
    test:mesh_rotate(1, 30,1,0,0)
    test:mesh_relative_translate(1,2, 0,300,0)
    a, b = viewpoint:bake()
    vp = model({a})
    t = 0
    dt = 1/60
    scr = image(WIDTH,HEIGHT)
    parameter.action("set cam", function() cam = camera3d() end)
    parameter.action("print test mtm", function() print(test.model_transform_matrix) end)
    readImage("Cargo Bot:Crate Green 2")
end

function draw()
    background(0)
    setContext(scr, true)
    background(127, 127, 127, 255)
    perspective(100,WIDTH/HEIGHT, 0.1, 10000)
    cam:camera()
    skybox:draw()
    viewpoint:v_moveto(cam.look/4)
    --viewpoint:draw()
    test:v_moveto(cam.look/2)
    test:mesh_rotate(1, dt*10, 1,0,0)
    test:mesh_relative_moveto(1,2, 300*math.sin(t),0,300*math.cos(t))
    test:draw()
    vp:v_moveto(cam.look/2)
    vp:draw()
    setContext()
    cam:gui()
    ortho(0, WIDTH, 0, HEIGHT, -10000, 10)
    sprite(scr, WIDTH/2, HEIGHT/2)
    sprite("Cargo Bot:Background Fade", WIDTH/2, HEIGHT/2, WIDTH, HEIGHT)
    t = t + dt
end

function touched(touch)
    cam:control_view(touch.deltaX*4/WIDTH, touch.deltaY*4/HEIGHT)
end

function createViewPoint()
    viewpoint = model({makecylinder(10, 105, 4), makecylinder(10, 105, 4), makecylinder(10, 105, 4)})
    viewpoint:mesh_translate(1, 45,0,0)
    viewpoint:mesh_rotate(1, 90, 0,0,1)
    viewpoint:mesh_setColors(1, 255,0,0)
    viewpoint:mesh_translate(2, 0,0,45)
    viewpoint:mesh_rotate(2, 90, 1,0,0)
    viewpoint:mesh_setColors(2, 0,0,255)
    viewpoint:mesh_translate(3, 0,45,0)
    viewpoint:mesh_setColors(3, 0,255,0)
end

function createSkyBox()
    skybox = model({makecube(5000)})
    -- readImage("Cargo Bot:Menu Button")
    set_box_texture(skybox.meshes[1], readImage("Platformer Art:Crate"))
    skybox:v_moveto(cam.pos) --при движущийся камере перенести в draw()
    skybox.meshes[1]:setColors(255,255,255)
end

function createFloor()
    floor = model({makesurface(vec3(0,-100,0))})
    floor:mesh_scale(1,10,1,10)
    set_surface_texture(floor.meshes[1], readImage("Cargo Bot:Dialogue Box"))
end

function createInterface()
    interface = model({makesurface(vec3(0,0,0))})
    set_surface_texture(interface.meshes[1], readImage("Cargo Bot:Menu Button"))
    interface:mesh_scale(1, 0.01,1,0.01)
end

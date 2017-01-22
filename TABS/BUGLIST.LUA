project = "Basic-3D-Framework"
buglist = {
    D756D3B7 = {
        places = {
            c_Camera3D = {
                places = {
                    "camera3d:init(t)"
                },
                status = {
                    "close"
                }
            },
            c_Viewport = {
                places = {
                    "viewport:init(t)"
                },
                status = {
                    "close"
                }
            },
            c_Model = {
                places = {
                    "model:init(t)"
                },
                status = {
                    "close"
                }
            },
            c_Scene = {
                places = {
                    "scene:init(t)"
                },
                status = {
                    "close"
                }
            },
        },
        status = "close",
        description = [[
            Bug takes place in init function of classes defined like:
                function class:init(t)
                    local name = t.name or "name"
                    local num = t.num or 1
                    --STUFF
                end
            FIX:
            Use only class{} calls or use next definition:
                function class:init(t)
                    local t = t or {}
                    local name = t.name or "name"
                    local num = t.num or 1
                    --STUFF
                end
        ]]
    },
    B7EFCF58 = {
        places = {
            f_Mesh_Gen = {
                places = {
                    "makeUVSphere(float rad, int Lsteps, int Asteps, boolean normals_in)"
                },
                status = {
                    "close"
                }
            }
        },
        status = "close",
        description = [[
            Генерирует не равномерное распределение треугольников по сфере
        ]]
    },
    A78A3B3D = {
        places = {
            c_Camera3D = {
                places = {
                    "camera3d:control_view(float deltaL, float deltaA)"
                },
                status = {
                    "close"
                }
            }
        },
        status = "close",
        description = [[
            Имена внутренних переменных не совпадают с действительностью,
            переменной self.revers вообще не существует, она должна быть
            Codea:vec2() и ровняться vec2(1,1) в camera3d:init(table t)
        ]]
    },
    FB7A9733 = {
        places = {
            c_Viewport = {
                places = {
                    "viewport:draw()"
                },
                status = {
                    "close"
                }
            },
        },
        status = "close",
        description = [[
            sprite(self.interface_canvas, WIDTH/2, HEIGHT/2)
            insted
            sprite(self.interface_canvas)
        ]]
    },
    DAED8CD8 = {
        places = {
            f_Mesh_Gen = {
                places = {
                    "subdivide(m, method)"
                },
                status = {
                    "open"
                }
            },
        },
        status = "open",
        description = [[
            color buffer handles incorrectly
            FIX:
            use special funxtion for collor buffer handling
        ]]
    },
}
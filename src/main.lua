-- rogue

function _init()
    -- global vars
    t=0
    cam = {}
    cam.x = 0
    cam.y = 0
    msg=''
    level=1
   
    -- thanks doc_robs!
    dust={}
       
    shots=new_group(shot)
    booms=new_group(boom)
 
    char=init_char()
    levels=roll_levels()
    map=generate_map()
    hud=init_hud()
end
   
function _update()
    t=(t+1)%128
 
    char:update()
    hud:update()

    shots:update()
    booms:update()
   
    for d in all(dust) do
        d:update()
    end

    cam.x = max(char.x - 8, 0)
    cam.y = max(char.y - 8, 0)
end
   
function _draw()
    cls()
    camera(cam.x * 8, cam.y * 8)

    draw_map(map)

    char:draw()

    hud:draw()
   
    -- for d in all(dust) do
    --     d:draw()
    -- end
       
    -- debug()
end
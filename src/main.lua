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
       
    -- shots=new_group(shot)
    -- booms=new_group(boom)

    goombas=new_group(goomba)
    evil_goombas = new_group(evil_goomba)

    char=init_char()
    levels=roll_levels()
    map=generate_map()
    hud=init_hud()
    state='p_turn'
end
   
function _update()
    pal()
    t=(t+1)%128

    if (state == 'p_turn') then
        char:update()
    elseif (state == 'e_turn') then
        state = 'p_turn'
        goombas:update()
        evil_goombas:update()
        lamia:turn()
    end

    lamia:update()
   
    for d in all(dust) do
        d:update()
    end

    hud:update()
    cam.x = max(char.x - 8, 0)
    cam.y = max(char.y - 8, 0)
end
   
function _draw()
    cls()
    camera(cam.x * 8, cam.y * 8)

    draw_map(map)

    char:draw()

    hud:draw()

    goombas:draw()
    evil_goombas:draw()
   
    for d in all(dust) do
        d:draw()
    end
      
    lamia:draw()
    -- debug()
end
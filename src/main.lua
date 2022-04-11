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

    goombas=new_group(goomba)
    g_koopas=new_group(g_koopa)
    r_koopas=new_group(r_koopa)

    char=init_char()
    levels=roll_levels()
    map=generate_map()
    hud=init_hud()
    state='p_turn'
    anim_time=0
end

function _update()
    pal()
    t=(t+1)%128

    if (state == 'p_turn') then
        controller:handle_input()
        char:turn()
        if (char.action_taken) then
            state = 'p_anim'
        end
    elseif (state == 'p_anim') then
        char.action_taken = false

        if (anim_time >= 1) then
            anim_time = 0
            state = 'e_turn'
        else
            anim_time += 1
        end
    elseif (state == 'e_turn') then
        state = 'e_anim'
        goombas:turn()
        g_koopas:turn()
        r_koopas:turn()
    elseif (state == 'e_anim') then
        if (anim_time >= 1) then
            anim_time = 0
            state = 'p_turn'
        else
            anim_time += 1
        end
    end

    char:update()
    goombas:update()
    g_koopas:update()
    r_koopas:update()

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

    -- todo: generic enemy management
    goombas:draw()
    g_koopas:draw()
    r_koopas:draw()

    for d in all(dust) do
        d:draw()
    end

    -- debug()
end

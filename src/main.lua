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

    char=init_char()
    levels=roll_levels()
    map=generate_map()
    hud=init_hud()
    state='p_turn'
    anim_time=1
end

function _update()
    pal()
    t=(t+1)%128

    if (state == 'p_turn') then
        -- continue enemy animation
        if (#animations._ > 0) then
            animations:update(anim_time)
            anim_time += 1
        end

        controller:handle_input()
        if (char.action_taken) then
            -- block synchronously to let long animations finish
            while(#animations._ > 0) do
                animations:update(anim_time)
                anim_time += 1
            end

            animations:dequeue()
            state = 'p_anim'
            char.action_taken = false
            anim_time = 1
        end
    end

    if (state == 'p_anim') then
        -- block for player animations
        if (#animations._ > 0) then
            animations:update(anim_time)
            anim_time += 1
        else
            char.spr = 1
            state = 'e_turn'
            anim_time = 1
        end
    end

    if (state == 'e_turn') then
        char:check_space()

        enemies:turn()
        state = 'p_turn'
        animations:dequeue()

        if (#animations._ > 0) then
            animations:update(anim_time)
            anim_time += 1
        end
    end

    char:update()
    enemies:update()

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

    enemies:draw()

    for d in all(dust) do
        d:draw()
    end

    animations:draw()

    -- debug()
end

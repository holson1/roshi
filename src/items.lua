-- items
key = {
    name='key',
    spr=80,
    desc='best used for unlocking',
    _count=1,
    count=1,
    sfx=1,
    use=function()
    end,
    consume=function(self)
        handle_count(self)
        hlog('*click*')
    end,
}

shovel = {
    spr=040,
    name='rusted shovel',
    desc='dig down one level',
    sfx=3,
    use=function()
        hud:set_msg('you strike the earth', 'the shovel breaks!')
        level += 1
        map = generate_map()
        del(hud.items, shovel)
    end
}

hyper_specs = {
    spr=035,
    name='hyper specs',
    desc='see fake walls',
    sfx=4,
    use=function()
        hlog('you peer into the void.')
        fake_wall.spr = 023
    end
}

inspect = {
    spr=034,
    name='inspect',
    desc='look around',
    use=function()
    end
}

tongue = {
    spr=033,
    name='tongue',
    desc='grab things 2 tiles away',
    use=function()
    end
}

egg = {
    spr=032,
    name='egg',
    desc='throw at enemies',
    _count=2,
    count=2,
    sfx=006,
    use=function(self)
        handle_count(self)
    end
}

jump_boots = {
    spr=041,
    name='jump boots',
    desc='used in plyometric training',
    sfx=006,
    use=function()
    end
}

function handle_count(inst)
    inst.count -= 1
    if (inst.count < 1) then
        del(hud.items, inst)
    end
end

-- coins
coin = {
    id='coin',
    spr=050,
    flag=3,
    value=1
}

red_coin = {
    id='red_coin',
    spr=051,
    flag=3,
    value=5
}

function roll_random_item()
    -- todo: use chest pools instead
    local r = rnd()
    if (r > 0.7) then
        return shovel
    elseif (r > 0.5) then
        return hyper_specs
    elseif (r > 0.3) then
        return jump_boots
    else
        return egg
    end
end
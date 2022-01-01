-- items
key = {
    name='key',
    spr=80,
    desc='best used for unlocking',
    sfx=1,
    use=function() end
}

shovel = {
    spr=040,
    name='rusted shovel',
    desc='dig down one level',
    sfx=3,
    use = function ()
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
    use = function ()
        hlog('you peer into the void.')
        fake_wall.spr = 023
    end
}

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
    if (rnd() > 0.5) then
        return shovel
    else
        return hyper_specs
    end
end
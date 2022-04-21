function init_char()
    local char={
        x=4,
        y=4,
        spr=001,
        spri=0,
        state='base',
        move_counter=0,
        idle_counter=0,
        action_time=0,
        flip=false,
        max_health=5,
        health=3,
        action_taken=false,
        collide=collide,
        update_position=update_position,
        turn=char_turn,
        update=update_char,

        -- all game logic should be implemented in cells, only draw functions care about px
        draw=function(self)
            spr(self.spr,(self.x * 8),(self.y * 8),1,1,self.flip)
        end
    }
    return char
end

function collide_exit_door(y, x, space)
    if (hud:find_item(key.name) != nil) then
        key.consume(key)
        map[y][x] = exit
    else
        hlog('i need a key!')
    end
end

function collide_fake_wall(y, x, space)
    place_coin(map, y, x, coin)
    hlog('the fake wall crumbles away...')
end

function collide_chest(y, x, chest)
    place_item(map, y, x, chest.item)
end

function collide(_char, space, y, x)
    local actions = {
        exit_door=collide_exit_door,
        fake_wall=collide_fake_wall,
        chest=collide_chest,
    }
    if (actions[space.id]) then
        actions[space.id](y, x, space)
    end
end

function char_turn(_char)
    _char.x = round(_char.x)
    _char.y = round(_char.y)
    check_space(_char)
end

function update_char(_char)
    if (_char.state == 'base') then
        _char.spri = 0
        _char.idle_counter += 1
    end

    if (_char.state == 'walk') then
        _char.move_counter += 1
    end

    if (_char.idle_counter > 128) then
        _char.state = 'idle'
        _char.idle_counter = 0  
    end

    if (_char.move_counter > 3) then
        _char.state = 'base'
        _char.move_counter = 0
    end
end

function update_position(_char, _y, _x)
    if (in_bounds(_y, _x)) then
        if (map[_y][_x].flag ~= 1) then
            -- _char.x = _x
            -- _char.y = _y
            local xdiff = _x - char.x
            local ydiff = _y - char.y
            animations:new(char_move(ydiff, xdiff))
        else
            _char:collide(map[_y][_x], _y, _x)
        end
    end
end

function check_space(_char)
    local space = map[_char.y][_char.x]

    -- exit
    if (space.flag == 7) then
        level += 1
        map = generate_map()
    end

    -- objects (carryable)
    if (space.flag == 2) then
        hud:pickup_item(space.item)
        map[_char.y][_char.x] = floor
    end

    -- coins
    if (space.flag == 3) then
        hud.coins += space.value
        map[_char.y][_char.x] = floor
    end
end
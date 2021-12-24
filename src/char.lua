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

        states={
            'base',
            'idle'
        },

        animations={
            base={1},
            idle={1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,3,2,2,2,2,1,1,1,1,1,1,1,1,1},
            walk={5,4,4}
        },

        get_animation=function(self)
            return self.animations[self.state]
        end,

        update=update_char,

        -- all game logic should be implemented in cells, only draw functions care about px
        draw=function(self)
            spr(self.spr,(self.x * 8),(self.y * 8),1,1,self.flip)
        end
    }
    return char
end

function update_char(_char)
    if (_char.state == 'base') then
        _char.spri = 0
        _char.idle_counter += 1
    end

    if (_char.state == 'walk') then
        _char.move_counter += 1
    end

    check_space(_char)

    handle_input(_char)
    update_position(_char)

    if (_char.idle_counter > 128) then
        _char.state = 'idle'
        _char.idle_counter = 0  
    end

    if (_char.move_counter > 3) then
        _char.state = 'base'
        _char.move_counter = 0
    end

    -- todo: proper animation timing system
    if (_char.spr ~= 'base' and t%4 == 0) then
        _char.spri = (_char.spri + 1) % 32
        set_spr(_char)
    end
end

function handle_input(_char)
    if (btnp(0) or btnp(1) or btnp(2) or btnp(3)) then
        _char.idle_counter = 0
        _char.state = 'walk'
        hud:clear_msg()
    end

    if (btnp(0)) then
        if ((_char.x - 1) > 0 and map[_char.y][_char.x - 1].flag ~= 1) then
            _char.x -= 1
        end
        _char.flip = true
    end

    if (btnp(1)) then
        if ((_char.x + 1) < MAP_SIZE+1 and map[_char.y][_char.x + 1].flag ~= 1) then
            _char.x += 1
        end
        _char.flip = false
    end

    if (btnp(2)) then
        if ((_char.y - 1) > 0 and map[_char.y - 1][_char.x].flag ~= 1) then
            _char.y -= 1
        end
    end

    if (btnp(3)) then
        if ((_char.y + 1) < MAP_SIZE+1 and map[_char.y + 1][_char.x].flag ~= 1) then
            _char.y += 1
        end
    end
end
  
function update_position(_char)
end

function set_spr(_char)
    local anim = _char:get_animation()
    local transformed_spri = (_char.spri % #anim) + 1
    
    _char.spr = anim[transformed_spri]
end

function check_space(_char)
    if (map[_char.y][_char.x].flag == 7) then
        map = generate_map()
    end
end
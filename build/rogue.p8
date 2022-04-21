pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--src/hud.lua
-- hud

function init_hud()
    local hud = {
        items={tongue, egg, jump_boots},
        selected_item=1,
        msg1="welcome to roshi's dungeon",
        msg2='find the key',
        coins=05,
        spri=0,

        set_msg = function(self, m1, m2)
            self.msg1 = m1
            self.msg2 = m2
        end,

        clear_msg = function(self)
            self.msg1 = ''
            self.msg2 = ''
        end,

        pickup_item = function(self, item)
            local existing_item = self:find_item(item.name)

            if (existing_item) then
                if (existing_item.count != nil) then
                    existing_item.count += 1
                end
            else
                item.count = item._count
                add(self.items, item)
            end

            sfx(item.sfx)
            self:set_msg('got: `' .. item.name .. '`', item.desc)
        end,

        find_item = function(self, name)
            for i in all(self.items) do
                if (i.name == name) then
                    return i
                end
            end
            return nil
        end,

        get_selected_item = function(self)
            return self.items[self.selected_item]
        end,

        use_selected_item = function(self, radians)
            local this_item = self:get_selected_item()

            sfx(this_item.sfx)
            this_item.use(this_item, radians)

            -- catch error w/ using last item
            if (self.selected_item > #self.items) then
                self.selected_item = #self.items
            end
        end,

        rotate_selected_item = function(self)
            self.selected_item = (self.selected_item + 1) % #self.items
            if (self.selected_item == 0) then
                self.selected_item = #self.items
            end

            local this_item = self:get_selected_item()
            self:set_msg(this_item['name'],this_item['desc'])
        end,

        update = function(self)
            if (t%8 == 0) then
                self.spri = (self.spri + 1) % 2
            end
        end,

        draw = function(self)
            local x = cam.x*8
            local y = cam.y*8

            -- items
            for i=1,#self.items do
                spr(self.items[i].spr,x,y+(i*8)-8)
                local item_count = self.items[i].count

                if (item_count != nil and item_count > 1) then
                    print(item_count,x+5,y+(i*8)-5,8)
                end
                if (i == self.selected_item) then
                    spr(016 + self.spri,x,y+(i*8)-8)
                end
            end

            -- text
            rectfill(x,y+112,x+127,y+127,0)
            rect(x+8,y+112,x+127,y+127,7)
            rectfill(x+10,y+112,x+125,y+127,0)

            print(self.msg1, x+12, y+114, 15)
            print(self.msg2, x+12, y+121, 15)

            -- health
            for i=0,(char.max_health-1) do
                spr(049,x,y+96-(i*8))
            end
            for i=0,(char.health-1) do
                spr(048,x,y+96-(i*8))
            end

            -- coins
            spr(050,x-1,y+111)
            if (self.coins > 9) then
                print(self.coins,x,y+120,10)
            else
                print('0' .. self.coins,x,y+120,10)
            end

            -- level
            if (levels != nil) then
                print(levels[level], x+16, y, 10)
            end
            print('l' .. level, x+116, y, 10)
        end
    }
    return hud
end
-->8
--src/levels.lua
LEVEL_COUNT = 50

-- sky castle dungeon
SCD = {
   "regular",
   "regular",
   "regular",
   "regular",
   "extra_chest",
   "extra_chest",
   "grass_cave",
   "grass_cave",
   "test",
   "test",
   "test",
   "hidden",
   "hidden"
}

-- forest
FOR = {
   "regular_for" 
}

-- sea cliffs
SEA = {}
-- moss cave
MOS = {}
-- town
TWN = {}
-- poison tower
PSN = {}
-- skeleton pit
SKP = {}
-- lava zone
LAV = {}
-- hospital
HSP = {}
-- void
VOI = {}


function roll_levels()
    local levels = {}

    for i=1,LEVEL_COUNT do

        this_level = nil
        -- TODO: expand this to include more types
        if (i < 10) then
            this_level = roll_and_extract(SCD)
        else
            this_level = roll_and_extract(FOR)
        end

        if (this_level != nil) then
            add(levels, this_level)
        end
    end

    return levels
end

function roll_and_extract(level_list)
    if (#level_list == 1) then
        return level_list[1]
    end

    local idx = rndi(1,#level_list)
    local lv = level_list[idx]
    del(level_list, i)
    return lv
end
-->8
--src/items.lua
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

tongue = {
    spr=033,
    name='tongue',
    desc='grab things 2 tiles away',
    can_aim=true,
    use=function()
    end
}

egg = {
    spr=032,
    name='egg',
    desc='throw at enemies',
    can_aim=true,
    _count=2,
    count=2,
    sfx=006,
    use=function(self)
        animations:new(char_throw)
        handle_count(self)
    end
}

jump_boots = {
    spr=041,
    name='jump boots',
    desc='used in plyometric training',
    can_aim=true,
    sfx=006,
    use=function(self, radians)
        local new_x = char.x + (cos(radians) * 2)
        local new_y = char.y + (sin(radians) * 2)
        
        char:update_position(new_y, new_x)
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
-->8
--src/controller.lua
-- game controller

controller = {
    state='move',
    handle_input = function(self)
        local did_act = false
        if (self.state == 'move') then
            did_act = self:handle_move()
        elseif (self.state == 'aim') then
            did_act = self:handle_aim()
        end

        if (did_act) then
            char.action_taken = true
            hud:clear_msg()
        end
    end,

    handle_move = function(self)
        if (btnp(0)) then
            -- LEFT
            char:update_position(char.y, char.x - 1)
            char.flip = true
            return true
        elseif (btnp(1)) then
            -- RIGHT
            char:update_position(char.y, char.x + 1)
            char.flip = false
            return true
        elseif (btnp(2)) then
            -- UP
            char:update_position(char.y - 1, char.x)
            return true
        elseif (btnp(3)) then
            -- DOWN
            char:update_position(char.y + 1, char.x)
            return true
        elseif (btnp(4)) then
            -- USE ITEM (Z)
            local this_item = hud:get_selected_item()
            if (this_item.can_aim) then
                self.state = 'aim'
            else
                hud:use_selected_item()
                return true
            end
        elseif (btnp(5)) then
            -- ROTATE ITEM (X)
            hud:rotate_selected_item()
        end
        return false
    end,

    handle_aim = function(self)
        local did_act = true
        local _state = 'move'

        if (btnp(0)) then
            -- LEFT
            hud:use_selected_item(0.5)
        elseif (btnp(1)) then
            -- RIGHT
            hud:use_selected_item(0)
        elseif (btnp(2)) then
            -- UP
            hud:use_selected_item(0.25)
        elseif (btnp(3)) then
            -- DOWN
            hud:use_selected_item(0.75)
        elseif (btnp(5)) then
            hud:rotate_selected_item()
            did_act = false
        else
            did_act = false
            _state = 'aim'
        end

        self.state = _state
        return did_act
    end
}
-->8
--src/main.lua
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
    anim_time=1
end

function _update()
    pal()
    t=(t+1)%128

    if (state == 'p_turn') then
        controller:handle_input()
        char:turn()
        if (char.action_taken) then
            state = 'p_anim'
            char.action_taken = false
        end
    elseif (state == 'p_anim') then
        if (t % 2 == 0) then
            if (#animations._ > 0) then
                animations:update(anim_time)
                anim_time += 1
            else
                char.spr = 1
                state = 'e_turn'
                anim_time = 1
            end
        end
    elseif (state == 'e_turn') then
        goombas:turn()
        g_koopas:turn()
        r_koopas:turn()
        state = 'e_anim'
    elseif (state == 'e_anim') then
        if (anim_time >= 1) then
            anim_time = 1
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
-->8
--src/map.lua
MAP_SIZE=24 -- map size in tiles
VISION_RADIUS=5

floor = {
    id='floor',
    spr=018,
    flag=0
}

start = {
    id='start',
    spr=103,
    flag=0
}

-- collidables
empty = {
    spr=017,
    flag=1
}

wall = {
    id='wall',
    spr=020,
    flag=1
}

fake_wall = {
    id='fake_wall',
    spr=017,
    flag=1
}

chest = {
    id='chest',
    spr=024,
    flag=1,
    item={}
}

exit_door = {
    id='exit_door',
    spr=096,
    flag=1
}

exit = {
    id='exit',
    spr=102,
    flag=7
}

function place_item(_map, y, x, _item)
    _map[y][x] = {
        flag=2,
        id=_item.name,
        spr=_item.spr,
        item=_item
    }
end

function place_coin(_map, y, x, _coin)
    _map[y][x] = {
        flag=3,
        id=_coin.id,
        spr=_coin.spr,
        value=_coin.value
    }
end

function place_chest()
    return {
        id='chest',
        spr=024,
        flag=1,
        item=roll_random_item()
    }
end

function place_enemies(rooms)
    -- this will really depend on level but _FOR NOW_ let's do the easy thing and gen a default number

    for room in all(rooms) do
        goombas:new({x=room[2],y=room[1]})
        if (rnd() > 0.5) then
            g_koopas:new({x=room[2],y=room[1]})
        else
            r_koopas:new({x=room[2],y=room[2]})
        end
    end
end

function draw_path_between_coords(_map, start, dest)
    local x = 2
    local y = 1

    path_x = start[x]
    path_y = start[y]

    while (path_x ~= dest[x] or path_y ~= dest[y]) do
        _map[path_y][path_x] = floor

        local x_diff = dest[x] - path_x
        local y_diff = dest[y] - path_y

        -- if x is not finished, and if it is chosen OR y is already done, then
        if (abs(x_diff) > 0 and (rnd() > 0.5 or abs(y_diff) == 0)) then
            if (x_diff > 0) then
                path_x += 1
            elseif (x_diff < 0) then
                path_x -= 1
            end
        else
            if (y_diff < 0) then
                path_y -= 1
            elseif (y_diff > 0) then
                path_y += 1
            end
        end
    end
end

function unique_point(points)
    local val = {}
    local found = true

    while found do
        found = false
        val = {rndi(1, MAP_SIZE), rndi(1, MAP_SIZE)}
        for v in all(points) do
            found = coord_match(val,v)
        end
    end

    return val
end

function draw_room(_map, point)
    local MIN_ROOM_SIZE = 3
    local MAX_ROOM_SIZE = 7
   
    -- roll a random room
    local width = rndi(MIN_ROOM_SIZE, MAX_ROOM_SIZE)
    local height = rndi(MIN_ROOM_SIZE, MAX_ROOM_SIZE)

    -- position the room midway over the point
    local room_c = {point[1]-flr(height/2), point[2]-flr(width/2)}

    -- draw the room in
    for i=max(1, room_c[2]), min(room_c[2]+width, MAP_SIZE) do
        for j=max(1, room_c[1]), min(room_c[1]+height, MAP_SIZE) do
            _map[j][i] = floor
        end
    end
end

function clear_map()
    for g in all(goombas._) do
        del(goombas._, g)
    end
    for g in all(g_koopas._) do
        del(g_koopas._, g)
    end
end

function generate_map()
    local _map = {}

    -- clear any existing enemies
    clear_map()

    -- fake wall generation
    for i=0,MAP_SIZE do
        add(_map, {})
        for j=0,MAP_SIZE do
            if (rnd() > 0.97) then
                add(_map[i], fake_wall)
            else
                add(_map[i], empty)
            end
        end
    end

    -- pick a start, exit, and key
    local points = {}
    local start_c = unique_point(points)
    add(points, start_c)
    local exit_c = unique_point(points)
    add(points, exit_c)
    local key_c = unique_point(points)
    add(points, key_c)
    local room1_c = unique_point(points)
    add(points, room1_c)
    local room2_c = unique_point(points)

    local y = 1
    local x = 2

    char.x = start_c[x]
    char.y = start_c[y]

    draw_path_between_coords(_map, start_c, key_c)
    draw_path_between_coords(_map, start_c, exit_c)
    draw_path_between_coords(_map, key_c, room1_c)
    draw_path_between_coords(_map, start_c, room2_c)

    draw_room(_map, start_c)
    -- todo: randomize which points get rooms
    draw_room(_map, exit_c)
    draw_room(_map, room1_c)
    draw_room(_map, room2_c)

    _map[start_c[y]][start_c[x]] = start
    _map[exit_c[y]][exit_c[x]] = exit_door
    place_item(_map, key_c[y], key_c[x], key)

    -- roll chest
    _map[room1_c[y]][room1_c[x]] = place_chest()

    -- place enemies
    place_enemies({room1_c, room2_c, exit_c})
    lamia.x = key_c[x]
    lamia.y = key_c[y]

    return _map
end

function draw_map(_map)
    local x = flr(char.x)
    local y = flr(char.y)

    for i=max(1, x-VISION_RADIUS), min(x+VISION_RADIUS, MAP_SIZE) do
        for j=max(1, y-VISION_RADIUS), min(y+VISION_RADIUS, MAP_SIZE) do
            spr(_map[j][i].spr, i*8, j*8)
        end
    end

    -- todo: get rid of this
    if (t % 16 == 0) then
        fake_wall.spr = 017
    end
end
-->8
--src/objects/boom.lua
boom={
    s=008,
    w=8,
    h=8,
    x=nil,
    y=nil,

    update=function(self)
            self.s+=1
            if(self.s>11) self.alive=false
    end
}
-->8
--src/objects/shot.lua
shot={
    w=4,
    h=4,
    s=195,
    x=nil,
    y=nil,
    dx=nil,
    dy=nil,
    d=nil,

    update=function(self)
        -- destroy on OOB
        if self.x < cam.x
            or self.x > cam.x + 128
            or self.y < cam.y
            or self.y > cam.y + 128 then
                self.alive = false
        end
  
        if t%2 == 0 then
            add_new_dust(self.x + self.w, self.y + self.h, self.dx/2, self.dy/2, 9, rnd(3), 0, 15)
        end
   
        self.x+=self.dx
        self.y+=self.dy	
    end
}
-->8
--src/animations.lua
animations = {
    _ = {},
    new=function(self, animation)
        local anim_copy = {}
        for k,v in pairs(animation) do
            anim_copy[k]=v
        end
        anim_copy.active = true
        add(self._, anim_copy)
    end,

    update=function(self, anim_time)
        for i,v in ipairs(self._) do
            v:update(anim_time)
            if v.active==false then
                del(self._,self._[i])
            end
        end
    end,

    draw=function(self)
        for v in all(self._) do
            spr(v.s,v.x*8,v.y*8,1,1,v.flip)
        end
    end
}

char_throw = {
    a={5,6,7,8},
    update=function(self,anim_time)
        if (anim_time > #self.a) then
            self.active = false
            return
        end
        char.spr = self.a[anim_time]
    end,
}

char_move = function(ydiff, xdiff)
    return {
        a={4},
        ydiff=ydiff,
        xdiff=xdiff, 
        update=function(self,anim_time)
            if (anim_time > #self.a) then
                self.active = false
                return
            end
            char.spr = self.a[anim_time]

            char.x += (self.xdiff / #self.a)
            char.y += (self.ydiff / #self.a)
        end,
    }
end
-->8
--src/lib/group.lua
function new_group(bp)
    return {
        _={},
        bp=bp,
        
        new=function(self,p)
            for k,v in pairs(bp) do
                if v!=nil then
                    p[k]=v
                end
            end
            p.alive=true
            add(self._,p)
        end,
           
        update=function(self)
            for i,v in ipairs(self._) do
                v:update()
                if v.alive==false then
                del(self._,self._[i])
                end
            end
        end,

        turn=function(self)
            for v in all(self._) do
                v:turn()
            end
        end,
        
        draw=function(self)
            for v in all(self._) do
                spr(v.s,v.x*8,v.y*8,1,1,v.flip)
            end
        end
    }
end
-->8
--src/lib/dust.lua
function add_new_dust(_x,_y,_dx,_dy,_l,_s,_g,_f)
    add(dust, {
    fade=_f,x=_x,y=_y,dx=_dx,dy=_dy,life=_l,orig_life=_l,rad=_s,col=0,grav=_g,draw=function(self)
    pal()palt()circfill(self.x,self.y,self.rad,self.col)
    end,update=function(self)
    self.x+=self.dx self.y+=self.dy
    self.dy+=self.grav self.rad*=0.9 self.life-=1
    if type(self.fade)=="table"then self.col=self.fade[flr(#self.fade*(self.life/self.orig_life))+1]else self.col=self.fade end
    if self.life<0then del(dust,self)end end})
end
-->8
--src/lib/util.lua
function rndi(min,max)
    return flr(rnd(max - min)) + min
end

function coord_match(a,b)
    return a[1] == b[1] and a[2] == b[2]
end

function in_bounds(a,b)
    return a > 0 and a < MAP_SIZE + 1 and b > 0 and b < MAP_SIZE + 1
end

function round(x)
    if ((x - flr(x)) >= 0.5) then
        return ceil(x)
    else
        return flr(x)
    end
end
-->8
--src/log.lua
_log={}
log_l=4
for i=1,log_l do
    add(_log,'')
end

function hlog(str)
    hud:set_msg(str, '')
end

function log(str)
    add(_log,str)
end
   
function debug()
    vars = {
        't='..t
    }

    -- draw the log
    for i=count(_log)-log_l+1,count(_log) do
        add(vars,'> '.._log[i])
    end

    for i,v in ipairs(vars) do
        print(v,(cam.x*8)+8,(cam.y*8)+(i*8),15)
    end
end
-->8
--src/char.lua
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
-->8
--src/enemies/lamia.lua
lamia={
    life=1,
    s=224,
    x=4,
    y=4,
    state='idle',
    spri=0,

    animations={
        idle={224,224,234,234,234,224,224,224,226,228,230,232},
    },

    update=function(self)
        -- generic animation code
        if (t%3==0) then
            self.spri = (self.spri + 1) % 16
        end
        local anim = self.animations[self.state]
        local transformed_spri = (self.spri % #anim) + 1
        
        self.s = anim[transformed_spri]
    end,

    turn=function(self)
        local new_cell = nil
        local dirs = {0,0.25,0.5,0.75}
        while new_cell == nil do
            local dir = rnd(dirs)
            local new_x = self.x + cos(dir)
            local new_y = self.y + sin(dir)

            -- check to see if it hits player
            if (coord_match({new_y, new_x}, {char.y, char.x})) then
                new_cell = {self.y, self.x}
                sfx(5)
                hlog('the lamia strikes!')
                pal(11,8)
                char.health -= 1
                break
            end

            if (in_bounds(new_y, new_x) and map[new_y][new_x].flag == 0) then
                new_cell = {new_y, new_x}
            else
                del(dirs, dir)
                if (#dirs == 0) then
                    new_cell = {self.y, self.x}
                end
            end
        end

        self.y = new_cell[1]
        self.x = new_cell[2]
    end,

    draw=function(self)
        spr(self.s,self.x*8,self.y*8,2,2)
    end
}
-->8
--src/enemies/evil_goomba.lua
evil_goomba={
    life=1,
    s=128,
    x=nil,
    y=nil,
    state='walk',
    spri=0,

    animations={
        walk={131,132}
    },

    update=function(self)
        -- generic animation code
        self.spri = (self.spri + 1) % 16
        local anim = self.animations[self.state]
        local transformed_spri = (self.spri % #anim) + 1
        
        self.s = anim[transformed_spri]

        -- evil goombas track you
        local x_diff = char.x - self.x
        local y_diff = char.y - self.y

        -- if x is not finished, and if it is chosen OR y is already done, then
        if (abs(x_diff) > 0 and (rnd() > 0.5 or abs(y_diff) == 0)) then
            if (x_diff > 0) then
               self.x += 1
            elseif (x_diff < 0) then
                self.x -= 1
            end
        else
            if (y_diff < 0) then
                self.y -= 1
            elseif (y_diff > 0) then
                self.y += 1
            end
        end
    end
}
-->8
--src/enemies/g_koopa.lua
g_koopa={
    life=1,
    s=128,
    x=nil,
    y=nil,
    state='walk',
    spri=0,
    dir=-1,
    flip=true,

    animations={
        idle={144},
        walk={144,145}
    },

    update=function(self)
        -- generic animation code
        if (t%8 == 0) then
            self.spri = (self.spri + 1) % 16
            local anim = self.animations[self.state]
            local transformed_spri = (self.spri % #anim) + 1
            self.s = anim[transformed_spri]
        end
    end,

    turn=function(self)
        local new_x = self.x + self.dir 

        -- check to see if it hits player
        if (coord_match({self.y, new_x}, {char.y, char.x})) then
            new_cell = {self.y, self.x}
            sfx(5)
            hlog('the koopa bites!')
            pal(11,8)
            char.health -= 1
            return
        end

        if (in_bounds(self.y, new_x) and map[self.y][new_x].flag == 0) then
            self.x = new_x
        else
            self.dir = self.dir * -1
            self.flip = self.dir > 0
        end
    end
}
-->8
--src/enemies/red_koopa.lua
r_koopa={
    life=1,
    s=128,
    x=nil,
    y=nil,
    state='walk',
    spri=0,
    dir=-1,
    flip=true,

    animations={
        idle={146},
        walk={146,147}
    },

    update=function(self)
        -- generic animation code
        if (t%8 == 0) then
            self.spri = (self.spri + 1) % 16
            local anim = self.animations[self.state]
            local transformed_spri = (self.spri % #anim) + 1
            self.s = anim[transformed_spri]
        end
    end,

    turn=function(self)
        local new_y = self.y + self.dir 

        -- check to see if it hits player
        if (coord_match({new_y, self.x}, {char.y, char.x})) then
            new_cell = {self.y, self.x}
            sfx(5)
            hlog('the koopa bites!')
            pal(11,8)
            char.health -= 1
            return
        end

        if (in_bounds(new_y, self.x) and map[new_y][self.x].flag == 0) then
            self.y = new_y
        else
            self.dir = self.dir * -1
            self.flip = self.dir > 0
        end
    end
}
-->8
--src/enemies/goomba.lua
goomba={
    life=1,
    s=128,
    x=nil,
    y=nil,
    state='walk',
    spri=0,

    animations={
        idle={128},
        walk={128,130}
    },

    update=function(self)
        if (t%8 == 0) then
            self.spri = (self.spri + 1) % 16
            local anim = self.animations[self.state]
            local transformed_spri = (self.spri % #anim) + 1
            self.s = anim[transformed_spri]
        end
    end,
    
    turn=function(self)
        -- goombas move in random directions
        local new_cell = nil
        local dirs = {0,0.25,0.5,0.75}
        while new_cell == nil do
            local dir = rnd(dirs)
            local new_x = self.x + cos(dir)
            local new_y = self.y + sin(dir)

            -- check to see if it hits player
            if (coord_match({new_y, new_x}, {char.y, char.x})) then
                new_cell = {self.y, self.x}
                sfx(5)
                hlog('the goomba strikes!')
                pal(11,8)
                char.health -= 1
                break
            end

            if (in_bounds(new_y, new_x) and map[new_y][new_x].flag == 0) then
                new_cell = {new_y, new_x}
            else
                del(dirs, dir)
                if (#dirs == 0) then
                    new_cell = {self.y, self.x}
                end
            end
        end

        self.y = new_cell[1]
        self.x = new_cell[2]
    end
}
-->8
__gfx__
0000000000000bb000000b0000000b000000000000000bb000000bb000000bb000000bb000000000000000000000000000000000000000000000000000000000
000000000000717100071b17000bbbbb00000bb00000717100007171000071710000717100000000000000000000000000000000000000000000000000000000
00700700000071bb00071b1700033b3300007171000071bb007771bb000771bb000071bb00000000000000000000000000000000000000000000000000000000
000770000008bbbb0008bbb00008bbb0000071bb0b08bbbb000777bb000877bb0008bbbb00000000000000000000000000000000000000000000000000000000
00077000b88bb000b88bb000b88bb0000008bbbb38bbb000b88b7700b88b7700b88bb00000000000000000000000000000000000000000000000000000000000
007007000bbb30000bbb30000bbb3000b88bb0000bbb30000bbbbb000bbbbb000bbbbb0000000000000000000000000000000000000000000000000000000000
0000000000b3b00000b3b00000b3b0000bbb300000b3200000b3000000b3000000b3000000000000000000000000000000000000000000000000000000000000
000000000082000000820000008200000082b0000080000008002000080020000800200000000000000000000000000000000000000000000000000000000000
aa0000aa0000000000000000000000000600006000000000060000600aa099090000000000666600000007000066660000000000000000000000000000000000
a000000a0000000000000000666666660600006000666666060000660000000009444440067666d007000000067006d000aaa900009998100000000000000000
00000000000000000000000000000000060000600600000006000000a0000009944444456776666d000000456770000d0a7aaa90097aa9800000000000000000
0000000000000000000110000000000006000060060000000600000000000009444444556666666d000404506000000d0aa7aa9009a7a9200000000000000000
0000000000000000000110000000000006000060060000000600000090000000aaaaaa99666666d170044500600000010aaaaa90089aa8200000000000000000
000000000000000000000000000000000600006006000000060000009000000444aa4455d6666dd100445007d00000d109aaa950028982100000000000000000
a000000a00000000000000006666666606000060060000660066666600000000444444550ddddd10044500000d000d1000999500002221000000000000000000
aa0000aa000000000000000000000000060000600600006000000000909904404444445500111100045070000011110000000000000000000000000000000000
00077000c0eee00c00000000000000000007700005fffff505fffff505fffff50044500000000000000000000000000000000000000000000000000000000000
00777b000eeee000007cc700555505550077780000ffffff00ffdfff00ff77ff0040500000077760000000000000000000000010000000000000000000000000
07bb77300ee0000007c07c70a9995a990788772000fffbbf00fdcdff00f77bff000500000008882000000450000006d000000820000000000000000000000000
07bb77600ee000c076c00c67999459940788776000f33fff00dcc71f007bb73f00040000000282204499451066776d1088998210000000000000000000000000
7777776600ee0000076cc670494004417777776600ff3bbf00dc7c1f007bb77f0005000000088820044451000666d10008882100000000000000000000000000
77777b36c00ee00000777700500001007777782600f33fff00fdc1ff0077773f0066d0000e8822200055100060dd100000221000000000000000000000000000
0777b3300000ee0000000000010110000777822000ff3ff000ff1ff000f773f00066d000e8888220000000000000000000990000000000000000000000000000
0076630000000ee000000000000000000076620000fff00000fff00000fff0000006000022222210000000000000000000010000000000000000000000000000
07710177000000000011a7a000118e800011c7c05ffffff58888888805fffff50088881005fffff5000000000000000000000000000000000000000000000000
077617760000000000117aa00011e88000117cc0088888880820082000ffffff0087681000ffffff000000000000000000000000000000000000000000000000
11771761000110000117aa9a011e88280117cc1c0f8ff8ff0888282800ffffff0086781000f111ff000000000000000000000000000000000000000000000000
771aa700001dd1000117aa9a011e88280117cc1c0888f8f88208288000ffffff008778100011111f000000000000000000000000000000000000000000000000
007aa166001dd100011aaa9a01188828011ccc1c0ff8f88f0008282000ffffff008668100018181f000000000000000000000000000000000000000000000000
0771761100011000011aaa9a01188828011ccc1c08f8f8ff0828282000ffffff0086781000f111ff000000000000000000000000000000000000000000000000
77617770000000000011a9a0001182800011c1c00f8ff8f80082082800fffff00087681000f111f0000000000000000000000000000000000000000000000000
76101670000000000011aaa0001188800011ccc008ff08808820088800fff0000088881000ffff00000000000000000000000000000000000000000000000000
00b553000095580000655c0000000000000000000000000000b3300000b330000b000005f1005050000000000000000000000000000000000000000000000000
0b1b3130092982800616c1c0000000000000000000000000088803000ddd0300030b00b0100001f1001000000000000000000000000000000000000000000000
b31b3131982982826c16c1c100000000000000000000000087882300d7dd130000b00b3005050015000001000000000000000000000000000000000000000000
b31b3131982982826c16c1c100bb000000ee00000099000088882300dddd13000b303000005f500000001c100000000000000000000000000000000000000000
b3133131982882826c1cc1c1000033000000220000004400088203000dd10300300030b001050050010001000000000000000000000000000000000000000000
3313313188288282cc1cc1c100bb300000ee200000994000000003300000033030b00b001f1005551c1000000000000000000000000000000000000000000000
03133110082882200c1cc11000003300000022000000440000003300000033000b0503b00150501001c100000000000000000000000000000000000000000000
003111000082220000c111000000300000002000000040000000030000000300030000035001f150001000000000000000000000000000000000000000000000
00a9900000b33000007cc0000044400000e220000066600000855000000000000000000000000000000000000000000000000000000000000000000000000000
0a1119000b11130007111c00041114000e1212000616160008050500000000000000000000000000000000000000000000000000000000000000000000000000
009991000133310000ccc10000444000002221000686860008855800000000000000000000000000000000000000000000000000000000000000000000000000
0009100001031000000c100000040000000210000066600002888200000000000000000000000000000000000000000000000000000000000000000000000000
0009100000131000000c100000040300000200000006000002080200000000000000000000000000000000000000000000000000000000000000000000000000
0009900000033000000cc00000044300000220000006600002088000000000000000000000000000000000000000000000000000000000000000000000000000
0009100000031000000c100000041000000210000006100002282000000000000000000000000000000000000000000000000000000000000000000000000000
0009910000033100000cc10000044300000220000006600022288220000000000000000000000000000000000000000000000000000000000000000000000000
006d6000006d6000006d600000d0d0000d000d00d00000d0d00000d000000000000030000000000b000000000000000000000000000000000000000000000000
066d6600066d6600066d660006d0d6006d000d60d00000d0d00900d000000000000b300000000b33333000000000000000000000000000000000000000000000
666d6660666d6660666d666066d0d6606d000d60d00000d0d00900d00000000000133100000b3333333333000000000000000000000000000000000000000000
66000660660a066066000660660006606d000d60d00000d0d00900d0000dd0000031130000031333511100000000000000000000000000000000000000000000
66000660660a066066aaa660660006606d000d60d00000d0d90909d0000dd0000133331000000045000000000000000000000000000000000000000000000000
66606660666a66606660666066d0d6606d000d60d00000d0d09990d0000000000b1111300b311f50000000000000000000000000000000000000000000000000
666d6660666d6660666d666066d0d6606d000d60d00000d0d00900d000000000133333330050f500b33330000000000000000000000000000000000000000000
666d6660666d6660666d666066d0d6606d000d60d00000d0d00000d00000000031333311000f4000433100000000000000000000000000000000000000000000
00455100451000000000000000000000000000000000000000000000000dd00000111100000f4044500000000000000000000000000000000000000000000000
0445451045100000000000000000000000000000000000000000000000dddd00000550000000f451000000000000000000000000000000000000000000000000
454545514510000000000000000000000000000000000000000000000dccc1d00004400000000400000000000000000000000000000000000000000000000000
454545414510000000000000000000000000000000000000000000000dccc1d00004445000000f40000000000000000000000000000000000000000000000000
454540414510000000000000000000000000000000000000000000000dccc1d00004500000000044000000000000000000000000000000000000000000000000
454545414510000000000000000000000000000000000000000000000d1111610044400000000004400000000000000000000000000000000000000000000000
4545454145100000000000000000000000000000000000000000000000d666110004400000000004440040000000000000000000000000000000000000000000
55555551451000000000000000000000000000000000000000000000000111110004400000000044444505000000000000000000000000000000000000000000
0504405005044050050440500000000000000000000ddd0000ddddd0000ddd00000ddd0066dddd6666dddd66000b3000000b30000000000000a9990000a99900
005455000054550000554500050440500004400000d000d00d70000d00d000d000d000d00d7888d00d7888d000a9990000a9990000a999000aa999900aa99990
04171740041717400471714000545500055445500d070001d00000010d0700010d07000106078060060780600a1717900a9999900a94a490aa94a490aa999490
04171740041717400471714004171740544444450d800081d08000800d0008810d0000010607206006078060a9171799a1191199a94a9440a94a9440a94a9440
44777744447777444477774404171740045455400188088110880880010808810108080100672600006726009e8899949e889994994a9440994a944094a99440
44444444444444444444444444777744444444440100000101000001001000010010000100677600007627009888119498881194994884400148840001894410
000ff000000ff000000ff0004444444444444444001111100011111000111110001111106d0660d66d0110d609111940091119400e8824000e882000e8820111
0044044004404400044044000055f5500055f5500001110000010100000101000001110000000000000660000099940000999400088220000882200088201110
00000000000000000000000000000000007877800078778000000000007877800000000000000000000000000000000000000000000000000000000000000000
7970b300000000007970e80000000000078877870788778700787780078877870000000000000000000000000000000000000000000000000000000000000000
090b33307970b300090e88807970e800088888880888888807887787088778880000000000000000000000000000000000000000000000000000000000000000
a9933333090b3330a9988882090e8880078888780788887808888888077117780000000000000000000000000000000000000000000000000000000000000000
99933336a993333399988826a9988882067777620677776207888878067117620000000000000000000000000000000000000000000000000000000000000000
00973360999333360097226099988826026666200266662006777762026666200000000000000000000000000000000000000000000000000000000000000000
00097790009733600009779000972260002222000322220332666623002222000000000000000000000000000000000000000000000000000000000000000000
00990090009977900099009000997790033033330030333003222230033033330000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000766666000000000076666600000000007666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00007667766d000000007662266d000000007667766d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000766722766d000000766787766d000000766722766d00000000000000000000000000000000000000000000000000000000000000000000000000000000000
00766668666661000076666866666100007666686666610000000000000000000000000000000000000000000000000000000000000000000000000000000000
00767766867761000076000682006100007677668677610000000000000000000000000000000000000000000000000000000000000000000000000000000000
00767176871761000076000620006100007671762717610000000000000000000000000000000000000000000000000000000000000000000000000000000000
00767176271761000076000660006100007671766717610000000000000000000000000000000000000000000000000000000000000000000000000000000000
0076dd866dd6610000768d8668d861000076dd866dd6610000000000000000000000000000000000000000000000000000000000000000000000000000000000
000666866266d000000686866268d000000666866266d00000000000000000000000000000000000000000000000000000000000000000000000000000000000
00016686666d1000000126686662100000016666666d100000000000000000000000000000000000000000000000000000000000000000000000000000000000
00016161606100000001606120610000000161616061000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00011100000000000001100020000000000176010601000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00017601060100000001760126010000000016161dd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000016161dd00000000016162dd00000000001666d10000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000001666d100000000001666d100000000000111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000011110000000000001111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000020eee02000000000020eee0200000000020eee0200000000020eee0200000000020eee020000000020eee02000000000000000000000000000000000000
00000028ee200000000000028ee20000000000028ee20000000000028ee20000000000028ee2000000000028ee20000000000000000000000000000000000000
000000078e000000000510027ee00000000510028ee00000000510027ee00000000000027ee00000000000078e00000000000000000000000000000000000000
000000028e0000005555111828e000005555111828e000005555111828e000000000000828e00000000000028e00000000000000000000000000000000000000
000000882e000000550528e882e00000000528e882e000000005008882e000000000008882e00000000000882e00000000000000000000000000000000000000
000028e88e8000005500888288e800000000888288e80000000028e888e80000000028e888e80000000028e88e80000000000000000000000000000000000000
00008882828000005500028882e800000000028882e800000000888282e800000000888282e80000000088828280000000000000000000000000000000000000
00000288808000005500022220e086000000022220e086000000028880e086000000028880e08600000002888080000000000000000000000000000000000000
00005822008022000550082200002820000008220000282000000822000028200000582200002800000058220080222000000000000000000000000000000000
01050882068222200055088200026662001008820002666200100882000266620105088200226660001508820682222200000000000000000000000000000000
015006666686222200100e820221162200100e820221162200100e820221162201500e8222112622015006666686122200000000000000000000000000000000
110008e216110022011008e266610622011008e211110622011008e211110622110008e211110622111008e21611002200000000000000000000000000000000
11001882110000221100088216666622110008821100062211000882110006221100188211000622110008821100002200000000000000000000000000000000
11011222220002211100128222066622110012822200062211001282220006221101128222000621110012222200022200000000000000000000000000000000
11111028222222101111112822222221111111282222222111111128222222211111102822222210111111282222222100000000000000000000000000000000
01110002222221000111000222222210011100022222221001110002222222100111000222222100011100022222221000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000004f4f4f4f4f4f4f4f4f4f4f4f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000004f4a4949494949494949474f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000004f4d45464646454645464b4949494700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000004f4d46454646464546455d5e5f5f4b49494949494949494947000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000004f4d45464546464645465e5d5f5f5f5f5f5e5d5e5f5d5e5f48000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000004f4d46454645454645454a494949475f5f5f5e5d5f5e5d5d48000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000004f4d4546454545464646484f004f4d5e5f5f5f5f5f5f5e5d48000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000004f4d4645464546454646484f004f4d5d5f5f5f5f5f5f5f5e48000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000004f4d4546464645464546484f00004d5f5f5f5f5f5f5f5f5f48000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000004f4d4645464646454645484f00004d5d5f5f5f5f5f5f5f5f48000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000004f4d4546454646464546484f00004d5e5d5d5f5f5f5d5f5d48000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000004f4d4645464545464545484f00004b4e4e4e4e4e4e4e4e4e4c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000004f4d4546454545464646484f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000004f4d4645464546454646484f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000004f4d4546464645464546484f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000004f4d4645464646454645484f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000004f4d4546454646464546484f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000004f4d4645464545464545484f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000004f4b4e4e4e4e4e4e4e4e4c4f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000004f4f4f4f4f4f4f4f4f4f4f4f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000d050070500705006050040500305003050020500105000050000000000000000000000000000000000000000000000000000000000000000000e5000f5000e5000f5000550005500055000550005500
00080000135501a550265503255030300283001d3001330013300173001d300243002d3002f300192001820018200192001c2001e200222002320026200272002820029200292002a2002b2002b2000000000000
00040000086310063100630006330a6000a6000a6000a6030960309603086030760307603086030860308603006030e6030f6031a603036030f6030f6030e6030e60313603146031460314603136031260312603
000600001762416621166211460002600026540263302625176041660116601146000260002604026030260527604166011660114600026000260402603026050c7000c7000c7000c7000c7000c7000c7000c705
0005000005554155500c5501c55011550215501855028550185002852011500285101b50028510005001c7051c7041c7001c7001c7001c7001c7001c7001c7001c7001c7001c7001c7001c7001c7001c7001c705
000300003255429550225501b550165500b5500255000650237002370023700237002370023700237002370523704237002370023700237002370023700237002370023700237002370023700237002370023705
00010000090330c0350e0340f0351203516035190341a0351c03320030220352403525035270352b0352e03531033350353803539035190050b0050a005390050900308005390150500504005380053901539005
011200001f7341f7301f7301f7301f7301f7301f7301f7301f7301f7301f7301f7301f7301f7301f7301f7351f7341f7301f7301f7301f7301f7301f7301f7301f7301f7301f7301f7301f7301f7301f7301f735
011100002305033000240502400023050000001f050000001c050000001a050000001c0541c0501c0501c0551f000000001f0541f0501f0501f0552100000000210542105021051210001f0541f0401f0301f020
011000002f0501770430050240002f050000002b050000002f0501c0002b0501c000240501f000230501f0002305033000240502400023050000001f050000001c0541c0501c0501c0551a0541a0501a0501a055
011000001c0500000000000000001f000000001f0500000000000210000000000000210500000000000000001f050000000000000000000000000000000000002305033000240502400023050000001f05000000
011000001c0500000000000000001f000000001f05000000000000000000000000002305000000000002300023050000002405000000000000000000000000002405000000260500000028050000002405000000
0110000026050000000000000000000000000024050000000000000000000000000021050000001f000000001f050000002105000000000000000000000000002405000000260500000028050000002405000000
0110000026050000000000000000000000000024050000000000000000000000000021050000002b0500000028050000000000000000000000000000000000002305033000240502400023050000001f05000000
011000000406300000241000406300000000000406300000106330000000000040630400000000040630406304063000000000004063000000000004063000001063300000000000400004063000000400004063
__music__
01 43444547
00 43444746
00 43444546
02 43444746
00 45424644
00 45424644
00 45424644
02 41424644
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 49424344
01 4a4e4344
00 4c4e4344
00 4c4e4344
02 4d4e4344


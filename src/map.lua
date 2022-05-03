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
        enemies:new(goomba, {x=room[2],y=room[1]})
        if (rnd() > 0.5) then
            enemies:new(g_koopa, {x=room[2],y=room[1]})
        else
            enemies:new(r_koopa, {x=room[2],y=room[1]})
        end
        enemies:new(shy_guy, {x=room[2], y=room[1]})
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
    for g in all(enemies._) do
        del(enemies._, g)
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

MAP_SIZE=24 -- map size in tiles

empty = {
    spr=017,
    flag=1
}

wall = {
    spr=020,
    flag=1
}

floor = {
    spr=018,
    flag=0
}

start = {
    spr=103,
    flag=0
}

exit = {
    spr=102,
    flag=7
}

key = {
    spr=80,
    flag=0
}

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

function generate_map()
    local _map = {}
    for i=0,MAP_SIZE do
        add(_map, {})
        for j=0,MAP_SIZE do
            add(_map[i], empty)
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

    _map[start_c[y]][start_c[x]] = start
    _map[exit_c[y]][exit_c[x]] = exit
    _map[key_c[y]][key_c[x]] = key

    return _map
end

function draw_map(_map)
    for i,row in ipairs(_map) do
        for j,cell in ipairs(row) do
            spr(cell.spr, j*8, i*8)
        end
    end
end
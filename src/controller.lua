-- game controller

function handle_input()
    local did_move = true
    local did_act = true

    if (btnp(0)) then
        -- LEFT
        char:update_position(char.y, char.x - 1)
        char.flip = true
    elseif (btnp(1)) then
        -- RIGHT
        char:update_position(char.y, char.x + 1)
        char.flip = false
    elseif (btnp(2)) then
        -- UP
        char:update_position(char.y - 1, char.x)
    elseif (btnp(3)) then
        -- DOWN
        char:update_position(char.y + 1, char.x)
    else
        did_move = false

        if (btnp(4)) then
            -- USE ITEM (Z)
            hud:use_selected_item()
        elseif (btnp(5)) then
            -- ROTATE ITEM (X)
            hud:rotate_selected_item()
            did_act = false
        else
            did_act = false
            -- no button pressed
        end
    end

    if (did_move) then
        char.idle_counter = 0
        char.state = 'walk'
    end

    if (did_act) then
        char.action_taken = true
        hud:clear_msg()
    end
end
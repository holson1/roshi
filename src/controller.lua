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
            char.flip = true
            hud:use_selected_item(0.5)
        elseif (btnp(1)) then
            -- RIGHT
            char.flip = false
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

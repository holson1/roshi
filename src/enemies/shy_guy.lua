shy_guy={
    life=1,
    s=153,
    x=nil,
    y=nil,
    spri=0,
    a={153,154},
    aggro=false,

    turn=function(self)
        -- shy guys stay still until aggro'd

        local x_diff = char.x - self.x
        local y_diff = char.y - self.y

        if (abs(x_diff) < 5 and abs(y_diff) < 5) then
            self.aggro = true
        elseif (abs(x_diff) > 8 and abs(y_diff) > 8) then
            self.aggro = false
        end

        if (self.aggro) then
            local new_cell = {self.y, self.x}
            local new_x = self.x
            local new_y = self.y

            -- if x is not finished, and if it is chosen OR y is already done, then
            if (abs(x_diff) > 0 and (rnd() > 0.5 or abs(y_diff) == 0)) then
                if (x_diff > 0) then
                   new_x = self.x + 1
                elseif (x_diff < 0) then
                    new_x = self.x - 1
                end
            else
                if (y_diff < 0) then
                    new_y = self.y - 1
                elseif (y_diff > 0) then
                    new_y = self.y + 1
                end
            end

            -- check to see if it hits player
            if (coord_match({new_y, new_x}, {char.y, char.x})) then
                new_cell = {self.y, self.x}
                char:take_damage(1)
                return
            end

            if (in_bounds(new_y, new_x) and map[new_y][new_x].flag == 0) then
                new_cell = {new_y, new_x}
            end

            animations:new(enemy_move(self, new_cell[1] - self.y, new_cell[2] - self.x))
        end
    end
}

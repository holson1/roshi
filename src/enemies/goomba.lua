goomba={
    life=1,
    s=128,
    x=nil,
    y=nil,
    spri=0,
    a={128,130},
    
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
                char:take_damage(1)
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

        animations:new(enemy_move(self, new_cell[1] - self.y, new_cell[2] - self.x))
    end
}
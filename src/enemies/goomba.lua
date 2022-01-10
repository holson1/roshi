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
        -- generic animation code
        self.spri = (self.spri + 1) % 16
        local anim = self.animations[self.state]
        local transformed_spri = (self.spri % #anim) + 1
        
        self.s = anim[transformed_spri]

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
                -- add_new_dust(char.x * 8, char.y * 8, 1, 1, 5, 5, 1, 8)
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
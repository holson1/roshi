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
        local x = ceil(self.x / 8)
        local y = ceil(self.y / 8)
        local new_cell = nil
        local dirs = {0,0.25,0.5,0.75}
        while new_cell == nil do
            local dir = rnd(dirs)
            local new_x = x + cos(dir)
            local new_y = y + sin(dir)
            if (map[new_y][new_x].flag == 0) then
                new_cell = {new_y, new_x}
            else
                del(dirs, dir)
                if (#dirs == 0) then
                    new_cell = {y, x}
                end
            end
        end

        self.y = new_cell[1] * 8
        self.x = new_cell[2] * 8
    end
}
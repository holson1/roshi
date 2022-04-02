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
g_koopa={
    life=1,
    s=128,
    x=nil,
    y=nil,
    spri=0,
    dir=-1,
    flip=true,
    a={144,145},

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
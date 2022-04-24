animations = {
    _ = {},
    new=function(self, animation)
        local anim_copy = {}
        for k,v in pairs(animation) do
            anim_copy[k]=v
        end
        anim_copy.active = true
        add(self._, anim_copy)
    end,

    update=function(self, anim_time)
        for i,v in ipairs(self._) do
            v:update(anim_time)
            if v.active==false then
                del(self._,self._[i])
            end
        end
    end,

    draw=function(self)
        for v in all(self._) do
            if (v.s ~= nil) then
                spr(v.s,v.x*8,v.y*8,1,1,v.flip)
            end
        end
    end
}

char_throw = {
    a={5,5,6,7,8,8},
    update=function(self,anim_time)
        if (anim_time > #self.a) then
            self.active = false
            return
        end
        char.spr = self.a[anim_time]
    end,
}

char_move = function(ydiff, xdiff)
    return {
        a={4,4,4,4},
        ydiff=ydiff,
        xdiff=xdiff, 
        update=function(self,anim_time)
            if (anim_time > #self.a) then
                self.active = false
                char.x = round(char.x)
                char.y = round(char.y)
                return
            end
            char.spr = self.a[anim_time]

            char.x += (self.xdiff / #self.a)
            char.y += (self.ydiff / #self.a)
        end,
    }
end

egg_throw = function(dir)
    return {
        s=58,
        x=char.x,
        y=char.y,
        update=function(self,anim_time)
            self.x += cos(dir)
            self.y += sin(dir)

            if (anim_time > 16) then
                self.active = false
            end

            if (map[self.y][self.x].flag == 1) then
                self.active = false
                animations:new(egg_break(self.x, self.y))
                sfx(2)
            end
        end,
    }
end

egg_break = function(_x,_y)
    return {
        s=58,
        x=_x,
        y=_y,
        a={59,59,60,60,61,61,62,62},
        update=function(self,anim_time)
            if (anim_time > #self.a) then
                self.active = false
                return
            end
            self.s = self.a[anim_time]
        end
    }
end
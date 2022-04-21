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
            spr(v.s,v.x*8,v.y*8,1,1,v.flip)
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
        a={4,4},
        ydiff=ydiff,
        xdiff=xdiff, 
        update=function(self,anim_time)
            if (anim_time > #self.a) then
                self.active = false
                return
            end
            char.spr = self.a[anim_time]

            char.x += (self.xdiff / #self.a)
            char.y += (self.ydiff / #self.a)
        end,
    }
end
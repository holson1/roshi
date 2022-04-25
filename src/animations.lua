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
            if (v.draw ~= nil) then
                v:draw()
            elseif (v.s ~= nil) then
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
        s=32,
        x=char.x,
        y=char.y,
        update=function(self,anim_time)
            add_new_dust(self.x + 0.5, self.y + 0.5, 0, 0, 6, 3, 0, 7)
            self.x += cos(dir)
            self.y += sin(dir)

            -- todo: generic projectile collision check
            if (in_bounds(self.y,self.x)) then
                if (map[self.y][self.x].flag == 1) then
                    self.active = false
                    animations:new(egg_break(self.x, self.y))
                    add_new_dust(self.x + 0.5, self.y + 0.5, 0, 0, 2, 4, 0, 7)
                    sfx(2)
                else
                    for e in all(enemies._) do
                        if (round(e.x) == round(self.x) and round(e.y) == round(self.y)) then
                            e:take_damage(egg.dmg)
                            self.active = false
                            animations:new(egg_break(self.x, self.y))
                            add_new_dust(self.x + 0.5, self.y + 0.5, 0, 0, 2, 4, 0, 7)
                            sfx(2)
                        end
                    end
                end
            else
                self.active = false
            end
        end,
    }
end

egg_break = function(_x,_y)
    return {
        s=32,
        x=_x,
        y=_y,
        a={59,60,60,61,61,62,62},
        update=function(self,anim_time)
            if (anim_time > #self.a) then
                self.active = false
                return
            end
            self.s = self.a[anim_time]
        end
    }
end

damage_num = function(_x, _y, dmg)
    return {
        x=_x,
        y=_y,
        g=-0.3,
        dmg=dmg,
        update=function(self, anim_time)
            if (anim_time > 14) then
                self.active = false
            end

            self.x += 0.05
            self.y += self.g
            self.g += 0.05 
        end,
        draw=function(self)
            print(self.dmg, (self.x + 0.25) * 8, (self.y + 0.25) * 8, 8)
        end
    }
end
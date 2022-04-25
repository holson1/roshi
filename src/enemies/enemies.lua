enemies = {
    _ = {},
    new=function(self, enemy, params)
        local copy = {}
        for k,v in pairs(enemy) do
            copy[k]=v
        end
        for k,v in pairs(params) do
            copy[k]=v
        end
        add(self._, copy)
    end,

    update=function(self)
        for i,v in ipairs(self._) do
            if (t%8 == 0) then
                v.spri = (v.spri + 1) % 16
                local transformed_spri = (v.spri % #v.a) + 1
                v.s = v.a[transformed_spri]
            end

            if (v.life < 1) then
                del(self._,self._[i])
            end
        end
    end,

    turn=function(self)
        for e in all(self._) do
            e:turn()
        end
    end,

    draw=function(self)
        for v in all(self._) do
            spr(v.s,v.x*8,v.y*8,1,1,v.flip)
        end
    end
}
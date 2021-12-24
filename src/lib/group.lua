function new_group(bp)
    return {
        _={},
        bp=bp,
        
        new=function(self,p)
        for k,v in pairs(bp) do
            if v!=nil then
                p[k]=v
            end
        end
        p.alive=true
            add(self._,p)
        end,
           
        update=function(self)
            for i,v in ipairs(self._) do
                v:update()
                if v.alive==false then
                del(self._,self._[i])
                end
            end
        end,
        
        -- todo: change to sspr
        draw=function(self)
            for v in all(self._) do
                spr(v.s,v.x,v.y,ceil(v.w/8),ceil(v.h/8),v.d)
            end
        end
    }
end
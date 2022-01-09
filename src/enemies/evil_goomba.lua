evil_goomba={
    life=1,
    s=128,
    x=nil,
    y=nil,
    state='walk',
    spri=0,

    animations={
        walk={131,132}
    },

    update=function(self)
        -- generic animation code
        self.spri = (self.spri + 1) % 16
        local anim = self.animations[self.state]
        local transformed_spri = (self.spri % #anim) + 1
        
        self.s = anim[transformed_spri]

        -- evil goombas track you
        local x_diff = char.x - self.x
        local y_diff = char.y - self.y

        -- if x is not finished, and if it is chosen OR y is already done, then
        if (abs(x_diff) > 0 and (rnd() > 0.5 or abs(y_diff) == 0)) then
            if (x_diff > 0) then
               self.x += 1
            elseif (x_diff < 0) then
                self.x -= 1
            end
        else
            if (y_diff < 0) then
                self.y -= 1
            elseif (y_diff > 0) then
                self.y += 1
            end
        end
    end
}
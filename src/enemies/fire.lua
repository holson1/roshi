fire={
    life=1,
    s=152,
    x=nil,
    y=nil,
    dx=nil,
    dy=nil,
    spri=0,
    a={152},
    flip=false,
    vflip=false,

    update=function(self)
        if (t % 4 == 0) then
            add_new_dust(self.x + 0.5, self.y + 0.5, 0, 0, 6, 2, -0.02, 8)
            if (self.flip == self.vflip) then
                self.flip = not(self.flip)
            else
                self.vflip = not(self.vflip)
            end
        end
    end,

    turn=function(self)
        self.x += self.dx
        self.y += self.dy
    end
}

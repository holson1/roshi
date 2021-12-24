shot={
    w=4,
    h=4,
    s=195,
    x=nil,
    y=nil,
    dx=nil,
    dy=nil,
    d=nil,

    update=function(self)
        -- destroy on OOB
        if self.x < cam.x
            or self.x > cam.x + 128
            or self.y < cam.y
            or self.y > cam.y + 128 then
                self.alive = false
        end
  
        if t%2 == 0 then
            add_new_dust(self.x + self.w, self.y + self.h, self.dx/2, self.dy/2, 9, rnd(3), 0, 15)
        end
   
        self.x+=self.dx
        self.y+=self.dy	
    end
}
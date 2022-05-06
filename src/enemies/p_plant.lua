piranha_plant={
    life=1,
    s=150,
    x=nil,
    y=nil,
    spri=0,
    a={150},
    timer=0,

    turn=function(self)
        self.timer = max(self.timer - 1, 0)
        local x_diff = char.x - self.x
        local y_diff = char.y - self.y

        -- todo: raycast sightline
        if (self.timer == 0) then
            if (x_diff == 0 and abs(y_diff) < 5) then
                self.timer = 4

                enemies:new(fire, {x=self.x, y=self.y, dx=0, dy=y_diff/abs(y_diff)}) 
            elseif (y_diff == 0 and abs(x_diff) < 5) then
                self.timer = 4

                enemies:new(fire, {x=self.x, y=self.y, dx=x_diff/abs(x_diff), dy=0}) 
            end
        end
    end
}

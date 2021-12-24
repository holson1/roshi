boom={
    s=008,
    w=8,
    h=8,
    x=nil,
    y=nil,

    update=function(self)
            self.s+=1
            if(self.s>11) self.alive=false
    end
}
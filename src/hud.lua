-- hud


function _use_inspect()
end

function _use_tongue()
end

function _use_egg()
end

function _use_key()
end

function init_hud()
    local hud = {

        items={
            {spr=034, name='inspect', desc='look around', use=_use_inspect},
            {spr=033, name='tongue', desc='grab things 2 tiles away', use=_use_tongue},
            {spr=032, name='egg', desc='throw at enemies', use=_use_egg}
        },
        selected_item=1,
        msg1="welcome to roshi's dungeon",
        msg2='find the key',
        coins=05,
        spri=0,

        set_msg = function(self, m1, m2)
            self.msg1 = m1
            self.msg2 = m2
        end,
        
        clear_msg = function(self)
            self.msg1 = ''
            self.msg2 = ''
        end,

        pickup_item = function(self, item)
            add(self.items, item)
            self:set_msg('got: `' .. item.name .. '`', item.desc)
        end,

        update = function(self)
            if (t%8 == 0) then
                self.spri = (self.spri + 1) % 2
            end

            if (btnp(4)) then
                self.items[self.selected_item].use()
            end

            if (btnp(5)) then
                self.selected_item = (self.selected_item + 1) % #self.items
                if (self.selected_item == 0) then
                    self.selected_item = #self.items
                end

                self:set_msg(self.items[self.selected_item]['name'],self.items[self.selected_item]['desc'])
            end
        end,

        draw = function(self)
            local x = cam.x*8
            local y = cam.y*8

            -- items
            rectfill(x,y,x+7,y+128,0)
            rect(x,y,x+7,y+63,7)
            rectfill(x,y+2,x+7,y+61,0)


            for i=1,#self.items do
                spr(self.items[i].spr,x,y+(i*8))
                if (i == self.selected_item) then
                    spr(016 + self.spri,x,y+(i*8))
                end
            end

            -- text
            rectfill(x,y+112,x+127,y+127,0)
            rect(x+8,y+112,x+127,y+127,7)
            rectfill(x+10,y+112,x+125,y+127,0)

            print(self.msg1, x+12, y+114, 15)
            print(self.msg2, x+12, y+121, 15)

            -- health
            for i=0,(char.max_health-1) do
                spr(049,x,y+96-(i*8))
            end
            for i=0,(char.health-1) do
                spr(048,x,y+96-(i*8))
            end

            -- coins
            spr(050,x-1,y+111)
            if (self.coins > 9) then
                print(self.coins,x,y+120,10)
            else
                print('0' .. self.coins,x,y+120,10)
            end
        end
    }
    return hud
end
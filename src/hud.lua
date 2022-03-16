-- hud

function init_hud()
    local hud = {

        items={inspect, tongue, egg},
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
            local existing_item = self:find_item(item.name)

            if (existing_item) then
                if (existing_item.count != nil) then
                    existing_item.count += 1
                end
            else
                item.count = item._count
                add(self.items, item)
            end

            sfx(item.sfx)
            self:set_msg('got: `' .. item.name .. '`', item.desc)
        end,

        find_item = function(self, name)
            for i in all(self.items) do
                if (i.name == name) then
                    return i
                end
            end
            return nil 
        end,

        update = function(self)
            if (t%8 == 0) then
                self.spri = (self.spri + 1) % 2
            end

            -- USE ITEM (Z)
            if (btnp(4)) then
                local this_item = self.items[self.selected_item]

                sfx(this_item.sfx) 
                this_item.use(this_item)

                -- catch error w/ using last item
                if (self.selected_item > #self.items) then
                    self.selected_item = #self.items
                end
            end

            -- ROTATE ITEM (X)
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
            for i=1,#self.items do
                spr(self.items[i].spr,x,y+(i*8)-8)
                local item_count = self.items[i].count

                if (item_count != nil and item_count > 1) then
                    print(item_count,x+5,y+(i*8)-5,8)
                end
                if (i == self.selected_item) then
                    spr(016 + self.spri,x,y+(i*8)-8)
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

            -- level
            if (levels != nil) then
                print(levels[level], x+16, y, 10)
            end
            print('l' .. level, x+116, y, 10)
        end
    }
    return hud
end
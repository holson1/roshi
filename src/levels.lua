LEVEL_COUNT = 50

-- sky castle dungeon
SCD = {
   "regular",
   "regular",
   "regular",
   "regular",
   "extra_chest",
   "extra_chest",
   "grass_cave",
   "grass_cave",
   "test",
   "test",
   "test",
   "hidden",
   "hidden"
}

-- forest
FOR = {
   "regular_for" 
}

-- sea cliffs
SEA = {}
-- moss cave
MOS = {}
-- town
TWN = {}
-- poison tower
PSN = {}
-- skeleton pit
SKP = {}
-- lava zone
LAV = {}
-- hospital
HSP = {}
-- void
VOI = {}


function roll_levels()
    local levels = {}

    for i=1,LEVEL_COUNT do

        this_level = nil
        -- TODO: expand this to include more types
        if (i < 10) then
            this_level = roll_and_extract(SCD)
        else
            this_level = roll_and_extract(FOR)
        end

        if (this_level != nil) then
            add(levels, this_level)
        end
    end

    return levels
end

function roll_and_extract(level_list)
    if (#level_list == 1) then
        return level_list[1]
    end

    local idx = rndi(1,#level_list)
    local lv = level_list[idx]
    del(level_list, i)
    return lv
end

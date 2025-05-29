Entity = require "components.entities.entity"
COMMON_UTILS = require "components.common_utils"
Tank_enemy = {}


setmetatable(Tank_enemy, {__index = Entity})

function Tank_enemy:new(grid_row, grid_col)
    local instance ={}
    setmetatable(instance, Entity)
    instance.grid_row=grid_row
    instance.grid_col=grid_col

    local x_coord, y_coord = COMMON_UTILS:fetchScreenCoords(grid_row, grid_col)
    instance.act_x=x_coord
    instance.act_y=y_coord
    return instance
end

function Tank_enemy:MoveEntity(mapObject)
    local directions = {"up","down","left","right"}

    -- Step 1: Pick a random index from the list of keys
    local randomIndex = love.math.random(#directions)

    -- Step 3: Use the random index to get the direction name
    local randomDirectionName = directions[randomIndex]
    local grid_dir =  Globals.GRID_DIRECTIONS_MAP[randomDirectionName]
    local is_move_valid = mapObject:TestMap(self.grid_row, self.grid_col, grid_dir.row, grid_dir.col)

    if is_move_valid then
        -- add tile to the entity 
        local old_tile = mapObject:FetchTile(self.grid_row, self.grid_col)
        local new_tile = mapObject:FetchTile(self.grid_row + grid_dir.row, self.grid_col + grid_dir.col)
        
        if not new_tile.entity then
            old_tile.entity = nil
            new_tile.entity = self

            self.tile = new_tile

            self.grid_row = self.grid_row + grid_dir.row
            self.grid_col = self.grid_col + grid_dir.col
        -- elseif getmetatable(new_tile.entity)==Player then
        --     print("ENEMY ATTACK PLAYER")
        end

    end


    -- jerk motion
    -- else
    --     -- if movement was not valid add jerk to the enemy position
    --     self.act_x = self.act_x + (dir.dx * self.JERK_OFFSET)
    --     self.act_y = self.act_y + (dir.dy * self.JERK_OFFSET)
    -- end
end

return Tank_enemy
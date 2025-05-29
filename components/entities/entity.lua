COMMON_UTILS = require "components.common_utils"
Globals = require "globals"
-- Player = require "components.player"

Entity = {
    JERK_OFFSET = 15, -- offset by which the Entity is moved on an invalid move
    grid_row = nil,
    grid_col = nil,
    act_x = nil,
    act_y = nil,
    speed = 15
}
Entity.__index = Entity 


--[[required: grid_x, grid_y, act_x, act_y, speed]]
function Entity:new(grid_row, grid_col)
    local instance ={}
    setmetatable(instance, Entity)

    instance.grid_row=grid_row
    instance.grid_col=grid_col
    instance.act_x=grid_col * Globals.TILE_SIZE
    instance.act_y=grid_row * Globals.TILE_SIZE

    instance.tile=nil


    return instance
end

function Entity:MoveEntity(mapObject)
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


function Entity:update(dt)
    local dest_x, dest_y = COMMON_UTILS:fetchScreenCoords(self.grid_row, self.grid_col)
    self.act_y = COMMON_UTILS:Lerp(self.act_y,dest_y, dt * self.speed )
    self.act_x = COMMON_UTILS:Lerp(self.act_x,dest_x, dt * self.speed )
end

function Entity:draw()
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle("fill", self.act_x, self.act_y, Globals.TILE_SIZE, Globals.TILE_SIZE)
    love.graphics.setColor(1, 1, 1, 1)
end

return Entity
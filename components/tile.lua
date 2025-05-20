require "components.utils.set"

-- base class
Tile = {}
Tile.__index = Tile

--- creates a new tile
---@x : int
---@y : int
---@sprite : int
---@passable : boolean
function Tile:new(x, y, sprite, passable)

    local instance ={}
    setmetatable(instance, self)

    instance.x = x
    instance.y = y
    instance.sprite = sprite
    instance.passable = passable

    instance.size_offset = -10
    instance.wall_directions = {}

    return instance
end

function Tile:draw()
    return
end
function Tile:doStuff()
    return
end



-- ---WALL TILE
-- Tile.Wall_tile = {}
-- Tile.Wall_tile.__index = Tile.Wall_tile
-- setmetatable(Tile.Wall_tile, {__index = Tile})

-- function Tile.Wall_tile:draw()
--     for _, direction in ipairs(self.wall_directions) do
--         if direction.x == 0 and direction.y ==-1 then
--             -- upper wall
--             love.graphics.line(self.x * TILE_SIZE, self.y * TILE_SIZE, (self.x * TILE_SIZE) + TILE_SIZE, (self.y* TILE_SIZE))
--         elseif direction.x == 0 and direction.y ==1 then
--             -- lower wall
--             love.graphics.line(self.x * TILE_SIZE, (self.y * TILE_SIZE) + TILE_SIZE, (self.x * TILE_SIZE) + TILE_SIZE, (self.y* TILE_SIZE)+ TILE_SIZE)
--         elseif direction.x == -1 and direction.y ==0 then
--             -- left wall
--             love.graphics.line(self.x * TILE_SIZE, (self.y * TILE_SIZE), self.x * TILE_SIZE  , (self.y* TILE_SIZE) + TILE_SIZE)
--         elseif direction.x == 1 and direction.y ==0 then
--             -- right wall
--             love.graphics.line((self.x * TILE_SIZE)+ TILE_SIZE, (self.y * TILE_SIZE), (self.x * TILE_SIZE)+TILE_SIZE, (self.y* TILE_SIZE)+TILE_SIZE)
--         end

--     end
-- end

-- function Tile.Wall_tile:new(x, y, wall_directions) 
--     local instance  = Tile:new(x, y, nil, false)
--     setmetatable(instance, Tile.Wall_tile)
--     instance.wall_directions = COMMON_UTILS:Set(wall_directions)
--     return instance
-- end


--FLOOR TILE
Tile.Floor_tile = {}
Tile.Floor_tile.__index = Tile.Floor_tile
setmetatable(Tile.Floor_tile, {__index = Tile})

function Tile.Floor_tile:draw()
    for _, direction in ipairs(self.wall_directions:elements()) do
        if direction.x == 0 and direction.y ==-1 then
            -- upper wall
            love.graphics.line(self.x * TILE_SIZE, self.y * TILE_SIZE, (self.x * TILE_SIZE) + TILE_SIZE, (self.y* TILE_SIZE))
        elseif direction.x == 0 and direction.y ==1 then
            -- lower wall
            love.graphics.line(self.x * TILE_SIZE, (self.y * TILE_SIZE) + TILE_SIZE, (self.x * TILE_SIZE) + TILE_SIZE, (self.y* TILE_SIZE)+ TILE_SIZE)
        elseif direction.x == -1 and direction.y ==0 then
            -- left wall
            love.graphics.line(self.x * TILE_SIZE, (self.y * TILE_SIZE), self.x * TILE_SIZE  , (self.y* TILE_SIZE) + TILE_SIZE)
        elseif direction.x == 1 and direction.y ==0 then
            -- right wall
            love.graphics.line((self.x * TILE_SIZE)+ TILE_SIZE, (self.y * TILE_SIZE), (self.x * TILE_SIZE)+TILE_SIZE, (self.y* TILE_SIZE)+TILE_SIZE)
        end

    end
end

function Tile.Floor_tile:isMoveAllowed(x, y)
    for _, direction in ipairs(self.wall_directions:elements()) do
        if direction.x ==x and direction.y == y then
            return false
        end
    end
    return true
end

function Tile.Floor_tile:new(x, y, wall_directions)
    local instance  = Tile:new(x, y, nil, true)
    setmetatable(instance, Tile.Floor_tile)
    instance.wall_directions = Set.new(wall_directions)
    return instance
end
function Tile.Floor_tile:doStuff()

end

-- EXIT TILE
Tile.Exit_tile = {}
Tile.Exit_tile.__index = Tile.Exit_tile
setmetatable(Tile.Exit_tile, {__index = Tile})

function Tile.Exit_tile:draw()
    love.graphics.setColor(0,1,0,1)
    love.graphics.rectangle("fill", self.x * TILE_SIZE, self.y * TILE_SIZE, TILE_SIZE, TILE_SIZE)
    love.graphics.setColor(1,1,1,1)

end
function Tile.Exit_tile:new(x, y)
    local instance  = Tile:new(x, y, nil, true)
    setmetatable(instance, Tile.Exit_tile)
    instance.wall_directions = {}
    return instance
end
function Tile.Exit_tile:doStuff()
    LoadNewMap()
end

return Tile
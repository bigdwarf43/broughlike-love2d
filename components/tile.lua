require "components.utils.set"
require "components.common_utils"
Events = require "components.events"

-- base class
Tile = {}
Tile.__index = Tile

--- creates a new tile
---@row : int
---@col : int
---@sprite : int
---@passable : boolean
function Tile:new(row, col, sprite, passable)

    local instance ={}
    setmetatable(instance, self)

    instance.row = row
    instance.col = col
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

function Tile:isMoveAllowed(row, col)

    local direction
    if row==-1 and col==0 then
        direction= "up"
    elseif row==1 and col==0  then
        direction= "down"
    elseif row==0 and col==-1  then
        direction= "left"
    elseif row==0 and col==1  then
        direction= "right"
    end

    print("CURRENT")
    print(self.row, self.col)
    print("MOVING IN")
    print(row, col)

    print("CURRENT WALLS")
    for _, val in ipairs(self.wall_directions:elements()) do
        print(val)
    end

    return not self.wall_directions:contains(direction)

end



---WALL TILE
Tile.Border_tile = {}
Tile.Border_tile.__index = Tile.Border_tile
setmetatable(Tile.Border_tile, {__index = Tile})

function Tile.Border_tile:draw()
    local x_coord, y_coord = COMMON_UTILS:fetchScreenCoords(self.row, self.col)
    love.graphics.rectangle("line", x_coord, y_coord, Globals.TILE_SIZE, Globals.TILE_SIZE)
    -- love.graphics.print(tostring(self.row)..","..tostring(self.col), x_coord, y_coord)
end

function Tile.Border_tile:new(row, col) 
    local instance  = Tile:new(row, col, nil, false)
    setmetatable(instance, Tile.Border_tile)
    instance.wall_directions = Set.new({"up", "down", "left", "right"})
    return instance
end


--FLOOR TILE
Tile.Floor_tile = {}
Tile.Floor_tile.__index = Tile.Floor_tile
setmetatable(Tile.Floor_tile, {__index = Tile})


function Tile.Floor_tile:draw(level_map)
    -- the function assumes that the walls are being drawn in a row wise manner
    -- it skips the wall drawing if it is already drawn in a previous tile

    local x_coord, y_coord = COMMON_UTILS:fetchScreenCoords(self.row, self.col)
    -- love.graphics.print(tostring(self.row)..","..tostring(self.col), x_coord, y_coord)

    for _, direction in ipairs(self.wall_directions:elements()) do
        if direction=="up" and not level_map[self.row-1][self.col].wall_directions:contains("down") then
            -- upper wall
            love.graphics.line(x_coord, y_coord, x_coord + Globals.TILE_SIZE, y_coord)
        elseif direction=="down" and getmetatable(level_map[self.row+1][self.col])~=Tile.Border_tile then
            -- lower wall
            love.graphics.line(x_coord, y_coord + Globals.TILE_SIZE, x_coord + Globals.TILE_SIZE, y_coord+ Globals.TILE_SIZE)
        elseif direction=="left" and not level_map[self.row][self.col-1].wall_directions:contains("right") then
            -- left wall
            love.graphics.line(x_coord, y_coord, x_coord  , y_coord + Globals.TILE_SIZE)
        elseif direction=="right" and getmetatable(level_map[self.row][self.col+1])~=Tile.Border_tile then
            -- right wall
            love.graphics.line(x_coord+ Globals.TILE_SIZE, y_coord, x_coord+Globals.TILE_SIZE, y_coord+Globals.TILE_SIZE)
        end

    end
end



function Tile.Floor_tile:new(row, col, wall_directions)
    local instance  = Tile:new(row, col, nil, true)
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
    local xcoords, ycoords = COMMON_UTILS:fetchScreenCoords(self.row, self.col)
    love.graphics.setColor(0,1,0,1)
    love.graphics.rectangle("fill", xcoords, ycoords, Globals.TILE_SIZE, Globals.TILE_SIZE)
    love.graphics.setColor(1,1,1,1)
end

function Tile.Exit_tile:new(row, col, room_row, room_col, exit_dir)
    local instance  = Tile:new(row, col, nil, true)
    setmetatable(instance, Tile.Exit_tile)
    instance.wall_directions = Set.new({})
    instance.room_row = room_row
    instance.room_col = room_col
    instance.exit_dir = exit_dir

    return instance
end
function Tile.Exit_tile:doStuff()
    Events.on_player_exit:emit(self.room_row, self.room_col, self.exit_dir)
    -- LoadNewMap()
end

return Tile
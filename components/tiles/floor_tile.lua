Tile = require "components.tiles.tile"
Border_tile = require "components.tiles.border_tile"

--FLOOR TILE
Floor_tile = {}
Floor_tile.__index = Floor_tile
setmetatable(Floor_tile, {__index = Tile})


function Floor_tile:draw(level_map)
    -- the function assumes that the walls are being drawn in a row wise manner
    -- it skips the wall drawing if it is already drawn in a previous tile

    local x_coord, y_coord = COMMON_UTILS:fetchScreenCoords(self.row, self.col)

    -- love.graphics.print(tostring(self.row)..","..tostring(self.col), x_coord, y_coord)
    
    love.graphics.setColor(1,1,0,1)
    
    for _, direction in ipairs(self.wall_directions:elements()) do
        if direction=="up" and not level_map[self.row-1][self.col].wall_directions:contains("down") then
            -- upper wall
            love.graphics.line(x_coord, y_coord, x_coord + Globals.TILE_SIZE, y_coord)
        elseif direction=="down" and getmetatable(level_map[self.row+1][self.col])~=Border_tile then
            -- lower wall
            love.graphics.line(x_coord, y_coord + Globals.TILE_SIZE, x_coord + Globals.TILE_SIZE, y_coord+ Globals.TILE_SIZE)
        elseif direction=="left" and not level_map[self.row][self.col-1].wall_directions:contains("right") then
            -- left wall
            love.graphics.line(x_coord, y_coord, x_coord  , y_coord + Globals.TILE_SIZE)
        elseif direction=="right" and getmetatable(level_map[self.row][self.col+1])~=Border_tile then
            -- right wall
            love.graphics.line(x_coord+ Globals.TILE_SIZE, y_coord, x_coord+Globals.TILE_SIZE, y_coord+Globals.TILE_SIZE)
        end

    end

    -- if self.entity then
    --     love.graphics.setColor(0,0,1,1)
    --     love.graphics.rectangle("line", x_coord, y_coord, Globals.TILE_SIZE, Globals.TILE_SIZE)
    -- end

    love.graphics.setColor(1,1,1,1)

end



function Floor_tile:new(row, col, wall_directions)
    local instance  = Tile:new(row, col, nil, true)
    setmetatable(instance, Floor_tile)
    instance.wall_directions = Set.new(wall_directions)
    return instance
end

function Floor_tile:stepped_on(entity)
    self.entity = entity
end


return Floor_tile
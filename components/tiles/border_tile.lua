Tile = require "components.tiles.tile"

---WALL TILE
Border_tile = {}
Border_tile.__index = Border_tile
setmetatable(Border_tile, {__index = Tile})

function Border_tile:draw()
    local x_coord, y_coord = COMMON_UTILS:fetchScreenCoords(self.row, self.col)

    -- love.graphics.rectangle("line", x_coord, y_coord, Globals.TILE_SIZE, Globals.TILE_SIZE)
    -- love.graphics.print(tostring(self.row)..","..tostring(self.col), x_coord, y_coord)
    -- quad = Globals.TILE_SHEET_ENVIRONMENT:fetch_quad(6)
    local quad =  nil
    -- Top-left corner
    if self.col == 1 and self.row == 1 then
        quad = Globals.TILE_SHEET_ENVIRONMENT:fetch_quad(10) -- Assuming quad 10 is for the top-left corner
    -- Top-right corner
    elseif self.col == Globals.MAP_COL and self.row == 1 then
        quad = Globals.TILE_SHEET_ENVIRONMENT:fetch_quad(11) -- Assuming quad 11 is for the top-right corner
    -- Bottom-left corner
    elseif self.col == 1 and self.row == Globals.MAP_ROW then
        quad = Globals.TILE_SHEET_ENVIRONMENT:fetch_quad(12) -- Assuming quad 12 is for the bottom-left corner
    -- Bottom-right corner
    elseif self.col == Globals.MAP_COL and self.row == Globals.MAP_ROW then
        quad = Globals.TILE_SHEET_ENVIRONMENT:fetch_quad(13) -- Assuming quad 13 is for the bottom-right corner
    -- Edges (existing logic)
    elseif self.col == 1 then
        quad = Globals.TILE_SHEET_ENVIRONMENT:fetch_quad(6)
    elseif self.col == Globals.MAP_COL then
        quad = Globals.TILE_SHEET_ENVIRONMENT:fetch_quad(7)
    elseif self.row == 1 then
        quad = Globals.TILE_SHEET_ENVIRONMENT:fetch_quad(8)
    elseif self.row == Globals.MAP_ROW then
        quad = Globals.TILE_SHEET_ENVIRONMENT:fetch_quad(9)
    end

    if quad then
        love.graphics
        .draw(Globals.TILE_SHEET_ENVIRONMENT.tilesetImage,quad, x_coord, y_coord, 0, -- Rotation (0 for no rotation)
        Globals.TILE_SCALE_X, -- X scale factor (default to 1 if not provided)
        Globals.TILE_SCALE_Y -- Y scale factor (default to 1 if not provided)
        )
    end


end

function Border_tile:new(row, col) 
    local instance  = Tile:new(row, col, nil, false)
    setmetatable(instance, Border_tile)
    instance.wall_directions = Set.new({"up", "down", "left", "right"})
    return instance
end

return Border_tile
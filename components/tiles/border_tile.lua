Tile = require "components.tiles.tile"

---WALL TILE
Border_tile = {}
Border_tile.__index = Border_tile
setmetatable(Border_tile, {__index = Tile})

function Border_tile:draw()
    local x_coord, y_coord = COMMON_UTILS:fetchScreenCoords(self.row, self.col)
    -- love.graphics.rectangle("line", x_coord, y_coord, Globals.TILE_SIZE, Globals.TILE_SIZE)
    -- love.graphics.print(tostring(self.row)..","..tostring(self.col), x_coord, y_coord)
love.graphics
    .draw(Globals.TILE_SHEET.tilesetImage, Globals.TILE_SHEET:fetch_quad(17), x_coord, y_coord, 0, -- Rotation (0 for no rotation)
    Globals.TILE_SCALE_X, -- X scale factor (default to 1 if not provided)
    Globals.TILE_SCALE_Y -- Y scale factor (default to 1 if not provided)
)

end

function Border_tile:new(row, col) 
    local instance  = Tile:new(row, col, nil, false)
    setmetatable(instance, Border_tile)
    instance.wall_directions = Set.new({"up", "down", "left", "right"})
    return instance
end

return Border_tile
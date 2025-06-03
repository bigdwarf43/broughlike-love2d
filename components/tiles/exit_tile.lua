Tile =  require "components.tiles.tile"
Events = require "components.events"
-- EXIT TILE
Exit_tile = {}
Exit_tile.__index = Exit_tile
setmetatable(Exit_tile, {__index = Tile})

function Exit_tile:draw()
    local xcoords, ycoords = COMMON_UTILS:fetchScreenCoords(self.row, self.col)
    -- love.graphics.setColor(0,1,0,1)
    -- love.graphics.rectangle("fill", xcoords, ycoords, Globals.TILE_SIZE, Globals.TILE_SIZE)
    -- love.graphics.setColor(1,1,1,1)

    love.graphics.draw(Globals.TILE_SHEET.tilesetImage, Globals.TILE_SHEET:fetch_quad(444), xcoords, ycoords, 0,
        Globals.TILE_SCALE_X, Globals.TILE_SCALE_Y)

end


function Exit_tile:new(row, col, room_row, room_col, exit_dir)
    local instance  = Tile:new(row, col, nil, true)
    setmetatable(instance, Exit_tile)
    instance.wall_directions = Set.new({})
    instance.room_row = room_row
    instance.room_col = room_col
    instance.exit_dir = exit_dir

    return instance
end
function Exit_tile:stepped_on()
    Events.on_player_exit:emit(self.room_row, self.room_col, self.exit_dir)
    -- LoadNewMap()
end

return Exit_tile
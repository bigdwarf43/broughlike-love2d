tile_sheet = require "components.graphics_handlers.tile_sheet"
Globals = {

    WORLD_SIZE_ROW=5,
    WORLD_SIZE_COL=5,
    WORLD_ARRAY = {},
    CURRENT_ROW = nil,
    CURRENT_COL = nil,

    -- MAP 
    MAP_ROW = 11,
    MAP_COL = 11,

    TILE_SIZE = 16,
    TILE_OFFSET = 1.3,
    TILE_SCALE_X =1,
    TILE_SCALE_Y =1,


    GRID_DIRECTIONS_MAP = {
        up    = { row =  -1, col = 0},
        down  = { row =  1, col =  0},
        left  = { row = 0, col =  -1},
        right = { row =  0, col =  1}
    },

    TILE_SHEET = tile_sheet:new("assests/1bitpack_kenney_1.2/Tilesheet/colored-transparent_packed.png", 16, 16)

}

return Globals

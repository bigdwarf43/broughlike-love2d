tile_sheet = require "components.graphics_handlers.tile_sheet"
Globals = {

    WORLD_SIZE_ROW=5,
    WORLD_SIZE_COL=5,
    WORLD_ARRAY = {},
    CURRENT_ROW = nil, -- current room row on world grid
    CURRENT_COL = nil, -- current room col on world grid

    -- MAP 
    MAP_ROW = 11, -- number of rows a map can have
    MAP_COL = 11, -- number of cols a map can have

    TILE_SIZE = 16,
    TILE_OFFSET =1,
    TILE_SCALE_X =1,
    TILE_SCALE_Y =1,

    WALL_OFFSET =2, 

    GRID_DIRECTIONS_MAP = {
        up    = { row =  -1, col = 0},
        down  = { row =  1, col =  0},
        left  = { row = 0, col =  -1},
        right = { row =  0, col =  1}
    },
    
    --fonts
    SMALL_FONT = love.graphics.newFont(10, "mono"),

    TILE_SHEET_CHARACTER = tile_sheet:new("assests/kenney_tiny-dungeon/Tilemap/tilemap_packed.png", 16, 16),
    TILE_SHEET_ENVIRONMENT = tile_sheet:new("assests/consolidated_sprite_sheets/environment.png",16,16),

    DEBUG =false
}

return Globals

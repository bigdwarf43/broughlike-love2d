
Globals = {

    WORLD_SIZE_ROW=5,
    WORLD_SIZE_COL=5,
    WORLD_ARRAY = {},
    CURRENT_ROW = nil,
    CURRENT_COL = nil,

    -- MAP 
    MAP_ROW = 11,
    MAP_COL = 11,

    TILE_SIZE = 32,
    TILE_OFFSET = 1.2,

    GRID_DIRECTIONS_MAP = {
        up    = { row =  -1, col = 0},
        down  = { row =  1, col =  0},
        left  = { row = 0, col =  -1},
        right = { row =  0, col =  1}
    }



}

return Globals

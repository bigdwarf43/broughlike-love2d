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
    
    local quad = Globals.TILE_SHEET_ENVIRONMENT:fetch_quad(1)
    if (self.row + self.col)%2==0 then
        quad = Globals.TILE_SHEET_ENVIRONMENT:fetch_quad(0)
    else
        quad = Globals.TILE_SHEET_ENVIRONMENT:fetch_quad(1)
    end
    
    love.graphics
        .draw(Globals.TILE_SHEET_ENVIRONMENT.tilesetImage, quad, x_coord, y_coord, 0, -- Rotation (0 for no rotation)
        Globals.TILE_SCALE_X, -- X scale factor (default to 1 if not provided)
        Globals.TILE_SCALE_Y -- Y scale factor (default to 1 if not provided)
    )
     if Globals.DEBUG then
        -- smallFont = love.graphics.newFont(7)
        love.graphics.setFont(Globals.SMALL_FONT)

        love.graphics.print(tostring(self.row)..","..tostring(self.col), x_coord, y_coord)
    end

end

function Floor_tile:draw_walls(level_map)
    local x_coord, y_coord = COMMON_UTILS:fetchScreenCoords(self.row, self.col)
    
   
    for _, direction in ipairs(self.wall_directions:elements()) do
        local wall_coord_x = x_coord
        local wall_coord_y = y_coord
        local wall_quad =  nil

        if direction=="up" and not level_map[self.row-1][self.col].wall_directions:contains("down") then
            -- upper wall
            wall_quad = 2
            love.graphics.draw(Globals.TILE_SHEET_ENVIRONMENT.tilesetImage,
                Globals.TILE_SHEET_ENVIRONMENT:fetch_quad(wall_quad), 
                wall_coord_x, 
                wall_coord_y-Globals.WALL_OFFSET, 
                0, -- Rotation (0 for no rotation)
                Globals.TILE_SCALE_X, -- X scale factor (default to 1 if not provided)
                Globals.TILE_SCALE_Y -- Y scale factor (default to 1 if not provided)
            )
            -- love.graphics.line(x_coord, y_coord, x_coord + Globals.TILE_SIZE, y_coord)
        elseif direction=="down" and getmetatable(level_map[self.row+1][self.col])~=Border_tile then
            -- lower wall
            wall_quad = 4
            love.graphics.draw(Globals.TILE_SHEET_ENVIRONMENT.tilesetImage,
                Globals.TILE_SHEET_ENVIRONMENT:fetch_quad(wall_quad), 
                wall_coord_x, 
                wall_coord_y+Globals.WALL_OFFSET, 
                0, -- Rotation (0 for no rotation)
                Globals.TILE_SCALE_X, -- X scale factor (default to 1 if not provided)
                Globals.TILE_SCALE_Y -- Y scale factor (default to 1 if not provided)
            )

            -- love.graphics.line(x_coord, y_coord + Globals.TILE_SIZE, x_coord + Globals.TILE_SIZE, y_coord+ Globals.TILE_SIZE)
        elseif direction=="left" and not level_map[self.row][self.col-1].wall_directions:contains("right") then
            -- left wall
            wall_quad = 5
            love.graphics.draw(Globals.TILE_SHEET_ENVIRONMENT.tilesetImage,
                Globals.TILE_SHEET_ENVIRONMENT:fetch_quad(wall_quad), 
                wall_coord_x-Globals.WALL_OFFSET, 
                wall_coord_y, 0, -- Rotation (0 for no rotation)
                Globals.TILE_SCALE_X, -- X scale factor (default to 1 if not provided)
                Globals.TILE_SCALE_Y -- Y scale factor (default to 1 if not provided)
            )

            -- love.graphics.line(x_coord, y_coord, x_coord  , y_coord + Globals.TILE_SIZE)
        elseif direction=="right" and getmetatable(level_map[self.row][self.col+1])~=Border_tile then
            -- right wall
            wall_quad = 3
            love.graphics.draw(Globals.TILE_SHEET_ENVIRONMENT.tilesetImage,
                Globals.TILE_SHEET_ENVIRONMENT:fetch_quad(wall_quad), 
                wall_coord_x+Globals.WALL_OFFSET, 
                wall_coord_y, 0, -- Rotation (0 for no rotation)
                Globals.TILE_SCALE_X, -- X scale factor (default to 1 if not provided)
                Globals.TILE_SCALE_Y -- Y scale factor (default to 1 if not provided)
            )

        end
    end
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
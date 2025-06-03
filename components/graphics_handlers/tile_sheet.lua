
tile_sheet = {}
tile_sheet.__index = tile_sheet

function tile_sheet:new(tileSheetImagePath, tileWidth, tileHeight)
    instance = {}
    setmetatable(instance, tile_sheet)

    instance.tileSheetImagePath = tileSheetImagePath
    instance.tileWidth = tileWidth
    instance.tileHeight = tileHeight
    instance.tilesetImage = love.graphics.newImage(instance.tileSheetImagePath)
    instance.tilesetImage:setFilter("nearest", "nearest")

    instance.tilesetWidth = instance.tilesetImage:getWidth()
    instance.tilesetHeight = instance.tilesetImage:getHeight()
    instance.tilesetCols = math.floor(instance.tilesetWidth / tileWidth)
    instance.tilesetRows = math.floor(instance.tilesetHeight / tileHeight)

    instance.tileQuads = {}

    instance:make_quads()

    return instance

end


function tile_sheet:make_quads()
    -- Create Quads for each tile in the tileset
    for row = 0, self.tilesetRows - 1 do
        for col = 0, self.tilesetCols - 1 do
            local id = row * self.tilesetCols + col
            self.tileQuads[id] = love.graphics.newQuad(
                col * self.tileWidth,     -- x in image
                row * self.tileHeight,    -- y in image
                self.tileWidth,           -- width of quad
                self.tileHeight,          -- height of quad
                self.tilesetWidth,        -- total width of image
                self.tilesetHeight        -- total height of image
            )
        end
    end
end

function tile_sheet:fetch_quad(quad_id)
    return self.tileQuads[quad_id]
end

return tile_sheet
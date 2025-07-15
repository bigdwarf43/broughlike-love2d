
Map = require "components.map"
World_map = require "components.world_map"
Player = require "components.player"
Push = require "lib.push"
Events = require "components.events"
ShaderManager = require("components.graphics_handlers.shader_manager")


--temp
Tank_enemy =  require "components.entities.tank_enemy"

WINDOW_WIDTH, WINDOW_HEIGHT = love.window.getDesktopDimensions()
VIRTUAL_WIDTH, VIRTUAL_HEIGHT = 177, 320

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    fullscreen = false
    -- Resolution config
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        resizable = true,
        highdpi = true,
        usedpiscale = false
    })
    Push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        resizable = true,
        fullscreen = true,
        vsync = true,
        usedpiscale = false,
        upscale = "pixel-perfect",
        highdpi = true
    })

        
    math.randomseed(os.time()) -- seed the RNG

    ShaderManager:load()    


    World_map_obj = World_map:new()
    MAP_OBJECT = World_map_obj:fetchInitMap()
    local row, col = MAP_OBJECT:findRandomEmptyPosition()
    player_init_tile = MAP_OBJECT:FetchTile(row, col)
    PLAYER_ENTITY = Player:new{
        grid_row = row,
        grid_col = col,
        speed = 30,
        tile = player_init_tile
    }
    player_init_tile.entity =  PLAYER_ENTITY

    --FOR TOUCH CONTROLS
    TOUCH_BEGIN_X = nil
    TOUCH_END_X = nil
    TOUCH_BEGIN_Y = nil
    TOUCH_END_Y = nil
    DOING_TOUCH = false
    SWIPE_THRESHOLD = 30 -- swipe threshold in pixels


    -- -- temp
    -- print("TILES IN RADIUS")
    -- tiles = MAP_OBJECT:fetchRadius(10, 2, 2)
    -- for i, tile in ipairs(tiles) do
    --     print(tile.row, tile.col)
    -- end

end

function love.resize(w, h)
    Push:resize(w,h)
end

function LoadNewMap(map_room, player_row, player_col)
    -- create a new Map object
    MAP_OBJECT = map_room

    PLAYER_ENTITY.grid_row = player_row
    PLAYER_ENTITY.grid_col = player_col
    PLAYER_ENTITY:MovePlayer(0, true)

end


function love.touchpressed(id , x , y , dx , dy , pressure)
    if DOING_TOUCH == false then
        TOUCH_BEGIN_Y = y
        TOUCH_BEGIN_X = x
        DOING_TOUCH = true
    end
end

function  love.touchreleased(id , x , y , dx , dy , pressure)
    if DOING_TOUCH then
        PLAYER_ENTITY:HandleTouch(MAP_OBJECT, TOUCH_BEGIN_X, TOUCH_BEGIN_Y, x, y, SWIPE_THRESHOLD)
        DOING_TOUCH = false
    end

end

function love.keypressed(key)
    PLAYER_ENTITY:HandleKeyPressed(MAP_OBJECT, key)

    if key=="escape" then
        love.event.quit()
    end
    if key == "f11" then
		fullscreen = not fullscreen
		love.window.setFullscreen(fullscreen, "desktop")
	end
end

-- every tick is a player move
Events.tick:connect(function()
    print("MOVING ENEMIES")
    for _, monster in ipairs(MAP_OBJECT.monsters_arr) do
        monster:handleTick(MAP_OBJECT)
    end
end)



function love.update(dt)
    PLAYER_ENTITY:MovePlayer(dt)
    -- update all of the monsters
    for _, monster in ipairs(MAP_OBJECT.monsters_arr) do
        monster:update(dt)
    end
end

function love.draw()

    Push:start()

    -- ------------------------
    -- Draw Game World (centered)
    -- ------------------------
    love.graphics.push()

    local game_map_x = 0
    local game_map_y = (VIRTUAL_HEIGHT / 2) - (Globals.TILE_SIZE * 3)

    love.graphics.translate(
        game_map_x,
        game_map_y
    )

    love.graphics.print(PLAYER_ENTITY.hp)
    MAP_OBJECT:draw()
    PLAYER_ENTITY:draw()

    -- draw all of the monsters
    for _, monster in ipairs(MAP_OBJECT.monsters_arr) do
        monster:draw()
    end

    love.graphics.pop() -- back to 0,0 screen coords

    --------------------------
    -- Draw Minimap in screen space (top center)
    --------------------------

    -- Define minimap tile size and spacing explicitly
    local minimapTileSize = Globals.TILE_SIZE -- Or a scaled down version
    local tileSpacing = (Globals.TILE_SIZE * Globals.TILE_OFFSET) - minimapTileSize -- Or just Globals.TILE_OFFSET if it represents the gap directly

    -- Corrected minimapWidth and minimapHeight
    local minimapWidth = (Globals.MAP_COL * minimapTileSize) + (math.max(0, Globals.MAP_COL - 1) * tileSpacing)

    local minimapX = game_map_x
    local minimapY = 0
    local minimapBorderHeight = game_map_y - minimapY

    -- Add a small buffer if you want some space between minimap and game map
    local buffer_space = 0
    minimapBorderHeight = minimapBorderHeight - buffer_space

    -- Ensure minimapBorderHeight is not negative
    minimapBorderHeight = math.max(0, minimapBorderHeight)

    -- Minimap border
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(1.5)
    love.graphics.rectangle("line", minimapX, minimapY, minimapWidth, minimapBorderHeight)

    -- Draw actual minimap tiles inside that border

    love.graphics.push()
    love.graphics.translate(minimapX, minimapY)
    World_map_obj:drawMinimap(minimapTileSize, tileSpacing)
    love.graphics.pop()
    
    -- love.graphics.rectangle("line", 0 , 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

    Push:finish()
end

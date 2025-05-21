
Map = require "components.map"
Player = require "components.player"
Push = require "lib.push"

WINDOW_WIDTH, WINDOW_HEIGHT = love.window.getDesktopDimensions()
VIRTUAL_WIDTH, VIRTUAL_HEIGHT = 540, 960
TILE_SIZE = 32


function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- Resolution config
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT,
        { resizable = false, fullscreen = true, highdpi = true, usedpiscale = false })
    Push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT,
        { fullscreen = false, vsync = true, resizable = true, usedpiscale = false, upscale = "pixel-perfect", canvas = true, highdpi = true })

        
    math.randomseed(os.time()) -- seed the RNG
    -- Initialize map and player.
    MAP_OBJECT = Map:new{level=0}
    -- MAP_OBJECT:findRandomEmptyPosition() returns (x_col_idx, y_row_idx).
    -- So, map_x becomes column index, map_y becomes row index.
    local map_x, map_y = MAP_OBJECT:findRandomEmptyPosition() 
    -- Player:new expects options: grid_col, grid_row, act_x, act_y, speed.
    PLAYER_ENTITY = Player:new{
        grid_col = map_x,
        grid_row = map_y,
        act_x = map_x * TILE_SIZE, -- Initial act_x should match target
        act_y = map_y * TILE_SIZE, -- Initial act_y should match target
        speed = 10
    }

    --FOR TOUCH CONTROLS
    TOUCH_BEGIN_X = nil
    TOUCH_END_X = nil
    TOUCH_BEGIN_Y = nil
    TOUCH_END_Y = nil
    DOING_TOUCH = false
    SWIPE_THRESHOLD = 30 -- swipe threshold in pixels

end

function love.resize(w, h)
    Push:resize(w,h)
end

function LoadNewMap()
    -- create a new Map object
    MAP_OBJECT = Map:new{level=0}
    -- MAP_OBJECT:findRandomEmptyPosition() returns (x_col_idx, y_row_idx).
    -- So, map_x is col_idx, map_y is row_idx.
    local map_x, map_y = MAP_OBJECT:findRandomEmptyPosition()
    -- Update player's grid and pixel positions.
    PLAYER_ENTITY.grid_col = map_x
    PLAYER_ENTITY.grid_row = map_y
    PLAYER_ENTITY.target_pixel_x = map_x * TILE_SIZE
    PLAYER_ENTITY.target_pixel_y = map_y * TILE_SIZE
    -- Reset act_x and act_y to prevent visual glitch from old position
    PLAYER_ENTITY.act_x = map_x * TILE_SIZE
    PLAYER_ENTITY.act_y = map_y * TILE_SIZE
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

    if key=="r" then
        LoadNewMap()
    end
end


function love.update(dt)
    PLAYER_ENTITY:MovePlayer(dt)
end

function love.draw()

    Push:start()
        -- translate origin to approx middle
        love.graphics.translate((VIRTUAL_WIDTH/2)-(TILE_SIZE*5), (VIRTUAL_HEIGHT/2)-(TILE_SIZE*6))
        love.graphics.print(tostring(WINDOW_WIDTH).."x"..tostring(WINDOW_HEIGHT))
        love.graphics.setLineWidth(1.5)
        -- draw the Map
        MAP_OBJECT:draw()
        -- draw the player
        PLAYER_ENTITY:draw()

        -- return the origin to 0,0
        love.graphics.origin()
    Push:finish()

end
COMMON_UTILS = require "components.common_utils"


Player = {
    CanMove = true,
    MoveDelay = 0.1 ,
    --FOR TOUCH CONTROLS
    TOUCH_BEGIN_X = nil,
    TOUCH_END_X = nil,
    TOUCH_BEGIN_Y = nil,
    TOUCH_END_Y = nil,
    DOING_TOUCH = false,
    SWIPE_THRESHOLD = 30, -- swipe threshold in pixels

    JERK_OFFSET = 15, -- offset by which the player is moved on an invalid move

    grid_col = 0, -- Logical map column index
    grid_row = 0, -- Logical map row index
    target_pixel_x = 0, -- Target visual X in pixels (for lerping)
    target_pixel_y = 0, -- Target visual Y in pixels (for lerping)
    act_x = 0, -- Actual rendered X in pixels
    act_y = 0  -- Actual rendered Y in pixels
}
Player.__index = Player 

-- Creates a new player instance.
-- Expects options: grid_col (initial map column index), grid_row (initial map row index),
--                  act_x (initial pixel X), act_y (initial pixel Y), speed.
--[[required: grid_col, grid_row, act_x, act_y, speed]]
function Player:new(options)
    local instance ={}
    setmetatable(instance, self)

    instance.grid_col = options.grid_col
    instance.grid_row = options.grid_row
    instance.target_pixel_x = options.grid_col * TILE_SIZE
    instance.target_pixel_y = options.grid_row * TILE_SIZE
    instance.act_x = options.act_x -- or options.grid_col * TILE_SIZE if not passed
    instance.act_y = options.act_y -- or options.grid_row * TILE_SIZE if not passed
    instance.speed = options.speed

    return instance
end


function Player:HandleKeyPressed(mapObject, key)
    if not self.CanMove then return end

    -- directions table: dx/dy are changes in grid_col and grid_row respectively.
    local directions = {
        up    = { dx =  0, dy = -1 }, -- dy is change in grid_row
        down  = { dx =  0, dy =  1 }, -- dy is change in grid_row
        left  = { dx = -1, dy =  0 }, -- dx is change in grid_col
        right = { dx =  1, dy =  0 }  -- dx is change in grid_col
    }

    local dir = directions[key]
    if not dir then return end  -- invalid key

    local next_grid_col = self.grid_col + dir.dx
    local next_grid_row = self.grid_row + dir.dy

    -- TestMap is called with (current_grid_col, current_grid_row, change_in_col, change_in_row).
    -- Anticipating TestMap to take (current_grid_col, current_grid_row, direction_col_change, direction_row_change)
    if mapObject:TestMap(self.grid_col, self.grid_row, dir.dx, dir.dy) then
        self.grid_col = next_grid_col
        self.grid_row = next_grid_row
        self.target_pixel_x = self.grid_col * TILE_SIZE
        self.target_pixel_y = self.grid_row * TILE_SIZE
        
        self.CanMove = false
        -- Access map with map[row_idx][col_idx]
        -- Access player's current tile using [grid_row][grid_col].
        local tile = mapObject.level_map[self.grid_row][self.grid_col]
        if tile and tile.doStuff then tile.doStuff() end
        Timer = love.timer.getTime() + self.MoveDelay
    else
        -- if movement was not valid add jerk to the player position
        self.act_x = self.act_x + (dir.dx * self.JERK_OFFSET)
        self.act_y = self.act_y + (dir.dy * self.JERK_OFFSET)
    end
end


function Player:HandleTouch(mapObject, touch_begin_x, touch_begin_y, touch_end_x, touch_end_y, swipe_threshold)
    local dx = touch_end_x - touch_begin_x
    local dy = touch_end_y - touch_begin_y
    
    if math.abs(dx) > math.abs(dy) and math.abs(dx) > swipe_threshold then
        if dx > 0 then
            self:HandleKeyPressed(mapObject, "right")
        else
            self:HandleKeyPressed(mapObject, "left")

        end
    elseif math.abs(dy) > swipe_threshold then
        if dy > 0  then
            self:HandleKeyPressed(mapObject, "down")

        else
            self:HandleKeyPressed(mapObject, "up")
        end
    else
        print("NORMAL TOUCH")
    end

end


function Player:MovePlayer(dt)
    -- Check if the move delay has passed
    if not self.CanMove and love.timer.getTime() >= Timer then
        self.CanMove = true
    end

    self.act_y = COMMON_UTILS:Lerp(self.act_y, self.target_pixel_y, dt * self.speed )
    self.act_x = COMMON_UTILS:Lerp(self.act_x, self.target_pixel_x, dt * self.speed )
end


function Player:draw()
    love.graphics.rectangle("fill", self.act_x, self.act_y, TILE_SIZE, TILE_SIZE)
end

return Player
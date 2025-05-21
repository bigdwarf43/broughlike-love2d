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

    JERK_OFFSET = 15 -- offset by which the player is moved on an invalid move
}
Player.__index = Player 


--[[required: grid_x, grid_y, act_x, act_y, speed]]
function Player:new(options)
    local instance ={}
    setmetatable(instance, self)

    instance.grid_row=options.grid_row
    instance.grid_col=options.grid_col
    instance.act_x=options.grid_col * TILE_SIZE
    instance.act_y=options.grid_row * TILE_SIZE
    instance.speed=options.speed

    return instance
end


function Player:HandleKeyPressed(mapObject, key)
    if not self.CanMove then return end

    local directions = {
        up    = { dx =  0, dy = -1, act = "y" },
        down  = { dx =  0, dy =  1, act = "y" },
        left  = { dx = -1, dy =  0, act = "x" },
        right = { dx =  1, dy =  0, act = "x" }
    }

    local grid_directions = {
        up    = { dx =  -1, dy = 0, act = "y" },
        down  = { dx =  1, dy =  0, act = "y" },
        left  = { dx = 0, dy =  -1, act = "x" },
        right = { dx =  0, dy =  1, act = "x" }
    }

    local dir = directions[key]
    local grid_dir =  grid_directions[key]
    if not dir then return end  -- invalid key


    if mapObject:TestMap(self.grid_row, self.grid_col, grid_dir.dx, grid_dir.dy) then
        self.grid_row = self.grid_row + grid_dir.dx
        self.grid_col = self.grid_col + grid_dir.dy

        self.CanMove = false

        -- fetch the grid tile and trigger its effect
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

    local dest_x, dest_y = COMMON_UTILS:fetchScreenCoords(self.grid_row, self.grid_col)
    self.act_y = COMMON_UTILS:Lerp(self.act_y,dest_y, dt * self.speed )
    self.act_x = COMMON_UTILS:Lerp(self.act_x,dest_x, dt * self.speed )
end


function Player:draw()
    love.graphics.rectangle("fill", self.act_x, self.act_y, TILE_SIZE, TILE_SIZE)
end

return Player
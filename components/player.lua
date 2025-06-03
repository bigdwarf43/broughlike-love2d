COMMON_UTILS = require "components.common_utils"
Globals = require "globals"
Entity = require "components.entities.entity"
Tank_enemy = require "components.entities.tank_enemy"

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

    JERK_OFFSET = 5 -- offset by which the Entity.player is moved on an invalid move

}
setmetatable(Player, {__index = Entity})



--[[required: grid_x, grid_y, act_x, act_y, speed]]
function Player:new(options)
    local instance ={}
    setmetatable(instance, {__index = Player})

    instance.grid_row=options.grid_row
    instance.grid_col=options.grid_col
    instance.act_x=options.grid_col * Globals.TILE_SIZE
    instance.act_y=options.grid_row * Globals.TILE_SIZE
    instance.speed=options.speed

    instance.CanMove = true
    instance.MoveDelay = 0.1



    return instance
end


function Player:HandleKeyPressed(mapObject, key)
    if not self.CanMove then return end

    local directions = {
        up    = { dx = 0, dy = -1 },
        down  = { dx = 0, dy = 1 },
        left  = { dx = -1, dy = 0 },
        right = { dx = 1, dy = 0 }
    }

    local grid_directions = {
        up    = { dx = -1, dy = 0 },
        down  = { dx = 1, dy = 0 },
        left  = { dx = 0, dy = -1 },
        right = { dx = 0, dy = 1 }
    }

    local dir = directions[key]
    local grid_dir =  grid_directions[key]
    if not dir then return end  -- invalid key


    if mapObject:TestMap(self.grid_row, self.grid_col, grid_dir.dx, grid_dir.dy) then

        local old_tile = mapObject:FetchTile(self.grid_row, self.grid_col)
        local new_tile = mapObject:FetchTile(self.grid_row + grid_dir.dx, self.grid_col + grid_dir.dy)
        
        if not new_tile.entity then
            old_tile.entity = nil
            if getmetatable(new_tile)~=Exit_tile then
                new_tile.entity = self
                self.tile = new_tile
            end 
            
    
    
            self.grid_row = self.grid_row + grid_dir.dx
            self.grid_col = self.grid_col + grid_dir.dy
    
            self.CanMove = false
    
            -- fetch the grid tile and trigger its effect
            local tile = mapObject.level_map[self.grid_row][self.grid_col]
            if tile and tile.doStuff then tile:stepped_on(self) end
    
            
    
            -- add delay to the movement
            Timer = love.timer.getTime() + self.MoveDelay
            
            -- emit tick signal 
            Events.tick:emit()
        elseif getmetatable(new_tile.entity)==Tank_enemy then
            print("PlAYER ATTACK ENEMY")
        end

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


function Player:MovePlayer(dt, without_lerp)

    without_lerp = without_lerp or false
    -- Check if the move delay has passed
    if not self.CanMove and love.timer.getTime() >= Timer then
        self.CanMove = true
    end

    local dest_x, dest_y = COMMON_UTILS:fetchScreenCoords(self.grid_row, self.grid_col)

    if not without_lerp then
        self.act_y = COMMON_UTILS:Lerp(self.act_y,dest_y, dt * self.speed )
        self.act_x = COMMON_UTILS:Lerp(self.act_x,dest_x, dt * self.speed )
    else
        self.act_y = dest_y
        self.act_x = dest_x
    end


end


function Player:draw()
    -- love.graphics.rectangle("fill", self.act_x, self.act_y, Globals.TILE_SIZE, Globals.TILE_SIZE)
    love.graphics.draw(Globals.TILE_SHEET.tilesetImage, Globals.TILE_SHEET:fetch_quad(25), 
    self.act_x, 
    self.act_y, 0, Globals.TILE_SCALE_X, Globals.TILE_SCALE_Y)
    -- love.graphics.draw()
end

return Player
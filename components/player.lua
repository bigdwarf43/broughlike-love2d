local COMMON_UTILS = require "components.common_utils"
local Globals = require "globals"
local Entity = require "components.entities.entity"
local Tank_enemy = require "components.entities.tank_enemy"
local ShaderManager = require("components.graphics_handlers.shader_manager")

local Player = {
    CanMove = true,
    MoveDelay = 0.1,

    -- Touch controls
    TOUCH_BEGIN_X = nil,
    TOUCH_END_X = nil,
    TOUCH_BEGIN_Y = nil,
    TOUCH_END_Y = nil,
    DOING_TOUCH = false,
    SWIPE_THRESHOLD = 30,

    -- Movement feedback
    JERK_OFFSET = 5,

}

setmetatable(Player, { __index = Entity })
Player.__index = Player

-- Constructor
function Player:new(options)
    local instance = {}
    setmetatable(instance, Player)

    instance.grid_row = options.grid_row
    instance.grid_col = options.grid_col
    instance.act_x = options.grid_col * Globals.TILE_SIZE
    instance.act_y = options.grid_row * Globals.TILE_SIZE
    instance.speed = options.speed or 5

    instance.CanMove = true
    instance.MoveDelay = 0.1
    instance.hp = 3
    instance.tile = options.tile



    return instance
end

-- Movement input handler
function Player:HandleKeyPressed(mapObject, key)
    if not self.CanMove then return end

    local screen_dirs = {
        up    = { dx = 0, dy = -1 },
        down  = { dx = 0, dy = 1 },
        left  = { dx = -1, dy = 0 },
        right = { dx = 1, dy = 0 }
    }

    local grid_dirs = {
        up    = { dx = -1, dy = 0 },
        down  = { dx = 1, dy = 0 },
        left  = { dx = 0, dy = -1 },
        right = { dx = 0, dy = 1 }
    }

    local dir = screen_dirs[key]
    local grid_dir = grid_dirs[key]
    if not dir then return end

    if mapObject:TestMap(self.grid_row, self.grid_col, grid_dir.dx, grid_dir.dy) then
        local old_tile = mapObject:FetchTile(self.grid_row, self.grid_col)
        local new_tile = mapObject:FetchTile(self.grid_row + grid_dir.dx, self.grid_col + grid_dir.dy)

        if not new_tile.entity then
            old_tile.entity = nil

            if getmetatable(new_tile) ~= Exit_tile then
                new_tile.entity = self
                self.tile = new_tile
            end

            self.grid_row = self.grid_row + grid_dir.dx
            self.grid_col = self.grid_col + grid_dir.dy
            self.CanMove = false

            local tile = mapObject.level_map[self.grid_row][self.grid_col]
            if tile and tile.doStuff then
                tile:stepped_on(self)
            end

            Timer = love.timer.getTime() + self.MoveDelay
            Events.tick:emit()

        elseif getmetatable(new_tile.entity) == Tank_enemy then
            self.act_x = self.act_x + (dir.dx * self.JERK_OFFSET)
            self.act_y = self.act_y + (dir.dy * self.JERK_OFFSET)
            new_tile.entity:takeDamage(1)


            Events.tick:emit()
            
            print("PLAYER ATTACKED ENEMY")
        end
    else
        self.act_x = self.act_x + (dir.dx * self.JERK_OFFSET)
        self.act_y = self.act_y + (dir.dy * self.JERK_OFFSET)
    end
end

-- Touch input handler
function Player:HandleTouch(mapObject, touch_begin_x, touch_begin_y, touch_end_x, touch_end_y, swipe_threshold)
    local dx = touch_end_x - touch_begin_x
    local dy = touch_end_y - touch_begin_y
    swipe_threshold = swipe_threshold or self.SWIPE_THRESHOLD

    if math.abs(dx) > math.abs(dy) and math.abs(dx) > swipe_threshold then
        self:HandleKeyPressed(mapObject, dx > 0 and "right" or "left")
    elseif math.abs(dy) > swipe_threshold then
        self:HandleKeyPressed(mapObject, dy > 0 and "down" or "up")
    else
        print("NORMAL TOUCH")
    end
end

-- Movement logic (smooth or instant)
function Player:MovePlayer(dt, without_lerp)
    if not self.CanMove and love.timer.getTime() >= Timer then
        self.CanMove = true
    end

    local dest_x, dest_y = COMMON_UTILS:fetchScreenCoords(self.grid_row, self.grid_col)

    if without_lerp then
        self.act_x = dest_x
        self.act_y = dest_y
    else
        self.act_x = COMMON_UTILS:Lerp(self.act_x, dest_x, dt * self.speed)
        self.act_y = COMMON_UTILS:Lerp(self.act_y, dest_y, dt * self.speed)
    end
end

-- Damage handler
function Player:takeDamage(damage)
    self.hp = self.hp - damage
end

-- Grid position accessor
function Player:fetchCurrentGridPosition()
    return self.grid_row, self.grid_col
end

-- Render function
function Player:draw()
    ShaderManager:setShader("grayscale")
    love.graphics.draw(
        Globals.TILE_SHEET_CHARACTER.tilesetImage,
        Globals.TILE_SHEET_CHARACTER:fetch_quad(97),
        self.act_x,
        self.act_y,
        0,
        Globals.TILE_SCALE_X,
        Globals.TILE_SCALE_Y
    )
    ShaderManager:reset()

end

return Player

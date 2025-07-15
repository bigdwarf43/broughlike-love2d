Entity = require "components.entities.entity"
COMMON_UTILS = require "components.common_utils"
Globals = require "globals"
Tank_enemy = {
    hp = 4
}
Tank_enemy.__index = Tank_enemy
setmetatable(Tank_enemy, {__index = Entity})

function Tank_enemy:new(grid_row, grid_col, tile)
    local instance ={}
    setmetatable(instance, Tank_enemy)
    instance.grid_row=grid_row
    instance.grid_col=grid_col

    local x_coord, y_coord = COMMON_UTILS:fetchScreenCoords(grid_row, grid_col)
    instance.act_x=x_coord
    instance.act_y=y_coord
    instance.tile = tile

    instance.dead = false
    return instance
end

function Tank_enemy:handleTick(mapObject)
    
    if self.hp <=0 then
        print("ENEMY DEAD")
        self:die()
        mapObject:RemoveEnemy(self)  
        return
    end

    -- NEED TO IMPLEMET A STAR HERE, THE ENEMIES ARE STUCK 
    -- WHEN THE PLAYER IS BEHIND A WALL
    
    local directions = {"up","down","left","right"}
    -- loop all the tiles in a radius
    in_radius_tiles = mapObject:fetchRadius(self.tile.row, self.tile.col, 2)

    -- check if any of them has the player
    player_found_in_radius = false
    player_tile =  null

    for i, tile in ipairs(in_radius_tiles) do
        if getmetatable(tile.entity) == Player then
            player_found_in_radius = true
            print("PLAYER FOUND IN RADIUS")
            player_tile =  tile
            break
        end
    end

    if player_found_in_radius==true then
        direction_name = COMMON_UTILS:get_cardinal_direction(self.tile, player_tile)
        print("MOVING in "..direction_name)
    else
        print("MOVING in RND DIR")
        -- Step 1: Pick a random index from the list of keys
        local randomIndex = love.math.random(#directions)
        -- Step 3: Use the random index to get the direction name
        direction_name = directions[randomIndex]
    end
                    
    -- try moving towards that tile
    local grid_dir =  Globals.GRID_DIRECTIONS_MAP[direction_name]

    if mapObject:inPlayableBounds(self.grid_row + grid_dir.row, self.grid_col + grid_dir.col) then
        
    
        local is_move_valid = mapObject:TestMap(self.grid_row, self.grid_col, grid_dir.row, grid_dir.col)

        if is_move_valid then
            -- add tile to the entity
            local old_tile = mapObject:FetchTile(self.grid_row, self.grid_col)
            local new_tile = mapObject:FetchTile(self.grid_row + grid_dir.row, self.grid_col + grid_dir.col)
            
            if not new_tile.entity then
                old_tile.entity = nil
                new_tile.entity = self

                self.tile = new_tile

                self.grid_row = self.grid_row + grid_dir.row
                self.grid_col = self.grid_col + grid_dir.col
            elseif getmetatable(new_tile.entity)==Player then
                self.act_x = self.act_x + (grid_dir.col * self.JERK_OFFSET)
                self.act_y = self.act_y + (grid_dir.row * self.JERK_OFFSET)
                new_tile.entity:takeDamage(1)
            end
        end

    end


    -- jerk motion
    -- else
    --     -- if movement was not valid add jerk to the enemy position
    --     self.act_x = self.act_x + (dir.dx * self.JERK_OFFSET)
    --     self.act_y = self.act_y + (dir.dy * self.JERK_OFFSET)
    -- end
end

function Tank_enemy:die()
    print("INSIDE ENEMY DIED")
    if self.tile~=null then
        self.tile.entity = null
    end
    self.dead = true
end

function Tank_enemy:draw()
    -- love.graphics.setColor(1, 0, 0, 1)
    -- love.graphics.rectangle("fill", self.act_x, self.act_y, Globals.TILE_SIZE, Globals.TILE_SIZE)
    -- love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(Globals.TILE_SHEET_CHARACTER.tilesetImage, 
    Globals.TILE_SHEET_CHARACTER:fetch_quad(110), 
    self.act_x,
    self.act_y,
    0,
    Globals.TILE_SCALE_X,
    Globals.TILE_SCALE_Y
    )

end

return Tank_enemy
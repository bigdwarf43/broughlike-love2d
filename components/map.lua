-- = require "components.tile"
Border_tile = require "components.tiles.border_tile"
Floor_tile = require "components.tiles.floor_tile"
Exit_tile = require "components.tiles.exit_tile"
Globals = require "globals"

--enemies
Tank_enemy = require "components.entities.tank_enemy"

Map ={}
Map.__index = Map


function Map:printMap()
    for x=1, #self.level_map do
        local tmp = {}
		for y=1, #self.level_map[x] do
            table.insert(tmp , tostring(x)..","..tostring(y))
        end
        print(table.concat(tmp, " "))
    end
end

-- required: level
function Map:new(options)

    local instance = {}
    setmetatable(instance, Map)

    -- Initialize the instance with the provided level
    instance.level = options.level
    instance.width = Globals.MAP_COL
    instance.height = Globals.MAP_ROW
    instance.exit_dirs = options.exit_dirs
    instance.room_world_row = options.room_world_row -- coords of room on world map
    instance.room_world_col = options.room_world_col -- coords of room on world map

    instance.level_map = instance:generateRandomMap(0.5)
    instance.revealed = false -- whether the room is explored, should it be shown on minimap

    instance.monsters_arr = {}
    instance.num_of_enemies = 2


    print("INITIATED MAP")
    print(instance.level, table.concat(instance.exit_dirs, ", "))
    -- Return the newly created instance
    return instance
end


function Map:addWallInCorrespondingTile(tile, direction)
    local opposite_dir ={
        up=  "down",
        down= "up",
        left= "right",
        right= "left"
    }
    tile.wall_directions:add(opposite_dir[direction])
end

function Map:generateRandomMap(wallProbability)
    -- Input validation
    wallProbability = wallProbability or 0.3
    
    -- Ensure probabilities are within range
    wallProbability = math.max(0, math.min(1, wallProbability))

    local function buildMap()

        -- Create the Map
        local level_map = {}

        -- First, create the entire level_map filled with floors (0)
        for row = 1, self.height do
            level_map[row] = {}
            for col = 1, self.width do
                level_map[row][col] = Floor_tile:new(row,col,{})
            end
        end

        -- Randomly place walls inside the level_map (excluding the border)
        local directions = {"up", "down", "left", "right"}
        for row = 2, self.height-2 do
            for col = 2, self.width-2 do
                if math.random() < wallProbability then
                    local random_dir = directions[math.random(#directions)]
                    level_map[row][col].wall_directions:add(random_dir)
                    
                end
            end
        end

        -- Add border walls (1) around the entire level_map
        for row = 1, self.height do
            level_map[row][1] = Border_tile:new(row, 1)
            level_map[row][self.width] = Border_tile:new(row, self.width)

        end
        
        for col = 1, self.width do
            level_map[1][col] = Border_tile:new(1, col)
            level_map[self.height][col] = Border_tile:new(self.height, col)

            
        end

        -- place exits on the map
        print("EXIT ARR")
        print(table.concat(self.exit_dirs, ", "))
        for _, exit in ipairs(self.exit_dirs) do
            local exit_row, exit_col = self:getExitCoords(exit)
            level_map[exit_row][exit_col] = Exit_tile:new(exit_row, exit_col, self.room_world_row, self.room_world_col, exit)
        end


        local grid_directions = {
            up    = { row =  -1, col = 0},
            down  = { row =  1, col =  0},
            left  = { row = 0, col =  -1},
            right = { row =  0, col =  1}
        }

        for row = 1, self.height do
            for col = 1, self.width do
                if getmetatable(level_map[row][col]) ~= Exit_tile or Border_tile then
                    for idx, dir in ipairs(level_map[row][col].wall_directions:elements()) do
                        local direction_obj =grid_directions[dir]
                        
                        if self:inBounds(row+direction_obj.row, col+direction_obj.col) then
                            local corresponding_tile = level_map[row+direction_obj.row][col+direction_obj.col]
                            if getmetatable(corresponding_tile) ~= Exit_tile then
                                self:addWallInCorrespondingTile(corresponding_tile, dir)
                            else
                                -- if the corresponding tile is exit then do not block it
                                level_map[row][col].wall_directions:remove(dir)
                            end
                        end
                        
                        
                    end
                end
                
            end
        end


        
        return level_map
    end
    
    local level_map =  buildMap()

    return level_map
end

function Map:findRandomEmptyPosition(level_map)

    level_map = level_map or self.level_map
    local zeroPositions = {}
    for row = 2, #level_map do
        for col = 2, #level_map[row] do
            local tile = level_map[row][col] 
            if tile.passable == true and tile.entity==nil and getmetatable(tile)~=Exit_tile then
                table.insert(zeroPositions, {row = row, col = col})
            end
        end
    end

    local player_pos = zeroPositions[math.random(#zeroPositions)]
    return player_pos.row, player_pos.col
end

function Map:getExitCoords(exit_dir)
    local exit_arr = {
        left = { row = math.floor(self.width / 2) + 1, col = 1 },                               -- left border
        up = { row = 1, col = math.floor(self.height / 2) + 1 },                                -- upper border
        down = { row = self.height, col = math.floor(self.height / 2) + 1 },                    -- lower border
        right = { row = math.floor(self.width / 2) + 1, col = self.height }                     --right border
    }
    print("PLACING EXIT ON ")
    print(exit_dir)
    local exit_pos = exit_arr[exit_dir]
    return exit_pos.row, exit_pos.col
end


function Map:inBounds(row, col)
    -- 1 is filled with border and also width column and height row
    if 0 < row and row <= self.height and 0 < col and col <= self.width then
        return true
    end
    return false
end

function Map:inPlayableBounds(row, col)
    -- 1 is filled with border and also width column and height row
    if 1 < row and row < self.height and 1 < col and col < self.width then
        return true
    end
    return false
end

function Map:fetchPLayerPositionFromExit(exit_dir)
    -- fetches position where the player should be placed depending upon the direction of the exit 
    -- that the player took in the last room
    local exit_arr = {
        left =  { row = math.floor(self.width / 2) + 1, col = self.height-1 }  ,                               -- left border
        up = { row = self.height-1, col = math.floor(self.height / 2) + 1 },                                -- upper border
        down = { row = 2, col = math.floor(self.height / 2) + 1 } ,                    -- lower border
        right = { row = math.floor(self.width / 2) + 1, col = 2 }                    --right border
    }

    local exit_loc = exit_arr[exit_dir]
    return exit_loc.row, exit_loc.col
end


function Map:TestMap(current_row, current_col, dir_row, dir_col)
    -- check bounds of the map
    if self:inBounds(current_row + dir_row, current_col + dir_col) then
        -- check if the tile on the grid is passable
        local tile = self.level_map[current_row][current_col]
        return tile:isMoveAllowed(dir_row, dir_col)
    end

    return false
end

function Map:FetchTile(row, col)
    return self.level_map[row][col]
end


function Map:fetchRadius(start_row, start_col, radius)
    local tiles_in_radius = {} -- Table to store the tiles found within the radius

    -- Iterate through rows within the radius
    for r = start_row - radius, start_row + radius do
        -- Iterate through columns within the radius
        for c = start_col - radius, start_col + radius do
            -- Check if the current (r, c) coordinates are within the map bounds
            if self:inPlayableBounds(r, c) then
                -- Check if the tile is within the actual square radius.
                -- For a circular radius, you would calculate Euclidean distance:
                -- local dist = math.sqrt((r - start_row)^2 + (c - start_col)^2)
                -- if dist <= radius then ... end
                -- For this example, we're using a square area defined by the radius.
                
                -- Fetch the tile using the existing FetchTile function
                local tile = self:FetchTile(r, c)
                
                -- Add the fetched tile to our results table
                table.insert(tiles_in_radius, tile)
            end
        end
    end

    return tiles_in_radius -- Return the table of tiles
end

function Map:GenerateMonsters()
    for _ = 1, self.num_of_enemies do
        local row, col = self:findRandomEmptyPosition()

        local tile = self:FetchTile(row, col)
        local enemy = Tank_enemy:new(row, col, tile)
        
        -- set the enemy on tile
        self.level_map[row][col].entity = enemy

        table.insert(self.monsters_arr, enemy)
    end
end

function Map:RemoveEnemy(monster)
    print('INSDIDE REMOVE ENEMY') 
    print(monster)
    local foundIndex = -1
    for i, m in ipairs(self.monsters_arr) do
        if m == monster then -- Compare by reference (checks if it's the exact same object)
            foundIndex = i
            break
        end
    end

    if foundIndex ~= -1 then
        table.remove(self.monsters_arr, foundIndex)
        print("Monster removed successfully from index:", foundIndex)
    else
        print("Error: Monster not found in the array.")
    end
end



function Map:draw()
    -- self:printMap()
    for row=1, #self.level_map do
		for col=1, #self.level_map[row] do
            self.level_map[row][col]:draw(self.level_map)
		end
	end
    for row=1, #self.level_map do
		for col=1, #self.level_map[row] do
            if getmetatable(self.level_map[row][col]) == Floor_tile then
                self.level_map[row][col]:draw_walls(self.level_map)
                
            end
		end
	end
end

return Map
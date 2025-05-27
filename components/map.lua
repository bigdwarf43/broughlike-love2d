Tile = require "components.tile"
Globals = require "globals"

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
                level_map[row][col] = Tile.Floor_tile:new(row,col,{})
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
            level_map[row][1] = Tile.Border_tile:new(row, 1)
            level_map[row][self.width] = Tile.Border_tile:new(row, self.width)

        end
        
        for col = 1, self.width do
            level_map[1][col] = Tile.Border_tile:new(1, col)
            level_map[self.height][col] = Tile.Border_tile:new(self.height, col)

            
        end

        -- place exits on the map
        print("EXIT ARR")
        print(table.concat(self.exit_dirs, ", "))
        for _, exit in ipairs(self.exit_dirs) do
            local exit_row, exit_col = self:getExitCoords(exit)
            level_map[exit_row][exit_col] = Tile.Exit_tile:new(exit_row, exit_col, self.room_world_row, self.room_world_col, exit)
        end


        local grid_directions = {
            up    = { row =  -1, col = 0},
            down  = { row =  1, col =  0},
            left  = { row = 0, col =  -1},
            right = { row =  0, col =  1}
        }

        for row = 1, self.height do
            for col = 1, self.width do
                if getmetatable(level_map[row][col]) ~= Tile.Exit_tile or Tile.Border_tile then
                    for idx, dir in ipairs(level_map[row][col].wall_directions:elements()) do
                        local direction_obj =grid_directions[dir]
                        
                        if self:inBounds(row+direction_obj.row, col+direction_obj.col) then
                            local corresponding_tile = level_map[row+direction_obj.row][col+direction_obj.col]
                            if getmetatable(corresponding_tile) ~= Tile.Exit_tile then
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
            if level_map[row][col].passable == true then
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

    print("INITIATED MAP")
    print(instance.level, table.concat(instance.exit_dirs, ", "))
    -- Return the newly created instance
    return instance
end

function Map:inBounds(row, col)
    -- 1 is filled with border and also width column and height row
    if 0 < row and row <= self.height and 0 < col and col <= self.width then
        return true
    end
    return false
end

function Map:fetchPLayerPositionFromExit(exit_dir)
    local exit_arr = {
        left =  { row = math.floor(self.width / 2) + 1, col = self.height-1 }  ,                               -- left border
        up = { row = self.height-1, col = math.floor(self.height / 2) + 1 },                                -- upper border
        down = { row = 2, col = math.floor(self.height / 2) + 1 } ,                    -- lower border
        right = { row = math.floor(self.width / 2) + 1, col = 2 }                    --right border
    }

    local exit_loc = exit_arr[exit_dir]
    return exit_loc.row, exit_loc.col
end


function Map:TestMap(player_current_grid_x, player_current_grid_y, dir_row, dir_col)
    -- check bounds of the map
    if self:inBounds(player_current_grid_x + dir_row, player_current_grid_y + dir_col) then
        -- check if the tile on the grid is passable
        local tile = self.level_map[player_current_grid_x][player_current_grid_y]
        return tile:isMoveAllowed(dir_row, dir_col)
    end

    return false
end

function Map:draw()
    -- self:printMap()
    for row=1, #self.level_map do
		for col=1, #self.level_map[row] do
            self.level_map[row][col]:draw(self.level_map)
		end
	end
end

return Map
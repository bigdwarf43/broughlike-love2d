Tile = require "components.tile"

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
    if getmetatable(tile) ~= Tile.Exit_tile then
        local opposite_dir ={
            up=  "down",
            down= "up",
            left= "right",
            right= "left"
        }
        tile.wall_directions:add(opposite_dir[direction])
    end

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
                    -- level_map[row][col] = Tile.Floor_tile:new(row, col, {random_dir})    -- Place a wallrandom_dir
                    -- local abs_dir = {x = random_dir.x*-1, y=random_dir.y*-1}
                    -- level_map[random_dir.y+y][random_dir.x+x].wall_directions:add(abs_dir)  
                    -- table.insert(level_map[random_dir.y+y][random_dir.x+x].wall_directions,  abs_dir)  -- Place a wallrandom_dir
                    
                end
            end
        end

        -- Add border walls (1) around the entire level_map
        for row = 1, self.height do
            -- level_map[y][1] = Tile.Floor_tile:new(1, y, {{x = 0, y = 1},{x = 0, y = -1},{x = 1, y = 0},{x = -1, y = 0}})      -- Left border
            -- level_map[y][self.width] = Tile.Floor_tile:new(self.width, y, {{x = 0, y = 1},{x = 0, y = -1},{x = 1, y = 0},{x = -1, y = 0}})    -- Right border
            level_map[row][1] = Tile.Border_tile:new(row, 1)
            level_map[row][self.width] = Tile.Border_tile:new(row, self.width)

        end
        
        for col = 1, self.width do
            -- level_map[1][x] = Tile.Floor_tile:new(x, 1, {{x = 0, y = 1},{x = 0, y = -1},{x = 1, y = 0},{x = -1, y = 0}})  -- Top border
            -- level_map[self.height][x] = Tile.Floor_tile:new(x, self.height, {{x = 0, y = 1},{x = 0, y = -1},{x = 1, y = 0},{x = -1, y = 0}})   -- Bottom border
            level_map[1][col] = Tile.Border_tile:new(1, col)
            level_map[self.height][col] = Tile.Border_tile:new(self.height, col)

            
        end

        -- -- place one exit on the map
        -- local exit_x, exit_y = self:getExitCoords()
        -- level_map[exit_y][exit_x] = Tile.Exit_tile:new(exit_x, exit_y)

        local grid_directions = {
            up    = { row =  -1, col = 0},
            down  = { row =  1, col =  0},
            left  = { row = 0, col =  -1},
            right = { row =  0, col =  1}
        }

        for row = 2, self.height-2 do
            for col = 2, self.width-2 do
                if getmetatable(level_map[row][col]) ~= Tile.Exit_tile or Tile.Border_tile then
                    for idx, dir in ipairs(level_map[row][col].wall_directions:elements()) do
                        local direction_obj =grid_directions[dir]
                        
                        if self:inBounds(row+direction_obj.row, col+direction_obj.col) then
                            local corresponding_tile = level_map[row+direction_obj.row][col+direction_obj.col]
                            self:addWallInCorrespondingTile(corresponding_tile, dir)
                        end
                        
                        
                    end
                end
                
            end
        end

        -- self:removeExitBlocks(exit_y,exit_x, level_map)

        
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

function Map:getExitCoords()
    local exit_arr = {
        { x = math.floor(self.width / 2) + 1,   y = 1 }, -- upper border
        { x = 1,                                y = math.floor(self.height / 2) + 1 }, -- left border
        { x = self.height,  y = math.floor(self.height / 2) + 1 }, -- right border
        { x = math.floor(self.width / 2) + 1,  y = self.height }
    }
    local exit_pos = exit_arr[math.random(#exit_arr)]
    return exit_pos.y, exit_pos.x
end

function Map:neighbours(tile, level_map)
    level_map =  level_map or self.level_map
    local dirs = { {x=0,y=1}, {x=0,y=-1}, {x=1,y=0}, {x=-1,y=0} }

    local neighbour_list = {}
    for _, dir in ipairs(dirs) do
        local nx = tile.x + dir.x
        local ny = tile.y + dir.y
        -- check bounds
        if ny > 0 and ny <= self.height and nx > 0 and nx <= self.width then
            local neighbor_tile = level_map[ny][nx]
            if neighbor_tile.passable == true then
                table.insert(neighbour_list, {x=nx, y=ny})
            end
        end
    end

    return neighbour_list 
end

function Map:removeExitBlocks(exit_x, exit_y, level_map)
    level_map = level_map or self.level_map
    
    -- Remember: From getExitCoords, exit_y is the column (x) and exit_x is the row (y)
    -- Let's rename these for clarity
    local exit_row = exit_x
    local exit_col = exit_y
    
    -- Determine which border the exit is on and its facing direction
    local facing_direction = {x = 0, y = 0}
    
    -- Debug output
    print("Exit position: row=" .. exit_row .. ", col=" .. exit_col)
    print("Map dimensions: width=" .. self.width .. ", height=" .. self.height)
    
    -- Exit is on top row (row 1)
    if exit_row == 1 then
        facing_direction.y = 1  -- Facing down into the map
    -- Exit is on bottom row
    elseif exit_row == self.height then
        facing_direction.y = -1  -- Facing up into the map
    -- Exit is on leftmost column
    elseif exit_col == 1 then
        facing_direction.x = 1  -- Facing right into the map
    -- Exit is on rightmost column
    elseif exit_col == self.width then
        facing_direction.x = -1  -- Facing left into the map
    end
    
    print("Exit facing direction: x=" .. facing_direction.x .. ", y=" .. facing_direction.y)
    
    -- Calculate the position of the tile in front of the exit
    local front_row = exit_row + facing_direction.y
    local front_col = exit_col + facing_direction.x
    
    print("Tile in front: row=" .. front_row .. ", col=" .. front_col)
    
    -- Safety check to make sure the front tile is within bounds
    if front_row <= 0 or front_row > self.height or
       front_col <= 0 or front_col > self.width then
        print("WARNING: Tile in front of exit is out of bounds!")
        return
    end
    
    -- Get the tile in front of the exit
    local front_tile = level_map[front_row][front_col]
    
    -- The wall to remove is in the opposite direction of facing_direction
    local wall_to_remove = {x = -facing_direction.x, y = -facing_direction.y}
    print("Wall to remove: x=" .. wall_to_remove.x .. ", y=" .. wall_to_remove.y)
    
    -- Remove the wall
    front_tile.wall_directions:remove(wall_to_remove)
    
    -- Also make sure the exit tile itself doesn't have walls
    -- (this is optional but might help ensure the exit is passable)
    level_map[exit_row][exit_col].wall_directions = {}
    
    -- Update the map
    level_map[front_row][front_col] = front_tile
    
    -- Debug output
    print("Walls in front tile after removal:")
    for _, dir in ipairs(front_tile.wall_directions:elements()) do
        print("  x=" .. dir.x .. ", y=" .. dir.y)
    end
end

-- required: level
function Map:new(options)

    local instance = {}
    setmetatable(instance, Map)

    -- Initialize the instance with the provided level
    instance.level = options.level
    instance.width = 11
    instance.height = 11

    instance.level_map = instance:generateRandomMap(0.3)


    -- Return the newly created instance
    return instance
end

function Map:inBounds(row, col)
    -- 1 is filled with border and also width column and height row
    if 1 < row and row < self.height and 1 < col and col < self.width then
        return true
    end
    return false
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
            self.level_map[row][col]:draw()
		end
	end
end

return Map
Tile = require "components.tile"

Map ={}
Map.__index = Map

-- Prints map grid coordinates to console. Output format: x_col,y_row.
-- Note: self.level_map is indexed [y_row_idx][x_col_idx].
function Map:printMap()
    for y_row = 1, #self.level_map do
        local tmp = {}
        for x_col = 1, #self.level_map[y_row] do
            table.insert(tmp , tostring(x_col)..","..tostring(y_row))
        end
        print(table.concat(tmp, " "))
    end
end

function Map:addWallInCorrespondingTile(tile, direction)
    if getmetatable(tile) ~= Tile.Exit_tile then
        local opposite_dir = {x = direction.x*-1, y=direction.y*-1}
        tile.wall_directions:add(opposite_dir)
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
        -- Map is indexed [y_row_idx][x_col_idx]
        for y = 1, self.height do -- y is y_row_idx
            level_map[y] = {}
            for x = 1, self.width do -- x is x_col_idx
                -- Tile.Floor_tile:new expects (col_idx, row_idx) for its x, y parameters, consistent with loop variables here.
                level_map[y][x] = Tile.Floor_tile:new(x,y,{})
            end
        end

        -- Randomly place walls inside the level_map (excluding the border)
        local directions = {{x = 0, y = 1},{x = 0, y = -1},{x = 1, y = 0},{x = -1, y = 0}}
        for y = 2, self.height-2 do
            for x = 2, self.width-2 do
                if math.random() < wallProbability then
                    local random_dir = directions[math.random(#directions)]
                    level_map[y][x] = Tile.Floor_tile:new(x, y, {random_dir})    -- Place a wallrandom_dir
                    -- local abs_dir = {x = random_dir.x*-1, y=random_dir.y*-1}
                    -- level_map[random_dir.y+y][random_dir.x+x].wall_directions:add(abs_dir)  
                    -- table.insert(level_map[random_dir.y+y][random_dir.x+x].wall_directions,  abs_dir)  -- Place a wallrandom_dir
                    
                end
            end
        end

        -- Add border walls (1) around the entire level_map
        for y = 1, self.height do
            level_map[y][1] = Tile.Floor_tile:new(1, y, {{x = 0, y = 1},{x = 0, y = -1},{x = 1, y = 0},{x = -1, y = 0}})      -- Left border
            -- table.insert(level_map[y][1+1].wall_directions,  {x = -1, y = 0})  -- Place a wallrandom_dir
            -- level_map[y][1+1].wall_directions:add({x = -1, y = 0})
            
            level_map[y][self.width] = Tile.Floor_tile:new(self.width, y, {{x = 0, y = 1},{x = 0, y = -1},{x = 1, y = 0},{x = -1, y = 0}})    -- Right border
            -- table.insert(level_map[y][self.width-1].wall_directions,  {x = 1, y = 0})  -- Place a wallrandom_dir
            -- level_map[y][self.width-1].wall_directions:add({x = 1, y = 0})
            
        end
        
        for x = 1, self.width do
            level_map[1][x] = Tile.Floor_tile:new(x, 1, {{x = 0, y = 1},{x = 0, y = -1},{x = 1, y = 0},{x = -1, y = 0}})  -- Top border
            -- table.insert(level_map[2][x].wall_directions,  {x = 0, y = -1})  -- Place a wallrandom_dir
            -- level_map[2][x].wall_directions:add({x = 0, y = -1})

            
            level_map[self.height][x] = Tile.Floor_tile:new(x, self.height, {{x = 0, y = 1},{x = 0, y = -1},{x = 1, y = 0},{x = -1, y = 0}})   -- Bottom border
            -- table.insert(level_map[self.height-1][x].wall_directions, {x = 0, y = 1})  -- Place a wallrandom_dir
            -- level_map[self.height-1][x].wall_directions:add({x = 0, y = 1})

        end

        -- place one exit on the map
        -- getExitCoords returns (x_col_idx, y_row_idx), so exit_x is col_idx, exit_y is row_idx.
        local exit_x, exit_y = self:getExitCoords()
        -- level_map access is [row_idx][col_idx]; Tile.Exit_tile:new expects (col_idx, row_idx).
        level_map[exit_y][exit_x] = Tile.Exit_tile:new(exit_x, exit_y)


        for y = 1, self.height do
            for x = 1, self.width do

                if getmetatable(level_map[y][x]) ~= Tile.Exit_tile then
                    for idx, dir in ipairs(level_map[y][x].wall_directions:elements()) do
                        if self:inBounds(x+dir.x, y+dir.y) then
                            local corresponding_tile = level_map[y+dir.y][x+dir.x]
                            self:addWallInCorrespondingTile(corresponding_tile, dir)
                        end
                    end
                end
                
            end
        end

        self:removeExitBlocks(exit_x, exit_y, level_map)
        -- removeExitBlocks expects (x_col_idx, y_row_idx) parameters.

        
        return level_map
    end
    
    local level_map =  buildMap()

    return level_map
end

function Map:findRandomEmptyPosition(level_map)

    level_map = level_map or self.level_map
    local zeroPositions = {}
    -- Iterate through rows (y_row_idx) then columns (x_col_idx)
    for y_row = 1, self.height do
        for x_col = 1, self.width do
            -- Access map with level_map[y_row_idx][x_col_idx]
            -- Ensure the row exists before trying to access a column in it
            if level_map[y_row] and level_map[y_row][x_col] and level_map[y_row][x_col].passable == true then
                table.insert(zeroPositions, {x = x_col, y = y_row})
            end
        end
    end

    if #zeroPositions == 0 then
        -- Handle the case where no empty positions are found, though this shouldn't happen in a valid map
        print("WARNING: No empty positions found in Map:findRandomEmptyPosition")
        return nil, nil 
    end

    local found_pos = zeroPositions[math.random(#zeroPositions)]
    -- Return as (x_col_idx, y_row_idx)
    return found_pos.x, found_pos.y
end

function Map:getExitCoords()
    -- local col, row = self:findRandomEmptyPosition()
    local exit_arr = {
        { x = math.floor(self.width / 2) + 1,   y = 1 }, -- upper border: (x_col_idx, y_row_idx=1)
        { x = 1,                                y = math.floor(self.height / 2) + 1 }, -- left border: (x_col_idx=1, y_row_idx)
        { x = self.width,                       y = math.floor(self.height / 2) + 1 }, -- right border: (x_col_idx=self.width, y_row_idx)
        { x = math.floor(self.width / 2) + 1,   y = self.height } -- bottom border: (x_col_idx, y_row_idx=self.height)
    }
    local exit_pos = exit_arr[math.random(#exit_arr)]
    -- Return as (x_col_idx, y_row_idx)
    return exit_pos.x, exit_pos.y
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

-- Parameters are: exit_x_param (column index), exit_y_param (row index)
function Map:removeExitBlocks(exit_x_param, exit_y_param, level_map)
    level_map = level_map or self.level_map
    
    -- exit_x_param is x_col_idx (column index)
    -- exit_y_param is y_row_idx (row index)
    
    -- Determine which border the exit is on and its facing direction
    local facing_direction = {x = 0, y = 0}
    
    -- Debug output
    print("Exit position: col=" .. exit_x_param .. ", row=" .. exit_y_param)
    print("Map dimensions: width=" .. self.width .. ", height=" .. self.height)
    
    -- Exit is on top row (y_row_idx = 1)
    if exit_y_param == 1 then
        facing_direction.y = 1  -- Facing down into the map (increasing y_row_idx)
    -- Exit is on bottom row (y_row_idx = self.height)
    elseif exit_y_param == self.height then
        facing_direction.y = -1  -- Facing up into the map (decreasing y_row_idx)
    -- Exit is on leftmost column (x_col_idx = 1)
    elseif exit_x_param == 1 then
        facing_direction.x = 1  -- Facing right into the map (increasing x_col_idx)
    -- Exit is on rightmost column (x_col_idx = self.width)
    elseif exit_x_param == self.width then
        facing_direction.x = -1  -- Facing left into the map (decreasing x_col_idx)
    end
    
    print("Exit facing direction: x=" .. facing_direction.x .. ", y=" .. facing_direction.y)
    
    -- Calculate the position of the tile in front of the exit
    local front_row = exit_y_param + facing_direction.y
    local front_col = exit_x_param + facing_direction.x
    
    print("Tile in front: row=" .. front_row .. ", col=" .. front_col)
    
    -- Safety check to make sure the front tile is within bounds
    if front_row <= 0 or front_row > self.height or
       front_col <= 0 or front_col > self.width then
        print("WARNING: Tile in front of exit is out of bounds!")
        return
    end
    
    -- Get the tile in front of the exit: level_map[y_row_idx][x_col_idx]
    local front_tile = level_map[front_row][front_col]
    
    -- The wall to remove is in the opposite direction of facing_direction
    local wall_to_remove = {x = -facing_direction.x, y = -facing_direction.y}
    print("Wall to remove: x=" .. wall_to_remove.x .. ", y=" .. wall_to_remove.y)
    
    -- Remove the wall
    front_tile.wall_directions:remove(wall_to_remove)
    
    -- Also make sure the exit tile itself doesn't have walls
    -- (this is optional but might help ensure the exit is passable)
    -- Access map with level_map[y_row_idx][x_col_idx]
    level_map[exit_y_param][exit_x_param].wall_directions = {}
    
    -- Update the map (modifying front_tile directly is enough as it's a reference)
    -- level_map[front_row][front_col] = front_tile 
    
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
    instance.width = 9
    instance.height = 9

    -- instance.level_map will store the map grid, indexed as [y_row_idx][x_col_idx].
    instance.level_map = instance:generateRandomMap(0.3)


    -- Return the newly created instance
    return instance
end

function Map:inBounds(x, y)
    if 0 < y and y <= self.height and 0 < x and x <= self.width then
        return true
    end
    return false
end

-- Parameters:
-- current_grid_x: Player's current column index on the map grid.
-- current_grid_y: Player's current row index on the map grid.
-- dir_x: Proposed movement direction in X (grid units, e.g., -1, 0, 1).
-- dir_y: Proposed movement direction in Y (grid units, e.g., -1, 0, 1).
function Map:TestMap(current_grid_x, current_grid_y, dir_x, dir_y)
    local target_grid_x = current_grid_x + dir_x
    local target_grid_y = current_grid_y + dir_y

    -- Check bounds of the TARGET tile
    if target_grid_y > 0 and target_grid_y <= self.height and
       target_grid_x > 0 and target_grid_x <= self.width then
        
        -- Get the CURRENT tile to check its walls
        -- Access map with level_map[y_row_idx][x_col_idx]
        local current_tile = self.level_map[current_grid_y][current_grid_x]
        
        -- Debug prints (optional, updated to reflect grid coordinates)
        -- print("--- Map:TestMap DEBUG ---")
        -- print("Current Grid Coords of Tile Being Checked: x=" .. current_tile.x .. ", y=" .. current_tile.y)
        -- print("Movement Direction: dx=" .. dir_x .. ", dy=" .. dir_y)
        -- print("Target Grid Coords: x=" .. target_grid_x .. ", y=" .. target_grid_y)
        -- print("Current Tile Wall Directions:")
        -- for _, direction in ipairs(current_tile.wall_directions:elements()) do
        --     print("  Wall: x=" .. direction.x .. ", y=" .. direction.y)
        -- end
        
        return current_tile:isMoveAllowed(dir_x, dir_y)
    end

    -- Movement is out of bounds
    -- print("--- Map:TestMap DEBUG ---")
    -- print("Movement out of bounds. Target: x=" .. target_grid_x .. ", y=" .. target_grid_y)
    return false
end



function Map:draw()
    -- self:printMap()
    for y=1, #self.level_map do
		for x=1, #self.level_map[y] do
            self.level_map[y][x]:draw()
		end
	end
end

return Map
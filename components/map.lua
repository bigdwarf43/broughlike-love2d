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
        for y = 1, self.height do
            level_map[y] = {}
            for x = 1, self.width do
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
        local exit_x, exit_y = self:getExitCoords()
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

        self:removeExitBlocks(exit_y,exit_x, level_map)

        
        return level_map
    end
    
    local level_map =  buildMap()

    return level_map
end

function Map:findRandomEmptyPosition(level_map)

    level_map = level_map or self.level_map
    local zeroPositions = {}
    for col = 1, #level_map do
        for row = 1, #level_map[col] do
            if level_map[col][row].passable == true then
                table.insert(zeroPositions, {row = row, col = col})
            end
        end
    end

    local player_pos = zeroPositions[math.random(#zeroPositions)]
    return player_pos.col, player_pos.row
end

function Map:getExitCoords()
    -- local col, row = self:findRandomEmptyPosition()
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
    instance.width = 9
    instance.height = 9

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


function Map:TestMap(player_current_x, player_current_y, dir_x, dir_y)
    -- check bounds of the map
    if 0 < ((player_current_y / TILE_SIZE) + dir_y) and ((player_current_y / TILE_SIZE) + dir_y) <= self.height and
        0 < ((player_current_x / TILE_SIZE) + dir_x) and ((player_current_x / TILE_SIZE) + dir_x) <= self.width then
        -- check if the tile on the grid is passable
        local tile = self.level_map[(player_current_y / TILE_SIZE)][(player_current_x / TILE_SIZE)]
        -- if tile.wall_directions[{x=dir_x, y=dir_y}] then
        --     return false
        -- end
        
        print("CURRENT COORDS")
        print(tile.x, tile.y)
        print("WALL DIRECTIONS")
        for _, direction in ipairs(tile.wall_directions:elements()) do
            print(direction.x, direction.y)
        end
        print("MOVIN IN")
        print(dir_x, dir_y)

        -- for _, direction in ipairs(tile.wall_directions) do
        --     if direction.x == dir_x and direction.y == dir_y then
        --         return false
        --     end
        -- end

        return tile:isMoveAllowed(dir_x, dir_y)

    end

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
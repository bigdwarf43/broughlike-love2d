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
    print(direction.x, direction.y)
    local opposite_dir = {x = direction.x*-1, y=direction.y*-1}
    table.insert(tile.wall_directions, opposite_dir)
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
                    local abs_dir = {x = random_dir.x*-1, y=random_dir.y*-1}

                    table.insert(level_map[random_dir.y+y][random_dir.x+x].wall_directions,  abs_dir)  -- Place a wallrandom_dir
                    
                end
            end
        end

        -- Add border walls (1) around the entire level_map
        for y = 1, self.height do
            level_map[y][1] = Tile.Floor_tile:new(1, y, {{x = 0, y = 1},{x = 0, y = -1},{x = 1, y = 0},{x = -1, y = 0}})      -- Left border
            table.insert(level_map[y][1+1].wall_directions,  {x = -1, y = 0})  -- Place a wallrandom_dir
            
            
            level_map[y][self.width] = Tile.Floor_tile:new(self.width, y, {{x = 0, y = 1},{x = 0, y = -1},{x = 1, y = 0},{x = -1, y = 0}})    -- Right border
            table.insert(level_map[y][self.width-1].wall_directions,  {x = 1, y = 0})  -- Place a wallrandom_dir
            
        end
        
        for x = 1, self.width do
            level_map[1][x] = Tile.Floor_tile:new(x, 1, {{x = 0, y = 1},{x = 0, y = -1},{x = 1, y = 0},{x = -1, y = 0}})  -- Top border
            table.insert(level_map[2][x].wall_directions,  {x = 0, y = -1})  -- Place a wallrandom_dir

            
            level_map[self.height][x] = Tile.Floor_tile:new(x, self.height, {{x = 0, y = 1},{x = 0, y = -1},{x = 1, y = 0},{x = -1, y = 0}})   -- Bottom border
            table.insert(level_map[self.height-1][x].wall_directions, {x = 0, y = 1})  -- Place a wallrandom_dir
        end

        -- for y = 1, self.height do
        --     for x = 1, self.width do
        --         for idx, dir in ipairs(level_map[y][x].wall_directions) do
        --             self:addWallInCorrespondingTile(level_map[y][x], dir)
        --         end
        --     end
        -- end
        
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

function Map:removeExitBlocks(exit_x, exit_y)
    -- Determine which border the exit is on and find its facing direction
    local exit_direction = {x = 0, y = 0}
    
    -- Exit is on the top row (row 1)
    if exit_x == 1 then
        exit_direction.x = 1  -- Facing down
    -- Exit is on the bottom row
    elseif exit_x == self.height then
        exit_direction.x = -1  -- Facing up
    -- Exit is on the leftmost column (column 1)
    elseif exit_y == 1 then
        exit_direction.y = 1  -- Facing right
    -- Exit is on the rightmost column
    elseif exit_y == self.height then
        exit_direction.y = -1  -- Facing left
    end
    
    print("EXIT ON")
    print(exit_x, exit_y)
    print("REMOVING WALL FROM")
    print(exit_x+exit_direction.x, exit_y+exit_direction.y)
    print("IN DIRECTION")
    print(exit_direction.x, exit_direction.y)



    local exit_corresponding_tile = self.level_map[exit_y+exit_direction.y][exit_x+exit_direction.x]
    
    for idx, dir in ipairs(exit_corresponding_tile.wall_directions) do
        if dir.x == (exit_direction.x*-1) and dir.y == (exit_direction.y*-1) then
            table.remove(exit_corresponding_tile.wall_directions, idx)
            print("WALLS IN")
            print(exit_corresponding_tile.x, exit_corresponding_tile.y)
            for _,line in ipairs(exit_corresponding_tile.wall_directions) do print(table.concat(line)) end
            break
        end
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

    -- place one exit on the map
    local exit_x, exit_y = instance:getExitCoords()

    instance.level_map = instance:generateRandomMap(0.3)

    instance.level_map[exit_y][exit_x] = Tile.Exit_tile:new(exit_x, exit_y)
    instance:removeExitBlocks(exit_x, exit_y)


    -- Return the newly created instance
    return instance
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
        for _, direction in ipairs(tile.wall_directions) do
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
        -- if tile.passable == false then
        --     return false
        -- end
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
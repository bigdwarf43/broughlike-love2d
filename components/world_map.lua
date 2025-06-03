Map = require "components.map"
Events = require "components.events"
Globals = require "globals"

World_map ={}
World_map.__index = World_map


function World_map:new()
    
    local instance  = {}
    setmetatable(instance, World_map)
    instance:GenerateWorld()

    return instance
end

function World_map:inBounds(row, col)
    -- 1 is filled with border and also width column and height row
    if 0 < row and row <= Globals.WORLD_SIZE_ROW and 0 < col and col <= Globals.WORLD_SIZE_COL then
        return true
    end
    return false
end

function World_map:GenerateWorld()
    for row=1,Globals.WORLD_SIZE_ROW do
        Globals.WORLD_ARRAY[row] = {}  -- initialize each row as a table
        for col=1,Globals.WORLD_SIZE_COL do
            
            local exit_dirs = {}
            if row > 1 then
                table.insert(exit_dirs, "up")
            end

            if row < Globals.WORLD_SIZE_ROW then
                table.insert(exit_dirs, "down")
            end

            if col > 1 then
                table.insert(exit_dirs, "left")
            end

            if col < Globals.WORLD_SIZE_COL then
                table.insert(exit_dirs, "right")
            end


            local map_obj = Map:new {
                level = ((row - 1) * Globals.WORLD_SIZE_COL) + (col - 1),
                exit_dirs = exit_dirs,
                room_world_row = row,
                room_world_col = col
            }
            map_obj:GenerateMonsters()

            Globals.WORLD_ARRAY[row][col] = map_obj
        end
    end
end

function World_map:fetchMapFromExitDir(room_row, room_col, exit_dir)
    print("Player exited the room (from listener.lua) " ..
    tostring(room_row) .. " " .. tostring(room_col) .. " " .. tostring(exit_dir))

    local grid_directions = {
        up    = { row = -1, col = 0 },
        down  = { row = 1, col = 0 },
        left  = { row = 0, col = -1 },
        right = { row = 0, col = 1 }
    }
    local grid_dir = grid_directions[exit_dir]
    local map_room = Globals.WORLD_ARRAY[room_row + grid_dir.row][room_col + grid_dir.col]
    map_room.revealed = true

    Globals.CURRENT_ROW = room_row + grid_dir.row
    Globals.CURRENT_COL = room_col + grid_dir.col

    local player_row, player_col = map_room:fetchPLayerPositionFromExit(exit_dir)

    LoadNewMap(map_room, player_row, player_col)
end


Events.on_player_exit:connect(function(room_row, room_col, exit_dir)
    World_map:fetchMapFromExitDir(room_row, room_col, exit_dir)
end)

function World_map:fetchInitMap()
    local row = math.random(Globals.WORLD_SIZE_ROW)
    local col = math.random(Globals.WORLD_SIZE_COL)
    local map_obj = Globals.WORLD_ARRAY[row][col]

    Globals.CURRENT_ROW = row
    Globals.CURRENT_COL = col

    map_obj.revealed = true
    return map_obj
end

function World_map:drawMinimap()
    local cellSize = 10
    local cellSpacing = 10
    local tileStep = cellSize + cellSpacing

    -- Draw border
    local mapWidth = Globals.WORLD_SIZE_COL * tileStep
    local mapHeight = Globals.WORLD_SIZE_ROW * tileStep
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", 0, 0, mapWidth+10, mapHeight+10)

    -- Draw each tile
    for row = 1, Globals.WORLD_SIZE_ROW do
        for col = 1, Globals.WORLD_SIZE_COL do
            local x = (col - 0.5) * tileStep
            local y = (row - 0.5) * tileStep

            if row == Globals.CURRENT_ROW and col == Globals.CURRENT_COL then
                love.graphics.setColor(0, 1, 0, 1)  -- Green for current position
            else
                love.graphics.setColor(0.5, 0.5, 0.5, 1)  -- Gray for other rooms
            end
            
            local map_room = Globals.WORLD_ARRAY[row][col]

            
            if map_room.revealed then
                
                -- draw the room on the map
                love.graphics.rectangle("fill", x, y, cellSize, cellSize)
                -- Calculate the center of the current room
                local roomCenterX = x + cellSize / 2
                local roomCenterY = y + cellSize / 2

                -- draw its paths
                for _, dir in ipairs(map_room.exit_dirs) do
                    local loc = Globals.GRID_DIRECTIONS_MAP[dir]
                    local endX = roomCenterX + loc.col * cellSize
                    local endY = roomCenterY + loc.row * cellSize
                    love.graphics.line(roomCenterX, roomCenterY, endX, endY)

                end

            end
        end
    end

    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

return World_map

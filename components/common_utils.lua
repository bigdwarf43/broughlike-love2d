COMMON_UTILS ={}
function COMMON_UTILS:Lerp(start, dest, t)
    return (1-t)*start + dest*t
end

function COMMON_UTILS:fetchScreenCoords(row, col)
    local x_coord = col * TILE_SIZE * OFFSET
    local y_coord =  row* TILE_SIZE * OFFSET

    return x_coord, y_coord
end

function COMMON_UTILS:Astar(start, goal, graph)

    local function heuristic(a, b)
        return math.abs(a.x - b.x) + math.abs(a.y - b.y) -- Manhattan distance
    end

    local frontier = {}

    local function node_id(n)
        -- Converts a node to a unique string key if n is a table
        if type(n) == "table" then
            return tostring(n.x) .. "," .. tostring(n.y)
        else
            return tostring(n)
        end
    end

    local function push(node, priority)
        table.insert(frontier, {node = node, priority=priority})
        table.sort(frontier, function(a, b) return a.priority < b.priority end)
        print("PUSHED "..tostring(node.x)..tostring(node.y))
    end

    local function pop()
        return table.remove(frontier, 1).node
    end

    local came_from = {}
    local visited = {}

    local start_id = node_id(start)
    local goal_id = node_id(goal)

    push(start, heuristic(start, goal))
    came_from[start_id] = nil
    visited[start_id] = true


    local function print_came_from()
        print("CAME FROM")
        for key , val in pairs(came_from) do
            print(key, val.x, val.y) 
        end
    end

    while #frontier>0 do
        local current = pop()
        local current_id = node_id(current)

        if current_id == goal_id then
            break
        end

        for _, next in ipairs(graph:neighbours(current)) do
            local next_id = node_id(next)
            if not visited[next_id] then
                print("VISITED"..tostring(next.x)..tostring(next.y))
                visited[next_id] = true
                local priority = heuristic(next, goal)
                push(next, priority)
                came_from[next_id] = current
                print_came_from()
            end
        end
        
       
    end

    local path = {}
    local current = goal
    
   

    print("PATH")
    while current~=nil do
        if current~=goal then
            table.insert(path, current)            
        end
        current = came_from[node_id(current)]
        print(node_id(current))
    end
    -- table.remove(path, goal)

    return path
    
end

return COMMON_UTILS
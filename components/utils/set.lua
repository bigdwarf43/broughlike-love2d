-- Set module
Set = {}
Set.__index = Set

-- Create a new set
function Set.new(list)
    local self = setmetatable({}, Set)
    self.items = {}
    if list then
        for _, value in ipairs(list) do
            self.items[value] = true
        end
    end
    return self
end

-- Add an element
function Set:add(value)
    self.items[value] = true
end

-- Remove an element
function Set:remove(value)
    self.items[value] = nil
end

-- Check if an element exists
function Set:contains(value)
    return self.items[value] ~= nil
end

-- Get size of set
function Set:size()
    local count = 0
    for _ in pairs(self.items) do
        count = count + 1
    end
    return count
end

-- Iterate over elements
function Set:elements()
    local elements = {}
    for key in pairs(self.items) do
        table.insert(elements, key)
    end
    return elements
end

-- Union of two sets
function Set:union(other)
    local result = Set.new()
    for k in pairs(self.items) do result:add(k) end
    for k in pairs(other.items) do result:add(k) end
    return result
end

-- Intersection of two sets
function Set:intersection(other)
    local result = Set.new()
    for k in pairs(self.items) do
        if other:contains(k) then result:add(k) end
    end
    return result
end

-- Difference between two sets
function Set:difference(other)
    local result = Set.new()
    for k in pairs(self.items) do
        if not other:contains(k) then result:add(k) end
    end
    return result
end

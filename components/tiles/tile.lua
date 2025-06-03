require "components.utils.set"
require "components.common_utils"
Events = require "components.events"

-- base class
Tile = {}
Tile.__index = Tile

--- creates a new tile
---@row : int
---@col : int
---@sprite : int
---@passable : boolean
function Tile:new(row, col, sprite, passable)

    local instance ={}
    setmetatable(instance, self)

    instance.row = row
    instance.col = col
    instance.sprite = sprite
    instance.passable = passable

    instance.size_offset = -10
    instance.wall_directions = {}
    instance.entity = nil

    return instance
end

function Tile:draw()
    return
end
function Tile:doStuff()
    return
end

function Tile:isMoveAllowed(row, col)

    local direction
    if row==-1 and col==0 then
        direction= "up"
    elseif row==1 and col==0  then
        direction= "down"
    elseif row==0 and col==-1  then
        direction= "left"
    elseif row==0 and col==1  then
        direction= "right"
    end

    return not self.wall_directions:contains(direction)

end


return Tile
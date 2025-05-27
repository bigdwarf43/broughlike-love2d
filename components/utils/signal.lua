Signal = {}
Signal.__index = Signal

function Signal:new()
    local instance = {
        listeners = {}
    }
    setmetatable(instance, Signal)
    return instance
end

function Signal:connect(callback)
    table.insert(self.listeners, callback)
end

function Signal:emit(...)
    for _, callback in ipairs(self.listeners) do
        callback(...)
    end
end

return Signal

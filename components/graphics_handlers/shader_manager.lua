local ShaderManager = {}
ShaderManager.__index = ShaderManager

local instance = nil

function ShaderManager:new()
    if instance then
        return instance
    end

    local self = setmetatable({}, ShaderManager)
    self.shaders = {}
    instance = self
    return self
end

function ShaderManager:load()
    self.shaders["grayscale"] = love.graphics.newShader("components/shaders/grayscale.glsl")
    -- Add more shaders here as needed
end

function ShaderManager:get(name)
    return self.shaders[name]
end

function ShaderManager:setShader(name)
    love.graphics.setShader(self:get(name))
end

function ShaderManager:reset()
    love.graphics.setShader()
end

return ShaderManager:new()

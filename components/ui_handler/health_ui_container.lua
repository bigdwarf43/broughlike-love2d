UI_MANAGER = {}

function UI_MANAGER:draw_health(current_health)
    for i=1,current_health do
        love.graphics.circle("fill", 0+i*20, 0 , 10)
    end
end


return UI_MANAGER
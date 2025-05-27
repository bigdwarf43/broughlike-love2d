local Signal = require "components.utils.signal"

-- Shared signal(s) available to other files
local Events = {}

Events.on_player_exit = Signal:new()

return Events

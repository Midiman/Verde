gamestate	= require "libs.hump.gamestate"

local state = {}
function state:enter(state)
	love.graphics.setBackgroundColor(32,32,32)
	self.uptime = 0
end

function state:keyreleased(key, unicode)
end

function state:update(dt)
	self.uptime = self.uptime + dt
	self.dt = dt
end

function state:draw()
	love.graphics.print(string.format("%02.2f",self.uptime),
						 SCREEN_LEFT + 0, SCREEN_TOP + 0, 0
						 )
end

return state

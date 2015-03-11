Class = require "libs.hump.class"
Vector = require "libs.hump.vector"

Rectangle = require "rectangle"
Entity = require "entity"

Creature = Class {
	init = function(self, x, y)
		self.position = Vector(x,y)
		self.bounds = Vector(32,32)
	end
}
function Creature:setPosition(x, y)
	self.position = Vector(x,y)
end

function Creature:getPosition()
	return self.position:unpack()
end
function Creature:draw()
	love.graphics.rectangle("fill",
		self.position.x - self.bounds.x/2, self.position.y - self.bounds.y/2,
		self.bounds.x, self.bounds.y
	)
end

return Creature

Class = require "libs.hump.class"
Vector = require "libs.hump.vector"

Entity = Class {
 	init = function(self, x, y)
		self.position = Vector(x,y)
		self.bounds = Vector(32,32)
	end
}
function Entity:setPosition(x, y)
	self.position = Vector2(x,y)
end
function Entity:getPosition()
	return self.position:unpack()
end

return Entity

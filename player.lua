Class = require "libs.hump.class"
Vector = require "libs.hump.vector"

Rectangle = require "rectangle"
Creature = require "creature"

Player = Class {
	__includes = Creature,
	init = function(self, x, y)
		self.position = Vector(x,y)
		self.velocity = Vector(0,0)
		self.bounds = Vector(32,32)
	end
}
function Player:setPosition(x, y)
	self.position = Vector(x,y)
end

function Player:move(v)
	self.position = self.position + v
end

function Player:getPosition()
	return self.position:unpack()
end

function Player:onCollision(entity, dx, dy)

end

function Player:draw()
	love.graphics.push()
	love.graphics.setColor(255,192,192)
	love.graphics.rectangle("fill",
		self.position.x - self.bounds.x/2, self.position.y - self.bounds.y/2,
		self.bounds.x, self.bounds.y
	)
	love.graphics.pop()
end

return Player

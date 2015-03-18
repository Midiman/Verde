Class = require "libs.hump.class"
Vector = require "libs.hump.vector"

Rectangle = require "rectangle"
Creature = require "creature"

Player = Class {
	__includes = Creature,
	init = function(self, x, y)
		self.position = Vector(x,y)
		self.velocity = Vector(0,0)
		self.grounded = false
		self.bounds = Vector(24,32)
		self.map = nil
		self.lastTile = Vector(0,0)
		self.color = {255,255,255}
	end
}
function Player:setMap( map )
	self.map = map
end
function Player:setPosition(x, y)
	self.position = Vector(x,y)
end
function Player:isGrounded() return self.grounded end
function Player:move(v)
	self.position = self.position + v
end

function Player:getPosition()
	return self.position:unpack()
end

function Player:getVelocity()
	return self.velocity:unpack()
end
function Player:onCollision(entity, dx, dy)

end

function Player:update(dt)
	if not self.grounded then
		self.velocity.y = self.velocity.y + GRAVITY
	end
	self:move( self.velocity * dt)
	self.velocity.x = 0
	local x, y = self.position:unpack()
	local tx, ty = self.map:convertScreenToTile(x, y)
	
	tx = math.floor(tx)
	ty = math.floor(ty)
	self.lastTile = Vector(tx,ty)
	
	self.grounded = false
	if self.map.layers["Tile Layer 1"].data[ty+1][tx+1] then
		local dy = (ty * self.map.tileheight) - self.position.y
		local dx = (tx * self.map.tilewidth) - self.position.x

		self.grounded = true
		self.position.y = self.position.y + dy
		self.velocity.y = 0 
	end
	if self.map.layers["Tile Layer 1"].data[ty][tx+2] then
		local dy = ((ty-1) * self.map.tileheight) - self.position.y
		local dx = ((tx) * self.map.tilewidth) - self.position.x
		
		self.position.x = self.position.x + dx
		self.velocity.x = 0 
	end
	
	self.color = self.grounded and {255,255,0} or {0,255,255}
	
	if self.grounded and love.keyboard.isDown("up") then
		self.velocity.y = -GRAVITY * self.map.tileheight
	end
	if love.keyboard.isDown("left") then
		self.velocity.x = -128
	end
	if love.keyboard.isDown("right") then
		self.velocity.x = 128
	end
end

function Player:draw()
	love.graphics.push()
	love.graphics.setColor( unpack(self.color) )
	love.graphics.rectangle("fill",
		self.position.x - self.bounds.x/2, self.position.y - self.bounds.y,
		self.bounds.x, self.bounds.y
	)
	love.graphics.setColor(0,255,255)
	love.graphics.rectangle("line",
		self.lastTile.x * self.map.tilewidth, self.lastTile.y * self.map.tileheight,
		self.map.tilewidth,self.map.tileheight
	)
	love.graphics.setColor(255,0,0)
	love.graphics.rectangle("fill",
		self.lastTile.x * self.map.tilewidth, (math.ceil( (self.position.y + 1 ) / self.map.tileheight) * self.map.tileheight),
		self.map.tileheight, 2
	)
	love.graphics.setColor(255,0,255)
	love.graphics.circle("fill", self.position.x, self.position.y, 4, 4)
	love.graphics.pop()
end

return Player

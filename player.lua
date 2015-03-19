Class = require "libs.hump.class"
Vector = require "libs.hump.vector"

Rectangle = require "rectangle"
Creature = require "creature"

Player = Class {
	__includes = Creature,
	init = function(self, x, y)
		self.position = Vector(x,y)
		self.velocity = Vector(0,0)
		self.correction = Vector(0,0)
		self.grounded = false
		self.bounds = Vector(32,32)
		self.map = nil
		self.bottomTile = Vector(0,0)
		self.rightTile = Vector(0,0)
		self.leftTile = Vector(0,0)
		self.topTile = Vector(0,0)
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

function Player:getCorrection()
	return self.correction:unpack()
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
	
	local bx, by = self.map:convertScreenToTile(x, y)
	bottom_x = math.floor(bx)
	bottom_y = math.floor(by)
	
	rx, ry = self.map:convertScreenToTile(x + self.bounds.x/2, y - self.bounds.y/2)
	right_x = math.floor(rx)
	right_y = math.floor(ry)
	
	lx, ly = self.map:convertScreenToTile(x - self.bounds.x/2, y - self.bounds.y/2)
	left_x = math.floor(lx)
	left_y = math.floor(ly)
	
	tx, ty = self.map:convertScreenToTile(x, y - self.bounds.y)
	top_x = math.floor(tx)
	top_y = math.floor(ty)
	
	self.bottomTile = Vector(bottom_x, bottom_y)
	self.rightTile = Vector(right_x, right_y)
	self.leftTile = Vector(left_x, left_y)
	self.topTile = Vector(top_x, top_y)
	self.grounded = false
	
	-- Top
	if self.map.layers["Tile Layer 1"].data[top_y+1][top_x+1] then
		--local tile_offset = self.map.layers["Tile Layer 1"].data[top_y+1][top_x+1].offset.y
		local tile_offset = self.map.tileheight
		local dy = ((top_y) * self.map.tileheight) + tile_offset - ( self.position.y - self.bounds.y )
		
		self.correction.y = dy
		
		self.position.y = self.position.y + dy
		self.velocity.y = 0 
	end
	-- Bottom
	if self.map.layers["Tile Layer 1"].data[bottom_y+1][bottom_x+1] then
		local dy = ((bottom_y) * self.map.tileheight) - self.position.y
		
		self.correction.y = dy

		self.grounded = true
		self.position.y = self.position.y + dy
		self.velocity.y = 0 
	end
	-- Left
	if self.map.layers["Tile Layer 1"].data[left_y+1][left_x+1] then
		--local tile_offset = self.map.layers["Tile Layer 1"].data[left_y+1][left_x+1].offset.x
		local tile_offset = self.map.tilewidth
		local dx = ((left_x) * self.map.tilewidth) + tile_offset - ( self.position.x - self.bounds.x/2)
		
		self.correction.x = dx
		
		self.position.x = ( self.position.x ) + dx
		self.velocity.x = 0
	end
	-- Right
	if self.map.layers["Tile Layer 1"].data[right_y+1][right_x+1] then
		local dx = ((right_x) * self.map.tilewidth) - ( self.position.x + self.bounds.x/2)
		
		self.correction.x = dx
		
		self.position.x = ( self.position.x ) + dx
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
	-- Player Mask
	love.graphics.setColor( unpack(self.color) )
	love.graphics.rectangle("fill",
		self.position.x - self.bounds.x/2, self.position.y - self.bounds.y,
		self.bounds.x, self.bounds.y
	)
	
	-- Tiles
	love.graphics.setColor(0,255,255)
	love.graphics.rectangle("line",
		(self.bottomTile.x) * self.map.tilewidth, (self.bottomTile.y) * self.map.tileheight,
		self.map.tilewidth, self.map.tileheight
	)
	love.graphics.rectangle("line",
		(self.rightTile.x) * self.map.tilewidth, (self.rightTile.y) * self.map.tileheight,
		self.map.tilewidth, self.map.tileheight
	)
	love.graphics.rectangle("line",
		(self.leftTile.x) * self.map.tilewidth, (self.leftTile.y) * self.map.tileheight,
		self.map.tilewidth, self.map.tileheight
	)
	love.graphics.rectangle("line",
		(self.topTile.x) * self.map.tilewidth, (self.topTile.y) * self.map.tileheight,
		self.map.tilewidth, self.map.tileheight
	)
	-- Origin
	love.graphics.setColor(255,0,255)
	love.graphics.circle("fill", self.position.x, self.position.y, 4, 4)
	love.graphics.pop()
end

return Player

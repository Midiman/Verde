gamestate	= require "libs.hump.gamestate"
sti = require "libs.simple-tiled-implementation"

function aabb_collision2(x1, y1, w1, h1, x2, y2, w2, h2)
	if  (x1 + w1 >= x2) and (x1 <= x2 + w2) and
		(y1 + h1 >= y2) and (y1 <= y2 + h2) then
		return true
	end
	return false
end
function aabb_collision( aX, aY, aW, aH, bX, bY, bW, bH ) 
  return aX < bX+bW and
		 bX < aX+aW and
		 aY < bY+bH and
		 bY < aY+aH
end

function aabb_intersect( aX, aY, aW, aH, bX, bY, bW, bH )
	local bIntersect = aX < bX+bW and
					   bX < aX+aW and
					   aY < bY+bH and
					   bY < aY+aH
	-- Centers of both rects
	local aHX = aX + aW/2
	local aHY = aY + aH/2
	local bHX = bX + bW/2
	local bHY = bY + bH/2
	
	-- Maximum distances to check for
	local mX, mY = aW/2 + bW/2, aH/2 + bH/2
	
	-- Pure distance between both rect's
	local dX, dY = aHX - bHX, aHY - bHY
	
	-- Return early if we exceed the maximum
	if math.abs(dX) >= mX or math.abs(dY) >= mY then return bIntersect, 0, 0 end
	
	-- Push em
	local rX = dX > 0 and mX - dX or -mX - dX
	local rY = dY > 0 and mY - dY or -mY - dY
	
	return bIntersect, rX, rY
end


local state = {}
function state:enter(state)
	love.graphics.setBackgroundColor(0,0,0)
	self.map = sti.new("data/maps/00")
	self._world = love.physics.newWorld(0,0)
	self.mapCollisions = self.map:initWorldCollision(self._world)
	self.uptime = 0
	--
	self.floors = {}
	local tile_width = 32
	local tile_height = 32
	for i=1,SCREEN_WIDTH/tile_width do
		self.floors[#self.floors+1] = { x=(i-1) * tile_width, y=480, width=tile_width, height=tile_height }
	end
		for i=1,SCREEN_WIDTH/tile_width do
		self.floors[#self.floors+1] = { x=(i-1) * tile_width, y=320, width=tile_width, height=tile_height }
	end
	for i=1,SCREEN_CENTER_X/tile_width do
		self.floors[#self.floors+1] = { x=(SCREEN_CENTER_X) + (i-1) * tile_width, y=480-tile_height, width=tile_width, height=tile_height }
	end
	for i=1,SCREEN_CENTER_X/tile_width - 4 do
		self.floors[#self.floors+1] = { x=(i-1) * tile_width, y=480-tile_height, width=tile_width, height=tile_height }
	end
	--
	self.dude = {}
	self.dude.x, self.dude.y = SCREEN_CENTER_X-32, SCREEN_CENTER_Y+96
	self.dude.prevX, self.dude.prevY = 0, 0
	self.dude.isColliding = false
	self.dude._intersectX = 0
	self.dude._intersectY = 0
	self.dude.mask = { width = 32, height = 64 }
	-- sensors; 10x32
	self.dude.sensors = {
		ceiling = {x=-16,y=-68,width=32,height=4},
		floor = {x=-16,y=0,width=32,height=4},
		left = {x=-16,y=-56,width=-4,height=48},
		right = {x=16,y=-56,width=4,height=48},
	}
	self.dude.xspeed = 0
	self.dude.yspeed = 0
	
	-- Accel / DT (1/60)
	self.dude.xaccel = 25
	self.dude.xdecel = 7.5
	self.dude.maxspeed = 5
	self.dude.onground = false
end

function state:keypressed(key, isRepeat)

end

function state:keyreleased(key, unicode)

end

function state:update(dt)
	self.map:update(dt)
	self.uptime = self.uptime + dt
	self.dt = dt
	
	self.dude._prevX = self.dude.x
	self.dude._prevY = self.dude.y
		
	-- On The Ground
	if love.keyboard.isDown( 'up' ) then
		if self.dude.onground then
			self.dude.yspeed = -GRAVITY/2;
			self.dude.onground = false
		end
	end
	
	-- Holding Right
	if love.keyboard.isDown( 'right' ) then
		-- Below Max Speed
		if self.dude.xspeed < self.dude.maxspeed then
			self.dude.xspeed = self.dude.xspeed + self.dude.xaccel * dt
		else 
			self.dude.xspeed = self.dude.maxspeed
		end
	end
	-- Holding Left
	if love.keyboard.isDown( 'left' ) then
		-- Below Max Speed
		if self.dude.xspeed > -self.dude.maxspeed then
			self.dude.xspeed = self.dude.xspeed - self.dude.xaccel * dt
		else
			self.dude.xspeed = -self.dude.maxspeed 
		end
	end
	-- Not Holding Right, Speed > 0
	if not love.keyboard.isDown( 'right' ) and self.dude.xspeed > 0.0  then
		if self.dude.xspeed > 0.0 and self.dude.xspeed < 1 then
			self.dude.xspeed = 0
		else
			self.dude.xspeed = self.dude.xspeed - self.dude.xdecel * dt
		end
	end
	-- Not Holding Left, Speed < 0
	if not love.keyboard.isDown( 'left' ) and self.dude.xspeed < 0.0  then
		if self.dude.xspeed < 0.0 and self.dude.xspeed > -1 then
			self.dude.xspeed = 0
		else
			self.dude.xspeed = self.dude.xspeed + self.dude.xdecel * dt
		end
	end

	-- Not On Ground
	if not self.dude.onground then 
		-- Apply Gravity
		self.dude.yspeed = self.dude.yspeed + dt * GRAVITY
	end
	
	self.dude.x = self.dude.x + self.dude.xspeed
	self.dude.y = self.dude.y + self.dude.yspeed

	--
	self.dude.onground = false
	self.dude.isColliding = false
	local pX, pY = self.dude.x, self.dude.y
	for i, tile in ipairs( self.floors ) do
		local tX, tY, tW, tH = tile.x, tile.y, tile.width, tile.height
		local x_dist, y_dist = tX - pX, tY - pY
		if (math.abs(x_dist) < 64) and (math.abs(y_dist) < 128) then
			if aabb_intersect( pX - self.dude.mask.width/2, pY - self.dude.mask.height , self.dude.mask.width, self.dude.mask.height, tX, tY, tW, tH ) then
				local b, _x, _y = aabb_intersect( pX - self.dude.mask.width/2, pY - self.dude.mask.height , self.dude.mask.width, self.dude.mask.height, tX, tY, tW, tH )
				self.dude._intersectX, self.dude._intersectY = _x, _y
				print( string.format("%02.2f,%02.2f", _x, _y))
				self.dude.isColliding = true
				
				if math.abs(_y) < math.abs(_x) then
					if self.dude._prevY >= tY then
						self.dude.onground = true
					end
					
					self.dude.y = math.floor( self.dude.y ) + _y
				else
					self.dude.x = math.floor( self.dude.x ) + _x
				end
				
				--[[
				if aabb_collision( pX + self.dude.sensors.ceiling.x, pY + self.dude.sensors.ceiling.y, self.dude.sensors.ceiling.width, 12, tX, tY, tW, tH) then
					--print("TOP COLLISION")
					self.dude.y = (tY + tH) + self.dude.mask.height
					self.dude.yspeed = 0
				end
				if yint < 0 and aabb_collision( pX + self.dude.sensors.floor.x, pY + self.dude.sensors.floor.y, self.dude.sensors.floor.width, self.dude.sensors.floor.height, tX, tY, tW, tH) then
					--print("BOT COLLISION")
					self.dude.y = tY
					self.dude.yspeed = 0
					self.dude.onground = true
				end
				if xint < 0 and aabb_collision( pX + self.dude.sensors.left.x, pY + self.dude.sensors.left.y, self.dude.sensors.left.width, self.dude.sensors.left.height, tX, tY, tW, tH) then
					--print("LEFT SIDE COLLISION")
					self.dude.x = tX + ( self.dude.mask.width * 1.5 ) 
					self.dude.xspeed = 0
				end
				if right_intersection < 0 and aabb_collision( pX + self.dude.sensors.right.x, pY + self.dude.sensors.right.y, self.dude.sensors.right.width, self.dude.sensors.right.height, tX, tY, tW, tH) then
					--print("RIGHT SIDE COLLISION")
					self.dude.x = tX - self.dude.mask.width/2
					self.dude.xspeed = 0
				end
				]]
			end
		end
	end
	
	if self.dude._prevX == self.dude.x then
		self.dude.xspeed = 0
	end
	if self.dude._prevY == self.dude.y then
		self.dude.yspeed = 0
	end
end

function state:draw()
	self.map:draw()
	-- Tiles
	for i, tile in ipairs(self.floors) do
		love.graphics.setColor(32,32,32)
		love.graphics.rectangle( "fill", tile.x, tile.y, tile.width, tile.height )
		love.graphics.setColor(64,64,64)
		love.graphics.rectangle( "line", tile.x, tile.y, tile.width, tile.height )
	end
	
	-- Mask
	love.graphics.setColor(255,255,255,32)
	if self.dude.isColliding then love.graphics.setColor(255,32,32,32) end
	love.graphics.rectangle( "fill", self.dude.x - self.dude.mask.width/2, self.dude.y - self.dude.mask.height, self.dude.mask.width, self.dude.mask.height )
	love.graphics.setColor(255,255,255)
	if self.dude.isColliding then love.graphics.setColor(255,32,32) end
	love.graphics.rectangle( "line", self.dude.x - self.dude.mask.width/2, self.dude.y - self.dude.mask.height, self.dude.mask.width, self.dude.mask.height )

	-- Point
	love.graphics.setColor(0,255,0)
	love.graphics.circle( "fill", self.dude.x, self.dude.y, 4, 4 )
	
	--[[ Individual Sensors
	for i, sensor in pairs(self.dude.sensors) do
		love.graphics.setColor(128,0,255,255)
		love.graphics.rectangle( "fill", self.dude.x + sensor.x, self.dude.y + sensor.y, sensor.width, sensor.height )
	end
	]]

	-- Debug
	love.graphics.setColor(255,255,255)
	love.graphics.print( 
    	("X:%05i (%02.2f)\nY:%05i (%02.2f)\nXSPD:%02.02f\nYSPD:%02.02f\nGrounded: %s"):format(
    		self.dude.x, self.dude._intersectX, self.dude.y, self.dude._intersectY, self.dude.xspeed, self.dude.yspeed, self.dude.onground) , SCREEN_LEFT + 16, SCREEN_TOP + 16
	)
end

return state

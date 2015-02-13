gamestate	= require "libs.hump.gamestate"


function aabb_collision( aX, aY, aW, aH, bX, bY, bW, bH ) 
  return aX < bX+bW and
		 bX < aX+aW and
		 aY < bY+bH and
		 bY < aY+aH
end
function aabb_right( aX, aY, aW, aH, bX, bY, bW, bH ) 
	return bX < aX + aW 
end
function aabb_left( aX, aY, aW, aH, bX, bY, bW, bH ) 
	return aX < bX + bW
end
function aabb_top( aX, aY, aW, aH, bX, bY, bW, bH ) 
	return aY < bY + bH
end
function aabb_bottom( aX, aY, aW, aH, bX, bY, bW, bH ) 
	return bY < aY + aH
end

local state = {}
function state:enter(state)
	love.graphics.setBackgroundColor(0,0,0)
	self.uptime = 0
	--
	self.floors = {}
	local tile_width = 32
	local tile_height = 32
	for i=1,SCREEN_WIDTH/tile_width do
		self.floors[#self.floors+1] = { x=(i-1) * tile_width, y=480, width=tile_width, height=tile_height }
	end
	for i=1,SCREEN_CENTER_X/tile_width do
		self.floors[#self.floors+1] = { x=(SCREEN_CENTER_X) + (i-1) * tile_width, y=480-tile_height, width=tile_width, height=tile_height }
	end
	--
	self.dude = {}
	self.dude.x, self.dude.y = SCREEN_CENTER_X, SCREEN_CENTER_Y-80
	self.dude._intersectX = 0
	self.dude._intersectY = 0
	self.dude.mask = { width = 32, height = 64 }
	-- sensors; 10x32
	self.dude.sensors = {
		floor = {x=-16,y=0,width=32,height=4},
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
	self.uptime = self.uptime + dt
	self.dt = dt

	--
	self.dude.onground = false
	local pX, pY, pW, pH = self.dude.x - self.dude.mask.width/2, self.dude.y - self.dude.mask.height, self.dude.mask.width, self.dude.mask.height
	for i, tile in ipairs( self.floors ) do
		local tX, tY, tW, tH = tile.x, tile.y, tile.width, tile.height
		if aabb_collision( pX, pY, pW, pH, tX, tY, tW, tH ) then
			local y_intersection = tile.y - (pY + pH)
			local x_intersection = tile.x - (pX + pW)
			
			self.dude._intersectX = x_intersection
			self.dude._intersectY = y_intersection

			--[[
			if aabb_left( pX, pY, pW, pH, tX, tY, tW, tH ) and x_intersection < 0 then
				self.dude.x = (tX + tW) + pW/2
				self.dude.xspeed = 0
			end
			if aabb_right( pX, pY, pW, pH, tX, tY, tW, tH ) and x_intersection > 0 then
				self.dude.x = tX - pW/2
				self.dude.xspeed = 0
			end
			]]
			
			if aabb_bottom( pX, pY, pW, pH, tX, tY, tW, tH ) and y_intersection < 0 then
				self.dude.y = tY
				self.dude.yspeed = 0
				self.dude.onground = true
			end
			--[[
			if aabb_top( pX, pY, pW, pH, tX, tY, tW, tH ) and y_intersection > 0 then
				self.dude.y = (tY + tH)
				self.dude.yspeed = 0
			end
			]]
		end
	end

	-- On The Ground
	if self.dude.onground then
		if love.keyboard.isDown( 'up' ) then
			self.dude.yspeed = -GRAVITY / 2;
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
end

function state:draw()
	-- Tiles
	for i, tile in ipairs(self.floors) do
		love.graphics.setColor(32,32,32)
		love.graphics.rectangle( "fill", tile.x, tile.y, tile.width, tile.height )
	end
	
	love.graphics.print(string.format("%02.2f",self.uptime),
						 SCREEN_LEFT + 0, SCREEN_TOP + 0, 0
						 )
	-- Mask
	love.graphics.setColor(255,255,255,32)
	love.graphics.rectangle( "fill", self.dude.x - self.dude.mask.width/2, self.dude.y - self.dude.mask.height, self.dude.mask.width, self.dude.mask.height )
	love.graphics.setColor(255,255,255)
	love.graphics.rectangle( "line", self.dude.x - self.dude.mask.width/2, self.dude.y - self.dude.mask.height, self.dude.mask.width, self.dude.mask.height )

	-- Point
	love.graphics.setColor(0,255,0)
	love.graphics.circle( "fill", self.dude.x, self.dude.y, 4, 4 )
	
	-- Individual Sensors
	for i, sensor in pairs(self.dude.sensors) do
		love.graphics.setColor(128,0,255,32)
		love.graphics.rectangle( "fill", self.dude.x + sensor.x, self.dude.y + sensor.y, sensor.width, sensor.height )
		love.graphics.setColor(128,0,255)
		love.graphics.rectangle( "line", self.dude.x + sensor.x, self.dude.y + sensor.y, sensor.width, sensor.height )
	end

	-- Debug
	love.graphics.setColor(255,255,255)
	love.graphics.print( 
    	("X:%05i (%02.2f)\nY:%05i (%02.2f)\nXSPD:%02.02f\nYSPD:%02.02f\nGrounded: %s"):format(
    		self.dude.x, self.dude._intersectX, self.dude.y, self.dude._intersectY, self.dude.xspeed, self.dude.yspeed, self.dude.onground) , SCREEN_LEFT + 16, SCREEN_TOP + 16
	)
    
end

return state

GameState = require "libs.hump.gamestate"
Class = require "libs.hump.class"
vector = require "libs.hump.vector"

sti = require "libs.sti"

Player = require "player"

--

content = {}
content.fonts = {}

game = {}
game.time = 0
game.focused = nil

GRAVITY = 9.80665

SCREEN_LEFT = nil
SCREEN_RIGHT = nil
SCREEN_TOP = nil
SCREEN_BOTTOM = nil
SCREEN_CENTER_X = nil
SCREEN_CENTER_Y = nil
SCREEN_WIDTH = nil
SCREEN_HEIGHT = nil

function love.load()
	-- Globals
	SCREEN_LEFT = 0
	SCREEN_RIGHT = love.graphics.getWidth()
	SCREEN_TOP = 0
	SCREEN_BOTTOM = love.graphics.getHeight()
	SCREEN_CENTER_X = SCREEN_RIGHT / 2
	SCREEN_CENTER_Y = SCREEN_BOTTOM / 2
	SCREEN_WIDTH = love.graphics.getWidth()
	SCREEN_HEIGHT = love.graphics.getHeight()
	--
	love.graphics.setBackgroundColor(0,0,0)
	--
	content.fonts["normal"] = love.graphics.newFont("data/fonts/OpenSans-Semibold.ttf",16)
	love.graphics.setFont(content.fonts["normal"])
	--
	map = sti.new("data/maps/00")
	gal1 = Player()
	gal1:setPosition(SCREEN_CENTER_X - 128,SCREEN_CENTER_Y)
	
	addVelocity = vector(0,0)
	
	numTiles = {}
end

function love.mousepressed(x, y, button)
	--print( string.format("MousePressed %s at [%3i,%3i]", button, x, y) )
end

function love.mousereleased(x, y, button)
	--print( string.format("MouseReleased %s at [%3i,%3i]", button, x, y) )
end

function love.keypressed(key, unicode)
	--print( string.format("KeyPressed %s [%i]", key, unicode) )
end

function love.keyreleased(key)
	--print( string.format("KeyReleased %s", key) )

	-- Quit that mess
	if key == "escape" then 
		love.event.push("quit")
	end
end

function love.update(dt)
	game.time = game.time + dt
	
	addVelocity.y = addVelocity.y + 0.125
	
	gal1:move(addVelocity * dt)
	
	--
	local prevx, prevy = gal1:getPosition()
	local x, y = prevx - 64, prevy - 64
	numTiles = {}
	while x < prevx + 64 do
		while y < prevy + 64 do
			local _x = math.ceil( x / 32 )
			local _y = math.ceil( y / 32 )
			
			if map.layers["Tile Layer 1"].data[_y][_x] then
				if numTiles then
					numTiles[#numTiles+1] = map.layers["Tile Layer 1"].data[_x][_y]
					numTiles[#numTiles].x = _x * 32
					numTiles[#numTiles].y = _y * 32
				end
			end
			x = x + 32
			y = y + 32
		end
	end
	
	--
	for i, t in ipairs(numTiles) do
		print( t.x + t.offset.x .. "," .. t.y + t.offset.y )
	end
end

function love.focus(f)
	game.focused = f
end

function love.quit()
	
end

function love.draw()
	map:draw()
	gal1:draw()
	love.graphics.setColor(0,0,0,128)
	love.graphics.rectangle("fill", 16,12,256,32)
	love.graphics.setColor(255,255,255)
	love.graphics.print( love.timer.getFPS(), 16, 12 )
	love.graphics.print( #map.layers["Tile Layer 1"].data, 16, 12 + 16)
	love.graphics.print( #numTiles, 16, 12 + 16*2)
	
	love.graphics.push()
	for i, t in ipairs(numTiles) do
		love.graphics.setColor(255,0,0)
		love.graphics.rectangle("line", t.x + t.offset.x, t.y + t.offset.y, t.width, t.height )
		love.graphics.setColor(255,0,255)
		love.graphics.print( t.x .. "," .. t.y, t.x + t.offset.x, t.y + t.offset.y )
	end
	love.graphics.pop()
end

Class = require "libs.hump.class"
Vector = require "libs.hump.vector"
sti = require "libs.sti"

Map = Class {
 	init = function(self, map_path)
		self.map = sti.new(map_path)
	end
}

function Map:GetMap()
	return self.map
end


function Map:update()
	self.map:update()
end

function Map:draw()
	self.map:draw()
end

return Map

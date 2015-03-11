Class = require "libs.hump.class"
Vector = require "libs.hump.vector"

Rectangle = Class {
	init = function(self, x, y, w, h)
		self.x = x
		self.y = y
		self.w = w
		self.h = h
	end,
	setBounds = function(self, x, y, w, h)
		self.x = x
		self.y = y
		self.w = w
		self.h = h
	end,
	getBounds = function(self)
		return { x = self.x, y = self.y, w = self.w, h = self.h }
	end
}

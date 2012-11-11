require "src/levels"
require "src/helpers"
_ = require "libs/underscore"

rigs = {}

local tiles = MOAITileDeck2D.new()
tiles:setTexture("asset/tiles.png")
tiles:setSize(8,8)
tiles:setRect(-0.5,-1,0.5,1)

local getProp = function(index)
	local prop = MOAIProp2D.new()
	prop:setDeck(tiles)
	prop:setIndex(index)
	prop:setLoc(20,0)
	return prop
end

local getX = helpers.pluck(1)
local getY = helpers.pluck(2)

rigs.initRig = function()

	rig = {}

	return rig

end

rigs.initRoman = function()

	local rig = rigs.initRig()

	rig.prop = getProp(12)

	return rig

end

local eol = function(points)
	local start, finish = points[1], points[#points]

	local intercept = math.min(unpack(_.map(points,getY)))
	local yMag = (start[2] - finish[2])
	
	local m = yMag / (finish[1] - start[1])
	return function(x)
		return -m * x + intercept
	end
end

rigs.initSquad = function(n)

	local rig = {}
	local squad = {}

	local roman
	local key
	for i = 1,n do
		roman = rigs.initRoman()
		if key == nil then
			key = roman
		else
			roman.prop:setAttrLink(MOAIProp2D.ATTR_PARTITION, key.prop)
			roman.prop:setLoc(i,0)
		end
		table.insert(squad,roman)
	end

	vent:on("input:gesture",function(points)
		local eol = eol(points)
		for i,roman in pairs(squad) do
			local x, y = roman.prop:getLoc()
			roman.prop:seekLoc( x, eol(x), 0.75,  MOAIEaseType.LINEAR)
		end
	end)

	rig.prop = key.prop

	return rig

end

rigs.level = function(name)

	local rig = {}

	rig.level = levels.init(name)

	rig.prop = rig.level.getRows(1,100)
	
	return rig

end

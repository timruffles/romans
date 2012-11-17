require "src/levels"
require "src/helpers"
_ = require "libs/underscore"
require "libs/protractor"
serpent = require "libs/serpent"

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

rigs.initRoman = function(level)

	local rig = rigs.initRig()

	rig.prop = getProp(12)

	rig.getLoc = function()
		return rig.prop:getLoc()
	end

	return rig

end

rigs.initSquad = function(n,level)

	local rig = {}
	local squad = {}

	local roman
	local key
	for i = 1,n do
		roman = rigs.initRoman(level)
		if key == nil then
			key = roman
		else
			roman.prop:setAttrLink(MOAIProp2D.ATTR_PARTITION, key.prop)
			roman.prop:setLoc(-4+i,0)
		end
		squad[#squad + 1] = roman
	end

	local recognizer = protractor.DollarRecognizer()

	-- input handelling
	
	local placeOnGesture = function(gesture)
		local points = _.map(gesture,function(coords)
			local x,y = unpack(coords)
			return protractor.Point(x,y)
		end)
		local squadPoints = protractor.Resample(points,#squad)
		local gesture = recognizer.Recognize(points)
		for i,roman in ipairs(squad) do
			local point = squadPoints[i]
			roman.prop:seekLoc( point.X, point.Y, 0.75,  MOAIEaseType.LINEAR)
		end
	end

	vent:on("input:gesture",placeOnGesture)

	rig.prop = key.prop
	rig.key = key
	rig.squad = squad


	return rig

end

rigs.initFoe = function(obj)

	local rig = {}

	rig.object = obj

	rig.prop = getProp(obj.gid)

	-- TODO crappily set from outsidej
	rig.level = nil

	rig.getLoc = function()
		local dx,dy = rig.prop:getLoc()
		local x,y = rig.level:getLoc()
		return x + dx,y + dy
	end

	return rig

end

rigs.level = function(name)

	local rig = {}

	rig.level = levels.init(name)

	rig.prop = rig.level.getRows(1,100)

	return rig

end

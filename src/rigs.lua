rigs = {}

local tiles = MOAITileDeck2D.new()
tiles:setTexture("tiles.png")
tiles:setSize(8,8)
tiles:setRect ( -50.5, -85.5, 50.5, 85.5 )

local getProp = function(index)
	local prop = MOAIProp2D.new()
	prop:setDeck(tiles)
	prop:setIndex(index)
	prop:setLoc(20,0)
	return prop
end

rigs.initRig = function()

	rig = {}

	return rig

end

rigs.initRoman = function()

	local rig = rigs.initRig()

	rig.prop = getProp(12)

	return rig

end

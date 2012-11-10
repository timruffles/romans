package.path = package.path .. ";../?.lua"

require "helpers"
require "moai"

levels = {}

local TILE_LAYER = 1
local ENEMY_LAYER = 2

local getRow = function(tiles,w,row)
	return helpers.table.slice(tiles,row * w,(row + 1) * w - 1)
end

function levels.init(levelName)

	local level = require ("levels/" .. levelName)

	local tiles = MOAITileDeck2D.new()
	tiles:setTexture("tiles.png")
	tiles:setSize(8,8)

	local tileIds = level.layers[TILE_LAYER].data

	function level:getRow(rowOffset)

		local grid = MOAIGrid.new()
		grid:initRectGrid(level.width,1,level.tilewidth,171)
		--helpers.trace(rowOffset,unpack(getRow(tileIds,level.width,rowOffset)))
		grid:setRow(1,unpack(getRow(tileIds,level.width,rowOffset)))

		local prop = MOAIProp2D.new()
		prop:setDeck(tiles)
		prop:setGrid(grid)
		
		return prop
	end

	function level:getRows(from,to)

		local parentRow
		local rows = {}

		for rowOffset = from, to do
			local row = self:getRow(rowOffset)
			if parentRow then
				row:setAttrLink(MOAIProp2D.INHERIT_LOC, parentRow, MOAIProp2D.TRANSFORM_TRAIT)
				row:setAttrLink(MOAIProp2D.ATTR_PARTITION, parentRow)
				row:setLoc(0,-85 * (rowOffset - 1))
			else
				parentRow = row
			end
			table.insert(rows,row)
		end

		return parentRow, rows

	end

	return level

end

require "src/helpers"

levels = {}

local TILE_LAYER = 1
local ENEMY_LAYER = 2

local getRow = function(tiles,w,row)
	return helpers.table.slice(tiles,(row - 1) * w + 1,(row + 1) * w)
end


function levels.init(levelName)

	local level = require ("levels/" .. levelName)

	local tiles = MOAITileDeck2D.new()
	tiles:setTexture("asset/tiles.png")
	tiles:setSize(8,8)

	local tileIds = level.layers[TILE_LAYER].data

	local logicalToLevel = function(row)
		return level.height + 1 - row
	end

	function level:getRow(rowOffset)

		local grid = MOAIGrid.new()
		grid:initRectGrid(level.width,1,1,2)
		--helpers.trace(rowOffset,unpack(getRow(tileIds,level.width,rowOffset)))
		local row = getRow(tileIds,level.width,rowOffset)
		grid:setRow(1,unpack(row))

		local prop = MOAIProp2D.new()
		prop:setDeck(tiles)
		prop:setGrid(grid)
		
		return prop
	end

	local getObjects = function(level)
		local objs = level.layers[ENEMY_LAYER].objects
		return _.reduce(objs,{},function(byRow,obj)
			obj.x = math.ceil(obj.x / level.tilewidth)
			obj.y = logicalToLevel( math.ceil(obj.y / level.tileheight) )
			byRow[obj.y] = byRow[obj.y] or {}
			table.insert(byRow[obj.y],obj)
			return byRow
		end)
	end

	local objects = getObjects(level)


	function level:getRows(from,to)

		local parentRow
		local rows = {}

		for rowOffset = to, from, -1 do
			local row = self:getRow(logicalToLevel(rowOffset))
			if parentRow then
				row:setAttrLink(MOAIProp2D.INHERIT_LOC, parentRow, MOAIProp2D.TRANSFORM_TRAIT)
				row:setAttrLink(MOAIProp2D.ATTR_PARTITION, parentRow)
				row:setLoc(-4,(rowOffset - 1) * 1)
				row:setPriority(1)
			else
				parentRow = row
				parentRow:setPriority(2)
				parentRow:setLoc(-4,-6)
			end
			table.insert(rows,row)
		end

		mainThread = MOAICoroutine.new()
		mainThread:run(function()
			local wait = function(action)
				while action:isBusy() do coroutine.yield() end
			end
			row = 1
			while true do
				wait(parentRow:moveLoc ( 0, -1, 0.75,  MOAIEaseType.LINEAR))
				row = row + 1
				vent:trigger("row",row)
				local rowObjects = objects[row] 
				if rowObjects then
					print("Found " .. #rowObjects .. " objects")
					vent:trigger("spawned",rowObjects,row)
				end
			end
		end)

		return parentRow, rows

	end

	return level

end

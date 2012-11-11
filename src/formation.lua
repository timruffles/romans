--[[
-- Formation
-- Accepts an array of props, converts it to a formation, then converts it back to an array of props, each paired with it's x/y coord.
-- Props will be assumed to be a horizontal row, if nothing else is spefified.
--]]
--
package.path = package.path .. ";../?.lua"
local _ = require '../libs/underscore'
local matrix = require '../libs/matrix'

formation = {}

-- input: array of props
-- output: horizontal matrix of props
local function toMatrix(props)
	local grid = matrix(1, #props)
	for i = 1, 1 do
		for j = 1, #props do
			grid[i][j] = props[j]
		end
	end
	return grid
end

-- input: matrix
-- output: weighted, indexed array
local function indexed(grid)
	local newprops = {}
	local counter = 0
	local rowDelta = math.floor(matrix.rows(grid) / 2)
	local colDelta = math.floor(matrix.columns(grid) / 2)
	for i = 1, matrix.rows(grid) do
		for j = 1, matrix.columns(grid) do
			counter = counter + 1
			local iw = i - rowDelta
			local jw = j - colDelta
			newprops[counter] = {iw, jw, matrix.getelement(grid, i, j)}
		end
	end
	return newprops
end

-- input: a weighted, indexed grid
-- output: the same, but with all nil props purged
local function trim(grid)
	local newgrid = {}
	local counter = 0
	for i = 1, #grid do
		-- match unwanted values, e.g. nil, or 0 (when using arrow, dunno why yet)
		if (grid[i][3] == nil or grid[i][3] == 0) then
			counter = counter + 1
		else
			newgrid[i - counter] = grid[i]
		end
	end
	return newgrid
end

function formation.verticalBar(props)
	local grid = matrix.rotr(toMatrix(props))
	return indexed(grid)
end

function formation.horizontalBar(props)
	local grid = toMatrix(props)
	return indexed(grid)
end

-- Roman Testudo formation
-- Will take the sqrt of the length of props to determine how long each side should be
function formation.testudo(props)
	local cols = math.ceil(math.sqrt(table.getn(props)))
	local rows = math.ceil(#props / cols)
	local grid = matrix(cols, rows)
	local counter = 0
	for i = 1, cols do
		for j = 1, rows do
			counter = counter + 1
			grid[i][j] = props[counter] or nil
		end
	end
	return trim(indexed(grid))
end

function formation.arrow(props)
	local cols = #props
	local upper = cols + (cols % 2)
	local rows = math.ceil(cols / 2)
	local rowSize = 0
	if (upper > cols) then
		rowSize = rows
	else
		rowSize = rows + 1
	end
	local grid = matrix(rowSize, cols, nil)
	for i = 1, cols do
		local row = 0
		if (i <= rows) then
			row = (upper / 2) - i + 1
		else
			row = i - rows + 1
		end
		grid[row][i] = props[i] or nil
	end
	return trim(indexed(grid))
end



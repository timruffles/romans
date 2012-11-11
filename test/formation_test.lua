require "lunatest"

package.path = package.path .. ";../?.lua"
require "../src/formation"
local matrix = require '../libs/matrix'
local dc = require '../libs/deepcompare'

-- ignore meta tables when using 'deepcompare'
local ignore = true

-- td = test data
local td1 = {"a", "b", "c" }
local td2 = {"a", "b", "c", "d", "e", "f", "g", "h", "i" }

function setup()
end

function test_formation_horizontalBar()
	local result = formation.horizontalBar(td1)
	local expected = {{1, 0, "a"}, {1, 1, "b"}, {1, 2, "c"}}
	assert_true(deepcompare(expected, result, ignore))
end

function test_formation_verticalBar()
	local result = formation.verticalBar(td1)
	local expected = {{0, 1, "a"}, {1, 1, "b"}, {2, 1, "c"}}
	assert_true(deepcompare(expected, result, ignore))
end

function test_formation_testudo()
	local result = formation.testudo(td1)
	local expected = {{0, 0, "a"}, {0, 1, "b"}, {1, 0, "c"}}
	assert_true(deepcompare(expected, result, ignore))
end

function test_formation_arrow()
	local result = formation.arrow(td1)
	local expected = {{0, 1, "b"}, {1, 0, "a"}, {1, 2, "c"}}
	assert_true(deepcompare(expected, result, ignore))
end

-- just to see what everything looks like
function print_all()

	local sample = {"a", "b", "c", "d", "e", "f", "g", "h", "i" }

	local vert = formation.verticalBar(sample)
	local hori = formation.horizontalBar(sample)
	print("Vertical bar")
	matrix.print(vert)

	print("Horizontal bar")
	matrix.print(hori)

	print("Testudo")
	matrix.print(formation.testudo(sample))

	print("Arrow")
	matrix.print(formation.arrow(sample))
end

lunatest.run()

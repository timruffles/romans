require "lunatest"

package.path = package.path .. ";../?.lua"
require "../src/formation"
local matrix = require '../libs/matrix'
require '../libs/deepcompare'

-- ignore meta tables when using 'deepcompare'
local ignore = true

-- td = test data
local td1 = {"a", "b", "c" }
local td2 = {"a", "b", "c", "d", "e", "f", "g", "h", "i" }

function setup()
end

function test_formation_horizontalBar1()
	local result = formation.horizontalBar(td1)
	local expected = {{0, -1, "a"}, {0, 0, "b"}, {0, 1, "c"}}
	assert_true(deepcompare(expected, result, ignore))
end

function test_formation_horizontalBar2()
	local result = formation.horizontalBar(td2)
	local expected = {{0, -4, "a"}, {0, -3, "b"}, {0, -2, "c"}, {0, -1, "d"}, {0, 0, "e"}, {0, 1, "f"}, {0, 2, "g"}, {0, 3, "h"}, {0, 4, "i"}}
	assert_true(deepcompare(expected, result, ignore))
end

function test_formation_verticalBar1()
	local result = formation.verticalBar(td1)
	local expected = {{-1, 0, "a"}, {0, 0, "b"}, {1, 0, "c"}}
	assert_true(deepcompare(expected, result, ignore))
end

function test_formation_verticalBar2()
	local result = formation.verticalBar(td2)
	local expected = {{-4, 0, "a"}, {-3, 0, "b"}, {-2, 0, "c"}, {-1, 0, "d"}, {0, 0, "e"}, {1, 0, "f"}, {2, 0, "g"}, {3, 0, "h"}, {4, 0, "i"}}
	assert_true(deepcompare(expected, result, ignore))
end

function test_formation_testudo1()
	local result = formation.testudo(td1)
	local expected = {{0, 0, "a"}, {0, 1, "b"}, {1, 0, "c"}}
	assert_true(deepcompare(expected, result, ignore))
end

function test_formation_testudo2()
	local result = formation.testudo(td2)
	local expected = {{-1, -1, "a"}, {-1, 0, "b"}, {-1, 1, "c"}, {0, -1, "d"}, {0, 0, "e"}, {0, 1, "f"}, {1, -1, "g"}, {1, 0, "h"}, {1, 1, "i"}}
	assert_true(deepcompare(expected, result, ignore))
end

function test_formation_arrow1()
	local result = formation.arrow(td1)
	local expected = {{0, 0, "b"}, {1, -1, "a"}, {1, 1, "c"}}
	assert_true(deepcompare(expected, result, ignore))
end

function test_formation_arrow2()
	local result = formation.arrow(td2)
	local expected = {{2, -4, "a"}, {1, -3, "b"}, {0, -2, "c"}, {-1, -1, "d"}, {-2, 0, "e"}, {-1, 1, "f"}, {0, 2, "g"}, {1, 3, "h"}, {2, 4, "i"}}
	matrix.print(result)
	print("Why is this failing? The output seems right")
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

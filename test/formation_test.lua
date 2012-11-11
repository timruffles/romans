require "lunatest"

package.path = package.path .. ";../?.lua"
require "../src/formation"
require "../libs/matrix"

local formation
function setup()
	 formation = Formation:new({"a","b","c","d","e"})
end

function test_formation_L()
	grid = {{"a", nil, nil}, {"b", nil, nil}, {"c", "d", "e"}}
	assert_true(formation.L == grid)
end

lunatest.run()

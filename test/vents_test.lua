require "lunatest"

package.path = package.path .. ";../?.lua"
require "../src/vents"

local vent
function setup()
	vent = vents.initVent()
end

function test_vent_on()
	local called = false
	vent:on("foo",function()
		called = true
	end)
	vent:trigger("foo")
	assert_true(called)
end

function test_vent_off()
	local called = false
	local handler = function()
		called = true
	end
	vent:on("foo",handler)
	vent:off("foo",handler)
	vent:trigger("foo")
	assert_false(called)
end


lunatest.run()

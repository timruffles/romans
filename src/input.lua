require "src/helpers"
_ = require "libs/underscore"
local matrix = require '../libs/matrix'

input = {}

input.init = function(vent,layer)

	local points = {}
	local pointCallback = function(...)
		table.insert(points,arg)
	end
	
	MOAIInputMgr.device.mouseLeft:setCallback(function(isMouseDown)
		if(isMouseDown) then
			points = {}
			MOAIInputMgr.device.pointer:setCallback(pointCallback)
		else
			if #points < 2 then
				return
			end
			--print(output)
			local worldPoints = _.map(points,function(p)
				return {layer:wndToWorld(unpack(p))}
			end)
			matrix.print(worldPoints)
			vent:trigger("input:gesture",worldPoints)
		end
	end)

end

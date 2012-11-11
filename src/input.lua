require "src/helpers"
_ = require "libs/underscore"

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
			--print(output)
			local worldPoints = _.map(points,function(p)
				return {layer:wndToWorld(unpack(p))}
			end)
			vent:trigger("input:gesture",worldPoints)
		end
	end)

end

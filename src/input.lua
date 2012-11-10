require "src/helpers"

input = {}

input.init = function(vent)

	local points = {}
	local pointCallback = function(x,y)
		table.insert(points,{x,y})
	end
	
	MOAIInputMgr.device.mouseLeft:setCallback(function(isMouseDown)
		if(isMouseDown) then
			points = {}
			MOAIInputMgr.device.pointer:setCallback(pointCallback)
		else
			print("gesture")
			local output = "{"
			for i,pos in ipairs(points) do
				output = output .. string.format("{%s,%s},",unpack(pos))
			end
			output = output .. "}"
			print(output)
			vent:trigger("input:gesture",points)
		end
	end)

end

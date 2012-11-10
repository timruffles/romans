require "src/levels"
require "src/rigs"
require "src/input"
require "src/vents"

local test = function(layer)
	local sprite = MOAIGfxQuad2D.new()
	sprite:setTexture("bob.png")
	sprite:setRect(0,0,200,200)

	local prop = MOAIProp2D.new()
	prop:setDeck(sprite)
	layer:insertProp(prop)
end




function init()

	if screenWidth == nil then screenWidth = 320 end
	if screenHeight == nil then screenHeight = 480 end

	MOAISim.openWindow("Window",screenWidth,screenHeight)

	viewport = MOAIViewport.new()
	viewport:setSize(screenWidth,screenHeight)
	local x_scale, y_scale = screenWidth*4,screenHeight*4
	viewport:setScale(x_scale,y_scale)

	local X_ORIGIN = (x_scale / screenWidth) * -screenWidth / 2
	local Y_ORIGIN = (y_scale / screenHeight) * screenHeight / 2

	function initLevel(layer)
		local level = levels.init("test")
		
		local slice, rows = level:getRows(1,100)

		slice:setLoc(X_ORIGIN,Y_ORIGIN)
		layer:insertProp(slice)

		local roman = rigs.initRoman()
		layer:insertProp(roman.prop)
		roman.prop:setPriority(500)
	end

	layer = MOAILayer2D.new()
	layer:setViewport(viewport)

	MOAIRenderMgr.setRenderTable({layer})

	vent = vents.initVent()
	initLevel(layer)
	input.init(vent)

	mainThread = MOAICoroutine.new ()
	mainThread:run(function()
		while true do
			coroutine.yield()
			vent:trigger("tick")
		end
	end)

end

print("Starting up on:" .. MOAIEnvironment.osBrand  .. " version:" .. (MOAIEnvironment.osVersion or ""))
init()

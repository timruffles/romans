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
	local x_scale, y_scale = screenWidth*2.5,screenHeight*2.5
	viewport:setScale(8,12)


	local X_ORIGIN = (x_scale / screenWidth) * -screenWidth / 2
	local Y_ORIGIN = (y_scale / screenHeight) * screenHeight / 2

	local SCROLL_SPEED = 1

	function initLevel(layer)
		local level = levels.init("test")
		
		local slice, rows = level:getRows(1,100)

		layer:insertProp(slice)

		local roman = rigs.initRoman()
		layer:insertProp(roman.prop)
		roman.prop:setPriority(500)


		return slice
	end

	layer = MOAILayer2D.new()
	layer:setViewport(viewport)

	MOAIRenderMgr.setRenderTable({layer})

	vent = vents.initVent()
	local level = initLevel(layer)
	input.init(vent,layer)

	local squad = rigs.initSquad(3)
	layer:insertProp(squad.prop)

	mainThread = MOAICoroutine.new()
	mainThread:run(function()
		while true do
			coroutine.yield()
			vent:trigger("tick")
		end
	end)

end

init()

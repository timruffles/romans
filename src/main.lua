require "levels"

local test = function(layer)
	local sprite = MOAIGfxQuad2D.new()
	sprite:setTexture("bob.png")
	sprite:setRect(0,0,25,25)

	local prop = MOAIProp2D.new()
	prop:setDeck(sprite)
	prop:setLoc(0,0)
	layer:insertProp(prop)
end

function init()

	if screenWidth == nil then screenWidth = 600 end
	if screenHeight == nil then screenHeight = 600 end

	MOAISim.openWindow("Window",screenWidth,screenHeight)

	viewport = MOAIViewport.new()
	viewport:setSize(screenWidth,screenHeight)
	viewport:setScale(screenWidth,screenHeight)

	layer = MOAILayer2D.new()
	layer:setViewport(viewport)

	MOAIRenderMgr.setRenderTable({layer})

	local level = levels.init("test")

	local sliceDuo = level:getRow(2)
	sliceDuo:setLoc(-screenWidth/2,-215)
	layer:insertProp(sliceDuo)

	local slice = level:getRow(1)

	slice:setLoc(-screenWidth/2,-screenHeight/2)
	layer:insertProp(slice)


	mainThread = MOAICoroutine.new ()
	mainThread:run(function()
		while true do
			coroutine.yield()
		end
	end)
	
end

print("Starting up on:" .. MOAIEnvironment.osBrand  .. " version:" .. (MOAIEnvironment.osVersion or ""))
init()

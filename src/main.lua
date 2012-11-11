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
		roman.prop:setPriority(5000)


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

	local foes = {}

	vent:on("spawned",function(objs,row)

		for i,obj in ipairs(objs) do

			local foe = rigs.initFoe(obj)
			print(foe.object.x,foe.object.y)
			foe.prop:setAttrLink(MOAIProp2D.INHERIT_LOC, level, MOAIProp2D.TRANSFORM_TRAIT)
			foe.prop:setLoc(foe.object.x,row)
			layer:insertProp(foe.prop)

			foes[foe] = true
		end
			
	end)

	local die = function(rig)
		layer:removeProp(rig.prop)
	end

	local collide = function(friend,foe)
		local result = math.random(1,2)
		if result == 1 then
			die(foe)
			foes[foe] = nil
		else
			die(friend)
			squad.squad[friend] = nil
			print("squad member lost")
			local allDead = true
			for m,i in pairs(squad.squad) do
				allDead = false
			end
			if allDead then
				vent:trigger("lose")
			else
				print("still alive")
			end
		end
	end

	vent:on("lose",function()
		local sprite = MOAIGfxQuad2D.new()
		sprite:setTexture("asset/dead.png")
		sprite:setRect(-2,-3,2,3)

		local prop = MOAIProp2D.new()
		prop:setDeck(sprite)
		layer:insertProp(prop)
	end)


	local detectCollisions = function()
		for roman,i in pairs(squad.squad) do
			local x,y = roman.prop:getLoc()
			for foe,i in pairs(foes) do
				local eX,eY = foe.prop:getLoc()
				if x-eX < 1 or y-eY < 1 then
					collide(roman,foe)
				end
			end
		end
	end

	vent:on("tick",function(frame)
		if frame % 4 == 0 then
			detectCollisions()
		end
	end)

	mainThread = MOAICoroutine.new()
	mainThread:run(function()
		local frame = 1
		while true do
			coroutine.yield()
			vent:trigger("tick",frame)
			frame = frame + 1
		end
	end)

end

init()

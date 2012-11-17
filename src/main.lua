require "src/rigs"
require "src/input"
require "src/vents"

require "src/helpers"

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
		local level = levels.init("test",{8,12})
		
		local slice, rows = level:getRows(1,100)

		layer:insertProp(slice)

		return slice
	end

	layer = MOAILayer2D.new()
	layer:setViewport(viewport)

	MOAIRenderMgr.setRenderTable({layer})

	vent = vents.initVent()
	local level = initLevel(layer)
	input.init(vent,layer)

	local squad = rigs.initSquad(6,level)
	layer:insertProp(squad.prop)

	local foes = {}

	vent:on("spawned",function(objs,row)

		for i,obj in ipairs(objs) do

			local foe = rigs.initFoe(obj)
			--print(foe.object.x,foe.object.y)
			foe.prop:setAttrLink(MOAIProp2D.INHERIT_LOC, level, MOAIProp2D.TRANSFORM_TRAIT)
			foe.prop:setLoc(foe.object.x,row)
			-- TODO crappy design
			foe.level = level
			foe.prop:setPriority(8750)

			layer:insertProp(foe.prop)


			foes[foe] = true
		end
			
	end)

	local die = function(rig)
		layer:removeProp(rig.prop)
	end

	local collide = function(friend,foe)
		local result = math.random(1,2)
		if true then
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

	local distance = function(x1,y1,x2,y2)
		local xdiff,ydiff = x1-x2, y1-y2
		return math.sqrt(xdiff*xdiff + ydiff*ydiff)
	end

	local row = 1
	vent:on("row",function(rowNow)
		row = rowNow
	end)

	local detectCollisions = function()
		local bX,bY = level:getLoc()
		for i,roman in ipairs(squad.squad) do
			local x,y = roman.getLoc()
			for foe,i in pairs(foes) do
				local eX,eY = foe.getLoc()
				local dis = distance(x,y,eX,eY) 
				--tracef("%d,%d %d,%d %d",x,y,eX,eY,dis)
				if dis < 0.25 then
					collide(roman,foe)
				end
			end
		end
	end

	vent:on("tick",function(frame)
		if frame % 16 == 0 then
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

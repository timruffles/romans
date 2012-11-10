_ = require "libs/underscore"

gestures = {}

local differences = function(points)
	local diffs = {}
	for i,p in ipairs(points) do
		local x2,y2 = unpack(p)
		if i > 1 then
			local x1,y1 = unpack(points[i - 1])
			local xdiff,ydiff = x2-x1,y2-y1
			local xydiff = xdiff-ydiff
			table.insert(diffs,{xdiff,ydiff,xydiff})
		end
	end
	return diffs
end


local sum = function(xs)
	return _.reduce(xs,0,function(sum,x)
		return sum + x
	end)
end

local mean = function(xs)
	return sum(xs) / #xs
end

local travel = function(differences)
	return sum( _.map(differences,_.compose(math.abs,getX)) ) + sum( _.map(differences,_.compose(math.abs,getY)) )
end

local stdDev = function(samples)
	local sampleMean = mean(samples)
	local variances = _.map(samples,function(sample)
		local diff = sampleMean - sample
		return diff * diff
	end)
	local meanVariance = mean(variances)
	local stdDev = math.sqrt(meanVariance)
	return stdDev, sampleMean
end

local chunks = function(xs,size)
	local chunked = _.reduce(xs,{chunks = {}, chunk = {}},function(memo,x)
		if #memo.chunk == size then
			table.insert(memo.chunks,chunk)
			memo.chunk = {}
		end
		table.insert(memo.chunk,x)
		return memo
	end)
	if #chunked.chunk > 0 then
		table.insert(chunked.chunks,chunked.chunk)
	end
	return chunked.chunks
end

local slices = function(xs,size)
	local slices = {}
	local xsCount = #xs
	for i = 1,xsCount do
		local slice = {}
		for io = 0,size - 1 do
			if i + io < xsCount + 1 then
				table.insert(slice,xs[i+io])
			end
		end
		if #slice == size then
			table.insert(slices,slice)
		end
	end
	return slices
end

local goodChunkSize = function(xs,min)
	min = min or 2
	return math.max(math.ceil(math.sqrt(#diffs)),min)
end

local movingAverage = function(xs)
	local size = goodChunkSize(xs,3)
	if size / 2 == 0 then
		size = size - 1
	end
	local sliced = slices(xs,size)
	local averages = _.map(sliced,mean)
	local rampLength =  math.floor(sliced /2)/2
	local weights = {}
	for i = rampLength,1,-1 do
	end
	for i,x in ipairs(xs) do
		local avg
		if i < rampLength then
			avg = math.floor(i/size)
		else
			avg = averages[i]
		end

	end
end

local turningPoints = function(diffs)
	local stdDev, mean = stdDev(diffs)
	local cutoff = stdDev
	local stdDevs = function(x)
		return x > (mean + stdDev)
	end
	print(stdDev,mean,unpack(_.map(diffs,stdDevs)))
	local chunked = chunks(diffs,goodChunkSize(diffs))
	return _.map(chunked,function(chunk)
		local isPos
		local turned = false
		_.each(chunk,function(diff)
			if isPos == nil then 
				isPos = diff >= 0
			else
				local hasTurned = isPos ~= (diff >= 0)
				if hasTurned then
					turned = true
				end
			end
		end)
		return turned
	end)
end

local near,far = "near","far"
local positiveThenNegative = "positiveThenNegative"

local gesturesByTurningPoints = {
	line = {
		xYRelation = far,
		x = { tp = 0 },
		y = { tp = 0 }
	},
	delta = {
		xYRelation = near,
		changePattern = positiveThenNegative, -- rules out 'u' shapes rather than 'n' shapes
		turningPoints = near,
		x = { tp = 1 },
		y = { tp = 1 }
	},
	circle = {
		xYRelation = near,
		x = { tp = 0 },
		y = { tp = 0 }
	},
	square = {
		xYRelation = far,
		turningPoints = far,
		x = { tp = 2 },
		y = { tp = 2 }
	}
}

local getX = function(point)
	return point[1]	
end
local getY = function(point)
	return point[2]	
end
local getXYDiff = function(point)
	return point[3]	
end

gestures.recognise = function(points)
	points = differences(points)
	local turningPointsX = turningPoints(_.map(points,getX))
	local turningPointsY = turningPoints(_.map(points,getY))
	print(string.format("x tps: %s, y tps: %s",#_.filter(turningPointsX,_.identity),#_.filter(turningPointsY,_.identity)))
	print(unpack(turningPointsX))
	print(unpack(turningPointsY))
end

local test_data = {
	vs = {
		{{50,366},{55,356},{60,349},{73,326},{103,275},{123,248},{137,224},{143,212},{148,203},{152,206},{154,211},{179,245},{200,269},{235,304},{262,328},{274,340},{276,345},{276,346}},
		{{51,384},{53,379},{57,365},{66,335},{74,310},{84,286},{95,261},{112,233},{124,218},{132,209},{135,206},{137,206},{143,225},{161,270},{176,304},{195,336},{205,357},{211,371},{212,377},{212,378}},
		{{63,381},{64,373},{67,360},{75,328},{85,287},{91,250},{95,231},{100,217},{106,204},{109,196},{110,194},{111,194},{115,200},{139,227},{167,262},{196,310},{226,367},{242,405},{248,426},{251,443},{252,445}}
	},
	os = {
		{{111,413},{107,409},{93,391},{81,372},{73,354},{70,335},{70,320},{75,305},{86,289},{102,275},{130,261},{171,250},{214,249},{232,250},{235,254},{237,271},{234,297},{225,331},{213,358},{199,376},{186,389},{170,397},{162,400},{158,401},},
	},
	square = {
		{{56,390},{56,388},{56,377},{56,362},{56,350},{56,332},{57,315},{60,296},{63,274},{65,263},{66,255},{67,247},{67,242},{68,238},{69,236},{70,235},{76,233},{96,230},{109,229},{126,228},{136,228},{144,228},{162,230},{180,234},{201,236},{224,240},{236,242},{239,243},{239,244},{239,249},{239,259},{239,277},{235,303},{231,334},{231,367},{234,391},{235,408},{235,416},{235,418},{235,420},{235,421},{233,422},{226,424},{207,424},{162,424},{97,417},{54,415},{25,411},{13,409},{9,408},}
	}

}

for name,tests in pairs(test_data) do
	print(name)
	for i,test in ipairs(tests) do
		gestures.recognise(test)
	end
	print("\n")
end


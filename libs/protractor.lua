--[=[
 * The $1 Unistroke Recognizer (JavaScript version)
 *
 *	Jacob O. Wobbrock, Ph.D.
 * 	The Information School
 *	University of Washington
 *	Seattle, WA 98195-2840
 *	wobbrock@uw.edu
 *
 *	Andrew D. Wilson, Ph.D.
 *	Microsoft Research
 *	One Microsoft Way
 *	Redmond, WA 98052
 *	awilson@microsoft.com
 *
 *	Yang Li, Ph.D.
 *	Department of Computer Science and Engineering
 * 	University of Washington
 *	Seattle, WA 98195-2840
 * 	yangli@cs.washington.edu
 *
 * The academic publication for the $1 recognizer, and what should be 
 * used to cite it, is:
 *
 *	Wobbrock, J.O., Wilson, A.D. and Li, Y. (2007). Gestures without 
 *	  libraries, toolkits or training: A $1 recognizer for user interface 
 *	  prototypes. Proceedings of the ACM Symposium on User Interface 
 *	  Software and Technology (UIST '07). Newport, Rhode Island (October 
 *	  7-10, 2007). York: ACM Press, pp. 159-168.
 *
 * The Protractor enhancement was separately published by Yang Li and programmed 
 * here by Jacob O. Wobbrock:
 *
 *	Li, Y. (2010). Protractor: A fast and accurate gesture
 *	  recognizer. Proceedings of the ACM Conference on Human
 *	  Factors in Computing Systems (CHI '10). Atlanta, Georgia
 *	  (April 10-15, 2010). York: ACM Press, pp. 2169-2172.
 *
 * This software is distributed under the "BSD License" agreement:
 *
 * Copyright (C) 2007-2012, Jacob O. Wobbrock, Andrew D. Wilson and Yang Li.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *    * Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *    * Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *    * Neither the names of the University of Washington nor Microsoft,
 *      nor the names of its contributors may be used to endorse or promote
 *      products derived from this software without specific prior written
 *      permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
 * IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Jacob O. Wobbrock OR Andrew D. Wilson
 * OR Yang Li BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
 * OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]=]

-- all globals become props of module
module("protractor", package.seeall)

require '../libs/splice'
require '../src/helpers'

local function Deg2Rad(d)
	return (d * math.pi / 180.0)
end

--
-- DollarRecognizer class constants
--
local NumUnistrokes = 16
local NumPoints = 64
local SquareSize = 250.0
local Diagonal = math.sqrt(SquareSize * SquareSize + SquareSize * SquareSize)
local HalfDiagonal = 0.5 * Diagonal
local AngleRange = Deg2Rad(45)
local AnglePrecision = Deg2Rad(2)
local Phi = 0.5 * (-1.0 + math.sqrt(5)) -- Golden Ratio

function Point(x, y) -- constructor
	return {X=x,Y=y}
end

local Origin = Point(0,0)

function Rectangle(x, y, width, height) -- constructor
	return {W=x,Y=y,Width=width,Height=height}
end

function Unistroke(name, points) -- constructor
	local this = {}
	this.Name = name
	this.Points = Resample(points, NumPoints)
	local radians = IndicativeAngle(this.Points)
	this.Points = RotateBy(this.Points, -radians)
	this.Points = ScaleTo(this.Points, SquareSize)
	this.Points = TranslateTo(this.Points, Origin)
	this.Vector = Vectorize(this.Points) -- for Protractor
	return this
end

function Result(name, score) -- constructor
	return {Name = name,Score = score}
end


--
-- Private helper functions from this point down
--
function Resample(points, n)
	-- divide total length by the length of our resampled path
	local I = PathLength(points) / (n - 1)
	local D = 0
	local newpoints = {points[1]}
	local i = 2
	local intervals = 0
	-- until we have enough points, resample
	while i < #points do
		local d = Distance(points[i - 1], points[i])
		if D + d >= I then
			local qx = points[i - 1].X + ((I - D) / d) * (points[i].X - points[i - 1].X)
			local qy = points[i - 1].Y + ((I - D) / d) * (points[i].Y - points[i - 1].Y)
			local q = Point(qx, qy)
			newpoints[#newpoints + 1] = q -- append new point 'q'
			Splice(points,i,0,q) -- ensure 'q' will be the next i
			D = 0
		else
			D = D + d
		end
		i = i + 1
	end
	if #newpoints == n - 1 then -- somtimes we fall a rounding-error short of adding the last point, so add it if so
		newpoints[#newpoints + 1] = Point(points[#points].X, points[#points].Y)
	end
	return newpoints
end

function IndicativeAngle(points)
	local c = Centroid(points)
	return math.atan2(c.Y - points[1].Y, c.X - points[1].X)
end

function RotateBy(points, radians) -- rotates points around centroid
	local c = Centroid(points)
	local cos = math.cos(radians)
	local sin = math.sin(radians)
	local newpoints = {}
	for i = 1, #points do
		local qx = (points[i].X - c.X) * cos - (points[i].Y - c.Y) * sin + c.X
		local qy = (points[i].X - c.X) * sin + (points[i].Y - c.Y) * cos + c.Y
		newpoints[#newpoints + 1] = Point(qx, qy)
	end
	return newpoints
end

function ScaleTo(points, size) -- non-uniform scale; assumes 2D gestures (i.e., no lines)
	local B = BoundingBox(points)
	local newpoints = {}
	for i = 1, #points do
		local qx = points[i].X * (size / B.Width)
		local qy = points[i].Y * (size / B.Height)
		newpoints[#newpoints + 1] = Point(qx, qy)
	end
	return newpoints
end

function TranslateTo(points, pt) -- translates points' centroid
	local c = Centroid(points)
	local newpoints = {}
	for i = 1, #points do
		local qx = points[i].X + pt.X - c.X
		local qy = points[i].Y + pt.Y - c.Y
		newpoints[#newpoints + 1] = Point(qx, qy)
	end
	return newpoints
end

function Vectorize(points) -- for Protractor
	local sum = 0.0
	local vector = {}
	for i = 1,#points do
		local point = points[i]
		vector[#vector + 1] = point.X
		vector[#vector + 1] = point.Y
		sum = sum + point.X * point.X + point.Y * point.Y
	end
	local magnitude = math.sqrt(sum)
	for i = 1, #vector do
		vector[i] = vector[i] / magnitude
	end
	return vector
end

function OptimalCosineDistance(v1, v2) -- for Protractor
	local a = 0.0
	local b = 0.0
	for i = 1, #v1, 2 do
		a = a + v1[i] * v2[i] + v1[i + 1] * v2[i + 1]
		b = b + v1[i] * v2[i + 1] - v1[i + 1] * v2[i]
	end
	local angle = math.atan(b / a)
	return math.acos(a * math.cos(angle) + b * math.sin(angle))
end

function DistanceAtBestAngle(points, T, a, b, threshold)
	local x1 = Phi * a + (1.0 - Phi) * b
	local f1 = DistanceAtAngle(points, T, x1)
	local x2 = (1.0 - Phi) * a + Phi * b
	local f2 = DistanceAtAngle(points, T, x2)
	while (math.abs(b - a) > threshold) do
		if (f1 < f2) then
			b = x2
			x2 = x1
			f2 = f1
			x1 = Phi * a + (1.0 - Phi) * b
			f1 = DistanceAtAngle(points, T, x1)
		else
			a = x1
			x1 = x2
			f1 = f2
			x2 = (1.0 - Phi) * a + Phi * b
			f2 = DistanceAtAngle(points, T, x2)
		end
	end
	return math.min(f1, f2)
end

function DistanceAtAngle(points, T, radians)
	local newpoints = RotateBy(points, radians)
	return PathDistance(newpoints, T.Points)
end

function Centroid(points)
	local x = 0.0
	local y = 0.0
	for i = 1, #points do
		x = x + points[i].X
		y = y + points[i].Y
	end
	x = x / #points
	y = y / #points
	return Point(x, y)
end

function BoundingBox(points)
	local minX = math.huge
	local maxX = -math.huge
	local minY = math.huge
	local maxY = -math.huge
	for i = 1, #points do
		minX = math.min(minX, points[i].X)
		minY = math.min(minY, points[i].Y)
		maxX = math.max(maxX, points[i].X)
		maxY = math.max(maxY, points[i].Y)
	end
	return Rectangle(minX, minY, maxX - minX, maxY - minY)
end

function PathDistance(pts1, pts2)
	local d = 0.0
	for i = 1, #pts1 do -- assumes pts1.length == pts2.length
		d = d + Distance(pts1[i], pts2[i])
	end
	return d / #pts1
end

function PathLength(points)
	local d = 0.0
	for i = 2, #points do
		d = d + Distance(points[i - 1], points[i])
	end
	return d
end

function Distance(p1, p2)
	local dx = p2.X - p1.X
	local dy = p2.Y - p1.Y
	return math.sqrt(dx * dx + dy * dy)
end


--
-- DollarRecognizer class
--
function DollarRecognizer() -- constructor
	local this = {}
	--
	-- one built-in unistroke per gesture type
	--
	this.Unistrokes = {}
	this.Unistrokes[1] = Unistroke("rectangle", {Point(78,149),Point(78,153),Point(78,157),Point(78,160),Point(79,162),Point(79,164),Point(79,167),Point(79,169),Point(79,173),Point(79,178),Point(79,183),Point(80,189),Point(80,193),Point(80,198),Point(80,202),Point(81,208),Point(81,210),Point(81,216),Point(82,222),Point(82,224),Point(82,227),Point(83,229),Point(83,231),Point(85,230),Point(88,232),Point(90,233),Point(92,232),Point(94,233),Point(99,232),Point(102,233),Point(106,233),Point(109,234),Point(117,235),Point(123,236),Point(126,236),Point(135,237),Point(142,238),Point(145,238),Point(152,238),Point(154,239),Point(165,238),Point(174,237),Point(179,236),Point(186,235),Point(191,235),Point(195,233),Point(197,233),Point(200,233),Point(201,235),Point(201,233),Point(199,231),Point(198,226),Point(198,220),Point(196,207),Point(195,195),Point(195,181),Point(195,173),Point(195,163),Point(194,155),Point(192,145),Point(192,143),Point(192,138),Point(191,135),Point(191,133),Point(191,130),Point(190,128),Point(188,129),Point(186,129),Point(181,132),Point(173,131),Point(162,131),Point(151,132),Point(149,132),Point(138,132),Point(136,132),Point(122,131),Point(120,131),Point(109,130),Point(107,130),Point(90,132),Point(81,133),Point(76,133)})
	this.Unistrokes[2] = Unistroke("triangle",{Point(137,139),Point(135,141),Point(133,144),Point(132,146),Point(130,149),Point(128,151),Point(126,155),Point(123,160),Point(120,166),Point(116,171),Point(112,177),Point(107,183),Point(102,188),Point(100,191),Point(95,195),Point(90,199),Point(86,203),Point(82,206),Point(80,209),Point(75,213),Point(73,213),Point(70,216),Point(67,219),Point(64,221),Point(61,223),Point(60,225),Point(62,226),Point(65,225),Point(67,226),Point(74,226),Point(77,227),Point(85,229),Point(91,230),Point(99,231),Point(108,232),Point(116,233),Point(125,233),Point(134,234),Point(145,233),Point(153,232),Point(160,233),Point(170,234),Point(177,235),Point(179,236),Point(186,237),Point(193,238),Point(198,239),Point(200,237),Point(202,239),Point(204,238),Point(206,234),Point(205,230),Point(202,222),Point(197,216),Point(192,207),Point(186,198),Point(179,189),Point(174,183),Point(170,178),Point(164,171),Point(161,168),Point(154,160),Point(148,155),Point(143,150),Point(138,148),Point(136,148)})
	this.Unistrokes[3] = Unistroke("circle", {Point(127,141),Point(124,140),Point(120,139),Point(118,139),Point(116,139),Point(111,140),Point(109,141),Point(104,144),Point(100,147),Point(96,152),Point(93,157),Point(90,163),Point(87,169),Point(85,175),Point(83,181),Point(82,190),Point(82,195),Point(83,200),Point(84,205),Point(88,213),Point(91,216),Point(96,219),Point(103,222),Point(108,224),Point(111,224),Point(120,224),Point(133,223),Point(142,222),Point(152,218),Point(160,214),Point(167,210),Point(173,204),Point(178,198),Point(179,196),Point(182,188),Point(182,177),Point(178,167),Point(170,150),Point(163,138),Point(152,130),Point(143,129),Point(140,131),Point(129,136),Point(126,139)})
	this.Unistrokes[4] = Unistroke("caret", {Point(79,245),Point(79,242),Point(79,239),Point(80,237),Point(80,234),Point(81,232),Point(82,230),Point(84,224),Point(86,220),Point(86,218),Point(87,216),Point(88,213),Point(90,207),Point(91,202),Point(92,200),Point(93,194),Point(94,192),Point(96,189),Point(97,186),Point(100,179),Point(102,173),Point(105,165),Point(107,160),Point(109,158),Point(112,151),Point(115,144),Point(117,139),Point(119,136),Point(119,134),Point(120,132),Point(121,129),Point(122,127),Point(124,125),Point(126,124),Point(129,125),Point(131,127),Point(132,130),Point(136,139),Point(141,154),Point(145,166),Point(151,182),Point(156,193),Point(157,196),Point(161,209),Point(162,211),Point(167,223),Point(169,229),Point(170,231),Point(173,237),Point(176,242),Point(177,244),Point(179,250),Point(181,255),Point(182,257)})

	this.Unistrokes[5] = Unistroke("line",{
		Point(100,10),Point(100,20),Point(100,30),Point(100,40),Point(100,50),Point(100,60),Point(100,70),Point(100,80),Point(100,90),Point(100,100),Point(100,110),Point(100,120),Point(100,130),Point(100,140),Point(100,150),Point(100,160),Point(100,170),Point(100,180),Point(100,190),Point(100,200),Point(100,210),Point(100,220),Point(100,230),Point(100,240),Point(100,250),Point(100,260),Point(100,270),Point(100,280),Point(100,290),Point(100,300),Point(100,310),Point(100,320),Point(100,330),Point(100,340),Point(100,350),Point(100,360),Point(100,370),Point(100,380),Point(100,390),Point(100,400),Point(100,410),Point(100,420),Point(100,430),Point(100,440),Point(100,450),Point(100,460),Point(100,470),Point(100,480),Point(100,490),Point(100,500),Point(100,510),Point(100,520),Point(100,530),Point(100,540),Point(100,550),Point(100,560),Point(100,570),Point(100,580),Point(100,590),Point(100,600),Point(100,610),Point(100,620),Point(100,630),Point(100,640)
	})
	--
	-- The $1 Gesture Recognizer API begins here -- 3 methods: Recognize(), AddGesture(), and DeleteUserGestures()
	--
	this.Recognize = function(points, useProtractor)
		points = Resample(points, NumPoints)
		local radians = IndicativeAngle(points)
		points = RotateBy(points, -radians)
		points = ScaleTo(points, SquareSize)
		points = TranslateTo(points, Origin)
		local vector = Vectorize(points) -- for Protractor

		local b = math.huge
		local u = -1
		for i = 1, #this.Unistrokes do -- for each unistroke
			local d
			if (useProtractor) then -- for Protractor
				d = OptimalCosineDistance(this.Unistrokes[i].Vector, vector)
			else -- Golden Section Search (original $1)
				d = DistanceAtBestAngle(points, this.Unistrokes[i], -AngleRange, AngleRange, AnglePrecision)
			end
			if (d < b) then
				b = d -- best (least) distance
				u = i -- unistroke
			end
		end
		if (u == -1) then
			return Result("No match.", 0.0)
		else
			local x = 0
			if useProtractor then
				x = 1.0 / b
			else
				x = 1.0 - b / HalfDiagonal
			end
			return Result(this.Unistrokes[u].Name, x)
		end
	end

	this.AddGesture = function(name, points)
		this.Unistrokes[#this.Unistrokes + 1] = Unistroke(name, points) -- append unistroke
		local num = 0
		for i = 1, #Unistrokes do
			if (this.Unistrokes[i].Name == name) then
				num = num + 1
			end
		end
		return num
	end

	this.DeleteUserGestures = function()
		-- this.Unistrokes.length = NumUnistrokes -- clear any beyond the original set
		-- I suppose the equivalent of resetting an array in Lua is:
		for k, v in pairs(this.Unistrokes) do
			this.Unistrokes[k] = nil
		end
		return NumUnistrokes
	end
	return this
end


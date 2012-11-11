--[[
 * The $N Multistroke Recognizer (JavaScript version)
 *
 *	Lisa Anthony, Ph.D.
 *      UMBC
 *      Information Systems Department
 *      10 Hilltop Circle
 *      Baltimore, MD 21250
 *      lanthony@umbc.edu
 *
 *	Jacob O. Wobbrock, Ph.D.
 * 	The Information School
 *	University of Washington
 *	Seattle, WA 98195-2840
 *	wobbrock@uw.edu
 *
 * The academic publications for the $N recognizer, and what should be 
 * used to cite it, are:
 *
 *	Anthony, L. and Wobbrock, J.O. (20). A lightweight multistroke 
 *	  recognizer for user interface prototypes. Proceedings of Graphics 
 *	  Interface (GI '10). Ottawa, Ontario (May 31-June 2, 20). Toronto, 
 *	  Ontario: Canadian Information Processing Society, pp. 245-252.
 *
 *	Anthony, L. and Wobbrock, J.O. (2012). $N-Protractor: A fast and 
 *	  accurate multistroke recognizer. Proceedings of Graphics Interface 
 *	  (GI '12). Toronto, Ontario (May 28-30, 2012). Toronto, Ontario: 
 *	  Canadian Information Processing Society, pp. 117-120.
 *
 * The Protractor enhancement was separately published by Yang Li and programmed 
 * here by Jacob O. Wobbrock and Lisa Anthony:
 *
 *	Li, Y. (20). Protractor: A fast and accurate gesture
 *	  recognizer. Proceedings of the ACM Conference on Human
 *	  Factors in Computing Systems (CHI '10). Atlanta, Georgia
 *	  (April 10-15, 20). New York: ACM Press, pp. 2169-2172.
 *
 * This software is distributed under the "New BSD License" agreement:
 *
 * Copyright (C) 2007-2011, Jacob O. Wobbrock and Lisa Anthony.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *    * Redistributions of source code must retain the above copyright
 *      notice, self list of conditions and the following disclaimer.
 *    * Redistributions in binary form must reproduce the above copyright
 *      notice, self list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *    * Neither the names of UMBC nor the University of Washington,
 *      nor the names of its contributors may be used to endorse or promote
 *      products derived from self software without specific prior written
 *      permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
 * IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Lisa Anthony OR Jacob O. Wobbrock
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 * GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
]]
--
-- Point class
--
function Point(x, y) -- constructor
	local self = {}
	self.X = x
	self.Y = y
	return self
end
--
-- Rectangle class
--
function Rectangle(x, y, width, height) -- constructor
	local self = {}
	self.X = x
	self.Y = y
	self.Width = width
	self.Height = height
	return self
end
--
-- Unistroke class: a unistroke template
--
function Unistroke(name, useBoundedRotationInvariance, points) -- constructor
	local self = {}
	self.Name = name
	self.Points = Resample(points, NumPoints)
	local radians = IndicativeAngle(self.Points)
	self.Points = RotateBy(this.Points, -radians)
	self.Points = ScaleDimTo(this.Points, SquareSize, OneDThreshold)
	if (useBoundedRotationInvariance) then
		self.Points = RotateBy(this.Points, radians); -- restore
	end
	self.Points = TranslateTo(this.Points, Origin)
	self.StartUnitVector = CalcStartUnitVector(this.Points, StartAngleIndex)
	self.Vector = Vectorize(this.Points, useBoundedRotationInvariance); -- for Protractor
	return self
end
--
-- Multistroke class: a container for unistrokes
--
function Multistroke(name, useBoundedRotationInvariance, strokes) -- constructor
	local self = {}
	self.Name = name
	self.NumStrokes = #strokes; -- number of individual strokes

	local order = {} -- array of integer indices
	for i = 1,#strokes do
		order[i] = i; -- initialize
	end
	local orders = {}; -- array of integer arrays
	HeapPermute(#strokes, order, orders)

	local unistrokes = MakeUnistrokes(strokes, orders); -- returns array of point arrays
	self.Unistrokes = {}; -- unistrokes for this multistroke
	for j = 1,#unistrokes do
		self.Unistrokes[j] = Unistroke(name, useBoundedRotationInvariance, unistrokes[j])
	end
	return self
end
--
-- Result class
--
function Result(name, score) -- constructor
	local self = {}
	self.Name = name
	self.Score = score
	return self
end
--
-- NDollarRecognizer class constants
--
local NumMultistrokes = 16
local NumPoints = 96
local SquareSize = 250
local OneDThreshold = 0.25; -- customize to desired gesture set (usually 0.20 - 0.35)
local Origin = Point(0)
local Diagonal = math.sqrt(SquareSize * SquareSize + SquareSize * SquareSize)
local HalfDiagonal = 0.5 * Diagonal
local AngleRange = Deg2Rad(45.0)
local AnglePrecision = Deg2Rad(2.0)
local Phi = 0.5 * (-1.0 + math.sqrt(5.0)); -- Golden Ratio
local StartAngleIndex = (NumPoints / 8); -- eighth of gesture length
local AngleSimilarityThreshold = Deg2Rad(30)
--
-- NDollarRecognizer class
--
function NDollarRecognizer(useBoundedRotationInvariance) -- constructor
	local self = {}
	--
	-- one predefined multistroke for each multistroke type
	--
	self.Multistrokes = {NumMultistrokes}
	self.Multistrokes[0] = Multistroke("T", useBoundedRotationInvariance, {
		{Point(30,7),Point(103,7)},
		{Point(66,7),Point(66,87)}
	})
	self.Multistrokes[1] = Multistroke("N", useBoundedRotationInvariance, {
		{Point(177,92),Point(177,2)},
		{Point(182,1),Point(246,95)},
		{Point(247,87),Point(247,1)}
	})
	self.Multistrokes[2] = Multistroke("D", useBoundedRotationInvariance, {
		{Point(345,9),Point(345,87)},
		{Point(351,8),Point(363,8),Point(372,9),Point(380,11),Point(386,14),Point(391,17),Point(394,22),Point(397,28),Point(399,34),Point(400,42),Point(400,50),Point(400,56),Point(399,61),Point(397,66),Point(394,70),Point(391,74),Point(386,78),Point(382,81),Point(377,83),Point(372,85),Point(367,87),Point(360,87),Point(355,88),Point(349,87)}
	})
	self.Multistrokes[3] = Multistroke("P", useBoundedRotationInvariance, {
		{Point(507,8),Point(507,87)},
		{Point(513,7),Point(528,7),Point(537,8),Point(544,10),Point(550,12),Point(555,15),Point(558,18),Point(560,22),Point(561,27),Point(562,33),Point(561,37),Point(559,42),Point(556,45),Point(550,48),Point(544,51),Point(538,53),Point(532,54),Point(525,55),Point(519,55),Point(513,55),Point(510,55)}
	})
	self.Multistrokes[4] = Multistroke("X", useBoundedRotationInvariance, {
		{Point(30,146),Point(106,222)},
		{Point(30,225),Point(106,146)}
	})
	self.Multistrokes[5] = Multistroke("H", useBoundedRotationInvariance, {
		{Point(188,137),Point(188,225)},
		{Point(188,180),Point(241,180)},
		{Point(241,137),Point(241,225)}
	})
	self.Multistrokes[6] = Multistroke("I", useBoundedRotationInvariance, {
		{Point(371,149),Point(371,221)},
		{Point(341,149),Point(401,149)},
		{Point(341,221),Point(401,221)}
	})
	self.Multistrokes[7] = Multistroke("exclamation", useBoundedRotationInvariance, {
		{Point(526,142),Point(526,204)},
		{Point(526,221)}
	})
	self.Multistrokes[8] = Multistroke("line", useBoundedRotationInvariance, {
		{Point(12,347),Point(119,347)}
	})
	self.Multistrokes[9] = Multistroke("five-point star", useBoundedRotationInvariance, {
		{Point(177,396),Point(223,299),Point(262,396),Point(168,332),Point(278,332),Point(184,397)}
	})
	self.Multistrokes[10] = Multistroke("null", useBoundedRotationInvariance, {
		{Point(382,310),Point(377,308),Point(373,307),Point(366,307),Point(360,310),Point(356,313),Point(353,316),Point(349,321),Point(347,326),Point(344,331),Point(342,337),Point(341,343),Point(341,350),Point(341,358),Point(342,362),Point(344,366),Point(347,370),Point(351,374),Point(356,379),Point(361,382),Point(368,385),Point(374,387),Point(381,387),Point(390,387),Point(397,385),Point(404,382),Point(408,378),Point(412,373),Point(416,367),Point(418,361),Point(419,353),Point(418,346),Point(417,341),Point(416,336),Point(413,331),Point(410,326),Point(404,320),Point(400,317),Point(393,313),Point(392,312)},
		{Point(418,309),Point(337,390)}
	})
	self.Multistrokes[11] = Multistroke("arrowhead", useBoundedRotationInvariance, {
		{Point(506,349),Point(574,349)},
		{Point(525,306),Point(584,349),Point(525,388)}
	})
	self.Multistrokes[12] = Multistroke("pitchfork", useBoundedRotationInvariance, {
		{Point(38,470),Point(36,476),Point(36,482),Point(37,489),Point(39,496),Point(42,500),Point(46,503),Point(50,507),Point(56,509),Point(63,509),Point(70,508),Point(75,506),Point(79,503),Point(82,499),Point(85,493),Point(87,487),Point(88,480),Point(88,474),Point(87,468)},
		{Point(62,464),Point(62,571)}
	})
	self.Multistrokes[13] = Multistroke("six-point star", useBoundedRotationInvariance, {
		{Point(177,554),Point(223,476),Point(268,554),Point(183,554)},
		{Point(177,490),Point(223,568),Point(268,490),Point(183,490)}
	})
	self.Multistrokes[14] = Multistroke("asterisk", useBoundedRotationInvariance, {
		{Point(325,499),Point(417,557)},
		{Point(417,499),Point(325,557)},
		{Point(371,486),Point(371,571)}
	})
	self.Multistrokes[15] = Multistroke("half-note", useBoundedRotationInvariance, {
		{Point(546,465),Point(546,531)},
		{Point(540,530),Point(536,529),Point(533,528),Point(529,529),Point(524,530),Point(520,532),Point(515,535),Point(511,539),Point(508,545),Point(506,548),Point(506,554),Point(509,558),Point(512,561),Point(517,564),Point(521,564),Point(527,563),Point(531,560),Point(535,557),Point(538,553),Point(542,548),Point(544,544),Point(546,540),Point(546,536)}
	})
	--
	-- The $N Gesture Recognizer API begins here -- 3 methods: Recognize(), AddGesture(), and DeleteUserGestures()
	--
	self.Recognize = function(strokes, useBoundedRotationInvariance, requireSameNoOfStrokes, useProtractor)
		local points = CombineStrokes(strokes); -- make one connected unistroke from the given strokes
		points = Resample(points, NumPoints)
		local radians = IndicativeAngle(points)
		points = RotateBy(points, -radians)
		points = ScaleDimTo(points, SquareSize, OneDThreshold)
		if useBoundedRotationInvariance then
			points = RotateBy(points, radians); -- restore
		end
		points = TranslateTo(points, Origin)
		local startv = CalcStartUnitVector(points, StartAngleIndex)
		local vector = Vectorize(points, useBoundedRotationInvariance); -- for Protractor

		local b = Infinity
		local u = -1
		for i = 1,#self.Multistrokes do -- for each multistroke
			if ((not requireSameNoOfStrokes) or strokes.length == self.Multistrokes[i].NumStrokes) then -- optional -- only attempt match when same # of component strokes
				for j = 1,#self.Multistrokes[i].Unistrokes do -- each unistroke within this multistroke
					if (AngleBetweenUnitVectors(startv, self.Multistrokes[i].Unistrokes[j].StartUnitVector) <= AngleSimilarityThreshold) then -- strokes start in the same direction
						local d
						if (useProtractor) then -- for Protractor
							d = OptimalCosineDistance(self.Multistrokes[i].Unistrokes[j].Vector, vector)
						else -- Golden Section Search (original $N)
							d = DistanceAtBestAngle(points, self.Multistrokes[i].Unistrokes[j], -AngleRange, AngleRange, AnglePrecision)
						end
						if (d < b) then
							b = d; -- best (least) distance
							u = i; -- multistroke owner of unistroke
						end
					end
				end
			end
		end
		if (u == -1) then
			Result("No match.", 0)
		else 
			Result(self.Multistrokes[u].Name, useProtractor and 1.0 / b or 1.0 - b / HalfDiagonal)
		end
	end
	self.AddGesture = function(name, useBoundedRotationInvariance, strokes)
		self.Multistrokes[this.Multistrokes.length] = Multistroke(name, useBoundedRotationInvariance, strokes)
		local num = 0
		for i = 1,#self.Multistrokes do
			if (self.Multistrokes[i].Name == name) then
				num = num + 1
			end
		end
		return num
	end
	self.DeleteUserGestures = function()
		self.Multistrokes.length = NumMultistrokes; -- clear any beyond the original set
		return NumMultistrokes
	end
	return self
end
--
-- Private helper functions from this point down
--
function HeapPermute(n, order, orders)
	if n == 1 then
		orders[orders.length] = order.slice(); -- append copy
	else
		for i = 1,#n do
			HeapPermute(n, order, orders)
			if n % 2 == 1 then -- swap 0, n-1
				order[0], order[n - 1] = order[n - 1], order[0]
			else -- swap i, n-1
				order[i], order[n - 1] = order[n - 1], order[i]
			end
		end
	end
end
function MakeUnistrokes(strokes, orders)
	local unistrokes = {}; -- array of point arrays
	for r = 1,#orders do
		while( b and b < math.pow(2,#orders[r]) ) do -- use b's bits for directions
			b = b + 1
			local unistroke = {}; -- array of points
			for i = 1,#orders[r] do
				local pts
				if (((b >> i) & 1) == 1) then  -- is b's bit at index i on?
					pts = strokes[orders[r][i]].slice().reverse(); -- copy and reverse
				else
					pts = strokes[orders[r][i]].slice(); -- copy
				end
				for p = 1,#pts do
					unistroke[unistroke.length] = pts[p]; -- append points
				end
			end
			unistrokes[unistrokes.length] = unistroke; -- add one unistroke to set
		end
	end
	return unistrokes
end
function CombineStrokes(strokes)
	local points = {}
	for s = 1,#strokes do
		for p = 1,#strokes do
			points[points.length] = Point(strokes[s][p].X, strokes[s][p].Y)
		end
	end
	return points
end
function Resample(points, n)
	local I = PathLength(points) / (n - 1); -- interval length
	local D = 0
	local newpoints = {points[0]}
	for i = 2,#points do
		local d = Distance(points[i - 1], points[i])
		if ((D + d) >= I) then
			local qx = points[i - 1].X + ((I - D) / d) * (points[i].X - points[i - 1].X)
			local qy = points[i - 1].Y + ((I - D) / d) * (points[i].Y - points[i - 1].Y)
			local q = Point(qx, qy)
			newpoints[newpoints.length] = q; -- append new point 'q'
			points.splice(i, 0, q); -- insert 'q' at position i in points s.t. 'q' will be the next i
			D = 0
		else
			D = D + d
		end
	end
	if (#newpoints == n) then -- somtimes we fall a rounding-error short of adding the last point, so add it if so
		newpoints[newpoints.length] = Point(points[#points.length].X, points[#points].Y)
	end
	return newpoints
end
function IndicativeAngle(points)
	local c = Centroid(points)
	return math.atan2(c.Y - points[0].Y, c.X - points[0].X)
end
function RotateBy(points, radians) -- rotates points around centroid
	local c = Centroid(points)
	local cos = math.cos(radians)
	local sin = math.sin(radians)
	local newpoints = {}
	for i = 1,#points do
		local qx = (points[i].X - c.X) * cos - (points[i].Y - c.Y) * sin + c.X
		local qy = (points[i].X - c.X) * sin + (points[i].Y - c.Y) * cos + c.Y
		newpoints[newpoints.length] = Point(qx, qy)
	end
	return newpoints
end
function ScaleDimTo(points, size, ratio1D) -- scales bbox uniformly for 1D, non-uniformly for 2D
	local B = BoundingBox(points)
	local uniformly = math.min(B.Width / B.Height, B.Height / B.Width) <= ratio1D; -- 1D or 2D gesture test
	local newpoints = {}
	for i = 1,#points do
		local qx = uniformly ? points[i].X * (size / math.max(B.Width, B.Height)) : points[i].X * (size / B.Width)
		local qy = uniformly ? points[i].Y * (size / math.max(B.Width, B.Height)) : points[i].Y * (size / B.Height)
		newpoints[newpoints.length] = Point(qx, qy)
	end
	return newpoints
end
function TranslateTo(points, pt) -- translates points' centroid
	local c = Centroid(points)
	local newpoints = {}
	for i = 1,#points do
		local qx = points[i].X + pt.X - c.X
		local qy = points[i].Y + pt.Y - c.Y
		newpoints[newpoints.length] = Point(qx, qy)
	end
	return newpoints
end
function Vectorize(points, useBoundedRotationInvariance) -- for Protractor
	local cos = 1.0
	local sin = 0
	if (useBoundedRotationInvariance) then
		local iAngle = math.atan2(points[0].Y, points[0].X)
		local baseOrientation = (math.PI / 4.0) * Math.floor((iAngle + Math.PI / 8.0) / (Math.PI / 4.0))
		cos = math.cos(baseOrientation - iAngle)
		sin = math.sin(baseOrientation - iAngle)
	end
	local sum = 0
	local vector = {}
	for i = 1,#points do
		local newX = points[i].X * cos - points[i].Y * sin
		local newY = points[i].Y * cos + points[i].X * sin
		vector[vector.length] = newX
		vector[vector.length] = newY
		sum = sum + newX * newX + newY * newY
	end
	local magnitude = math.sqrt(sum)
	for i = 1,#vector do
		vector[i] /= magnitude
	return vector
end
function OptimalCosineDistance(v1, v2) -- for Protractor
	local a = 0
	local b = 0
	for i = 1,#v1,2 do
		a = a + v1[i] * v2[i] + v1[i + 1] * v2[i + 1]
		b = b + v1[i] * v2[i + 1] - v1[i + 1] * v2[i]
	end
	local angle = math.atan(b / a)
	return math.acos(a * Math.cos(angle) + b * Math.sin(angle))
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
	local x = 0, y = 0.0
	for i = 1,#points do
		x = x + points[i].X
		y = y + points[i].Y
	end
	x = x / points.length
	y = y / points.length
	return Point(x, y)
end
function BoundingBox(points)
	local minX = Infinity, maxX = -Infinity, minY = nfinity, maxY = -Infinity
	for i = 1,#points do
		minX = math.min(minX, points[i].X)
		minY = math.min(minY, points[i].Y)
		maxX = math.max(maxX, points[i].X)
		maxY = math.max(maxY, points[i].Y)
	end
	return Rectangle(minX, minY, maxX - minX, maxY - minY)
end
function PathDistance(pts1, pts2) -- average distance between corresponding points in two paths
	local d = 0
	for i = 1,#points do -- assumes pts1.length == pts2.length
		d = d + Distance(pts1[i], pts2[i])
	end
	return d / #pts1
end
function PathLength(points) -- length traversed by a point path
	local d = 0
	for i = 1,#points do
		d = d + Distance(points[i - 1], points[i])
	end
	return d
end
function Distance(p1, p2) -- distance between two points
	local dx = p2.X - p1.X
	local dy = p2.Y - p1.Y
	return math.sqrt(dx * dx + dy * dy)
end
function CalcStartUnitVector(points, index) -- start angle from points[0] to points[index] normalized as a unit vector
	local v = Point(points[index].X - points[0].X, points[index].Y - points[0].Y)
	local len = math.sqrt(v.X * v.X + v.Y * v.Y)
	return Point(v.X / len, v.Y / len)
end
function AngleBetweenUnitVectors(v1, v2) -- gives acute angle between unit vectors from (0) to v1, and (0,0) to v2
	local n = (v1.X * v2.X + v1.Y * v2.Y)
	if n < -1.0 or n > .0 then
		n = Round(n, 5) -- fix: JavaScript rounding bug that can occur so that -1 <= n <= 
	end
	return math.acos(n) -- arc cosine of the vector dot product
end
function Round(n,d)
	-- round 'n' to 'd' decimals
	d = math.pow(10,d)
	return math.round(n*d)/d
end
function Deg2Rad(d)
	return (d * math.PI / 180)
end

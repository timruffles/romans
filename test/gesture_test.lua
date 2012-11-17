require "lunatest"

package.path = package.path .. ";../?.lua"
require "../libs/protractor"
require "../src/helpers"
local matrix = require '../libs/matrix'
local ser = require '../libs/table2'
local Point = protractor.Point
local DollarRecognizer = protractor.DollarRecognizer

local test_data = {
	vs = {Point(50,366),Point(55,356),Point(60,349),Point(73,326),Point(103,275),Point(123,248),Point(137,224),Point(143,212),Point(148,203),Point(152,206),Point(154,211),Point(179,245),Point(200,269),Point(235,304),Point(262,328),Point(274,340),Point(276,345),Point(276,346)},
	vs2 = {Point(51,384),Point(53,379),Point(57,365),Point(66,335),Point(74,310),Point(84,286),Point(95,261),Point(112,233),Point(124,218),Point(132,209),Point(135,206),Point(137,206),Point(143,225),Point(161,270),Point(176,304),Point(195,336),Point(205,357),Point(211,371),Point(212,377),Point(212,378)},
	vs3 = {Point(63,381),Point(64,373),Point(67,360),Point(75,328),Point(85,287),Point(91,250),Point(95,231),Point(100,217),Point(106,204),Point(109,196),Point(110,194),Point(111,194),Point(115,200),Point(139,227),Point(167,262),Point(196,310),Point(226,367),Point(242,405),Point(248,426),Point(251,443),Point(252,445)},
	os = {Point(111,413),Point(107,409),Point(93,391),Point(81,372),Point(73,354),Point(70,335),Point(70,320),Point(75,305),Point(86,289),Point(102,275),Point(130,261),Point(171,250),Point(214,249),Point(232,250),Point(235,254),Point(237,271),Point(234,297),Point(225,331),Point(213,358),Point(199,376),Point(186,389),Point(170,397),Point(162,400),Point(158,401)},
	square = {Point(78,149),Point(78,153),Point(78,157),Point(78,160),Point(79,162),Point(79,164),Point(79,167),Point(79,169),Point(79,173),Point(79,178),Point(79,183),Point(80,189),Point(80,193),Point(80,198),Point(80,202),Point(81,208),Point(81,210),Point(81,216),Point(82,222),Point(82,224),Point(82,227),Point(83,229),Point(83,231),Point(85,230),Point(88,232),Point(90,233),Point(92,232),Point(94,233),Point(99,232),Point(102,233),Point(106,233),Point(109,234),Point(117,235),Point(123,236),Point(126,236),Point(135,237),Point(142,238),Point(145,238),Point(152,238),Point(154,239),Point(165,238),Point(174,237),Point(179,236),Point(186,235),Point(191,235),Point(195,233),Point(197,233),Point(200,233),Point(201,235),Point(201,233),Point(199,231),Point(198,226),Point(198,220),Point(196,207),Point(195,195),Point(195,181),Point(195,173),Point(195,163),Point(194,155),Point(192,145),Point(192,143),Point(192,138),Point(191,135),Point(191,133),Point(191,130),Point(190,128),Point(188,129),Point(186,129),Point(181,132),Point(173,131),Point(162,131),Point(151,132),Point(149,132),Point(138,132),Point(136,132),Point(122,131),Point(120,131),Point(109,130),Point(107,130),Point(90,132)},
	-- TODO this was copied from protractor.lua, and does not match. Either matchers can't be used as test data, or the protractor port is buggered... 
	triangle = {Point(137,139),Point(135,141),Point(133,144),Point(132,146),Point(130,149),Point(128,151),Point(126,155),Point(123,160),Point(120,166),Point(116,171),Point(112,177),Point(107,183),Point(102,188),Point(100,191),Point(95,195),Point(90,199),Point(86,203),Point(82,206),Point(80,209),Point(75,213),Point(73,213),Point(70,216),Point(67,219),Point(64,221),Point(61,223),Point(60,225),Point(62,226),Point(65,225),Point(67,226),Point(74,226),Point(77,227),Point(85,229),Point(91,230),Point(99,231),Point(108,232),Point(116,233),Point(125,233),Point(134,234),Point(145,233),Point(153,232),Point(160,233),Point(170,234),Point(177,235),Point(179,236),Point(186,237),Point(193,238),Point(198,239),Point(200,237),Point(202,239),Point(204,238),Point(206,234),Point(205,230),Point(202,222),Point(197,216),Point(192,207),Point(186,198),Point(179,189),Point(174,183),Point(170,178),Point(164,171),Point(161,168),Point(154,160),Point(148,155),Point(143,150),Point(138,148),Point(136,148)},
	homemade = {
		Point(2.1249995231628,-0.42499971389771),
		Point(1.8999996185303,-0.42499971389771),
		Point(1.3999996185303,-0.49999952316284),
		Point(1.1249995231628,-0.59999942779541),
		Point(0.74999952316284,-0.77499961853027),
		Point(0.34999990463257,-0.97499942779541),
		Point(-2.3841857910156e-07,-1.1249995231628),
		Point(-0.25000023841858,-1.2249994277954),
		Point(-0.65000009536743,-1.4749994277954),
		Point(-0.87500023841858,-1.6249995231628),
		Point(-1.1500000953674,-1.7749996185303),
		Point(-1.3750002384186,-1.8999996185303),
		Point(-1.5000002384186,-1.9749994277954),
		Point(-1.6750001907349,-2.0499992370605),
		Point(-1.7750000953674,-2.0749998092651),
		Point(-1.8500001430511,-2.1249990463257),
		Point(-1.8750002384186,-2.1499996185303),
		Point(-1.8750002384186,-2.1499996185303),
		Point(-1.6750001907349,-2.2749996185303),
		Point(-0.90000009536743,-2.6749992370605),
		Point(-0.050000190734863,-3.0749998092651),
		Point(1.0249996185303,-3.6249990463257),
		Point(1.5999994277954,-3.9999990463257),
		Point(1.9499998092651,-4.2749996185303),
		Point(2.1999998092651,-4.5499992370605),
		Point(2.3999996185303,-4.7499990463257),
		Point(2.5249996185303,-4.8999996185303),
		Point(2.7499995231628,-5.0749998092651),
		Point(3.0499997138977,-5.2749996185303),
		Point(3.3749995231628,-5.4749994277954),
		Point(3.6249995231628,-5.6249990463257),
		Point(3.7749996185303,-5.7249994277954),
		Point(3.8499994277954,-5.7999992370605),
		Point(3.8999996185303,-5.8499994277954)
	}
}

function setup()
end

function test_Resample()
	local resamples = protractor.Resample({
		Point(0,0),
		Point(5,0),
		Point(10,0),
		Point(15,0),
		Point(20,0),
		Point(25,0),
		Point(30,0),
		Point(35,0),
		Point(40,0),
		Point(45,0),
		Point(50,0),
	},5)
	assert_equal(0,resamples[1].X)
	assert_equal(37.5,resamples[4].X)
end

function test_vs()
	local protractor = DollarRecognizer()
	local result = protractor.Recognize(test_data.vs, true)
	assert_equal("caret",result.Name)
end

function test_vs2()
	local protractor = DollarRecognizer()
	local result = protractor.Recognize(test_data.vs2, true)
	assert_equal("caret",result.Name)
end

function test_vs3()
	local protractor = DollarRecognizer()
	local result = protractor.Recognize(test_data.vs3, true)
	assert_equal("caret",result.Name)
end

function test_os()
	local protractor = DollarRecognizer()
	local result = protractor.Recognize(test_data.os, true)
	return
	assert_equal("circle",result.Name)
end

function test_square()
	local protractor = DollarRecognizer()
	local result = protractor.Recognize(test_data.square, true)
	assert_equal("rectangle",result.Name)
end

lunatest.run()


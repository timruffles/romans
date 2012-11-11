require "lunatest"

package.path = package.path .. ";../?.lua"
require "../libs/protractor"
local matrix = require '../libs/matrix'
local ser = require '../libs/table2'

local test_data = {
	vs = {Point(50,366),Point(55,356),Point(60,349),Point(73,326),Point(103,275),Point(123,248),Point(137,224),Point(143,212),Point(148,203),Point(152,206),Point(154,211),Point(179,245),Point(200,269),Point(235,304),Point(262,328),Point(274,340),Point(276,345),Point(276,346)},
	vs2 = {Point(51,384),Point(53,379),Point(57,365),Point(66,335),Point(74,310),Point(84,286),Point(95,261),Point(112,233),Point(124,218),Point(132,209),Point(135,206),Point(137,206),Point(143,225),Point(161,270),Point(176,304),Point(195,336),Point(205,357),Point(211,371),Point(212,377),Point(212,378)},
	vs3 = {Point(63,381),Point(64,373),Point(67,360),Point(75,328),Point(85,287),Point(91,250),Point(95,231),Point(100,217),Point(106,204),Point(109,196),Point(110,194),Point(111,194),Point(115,200),Point(139,227),Point(167,262),Point(196,310),Point(226,367),Point(242,405),Point(248,426),Point(251,443),Point(252,445)},
	os = {Point(111,413),Point(107,409),Point(93,391),Point(81,372),Point(73,354),Point(70,335),Point(70,320),Point(75,305),Point(86,289),Point(102,275),Point(130,261),Point(171,250),Point(214,249),Point(232,250),Point(235,254),Point(237,271),Point(234,297),Point(225,331),Point(213,358),Point(199,376),Point(186,389),Point(170,397),Point(162,400),Point(158,401)},
	square = {Point(56,390),Point(56,388),Point(56,377),Point(56,362),Point(56,350),Point(56,332),Point(57,315),Point(60,296),Point(63,274),Point(65,263),Point(66,255),Point(67,247),Point(67,242),Point(68,238),Point(69,236),Point(70,235),Point(76,233),Point(96,230),Point(109,229),Point(126,228),Point(136,228),Point(144,228),Point(162,230),Point(180,234),Point(201,236),Point(224,240),Point(236,242),Point(239,243),Point(239,244),Point(239,249),Point(239,259),Point(239,277),Point(235,303),Point(231,334),Point(231,367),Point(234,391),Point(235,408),Point(235,416),Point(235,418),Point(235,420),Point(235,421),Point(233,422),Point(226,424),Point(207,424),Point(162,424),Point(97,417),Point(54,415),Point(25,411),Point(13,409),Point(9,408)}
}

function setup()
end

function test_vs()
	local protractor = DollarRecognizer()
	local result = protractor.Recognize(test_data.vs, true)
	ser.print(result)
end

function test_vs2()
	local protractor = DollarRecognizer()
	local result = protractor.Recognize(test_data.vs2, true)
	ser.print(result)
end

function test_vs3()
	local protractor = DollarRecognizer()
	local result = protractor.Recognize(test_data.vs3, true)
	ser.print(result)
end

function test_os()
	local protractor = DollarRecognizer()
	local result = protractor.Recognize(test_data.os, true)
	ser.print(result)
end

function test_square()
	local protractor = DollarRecognizer()
	local result = protractor.Recognize(test_data.square, true)
	ser.print(result)
end

lunatest.run()

require "lunatest"

package.path = package.path .. ";../?.lua"
require "../libs/protractor"
local matrix = require '../libs/matrix'

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

function setup()
end

function test_g()
	local result = protractor.DollarRecognizer.this.Recognize(test_data.vs, true)
	matrix.print(result)
end

lunatest.run()

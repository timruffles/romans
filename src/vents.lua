vents = {}

function vents.initVent()
	vent = {cbs = {}}
	function vent:on (evt,cb)
		self.cbs[evt] = self.cbs[evt] or {}
		self.cbs[evt][cb] = cb
	end
	function vent:once (evt,cb)
		local once = function(...)
			cb(...)
			vent:off(evt,once)
		end
		vent:on(evt,once)
	end
	function vent:off(evt,cb)
		local cbs = self.cbs[evt]
		if cbs[cb] then
			cbs[cb] = nil
		end
	end
	function vent:trigger(evt,...)
		local cbs = self.cbs[evt] or {}
		for _,cb in pairs(cbs) do
			cb(...)
		end
	end
	return vent
end

return vents

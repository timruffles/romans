-- http://phi.lho.free.fr/programming/TestLuaArray.lua.html
-- TODO move this to helpers
-- Emulate the splice function of JS (or array_splice of PHP)
-- I keep the imperfect parameter names from the Mozilla doc.
-- http://developer.mozilla.org/en/docs/Core_JavaScript_1.5_Reference:Global_Objects:Array:splice
-- I use 1-based indices, of course.
function Splice(t, index, howMany, ...)
	local removed = {}
	local tableSize = table.getn(t) -- Table size
	-- Lua 5.0 handling of vararg...
	local argNb = table.getn(arg) -- Number of elements to insert
	-- Check parameter validity
	if index < 1 then index = 1 end
	if howMany < 0 then howMany = 0 end
	if index > tableSize then
		index = tableSize + 1 -- At end
		howMany = 0 -- Nothing to delete
	end
	if index + howMany - 1 > tableSize then
		howMany = tableSize - index + 1 -- Adjust to number of elements at index
	end

	local argIdx = 1 -- Index in arg
	-- Replace min(howMany, argNb) entries
	for pos = index, index + math.min(howMany, argNb) - 1 do
		-- Copy removed entry
		table.insert(removed, t[pos])
		-- Overwrite entry
		t[pos] = arg[argIdx]
		argIdx = argIdx + 1
	end
	argIdx = argIdx - 1
	-- If howMany > argNb, remove extra entries
	for i = 1, howMany - argNb do
		table.insert(removed, table.remove(t, index + argIdx))
	end
	-- If howMany < argNb, insert remaining new entries
	for i = argNb - howMany, 1, -1 do
		table.insert(t, index + howMany, arg[argIdx + i])
	end
	return removed
end



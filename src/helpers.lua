local serpent = require "libs/serpent"

helpers = {table={}}

local locationFormat = "%s(%s):"
helpers.trace = function(...)
	local info = debug.getinfo( 2, "Sl" )
	return print(locationFormat:format( info.source, info.currentline), ... )
end

tracef = function(fmt,...)
	local info = debug.getinfo( 2, "Sl" )
	return print(locationFormat:format( info.source, info.currentline), string.format(fmt,...) )
end

helpers.table.slice = function(values,i1,i2)
	local res = {}
	local n = #values
	-- default values for range
	i1 = i1 or 1
	i2 = i2 or n
	if i2 < 0 then
		i2 = n + i2 + 1
	elseif i2 > n then
		i2 = n
	end
	if i1 < 1 or i1 > n then
		return {}
	end
	local k = 1
	for i = i1,i2 do
		res[k] = values[i]
		k = k + 1
	end
	return res
end

helpers.table.join = function(list, delimiter)
  local len = #list
  if len == 0 then 
    return "" 
  end
  local string = list[1]
  for i = 2, len do 
    string = string .. delimiter .. list[i] 
  end
  return string
end

function p(...)
	local args = ...
	if #args == 1 then
		if type(args[1]) == "table" then
			return print(serpent.block(args[1]))
		end
	end
	print(unpack(args))
end

function pp(table)
	print(serpent.block(table))
end

function helpers.pluck(k)
	return function(o)
		return o[k]
	end
end

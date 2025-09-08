local csprng = require('@self/csprng')
local helper = require('@self/helper')
local prng = require('@self/prng')

-- functions
export type weight = number
local function binary_search(arr: { number }, value: number): number
	local range = #arr
	local init = 1
	while range > 0 do
		range //= 2
		local mid = init + range
		local mid_value = arr[mid]
		init = if mid_value == nil then mid elseif value < mid_value then init else mid + 1
	end
	return init
end
local function rarest_keys<K>(key_weights: { [K]: weight }): { K }
	local rarest_weights = {}
	local rarest_keys = {}
	for key, weight in key_weights do
		local index = binary_search(rarest_weights, weight)
		table.insert(rarest_keys, index, key)
		table.insert(rarest_weights, index, weight)
	end
	return rarest_keys
end
local function deterministic_iter_order<K>(key_weights: { [K]: weight }): { [K]: weight }
	local ordered_keys = rarest_keys(key_weights)

	local function iter(): () -> (K?, weight?)
		local index = 0
		return function()
			index += 1
			local key = ordered_keys[index]
			local weight = key and key_weights[key]
			return key, weight
		end
	end

	return setmetatable(key_weights, { __iter = iter }) :: any
end

-- module
local std = helper(math.random)
return table.freeze {
	new_secure = csprng,
	custom = helper,
	new = prng,

	deterministic_iter_order = deterministic_iter_order,
	rarest_keys = rarest_keys,

	-- primitive
	vector_range = std.vector_range,
	vector = std.vector,
	number = std.number,
	range = std.range,
	step = std.step,

	buffer = std.buffer,
	truth = std.truth,
	pass = std.truth,
	skip = std.skip,

	-- table
	write_shuffle = std.write_shuffle,
	key_by_weight = std.key_by_weight,
	value = std.value,
	key = std.key,
}

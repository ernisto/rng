type ratio = number -- a number ranging 0.00 to 1.00

-- primitive
local function number(min: number?, max: number?, step: number?): number
	return if step
		then math.lerp(min :: number, max :: number, math.random()) // step * step
		elseif max then math.lerp(min :: number, max, math.random())
		elseif min then math.random() * min
		else math.random()
end
local function vect(min: vector?, max: vector?, step: vector?): vector
	return vector.create(
		number(min and min.x, max and max.x, step and step.x),
		number(min and min.y, max and max.y, step and step.y),
		number(min and min.z, max and max.z, step and step.z)
	)
end
local function buff(count: number, target: buffer?, offset: number?): buffer
	local output = target or buffer.create(count)
	local init = offset or 0
	for cursor = init, init + count do
		buffer.writeu32(output, cursor, number(2 ^ 32 - 1))
	end
	return output
end
local function truth(chance: ratio): boolean
	return number() <= chance
end
local function skip(chance: ratio): boolean
	return number() > chance
end

-- table
type weight = number -- any number
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
	local rarest = {}
	local weights = {}
	for key, weight in key_weights do
		local index = binary_search(weights, weight)
		table.insert(rarest, index, key)
		table.insert(weights, index, weight)
	end
	return rarest
end
local function key_by_weight<K>(key_weights: { [K]: weight }): K
	local total_weight = 0
	for _, weight in key_weights do
		total_weight += weight
	end

	local n = number(total_weight)
	for key, weight in key_weights do
		if weight <= n then return key end
		n -= weight
	end
	return next(key_weights) or error(`no keys provided`)
end
local function write_shuffle<T>(mut_arr: { T }): { T }
	for index, value in mut_arr do
		local index2 = number(1, #mut_arr) // 1
		mut_arr[index], mut_arr[index2] = mut_arr[index2], mut_arr[index]
	end
	return mut_arr
end
local function value<T>(arr: { T }): T
	return arr[number(#arr) // 1]
end

-- module
return table.freeze {
	number = number :: ((max: number?) -> number) & (min: number, max: number, step: number?) -> number,
	vector = vect :: ((max: vector?) -> vector) & (min: vector, max: vector, step: vector?) -> vector,
	buffer = buff,
	truth = truth,
	pass = truth,
	skip = skip,

	-- table
	write_shuffle = write_shuffle,
	key_by_weight = key_by_weight,
	rarest_keys = rarest_keys,
	value = value,
}

type ratio = number -- a number ranging 0.00 to 1.00
return function(rng: () -> ratio)
	local function number(max: number?): number
		return if max then rng() * max else rng()
	end
	local function number_step(max: number?, step: number?): number
		return if step then (max :: number) * rng() // step * step elseif max then rng() * max else rng()
	end
	local function number_range(min: number, max: number, step: number?): number
		return if step then math.lerp(min, max, rng()) // step * step else math.lerp(min, max, rng())
	end
	local function vect(x: number?, y: number?, z: number?, step: number?): vector
		return if y
			then vector.create(number_step(x, step), number_step(y, step), z and number_step(z, step) or 0)
			else vector.create(number_step(x), number_step(x), number_step(x))
	end
	local function vect_range(min: vector, max: vector, step: vector?): vector
		return vector.create(
			number_range(min and min.x, max and max.x, step and step.x),
			number_range(min and min.y, max and max.y, step and step.y),
			number_range(min and min.z, max and max.z, step and step.z)
		)
	end
	local function buff(count: number, target: buffer?, offset: number?): buffer
		local output = target or buffer.create(count)
		local init = offset or 0
		for cursor = init, init + count - 4, 4 do
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
	local function key_by_weight<K>(key_weights: { [K]: weight }): K
		local total_weight = 0
		for _, weight in key_weights do
			total_weight += weight
		end

		local n = number(total_weight)
		for key, weight in key_weights do
			if n <= weight then return key end
			n -= weight
		end
		if next(key_weights) then
			print(`couldnt possible match a key to {n}. fallback to any key, pls send me a repro`)
		end
		return next(key_weights) or error(`no keys provided`)
	end
	local function write_shuffle<T>(mut_arr: { T }): { T }
		for index, value in mut_arr do
			local index2 = number_range(1, #mut_arr) // 1
			mut_arr[index], mut_arr[index2] = mut_arr[index2], mut_arr[index]
		end
		return mut_arr
	end
	local function value<T>(arr: { T }): T
		return arr[number_range(1, #arr) // 1]
	end
	local function key<K, V>(map: { [K]: V }): K
		local keys = {}
		for key in map do
			table.insert(keys, key)
		end
		return value(keys)
	end

	-- module
	return table.freeze {
		number = number,
		step = number_step,
		range = number_range,
		vector = vect :: ((max: number?) -> vector) & (x: number, y: number, z: number?, step: number?) -> vector,
		vector_range = vect_range,
		buffer = buff,
		truth = truth,
		pass = truth,
		skip = skip,

		-- table
		write_shuffle = write_shuffle,
		key_by_weight = key_by_weight,
		value = value,
		key = key,
	}
end

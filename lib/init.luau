local csprng = require('@self/csprng')
local helper = require('@self/helper')
local prng = require('@self/prng')

-- module
local std = helper(math.random)
return table.freeze {
	new_secure = csprng,
	custom = helper,
	new = prng,

	-- primitive
	number = std.number,
	vector = std.vector,
	buffer = std.buffer,
	truth = std.truth,
	pass = std.truth,
	skip = std.skip,

	-- table
	deterministic = std.deterministic,
	write_shuffle = std.write_shuffle,
	key_by_weight = std.key_by_weight,
	rarest_keys = std.rarest_keys,
	value = std.value,
	key = std.key,
}

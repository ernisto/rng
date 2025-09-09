-- run tests on terminal `pesde x ernisto/test`

local rng = require('../lib')
local run = {}

local N = 2 ^ 16

-- number()
function run.should_return_number_in_range()
	for i = 1, N do
		local n = rng.range(1, 10)
		assert(n >= 1 and n <= 10)
	end
end

function run.should_return_number_with_step()
	for i = 1, N do
		local n = rng.range(0, 10, 2)
		assert(n % 2 == 0)
	end
end

-- vect()
function run.should_return_vector_in_range()
	for i = 1, N do
		local v = rng.vector_range(vector.create(0, 0, 0), vector.create(5, 5, 5))
		assert(0 <= v.x and v.x <= 5)
		assert(0 <= v.y and v.y <= 5)
		assert(0 <= v.z and v.z <= 5)
	end
end

function run.should_generate_uniform_distribuited_directions()
	local sum = 0
	for i = 1, N do
		local v = rng.direction()
		sum += v.x + v.y + v.z
	end
	local mean = sum / N
	assert(math.abs(mean) < 0.01, `Expected mean of ~0.5 (0.01 threshold), got {mean}`)
end

-- buff()
function run.should_return_buffer_with_count()
	local b = rng.buffer(8)
	assert(type(b) == 'buffer')
	assert(buffer.len(b) == 8)
end

-- truth()
function run.should_return_boolean()
	for i = 1, N do
		local b = rng.truth(0.5)
		assert(type(b) == 'boolean')
	end
end

-- skip()
function run.should_return_boolean_skip()
	for i = 1, N do
		local b = rng.skip(0.5)
		assert(type(b) == 'boolean')
	end
end

-- rarest_keys()
function run.should_return_key_with_lowest_weight()
	for i = 1, N do
		local keys = rng.rarest_keys({ a = 1, b = 10, c = 1 })
		assert(table.find(keys, 'a') <= 2)
		assert(table.find(keys, 'c') <= 2)
		assert(table.find(keys, 'b') == 3)
	end
end

-- deterministic()
function run.should_keep_same_iter_order()
	local iter_order1 = {}
	for key in rng.same_iter_order { a = 2, b = 3 } do
		table.insert(iter_order1, key)
	end
	assert(iter_order1[1] == 'a')
	assert(iter_order1[2] == 'b')

	local iter_order2 = {}
	for key in rng.same_iter_order { aaaa = 2, bbbb = 3 } do
		table.insert(iter_order2, key)
	end
	assert(iter_order2[1] == 'aaaa')
	assert(iter_order2[2] == 'bbbb')
end

-- key_by_weight()
function run.should_return_key_from_weighted_table()
	for i = 1, N do
		local k = rng.key_by_weight { a = 100, b = 0 }
		assert(k == 'a')
	end
end

-- write_shuffle()
function run.should_shuffle_array()
	local arr = { 1, 2, 3, 4 }
	rng.write_shuffle(arr)
	assert(#arr == 4)
	assert(table.find(arr, 1))
	assert(table.find(arr, 2))
	assert(table.find(arr, 3))
	assert(table.find(arr, 4))
end

-- value()
function run.should_return_value_from_array()
	for i = 1, N do
		local v = rng.value { 'x', 'y', 'z' }
		assert(v == 'x' or v == 'y' or v == 'z')
	end
end

-- key()
function run.should_return_key_from_map()
	for i = 1, N do
		local k = rng.key { a = 1, b = 2 }
		assert(k == 'a' or k == 'b')
	end
end

return run

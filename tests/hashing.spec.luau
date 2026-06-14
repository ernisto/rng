local hash = require '../lib/hash'

local focus = {}
local run = {}

local U32_CAP = 2 ^ 32

function run.dont_get_0()
	local num = hash('cavalo muito esperto chama', 1)
	assert(num ~= 0, `number is {num}`)
end

function run.is_deterministic()
	for i = 1, 1000 do
		local seed = `seed_{i}`
		local a = hash(seed, 1)
		local b = hash(seed, 1)
		assert(a == b, `non-deterministic for {seed}: {a} ~= {b}`)
	end
end

function run.distinct_seeds_diverge()
	local seen = {}
	for i = 1, 100000 do
		local h = hash(i, 1)
		assert(seen[h] == nil, `collision: seed {i} and {seen[h]} both hash to {h}`)
		seen[h] = i
	end
end

function run.output_in_u32_range()
	for i = 1, 100000 do
		local h = hash(i, 1)
		assert(h >= 0 and h < U32_CAP, `out of u32 range: {h}`)
		assert(h % 1 == 0, `not integer: {h}`)
	end
end

function run.count_returns_n_values()
	for count = 1, 16 do
		local values = { hash('count_test', count) }
		assert(#values == count, `expected {count} values, got {#values}`)
	end
end

function run.chained_values_are_distinct()
	local values = { hash('chain_test', 8) }
	local seen = {}
	for _, v in values do
		assert(seen[v] == nil, `repeated value in single call: {v}`)
		seen[v] = true
	end
end

function run.supports_seed_types()
	assert(hash(12345, 1) ~= 0, 'number seed failed')
	assert(hash('12345', 1) ~= 0, 'string seed failed')
	assert(hash(buffer.fromstring('12345'), 1) ~= 0, 'buffer seed failed')
end

function run.no_zero_across_seeds()
	for i = 1, 100000 do
		local h = hash(i, 1)
		assert(h ~= 0, `got 0 for seed {i}`)
	end
end

function run.avalanche_on_small_change()
	-- single-char change should produce different hash
	local a = hash('avalanche_a', 1)
	local b = hash('avalanche_b', 1)
	assert(a ~= b, `no avalanche: {a} == {b}`)
end

function run.uniform_bit_distribution()
	-- each of the 32 bits should be set roughly half the time
	local N = 2 ^ 16
	local bit_counts = table.create(32, 0)
	for i = 1, N do
		local h = hash(i, 1)
		for bit = 0, 31 do
			if bit32.btest(h, bit32.lshift(1, bit)) then bit_counts[bit + 1] += 1 end
		end
	end
	for bit = 0, 31 do
		local ratio = bit_counts[bit + 1] / N
		assert(ratio > 0.45 and ratio < 0.55, `bit {bit} biased: {ratio}`)
	end
end

return { run = run, focus = focus }

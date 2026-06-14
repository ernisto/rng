-- run tests on terminal `lute test`

local hash = require '../lib/hash'
local test = require '@std/test'

local U32_CAP = 2 ^ 32

test.case('dont get 0', function(t)
	local num = hash('cavalo muito esperto chama', 1)
	t.neq(num, 0, `number is {num}`)
end)

test.case('is deterministic', function(t)
	for i = 1, 1000 do
		local seed = `seed_{i}`
		local a = hash(seed, 1)
		local b = hash(seed, 1)
		t.eq(a, b, `non-deterministic for {seed}: {a} ~= {b}`)
	end
end)

test.case('distinct seeds diverge', function(t)
	local seen = {}
	for i = 1, 100000 do
		local h = hash(i, 1)
		t.eq(seen[h], nil, `collision: seed {i} and {seen[h]} both hash to {h}`)
		seen[h] = i
	end
end)

test.case('output in u32 range', function(t)
	for i = 1, 100000 do
		local h = hash(i, 1)
		t.that(h >= 0 and h < U32_CAP, `out of u32 range: {h}`)
		t.that(h % 1 == 0, `not integer: {h}`)
	end
end)

test.case('count returns n values', function(t)
	for count = 1, 16 do
		local values = { hash('count_test', count) }
		t.eq(#values, count, `expected {count} values, got {#values}`)
	end
end)

test.case('chained values are distinct', function(t)
	local values = { hash('chain_test', 8) }
	local seen = {}
	for _, v in values do
		t.eq(seen[v], nil, `repeated value in single call: {v}`)
		seen[v] = true
	end
end)

test.case('supports seed types', function(t)
	t.neq(hash(12345, 1), 0, 'number seed failed')
	t.neq(hash('12345', 1), 0, 'string seed failed')
	t.neq(hash(buffer.fromstring '12345', 1), 0, 'buffer seed failed')
end)

test.case('no zero across seeds', function(t)
	for i = 1, 100000 do
		local h = hash(i, 1)
		t.neq(h, 0, `got 0 for seed {i}`)
	end
end)

test.case('avalanche on small change', function(t)
	-- single-char change should produce different hash
	local a = hash('avalanche_a', 1)
	local b = hash('avalanche_b', 1)
	t.neq(a, b, `no avalanche: {a} == {b}`)
end)

test.case('uniform bit distribution', function(t)
	-- each of the 32 bits should be set roughly half the time
	local N = 2 ^ 16
	local bit_counts = table.create(32, 0)
	for i = 1, N do
		local h = hash(i, 1)
		for bit = 0, 31 do
			if bit32.btest(h, bit32.lshift(1, bit)) then
				bit_counts[bit + 1] += 1
			end
		end
	end
	for bit = 0, 31 do
		local ratio = bit_counts[bit + 1] / N
		t.that(ratio > 0.45 and ratio < 0.55, `bit {bit} biased: {ratio}`)
	end
end)

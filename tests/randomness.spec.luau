-- run tests on terminal `lute test`

local lib = require '../lib'
local test = require '@std/test'

local N = 2 ^ 20

local function define(prefix: string, rng: () -> number)
	test.case(`{prefix} uniform frequency`, function(t)
		local sum = 0
		for i = 1, N do
			local r = rng()
			t.that(r > 0 and r <= 1, `Out of range [0, 1]: {r}`)
			sum = sum + r
		end
		local mean = sum / N
		t.that(mean > 0.49 and mean < 0.51, `Expected mean of ~0.5 (0.01 threshold), got {mean}`)
	end)

	test.case(`{prefix} no absurd_sequences`, function(t)
		local last = rng()
		local absurd_sequence_length = math.log(N, 2) * 5
		local current_sequence = 1
		local higher_sequence_length = 1
		for i = 2, N do
			local r = rng()
			if (r > 0.5) == (last > 0.5) then
				current_sequence = current_sequence + 1
				if current_sequence > higher_sequence_length then higher_sequence_length = current_sequence end
			else
				current_sequence = 1
			end
			last = r
		end
		t.that(higher_sequence_length < absurd_sequence_length, `Got so high sequence of 1/2: {higher_sequence_length}`)
	end)

	test.case(`{prefix} low auto correlation`, function(t)
		local seq = {}
		for i = 1, N do
			seq[i] = rng()
		end
		local dot, norm = 0, 0
		for i = 1, N - 1 do
			dot += (seq[i] - 0.5) * (seq[i + 1] - 0.5)
			norm += (seq[i] - 0.5) ^ 2
		end
		local corr = dot / norm
		t.that(math.abs(corr) < 0.05, `High correlation: {corr}`)
	end)

	test.case(`{prefix} distinct seeds diverge`, function(t)
		local r1 = lib.new(1)
		local r2 = lib.new(2)

		for i = 1, 1000000 do
			t.neq(r1.number(), r2.number())
		end
	end)
end

define('secure_new', lib.new_secure().number)
define('new', lib.new().number)

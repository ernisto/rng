-- run tests on terminal `pesde x ernisto/test`

local rng = require('../lib/csprng')()

local run = {}
local N = 2 ^ 16

function run.uniform_frequency()
	local sum = 0
	for i = 1, N do
		local r = rng()
		assert(r >= 0 and r <= 1, `Out of range [0, 1]`)
		sum = sum + r
	end
	local mean = sum / N
	assert(mean > 0.49 and mean < 0.51, `Expected mean of ~0.5 (0.01 threshold), got {mean}`)
end

function run.no_absurd_sequences()
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
	assert(higher_sequence_length < absurd_sequence_length, `Got so high sequence of 1/2: {higher_sequence_length}`)
end

function run.low_auto_correlation()
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
	assert(math.abs(corr) < 0.05, `High correlation: {corr}`)
end

return run

local hash = require('./hash')
local helper = require('./helper')
local U32_CAP = 2 ^ 32
type u32 = number

type ratio = number -- ranging 0.00 to 1.00

-- functions
local function xoroshiro(s0: u32, s1: u32, s2: u32, s3: u32): ...u32
	local t = bit32.lshift(s1, 9)

	s2 = bit32.bxor(s2, s0)
	s3 = bit32.bxor(s3, s1)
	s1 = bit32.bxor(s1, s2)
	s0 = bit32.bxor(s0, s3)

	s2 = bit32.bxor(s2, t)
	s3 = bit32.lrotate(s3, 11)
	return s0, s1, s2, s3, (s0 + s3) % U32_CAP
end

-- module
local function generator(seed: hash.seed?)
	local s0, s1, s2, s3 = hash(seed, 4)
	local r = 0

	local function generate(): ratio
		s0, s1, s2, s3, r = xoroshiro(s0, s1, s2, s3)
		return math.ldexp(r, -32)
	end
	return helper(generate)
end

return generator

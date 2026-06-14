-- defs
local PRIME32_1 = 0x9E3779B1 -- golden ratio prime
local PRIME32_2 = 0x85EBCA77 -- good primes
local PRIME32_3 = 0xC2B2AE3D
local PRIME32_4 = 0x27D4EB2F
local PRIME32_5 = 0x165667B1

local U32_CAP = 2 ^ 32
type u32 = number

local function multiply_u32(x: u32, m: u32): u32
	-- split 32x32 mult so intermediates stay below 2^53 (no float precision loss)
	x %= U32_CAP
	m %= U32_CAP
	local lo = x % 0x10000 * m
	local hi = x // 0x10000 * m % 0x10000 * 0x10000
	return (lo + hi) % U32_CAP
end

-- functions
local function xxhash(buff: buffer, h: u32): u32
	local len = buffer.len(buff)
	h += PRIME32_5
	if len >= 4 then
		for offset = 0, len - 4 do
			h += multiply_u32(buffer.readu32(buff, offset), PRIME32_1)
			h = bit32.bxor(h, bit32.rshift(h, 17))
			h = multiply_u32(h, PRIME32_4)
		end
	else
		-- inputs < 4 bytes can't be read as u32; mix per-byte so content matters
		for offset = 0, len - 1 do
			h += multiply_u32(buffer.readu8(buff, offset), PRIME32_5)
			h = bit32.lrotate(h, 11)
			h = multiply_u32(h, PRIME32_1)
		end
	end

	h = bit32.bxor(h, bit32.rshift(h, 15))
	h = multiply_u32(h, PRIME32_2)
	h = bit32.bxor(h, bit32.rshift(h, 13))
	h = multiply_u32(h, PRIME32_3)
	h = bit32.bxor(h, bit32.rshift(h, 16))

	return h
end

-- module
export type seed = number | string | buffer
local function hash_to_u32(seed: seed?, count: number): ...u32
	local buff = buffer.fromstring(if type(seed) == 'string' then seed else tostring(seed))
	local last = 0
	local u32s = {}
	for i = 1, count do
		last = xxhash(buff, last)
		table.insert(u32s, last)
	end
	return unpack(u32s)
end

return hash_to_u32

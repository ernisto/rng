-- defs
local PRIME32_1 = 0x9E3779B1 -- golden ratio prime
local PRIME32_2 = 0x85EBCA77 -- good primes
local PRIME32_3 = 0xC2B2AE3D
local PRIME32_4 = 0x27D4EB2F
local PRIME32_5 = 0x165667B1

type u32 = number

-- functions
local function xxhash(buff: buffer, h: u32): u32
	h += PRIME32_5
	for offset = 0, buffer.len(buff) - 4, 4 do
		h += PRIME32_1 * buffer.readu32(buff, offset)
		h = bit32.bxor(h, bit32.rshift(h, 17))
		h *= PRIME32_4
	end

	h = bit32.bxor(h, bit32.rshift(h, 15))
	h *= PRIME32_2
	h = bit32.bxor(h, bit32.rshift(h, 13))
	h *= PRIME32_3
	h = bit32.bxor(h, bit32.rshift(h, 16))

	return h
end

-- module
export type seed = number | string | buffer
local function hash_to_u32(seed: seed?, count: number): ...u32
	local buff = buffer.fromstring(
		if type(seed) == 'string'
			then seed
			elseif seed then tostring(seed)
			else tostring(bit32.lrotate(os.clock() + 1e9, 16))
	)
	local last = 0
	local u32s = {}
	for i = 1, count do
		last = xxhash(buff, last)
		table.insert(u32s, last)
	end
	return unpack(u32s)
end

return hash_to_u32

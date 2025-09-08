local hash = require('./hash')
local helper = require('./helper')

-- defs
local U32_CAP = 2 ^ 32 - 1
type u32 = number
type ratio = number -- ranging 0.00 to 1.00

-- functions
local function write_quarter_round(s: chacha_block, a: number, b: number, c: number, d: number)
	s[a] += s[b]
	s[d] = bit32.lrotate(bit32.bxor(s[d], s[a]), 16)
	s[c] += s[d]
	s[b] = bit32.lrotate(bit32.bxor(s[b], s[c]), 12)
	s[a] += s[b]
	s[d] = bit32.lrotate(bit32.bxor(s[d], s[a]), 8)
	s[c] += s[d]
	s[b] = bit32.lrotate(bit32.bxor(s[b], s[c]), 7)
end

local function write_20_rounds(state: chacha_block)
	local new_state = table.clone(state)
	for i = 1, 20 / 2 do
		-- column rounds
		write_quarter_round(new_state, 01, 05, 09, 13)
		write_quarter_round(new_state, 02, 06, 10, 14)
		write_quarter_round(new_state, 03, 07, 11, 15)
		write_quarter_round(new_state, 04, 08, 12, 16)

		-- diagonal rounds
		write_quarter_round(new_state, 01, 05 + 1, 09 + 2, 13 + 3)
		write_quarter_round(new_state, 02, 06 + 1, 10 + 2, 14 - 1)
		write_quarter_round(new_state, 03, 07 + 1, 11 - 2, 15 - 1)
		write_quarter_round(new_state, 04, 08 - 3, 12 - 2, 16 - 1)
	end
	for i = 1, 16 do
		state[i] += new_state[i]
	end
end

type byte = number
local function bytes_to_u32(...: byte): { u32 }
	local bytes = { ... }
	local u32 = {}
	for i = 1, #bytes - 3, 4 do
		table.insert(u32, bytes[i] + bytes[i + 1] * 2 ^ 8 + bytes[i + 2] * 2 ^ 16 + bytes[i + 3] * 2 ^ 24)
	end
	return u32
end

-- module
type chacha_block = { u32 } -- 16 elements
local function generator(seed: hash.seed?, salt: buffer?)
	local state: chacha_block = table.create(16, 0)
	state[1], state[2], state[3], state[4] = unpack(bytes_to_u32(string.byte('expand 32-byte k', 0, 16)))

	-- key: 32 bytes
	state[5], state[6], state[7], state[8], state[9], state[10], state[11], state[12] = hash(seed, 8)
	state[13] = 0 -- counter: 4 bytes

	-- nonce: 12 bytes
	for i = 1, 3 do
		state[13 + i] = salt and buffer.readu32(salt, (i - 1) * 4) or math.random() * U32_CAP
	end

	-- gen
	local block = table.create(16, 0)
	local cursor = 0

	local function refill_block()
		for i = 1, 16 do
			block[i] = state[i]
		end
		write_20_rounds(block)
		cursor = 0
		state[13] += 1
	end

	local function next(): ratio
		if cursor >= 16 then refill_block() end
		cursor += 1
		return math.ldexp(block[cursor], -32) % 1
	end

	return helper(next)
end

return generator

-- run tests on terminal `lute test`

local rng = require '../lib'
local test = require '@std/test'

local N = 2 ^ 16

-- number()
test.case('should return number in range', function(t)
	for i = 1, N do
		local n = rng.range(1, 10)
		t.that(n >= 1 and n <= 10, `out of range: {n}`)
	end
end)

test.case('should return number with step', function(t)
	local outputs = {}
	for i = 1, N do
		local n = rng.range(0, 10, 2)
		t.that(n % 2 == 0, `not stepped: {n}`)
		table.insert(outputs, n)
	end
	for n = 0, 10, 2 do
		t.that(table.find(outputs, n), `missing {n}`)
	end
end)

test.case('should return number within negative interval', function(t)
	local outputs = {}
	for i = 1, N do
		local n = rng.range(-10, -5, 2)
		t.that(-10 <= n and n <= -5, `received {n}`)
		table.insert(outputs, n)
	end
	for n = -10, -5, 2 do
		t.that(table.find(outputs, n), `missing {n}`)
	end
	t.that(table.find(outputs, -5), 'missing -5')
end)

-- vect()
test.case('should return vector in range', function(t)
	local outputs = table.create(N)
	for i = 1, N do
		local v = rng.vector_range(vector.create(0, 0, 0), vector.create(5, 5, 5), vector.one)
		t.that(0 <= v.x and v.x <= 5, `x out of range: {v.x}`)
		t.that(0 <= v.y and v.y <= 5, `y out of range: {v.y}`)
		t.that(0 <= v.z and v.z <= 5, `z out of range: {v.z}`)
		table.insert(outputs, v)
	end
	for x = 0, 5 do
		for y = 0, 5 do
			for z = 0, 5 do
				t.that(table.find(outputs, vector.create(x, y, z)), `missing {x},{y},{z}`)
			end
		end
	end
end)

test.case('should generate uniform distribuited directions', function(t)
	local sum = 0
	for i = 1, N do
		local v = rng.direction()
		sum += v.x + v.y + v.z
	end
	local mean = sum / N
	t.that(math.abs(mean) < 0.01, `Expected mean of ~0.5 (0.01 threshold), got {mean}`)
end)

-- buff()
test.case('should return buffer with count', function(t)
	local b = rng.buffer(8)
	t.eq(type(b), 'buffer')
	t.eq(buffer.len(b), 8)
end)

-- truth()
test.case('should return boolean', function(t)
	local outputs = table.create(N)
	for i = 1, N do
		local b = rng.truth(0.5)
		table.insert(outputs, b)
	end
	t.that(table.find(outputs, true), 'never true')
	t.that(table.find(outputs, false), 'never false')
end)

-- skip()
test.case('should return boolean skip', function(t)
	local outputs = table.create(N)
	for i = 1, N do
		local b = rng.skip(0.5)
		table.insert(outputs, b)
	end
	t.that(table.find(outputs, true), 'never true')
	t.that(table.find(outputs, false), 'never false')
end)

-- rarest_keys()
test.case('should return key with lowest weight', function(t)
	local keys = rng.rarest_keys { a = 1, b = 10, c = 1, d = 5 }
	t.that((keys[1] == 'a' and keys[2] == 'c') or (keys[1] == 'c' and keys[2] == 'a'), `got {keys[1]},{keys[2]}`)
	t.eq(keys[3], 'd')
	t.eq(keys[4], 'b')
end)

-- deterministic()
test.case('should keep same iter order', function(t)
	local iter_order1 = {}
	for key in rng.same_iter_order { a = 2, b = 3 } do
		table.insert(iter_order1, key)
	end
	t.eq(iter_order1[1], 'a')
	t.eq(iter_order1[2], 'b')

	local iter_order2 = {}
	for key in rng.same_iter_order { aaaa = 2, bbbb = 3 } do
		table.insert(iter_order2, key)
	end
	t.eq(iter_order2[1], 'aaaa')
	t.eq(iter_order2[2], 'bbbb')
end)

-- key_by_weight()
test.case('should return key from weighted table', function(t)
	for i = 1, N do
		local k = rng.key_by_weight { a = 100, b = 0 }
		t.eq(k, 'a')
	end
end)

-- write_shuffle()
test.case('should shuffle array', function(t)
	local arr = { 1, 2, 3, 4 }
	rng.write_shuffle(arr)
	t.eq(#arr, 4)
	t.that(table.find(arr, 1), 'missing 1')
	t.that(table.find(arr, 2), 'missing 2')
	t.that(table.find(arr, 3), 'missing 3')
	t.that(table.find(arr, 4), 'missing 4')
end)

-- value()
test.case('should return value from array', function(t)
	local outputs = table.create(N)
	for i = 1, N do
		local v = rng.value { 'x', 'y', 'z' }
		t.that(v == 'x' or v == 'y' or v == 'z', `unexpected: {v}`)
		table.insert(outputs, v)
	end
	t.that(table.find(outputs, 'x'), 'never x')
	t.that(table.find(outputs, 'y'), 'never y')
	t.that(table.find(outputs, 'z'), 'never z')
end)

-- key()
test.case('should return key from map', function(t)
	local outputs = table.create(N)
	for i = 1, N do
		local k = rng.key { a = 1, b = 2 }
		t.that(k == 'a' or k == 'b', `unexpected: {k}`)
		table.insert(outputs, k)
	end
	t.that(table.find(outputs, 'a'), 'never a')
	t.that(table.find(outputs, 'b'), 'never b')
end)

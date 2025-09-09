local hash = require('../lib/hash')

local focus = {}
local run = {}

function run.dont_get_0()
	local num = hash('cavalo muito esperto chama', 1)
	assert(num ~= 0, `number is {num}`)
end

return { run = run, focus = focus }

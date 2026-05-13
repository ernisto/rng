local fs = require '@lute/fs'
local process = require '@lute/process'

-- functions
local function await_query_latest_version_tag(): string
	local result = process.run {
		'git',
		'for-each-ref',
		'--sort=-creatordate',
		'--format=%(refname:short)',
		'--count=1',
		'refs/tags',
	}
	assert(result.ok, `git for-each-ref failed: {result.stderr}`)

	local tag = result.stdout:match '^%s*(.-)%s*$'
	assert(tag, `invalid tag '{tag}'`)

	return tag:match '^v?(.+)$' or tag
end

local function update_toml_version(path, version)
	local handle = fs.open(path, 'r')
	local contents = fs.read(handle)
	fs.close(handle)

	local updated, n = contents:gsub('(version%s*=%s*")[^"]*(")', `%1{version}%2`, 1)
	assert(n == 1, `no version field found in {path}`)

	handle = fs.open(path, 'w')
	fs.write(handle, updated)
	fs.close(handle)

	print(`{path} version -> {version}`)
end

local function update_json_version(path, version)
	local handle = fs.open(path, 'r')
	local contents = fs.read(handle)
	fs.close(handle)

	local updated, n = contents:gsub('("version"%s*:%s*")[^"]*(")', `%1{version}%2`, 1)
	assert(n == 1, `no version field found in {path}`)

	handle = fs.open(path, 'w')
	fs.write(handle, updated)
	fs.close(handle)

	print(`{path} version -> {version}`)
end

-- run
local version = await_query_latest_version_tag()
update_toml_version('wally.toml', version)
update_toml_version('pesde.toml', version)
update_json_version('package.json', version)

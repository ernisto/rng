# rng

Simple, fast RNG utilities for Luau: numbers, booleans by probability, weighted choice, array helpers, vectors, and buffers.

## Installation

- Wally (`wally.toml`): add under `[dependencies]`
```toml
rng = "ernisto/rng@0.3.0"
```

- Pesde (terminal):
```sh
pesde add ernisto/rng --target luau
```

## Quick start

Require it from your `Packages` (adjust the path to match your setup):
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local rng = require(ReplicatedStorage.Packages.rng)
```

### Weighted choice
```lua
local rarity = rng.key_by_weight(rng.deterministic {
    common = 75,     -- 75/150 → 50.0%
    uncommon = 50,   -- 50/150 → 33.3%
    rare = 20,       -- 20/150 → 13.3%
    epic = 4,        --  4/150 →  2.6%
    legendary = 1,   --  1/150 →  0.6%
})
print("loot rarity:", rarity)
```

### Numbers
```lua
local x = rng.number()                 -- [0, 1]
local y = rng.number(10)               -- [0, 10]
local z = rng.number(5, 15)            -- [5, 15]
local s = rng.number(0, 1, 0.25)       -- one of {0.00, 0.25, 0.50, 0.75, 1.00}
```

### Booleans by probability
```lua
if rng.truth(0.2) then
    print("1/5 = 20% chance")
end

if rng.skip(1/3) then return end
print("1/3 = 33% chance")
```

### Vectors (Luau `vector` 3D type)
```lua
local v = rng.vector(vector.create(0, 0, 0), vector.create(100, 50, 100))
```

### Arrays
```lua
local items = {"a", "b", "c", "d"}
local pick = rng.value(items)   -- random element
local index = rng.key(items)    -- random index
rng.write_shuffle(items)        -- shuffles in place
```

### Buffers
```lua
local buf = rng.buffer(1024)           -- 1025 u32 values written starting at 0
-- or reuse an existing buffer, starting at an offset
local out = buffer.create(4096)
rng.buffer(512, out, 128)
```

## API

- `rng.number(): number` — range \[0, 1]
- `rng.number(max: number): number` — range \[0, max]
- `rng.number(min: number, max: number): number` — range \[min, max]
- `rng.number(min: number, max: number, step: number): number` — \[min, max] snapped to `step`

- `rng.vector(): vector` — each component in \[0, 1]
- `rng.vector(max: vector): vector` — each component in \[0, max]
- `rng.vector(min: vector, max: vector): vector` — component-wise \[min, max]
- `rng.vector(min: vector, max: vector, step: vector): vector` — component-wise stepped values

- `rng.truth(ratio: number): boolean`
- `rng.pass(ratio: number): boolean`
  - Returns true with probability `ratio` (e.g. 0.25 → 25% → 1/4).

- `rng.skip(ratio: number): boolean`
  - Returns false with probability `ratio` (e.g. 0.25 → 25% → 1/4).

- `rng.key_by_weight(weights: { [K]: number }): K`
  - Returns a key chosen by its weight (weights can be any positive decimal numbers).

- `rng.rarest_keys(weights: { [K]: number }): { K }`
  - Returns a array of keys ordered by weight

- `rng.deterministic(weights: { [K]: number }): { [K]: number }`
  - Returns the given weight map with a `__iter` metamethod, keeping the iteration order
    of this same table in anothers machines. Making `rng.key_by_weight` more deterministic,
    regenerative markets with same seed of all servers would be more consistent even using table as key.
    The consistency is taken when keys between 2 machines have different weight.

- `rng.write_shuffle<T>(mut_arr: { T }): { T }`
  - In-place array shuffle. Returns the same array for convenience.

- `rng.value<T>(arr: { T }): T`
  - Random element from an array.

- `rng.key<K>(arr: { [K]: _ }): K`
  - Random key from an table.

- `rng.buffer(count: number, target?: buffer, offset?: number): buffer`
  - Fills a buffer with random 32-bit unsigned integers; creates one if not provided.

- `rng.cryptographically_secure(seed: buffer?): () -> 0..1`
  - Returns a **C**ryptographically **S**ecure **P**seudo **R**andom **N**umber **G**enerator based on ChaCha20

## Notes

- See `test/randomness.spec.luau` for statistical sanity checks used during development.

## License

MIT

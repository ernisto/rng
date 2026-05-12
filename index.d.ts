declare namespace rng {
	type weight = number;
	type seed = number | string | buffer;
	type weight_map<K = unknown> = ReadonlyMap<K, weight>;

	interface shared_helper {
		number(this: void): number;
		number(this: void, max: number): number;

		step(this: void, max: number, step?: number): number;
		range(this: void, min: number, max: number, step?: number): number;

		vector(this: void): vector;
		vector(this: void, max: number): vector;
		vector(this: void, x: number, y: number, z?: number, step?: number): vector;
		vector_range(this: void, min: vector, max: vector, step?: vector): vector;
		direction(this: void): vector;

		buffer(this: void, count: number, target?: buffer, offset?: number): buffer;
		truth(this: void, chance: number): boolean;
		pass(this: void, chance: number): boolean;
		skip(this: void, chance: number): boolean;

		write_shuffle<T>(this: void, mut_arr: T[]): T[];
		key_by_weight<K>(this: void, key_weights: weight_map<K>): K;
		value<T>(this: void, arr: ReadonlyArray<T>): T;
		key<T extends object>(this: void, map: T): keyof T;
	}

	interface helper extends shared_helper {
		int(this: void, max: number): number;
		int_range(this: void, min: number, max: number, step?: number): number;
	}

	interface api extends shared_helper {
		new_secure: (this: void, seed?: seed, salt?: buffer) => helper;
		custom: (this: void, generator: () => number) => helper;
		new: (this: void, seed?: seed) => helper;

		same_iter_order<K>(this: void, key_weights: weight_map<K>): weight_map<K>;
		rarest_keys<K>(this: void, key_weights: weight_map<K>): K[];
	}
}

declare const rng: rng.api;
export = rng;

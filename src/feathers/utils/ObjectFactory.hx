/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.utils;

/**
	An abstract that creates a function that returns an instance of type `T`.

	Accepts one of the following values:

	- A function that returns an instance of `T`
	- The type `T` or a subtype of `T`
	- An existing instance of type `T`

	@since 1.0.0
**/
abstract ObjectFactory<T>(() -> T) from() -> T to() -> T {
	inline function new(factory:() -> T) {
		this = factory;
	}

	/**
		Accepts `Class<T>`, and creates a factory that instantiates it. The
		constructor must have zero required parameters.

		@since 1.0.0
	**/
	@:from
	public static function fromClass<T>(type:Class<T>) {
		return new ObjectFactory(() -> {
			return Type.createInstance(type, []);
		});
	}

	/**
		Accepts an instance of type `T`, and creates a factory that returns it.

		@since 1.0.0
	**/
	@:from
	public static function fromInstance<T>(instance:T) {
		return new ObjectFactory(() -> {
			return instance;
		});
	}
}

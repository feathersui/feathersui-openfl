/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.utils;

import haxe.Constraints.Constructible;
import openfl.display.DisplayObject;

/**
	@since 1.0.0
**/
class DisplayObjectRecycler<T:DisplayObject & Constructible<() -> Void>, S> {
	public function new(create:DisplayObjectClassOrFunction<T>, ?update:(target:T, state:S) -> Void, ?clean:(target:T, state:S) -> Void,
			?destroy:(T) -> Void) {
		if (create != null) {
			this.create = create;
		}
		if (update != null) {
			this.update = update;
		}
		if (clean != null) {
			this.clean = clean;
		}
		if (destroy != null) {
			this.destroy = destroy;
		}
	}

	public dynamic function update(target:T, state:S):Void {}

	public dynamic function clean(target:T, state:S):Void {}

	public dynamic function create():T {
		return null;
	}

	public dynamic function destroy(target:T):Void {}
}

abstract DisplayObjectClassOrFunction<T>(() -> T) from() -> T to() -> T {
	inline function new(factory:() -> T) {
		this = factory;
	}

	@:from
	public static function fromClass<T>(type:Class<T>) {
		return new DisplayObjectClassOrFunction(() -> {
			return Type.createInstance(type, []);
		});
	}
}

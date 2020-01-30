/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.utils;

import haxe.Constraints.Constructible;
import openfl.display.DisplayObject;

/**
	Manages display objects that may be used to render data, in a component like
	`ListView` or `TabBar`.

	@see `DisplayObjectRecycler.withClass()`
	@see `DisplayObjectRecycler.withFunction()`

	@since 1.0.0
**/
class DisplayObjectRecycler<T:B, S, B:DisplayObject> {
	/**
		Creates a `DisplayObjectRecycler` that instantiates a display object by
		instantiating the specified class. The class must have a constructor
		with zero required arguments.

		To instantiate an object with one or more required constructor
		arguments, use `DisplayObjectRecycler.withFunction()` instead.
	**/
	public static function withClass<T:B & Constructible<() -> Void>, S, B:DisplayObject>(displayObjectType:Class<T>, ?update:(target:T, state:S) -> Void,
			?reset:(target:T, state:S) -> Void, ?destroy:(T) -> Void):DisplayObjectRecycler<T, S, B> {
		var item = new DisplayObjectRecycler<T, S, B>();
		item.create = () -> {
			Type.createInstance(displayObjectType, []);
		};
		item.update = update;
		item.reset = reset;
		item.destroy = destroy;
		return item;
	}

	/**
		Creates a `DisplayObjectRecycler` that instantiates a display object by
		calling the specified function.
	**/
	public static function withFunction<T:B, S, B:DisplayObject>(create:() -> T, ?update:(target:T, state:S) -> Void, ?reset:(target:T, state:S) -> Void,
			?destroy:(T) -> Void):DisplayObjectRecycler<T, S, B> {
		var item = new DisplayObjectRecycler<T, S, B>();
		item.create = create;
		item.update = update;
		item.reset = reset;
		item.destroy = destroy;
		return item;
	}

	private function new() {}

	/**
		Updates the properties an existing display object. It may be a display
		object that was used previously, but it will have been passed to
		`reset()` first, to ensure that it has been restored to its original
		state when it was returned from `create()`.

		@since 1.0.0
	**/
	public dynamic function update(target:T, state:S):Void {};

	/**
		Prepares a display object to be used again. This method should restore
		the display object to its original state from when it was returned by
		`create()`.

		@since 1.0.0
	**/
	public dynamic function reset(target:T, state:S):Void {}

	/**
		Creates a new display object.

		@since 1.0.0
	**/
	public dynamic function create():T {
		return null;
	}

	/**
		Destroys/disposes a display object when it will no longer be used.

		@since 1.0.0
	**/
	public dynamic function destroy(target:T):Void {}
}

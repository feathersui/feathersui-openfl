/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.utils;

import openfl.display.DisplayObject;

/**
	Manages display objects that need to be created dynamically, such as
	sub-components of a complex UI component.

	@see `DisplayObjectFactory.withClass()`
	@see `DisplayObjectFactory.withFunction()`

	@since 1.0.0
**/
class DisplayObjectFactory<T:B, B:DisplayObject> {
	/**
		Creates a `DisplayObjectFactory` that instantiates a display object by
		instantiating the specified class. The class must have a constructor
		with zero required arguments.

		To instantiate an object with one or more required constructor
		arguments, use `DisplayObjectFactory.withFunction()` instead.
	**/
	public static function withDisplayObject<T:B, B:DisplayObject>(displayObject:T, ?destroy:(T) -> Void):DisplayObjectFactory<T, B> {
		var item = new DisplayObjectFactory<T, B>();
		item.create = () -> {
			return displayObject;
		};
		item.destroy = destroy;
		return item;
	}

	/**
		Creates a `DisplayObjectFactory` that instantiates a display object by
		instantiating the specified class. The class must have a constructor
		with zero required arguments.

		To instantiate an object with one or more required constructor
		arguments, use `DisplayObjectFactory.withFunction()` instead.
	**/
	public static function withClass<T:B, B:DisplayObject>(displayObjectType:Class<T>, ?destroy:(T) -> Void):DisplayObjectFactory<T, B> {
		var item = new DisplayObjectFactory<T, B>();
		item.create = () -> {
			Type.createInstance(displayObjectType, []);
		};
		item.destroy = destroy;
		return item;
	}

	/**
		Creates a `DisplayObjectFactory` that instantiates a display object by
		calling the specified function.
	**/
	public static function withFunction<T:B, B:DisplayObject>(create:() -> T, ?destroy:(T) -> Void):DisplayObjectFactory<T, B> {
		var item = new DisplayObjectFactory<T, B>();
		item.create = create;
		item.destroy = destroy;
		return item;
	}

	private function new() {}

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

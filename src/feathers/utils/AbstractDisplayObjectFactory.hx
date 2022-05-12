/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.utils;

import feathers.utils.DisplayObjectFactory;
import openfl.display.DisplayObject;

/**
	An abstract that accepts a `DisplayObjectFactory`, a function, a class, or
	a display object instance.

	@since 1.0.0
**/
@:forward(create, destroy)
abstract AbstractDisplayObjectFactory<T:B, B:DisplayObject>(DisplayObjectFactory<T, B>) from DisplayObjectFactory<T, B> to DisplayObjectFactory<T, B> {
	/**
		Converts a function value to a `feathers.utils.DisplayObjectFactory`
		value.

		@since 1.0.0
	**/
	@:from
	public static function fromFunction<T:B, B:DisplayObject>(func:() -> T):AbstractDisplayObjectFactory<T, B> {
		return DisplayObjectFactory.withFunction(func);
	}

	/**
		Converts a class value to a `feathers.utils.DisplayObjectFactory`
		value.

		@since 1.0.0
	**/
	@:from
	public static function fromClass<T:B, B:DisplayObject>(type:Class<T>):AbstractDisplayObjectFactory<T, B> {
		return DisplayObjectFactory.withClass(type);
	}

	/**
		Converts a display object value to a
		`feathers.utils.DisplayObjectFactory` value.

		@since 1.0.0
	**/
	@:from
	public static function fromDisplayObject<T:B, B:DisplayObject>(displayObject:T):AbstractDisplayObjectFactory<T, B> {
		return DisplayObjectFactory.withDisplayObject(displayObject);
	}
}

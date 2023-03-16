/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.utils;

import feathers.utils.DisplayObjectRecycler;
import openfl.display.DisplayObject;

/**
	An abstract that accepts a `DisplayObjectRecycler`, a function, or a class.

	@since 1.0.0
**/
@:forward(create, destroy, update, reset)
abstract AbstractDisplayObjectRecycler<T:B, S, B:DisplayObject>(DisplayObjectRecycler<T, S, B>) from DisplayObjectRecycler<T, S, B> to DisplayObjectRecycler<T,
	S, B> {
	/**
		Converts a function value to a `feathers.utils.DisplayObjectRecycler`
		value.

		@since 1.0.0
	**/
	@:from
	public static function fromFunction<T:B, S, B:DisplayObject>(func:() -> T):AbstractDisplayObjectRecycler<T, S, B> {
		return DisplayObjectRecycler.withFunction(func);
	}

	/**
		Converts a class value to a `feathers.utils.DisplayObjectRecycler`
		value.

		@since 1.0.0
	**/
	@:from
	public static function fromClass<T:B, S, B:DisplayObject>(type:Class<T>):AbstractDisplayObjectRecycler<T, S, B> {
		return DisplayObjectRecycler.withClass(type);
	}
}

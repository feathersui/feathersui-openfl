/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import openfl.display.DisplayObject;
import openfl.events.IEventDispatcher;
import openfl.geom.Rectangle;

/**
	Determines how an application is scaled and how its dimensions are set.

	@since 1.0.0
**/
interface IScaleManager extends IEventDispatcher {
	/**
		The target application that is being scaled.

		@since 1.0.0
	**/
	public var target(get, set):DisplayObject;

	/**
		Calculates the application's scale, which will be applied to the
		`scaleX` and `scaleY` properties.

		@since 1.0.0
	**/
	public function getScale():Float;

	/**
		Calculates the application's bounds, which will be applied to the
		`x`, `y`, `width`, and `height` properties.

		@since 1.0.0
	**/
	public function getBounds():Rectangle;
}

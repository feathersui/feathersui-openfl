/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

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
	@:flash.property
	public var target(get, set):DisplayObject;

	public function getScale():Float;
	public function getBounds():Rectangle;
}

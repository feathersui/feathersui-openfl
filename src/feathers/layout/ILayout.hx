/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import openfl.display.DisplayObject;
import openfl.events.IEventDispatcher;

/**
	Positions and sizes children in a container.

	@event openfl.events.Event.CHANGE Dispatched when a property of the layout
	changes, which triggers the container to invalidate.

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
interface ILayout extends IEventDispatcher {
	/**
		Positions and sizes an array of display objects based on their parent
		container's measurements. Returns new measurements, if the parent does
		not have explicit measurements.

		@since 1.0.0
	**/
	function layout(items:Array<DisplayObject>, measurements:Measurements, ?result:LayoutBoundsResult):LayoutBoundsResult;
}

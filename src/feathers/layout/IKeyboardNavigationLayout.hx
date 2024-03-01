/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import openfl.display.DisplayObject;
import openfl.events.KeyboardEvent;

/**
	A layout with custom behavior for navigating between items with the
	keyboard arrow keys, page up, page down, home, and end.

	@since 1.0.0
**/
interface IKeyboardNavigationLayout extends ILayout {
	/**
		Based on a starting index and the keyboard event, determine the next
		index. May return the starting index unchanged.

		@since 1.0.0
	**/
	public function findNextKeyboardIndex(startIndex:Int, event:KeyboardEvent, wrapArrowKeys:Bool, items:Array<DisplayObject>, indicesToSkip:Array<Int>,
		viewPortWidth:Float, viewPortHeight:Float):Int;
}

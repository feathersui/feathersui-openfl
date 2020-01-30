/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

/**
	Minimum requirements for a scroll bar to be usable with subclasses of the
	`BaseScrollContainer` component.

	@since 1.0.0
**/
interface IScrollBar extends IRange {
	/**
		The amount the value must change to increment or decrement by a "step".

		@since 1.0.0
	**/
	public var step(get, set):Float;

	/**
		The amount the scroll bar value must change to get from one "page" to
		the next.

		@since 1.0.0
	**/
	public var page(get, set):Float;
}

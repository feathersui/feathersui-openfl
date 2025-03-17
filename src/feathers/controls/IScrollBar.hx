/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

/**
	Minimum requirements for a scroll bar to be usable with subclasses of the
	`BaseScrollContainer` component.

	@event feathers.events.ScrollEvent.SCROLL_START Dispatched when scrolling
	starts.

	@event feathers.events.ScrollEvent.SCROLL_COMPLETE Dispatched when scrolling
	completes.

	@since 1.0.0
**/
@:event(feathers.events.ScrollEvent.SCROLL_START)
@:event(feathers.events.ScrollEvent.SCROLL_COMPLETE)
interface IScrollBar extends IRange {
	/**
		The amount the value must change to increment or decrement by a "step".

		The value should always be greater than `0.0` to ensure that the scroll
		bar reacts to keyboard events when focused, and to ensure that the
		increment and decrement buttons change the value when they are
		triggered.

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

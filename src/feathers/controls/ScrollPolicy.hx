/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

/**
	Constants that define whether a container that supports scrolling enables
	scrolling or not.

	@since 1.0.0
**/
enum ScrollPolicy {
	/**
		The container will always scroll. If the interaction mode is touch,
		elastic edges will always be active, even when the maximum scroll
		position is not greater than the minimum scroll position. If the scroll
		bar display mode is fixed, the scroll bar will always be visible.

		@since 1.0.0
	**/
	ON;

	/**
		The scroller does not scroll at all, even if the content is larger than
		the view port's bounds. The scroll bar will never be visible.

		@since 1.0.0
	**/
	OFF;

	/**
		The scroller may scroll if the content is larger than the view port's
		bounds. If the interaction mode is touch, the elastic edges will only be
		active if the maximum scroll position is greater than the minimum scroll
		position. Similarly, if the scroll bar display mode is fixed, the scroll
		bar will only be visible when the maximum scroll position is greater
		than the minimum scroll position.

		@since 1.0.0
	**/
	AUTO;
}

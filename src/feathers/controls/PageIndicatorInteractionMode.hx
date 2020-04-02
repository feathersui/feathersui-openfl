/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

/**
	Constants that define how the `PageIndicator` component changes between
	pages.

	@see `feathers.controls.PageIndicator`

	@since 1.0.0
**/
enum PageIndicatorInteractionMode {
	/**
		Clicking or tapping the page indicator to the left of the selected
		button will select the previous index, and to the right of the selected
		button will select the next index.

		@since 1.0.0
	**/
	PREVIOUS_NEXT;

	/**
		Clicking or tapping one of the page indicator's buttons will select
		that specific index.

		@since 1.0.0
	**/
	PRECISE;

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

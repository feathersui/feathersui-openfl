/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

/**
	Methods of updating the scrolling view port in containers.

	@see `feathers.controls.BaseScrollContainer`

	@since 1.0.0
**/
enum ScrollMode {
	/**
		The view port's `scrollRect` is set.

		@since 1.0.0
	**/
	SCROLL_RECT;

	/**
		The view port is given a `mask` and its `x` and `y` position are updated.

		@since 1.0.0
	**/
	MASK;
}

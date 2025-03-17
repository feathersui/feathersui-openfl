/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

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

	/**
		The view port's `x` and `y` position are updated, but it is not masked
		in any way. `MASKLESS` may have slightly better performance than `MASK`
		on some devices.

		Warning: Using `MASKLESS` may reveal some children outside of the bounds
		of the view port, if they are not obscured by other display objects.

		@since 1.0.0
	**/
	MASKLESS;
}

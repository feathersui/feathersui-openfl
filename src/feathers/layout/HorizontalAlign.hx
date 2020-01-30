/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

/**
	Constants for horizontal alignment (positioning along the x axis) of items
	in a layout.

	Note: Some constants may not be valid for certain properties. Please see
	the description of the property in the API reference for complete details.

	@since 1.0.0
**/
enum HorizontalAlign {
	/**
		The items in the layout will be horizontally aligned to the left of the
		bounds.

		@since 1.0.0
	**/
	LEFT;

	/**
		The items in the layout will be horizontally aligned to the center of
		the bounds.

		@since 1.0.0
	**/
	CENTER;

	/**
		The items in the layout will be horizontally aligned to the right of the
		bounds.

		@since 1.0.0
	**/
	RIGHT;

	/**
		The items in the layout will fill the width of the bounds.

		@since 1.0.0
	**/
	JUSTIFY;
}

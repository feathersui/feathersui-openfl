/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

/**
	Constants for vertical alignment (positioning along the y axis) of items in
	a layout.

	Note: Some constants may not be valid for certain properties. Please see
	the description of the property in the API reference for complete details.

	@since 1.0.0
**/
enum VerticalAlign {
	/**
		The items in the layout will be vertically aligned to the top of the
		bounds.

		@since 1.0.0
	**/
	TOP;

	/**
		The items in the layout will be vertically aligned to the middle of the
		bounds.

		@since 1.0.0
	**/
	MIDDLE;

	/**
		The items in the layout will be vertically aligned to the bottom of the
		bounds.

		@since 1.0.0
	**/
	BOTTOM;

	/**
		The items in the layout will fill the height of the bounds.

		@since 1.0.0
	**/
	JUSTIFY;
}

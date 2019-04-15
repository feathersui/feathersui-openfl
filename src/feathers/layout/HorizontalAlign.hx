/*
	Feathers
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

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
@:enum
abstract HorizontalAlign(String) {
	/**
		The items in the layout will be horizontally aligned to the left of the
		bounds.

		@since 1.0.0
	**/
	var LEFT = "left";

	/**
		The items in the layout will be horizontally aligned to the center of
		the bounds.

		@since 1.0.0
	**/
	var CENTER = "center";

	/**
		The items in the layout will be horizontally aligned to the right of the
		bounds.

		@since 1.0.0
	**/
	var RIGHT = "right";

	/**
		The items in the layout will fill the width of the bounds.

		@since 1.0.0
	**/
	var JUSTIFY = "justify";
}

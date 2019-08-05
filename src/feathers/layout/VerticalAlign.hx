/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

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
@:enum
abstract VerticalAlign(String) {
	/**
		The items in the layout will be vertically aligned to the top of the
		bounds.

		@since 1.0.0
	**/
	var TOP = "top";

	/**
		The items in the layout will be vertically aligned to the middle of the
		bounds.

		@since 1.0.0
	**/
	var MIDDLE = "middle";

	/**
		The items in the layout will be vertically aligned to the bottom of the
		bounds.

		@since 1.0.0
	**/
	var BOTTOM = "bottom";

	/**
		The items in the layout will fill the height of the bounds.

		@since 1.0.0
	**/
	var JUSTIFY = "justify";
}

/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

/**
	Constants for positioning an item relative to another item in a layout.

	Note: Some constants may not be valid for certain properties. Please see
	the description of the property in the API reference for complete details.

	@since 1.0.0
**/
@:enum
abstract RelativePosition(String) {
	/**
		The item will be positioned above another item.

		@since 1.0.0
	**/
	var TOP = "top";

	/**
		The item will be positioned to the right of another item.

		@since 1.0.0
	**/
	var RIGHT = "right";

	/**
		The item will be positioned below another item.

		@since 1.0.0
	**/
	var BOTTOM = "bottom";

	/**
		The item will be positioned to the left of another item.

		@since 1.0.0
	**/
	var LEFT = "left";

	/**
		The item will be positioned manually with no relation to the position of
		another item. Additional properties may be available to manually set the
		`x` and `y` position of the item.

		@since 1.0.0
	**/
	var MANUAL = "manual";
}

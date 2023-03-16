/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

/**
	Interface for column data in components like `GridView` and `TreeGridView`.

	@since 1.0.0
**/
interface IGridViewColumn {
	/**
		The width of the column, measured in pixels.

		In the following example, the column's width is customized.

		```haxe
		column.width = 120.0;
		```

		@since 1.0.0
	**/
	public var width:Null<Float>;

	/**
		The minimum width of the column, measured in pixels.

		If the `width` is specified explicitly, then the `minWidth` will be
		ignored.

		In the following example, the column's minimum width is customized.

		```haxe
		column.minWidth = 120.0;
		```

		@since 1.0.0
	**/
	public var minWidth:Float;
}

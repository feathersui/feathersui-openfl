/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

interface IGridViewColumn {
	/**
		The width of the column, measured in pixels.

		In the following example, the column's width is customized.

		```hx
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

		```hx
		column.minWidth = 120.0;
		```

		@since 1.0.0
	**/
	public var minWidth:Float;
}

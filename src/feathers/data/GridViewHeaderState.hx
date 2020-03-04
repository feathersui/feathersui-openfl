/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.data;

import feathers.controls.GridViewColumn;

/**
	Represents the current state of a `GridView` header renderer.

	@see `feathers.controls.GridView`
	@see `feathers.controls.GridView.headerRendererRecycler`
	@see `feathers.controls.GridViewColumn`
	@see `feathers.controls.GridViewColumn.headerRendererRecycler`

	@since 1.0.0
**/
class GridViewHeaderState {
	/**
		Creates a new `GridViewHeaderState` object with the given arguments.

		@since 1.0.0
	**/
	public function new(column:GridViewColumn = null, columnIndex:Int = -1, text:String = null) {
		this.column = column;
		this.columnIndex = columnIndex;
		this.text = text;
	}

	/**
		An item from the collection displayed by the `GridView`.

		@since 1.0.0
	**/
	public var column(default, null):GridViewColumn;

	/**
		The horizontal position of the header within the `GridView`.

		@since 1.0.0
	**/
	public var columnIndex(default, null):Int;

	/**
		Returns the text to display for the header, as returned by the function
		`GridViewColumn.headerText`.

		@see `feathers.controls.GridViewColumn.headerText`

		@since 1.0.0
	**/
	public var text(default, null):String;
}

/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.data;

import feathers.controls.GridViewColumn;

/**
	Represents the current state of a `GridView` cell renderer.

	@see `feathers.controls.GridView`
	@see `feathers.controls.GridView.cellRendererRecycler`
	@see `feathers.controls.GridViewColumn`
	@see `feathers.controls.GridViewColumn.cellRendererRecycler`

	@since 1.0.0
**/
class GridViewCellState {
	/**
		Creates a new `GridViewCellState` object with the given arguments.

		@since 1.0.0
	**/
	public function new(data:Dynamic = null, rowIndex:Int = -1, columnIndex:Int = -1, selected:Bool = false, text:String = null) {
		this.data = data;
		this.rowIndex = rowIndex;
		this.columnIndex = columnIndex;
		this.selected = false;
		this.text = text;
	}

	/**
		An row from the collection displayed by the `GridView`.

		@since 1.0.0
	**/
	public var data(default, null):Dynamic;

	/**
		The vertical position of the cell within the `GridView`.

		@since 1.0.0
	**/
	public var rowIndex(default, null):Int;

	/**
		The horizontal position of the cell within the `GridView`.

		@since 1.0.0
	**/
	public var columnIndex(default, null):Int;

	/**
		The column of the cell.

		@since 1.0.0
	**/
	public var column(default, null):GridViewColumn;

	/**
		Returns whether the cell is selected or not.

		@see `feathers.controls.GridView.selectedIndex`
		@see `feathers.controls.GridView.selectedItem`

		@since 1.0.0
	**/
	public var selected(default, null):Bool;

	/**
		Returns the text to display for the cell, as returned by the function
		`GridViewColumn.itemToText`.

		@see `feathers.controls.GridViewColumn.itemToText`

		@since 1.0.0
	**/
	public var text(default, null):String;
}

/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.data;

import feathers.controls.TreeGridView;
import feathers.controls.TreeGridViewColumn;

/**
	Represents the current state of a `TreeGridView` cell renderer.

	@see `feathers.controls.TreeGridView`
	@see `feathers.controls.TreeGridView.cellRendererRecycler`
	@see `feathers.controls.TreeGridViewColumn`
	@see `feathers.controls.TreeGridViewColumn.cellRendererRecycler`

	@since 1.0.0
**/
class TreeGridViewCellState {
	/**
		Creates a new `TreeGridViewCellState` object with the given arguments.

		@since 1.0.0
	**/
	public function new(data:Dynamic = null, rowLocation:Array<Int> = null, columnIndex:Int = -1, layoutIndex:Int = -1, branch:Bool = false,
			opened:Bool = false, selected:Bool = false, text:String = null) {
		this.data = data;
		this.rowLocation = rowLocation;
		this.columnIndex = columnIndex;
		this.layoutIndex = layoutIndex;
		this.branch = branch;
		this.opened = opened;
		this.selected = false;
		this.text = text;
	}

	/**
		Returns a reference to the `TreeGridView` that contains this cell.

		@since 1.0.0
	**/
	public var owner:TreeGridView;

	/**
		An row from the collection displayed by the `TreeGridView`.

		@since 1.0.0
	**/
	public var data:Dynamic;

	/**
		The vertical position of the cell within the `TreeGridView`.

		@since 1.0.0
	**/
	public var rowLocation:Array<Int> = null;

	/**
		The horizontal position of the cell within the `TreeGridView`.

		@since 1.0.0
	**/
	public var columnIndex:Int = -1;

	/**
		Returns the location of the item in the `TreeGridView` layout.

		@since 1.0.0
	**/
	public var layoutIndex:Int = -1;

	/**
		Returns whether the item is a branch or not.

		@since 1.0.0
	**/
	public var branch:Bool = false;

	/**
		Returns whether the branch is opened or closed. If the item is a leaf,
		the value will always be `false`.

		@since 1.0.0
	**/
	public var opened:Bool = false;

	/**
		The column of the cell.

		@since 1.0.0
	**/
	public var column:TreeGridViewColumn;

	/**
		Returns whether the cell is selected or not.

		@see `feathers.controls.TreeGridView.selectedIndex`
		@see `feathers.controls.TreeGridView.selectedItem`

		@since 1.0.0
	**/
	public var selected:Bool = false;

	/**
		Returns the text to display for the cell, as returned by the function
		`TreeGridViewColumn.itemToText`.

		@see `feathers.controls.TreeGridViewColumn.itemToText`

		@since 1.0.0
	**/
	public var text:String;

	/**
		Returns whether the item is enabled or not.

		@see `feathers.core.IUIControl.enabled`

		@since 1.0.0
	**/
	public var enabled:Bool = true;
}

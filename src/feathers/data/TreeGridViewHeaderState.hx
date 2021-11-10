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
	Represents the current state of a `TreeGridView` header renderer.

	@see `feathers.controls.TreeGridView`
	@see `feathers.controls.TreeGridView.headerRendererRecycler`
	@see `feathers.controls.TreeGridViewColumn`
	@see `feathers.controls.TreeGridViewColumn.headerRendererRecycler`

	@since 1.0.0
**/
class TreeGridViewHeaderState {
	/**
		Creates a new `TreeGridViewHeaderState` object with the given arguments.

		@since 1.0.0
	**/
	public function new(column:TreeGridViewColumn = null, columnIndex:Int = -1, text:String = null) {
		this.column = column;
		this.columnIndex = columnIndex;
		this.text = text;
	}

	/**
		Returns a reference to the `TreeGridView` that contains this header.

		@since 1.0.0
	**/
	public var owner:TreeGridView;

	/**
		An item from the collection displayed by the `TreeGridView`.

		@since 1.0.0
	**/
	public var column:TreeGridViewColumn;

	/**
		The horizontal position of the header within the `TreeGridView`.

		@since 1.0.0
	**/
	public var columnIndex:Int = -1;

	/**
		Returns the text to display for the header, as returned by the function
		`TreeGridViewColumn.headerText`.

		@see `feathers.controls.TreeGridViewColumn.headerText`

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

/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.dataRenderers;

import feathers.core.IUIControl;

/**
	A header renderer optimized for the `TreeGridView` component.

	@see `feathers.controls.TreeGridView`

	@since 1.0.0
**/
interface ITreeGridViewHeaderRenderer extends IUIControl {
	/**
		The column rendered by this header.

		@since 1.0.0
	**/
	@:flash.property
	public var column(get, set):TreeGridViewColumn;

	/**
		The index of the column.

		@since 1.0.0
	**/
	@:flash.property
	public var columnIndex(get, set):Int;

	/**
		The `TreeGridView` that contains this header renderer.

		@since 1.0.0
	**/
	@:flash.property
	public var treeGridViewOwner(get, set):TreeGridView;
}

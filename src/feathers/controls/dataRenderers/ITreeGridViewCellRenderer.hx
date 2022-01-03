/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.dataRenderers;

/**
	A cell renderer optimized for the `TreeGridView` component.

	@see `feathers.controls.TreeGridView`

	@since 1.0.0
**/
interface ITreeGridViewCellRenderer extends IHierarchicalItemRenderer {
	/**
		The column rendered by this cell.

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
		The location of the row.

		@since 1.0.0
	**/
	@:flash.property
	public var rowLocation(get, set):Array<Int>;

	/**
		The `TreeGridView` that contains this cell renderer.

		@since 1.0.0
	**/
	@:flash.property
	public var treeGridViewOwner(get, set):TreeGridView;
}

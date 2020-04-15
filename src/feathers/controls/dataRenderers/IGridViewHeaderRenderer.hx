/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.dataRenderers;

import feathers.core.IUIControl;

/**
	A header renderer optimized for the `GridView` component.

	@see `feathers.controls.GridView`

	@since 1.0.0
**/
interface IGridViewHeaderRenderer extends IUIControl {
	/**
		The column rendered by this header.

		@since 1.0.0
	**/
	public var column(get, set):GridViewColumn;

	/**
		The index of the column.

		@since 1.0.0
	**/
	public var columnIndex(get, set):Int;
}

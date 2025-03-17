/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.dataRenderers;

import feathers.core.IUIControl;

/**
	An item renderer optimized for the `ListView` component.

	@since 1.0.0
**/
interface IListViewItemRenderer extends IUIControl {
	/**
		The index of the item in the data provider of the `ListView`.

		@since 1.0.0
	**/
	public var index(get, set):Int;

	/**
		The `ListView` that contains this item renderer.

		@since 1.0.0
	**/
	public var listViewOwner(get, set):ListView;
}

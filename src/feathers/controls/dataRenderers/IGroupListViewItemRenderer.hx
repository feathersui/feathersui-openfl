/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.dataRenderers;

import feathers.core.IUIControl;

/**
	An item renderer optimized for the `GroupListView` component.

	@since 1.0.0
**/
interface IGroupListViewItemRenderer extends IUIControl {
	/**
		The location of the item in the data provider of the `GroupListView`.

		@since 1.0.0
	**/
	@:flash.property
	public var location(get, set):Array<Int>;

	/**
		The `GroupListView` that contains this item renderer.

		@since 1.0.0
	**/
	@:flash.property
	public var groupListViewOwner(get, set):GroupListView;
}

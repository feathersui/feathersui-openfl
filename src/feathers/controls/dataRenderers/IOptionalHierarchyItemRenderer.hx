/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.dataRenderers;

import feathers.core.IUIControl;

/**
	An item renderer for hierarchical data containers that may optionally hide
	any indicators that it is rendered in a hierarchy. Used by `TreeGridView`
	to differentiate between the first column and other columns.

	@see `feathers.controls.TreeGridView`

	@since 1.0.0
**/
interface IOptionalHierarchyItemRenderer extends IUIControl {
	/**
		Indicates if this item renderer should show indicators of its hierarchy,
		such as a disclosure button and indentation.

		@since 1.0.0
	**/
	@:flash.property
	public var showHierarchy(get, set):Bool;
}

/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.dataRenderers;

import feathers.core.IUIControl;

/**
	An item renderer optimized for hierarchical data.

	@see `feathers.controls.TreeView`

	@since 1.0.0
**/
interface IHierarchicalItemRenderer extends IUIControl {
	/**
		Indicates if the item renderer is a branch or a leaf.

		@since 1.0.0
	**/
	public var branch(get, set):Bool;
}

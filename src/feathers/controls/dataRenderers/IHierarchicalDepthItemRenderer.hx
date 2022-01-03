/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.dataRenderers;

import feathers.core.IUIControl;

/**
	An item renderer that appears with a hierarchical collection and has
	awareness of its depth. A common use would be to determine how far to indent
	the content of items that are deeper in the hierarchy.

	@see `feathers.controls.TreeView`
	@see `feathers.controls.TreeGridView`

	@since 1.0.0
**/
interface IHierarchicalDepthItemRenderer extends IUIControl {
	/**
		Indicates if depth of the item renderer's data within the hierarchical
		collection.

		@since 1.0.0
	**/
	@:flash.property
	public var hierarchyDepth(get, set):Int;
}

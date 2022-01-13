/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.dataRenderers;

/**
	An item renderer optimized for the `TreeView` component.

	@see `feathers.controls.TreeView`

	@since 1.0.0
**/
interface ITreeViewItemRenderer extends IHierarchicalItemRenderer {
	/**
		The location of the item in the data provider of the `TreeView`.

		@since 1.0.0
	**/
	public var location(get, set):Array<Int>;

	/**
		The `TreeView` that contains this header renderer.

		@since 1.0.0
	**/
	public var treeViewOwner(get, set):TreeView;
}

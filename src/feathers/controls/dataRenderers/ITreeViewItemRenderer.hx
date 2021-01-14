/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.dataRenderers;

import feathers.core.IUIControl;

/**
	An item renderer optimized for the `TreeView` component.

	@see `feathers.controls.TreeView`

	@since 1.0.0
**/
interface ITreeViewItemRenderer extends IUIControl {
	/**
		The location of the item in the data provider of the `TreeView`.

		@since 1.0.0
	**/
	@:flash.property
	public var location(get, set):Array<Int>;

	/**
		Indicates if the item renderer is a branch or a leaf.

		@since 1.0.0
	**/
	@:flash.property
	public var branch(get, set):Bool;

	/**
		The `TreeView` that contains this header renderer.

		@since 1.0.0
	**/
	@:flash.property
	public var treeViewOwner(get, set):TreeView;
}

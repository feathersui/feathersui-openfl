/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.dataRenderers;

import feathers.core.IUIControl;

/**
	An item renderer optimized for the `Menu` component.

	@since 1.4.0
**/
interface IMenuItemRenderer extends IUIControl {
	/**
		The index of the item in the data provider of the `Menu`.

		@since 1.4.0
	**/
	public var index(get, set):Int;

	/**
		The `MenuBar` that contains this item renderer. A `Menu` is not required
		to be added to a `MenuBar, so this value may be `null`.

		@since 1.4.0
	**/
	public var menuBarOwner(get, set):MenuBar;

	/**
		The `Menu` that contains this item renderer.

		@since 1.4.0
	**/
	public var menuOwner(get, set):Menu;
}

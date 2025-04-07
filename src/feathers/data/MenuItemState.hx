/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.data;

import feathers.controls.Menu;
import feathers.controls.MenuBar;

/**
	Represents the current state of a `Menu` or `MenuBar` item renderer.

	@see `feathers.controls.Menu`
	@see `feathers.controls.Menu.itemRendererRecycler`
	@see `feathers.controls.MenuBar`
	@see `feathers.controls.MenuBar.itemRendererRecycler`

	@since 1.4.0
**/
class MenuItemState {
	/**
		Creates a new `MenuItemState` object with the given arguments.

		@since 1.4.0
	**/
	public function new(data:Dynamic = null, index:Int = -1, text:String = null) {
		this.data = data;
		this.index = index;
		this.text = text;
	}

	/**
		Returns a reference to the `MenuBar` that contains this menu item. A
		`Menu` is not required to be associated with a `MenuBar`, so this value
		may be `null`.

		@since 1.4.0
	**/
	public var menuBarOwner:MenuBar;

	/**
		Returns a reference to the `Menu` that contains this item. A menu item
		may be added to a `MenuBar` instead of a `Menu`, so this value may be
		`null`.

		@since 1.4.0
	**/
	public var menuOwner:Menu;

	/**
		An item from the collection used as the `Menu` data provider.

		@since 1.4.0
	**/
	public var data:Dynamic;

	/**
		The position of the data within the collection used as the `Menu`
		data provider.

		@since 1.4.0
	**/
	public var index:Int = -1;

	/**
		Returns the text to display for the item, as returned by the function
		`MenuBar.itemToText` or `Menu.itemToText`.

		@see `feathers.controls.MenuBar.itemToText`
		@see `feathers.controls.Menu.itemToText`

		@since 1.4.0
	**/
	public var text:String;

	/**
		Returns whether the item is enabled or not.

		@see `feathers.core.IUIControl.enabled`

		@since 1.4.0
	**/
	public var enabled:Bool = true;

	/**
		Returns whether the item is selected or not.

		@see `feathers.core.IToggle.enabled`

		@since 1.4.0
	**/
	public var selected:Bool = false;

	/**
		Returns whether the item is a branch or not.

		@since 1.4.0
	**/
	public var branch:Bool = false;

	/**
		Returns whether the item is a separator or not.

		@since 1.4.0
	**/
	public var separator:Bool = false;

	/**
		Returns the item's recycler ID.

		@see `feathers.controls.MenuBar.itemRendererRecyclerIDFunction`
		@see `feathers.controls.Menu.itemRendererRecyclerIDFunction`

		@since 1.4.0
	**/
	public var recyclerID:String;
}

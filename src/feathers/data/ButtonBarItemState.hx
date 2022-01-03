/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.data;

import feathers.controls.ButtonBar;

/**
	Represents the current state of a `ButtonBar` button renderer.

	@see `feathers.controls.ButtonBar`
	@see `feathers.controls.ButtonBar.buttonRecycler`

	@since 1.0.0
**/
class ButtonBarItemState {
	/**
		Creates a new `ButtonBarItemState` object with the given arguments.

		@since 1.0.0
	**/
	public function new(data:Dynamic = null, index:Int = -1, text:String = null) {
		this.data = data;
		this.index = index;
		this.text = text;
	}

	/**
		Returns a reference to the `ButtonBar` that contains this item.

		@since 1.0.0
	**/
	public var owner:ButtonBar;

	/**
		An item from the collection used as the `ButtonBar` data provider.

		@since 1.0.0
	**/
	public var data:Dynamic;

	/**
		The position of the data within the collection used as the `ButtonBar`
		data provider.

		@since 1.0.0
	**/
	public var index:Int = -1;

	/**
		Returns the text to display for the item, as returned by the function
		`ButtonBar.itemToText`.

		@see `feathers.controls.ButtonBar.itemToText`

		@since 1.0.0
	**/
	public var text:String;

	/**
		Returns whether the item is enabled or not.

		@see `feathers.core.IUIControl.enabled`

		@since 1.0.0
	**/
	public var enabled:Bool = true;

	/**
		Returns the item's recycler ID.

		@see `feathers.controls.ButtonBar.buttonRecyclerIDFunction`

		@since 1.0.0
	**/
	public var recyclerID:String;
}

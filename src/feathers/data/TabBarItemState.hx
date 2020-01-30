/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.data;

/**
	Represents the current state of a `TabBar` tab renderer.

	@see `feathers.controls.TabBar`
	@see `feathers.controls.TabBar.tabRecycler`

	@since 1.0.0
**/
class TabBarItemState {
	/**
		Creates a new `TabBarItemState` object with the given arguments.

		@since 1.0.0
	**/
	public function new(data:Dynamic = null, index:Int = -1, selected:Bool = false, text:String = null) {
		this.data = data;
		this.index = index;
		this.selected = false;
		this.text = text;
	}

	/**
		An item from the collection used as the `TabBar` data provider.

		@since 1.0.0
	**/
	public var data(default, null):Dynamic;

	/**
		The position of the data within the collection used as the `TabBar`
		data provider.

		@since 1.0.0
	**/
	public var index(default, null):Int;

	/**
		Returns whether the item is selected or not.

		@see `feathers.controls.TabBar.selectedIndex`
		@see `feathers.controls.TabBar.selectedItem`

		@since 1.0.0
	**/
	public var selected(default, null):Bool;

	/**
		Returns the text to display for the item, as returned by the function
		`TabBar.itemToText`.

		@see `feathers.controls.TabBar.itemToText`

		@since 1.0.0
	**/
	public var text(default, null):String;
}

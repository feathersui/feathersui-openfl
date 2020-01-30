/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.data;

/**
	Represents the current state of a `ListView` item renderer.

	@see `feathers.controls.ListView`
	@see `feathers.controls.ListView.itemRendererRecycler`

	@since 1.0.0
**/
class ListViewItemState {
	/**
		Creates a new `ListViewItemState` object with the given arguments.

		@since 1.0.0
	**/
	public function new(data:Dynamic = null, index:Int = -1, selected:Bool = false, text:String = null) {
		this.data = data;
		this.index = index;
		this.selected = false;
		this.text = text;
	}

	/**
		An item from the collection used as the `ListView` data provider.

		@since 1.0.0
	**/
	public var data(default, null):Dynamic;

	/**
		The position of the data within the collection used as the `ListView`
		data provider.

		@since 1.0.0
	**/
	public var index(default, null):Int;

	/**
		Returns whether the item is selected or not.

		@see `feathers.controls.ListView.selectedIndex`
		@see `feathers.controls.ListView.selectedItem`

		@since 1.0.0
	**/
	public var selected(default, null):Bool;

	/**
		Returns the text to display for the item, as returned by the function
		`ListView.itemToText`.

		@see `feathers.controls.ListView.itemToText`

		@since 1.0.0
	**/
	public var text(default, null):String;
}

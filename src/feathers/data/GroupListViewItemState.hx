/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.data;

import feathers.controls.GroupListView;

/**
	Represents the current state of a `GroupListView` item renderer.

	@see `feathers.controls.GroupListView`
	@see `feathers.controls.GroupListView.itemRendererRecycler`

	@since 1.0.0
**/
class GroupListViewItemState {
	/**
		Creates a new `TreeViewItemState` object with the given arguments.

		@since 1.0.0
	**/
	public function new(type:GroupListViewItemType = STANDARD, data:Dynamic = null, location:Array<Int> = null, layoutIndex:Int = -1, selected:Bool = false,
			text:String = null) {
		this.type = type;
		this.data = data;
		this.location = location;
		this.layoutIndex = layoutIndex;
		this.selected = false;
		this.text = text;
	}

	/**
		Returns a reference to the `GroupListView` that contains this item.

		@since 1.0.0
	**/
	public var owner:GroupListView;

	/**
		The type of item that this state represents.

		@since 1.0.0
	**/
	public var type:GroupListViewItemType;

	/**
		An item from the collection used as the `GroupListView` data provider.

		@since 1.0.0
	**/
	public var data:Dynamic;

	/**
		The location of the item in the `GroupListView` data provider.

		@since 1.0.0
	**/
	public var location:Array<Int>;

	/**
		Returns the location of the item in the `GroupListView` layout.

		@since 1.0.0
	**/
	public var layoutIndex:Int;

	/**
		Returns whether the item is selected or not.

		@since 1.0.0
	**/
	public var selected:Bool;

	/**
		Returns the text to display for the item, as returned by the function
		`GroupListView.itemToText`.

		@see `feathers.controls.GroupListView.itemToText`

		@since 1.0.0
	**/
	public var text:String;
}

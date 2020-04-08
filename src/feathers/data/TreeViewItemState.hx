/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.data;

/**
	Represents the current state of a `TreeView` item renderer.

	@see `feathers.controls.TreeView`
	@see `feathers.controls.TreeView.itemRendererRecycler`

	@since 1.0.0
**/
class TreeViewItemState {
	/**
		Creates a new `TreeViewItemState` object with the given arguments.

		@since 1.0.0
	**/
	public function new(data:Dynamic = null, location:Array<Int> = null, layoutIndex:Int = -1, branch:Bool = false, selected:Bool = false,
			text:String = null) {
		this.data = data;
		this.location = location;
		this.layoutIndex = layoutIndex;
		this.branch = branch;
		this.selected = false;
		this.text = text;
	}

	/**
		An item from the collection used as the `TreeView` data provider.

		@since 1.0.0
	**/
	public var data(default, null):Dynamic;

	/**
		The location of the item in the `TreeView` data provider.

		@since 1.0.0
	**/
	public var location(default, null):Array<Int>;

	/**
		Returns the location of the item in the `TreeView` layout.

		@since 1.0.0
	**/
	public var layoutIndex(default, null):Int;

	/**
		Returns whether the item is a branch or not.

		@since 1.0.0
	**/
	public var branch(default, null):Bool;

	/**
		Returns whether the branch is opened or closed. If the item is a leaf,
		the value will always be `false`.

		@since 1.0.0
	**/
	public var opened(default, null):Bool;

	/**
		Returns whether the item is selected or not.

		@since 1.0.0
	**/
	public var selected(default, null):Bool;

	/**
		Returns the text to display for the item, as returned by the function
		`TreeView.itemToText`.

		@see `feathers.controls.TreeView.itemToText`

		@since 1.0.0
	**/
	public var text(default, null):String;
}

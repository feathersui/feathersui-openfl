/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

/**
	A layout algorithm that supports _virtualization_ of items. In other words,
	only the items that are visible need to be created as display objects, and
	those outside of the view port bounds are represented with empty space until
	they are scrolled into view. Useful in components like `ListView`,
	`TreeView`, or `GridView` where dozens or hundreds of items are needed, but
	only a small subset of them are visible at any given moment.

	@since 1.0.0
**/
interface IVirtualLayout extends IScrollLayout {
	/**
		Used by the layout to store additional data for virtual items (items
		that are not currently represeted by display objects). For instance, it
		might store the width and height of an item so that this value may be
		used to calculate the total layout dimensions when the item is out of
		bounds.

		@since 1.0.0
	**/
	var virtualCache(get, set):Array<Dynamic>;

	/**
		Used internally by a UI component (such as `ListView`, `TreeView`, or
		`GridView`) to determine which indices are visible with the specified
		view port bounds and scroll position. Indices that aren't included in
		the result typically do not receive display objects to represent them.

		@see `IScrollLayout.scrollX`
		@see `IScrollLayout.scrollY`

		@since 1.0.0
	**/
	function getVisibleIndices(itemCount:Int, width:Float, height:Float, ?result:VirtualLayoutRange):VirtualLayoutRange;
}

/**
	The range of items currently displayed by a virtual layout.

	@since 1.0.0
**/
class VirtualLayoutRange {
	/**
		Creates a `VirtualLayoutRange` object with the given arguments.
	**/
	public function new(start:Int, end:Int) {
		this.start = start;
		this.end = end;
	}

	/**
		The start index of the range.

		@since 1.0.0
	**/
	public var start:Int;

	/**
		The end index of the range.

		@since 1.0.0
	**/
	public var end:Int;
}

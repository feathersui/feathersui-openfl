/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.data.GridViewCellState;
import feathers.data.SortOrder;
import feathers.utils.AbstractDisplayObjectRecycler;
import openfl.display.DisplayObject;
import openfl.events.EventDispatcher;

/**
	Configures a column in a `GridView` component.

	@see `feathers.controls.GridView`

	@since 1.0.0
**/
class GridViewColumn extends EventDispatcher implements IGridViewColumn {
	/**
		Creates a new `GridViewColumn` object with the given arguments.

		@since 1.0.0
	**/
	public function new(?headerText:String, ?itemToText:(Dynamic) -> String, ?width:Float) {
		super();
		this.headerText = headerText;
		if (itemToText != null) {
			this.itemToText = itemToText;
		}
		this.width = width;
	}

	/**
		The text to display in the column's header.

		In the following example, the column's header text is customized.

		```haxe
		column.headerText = "Name";
		```

		@since 1.0.0
	**/
	public var headerText:String;

	/**
		The width of the column, measured in pixels.

		In the following example, the column's width is customized.

		```haxe
		column.width = 120.0;
		```

		@since 1.0.0
	**/
	public var width:Null<Float> = null;

	/**
		The minimum width of the column, measured in pixels.

		If the `width` is specified explicitly, then the `minWidth` will be
		ignored.

		In the following example, the column's minimum width is customized.

		```haxe
		column.minWidth = 120.0;
		```

		@since 1.0.0
	**/
	public var minWidth:Float = 0.0;

	/**
		Manages cell renderers used by this grid view column.

		In the following example, the column uses a custom cell renderer class:

		```haxe
		column.cellRendererRecycler = DisplayObjectRecycler.withClass(CustomCellRenderer);
		```

		@see `feathers.controls.GridView.cellRendererRecycler`

		@since 1.0.0
	**/
	public var cellRendererRecycler:AbstractDisplayObjectRecycler<Dynamic, GridViewCellState, DisplayObject> = null;

	/**

		A function to compare each item in the collection to determine the
		order when sorted.

		The return value should be `-1` if the first item should appear before
		the second item when the collection is sorted. The return value should
		be `1` if the first item should appear after the second item when the
		collection in sorted. Finally, the return value should be `0` if both
		items have the same sort order.

		@see `GridViewColumn.defaultSortOrder`
		@see `feathers.controls.GridView.sortableColumns`

		@since 1.0.0
	**/
	public var sortCompareFunction:(Dynamic, Dynamic) -> Int = null;

	/**
		Indicates if the column may be sorted by triggering the header renderer,
		and which direction it should be sorted by default (ascending or
		descending).

		Setting this property will not start a sort. It only provides the
		initial order of the sort when triggered by the user.

		If the `sortableColumns` property of the `GridView` is `false`, it takes
		precendence over this property, and the column will not be sortable by
		the user under any circumstances.

		The following example disables sorting of a column:

		```haxe
		column.defaultSortOrder = SortOrder.NONE;
		```

		@see `feathers.controls.GridView.sortableColumns`
		@see `GridViewColumn.sortCompareFunction`
		@see `feathers.data.SortOrder.ASCENDING`
		@see `feathers.data.SortOrder.DESCENDING`
		@see `feathers.data.SortOrder.NONE`

		@since 1.0.0
	**/
	public var defaultSortOrder:SortOrder = ASCENDING;

	/**
		Converts an item to text to display within a grid view cell. By default,
		the `toString()` method is called to convert an item to text. This
		method may be replaced to provide custom text.

		For example, consider the following item:

		```haxe
		{ text: "Example Item" }
		```

		If the grid view cell should display the text "Example Item", a custom
		implementation of `itemToText()` might look like this:

		```haxe
		column.itemToText = (item:Dynamic) -> {
			return item.text;
		};
		```

		@since 1.0.0
	**/
	public dynamic function itemToText(data:Dynamic):String {
		return Std.string(data);
	}
}

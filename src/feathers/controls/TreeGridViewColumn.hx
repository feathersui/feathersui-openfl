/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.data.TreeGridViewCellState;
import feathers.utils.AbstractDisplayObjectRecycler;
import feathers.utils.DisplayObjectRecycler;
import openfl.display.DisplayObject;
import openfl.events.EventDispatcher;

/**
	Configures a column in a `TreeGridView` component.

	@see `feathers.controls.TreeGridView`

	@since 1.0.0
**/
class TreeGridViewColumn extends EventDispatcher implements IGridViewColumn {
	/**
		Creates a new `TreeGridViewColumn` object with the given arguments.

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

		@see `feathers.controls.TreeGridView.cellRendererRecycler`

		@since 1.0.0
	**/
	public var cellRendererRecycler:AbstractDisplayObjectRecycler<Dynamic, TreeGridViewCellState, DisplayObject> = null;

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

/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.data.TreeGridViewCellState;
import feathers.data.TreeGridViewHeaderState;
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
	private static var CURRENT_COLUMN_ID = 0;

	/**
		Creates a new `TreeGridViewColumn` object with the given arguments.

		@since 1.0.0
	**/
	public function new(?headerText:String, ?itemToText:(Dynamic) -> String, ?width:Float) {
		super();
		this.__columnID = CURRENT_COLUMN_ID;
		CURRENT_COLUMN_ID++;
		this.headerText = headerText;
		if (itemToText != null) {
			this.itemToText = itemToText;
		}
		this.width = width;
	}

	@:noCompletion private var __columnID:Int;

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
		@see `feathers.controls.dataRenderers.HierarchicalItemRenderer`
		@see `feathers.controls.dataRenderers.LayoutGroupItemRenderer`

		@since 1.0.0
	**/
	public var cellRendererRecycler:AbstractDisplayObjectRecycler<Dynamic, TreeGridViewCellState, DisplayObject> = null;

	/**
		Manages the header renderer used by this tree grid view column.

		In the following example, the column uses a custom header renderer class:

		```haxe
		column.headerRendererRecycler = DisplayObjectRecycler.withClass(CustomHeaderRenderer);
		```

		@see `feathers.controls.TreeGridView.headerRendererRecycler`
		@see `feathers.controls.dataRenderers.SortOrderHeaderRenderer`
		@see `feathers.controls.dataRenderers.LayoutGroupItemRenderer`

		@since 1.4.0
	**/
	public var headerRendererRecycler:AbstractDisplayObjectRecycler<Dynamic, TreeGridViewHeaderState, DisplayObject> = null;

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

	private var _recyclerMap:Map<String, DisplayObjectRecycler<Dynamic, TreeGridViewCellState, DisplayObject>> = null;

	/**
		Returns the item renderer recycler associated with a specific ID.
		Returns `null` if no recycler is associated with the ID.

		@see `TreeGridViewColumn.cellRendererRecyclerIDFunction`
		@see `TreeGridViewColumn.setCellRendererRecycler()`

		@since 1.4.0
	**/
	public function getCellRendererRecycler(id:String):DisplayObjectRecycler<Dynamic, TreeGridViewCellState, DisplayObject> {
		if (this._recyclerMap == null) {
			return null;
		}
		return this._recyclerMap.get(id);
	}

	/**
		Associates a cell renderer recycler with an ID to allow multiple types
		of cell renderers may be displayed in the grid view column. A custom
		`cellRendererRecyclerIDFunction` may be specified to return the ID of
		the recycler to use for a specific item in the data provider.

		To clear a recycler, pass in `null` for the value.

		@see `TreeGridViewColumn.cellRendererRecyclerIDFunction`
		@see `TreeGridViewColumn.getCellRendererRecycler()`

		@since 1.4.0
	**/
	public function setCellRendererRecycler(id:String, recycler:AbstractDisplayObjectRecycler<Dynamic, TreeGridViewCellState, DisplayObject>):Void {
		if (this._recyclerMap == null) {
			this._recyclerMap = [];
		}
		if (recycler == null) {
			this._recyclerMap.remove(id);
			return;
		}
		this._recyclerMap.set(id, recycler);
	}

	/**
		When a grid view column requires multiple cell renderer types, this
		function is used to determine which type of cell renderer is required
		for a specific item. Returns the ID of the cell renderer recycler to use
		for the item, or `null` if the default `cellRendererRecycler` should be
		used.

		The following example provides an `cellRendererRecyclerIDFunction`:

		```haxe
		var regularItemRecycler = DisplayObjectRecycler.withClass(HierarchicalItemRenderer);
		var firstItemRecycler = DisplayObjectRecycler.withClass(MyCustomItemRenderer);
		column.setCellRendererRecycler("regular-item", regularItemRecycler);
		column.setCellRendererRecycler("first-item", firstItemRecycler);
		column.cellRendererRecyclerIDFunction = function(state:TreeGridViewCellState):String {
			if(state.rowIndex == 0) {
				return "first-item";
			}
			return "regular-item";
		};
		```

		@default null

		@see `TreeGridViewColumn.setCellRendererRecycler()`
		@see `TreeGridViewColumn.itemRendererRecycler

		@since 1.4.0
	**/
	public var cellRendererRecyclerIDFunction:(state:TreeGridViewCellState) -> String;
}

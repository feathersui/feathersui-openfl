/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import openfl.display.InteractiveObject;
import openfl.display.DisplayObjectContainer;
import feathers.controls.dataRenderers.CellRenderer;
import feathers.controls.dataRenderers.GridViewRowRenderer;
import feathers.controls.dataRenderers.IGridViewHeaderRenderer;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.controls.supportClasses.AdvancedLayoutViewPort;
import feathers.controls.supportClasses.BaseScrollContainer;
import feathers.core.IDataSelector;
import feathers.core.IIndexSelector;
import feathers.core.ITextControl;
import feathers.core.IUIControl;
import feathers.data.ArrayCollection;
import feathers.data.GridViewCellState;
import feathers.data.GridViewHeaderState;
import feathers.data.IFlatCollection;
import feathers.events.FeathersEvent;
import feathers.events.FlatCollectionEvent;
import feathers.events.GridViewEvent;
import feathers.events.TriggerEvent;
import feathers.layout.GridViewRowLayout;
import feathers.layout.ILayout;
import feathers.layout.IScrollLayout;
import feathers.layout.IVirtualLayout;
import feathers.layout.VerticalListFixedRowLayout;
import feathers.skins.IProgrammaticSkin;
import feathers.style.IVariantStyleObject;
import feathers.themes.steel.components.SteelGridViewStyles;
import feathers.utils.DisplayObjectRecycler;
import haxe.ds.ObjectMap;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.errors.IllegalOperationError;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
import openfl.ui.Keyboard;

@:event(openfl.events.Event.CHANGE)

/**
	Displays a list of items as a table. Each item is rendered as a row, divided
	into columns for each of the item's fields. Supports scrolling, custom cell,
	sorting columns, resizing columns, and drag and drop re-ordering of columns.

	The following example creates a grid view, gives it a data provider, tells
	the columns how to interpret the data, and listens for when the selection
	changes:

	```hx
	var gridView = new GridView();

	gridView.dataProvider = new ArrayCollection([
		{ item: "Chicken breast", dept: "Meat", price: "5.90" },
		{ item: "Butter", dept: "Dairy", price: "4.69" },
		{ item: "Broccoli", dept: "Produce", price: "2.99" },
		{ item: "Whole Wheat Bread", dept: "Bakery", price: "2.49" }
	]);
	gridView.columns = new ArrayCollection([
		new GridViewColumn("Item", (data) -> data.item),
		new GridViewColumn("Department", (data) -> data.dept),
		new GridViewColumn("Price", (data) -> data.price)
	]);

	gridView.addEventListener(Event.CHANGE, (event:Event) -> {
		var gridView = cast(event.currentTarget, GridView);
		trace("GridView changed: " + gridView.selectedIndex + " " + gridView.selectedItem.item);
	});

	this.addChild(gridView);
	```

	@see [Tutorial: How to use the GridView component](https://feathersui.com/learn/haxe-openfl/grid-view/)

	@since 1.0.0
**/
@:access(feathers.data.GridViewHeaderState)
@:styleContext
class GridView extends BaseScrollContainer implements IIndexSelector implements IDataSelector<Dynamic> {
	/**
		A variant used to style the grid view without a border. The variant is
		used by default on mobile.

		The following example uses this variant:

		```hx
		var gridView = new GridView();
		gridView.variant = GridView.VARIANT_BORDERLESS;
		```

		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final VARIANT_BORDERLESS = "borderless";

	/**
		A variant used to style the grid view with a border. This variant is
		used by default on desktop.

		The following example uses this variant:

		```hx
		var gridView = new GridView();
		gridView.variant = GridView.VARIANT_BORDER;
		```

		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final VARIANT_BORDER = "border";

	/**
		The variant used to style the column headers in a theme.

		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_HEADER = "gridView_header";

	private static final INVALIDATION_FLAG_HEADER_RENDERER_FACTORY = InvalidationFlag.CUSTOM("headerRendererFactory");

	private static function defaultUpdateHeaderRenderer(headerRenderer:DisplayObject, state:GridViewHeaderState):Void {
		if (Std.is(headerRenderer, ITextControl)) {
			var textControl = cast(headerRenderer, ITextControl);
			textControl.text = state.text;
		}
	}

	private static function defaultResetHeaderRenderer(headerRenderer:DisplayObject, state:GridViewHeaderState):Void {
		if (Std.is(headerRenderer, ITextControl)) {
			var textControl = cast(headerRenderer, ITextControl);
			textControl.text = null;
		}
	}

	/**
		Creates a new `GridView` object.

		@since 1.0.0
	**/
	public function new() {
		initializeGridViewTheme();

		super();

		this.tabEnabled = true;
		this.focusRect = null;

		if (this.viewPort == null) {
			this.gridViewPort = new AdvancedLayoutViewPort();
			this.addChild(this.gridViewPort);
			this.viewPort = this.gridViewPort;
		}
	}

	private var _headerContainer:LayoutGroup;
	private var _headerContainerLayout:GridViewRowLayout;
	private var _headerResizeContainer:Sprite;
	private var _activeHeaderDividers:Array<DisplayObject> = [];
	private var _resizingHeaderIndex:Int = -1;
	private var _resizingHeaderStartStageX:Float;
	private var _customColumnWidths:Array<Float>;

	override private function get_focusEnabled():Bool {
		return (this._selectable || this.maxScrollY != this.minScrollY || this.maxScrollX != this.minScrollX)
			&& this._enabled
			&& this._focusEnabled;
	}

	private var gridViewPort:AdvancedLayoutViewPort;

	private var _dataProvider:IFlatCollection<Dynamic> = null;

	/**
		The collection of data displayed by the grid view.

		The following example passes in a data provider and tells the columns
		how to interpret the data:

		```hx
		gridView.dataProvider = new ArrayCollection([
			{ item: "Chicken breast", dept: "Meat", price: "5.90" },
			{ item: "Butter", dept: "Dairy", price: "4.69" },
			{ item: "Broccoli", dept: "Produce", price: "2.99" },
			{ item: "Whole Wheat Bread", dept: "Bakery", price: "2.49" }
		]);
		gridView.columns = new ArrayCollection([
			new GridViewColumn("Item", (data) -> data.item),
			new GridViewColumn("Department", (data) -> data.dept),
			new GridViewColumn("Price", (data) -> data.price)
		]);
		```

		@default null

		@see `feathers.data.ArrayCollection`

		@since 1.0.0
	**/
	@:flash.property
	public var dataProvider(get, set):IFlatCollection<Dynamic>;

	private function get_dataProvider():IFlatCollection<Dynamic> {
		return this._dataProvider;
	}

	private function set_dataProvider(value:IFlatCollection<Dynamic>):IFlatCollection<Dynamic> {
		if (this._dataProvider == value) {
			return this._dataProvider;
		}
		this._virtualCache.resize(0);
		if (this._dataProvider != null) {
			this._dataProvider.removeEventListener(Event.CHANGE, gridView_dataProvider_changeHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.ADD_ITEM, gridView_dataProvider_addItemHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.REMOVE_ITEM, gridView_dataProvider_removeItemHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.REPLACE_ITEM, gridView_dataProvider_replaceItemHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.REMOVE_ALL, gridView_dataProvider_removeAllHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.RESET, gridView_dataProvider_resetHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.SORT_CHANGE, gridView_dataProvider_sortChangeHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.FILTER_CHANGE, gridView_dataProvider_filterChangeHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.UPDATE_ITEM, gridView_dataProvider_updateItemHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.UPDATE_ALL, gridView_dataProvider_updateAllHandler);
		}
		this._dataProvider = value;
		if (this._dataProvider != null) {
			this._virtualCache.resize(this._dataProvider.length);
			this._dataProvider.addEventListener(Event.CHANGE, gridView_dataProvider_changeHandler);
			this._dataProvider.addEventListener(FlatCollectionEvent.ADD_ITEM, gridView_dataProvider_addItemHandler);
			this._dataProvider.addEventListener(FlatCollectionEvent.REMOVE_ITEM, gridView_dataProvider_removeItemHandler);
			this._dataProvider.addEventListener(FlatCollectionEvent.REPLACE_ITEM, gridView_dataProvider_replaceItemHandler);
			this._dataProvider.addEventListener(FlatCollectionEvent.REMOVE_ALL, gridView_dataProvider_removeAllHandler);
			this._dataProvider.addEventListener(FlatCollectionEvent.RESET, gridView_dataProvider_resetHandler);
			this._dataProvider.addEventListener(FlatCollectionEvent.SORT_CHANGE, gridView_dataProvider_sortChangeHandler);
			this._dataProvider.addEventListener(FlatCollectionEvent.FILTER_CHANGE, gridView_dataProvider_filterChangeHandler);
			this._dataProvider.addEventListener(FlatCollectionEvent.UPDATE_ITEM, gridView_dataProvider_updateItemHandler);
			this._dataProvider.addEventListener(FlatCollectionEvent.UPDATE_ALL, gridView_dataProvider_updateAllHandler);
		}

		// reset the scroll position because this is a drastic change and
		// the data is probably completely different
		this.scrollX = 0.0;
		this.scrollY = 0.0;

		// clear the selection for the same reason
		this.selectedIndex = -1;

		this.setInvalid(DATA);
		return this._dataProvider;
	}

	private var _columns:IFlatCollection<GridViewColumn> = null;

	/**
		Defines the set of columns to display for each item in the grid view's
		data provider. If `null`, the grid view will attempt to populate the
		columns automatically using
		[reflection](https://haxe.org/manual/std-reflection.html).

		The following example passes in a data provider and tells the columns
		how to interpret the data:

		```hx
		gridView.dataProvider = new ArrayCollection([
			{ item: "Chicken breast", dept: "Meat", price: "5.90" },
			{ item: "Butter", dept: "Dairy", price: "4.69" },
			{ item: "Broccoli", dept: "Produce", price: "2.99" },
			{ item: "Whole Wheat Bread", dept: "Bakery", price: "2.49" }
		]);
		gridView.columns = new ArrayCollection([
			new GridViewColumn("Item", (data) -> data.item),
			new GridViewColumn("Department", (data) -> data.dept),
			new GridViewColumn("Price", (data) -> data.price)
		]);
		```

		@default null

		@see `GridView.dataProvider`
		@see `feathers.controls.GridViewColumn`

		@since 1.0.0
	**/
	@:flash.property
	public var columns(get, set):IFlatCollection<GridViewColumn>;

	private function get_columns():IFlatCollection<GridViewColumn> {
		return this._columns;
	}

	private function set_columns(value:IFlatCollection<GridViewColumn>):IFlatCollection<GridViewColumn> {
		if (this._columns == value) {
			return this._columns;
		}
		if (this._columns != null) {
			this._columns.removeEventListener(Event.CHANGE, gridView_columns_changeHandler);
		}
		this._columns = value;
		if (this._columns != null) {
			this._columns.addEventListener(Event.CHANGE, gridView_columns_changeHandler);
		}
		this.setInvalid(DATA);
		return this._columns;
	}

	private var _oldHeaderRendererRecycler:DisplayObjectRecycler<Dynamic, GridViewHeaderState, DisplayObject> = null;

	private var _headerRendererRecycler:DisplayObjectRecycler<Dynamic, GridViewHeaderState, DisplayObject> = DisplayObjectRecycler.withFunction(() -> {
		var headerRenderer = new ItemRenderer();
		headerRenderer.toggleable = false;
		return headerRenderer;
	});

	/**
		Manages header renderers used by the grid view.

		In the following example, the grid view uses a custom header renderer
		class:

		```hx
		gridView.headerRendererRecycler = DisplayObjectRecycler.withClass(CustomHeaderRenderer);
		```

		@since 1.0.0
	**/
	@:flash.property
	public var headerRendererRecycler(get, set):DisplayObjectRecycler<Dynamic, GridViewHeaderState, DisplayObject>;

	private function get_headerRendererRecycler():DisplayObjectRecycler<Dynamic, GridViewHeaderState, DisplayObject> {
		return this._headerRendererRecycler;
	}

	private function set_headerRendererRecycler(value:DisplayObjectRecycler<Dynamic, GridViewHeaderState, DisplayObject>):DisplayObjectRecycler<Dynamic,
		GridViewHeaderState, DisplayObject> {
		if (this._headerRendererRecycler == value) {
			return this._headerRendererRecycler;
		}
		this._oldHeaderRendererRecycler = this._headerRendererRecycler;
		this._headerRendererRecycler = value;
		this.setInvalid(INVALIDATION_FLAG_HEADER_RENDERER_FACTORY);
		return this._headerRendererRecycler;
	}

	private var _rowRendererRecycler:DisplayObjectRecycler<Dynamic, Dynamic, DisplayObject> = DisplayObjectRecycler.withClass(GridViewRowRenderer);

	private var _selectedIndex:Int = -1;

	/**
		@see `feathers.core.IIndexSelector.selectedIndex`
	**/
	@:flash.property
	public var selectedIndex(get, set):Int;

	private function get_selectedIndex():Int {
		return this._selectedIndex;
	}

	private function set_selectedIndex(value:Int):Int {
		if (!this._selectable || this._dataProvider == null) {
			value = -1;
		}
		if (this._selectedIndex == value && this._selectedIndices.length <= 1) {
			return this._selectedIndex;
		}
		if (value == -1) {
			this._selectionAnchorIndex = -1;
			this._selectedIndex = -1;
			this._selectedItem = null;
			this._selectedIndices.resize(0);
			this._selectedItems.resize(0);
			this.setInvalid(SELECTION);
			FeathersEvent.dispatch(this, Event.CHANGE);
			return this._selectedIndex;
		}
		this._selectedIndex = value;
		this._selectedItem = this._dataProvider.get(this._selectedIndex);
		this._selectedIndices.resize(1);
		this._selectedIndices[0] = this._selectedIndex;
		this._selectedItems.resize(1);
		this._selectedItems[0] = this._selectedItem;
		this._selectionAnchorIndex = this._selectedIndex;
		this.setInvalid(SELECTION);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._selectedIndex;
	}

	/**
		@see `feathers.core.IIndexSelector.maxSelectedIndex`
	**/
	@:flash.property
	public var maxSelectedIndex(get, never):Int;

	private function get_maxSelectedIndex():Int {
		if (this._dataProvider == null) {
			return -1;
		}
		return this._dataProvider.length - 1;
	}

	private var _selectedItem:Dynamic = null;

	/**
		@see `feathers.core.IDataSelector.selectedItem`
	**/
	@:flash.property
	public var selectedItem(get, set):Dynamic;

	private function get_selectedItem():Dynamic {
		return this._selectedItem;
	}

	private function set_selectedItem(value:Dynamic):Dynamic {
		if (value == null || !this._selectable || this._dataProvider == null) {
			// use the setter
			this.selectedIndex = -1;
			return this._selectedItem;
		}
		var index = this._dataProvider.indexOf(value);
		if (index == -1) {
			// use the setter
			this.selectedIndex = -1;
			return this._selectedItem;
		}
		if (this._selectedIndex == index && this._selectedIndices.length <= 0) {
			return this._selectedItem;
		}
		this._selectedIndex = index;
		this._selectedItem = value;
		this._selectedIndices.resize(1);
		this._selectedIndices[0] = this._selectedIndex;
		this._selectedItems.resize(1);
		this._selectedItems[0] = this._selectedItem;
		this._selectionAnchorIndex = this._selectedIndex;
		this.setInvalid(SELECTION);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._selectedIndex;
	}

	private var _allowMultipleSelection:Bool = false;

	/**
		Determines if multiple items may be selected at the same time. Has no
		effect if `selectable` is `false`.

		In the following example, multiple selection is enabled:

		```hx
		gridView.allowMultipleSelection = true;
		```

		@see `GridView.selectable`
		@see `GridView.selectedIndices`
		@see `GridView.selectedItems`

		@since 1.0.0
	**/
	@:flash.property
	public var allowMultipleSelection(get, set):Bool;

	private function get_allowMultipleSelection():Bool {
		return this._allowMultipleSelection;
	}

	private function set_allowMultipleSelection(value:Bool):Bool {
		if (this._allowMultipleSelection == value) {
			return this._allowMultipleSelection;
		}
		this._allowMultipleSelection = value;
		this.setInvalid(SELECTION);
		return this._allowMultipleSelection;
	}

	private var _selectionAnchorIndex:Int = -1;

	private var _selectedIndices:Array<Int> = [];

	/**
		Contains all of the indices that are currently selected. The most
		recently selected index will appear at the beginning of the array. In
		other words, the indices are in the reverse order that they were
		selected by the user.

		When the `selectedIndices` array contains multiple items, the
		`selectedIndex` property will return the first item from
		`selectedIndices`.

		@see `GridView.allowMultipleSelection`
		@see `GridView.selectedItems`

		@since 1.0.0
	**/
	@:flash.property
	public var selectedIndices(get, set):Array<Int>;

	private function get_selectedIndices():Array<Int> {
		return this._selectedIndices;
	}

	private function set_selectedIndices(value:Array<Int>):Array<Int> {
		if (value == null || value.length == 0 || !this._selectable || this._dataProvider == null) {
			// use the setter
			this.selectedIndex = -1;
			return this._selectedIndices;
		}
		if (this._selectedIndices == value) {
			return this._selectedIndices;
		}
		if (!this._allowMultipleSelection && value.length > 1) {
			value.resize(1);
		}
		this._selectedIndices = value;
		this._selectedIndex = this._selectedIndices[0];
		this._selectedItems.resize(this._selectedIndices.length);
		for (i in 0...this._selectedIndices.length) {
			var index = this._selectedIndices[i];
			this._selectedItems[i] = this._dataProvider.get(index);
		}
		this._selectedItem = this._selectedItems[0];
		this._selectionAnchorIndex = this._selectedIndex;
		this.setInvalid(SELECTION);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._selectedIndices;
	}

	private var _selectedItems:Array<Dynamic> = [];

	/**
		Contains all of the items that are currently selected. The most
		recently selected item will appear at the beginning of the array. In
		other words, the items are in the reverse order that they were
		selected by the user.

		When the `selectedItems` array contains multiple items, the
		`selectedItem` property will return the first item from `selectedItems`.

		@see `GridView.allowMultipleSelection`
		@see `GridView.selectedIndices`

		@since 1.0.0
	**/
	@:flash.property
	public var selectedItems(get, set):Array<Dynamic>;

	private function get_selectedItems():Array<Dynamic> {
		return this._selectedItems;
	}

	private function set_selectedItems(value:Array<Dynamic>):Array<Dynamic> {
		if (value == null || value.length == 0 || !this._selectable || this._dataProvider == null) {
			// use the setter
			this.selectedIndex = -1;
			return this._selectedItems;
		}
		if (this._selectedItems == value) {
			return this._selectedItems;
		}
		if (!this._allowMultipleSelection && value.length > 1) {
			value.resize(1);
		}
		var indices:Array<Int> = [];
		var i = 0;
		while (i < value.length) {
			var item = value[i];
			var index = this._dataProvider.indexOf(item);
			if (index == -1) {
				value.splice(i, 1);
				continue;
			}
			indices.push(index);
			i++;
		}
		this._selectedIndices = indices;
		this._selectedItems = value;
		if (value.length == 0) {
			this._selectedIndex = -1;
			this._selectedItem = null;
		} else {
			this._selectedIndex = this._selectedIndices[0];
			this._selectedItem = this._selectedItems[0];
		}
		this._selectionAnchorIndex = this._selectedIndex;
		this.setInvalid(SELECTION);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._selectedIndices;
	}

	private var _layout:ILayout;

	private var _virtualLayout:Bool = true;

	/**
		Indicates if the grid view's layout is allowed to virtualize items or
		not.

		The following example disables virtual layouts:

		```hx
		gridView.virtualLayout = false;
		```

		@since 1.0.0
	**/
	@:flash.property
	public var virtualLayout(get, set):Bool;

	private function get_virtualLayout():Bool {
		return this._virtualLayout;
	}

	private function set_virtualLayout(value:Bool):Bool {
		if (this._virtualLayout = value) {
			return this._virtualLayout;
		}
		this._virtualLayout = value;
		this.setInvalid(LAYOUT);
		return this._virtualLayout;
	}

	private var _cellRendererRecycler:DisplayObjectRecycler<Dynamic, GridViewCellState, DisplayObject> = DisplayObjectRecycler.withClass(CellRenderer);

	/**
		Manages cell renderers used by the grid view.

		In the following example, the grid view uses a custom cell renderer
		class:

		```hx
		gridView.cellRendererRecycler = DisplayObjectRecycler.withClass(CustomCellRenderer);
		```

		@since 1.0.0
	**/
	@:flash.property
	public var cellRendererRecycler(get, set):DisplayObjectRecycler<Dynamic, GridViewCellState, DisplayObject>;

	private function get_cellRendererRecycler():DisplayObjectRecycler<Dynamic, GridViewCellState, DisplayObject> {
		return this._cellRendererRecycler;
	}

	private function set_cellRendererRecycler(value:DisplayObjectRecycler<Dynamic, GridViewCellState, DisplayObject>):DisplayObjectRecycler<Dynamic,
		GridViewCellState, DisplayObject> {
		if (this._cellRendererRecycler == value) {
			return this._cellRendererRecycler;
		}
		this._cellRendererRecycler = value;
		this.setInvalid(DATA);
		return this._cellRendererRecycler;
	}

	private var _resizableColumns:Bool = false;

	/**
		Determines if the grid view's columns may be resized by mouse/touch.

		The following example enables column resizing:

		```hx
		gridView.resizableColumns = true;
		```

		@see `GridView.columnResizeSkin`

		@default false
	**/
	@:flash.property
	public var resizableColumns(get, set):Bool;

	private function get_resizableColumns():Bool {
		return this._resizableColumns;
	}

	private function set_resizableColumns(value:Bool):Bool {
		if (this._resizableColumns == value) {
			return this._resizableColumns;
		}
		this._resizableColumns = value;
		this.setInvalid(LAYOUT);
		return this._resizableColumns;
	}

	private var _currentColumnResizeSkin:DisplayObject;

	/**
		The skin to display when a column is being resized.

		@see `GridView.resizableColumns`

		@since 1.0.0
	**/
	@:style
	public var columnResizeSkin:DisplayObject = null;

	private var activeHeaderRenderers:Array<DisplayObject> = [];
	private var dataToHeaderRenderer = new ObjectMap<GridViewColumn, DisplayObject>();
	private var headerRendererToData = new ObjectMap<DisplayObject, GridViewColumn>();
	private var inactiveRowRenderers:Array<GridViewRowRenderer> = [];
	private var activeRowRenderers:Array<GridViewRowRenderer> = [];
	private var dataToRowRenderer = new ObjectMap<Dynamic, GridViewRowRenderer>();
	private var rowRendererToData = new ObjectMap<GridViewRowRenderer, Dynamic>();
	private var _unrenderedData:Array<Dynamic> = [];
	private var _layoutItems:Array<DisplayObject> = [];
	private var _virtualCache:Array<Dynamic> = [];
	private var _visibleIndices:VirtualLayoutRange = new VirtualLayoutRange(0, 0);

	private var _currentHeaderState:GridViewHeaderState = new GridViewHeaderState();

	private var _selectable:Bool = true;

	/**
		Determines if items in the grid view may be selected. By default only a
		single item may be selected at any given time. In other words, if item
		_A_ is already selected, and the user selects item _B_, item _A_ will be
		deselected automatically.

		The following example disables selection of items in the grid view:

		```hx
		gridView.selectable = false;
		```

		@default true

		@see `GridView.selectedItem`
		@see `GridView.selectedIndex`
	**/
	@:flash.property
	public var selectable(get, set):Bool;

	private function get_selectable():Bool {
		return this._selectable;
	}

	private function set_selectable(value:Bool):Bool {
		if (this._selectable == value) {
			return this._selectable;
		}
		this._selectable = value;
		if (!this._selectable) {
			// use the setter
			this.selectedIndex = -1;
		}
		return this._selectable;
	}

	private var _ignoreSelectionChange = false;

	/**
		Scrolls the grid view so that the specified row is completely visible.
		If the row is already completely visible, does not update the scroll
		position.

		A custom animation duration may be specified. To update the scroll
		position without animation, pass a value of `0.0` for the duration.

		 @since 1.0.0
	**/
	public function scrollToRowIndex(rowIndex:Int, ?animationDuration:Float):Void {
		if (this._dataProvider == null || this._dataProvider.length == 0) {
			return;
		}

		var targetX = this.scrollX;
		var targetY = this.scrollY;
		if (Std.is(this._layout, IScrollLayout)) {
			var scrollLayout = cast(this._layout, IScrollLayout);
			var result = scrollLayout.getNearestScrollPositionForIndex(rowIndex, this._dataProvider.length, this.viewPort.visibleWidth,
				this.viewPort.visibleHeight);
			targetX = result.x;
			targetY = result.y;
		} else {
			var row = this._dataProvider.get(rowIndex);
			var rowRenderer = this.dataToRowRenderer.get(row);
			if (rowRenderer == null) {
				return;
			}

			var maxX = rowRenderer.x;
			var minX = maxX + rowRenderer.width - this.viewPort.visibleWidth;
			if (targetX < minX) {
				targetX = minX;
			} else if (targetX > maxX) {
				targetX = maxX;
			}

			var maxY = rowRenderer.y;
			var minY = maxY + rowRenderer.height - this.viewPort.visibleHeight;
			if (targetY < minY) {
				targetY = minY;
			} else if (targetY > maxY) {
				targetY = maxY;
			}
		}
		this.scroller.scrollX = targetX;
		this.scroller.scrollY = targetY;
	}

	/**
		Returns the current header renderer used to render a specific column.

		@see `GridView.columns`

		@since 1.0.0
	**/
	public function columnToHeaderRenderer(column:GridViewColumn):DisplayObject {
		return this.dataToHeaderRenderer.get(column);
	}

	/**
		Returns the current column that is rendered by a specific header
		renderer.

		@see `GridView.columns`

		@since 1.0.0
	**/
	public function headerRendererToColumn(headerRenderer:DisplayObject):GridViewColumn {
		return this.headerRendererToData.get(headerRenderer);
	}

	private function initializeGridViewTheme():Void {
		SteelGridViewStyles.initialize();
	}

	override private function initialize():Void {
		super.initialize();

		if (this._headerContainerLayout == null) {
			this._headerContainerLayout = new GridViewRowLayout();
		}

		if (this._headerContainer == null) {
			this._headerContainer = new LayoutGroup();
			this._headerContainer.layout = this._headerContainerLayout;
			this.addChild(this._headerContainer);
		}

		if (this._headerResizeContainer == null) {
			this._headerResizeContainer = new Sprite();
			this.addChild(this._headerResizeContainer);
		}

		if (this._layout == null) {
			this._layout = new VerticalListFixedRowLayout();
		}
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(DATA);
		var layoutInvalid = this.isInvalid(LAYOUT);
		var selectionInvalid = this.isInvalid(SELECTION);
		var stateInvalid = this.isInvalid(STATE);
		var stylesInvalid = this.isInvalid(STYLES);
		var headerRendererInvalid = this.isInvalid(INVALIDATION_FLAG_HEADER_RENDERER_FACTORY);

		this.validateColumns();
		this.validateCustomColumnWidths();

		if (stylesInvalid || layoutInvalid) {
			this.refreshColumnResizeSkin();
		}

		if (headerRendererInvalid || stateInvalid || dataInvalid) {
			this.refreshHeaderRenderers();
		}

		if (layoutInvalid) {
			this._headerResizeContainer.mouseEnabled = this._resizableColumns;
			this._headerResizeContainer.mouseChildren = this._resizableColumns;
		}

		if (layoutInvalid || stylesInvalid) {
			this.gridViewPort.layout = this._layout;
		}

		this.gridViewPort.refreshChildren = this.refreshRowRenderers;

		for (flag in this._invalidationFlags.keys()) {
			this.gridViewPort.setInvalid(flag);
		}

		super.update();

		this.layoutHeaders();
	}

	override private function refreshScrollerValues():Void {
		super.refreshScrollerValues();
		if (Std.is(this._layout, IScrollLayout)) {
			var scrollLayout = cast(this._layout, IScrollLayout);
			this.scroller.forceElasticTop = scrollLayout.elasticTop;
			this.scroller.forceElasticRight = scrollLayout.elasticRight;
			this.scroller.forceElasticBottom = scrollLayout.elasticBottom;
			this.scroller.forceElasticLeft = scrollLayout.elasticLeft;
		} else {
			this.scroller.forceElasticTop = false;
			this.scroller.forceElasticRight = false;
			this.scroller.forceElasticBottom = false;
			this.scroller.forceElasticLeft = false;
		}
	}

	override private function calculateViewPortOffsets(forceScrollBars:Bool, useActualBounds:Bool):Void {
		if (this.fixedScrollBars && this.showScrollBars) {
			// this extra call may be needed for the left/right offsets?
			super.calculateViewPortOffsets(forceScrollBars, useActualBounds);
		}

		if (this._headerContainer != null) {
			switch (this.scrollBarYPosition) {
				case LEFT:
					this._headerContainerLayout.paddingLeft = this.leftViewPortOffset;
				default:
					this._headerContainerLayout.paddingRight = this.rightViewPortOffset;
			};

			this._headerContainer.validateNow();
			this.topViewPortOffset += this._headerContainer.height;
			this.chromeMeasuredWidth = Math.max(this.chromeMeasuredWidth, this._headerContainer.width);
			this.chromeMeasuredMinWidth = Math.max(this.chromeMeasuredMinWidth, this._headerContainer.width);
		}

		// call after measuring the headers because they affect the
		// topViewPortOffset used in
		super.calculateViewPortOffsets(forceScrollBars, useActualBounds);
	}

	private function validateColumns():Void {
		if (this._columns != null) {
			return;
		}
		if (this._dataProvider != null && this._dataProvider.length > 0) {
			var item = this._dataProvider.get(0);
			// use the setter
			this.columns = new ArrayCollection(Reflect.fields(item)
				.map((fieldName) -> new GridViewColumn(fieldName, (item) -> Reflect.getProperty(item, fieldName))));
		} else {
			// use the setter
			this.columns = new ArrayCollection();
		}
	}

	private function layoutHeaders():Void {
		if (this._headerContainer == null) {
			return;
		}
		this._headerContainerLayout.customColumnWidths = this._customColumnWidths;
		this._headerContainer.x = this.paddingLeft;
		this._headerContainer.y = this.paddingTop;
		this._headerContainer.width = this.actualWidth - this.paddingLeft - this.paddingRight;
		this._headerContainer.validateNow();

		this._headerResizeContainer.x = this._headerContainer.x;
		this._headerResizeContainer.y = this._headerContainer.y;
		for (i in 0...this._activeHeaderDividers.length) {
			var divider = this._activeHeaderDividers[i];
			var header = this.activeHeaderRenderers[i];
			divider.x = header.x + header.width - (divider.width / 2.0);
			divider.y = header.y;
			divider.height = header.height;
		}
	}

	private function refreshColumnResizeSkin():Void {
		var oldSkin = this._currentColumnResizeSkin;
		this._currentColumnResizeSkin = this.getCurrentColumnResizeSkin();
		if (this._currentColumnResizeSkin == oldSkin) {
			return;
		}
		this.removeCurrentColumnResizeSkin(oldSkin);
		if (this._currentColumnResizeSkin == null) {
			return;
		}
		if (Std.is(this._currentColumnResizeSkin, IUIControl)) {
			cast(this._currentColumnResizeSkin, IUIControl).initializeNow();
		}
		if (Std.is(this._currentColumnResizeSkin, IProgrammaticSkin)) {
			cast(this._currentColumnResizeSkin, IProgrammaticSkin).uiContext = this;
		}
		this._currentColumnResizeSkin.visible = false;
		if (Std.is(this._currentColumnResizeSkin, InteractiveObject)) {
			cast(this._currentColumnResizeSkin, InteractiveObject).mouseEnabled = false;
		}
		if (Std.is(this._currentColumnResizeSkin, DisplayObjectContainer)) {
			cast(this._currentColumnResizeSkin, DisplayObjectContainer).mouseChildren = false;
		}
		this.addChildAt(this._currentColumnResizeSkin, 0);
	}

	private function getCurrentColumnResizeSkin():DisplayObject {
		return this.columnResizeSkin;
	}

	private function removeCurrentColumnResizeSkin(skin:DisplayObject):Void {
		if (skin == null) {
			return;
		}
		if (Std.is(skin, IProgrammaticSkin)) {
			cast(skin, IProgrammaticSkin).uiContext = null;
		}
		if (skin.parent == this) {
			this.removeChild(skin);
		}
	}

	private function refreshHeaderRenderers():Void {
		this._headerContainerLayout.columns = this._columns;

		if (this._headerRendererRecycler.update == null) {
			this._headerRendererRecycler.update = defaultUpdateHeaderRenderer;
			if (this._headerRendererRecycler.reset == null) {
				this._headerRendererRecycler.reset = defaultResetHeaderRenderer;
			}
		}

		var recycler = this._oldHeaderRendererRecycler != null ? this._oldHeaderRendererRecycler : this._headerRendererRecycler;
		for (headerRenderer in this.activeHeaderRenderers) {
			var column = this.headerRendererToData.get(headerRenderer);
			this.headerRendererToData.remove(headerRenderer);
			this.dataToHeaderRenderer.remove(column);
			headerRenderer.removeEventListener(TriggerEvent.TRIGGER, gridView_headerRenderer_triggerHandler);
			headerRenderer.removeEventListener(MouseEvent.CLICK, gridView_headerRenderer_clickHandler);
			headerRenderer.removeEventListener(TouchEvent.TOUCH_TAP, gridView_headerRenderer_touchTapHandler);

			this._currentHeaderState.owner = this;
			this._currentHeaderState.column = column;
			this._currentHeaderState.columnIndex = -1;
			this._currentHeaderState.text = null;
			this._currentHeaderState.enabled = true;
			if (recycler != null && recycler.reset != null) {
				recycler.reset(headerRenderer, this._currentHeaderState);
			}
			if (Std.is(headerRenderer, IUIControl)) {
				var uiControl = cast(headerRenderer, IUIControl);
				uiControl.enabled = this._currentHeaderState.enabled;
			}
			if (Std.is(headerRenderer, IGridViewHeaderRenderer)) {
				var header = cast(headerRenderer, IGridViewHeaderRenderer);
				header.column = null;
				header.columnIndex = -1;
			}
			this.destroyHeaderRenderer(headerRenderer, recycler);
		}
		this._oldHeaderRendererRecycler = null;
		this.activeHeaderRenderers.resize(0);
		for (i in 0...this._columns.length) {
			var column = this._columns.get(i);
			var headerRenderer = this.createHeaderRenderer(column, i);
			this.activeHeaderRenderers.insert(i, headerRenderer);
			this._headerContainer.addChildAt(headerRenderer, i);
		}

		for (divider in this._activeHeaderDividers) {
			divider.removeEventListener(MouseEvent.MOUSE_DOWN, gridView_headerDivider_mouseDownHandler);
			this._headerResizeContainer.removeChild(divider);
		}
		this._activeHeaderDividers.resize(0);

		for (i in 0...this._columns.length - 1) {
			var divider = new Sprite();
			divider.graphics.clear();
			divider.graphics.beginFill(0xff00ff, 0.0);
			divider.graphics.drawRect(0.0, 0.0, 6.0, 1.0);
			divider.graphics.endFill();
			divider.addEventListener(MouseEvent.MOUSE_DOWN, gridView_headerDivider_mouseDownHandler);
			this._activeHeaderDividers.insert(i, divider);
			this._headerResizeContainer.addChildAt(divider, i);
		}
	}

	private function refreshRowRenderers(items:Array<DisplayObject>):Void {
		this._layoutItems = items;

		this.refreshInactiveRowRenderers();
		this.findUnrenderedData();
		this.recoverInactiveRowRenderers();
		this.renderUnrenderedData();
		this.freeInactiveRowRenderers();
		if (this.inactiveRowRenderers.length > 0) {
			throw new IllegalOperationError(Type.getClassName(Type.getClass(this)) + ": inactive row renderers should be empty after updating.");
		}
	}

	private function refreshInactiveRowRenderers():Void {
		var temp = this.inactiveRowRenderers;
		this.inactiveRowRenderers = this.activeRowRenderers;
		this.activeRowRenderers = temp;
		if (this.activeRowRenderers.length > 0) {
			throw new IllegalOperationError(Type.getClassName(Type.getClass(this)) + ": active row renderers should be empty before updating.");
		}
	}

	private function recoverInactiveRowRenderers():Void {
		for (rowRenderer in this.inactiveRowRenderers) {
			if (rowRenderer == null) {
				continue;
			}
			var item = this.rowRendererToData.get(rowRenderer);
			if (item == null) {
				return;
			}
			this.rowRendererToData.remove(rowRenderer);
			this.dataToRowRenderer.remove(item);
			rowRenderer.removeEventListener(GridViewEvent.CELL_TRIGGER, gridView_rowRenderer_cellTriggerHandler);
			rowRenderer.removeEventListener(TriggerEvent.TRIGGER, gridView_rowRenderer_triggerHandler);
			var oldIgnoreSelectionChange = this._ignoreSelectionChange;
			this._ignoreSelectionChange = true;
			if (this._rowRendererRecycler.reset != null) {
				this._rowRendererRecycler.reset(rowRenderer, null);
			}
			rowRenderer.selected = false;
			rowRenderer.data = null;
			rowRenderer.rowIndex = -1;
			rowRenderer.enabled = true;
			this._ignoreSelectionChange = oldIgnoreSelectionChange;
		}
	}

	private function freeInactiveRowRenderers():Void {
		for (rowRenderer in this.inactiveRowRenderers) {
			if (rowRenderer == null) {
				continue;
			}
			this.destroyRowRenderer(rowRenderer);
		}
		this.inactiveRowRenderers.resize(0);
	}

	private function findUnrenderedData():Void {
		// remove all old items, then fill with null
		this._layoutItems.resize(0);
		this._visibleIndices.start = 0;
		this._visibleIndices.end = 0;
		if (this._dataProvider == null || this._dataProvider.length == 0) {
			return;
		}
		this._layoutItems.resize(this._dataProvider.length);

		if (this._virtualLayout && Std.is(this._layout, IVirtualLayout)) {
			var virtualLayout = cast(this._layout, IVirtualLayout);
			virtualLayout.virtualCache = this._virtualCache;
			virtualLayout.getVisibleIndices(this._dataProvider.length, this.gridViewPort.visibleWidth, this.gridViewPort.visibleHeight, this._visibleIndices);
		} else {
			this._visibleIndices.start = 0;
			this._visibleIndices.end = this._dataProvider.length - 1;
		}
		if (this._dataProvider == null || this._dataProvider.length == 0) {
			return;
		}
		for (i in this._visibleIndices.start...this._visibleIndices.end + 1) {
			var item = this._dataProvider.get(i);
			var rowRenderer = this.dataToRowRenderer.get(item);
			if (rowRenderer != null) {
				var oldIgnoreSelectionChange = this._ignoreSelectionChange;
				this._ignoreSelectionChange = true;
				if (this._rowRendererRecycler.update != null) {
					this._rowRendererRecycler.update(rowRenderer, item);
				}
				this.refreshRowRendererProperties(rowRenderer, item, i);
				this._ignoreSelectionChange = oldIgnoreSelectionChange;
				this._layoutItems[i] = rowRenderer;
				var removed = this.inactiveRowRenderers.remove(rowRenderer);
				if (!removed) {
					throw new IllegalOperationError(Type.getClassName(Type.getClass(this))
						+ ": row renderer map contains bad data. This may be caused by duplicate items in the data provider, which is not allowed.");
				}
				this.activeRowRenderers.push(rowRenderer);
			} else {
				this._unrenderedData.push(item);
			}
		}
	}

	private function renderUnrenderedData():Void {
		for (item in this._unrenderedData) {
			var index = this._dataProvider.indexOf(item);
			var rowRenderer = this.createRowRenderer(item, index);
			rowRenderer.visible = true;
			this.activeRowRenderers.push(rowRenderer);
			this.gridViewPort.addChild(rowRenderer);
			this._layoutItems[index] = rowRenderer;
		}
		this._unrenderedData.resize(0);
	}

	private function createRowRenderer(item:Dynamic, index:Int):GridViewRowRenderer {
		var rowRenderer:GridViewRowRenderer = null;
		if (this.inactiveRowRenderers.length == 0) {
			rowRenderer = this._rowRendererRecycler.create();
		} else {
			rowRenderer = this.inactiveRowRenderers.shift();
		}
		if (this._rowRendererRecycler.update != null) {
			this._rowRendererRecycler.update(rowRenderer, item);
		}
		this.refreshRowRendererProperties(rowRenderer, item, index);
		rowRenderer.addEventListener(GridViewEvent.CELL_TRIGGER, gridView_rowRenderer_cellTriggerHandler);
		rowRenderer.addEventListener(TriggerEvent.TRIGGER, gridView_rowRenderer_triggerHandler);
		this.rowRendererToData.set(rowRenderer, item);
		this.dataToRowRenderer.set(item, rowRenderer);
		return rowRenderer;
	}

	private function destroyRowRenderer(rowRenderer:GridViewRowRenderer):Void {
		this.gridViewPort.removeChild(rowRenderer);
		if (this._rowRendererRecycler.destroy != null) {
			this._rowRendererRecycler.destroy(rowRenderer);
		}
	}

	private function refreshRowRendererProperties(rowRenderer:GridViewRowRenderer, item:Dynamic, index:Int):Void {
		rowRenderer.gridView = this;
		rowRenderer.data = item;
		rowRenderer.rowIndex = index;
		rowRenderer.selectable = this._selectable;
		rowRenderer.selected = this._selectedIndices.indexOf(index) != -1;
		rowRenderer.cellRendererRecycler = this._cellRendererRecycler;
		rowRenderer.columns = this._columns;
		rowRenderer.customColumnWidths = this._customColumnWidths;
		rowRenderer.enabled = this._enabled;
	}

	private function createHeaderRenderer(column:GridViewColumn, columnIndex:Int):DisplayObject {
		var headerRenderer:DisplayObject = null;
		headerRenderer = this._headerRendererRecycler.create();
		/*if (this.inactiveHeaderRenderers.length == 0) {
				rowRenderer = this._headerRendererRecycler.create();
			} else {
				rowRenderer = this.inactiveHeaderRenderers.shift();
		}*/
		var variantHeaderRenderer = cast(headerRenderer, IVariantStyleObject);
		if (variantHeaderRenderer.variant == null) {
			variantHeaderRenderer.variant = GridView.CHILD_VARIANT_HEADER;
		}
		this.refreshHeaderRendererProperties(headerRenderer, column, columnIndex);
		if (Std.is(headerRenderer, ITriggerView)) {
			// prefer TriggerEvent.TRIGGER
			headerRenderer.addEventListener(TriggerEvent.TRIGGER, gridView_headerRenderer_triggerHandler);
		} else {
			// fall back to these events if TriggerEvent.TRIGGER isn't available
			headerRenderer.addEventListener(MouseEvent.CLICK, gridView_headerRenderer_clickHandler);
			#if (openfl >= "9.0.0")
			headerRenderer.addEventListener(TouchEvent.TOUCH_TAP, gridView_headerRenderer_touchTapHandler);
			#end
		}
		this.headerRendererToData.set(headerRenderer, column);
		this.dataToHeaderRenderer.set(column, headerRenderer);
		return headerRenderer;
	}

	private function destroyHeaderRenderer(headerRenderer:DisplayObject, recycler:DisplayObjectRecycler<Dynamic, GridViewHeaderState, DisplayObject>):Void {
		this._headerContainer.removeChild(headerRenderer);
		if (recycler != null && recycler.destroy != null) {
			recycler.destroy(headerRenderer);
		}
	}

	private function populateCurrentItemState(column:GridViewColumn, columnIndex:Int):Void {
		this._currentHeaderState.owner = this;
		this._currentHeaderState.column = column;
		this._currentHeaderState.columnIndex = columnIndex;
		this._currentHeaderState.text = column.headerText;
		this._currentHeaderState.enabled = this._enabled;
	}

	private function refreshHeaderRendererProperties(headerRenderer:DisplayObject, column:GridViewColumn, columnIndex:Int):Void {
		this.populateCurrentItemState(column, columnIndex);
		if (this._headerRendererRecycler.update != null) {
			this._headerRendererRecycler.update(headerRenderer, this._currentHeaderState);
		}
		if (Std.is(headerRenderer, IUIControl)) {
			var uiControl = cast(headerRenderer, IUIControl);
			uiControl.enabled = this._currentHeaderState.enabled;
		}
		if (Std.is(headerRenderer, IGridViewHeaderRenderer)) {
			var header = cast(headerRenderer, IGridViewHeaderRenderer);
			header.column = this._currentHeaderState.column;
			header.columnIndex = this._currentHeaderState.columnIndex;
		}
	}

	private function refreshSelectedIndicesAfterFilterOrSort():Void {
		if (this._selectedIndex == -1) {
			return;
		}
		// the index may have changed, possibily even to -1, if the item was
		// filtered out
		this.selectedIndex = this._dataProvider.indexOf(this._selectedItem); // use the setter
	}

	private function navigateWithKeyboard(event:KeyboardEvent):Void {
		if (this._dataProvider == null || this._dataProvider.length == 0) {
			return;
		}
		var result = this._selectedIndex;
		switch (event.keyCode) {
			case Keyboard.UP:
				result = result - 1;
			case Keyboard.DOWN:
				result = result + 1;
			case Keyboard.LEFT:
				result = result - 1;
			case Keyboard.RIGHT:
				result = result + 1;
			case Keyboard.PAGE_UP:
				result = result - 1;
			case Keyboard.PAGE_DOWN:
				result = result + 1;
			case Keyboard.HOME:
				result = 0;
			case Keyboard.END:
				result = this._dataProvider.length - 1;
			default:
				// not keyboard navigation
				return;
		}
		if (result < 0) {
			result = 0;
		} else if (result >= this._dataProvider.length) {
			result = this._dataProvider.length - 1;
		}
		event.stopPropagation();
		// use the setter
		this.selectedIndex = result;
		if (this._selectedIndex != -1) {
			this.scrollToRowIndex(this._selectedIndex);
		}
	}

	override private function baseScrollContainer_keyDownHandler(event:KeyboardEvent):Void {
		if (!this._enabled || event.isDefaultPrevented()) {
			return;
		}
		this.navigateWithKeyboard(event);
	}

	private function dispatchHeaderTriggerEvent(column:GridViewColumn):Void {
		var columnIndex = this._columns.indexOf(column);
		this.populateCurrentItemState(column, columnIndex);
		GridViewEvent.dispatchForHeader(this, GridViewEvent.HEADER_TRIGGER, this._currentHeaderState);
	}

	private function handleSelectionChange(item:Dynamic, index:Int, ctrlKey:Bool, shiftKey:Bool):Void {
		if (index == -1 || !this._selectable) {
			// use the setter
			this.selectedItem = null;
			return;
		}
		var selectionIndex = this._selectedItems.indexOf(item);
		if (this._allowMultipleSelection && (ctrlKey || shiftKey)) {
			if (shiftKey) {
				var anchorIndex = this._selectionAnchorIndex;
				if (anchorIndex == -1) {
					anchorIndex = 0;
				}
				var selectedIndices:Array<Int> = [];
				if (index == anchorIndex) {
					selectedIndices.unshift(anchorIndex);
				} else {
					var i = anchorIndex;
					do {
						selectedIndices.unshift(i);
						i += (anchorIndex > index) ? -1 : 1;
					} while (i != index);
					if (index != anchorIndex) {
						selectedIndices.unshift(index);
					}
				}
				this.selectedIndices = selectedIndices;
				// make sure the anchor remains the same as before
				this._selectionAnchorIndex = anchorIndex;
			} else {
				if (selectionIndex == -1) {
					var selectedItems = this._selectedItems.copy();
					selectedItems.unshift(item);
					// use the setter
					this.selectedItems = selectedItems;
				} else {
					var selectedItems = this._selectedItems.copy();
					selectedItems.splice(selectionIndex, 1);
					// use the setter
					this.selectedItems = selectedItems;
				}
				// even if deselecting, this is the new anchor
				this._selectionAnchorIndex = index;
			}
		} else {
			// use the setter
			this.selectedItem = item;
		}
	}

	private function gridView_rowRenderer_triggerHandler(event:TriggerEvent):Void {
		var rowRenderer = cast(event.currentTarget, GridViewRowRenderer);
		var item = this.rowRendererToData.get(rowRenderer);
		this.handleSelectionChange(item, rowRenderer.rowIndex, event.ctrlKey, event.shiftKey);
	}

	private function gridView_rowRenderer_cellTriggerHandler(event:GridViewEvent<GridViewCellState>):Void {
		this.dispatchEvent(event.clone());
	}

	private function gridView_dataProvider_changeHandler(event:Event):Void {
		this.setInvalid(DATA);
	}

	private function gridView_dataProvider_addItemHandler(event:FlatCollectionEvent):Void {
		if (this._virtualCache != null) {
			this._virtualCache.insert(event.index, null);
		}
		if (this._selectedIndex == -1) {
			return;
		}
		if (this._selectedIndex <= event.index) {
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
	}

	private function gridView_dataProvider_removeItemHandler(event:FlatCollectionEvent):Void {
		if (this._virtualCache != null) {
			this._virtualCache.remove(event.index);
		}
		if (this._selectedIndex == -1) {
			return;
		}
		if (this._selectedIndex == event.index) {
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
	}

	private function gridView_dataProvider_replaceItemHandler(event:FlatCollectionEvent):Void {
		if (this._virtualCache != null) {
			this._virtualCache[event.index] = null;
		}
		if (this._selectedIndex == -1) {
			return;
		}
		if (this._selectedIndex == event.index) {
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
	}

	private function gridView_dataProvider_removeAllHandler(event:FlatCollectionEvent):Void {
		if (this._virtualCache != null) {
			this._virtualCache.resize(0);
		}
		// use the setter
		this.selectedIndex = -1;
	}

	private function gridView_dataProvider_resetHandler(event:FlatCollectionEvent):Void {
		if (this._virtualCache != null) {
			this._virtualCache.resize(0);
			this._virtualCache.resize(this._dataProvider.length);
		}
		// use the setter
		this.selectedIndex = -1;
	}

	private function gridView_dataProvider_sortChangeHandler(event:FlatCollectionEvent):Void {
		if (this._virtualCache != null) {
			// we don't know exactly which indices have changed, so reset the
			// whole cache.
			this._virtualCache.resize(0);
			this._virtualCache.resize(this._dataProvider.length);
		}
		this.refreshSelectedIndicesAfterFilterOrSort();
	}

	private function gridView_dataProvider_filterChangeHandler(event:FlatCollectionEvent):Void {
		if (this._virtualCache != null) {
			// we don't know exactly which indices have changed, so reset the
			// whole cache.
			this._virtualCache.resize(0);
			this._virtualCache.resize(this._dataProvider.length);
		}
		this.refreshSelectedIndicesAfterFilterOrSort();
	}

	private function updateRowRendererForIndex(index:Int):Void {
		var item = this._dataProvider.get(index);
		var rowRenderer = this.dataToRowRenderer.get(item);
		if (rowRenderer == null) {
			// doesn't exist yet, so we need to do a full invalidation
			this.setInvalid(DATA);
			return;
		}
		// in order to display the same item with modified properties, this
		// hack tricks the item renderer into thinking that it has been given
		// a different item to render.
		rowRenderer.data = null;
		this.refreshRowRendererProperties(rowRenderer, item, index);
	}

	private function validateCustomColumnWidths():Void {
		if (this._customColumnWidths == null || this._customColumnWidths.length < this._columns.length) {
			return;
		}

		var availableWidth = this.actualWidth - this.leftViewPortOffset - this.rightViewPortOffset;
		var totalWidth = 0.0;
		var indices:Array<Int> = [];
		for (i in 0...this._customColumnWidths.length) {
			var column = this._columns.get(i);
			if (column.width != null) {
				// if the width is set explicitly, skip it!
				availableWidth -= column.width;
				continue;
			}
			var size = this._customColumnWidths[i];
			totalWidth += size;
			indices[i] = i;
		}
		if (totalWidth == availableWidth) {
			return;
		}

		// make a copy so that this is detected as a change
		this._customColumnWidths = this._customColumnWidths.copy();

		var widthToDistribute = availableWidth - totalWidth;
		this.distributeWidthToIndices(widthToDistribute, indices, totalWidth);
	}

	private function calculateResizedColumnWidth(offset:Float):Void {
		var columnCount = this._columns.length;
		if (this._customColumnWidths == null) {
			this._customColumnWidths = [];
			this._customColumnWidths.resize(columnCount);
		} else {
			// make a copy so that it will be detected as a change
			this._customColumnWidths = this._customColumnWidths.copy();
			// try to keep any column widths we already saved
			this._customColumnWidths.resize(columnCount);
		}
		var column = this._columns.get(this._resizingHeaderIndex);
		// clear the explicit width because the user resized it
		column.width = null;
		var headerRenderer = this.activeHeaderRenderers[this._resizingHeaderIndex];
		var column = this._columns.get(this._resizingHeaderIndex);
		var minX = this._headerContainer.x + headerRenderer.x + column.minWidth;
		var maxX = this.actualWidth - this.rightViewPortOffset;
		var originalX = this._headerContainer.x + headerRenderer.x + headerRenderer.width;
		var newX = Math.min(Math.max(originalX + offset, minX), maxX);

		var preferredWidth = newX - headerRenderer.x;
		var totalMinWidth = 0.0;
		var originalWidth = headerRenderer.width;
		var totalWidthAfter = 0.0;
		var indicesAfter:Array<Int> = [];
		for (i in 0...columnCount) {
			var currentColumn = this._columns.get(i);
			if (i == this._resizingHeaderIndex) {
				continue;
			} else if (i < this._resizingHeaderIndex) {
				// we want these columns to maintain their width so that the
				// resized one will start at the same x position
				// however, we're not setting the width property on the
				// DataGridColumn because we want them to be able to resize
				// later if the whole DataGrid resizes.
				headerRenderer = this.activeHeaderRenderers[i];
				this._customColumnWidths[i] = headerRenderer.width;
				totalMinWidth += headerRenderer.width;
			} else {
				if (currentColumn.width != null) {
					totalMinWidth += currentColumn.width;
					continue;
				}
				totalMinWidth += currentColumn.minWidth;
				headerRenderer = this.activeHeaderRenderers[i];
				var columnWidth = headerRenderer.width;
				totalWidthAfter += columnWidth;
				this._customColumnWidths[i] = columnWidth;
				indicesAfter[indicesAfter.length] = i;
			}
		}
		if (indicesAfter.length == 0) {
			// if all of the columns after the resizing one have explicit
			// widths, we need to force one to be resized
			var index = this._resizingHeaderIndex + 1;
			indicesAfter[0] = index;
			column = this._columns.get(index);
			totalWidthAfter = column.width;
			totalMinWidth -= totalWidthAfter;
			totalMinWidth += column.minWidth;
			this._customColumnWidths[index] = totalWidthAfter;
			column.width = null;
		}
		var newWidth = preferredWidth;
		var maxWidth = this._headerContainer.width - totalMinWidth;
		if (newWidth > maxWidth) {
			newWidth = maxWidth;
		}
		if (newWidth < column.minWidth) {
			newWidth = column.minWidth;
		}
		this._customColumnWidths[this._resizingHeaderIndex] = newWidth;

		// the width to distribute may be positive or negative, depending on
		// whether the resized column was made smaller or larger
		var widthToDistribute = originalWidth - newWidth;
		this.distributeWidthToIndices(widthToDistribute, indicesAfter, totalWidthAfter);
		this.setInvalid(LAYOUT);
	}

	private function distributeWidthToIndices(widthToDistribute:Float, indices:Array<Int>, totalWidthOfIndices:Float):Void {
		while (Math.abs(widthToDistribute) > 1.0) {
			// this will be the store value if we need to loop again
			var nextWidthToDistribute = widthToDistribute;
			var i = indices.length - 1;
			while (i >= 0) {
				var index = indices[i];
				var headerRenderer = this.activeHeaderRenderers[index];
				var columnWidth = headerRenderer.width;
				var column = this._columns.get(index);
				var percent = columnWidth / totalWidthOfIndices;
				var offset = widthToDistribute * percent;
				var newWidth = this._customColumnWidths[index] + offset;
				if (newWidth < column.minWidth) {
					offset += (column.minWidth - newWidth);
					newWidth = column.minWidth;
					// we've hit the minimum, so skip it if we loop again
					indices.splice(i, 1);
					// also readjust the total to exclude this column
					// so that the percentages still add up to 100%
					totalWidthOfIndices -= columnWidth;
				}
				this._customColumnWidths[index] = newWidth;
				nextWidthToDistribute -= offset;
				i--;
			}
			widthToDistribute = nextWidthToDistribute;
		}

		if (widthToDistribute != 0) {
			// if we have less than a pixel left, just add it to the
			// final column and exit the loop
			this._customColumnWidths[this._customColumnWidths.length - 1] += widthToDistribute;
		}
	}

	private function gridView_dataProvider_updateItemHandler(event:FlatCollectionEvent):Void {
		this.updateRowRendererForIndex(event.index);
	}

	private function gridView_dataProvider_updateAllHandler(event:FlatCollectionEvent):Void {
		for (i in 0...this._dataProvider.length) {
			this.updateRowRendererForIndex(i);
		}
	}

	private function gridView_columns_changeHandler(event:Event):Void {
		this.setInvalid(DATA);
	}

	private function gridView_headerRenderer_touchTapHandler(event:TouchEvent):Void {
		if (!this._enabled) {
			return;
		}
		if (event.isPrimaryTouchPoint #if air && Multitouch.mapTouchToMouse #end) {
			// ignore the primary one because MouseEvent.CLICK will catch it
			return;
		}

		var headerRenderer = cast(event.currentTarget, DisplayObject);
		var column = this.headerRendererToData.get(headerRenderer);
		this.dispatchHeaderTriggerEvent(column);
	}

	private function gridView_headerRenderer_clickHandler(event:MouseEvent):Void {
		if (!this._enabled) {
			return;
		}

		var headerRenderer = cast(event.currentTarget, DisplayObject);
		var column = this.headerRendererToData.get(headerRenderer);
		this.dispatchHeaderTriggerEvent(column);
	}

	private function gridView_headerRenderer_triggerHandler(event:TriggerEvent):Void {
		if (!this._enabled) {
			return;
		}

		var headerRenderer = cast(event.currentTarget, DisplayObject);
		var column = this.headerRendererToData.get(headerRenderer);
		this.dispatchHeaderTriggerEvent(column);
	}

	private function gridView_headerDivider_mouseDownHandler(event:MouseEvent):Void {
		if (!this._enabled || !this._resizableColumns || this._resizingHeaderIndex != -1) {
			return;
		}

		var divider = cast(event.currentTarget, DisplayObject);
		this._resizingHeaderIndex = this._activeHeaderDividers.indexOf(divider);
		this._resizingHeaderStartStageX = event.stageX;
		this.layoutColumnResizeSkin(0.0);
		this.stage.addEventListener(MouseEvent.MOUSE_MOVE, gridView_headerDivider_stage_mouseMoveHandler, false, 0, true);
		this.stage.addEventListener(MouseEvent.MOUSE_UP, gridView_headerDivider_stage_mouseUpHandler, false, 0, true);
	}

	private function gridView_headerDivider_stage_mouseMoveHandler(event:MouseEvent):Void {
		var offset = event.stageX - this._resizingHeaderStartStageX;
		this.layoutColumnResizeSkin(offset);
	}

	private function layoutColumnResizeSkin(offset:Float):Void {
		if (this._currentColumnResizeSkin == null) {
			return;
		}
		var headerRenderer = this.activeHeaderRenderers[this._resizingHeaderIndex];
		var column = this._columns.get(this._resizingHeaderIndex);
		var minX = this._headerContainer.x + headerRenderer.x + column.minWidth;
		var maxX = this.actualWidth - this.rightViewPortOffset;
		var originalX = this._headerContainer.x + headerRenderer.x + headerRenderer.width;
		var newX = Math.min(Math.max(originalX + offset, minX), maxX) - (this._currentColumnResizeSkin.width / 2.0);
		this._currentColumnResizeSkin.visible = true;
		this._currentColumnResizeSkin.x = newX;
		this._currentColumnResizeSkin.y = this.paddingTop;
		this._currentColumnResizeSkin.height = this.actualHeight - this.paddingTop - this.bottomViewPortOffset;
		this.setChildIndex(this._currentColumnResizeSkin, this.numChildren - 1);
	}

	private function gridView_headerDivider_stage_mouseUpHandler(event:MouseEvent):Void {
		this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, gridView_headerDivider_stage_mouseMoveHandler);
		this.stage.removeEventListener(MouseEvent.MOUSE_UP, gridView_headerDivider_stage_mouseUpHandler);
		if (this._currentColumnResizeSkin != null) {
			this._currentColumnResizeSkin.visible = false;
		}

		var offset = event.stageX - this._resizingHeaderStartStageX;
		this.calculateResizedColumnWidth(offset);

		this._resizingHeaderIndex = -1;
	}
}

/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import feathers.controls.dataRenderers.CellRenderer;
import feathers.controls.dataRenderers.GridViewRowRenderer;
import feathers.controls.dataRenderers.IGridViewHeaderRenderer;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.controls.supportClasses.AdvancedLayoutViewPort;
import feathers.controls.supportClasses.BaseScrollContainer;
import feathers.core.IDataSelector;
import feathers.core.IIndexSelector;
import feathers.core.ITextControl;
import feathers.core.IValidating;
import feathers.core.InvalidationFlag;
import feathers.data.GridViewCellState;
import feathers.data.GridViewHeaderState;
import feathers.data.IFlatCollection;
import feathers.events.FeathersEvent;
import feathers.events.FlatCollectionEvent;
import feathers.events.TriggerEvent;
import feathers.layout.Direction;
import feathers.layout.GridViewRowLayout;
import feathers.layout.ILayout;
import feathers.layout.IScrollLayout;
import feathers.layout.IVirtualLayout.VirtualLayoutRange;
import feathers.layout.IVirtualLayout;
import feathers.layout.VerticalListFixedRowLayout;
import feathers.themes.steel.components.SteelGridViewStyles;
import feathers.utils.DisplayObjectRecycler;
import haxe.ds.ObjectMap;
import openfl.display.DisplayObject;
import openfl.errors.IllegalOperationError;
import openfl.events.Event;

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

	private static final INVALIDATION_FLAG_HEADER_RENDERER_FACTORY = "headerRendererFactory";

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

	override private function get_focusEnabled():Bool {
		return (this.selectable || this.maxScrollY != this.minScrollY || this.maxScrollX != this.minScrollX)
			&& this.enabled
			&& this.focusEnabled;
	}

	private var gridViewPort:AdvancedLayoutViewPort;

	override private function get_primaryDirection():Direction {
		if (Std.is(this._layout, IScrollLayout)) {
			return cast(this._layout, IScrollLayout).primaryDirection;
		}
		return Direction.NONE;
	}

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
	public var dataProvider(default, set):IFlatCollection<Dynamic> = null;

	private function set_dataProvider(value:IFlatCollection<Dynamic>):IFlatCollection<Dynamic> {
		if (this.dataProvider == value) {
			return this.dataProvider;
		}
		this._virtualCache.resize(0);
		if (this.dataProvider != null) {
			this.dataProvider.removeEventListener(Event.CHANGE, gridView_dataProvider_changeHandler);
			this.dataProvider.removeEventListener(FlatCollectionEvent.ADD_ITEM, gridView_dataProvider_addItemHandler);
			this.dataProvider.removeEventListener(FlatCollectionEvent.REMOVE_ITEM, gridView_dataProvider_removeItemHandler);
			this.dataProvider.removeEventListener(FlatCollectionEvent.REPLACE_ITEM, gridView_dataProvider_replaceItemHandler);
			this.dataProvider.removeEventListener(FlatCollectionEvent.REMOVE_ALL, gridView_dataProvider_removeAllHandler);
			this.dataProvider.removeEventListener(FlatCollectionEvent.RESET, gridView_dataProvider_resetHandler);
			this.dataProvider.removeEventListener(FlatCollectionEvent.SORT_CHANGE, gridView_dataProvider_sortChangeHandler);
			this.dataProvider.removeEventListener(FlatCollectionEvent.FILTER_CHANGE, gridView_dataProvider_filterChangeHandler);
		}
		this.dataProvider = value;
		if (this.dataProvider != null) {
			this._virtualCache.resize(this.dataProvider.length);
			this.dataProvider.addEventListener(Event.CHANGE, gridView_dataProvider_changeHandler);
			this.dataProvider.addEventListener(FlatCollectionEvent.ADD_ITEM, gridView_dataProvider_addItemHandler);
			this.dataProvider.addEventListener(FlatCollectionEvent.REMOVE_ITEM, gridView_dataProvider_removeItemHandler);
			this.dataProvider.addEventListener(FlatCollectionEvent.REPLACE_ITEM, gridView_dataProvider_replaceItemHandler);
			this.dataProvider.addEventListener(FlatCollectionEvent.REMOVE_ALL, gridView_dataProvider_removeAllHandler);
			this.dataProvider.addEventListener(FlatCollectionEvent.RESET, gridView_dataProvider_resetHandler);
			this.dataProvider.addEventListener(FlatCollectionEvent.SORT_CHANGE, gridView_dataProvider_sortChangeHandler);
			this.dataProvider.addEventListener(FlatCollectionEvent.FILTER_CHANGE, gridView_dataProvider_filterChangeHandler);
		}
		this.setInvalid(InvalidationFlag.DATA);
		return this.dataProvider;
	}

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
	public var columns(default, set):IFlatCollection<GridViewColumn> = null;

	private function set_columns(value:IFlatCollection<GridViewColumn>):IFlatCollection<GridViewColumn> {
		if (this.columns == value) {
			return this.columns;
		}
		if (this.columns != null) {
			this.columns.removeEventListener(Event.CHANGE, gridView_columns_changeHandler);
		}
		this.columns = value;
		if (this.columns != null) {
			this.columns.addEventListener(Event.CHANGE, gridView_columns_changeHandler);
		}
		this.setInvalid(InvalidationFlag.DATA);
		return this.columns;
	}

	/**
		Manages header renderers used by the grid view.

		In the following example, the grid view uses a custom header renderer
		class:

		```hx
		gridView.headerRendererRecycler = DisplayObjectRecycler.withClass(CustomHeaderRenderer);
		```

		@since 1.0.0
	**/
	public var headerRendererRecycler(default,
		set):DisplayObjectRecycler<Dynamic, GridViewHeaderState, DisplayObject> = DisplayObjectRecycler.withFunction(() -> {
			var headerRenderer = new ItemRenderer();
			headerRenderer.toggleable = false;
			return headerRenderer;
		});

	private function set_headerRendererRecycler(value:DisplayObjectRecycler<Dynamic, GridViewHeaderState, DisplayObject>):DisplayObjectRecycler<Dynamic,
		GridViewHeaderState, DisplayObject> {
		if (this.headerRendererRecycler == value) {
			return this.headerRendererRecycler;
		}
		this.headerRendererRecycler = value;
		this.setInvalid(INVALIDATION_FLAG_HEADER_RENDERER_FACTORY);
		return this.headerRendererRecycler;
	}

	private var _rowRendererRecycler:DisplayObjectRecycler<Dynamic, Dynamic, DisplayObject> = DisplayObjectRecycler.withClass(GridViewRowRenderer);

	/**
		@see `feathers.core.IIndexSelector.selectedIndex`
	**/
	@:isVar
	public var selectedIndex(get, set):Int = -1;

	private function get_selectedIndex():Int {
		return this.selectedIndex;
	}

	private function set_selectedIndex(value:Int):Int {
		if (!this.selectable || this.dataProvider == null) {
			value = -1;
		}
		if (this.selectedIndex == value) {
			return this.selectedIndex;
		}
		this.selectedIndex = value;
		// using @:bypassAccessor because if we were to call the selectedItem
		// setter, this change wouldn't be saved properly
		if (this.selectedIndex == -1) {
			@:bypassAccessor this.selectedItem = null;
		} else {
			@:bypassAccessor this.selectedItem = this.dataProvider.get(this.selectedIndex);
		}
		this.setInvalid(InvalidationFlag.SELECTION);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this.selectedIndex;
	}

	/**
		@see `feathers.core.IIndexSelector.maxSelectedIndex`
	**/
	public var maxSelectedIndex(get, never):Int;

	private function get_maxSelectedIndex():Int {
		if (this.dataProvider == null) {
			return -1;
		}
		return this.dataProvider.length - 1;
	}

	/**
		@see `feathers.core.IDataSelector.selectedItem`
	**/
	@:isVar
	public var selectedItem(get, set):Dynamic = null;

	private function get_selectedItem():Dynamic {
		return this.selectedItem;
	}

	private function set_selectedItem(value:Dynamic):Dynamic {
		if (!this.selectable || this.dataProvider == null) {
			this.selectedIndex = -1;
			return this.selectedItem;
		}
		this.selectedIndex = this.dataProvider.indexOf(value);
		return this.selectedItem;
	}

	private var _layout:ILayout;

	/**
		Indicates if the grid view's layout is allowed to virtualize items or
		not.

		The following example disables virtual layouts:

		```hx
		gridView.virtualLayout = false;
		```

		@since 1.0.0
	**/
	public var virtualLayout(default, set):Bool = true;

	private function set_virtualLayout(value:Bool):Bool {
		if (this.virtualLayout = value) {
			return this.virtualLayout;
		}
		this.virtualLayout = value;
		this.setInvalid(InvalidationFlag.LAYOUT);
		return this.virtualLayout;
	}

	/**
		Manages cell renderers used by the grid view.

		In the following example, the grid view uses a custom cell renderer
		class:

		```hx
		gridView.cellRendererRecycler = DisplayObjectRecycler.withClass(CustomCellRenderer);
		```

		@since 1.0.0
	**/
	public var cellRendererRecycler(default,
		set):DisplayObjectRecycler<Dynamic, GridViewCellState, DisplayObject> = DisplayObjectRecycler.withClass(CellRenderer);

	private function set_cellRendererRecycler(value:DisplayObjectRecycler<Dynamic, GridViewCellState, DisplayObject>):DisplayObjectRecycler<Dynamic,
		GridViewCellState, DisplayObject> {
		if (this.cellRendererRecycler == value) {
			return this.cellRendererRecycler;
		}
		this.cellRendererRecycler = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this.cellRendererRecycler;
	}

	private var activeHeaderRenderers:Array<DisplayObject> = [];
	private var inactiveRowRenderers:Array<GridViewRowRenderer> = [];
	private var activeRowRenderers:Array<GridViewRowRenderer> = [];
	private var dataToRowRenderer = new ObjectMap<Dynamic, GridViewRowRenderer>();
	private var rowRendererToData = new ObjectMap<GridViewRowRenderer, Dynamic>();
	private var _unrenderedData:Array<Dynamic> = [];
	private var _layoutItems:Array<DisplayObject> = [];
	private var _virtualCache:Array<Dynamic> = [];
	private var _visibleIndices:VirtualLayoutRange = new VirtualLayoutRange(0, 0);

	private var _currentHeaderState:GridViewHeaderState = new GridViewHeaderState();

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
	public var selectable(default, set):Bool = true;

	private function set_selectable(value:Bool):Bool {
		if (this.selectable == value) {
			return this.selectable;
		}
		this.selectable = value;
		if (!this.selectable) {
			this.selectedIndex = -1;
		}
		return this.selectable;
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
		if (this.dataProvider == null || this.dataProvider.length == 0) {
			return;
		}

		var targetX = this.scrollX;
		var targetY = this.scrollY;
		if (Std.is(this._layout, IScrollLayout)) {
			var scrollLayout = cast(this._layout, IScrollLayout);
			var result = scrollLayout.getNearestScrollPositionForIndex(rowIndex, this.dataProvider.length, this.viewPort.visibleWidth,
				this.viewPort.visibleHeight);
			targetX = result.x;
			targetY = result.y;
		} else {
			var row = this.dataProvider.get(rowIndex);
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

		if (this._layout == null) {
			this._layout = new VerticalListFixedRowLayout();
		}
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);
		var layoutInvalid = this.isInvalid(InvalidationFlag.LAYOUT);
		var selectionInvalid = this.isInvalid(InvalidationFlag.SELECTION);
		var stateInvalid = this.isInvalid(InvalidationFlag.STATE);
		var stylesInvalid = this.isInvalid(InvalidationFlag.STYLES);
		var headerRendererInvalid = this.isInvalid(INVALIDATION_FLAG_HEADER_RENDERER_FACTORY);

		if (headerRendererInvalid || stateInvalid || dataInvalid) {
			this.refreshHeaderRenderers();
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

	override private function calculateViewPortOffsets(forceScrollBars:Bool = false, useActualBounds:Bool = false):Void {
		super.calculateViewPortOffsets(forceScrollBars, useActualBounds);

		if (this._headerContainer != null) {
			switch (this.scrollBarYPosition) {
				case LEFT:
					this._headerContainerLayout.paddingLeft = this.leftViewPortOffset;
				default:
					this._headerContainerLayout.paddingRight = this.rightViewPortOffset;
			};

			if (Std.is(this._headerContainer, IValidating)) {
				cast(this._headerContainer, IValidating).validateNow();
			}
			this.topViewPortOffset += this._headerContainer.height;
			this.chromeMeasuredWidth = Math.max(this.chromeMeasuredWidth, this._headerContainer.width);
			this.chromeMeasuredMinWidth = Math.max(this.chromeMeasuredMinWidth, this._headerContainer.width);
		}
	}

	private function layoutHeaders():Void {
		if (this._headerContainer == null) {
			return;
		}
		this._headerContainer.x = this.paddingLeft;
		this._headerContainer.y = this.paddingTop;
		this._headerContainer.width = this.actualWidth - this.paddingLeft - this.paddingRight;
		if (Std.is(this._headerContainer, IValidating)) {
			cast(this._headerContainer, IValidating).validateNow();
		}
	}

	private function refreshHeaderRenderers():Void {
		this._headerContainerLayout.columns = this.columns;

		if (this.headerRendererRecycler.update == null) {
			this.headerRendererRecycler.update = defaultUpdateHeaderRenderer;
			if (this.headerRendererRecycler.reset == null) {
				this.headerRendererRecycler.reset = defaultResetHeaderRenderer;
			}
		}

		for (headerRenderer in this.activeHeaderRenderers) {
			this._currentHeaderState.column = null;
			this._currentHeaderState.columnIndex = -1;
			this._currentHeaderState.text = null;
			if (this.headerRendererRecycler.reset != null) {
				this.headerRendererRecycler.reset(headerRenderer, this._currentHeaderState);
			}
			if (Std.is(headerRenderer, IGridViewHeaderRenderer)) {
				var header = cast(headerRenderer, IGridViewHeaderRenderer);
				header.column = null;
				header.columnIndex = -1;
			}
			this.destroyHeaderRenderer(headerRenderer);
		}
		this.activeHeaderRenderers.resize(0);
		for (i in 0...this.columns.length) {
			var column = this.columns.get(i);
			var headerRenderer = this.createHeaderRenderer(column, i);
			this.activeHeaderRenderers.insert(i, headerRenderer);
			this._headerContainer.addChildAt(headerRenderer, i);
		}
	}

	private function refreshRowRenderers(items:Array<DisplayObject>):Void {
		this._layoutItems = items;

		this.refreshInactiveRowRenderers();
		if (this.dataProvider == null) {
			return;
		}

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
			rowRenderer.removeEventListener(TriggerEvent.TRIGGER, gridView_rowRenderer_triggerHandler);
			rowRenderer.removeEventListener(Event.CHANGE, gridView_rowRenderer_changeHandler);
			var oldIgnoreSelectionChange = this._ignoreSelectionChange;
			this._ignoreSelectionChange = true;
			if (this._rowRendererRecycler.reset != null) {
				this._rowRendererRecycler.reset(rowRenderer, null);
			}
			rowRenderer.selected = false;
			rowRenderer.data = null;
			rowRenderer.rowIndex = -1;
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
		this._layoutItems.resize(this.dataProvider.length);

		if (this.virtualLayout && Std.is(this._layout, IVirtualLayout)) {
			var virtualLayout = cast(this._layout, IVirtualLayout);
			virtualLayout.virtualCache = this._virtualCache;
			virtualLayout.getVisibleIndices(this.dataProvider.length, this.gridViewPort.visibleWidth, this.gridViewPort.visibleHeight, this._visibleIndices);
		} else {
			this._visibleIndices.start = 0;
			this._visibleIndices.end = this.dataProvider.length - 1;
		}
		if (this.dataProvider == null || this.dataProvider.length == 0) {
			return;
		}
		for (i in this._visibleIndices.start...this._visibleIndices.end + 1) {
			var item = this.dataProvider.get(i);
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
				var removed = inactiveRowRenderers.remove(rowRenderer);
				if (!removed) {
					throw new IllegalOperationError(Type.getClassName(Type.getClass(this))
						+ ": row renderer map contains bad data. This may be caused by duplicate items in the data provider, which is not allowed.");
				}
				activeRowRenderers.push(rowRenderer);
			} else {
				this._unrenderedData.push(item);
			}
		}
	}

	private function renderUnrenderedData():Void {
		for (item in this._unrenderedData) {
			var index = this.dataProvider.indexOf(item);
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
		rowRenderer.addEventListener(TriggerEvent.TRIGGER, gridView_rowRenderer_triggerHandler);
		rowRenderer.addEventListener(Event.CHANGE, gridView_rowRenderer_changeHandler);
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
		rowRenderer.data = item;
		rowRenderer.rowIndex = index;
		rowRenderer.selectable = this.selectable;
		rowRenderer.selected = index == this.selectedIndex;
		rowRenderer.cellRendererRecycler = this.cellRendererRecycler;
		rowRenderer.columns = this.columns;
	}

	private function createHeaderRenderer(column:GridViewColumn, columnIndex:Int):DisplayObject {
		var headerRenderer:DisplayObject = null;
		headerRenderer = this.headerRendererRecycler.create();
		/*if (this.inactiveHeaderRenderers.length == 0) {
				rowRenderer = this.headerRendererRecycler.create();
			} else {
				rowRenderer = this.inactiveHeaderRenderers.shift();
		}*/
		this._currentHeaderState.column = column;
		this._currentHeaderState.columnIndex = columnIndex;
		this._currentHeaderState.text = column.headerText;
		if (this.headerRendererRecycler.update != null) {
			this.headerRendererRecycler.update(headerRenderer, this._currentHeaderState);
		}
		if (Std.is(headerRenderer, IGridViewHeaderRenderer)) {
			var header = cast(headerRenderer, IGridViewHeaderRenderer);
			header.column = this._currentHeaderState.column;
			header.columnIndex = this._currentHeaderState.columnIndex;
		}
		return headerRenderer;
	}

	private function destroyHeaderRenderer(headerRenderer:DisplayObject):Void {
		this._headerContainer.removeChild(headerRenderer);
		if (this.headerRendererRecycler.destroy != null) {
			this.headerRendererRecycler.destroy(headerRenderer);
		}
	}

	private function refreshSelectedIndicesAfterFilterOrSort():Void {
		if (this.selectedIndex == -1) {
			return;
		}
		// the index may have changed, possibily even to -1, if the item was
		// filtered out
		this.selectedIndex = this.dataProvider.indexOf(this.selectedItem);
	}

	private function navigateWithKeyboard(event:KeyboardEvent):Void {
		if (this.dataProvider == null || this.dataProvider.length == 0) {
			return;
		}
		var result = this.selectedIndex;
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
				result = this.dataProvider.length - 1;
			default:
				// not keyboard navigation
				return;
		}
		if (result < 0) {
			result = 0;
		} else if (result >= this.dataProvider.length) {
			result = this.dataProvider.length - 1;
		}
		event.stopPropagation();
		this.selectedIndex = result;
		if (this.selectedIndex != -1) {
			this.scrollToRowIndex(this.selectedIndex);
		}
	}

	override private function baseScrollContainer_keyDownHandler(event:KeyboardEvent):Void {
		if (!this.enabled || event.isDefaultPrevented()) {
			return;
		}
		this.navigateWithKeyboard(event);
	}

	private function gridView_rowRenderer_triggerHandler(event:TriggerEvent):Void {
		var rowRenderer = cast(event.currentTarget, GridViewRowRenderer);
		var item = this.rowRendererToData.get(rowRenderer);
		// trigger before change
		this.dispatchEvent(event);
	}

	private function gridView_rowRenderer_changeHandler(event:Event):Void {
		if (this._ignoreSelectionChange) {
			return;
		}
		var rowRenderer = cast(event.currentTarget, GridViewRowRenderer);
		if (!this.selectable) {
			var toggle = cast(rowRenderer, IToggle);
			toggle.selected = false;
			return;
		}
		var item = this.rowRendererToData.get(rowRenderer);
		this.selectedItem = item;
	}

	private function gridView_dataProvider_changeHandler(event:Event):Void {
		this.setInvalid(InvalidationFlag.DATA);
	}

	private function gridView_dataProvider_addItemHandler(event:FlatCollectionEvent):Void {
		if (this._virtualCache != null) {
			this._virtualCache.insert(event.index, null);
		}
		if (this.selectedIndex == -1) {
			return;
		}
		if (this.selectedIndex <= event.index) {
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
	}

	private function gridView_dataProvider_removeItemHandler(event:FlatCollectionEvent):Void {
		if (this._virtualCache != null) {
			this._virtualCache.remove(event.index);
		}
		if (this.selectedIndex == -1) {
			return;
		}
		if (this.selectedIndex == event.index) {
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
	}

	private function gridView_dataProvider_replaceItemHandler(event:FlatCollectionEvent):Void {
		if (this._virtualCache != null) {
			this._virtualCache[event.index] = null;
		}
		if (this.selectedIndex == -1) {
			return;
		}
		if (this.selectedIndex == event.index) {
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
	}

	private function gridView_dataProvider_removeAllHandler(event:FlatCollectionEvent):Void {
		if (this._virtualCache != null) {
			this._virtualCache.resize(0);
		}
		this.selectedIndex = -1;
	}

	private function gridView_dataProvider_resetHandler(event:FlatCollectionEvent):Void {
		if (this._virtualCache != null) {
			this._virtualCache.resize(0);
			this._virtualCache.resize(this.dataProvider.length);
		}
		this.selectedIndex = -1;
	}

	private function gridView_dataProvider_sortChangeHandler(event:FlatCollectionEvent):Void {
		if (this._virtualCache != null) {
			// we don't know exactly which indices have changed, so reset the
			// whole cache.
			this._virtualCache.resize(0);
			this._virtualCache.resize(this.dataProvider.length);
		}
		this.refreshSelectedIndicesAfterFilterOrSort();
	}

	private function gridView_dataProvider_filterChangeHandler(event:FlatCollectionEvent):Void {
		if (this._virtualCache != null) {
			// we don't know exactly which indices have changed, so reset the
			// whole cache.
			this._virtualCache.resize(0);
			this._virtualCache.resize(this.dataProvider.length);
		}
		this.refreshSelectedIndicesAfterFilterOrSort();
	}

	private function gridView_columns_changeHandler(event:Event):Void {
		this.setInvalid(InvalidationFlag.DATA);
	}
}

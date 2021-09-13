/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.controls.dataRenderers.GridViewHeaderRenderer;
import feathers.controls.dataRenderers.GridViewRowRenderer;
import feathers.controls.dataRenderers.IGridViewHeaderRenderer;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.controls.supportClasses.AdvancedLayoutViewPort;
import feathers.controls.supportClasses.BaseScrollContainer;
import feathers.core.IDataSelector;
import feathers.core.IIndexSelector;
import feathers.core.ITextControl;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.core.InvalidationFlag;
import feathers.data.ArrayCollection;
import feathers.data.GridViewCellState;
import feathers.data.GridViewHeaderState;
import feathers.data.IFlatCollection;
import feathers.data.ISortOrderObserver;
import feathers.data.SortOrder;
import feathers.events.FeathersEvent;
import feathers.events.FlatCollectionEvent;
import feathers.events.GridViewEvent;
import feathers.events.TriggerEvent;
import feathers.layout.IKeyboardNavigationLayout;
import feathers.layout.GridViewRowLayout;
import feathers.layout.ILayout;
import feathers.layout.ILayoutIndexObject;
import feathers.layout.IScrollLayout;
import feathers.layout.IVirtualLayout;
import feathers.layout.Measurements;
import feathers.skins.IProgrammaticSkin;
import feathers.style.IVariantStyleObject;
import feathers.themes.steel.components.SteelGridViewStyles;
import feathers.utils.DisplayObjectFactory;
import feathers.utils.DisplayObjectRecycler;
import feathers.utils.DisplayUtil;
import feathers.utils.ExclusivePointer;
import feathers.utils.MathUtil;
import haxe.ds.ObjectMap;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.InteractiveObject;
import openfl.display.Sprite;
import openfl.display.Stage;
import openfl.errors.IllegalOperationError;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
import openfl.geom.Rectangle;
import openfl.ui.Keyboard;
import openfl.ui.Mouse;
import openfl.ui.MouseCursor;
#if (lime && !flash)
import lime.ui.MouseCursor as LimeMouseCursor;
#end
#if air
import openfl.ui.Multitouch;
#end
#if (openfl >= "9.1.0")
import openfl.utils.ObjectPool;
#else
import openfl._internal.utils.ObjectPool;
#end

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

	@event openfl.events.Event.CHANGE Dispatched when either
	`GridView.selectedItem` or `GridView.selectedIndex` changes.

	@event feathers.events.GridViewEvent.CELL_TRIGGER Dispatched when the user
	taps or clicks a cell renderer in the grid view. The pointer must remain
	within the bounds of the cell renderer on release, and the grid view cannot
	scroll before release, or the gesture will be ignored.

	@event feathers.events.GridViewEvent.HEADER_TRIGGER Dispatched when the user
	taps or clicks a header renderer in the grid view. The pointer must remain
	within the bounds of the header renderer on release, and the grid view cannot
	scroll before release, or the gesture will be ignored.

	@see [Tutorial: How to use the GridView component](https://feathersui.com/learn/haxe-openfl/grid-view/)

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
@:event(feathers.events.GridViewEvent.CELL_TRIGGER)
@:event(feathers.events.GridViewEvent.HEADER_TRIGGER)
@:access(feathers.data.GridViewHeaderState)
@:meta(DefaultProperty("dataProvider"))
@defaultXmlProperty("dataProvider")
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
		The variant used to style the cell renderers in a theme.

		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_CELL_RENDERER = "gridView_cellRenderer";

	/**
		The variant used to style the column header renderers in a theme.

		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_HEADER_RENDERER = "gridView_headerRenderer";

	@:deprecated('GridView.CHILD_VARIANT_HEADER is deprecated. Use GridView.CHILD_VARIANT_HEADER_RENDERER instead.')
	public static final CHILD_VARIANT_HEADER = CHILD_VARIANT_HEADER_RENDERER;

	/**
		The variant used to style the column header dividers in a theme.

		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_HEADER_DIVIDER = "gridView_headerDivider";

	/**
		The variant used to style the column view port dividers in a theme.

		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_COLUMN_DIVIDER = "gridView_columnDivider";

	private static final INVALIDATION_FLAG_HEADER_RENDERER_FACTORY = InvalidationFlag.CUSTOM("headerRendererFactory");
	private static final INVALIDATION_FLAG_HEADER_DIVIDER_FACTORY = InvalidationFlag.CUSTOM("headerDividerFactory");
	private static final INVALIDATION_FLAG_COLUMN_DIVIDER_FACTORY = InvalidationFlag.CUSTOM("columnDividerFactory");

	private static final RESET_HEADER_STATE = new GridViewHeaderState();
	private static final RESET_ROW_STATE = new GridViewCellState();

	private static function defaultUpdateHeaderRenderer(headerRenderer:DisplayObject, state:GridViewHeaderState):Void {
		if ((headerRenderer is ITextControl)) {
			var textControl = cast(headerRenderer, ITextControl);
			textControl.text = state.text;
		}
	}

	private static function defaultResetHeaderRenderer(headerRenderer:DisplayObject, state:GridViewHeaderState):Void {
		if ((headerRenderer is ITextControl)) {
			var textControl = cast(headerRenderer, ITextControl);
			textControl.text = null;
		}
	}

	private static function defaultSortCompareFunction(a:Dynamic, b:Dynamic):Int {
		var aString = Std.string(a).toLowerCase();
		var bString = Std.string(b).toLowerCase();
		if (aString < bString) {
			return -1;
		}
		if (aString > bString) {
			return 1;
		}
		return 0;
	}

	/**
		Creates a new `GridView` object.

		@since 1.0.0
	**/
	public function new(?dataProvider:IFlatCollection<Dynamic>) {
		initializeGridViewTheme();

		super();

		this.dataProvider = dataProvider;

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
	private var _columnDividerContainer:Sprite;
	private var _resizingHeaderIndex:Int = -1;
	private var _resizingHeaderTouchID:Int = -1;
	private var _resizingHeaderStartStageX:Float;
	private var _customColumnWidths:Array<Float>;

	private var _defaultHeaderStorage:HeaderRendererStorage = new HeaderRendererStorage(DisplayObjectRecycler.withClass(GridViewHeaderRenderer));
	private var _unrenderedHeaderData:Array<GridViewColumn> = [];
	private var _headerLayoutItems:Array<DisplayObject> = [];

	private var _defaultHeaderDividerStorage:HeaderDividerStorage = new HeaderDividerStorage(DisplayObjectFactory.withClass(Button));
	private var _headerDividerLayoutItems:Array<InteractiveObject> = [];

	private var _defaultColumnDividerStorage:ColumnDividerStorage = new ColumnDividerStorage();
	private var _columnDividerLayoutItems:Array<InteractiveObject> = [];

	private var _currentHeaderScrollRect:Rectangle;
	private var _headerScrollRect1:Rectangle = new Rectangle();
	private var _headerScrollRect2:Rectangle = new Rectangle();
	private var _oldHeaderDividerMouseCursor:MouseCursor;

	@:getter(tabEnabled)
	override private function get_tabEnabled():Bool {
		return (this._selectable || this.maxScrollY != this.minScrollY || this.maxScrollX != this.minScrollX)
			&& this._enabled
			&& this.rawTabEnabled;
	}

	private var gridViewPort:AdvancedLayoutViewPort;
	private var _ignoreDataProviderChanges:Bool = false;
	private var _dataProvider:IFlatCollection<Dynamic>;

	/**
		The collection of data displayed by the grid view.

		Items in the collection must be class instances or anonymous structures.
		Do not add primitive values (such as strings, booleans, or numeric
		values) directly to the collection.

		Additionally, all items in the collection must be unique object
		instances. Do not add the same instance to the collection more than
		once because a runtime exception will be thrown.

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
			this._columns.removeEventListener(FlatCollectionEvent.ADD_ITEM, gridView_columns_addItemHandler);
			this._columns.removeEventListener(FlatCollectionEvent.REMOVE_ITEM, gridView_columns_removeItemHandler);
		}
		this._columns = value;
		if (this._columns != null) {
			this._columns.addEventListener(Event.CHANGE, gridView_columns_changeHandler);
			this._columns.addEventListener(FlatCollectionEvent.ADD_ITEM, gridView_columns_addItemHandler);
			this._columns.addEventListener(FlatCollectionEvent.REMOVE_ITEM, gridView_columns_removeItemHandler);
		}
		this.setInvalid(DATA);
		return this._columns;
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
	@:flash.property
	public var headerRendererRecycler(get, set):DisplayObjectRecycler<Dynamic, GridViewHeaderState, DisplayObject>;

	private function get_headerRendererRecycler():DisplayObjectRecycler<Dynamic, GridViewHeaderState, DisplayObject> {
		return this._defaultHeaderStorage.headerRendererRecycler;
	}

	private function set_headerRendererRecycler(value:DisplayObjectRecycler<Dynamic, GridViewHeaderState, DisplayObject>):DisplayObjectRecycler<Dynamic,
		GridViewHeaderState, DisplayObject> {
		if (this._defaultHeaderStorage.headerRendererRecycler == value) {
			return this._defaultHeaderStorage.headerRendererRecycler;
		}
		this._defaultHeaderStorage.oldHeaderRendererRecycler = this._defaultHeaderStorage.headerRendererRecycler;
		this._defaultHeaderStorage.headerRendererRecycler = value;
		this.setInvalid(INVALIDATION_FLAG_HEADER_RENDERER_FACTORY);
		return this._defaultHeaderStorage.headerRendererRecycler;
	}

	private var _previousCustomHeaderRendererVariant:String = null;

	/**
		A custom variant to set on all header renderers, instead of
		`GridView.CHILD_VARIANT_HEADER_RENDERER`.

		The `customHeaderRendererVariant` will be not be used if the result of
		`headerRendererRecycler.create()` already has a variant set.

		@see `GridView.CHILD_VARIANT_HEADER_RENDERER

		@since 1.0.0
	**/
	@:style
	public var customHeaderRendererVariant:String = null;

	/**
		Manages the dividers between the grid view's headers.

		In the following example, the grid view uses a custom header divider
		class:

		```hx
		gridView.headerDividerFactory = DisplayObjectFactory.withClass(CustomHeaderDivider);
		```

		@since 1.0.0
	**/
	@:style
	public var headerDividerFactory:DisplayObjectFactory<Dynamic, InteractiveObject> = DisplayObjectFactory.withClass(Button);

	/**
		A custom variant to set on all header dividers, instead of
		`GridView.CHILD_VARIANT_HEADER_DIVIDER`.

		The `customHeaderDividerVariant` will be not be used if the result of
		`headerDividerFactory.create()` already has a variant set.

		@see `GridView.CHILD_VARIANT_HEADER_DIVIDER

		@since 1.0.0
	**/
	@:style
	public var customHeaderDividerVariant:String = null;

	/**
		Manages the dividers between the grid view's columns.

		In the following example, the grid view uses a custom column divider
		class:

		```hx
		gridView.columnDividerFactory = DisplayObjectFactory.withClass(CustomColumnDivider);
		```

		@since 1.0.0
	**/
	@:style
	public var columnDividerFactory:DisplayObjectFactory<Dynamic, DisplayObject> = null;

	/**
		A custom variant to set on all column dividers, instead of
		`GridView.CHILD_VARIANT_COLUMN_DIVIDER`.

		The `customColumnDividerVariant` will be not be used if the result of
		`columnDividerFactory.create()` already has a variant set.

		@see `GridView.CHILD_VARIANT_COLUMN_DIVIDER

		@since 1.0.0
	**/
	@:style
	public var customColumnDividerVariant:String = null;

	private var _rowRendererRecycler:DisplayObjectRecycler<Dynamic, Dynamic, DisplayObject> = DisplayObjectRecycler.withClass(GridViewRowRenderer);
	private var _rowRendererMeasurements:Measurements;
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
		if (this._selectedIndex == index && this._selectedIndices.length == 1) {
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
		return this._selectedItem;
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

	private var _previousLayout:ILayout;

	/**
		The layout algorithm used to position and size the grid view's items.

		By default, if no layout is provided by the time that the grid view
		initializes, a default layout that displays items vertically will be
		created.

		The following example tells the list view to use a horizontal layout:

		```hx
		var layout = new VerticalListLayout();
		layout.requestedRowCount = 5.0;
		layout.gap = 20.0;
		layout.padding = 20.0;
		listView.layout = layout;
		```

		@since 1.0.0
	**/
	@:style
	public var layout:ILayout = null;

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

	private var _cellRendererRecycler:DisplayObjectRecycler<Dynamic, GridViewCellState, DisplayObject> = DisplayObjectRecycler.withClass(ItemRenderer);

	/**
		Manages cell renderers used by the grid view.

		In the following example, the grid view uses a custom cell renderer
		class:

		```hx
		gridView.cellRendererRecycler = DisplayObjectRecycler.withClass(CustomCellRenderer);
		```

		@see `feathers.controls.GridViewColumn.cellRendererRecycler`

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

	private var _sortableColumns:Bool = false;

	/**
		Determines if the data grid's columns may be sorted by triggering the
		column headers. If a column does not provide a custom
		`sortCompareFunction`, the default behavior will compare the strings
		returned by`itemToText()`. A custom `sortCompareFunction` is recommended
		for comparing numeric values.

		The following example enables column sorting:

		```hx
		gridView.sortableColumns = true;
		```

		@see `feathers.controls.GridViewColumn.sortOrder`
		@see `feathers.controls.GridViewColumn.sortCompareFunction`

		@default false
	**/
	@:flash.property
	public var sortableColumns(get, set):Bool;

	private function get_sortableColumns():Bool {
		return this._sortableColumns;
	}

	private function set_sortableColumns(value:Bool):Bool {
		if (this._sortableColumns == value) {
			return this._sortableColumns;
		}
		this._sortableColumns = value;
		return this._sortableColumns;
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

	private var _sortOrder:SortOrder = NONE;

	/**
		Indicates the sort order of `sortedColumn`, if `sortedColumn` is not
		`null`. Otherwise, returns `SortOrder.NONE`.

		@see `GridView.sortedColumn`.

		@since 1.0.0
	**/
	@:flash.property
	public var sortOrder(get, set):SortOrder;

	private function get_sortOrder():SortOrder {
		return this._sortOrder;
	}

	private function set_sortOrder(value:SortOrder):SortOrder {
		if (this._sortedColumn == null) {
			// can't change the order of a sort that doesn't exist!
			value = NONE;
		}
		if (this._sortOrder == value) {
			return this._sortOrder;
		}
		this._sortOrder = value;
		this.setInvalid(SORT);
		return this._sortOrder;
	}

	private var _sortedColumn:GridViewColumn = null;

	/**
		The currently sorted column, or `null`, if no columns have been sorted.

		@since 1.0.0
	**/
	@:flash.property
	public var sortedColumn(get, set):GridViewColumn;

	private function get_sortedColumn():GridViewColumn {
		return this._sortedColumn;
	}

	private function set_sortedColumn(value:GridViewColumn):GridViewColumn {
		if (this._sortedColumn == value) {
			return this._sortedColumn;
		}
		if (this._columns.indexOf(value) == -1) {
			this._sortedColumn = null;
			this._sortOrder = NONE;
			return this._sortedColumn;
		}
		this._sortedColumn = value;
		if (this._sortedColumn != null) {
			this.sortOrder = this._sortedColumn.defaultSortOrder;
		} else {
			this._sortOrder = NONE;
		}
		this.setInvalid(SORT);
		return this._sortedColumn;
	}

	private var dataToHeaderRenderer = new ObjectMap<GridViewColumn, DisplayObject>();
	private var headerRendererToHeaderState = new ObjectMap<DisplayObject, GridViewHeaderState>();
	private var inactiveRowRenderers:Array<GridViewRowRenderer> = [];
	private var activeRowRenderers:Array<GridViewRowRenderer> = [];
	private var dataToRowRenderer = new ObjectMap<Dynamic, GridViewRowRenderer>();
	private var rowRendererToRowState = new ObjectMap<GridViewRowRenderer, GridViewCellState>();
	private var headerStatePool = new ObjectPool(() -> new GridViewHeaderState());
	private var rowStatePool = new ObjectPool(() -> new GridViewCellState());
	private var _unrenderedData:Array<Dynamic> = [];
	private var _rowLayoutItems:Array<DisplayObject> = [];
	private var _virtualCache:Array<Dynamic> = [];
	private var _visibleIndices:VirtualLayoutRange = new VirtualLayoutRange(0, 0);
	private var _tempVisibleIndices:VirtualLayoutRange = new VirtualLayoutRange(0, 0);
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

	/**
		Determines if the vertical scroll bar will start from the top of the
		headers, instead of starting below them.

		@since 1.0.0
	**/
	@:style
	public var extendedScrollBarY:Bool = false;

	/**
		Determines if header dividers are visible only when `resizableColumns`
		is `true`.
	**/
	@:style
	public var showHeaderDividersOnlyWhenResizable:Bool = false;

	private var _ignoreSelectionChange = false;
	private var _ignoreLayoutChanges = false;
	private var _ignoreHeaderLayoutChanges = false;
	private var _pendingScrollRowIndex:Int = -1;
	private var _pendingScrollDuration:Null<Float> = null;

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
		this._pendingScrollRowIndex = rowIndex;
		this._pendingScrollDuration = animationDuration;
		this.setInvalid(SCROLL);
	}

	/**
		Returns the current cell renderer used to render a specific column from
		an item from the data provider. May return `null` if an item and column
		doesn't currently have a cell renderer.

		**Note:** Most grid views use "virtual" layouts, which means that only
		the currently-visible subset of items will have cell renderers. As the
		grid view scrolls, the items with cell renderers will change, and cell
		renderers may even be re-used to display different items.

		@since 1.0.0
	**/
	public function itemAndColumnToCellRenderer(item:Dynamic, column:GridViewColumn):DisplayObject {
		var rowRenderer = this.dataToRowRenderer.get(item);
		if (rowRenderer == null) {
			return null;
		}
		return rowRenderer.columnToCellRenderer(column);
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
		var state = this.headerRendererToHeaderState.get(headerRenderer);
		if (state == null) {
			return null;
		}
		return state.column;
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

		if (this._columnDividerContainer == null) {
			this._columnDividerContainer = new Sprite();
			this._columnDividerContainer.mouseEnabled = false;
			this._columnDividerContainer.mouseChildren = false;
			this.addChild(this._columnDividerContainer);
		}
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(DATA);
		var layoutInvalid = this.isInvalid(LAYOUT);
		var sortInvalid = this.isInvalid(SORT);
		var stateInvalid = this.isInvalid(STATE);
		var stylesInvalid = this.isInvalid(STYLES);

		if (this._previousCustomHeaderRendererVariant != this.customHeaderRendererVariant) {
			this.setInvalidationFlag(INVALIDATION_FLAG_HEADER_RENDERER_FACTORY);
		}
		var headerRendererInvalid = this.isInvalid(INVALIDATION_FLAG_HEADER_RENDERER_FACTORY);

		if (this._defaultHeaderDividerStorage.headerDividerFactory != this.headerDividerFactory) {
			this._defaultHeaderDividerStorage.oldHeaderDividerFactory = this._defaultHeaderDividerStorage.headerDividerFactory;
			this._defaultHeaderDividerStorage.headerDividerFactory = this.headerDividerFactory;
			this.setInvalidationFlag(INVALIDATION_FLAG_HEADER_DIVIDER_FACTORY);
		}
		if (this._defaultHeaderDividerStorage.customHeaderDividerVariant != this.customHeaderDividerVariant) {
			this._defaultHeaderDividerStorage.customHeaderDividerVariant = this.customHeaderDividerVariant;
			this.setInvalidationFlag(INVALIDATION_FLAG_HEADER_DIVIDER_FACTORY);
		}
		var headerDividerInvalid = this.isInvalid(INVALIDATION_FLAG_HEADER_DIVIDER_FACTORY);

		if (this._defaultColumnDividerStorage.columnDividerFactory != this.columnDividerFactory) {
			this._defaultColumnDividerStorage.oldColumnDividerFactory = this._defaultColumnDividerStorage.columnDividerFactory;
			this._defaultColumnDividerStorage.columnDividerFactory = this.columnDividerFactory;
			this.setInvalidationFlag(INVALIDATION_FLAG_COLUMN_DIVIDER_FACTORY);
		}
		if (this._defaultColumnDividerStorage.customColumnDividerVariant != this.customColumnDividerVariant) {
			this._defaultColumnDividerStorage.customColumnDividerVariant = this.customColumnDividerVariant;
			this.setInvalidationFlag(INVALIDATION_FLAG_COLUMN_DIVIDER_FACTORY);
		}
		var columnDividerInvalid = this.isInvalid(INVALIDATION_FLAG_COLUMN_DIVIDER_FACTORY);

		this.validateColumns();

		if (dataInvalid || sortInvalid) {
			this.refreshSortedColumn(sortInvalid);
		}

		if (stylesInvalid || layoutInvalid) {
			this.refreshColumnResizeSkin();
		}

		if (headerRendererInvalid || stateInvalid || dataInvalid || sortInvalid) {
			this.refreshHeaderRenderers();
		}

		if (headerDividerInvalid || stateInvalid || dataInvalid || sortInvalid) {
			this.refreshHeaderDividers();
		}

		if (columnDividerInvalid || stateInvalid || dataInvalid || sortInvalid) {
			this.refreshColumnDividers();
		}

		if (layoutInvalid) {
			this._headerResizeContainer.mouseEnabled = this._resizableColumns;
			this._headerResizeContainer.mouseChildren = this._resizableColumns;
		}

		if (layoutInvalid || stylesInvalid) {
			if (this._previousLayout != this.layout) {
				// don't keep the old layout's cache because it may not be
				// compatible with the new layout
				this._virtualCache.resize(0);
				if (this._dataProvider != null) {
					this._virtualCache.resize(this._dataProvider.length);
				}
			}
			this.gridViewPort.layout = this.layout;
			this._previousLayout = this.layout;
		}

		this.gridViewPort.refreshChildren = this.refreshRowRenderers;

		for (flag in this._invalidationFlags.keys()) {
			this.gridViewPort.setInvalid(flag);
		}

		super.update();

		this._previousCustomHeaderRendererVariant = this.customHeaderRendererVariant;

		this.validateCustomColumnWidths();
		this.layoutHeaders();
		this.layoutHeaderDividers();
		this.layoutColumnDividers();
		this.handlePendingScroll();
	}

	override private function refreshScrollerValues():Void {
		super.refreshScrollerValues();
		if ((this.layout is IScrollLayout)) {
			var scrollLayout = cast(this.layout, IScrollLayout);
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
		this.scroller.snapPositionsX = this.gridViewPort.snapPositionsX;
		this.scroller.snapPositionsY = this.gridViewPort.snapPositionsY;
	}

	override private function needsScrollMeasurement():Bool {
		var oldStart = this._visibleIndices.start;
		var oldEnd = this._visibleIndices.end;
		if (this._virtualLayout && (this.layout is IVirtualLayout)) {
			var virtualLayout = cast(this.layout, IVirtualLayout);
			virtualLayout.scrollX = this.scrollX;
			virtualLayout.scrollY = this.scrollY;
			virtualLayout.getVisibleIndices(this._rowLayoutItems.length, this.gridViewPort.visibleWidth, this.gridViewPort.visibleHeight,
				this._tempVisibleIndices);
		} else {
			this._tempVisibleIndices.start = 0;
			this._tempVisibleIndices.end = this._rowLayoutItems.length - 1;
		}
		return oldStart != this._tempVisibleIndices.start || oldEnd != this._tempVisibleIndices.end;
	}

	override private function calculateViewPortOffsets(forceScrollBars:Bool, useActualBounds:Bool):Void {
		var oldTopViewPortOffset = this.topViewPortOffset;
		var oldRightViewPortOffset = this.rightViewPortOffset;
		var oldBottomViewPortOffset = this.bottomViewPortOffset;
		var oldLeftViewPortOffset = this.leftViewPortOffset;
		if (this.fixedScrollBars && this.showScrollBars) {
			// this extra call is needed for the left/right offsets to affect
			// the padding below
			super.calculateViewPortOffsets(forceScrollBars, useActualBounds);
		}

		if (this._headerContainer != null) {
			var oldIgnoreHeaderLayoutChanges = this._ignoreHeaderLayoutChanges;
			this._ignoreHeaderLayoutChanges = true;
			switch (this.scrollBarYPosition) {
				case LEFT:
					this._headerContainerLayout.paddingLeft = this.leftViewPortOffset;
					this._headerContainerLayout.paddingRight = 0.0;
				default:
					this._headerContainerLayout.paddingLeft = 0.0;
					this._headerContainerLayout.paddingRight = this.rightViewPortOffset;
			}
			this._ignoreHeaderLayoutChanges = oldIgnoreHeaderLayoutChanges;
			// restore these values because we're going to calculate them again
			// this is kind of hacky, but our change to topViewPortOffset
			// depends on left/right offsets being known first
			this.topViewPortOffset = oldTopViewPortOffset;
			this.rightViewPortOffset = oldRightViewPortOffset;
			this.bottomViewPortOffset = oldBottomViewPortOffset;
			this.leftViewPortOffset = oldLeftViewPortOffset;

			this._headerContainer.validateNow();
			this.topViewPortOffset += this._headerContainer.height;
			this.chromeMeasuredWidth = Math.max(this.chromeMeasuredWidth, this._headerContainer.width);
			this.chromeMeasuredMinWidth = Math.max(this.chromeMeasuredMinWidth, this._headerContainer.width);

			// call again after measuring the headers because they are affected
			// by the topViewPortOffset that we changed above
			super.calculateViewPortOffsets(forceScrollBars, useActualBounds);

			var oldIgnoreHeaderLayoutChanges = this._ignoreHeaderLayoutChanges;
			this._ignoreHeaderLayoutChanges = true;
			switch (this.scrollBarYPosition) {
				case LEFT:
					this._headerContainerLayout.paddingLeft = this.leftViewPortOffset;
					this._headerContainerLayout.paddingRight = 0.0;
				default:
					this._headerContainerLayout.paddingLeft = 0.0;
					this._headerContainerLayout.paddingRight = this.rightViewPortOffset;
			}
			this._ignoreHeaderLayoutChanges = oldIgnoreHeaderLayoutChanges;
		}
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
		var oldIgnoreHeaderLayoutChanges = this._ignoreHeaderLayoutChanges;
		this._ignoreHeaderLayoutChanges = true;
		this._headerContainerLayout.customColumnWidths = this._customColumnWidths;
		this._ignoreHeaderLayoutChanges = oldIgnoreHeaderLayoutChanges;

		this._headerContainer.x = this.paddingLeft;
		this._headerContainer.y = this.paddingTop;
		var minHeaderWidth = this.actualWidth - this.paddingLeft - this.paddingRight;
		// same width as the viewPort so that the columns line up
		this._headerContainer.width = Math.max(this._viewPort.width + this._headerContainerLayout.paddingLeft + this._headerContainerLayout.paddingRight,
			minHeaderWidth);
		this._headerContainer.validateNow();

		if (!MathUtil.fuzzyEquals(this.maxScrollX, this.minScrollX)) {
			// instead of creating a new Rectangle every time, we're going to swap
			// between two of them to avoid excessive garbage collection
			var scrollRect = this._scrollRect1;
			if (this._currentScrollRect == scrollRect) {
				scrollRect = this._scrollRect2;
			}
			this._currentScrollRect = scrollRect;

			// no larger than the full width
			var scrollRectWidth = minHeaderWidth;
			if (scrollRectWidth < 0.0) {
				scrollRectWidth = 0.0;
			}
			var scrollRectHeight = this._headerContainer.height;
			if (scrollRectHeight < 0.0) {
				scrollRectHeight = 0.0;
			}
			scrollRect.setTo(this.scrollX - this.minScrollX, 0.0, scrollRectWidth, scrollRectHeight);
			this._headerContainer.scrollRect = scrollRect;
		} else {
			this._headerContainer.scrollRect = null;
		}
	}

	private function layoutHeaderDividers():Void {
		this._headerResizeContainer.x = this._headerContainer.x;
		this._headerResizeContainer.y = this._headerContainer.y;
		for (i in 0...this._headerDividerLayoutItems.length) {
			var headerDivider = this._headerDividerLayoutItems[i];
			headerDivider.visible = !this.showHeaderDividersOnlyWhenResizable || this.resizableColumns;
			if ((headerDivider is IValidating)) {
				cast(headerDivider, IValidating).validateNow();
			}
			var headerRenderer = this._headerLayoutItems[i];
			headerDivider.x = headerRenderer.x + headerRenderer.width - (headerDivider.width / 2.0);
			headerDivider.y = headerRenderer.y;
			headerDivider.height = headerRenderer.height;
		}
	}

	private function layoutColumnDividers():Void {
		this._columnDividerContainer.x = this._viewPort.x;
		this._columnDividerContainer.y = this._viewPort.y;
		for (i in 0...this._columnDividerLayoutItems.length) {
			var columnDivider = this._columnDividerLayoutItems[i];
			if ((columnDivider is IValidating)) {
				cast(columnDivider, IValidating).validateNow();
			}
			var headerRenderer = this._headerLayoutItems[i];
			columnDivider.x = headerRenderer.x + headerRenderer.width - (columnDivider.width / 2.0);
			columnDivider.y = headerRenderer.y;
			columnDivider.height = this._viewPort.visibleHeight;
		}
	}

	override private function layoutScrollBars():Void {
		if (!this.extendedScrollBarY) {
			super.layoutScrollBars();
			return;
		}
		var oldTopViewPortOffset = this.topViewPortOffset;
		this.topViewPortOffset = 0.0;
		super.layoutScrollBars();
		this.topViewPortOffset = oldTopViewPortOffset;
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
		if ((this._currentColumnResizeSkin is IUIControl)) {
			cast(this._currentColumnResizeSkin, IUIControl).initializeNow();
		}
		if ((this._currentColumnResizeSkin is IProgrammaticSkin)) {
			cast(this._currentColumnResizeSkin, IProgrammaticSkin).uiContext = this;
		}
		this._currentColumnResizeSkin.visible = false;
		if ((this._currentColumnResizeSkin is InteractiveObject)) {
			cast(this._currentColumnResizeSkin, InteractiveObject).mouseEnabled = false;
		}
		if ((this._currentColumnResizeSkin is DisplayObjectContainer)) {
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
		if ((skin is IProgrammaticSkin)) {
			cast(skin, IProgrammaticSkin).uiContext = null;
		}
		if (skin.parent == this) {
			this.removeChild(skin);
		}
	}

	private function refreshHeaderRenderers():Void {
		var oldIgnoreHeaderLayoutChanges = this._ignoreHeaderLayoutChanges;
		this._ignoreHeaderLayoutChanges = true;
		this._headerContainerLayout.columns = this._columns;
		this._ignoreHeaderLayoutChanges = oldIgnoreHeaderLayoutChanges;

		if (this._defaultHeaderStorage.headerRendererRecycler.update == null) {
			this._defaultHeaderStorage.headerRendererRecycler.update = defaultUpdateHeaderRenderer;
			if (this._defaultHeaderStorage.headerRendererRecycler.reset == null) {
				this._defaultHeaderStorage.headerRendererRecycler.reset = defaultResetHeaderRenderer;
			}
		}

		var headerRendererInvalid = this.isInvalid(INVALIDATION_FLAG_HEADER_RENDERER_FACTORY);
		this.refreshInactiveHeaderRenderers(headerRendererInvalid);
		this.findUnrenderedHeaderData();
		this.recoverInactiveHeaderRenderers();
		this.renderUnrenderedHeaderData();
		this.freeInactiveHeaderRenderers();
		if (this._defaultHeaderStorage.inactiveHeaderRenderers.length > 0) {
			throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: inactive header renderers should be empty after updating.');
		}
	}

	private function refreshHeaderDividers():Void {
		var headerDividerInvalid = this.isInvalid(INVALIDATION_FLAG_HEADER_DIVIDER_FACTORY);
		this.refreshInactiveHeaderDividers(headerDividerInvalid);
		this.refreshActiveHeaderDividers();
		this.freeInactiveHeaderDividers();
		if (this._defaultHeaderDividerStorage.inactiveHeaderDividers.length > 0) {
			throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: inactive header dividers should be empty after updating.');
		}
	}

	private function refreshColumnDividers():Void {
		var columnDividerInvalid = this.isInvalid(INVALIDATION_FLAG_COLUMN_DIVIDER_FACTORY);
		this.refreshInactiveColumnDividers(columnDividerInvalid);
		this.refreshActiveColumnDividers();
		this.freeInactiveColumnDividers();
		if (this._defaultColumnDividerStorage.inactiveColumnDividers.length > 0) {
			throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: inactive column dividers should be empty after updating.');
		}
	}

	private function refreshInactiveHeaderDividers(factoryInvalid:Bool):Void {
		var temp = this._defaultHeaderDividerStorage.inactiveHeaderDividers;
		this._defaultHeaderDividerStorage.inactiveHeaderDividers = this._defaultHeaderDividerStorage.activeHeaderDividers;
		this._defaultHeaderDividerStorage.activeHeaderDividers = temp;
		if (this._defaultHeaderDividerStorage.activeHeaderDividers.length > 0) {
			throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: active header dividers should be empty before updating.');
		}
		if (factoryInvalid) {
			this.freeInactiveHeaderDividers();
			this._defaultHeaderDividerStorage.oldHeaderDividerFactory = null;
		}
	}

	private function freeInactiveHeaderDividers():Void {
		var factory = this._defaultHeaderDividerStorage.oldHeaderDividerFactory != null ? this._defaultHeaderDividerStorage.oldHeaderDividerFactory : this._defaultHeaderDividerStorage.headerDividerFactory;
		for (headerDivider in this._defaultHeaderDividerStorage.inactiveHeaderDividers) {
			if (headerDivider == null) {
				continue;
			}
			this.destroyHeaderDivider(headerDivider, factory);
		}
		this._defaultHeaderDividerStorage.inactiveHeaderDividers.resize(0);
	}

	private function refreshActiveHeaderDividers():Void {
		this._headerDividerLayoutItems.resize(0);
		if (this._defaultHeaderDividerStorage.headerDividerFactory == null) {
			return;
		}

		for (i in 0...this._columns.length - 1) {
			var column = this._columns.get(i);
			var headerDivider = this.createHeaderDivider(column, i);
			this._headerDividerLayoutItems[i] = headerDivider;
			this._defaultHeaderDividerStorage.activeHeaderDividers.push(headerDivider);
		}
	}

	private function createHeaderDivider(column:GridViewColumn, columnIndex:Int):InteractiveObject {
		var headerDivider:InteractiveObject = null;
		if (this._defaultHeaderDividerStorage.inactiveHeaderDividers.length == 0) {
			headerDivider = this._defaultHeaderDividerStorage.headerDividerFactory.create();
			if ((headerDivider is IVariantStyleObject)) {
				var variantHeaderDivider = cast(headerDivider, IVariantStyleObject);
				if (variantHeaderDivider.variant == null) {
					var variant = (this.customHeaderDividerVariant != null) ? this.customHeaderDividerVariant : CHILD_VARIANT_HEADER_DIVIDER;
					variantHeaderDivider.variant = variant;
				}
			}
			if ((headerDivider is IUIControl)) {
				cast(headerDivider, IUIControl).initializeNow();
			}
			headerDivider.addEventListener(MouseEvent.ROLL_OVER, gridView_headerDivider_rollOverHandler);
			headerDivider.addEventListener(MouseEvent.ROLL_OUT, gridView_headerDivider_rollOutHandler);
			headerDivider.addEventListener(MouseEvent.MOUSE_DOWN, gridView_headerDivider_mouseDownHandler);
			headerDivider.addEventListener(TouchEvent.TOUCH_BEGIN, gridView_headerDivider_touchBeginHandler);
			this._headerResizeContainer.addChildAt(headerDivider, columnIndex);
		} else {
			headerDivider = this._defaultHeaderDividerStorage.inactiveHeaderDividers.shift();
			this._headerResizeContainer.setChildIndex(headerDivider, columnIndex);
		}
		return headerDivider;
	}

	private function destroyHeaderDivider(headerDivider:InteractiveObject, factory:DisplayObjectFactory<Dynamic, InteractiveObject>):Void {
		headerDivider.removeEventListener(MouseEvent.ROLL_OVER, gridView_headerDivider_rollOverHandler);
		headerDivider.removeEventListener(MouseEvent.ROLL_OUT, gridView_headerDivider_rollOutHandler);
		headerDivider.removeEventListener(MouseEvent.MOUSE_DOWN, gridView_headerDivider_mouseDownHandler);
		headerDivider.removeEventListener(TouchEvent.TOUCH_BEGIN, gridView_headerDivider_touchBeginHandler);
		this._headerResizeContainer.removeChild(headerDivider);
		if (factory != null && factory.destroy != null) {
			factory.destroy(headerDivider);
		}
	}

	private function refreshInactiveColumnDividers(factoryInvalid:Bool):Void {
		var temp = this._defaultColumnDividerStorage.inactiveColumnDividers;
		this._defaultColumnDividerStorage.inactiveColumnDividers = this._defaultColumnDividerStorage.activeColumnDividers;
		this._defaultColumnDividerStorage.activeColumnDividers = temp;
		if (this._defaultColumnDividerStorage.activeColumnDividers.length > 0) {
			throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: active column dividers should be empty before updating.');
		}
		if (factoryInvalid) {
			this.freeInactiveHeaderDividers();
			this._defaultColumnDividerStorage.oldColumnDividerFactory = null;
		}
	}

	private function freeInactiveColumnDividers():Void {
		var factory = this._defaultColumnDividerStorage.oldColumnDividerFactory != null ? this._defaultColumnDividerStorage.oldColumnDividerFactory : this._defaultColumnDividerStorage.columnDividerFactory;
		for (headerDivider in this._defaultColumnDividerStorage.inactiveColumnDividers) {
			if (headerDivider == null) {
				continue;
			}
			this.destroyColumnDivider(headerDivider, factory);
		}
		this._defaultColumnDividerStorage.inactiveColumnDividers.resize(0);
	}

	private function refreshActiveColumnDividers():Void {
		this._columnDividerLayoutItems.resize(0);
		if (this._defaultColumnDividerStorage.columnDividerFactory == null) {
			return;
		}

		for (i in 0...this._columns.length - 1) {
			var column = this._columns.get(i);
			var columnDivider = this.createColumnDivider(column, i);
			this._columnDividerLayoutItems[i] = columnDivider;
			this._defaultColumnDividerStorage.activeColumnDividers.push(columnDivider);
		}
	}

	private function createColumnDivider(column:GridViewColumn, columnIndex:Int):InteractiveObject {
		var columnDivider:InteractiveObject = null;
		if (this._defaultColumnDividerStorage.inactiveColumnDividers.length == 0) {
			columnDivider = this._defaultColumnDividerStorage.columnDividerFactory.create();
			if ((columnDivider is IVariantStyleObject)) {
				var variantColumnDivider = cast(columnDivider, IVariantStyleObject);
				if (variantColumnDivider.variant == null) {
					var variant = (this.customColumnDividerVariant != null) ? this.customColumnDividerVariant : CHILD_VARIANT_COLUMN_DIVIDER;
					variantColumnDivider.variant = variant;
				}
			}
			if ((columnDivider is IUIControl)) {
				cast(columnDivider, IUIControl).initializeNow();
			}
			this._columnDividerContainer.addChildAt(columnDivider, columnIndex);
		} else {
			columnDivider = this._defaultColumnDividerStorage.inactiveColumnDividers.shift();
			this._columnDividerContainer.setChildIndex(columnDivider, columnIndex);
		}
		return columnDivider;
	}

	private function destroyColumnDivider(columnDivider:DisplayObject, factory:DisplayObjectFactory<Dynamic, DisplayObject>):Void {
		this._columnDividerContainer.removeChild(columnDivider);
		if (factory != null && factory.destroy != null) {
			factory.destroy(columnDivider);
		}
	}

	private function refreshInactiveHeaderRenderers(factoryInvalid:Bool):Void {
		var temp = this._defaultHeaderStorage.inactiveHeaderRenderers;
		this._defaultHeaderStorage.inactiveHeaderRenderers = this._defaultHeaderStorage.activeHeaderRenderers;
		this._defaultHeaderStorage.activeHeaderRenderers = temp;
		if (this._defaultHeaderStorage.activeHeaderRenderers.length > 0) {
			throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: active header renderers should be empty before updating.');
		}
		if (factoryInvalid) {
			this.recoverInactiveHeaderRenderers();
			this.freeInactiveHeaderRenderers();
			this._defaultHeaderStorage.oldHeaderRendererRecycler = null;
		}
	}

	private function recoverInactiveHeaderRenderers():Void {
		for (headerRenderer in this._defaultHeaderStorage.inactiveHeaderRenderers) {
			if (headerRenderer == null) {
				continue;
			}
			var state = this.headerRendererToHeaderState.get(headerRenderer);
			if (state == null) {
				continue;
			}
			var column = state.column;
			this.headerRendererToHeaderState.remove(headerRenderer);
			this.dataToHeaderRenderer.remove(column);
			headerRenderer.removeEventListener(TriggerEvent.TRIGGER, gridView_headerRenderer_triggerHandler);
			headerRenderer.removeEventListener(MouseEvent.CLICK, gridView_headerRenderer_clickHandler);
			headerRenderer.removeEventListener(TouchEvent.TOUCH_TAP, gridView_headerRenderer_touchTapHandler);
			this.resetHeaderRenderer(headerRenderer, state);
			if (this._defaultHeaderStorage.measurements != null) {
				this._defaultHeaderStorage.measurements.restore(headerRenderer);
			}
			this.headerStatePool.release(state);
		}
	}

	private function freeInactiveHeaderRenderers():Void {
		var recycler = this._defaultHeaderStorage.oldHeaderRendererRecycler != null ? this._defaultHeaderStorage.oldHeaderRendererRecycler : this._defaultHeaderStorage.headerRendererRecycler;
		for (headerRenderer in this._defaultHeaderStorage.inactiveHeaderRenderers) {
			if (headerRenderer == null) {
				continue;
			}
			this.destroyHeaderRenderer(headerRenderer, recycler);
		}
		this._defaultHeaderStorage.inactiveHeaderRenderers.resize(0);
	}

	private function findUnrenderedHeaderData():Void {
		// remove all old items, then fill with null
		this._rowLayoutItems.resize(0);
		if (this._columns == null || this._columns.length == 0) {
			return;
		}
		this._rowLayoutItems.resize(this._columns.length);

		for (i in 0...this._columns.length) {
			var column = this._columns.get(i);
			var headerRenderer = this.dataToHeaderRenderer.get(column);
			if (headerRenderer != null) {
				var state = this.headerRendererToHeaderState.get(headerRenderer);
				this.populateCurrentHeaderState(column, i, state);
				this.updateHeaderRenderer(headerRenderer, state);
				// if this item renderer used to be the typical layout item, but
				// it isn't anymore, it may have been set invisible
				headerRenderer.visible = true;
				this._headerLayoutItems[i] = headerRenderer;
				var removed = this._defaultHeaderStorage.inactiveHeaderRenderers.remove(headerRenderer);
				if (!removed) {
					throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: header renderer map contains bad data for column at index ${i}. This may be caused by duplicate columns, which is not allowed.');
				}
				this._defaultHeaderStorage.activeHeaderRenderers.push(headerRenderer);
			} else {
				this._unrenderedHeaderData.push(column);
			}
		}
	}

	private function renderUnrenderedHeaderData():Void {
		for (column in this._unrenderedHeaderData) {
			var index = this._columns.indexOf(column);
			var state = this.headerStatePool.get();
			this.populateCurrentHeaderState(column, index, state);
			var headerRenderer = this.createHeaderRenderer(state);
			headerRenderer.visible = true;
			this._headerContainer.addChildAt(headerRenderer, index);
			this._headerLayoutItems[index] = headerRenderer;
		}
		this._unrenderedHeaderData.resize(0);
	}

	private function refreshRowRenderers(items:Array<DisplayObject>):Void {
		this._rowLayoutItems = items;

		this.refreshInactiveRowRenderers();
		this.findUnrenderedData();
		this.recoverInactiveRowRenderers();
		this.renderUnrenderedData();
		this.freeInactiveRowRenderers();
		if (this.inactiveRowRenderers.length > 0) {
			throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: inactive row renderers should be empty after updating.');
		}
	}

	private function refreshInactiveRowRenderers():Void {
		var temp = this.inactiveRowRenderers;
		this.inactiveRowRenderers = this.activeRowRenderers;
		this.activeRowRenderers = temp;
		if (this.activeRowRenderers.length > 0) {
			throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: active row renderers should be empty before updating.');
		}
	}

	private function recoverInactiveRowRenderers():Void {
		for (rowRenderer in this.inactiveRowRenderers) {
			if (rowRenderer == null) {
				continue;
			}
			var state = this.rowRendererToRowState.get(rowRenderer);
			if (state == null) {
				return;
			}
			var item = state.data;
			this.rowRendererToRowState.remove(rowRenderer);
			this.dataToRowRenderer.remove(item);
			rowRenderer.removeEventListener(GridViewEvent.CELL_TRIGGER, gridView_rowRenderer_cellTriggerHandler);
			rowRenderer.removeEventListener(TriggerEvent.TRIGGER, gridView_rowRenderer_triggerHandler);
			this.resetRowRenderer(rowRenderer, state);
			if (this._rowRendererMeasurements != null) {
				this._rowRendererMeasurements.restore(rowRenderer);
			}
			this.rowStatePool.release(state);
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
		this._rowLayoutItems.resize(0);
		this._visibleIndices.start = 0;
		this._visibleIndices.end = 0;
		if (this._dataProvider == null || this._dataProvider.length == 0) {
			return;
		}
		this._rowLayoutItems.resize(this._dataProvider.length);

		if (this._virtualLayout && (this.layout is IVirtualLayout)) {
			var virtualLayout = cast(this.layout, IVirtualLayout);
			var oldIgnoreLayoutChanges = this._ignoreLayoutChanges;
			this._ignoreLayoutChanges = true;
			virtualLayout.virtualCache = this._virtualCache;
			this._ignoreLayoutChanges = oldIgnoreLayoutChanges;
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
				var state = this.rowRendererToRowState.get(rowRenderer);
				this.populateCurrentRowState(item, i, state);
				this.updateRowRenderer(rowRenderer, state);
				this._rowLayoutItems[i] = rowRenderer;
				var removed = this.inactiveRowRenderers.remove(rowRenderer);
				if (!removed) {
					throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: row renderer map contains bad data for item at index ${i}. This may be caused by duplicate items in the data provider, which is not allowed.');
				}
				this.activeRowRenderers.push(rowRenderer);
			} else {
				this._unrenderedData.push(item);
			}
		}
	}

	private function renderUnrenderedData():Void {
		for (item in this._unrenderedData) {
			var rowIndex = this._dataProvider.indexOf(item);
			var state = this.rowStatePool.get();
			this.populateCurrentRowState(item, rowIndex, state);
			var rowRenderer = this.createRowRenderer(state);
			rowRenderer.visible = true;
			this.activeRowRenderers.push(rowRenderer);
			this.gridViewPort.addChild(rowRenderer);
			this._rowLayoutItems[rowIndex] = rowRenderer;
		}
		this._unrenderedData.resize(0);
	}

	private function createRowRenderer(state:GridViewCellState):GridViewRowRenderer {
		var rowRenderer:GridViewRowRenderer = null;
		if (this.inactiveRowRenderers.length == 0) {
			rowRenderer = this._rowRendererRecycler.create();
			if (this._rowRendererMeasurements == null) {
				this._rowRendererMeasurements = new Measurements(rowRenderer);
			}
			// for consistency, initialize before passing to the recycler's
			// update function
			rowRenderer.initializeNow();
		} else {
			rowRenderer = this.inactiveRowRenderers.shift();
		}
		this.updateRowRenderer(rowRenderer, state);
		rowRenderer.addEventListener(GridViewEvent.CELL_TRIGGER, gridView_rowRenderer_cellTriggerHandler);
		rowRenderer.addEventListener(TriggerEvent.TRIGGER, gridView_rowRenderer_triggerHandler);
		this.rowRendererToRowState.set(rowRenderer, state);
		this.dataToRowRenderer.set(state.data, rowRenderer);
		return rowRenderer;
	}

	private function destroyRowRenderer(rowRenderer:GridViewRowRenderer):Void {
		this.gridViewPort.removeChild(rowRenderer);
		if (this._rowRendererRecycler.destroy != null) {
			this._rowRendererRecycler.destroy(rowRenderer);
		}
	}

	private function updateRowRenderer(rowRenderer:GridViewRowRenderer, state:GridViewCellState):Void {
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		if (this._rowRendererRecycler.update != null) {
			this._rowRendererRecycler.update(rowRenderer, state);
		}
		this._ignoreSelectionChange = oldIgnoreSelectionChange;
		this.refreshRowRendererProperties(rowRenderer, state);
	}

	private function resetRowRenderer(rowRenderer:GridViewRowRenderer, state:GridViewCellState):Void {
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		if (this._rowRendererRecycler.reset != null) {
			this._rowRendererRecycler.reset(rowRenderer, state);
		}
		this._ignoreSelectionChange = oldIgnoreSelectionChange;
		this.refreshRowRendererProperties(rowRenderer, RESET_ROW_STATE);
	}

	private function populateCurrentRowState(item:Dynamic, rowIndex:Int, state:GridViewCellState):Void {
		state.owner = this;
		state.data = item;
		state.rowIndex = rowIndex;
		state.columnIndex = -1;
		state.selected = this._selectedIndices.indexOf(rowIndex) != -1;
		state.column = null;
		state.text = null;
		state.enabled = this._enabled;
	}

	private function refreshRowRendererProperties(rowRenderer:GridViewRowRenderer, state:GridViewCellState):Void {
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		rowRenderer.gridView = state.owner;
		rowRenderer.data = state.data;
		rowRenderer.rowIndex = state.rowIndex;
		rowRenderer.selected = state.selected;
		rowRenderer.enabled = state.enabled;
		rowRenderer.columns = (state.rowIndex == -1) ? null : this._columns;
		rowRenderer.selectable = (state.rowIndex == -1) ? false : this._selectable;
		rowRenderer.cellRendererRecycler = (state.rowIndex == -1) ? null : this._cellRendererRecycler;
		rowRenderer.customColumnWidths = (state.rowIndex == -1) ? null : this._customColumnWidths;
		this._ignoreSelectionChange = oldIgnoreSelectionChange;
	}

	private function createHeaderRenderer(state:GridViewHeaderState):DisplayObject {
		var headerRenderer:DisplayObject = null;
		if (this._defaultHeaderStorage.inactiveHeaderRenderers.length == 0) {
			headerRenderer = this._defaultHeaderStorage.headerRendererRecycler.create();
			if ((headerRenderer is IVariantStyleObject)) {
				var variantHeaderRenderer = cast(headerRenderer, IVariantStyleObject);
				if (variantHeaderRenderer.variant == null) {
					var variant = (this.customHeaderRendererVariant != null) ? this.customHeaderRendererVariant : CHILD_VARIANT_HEADER_RENDERER;
					variantHeaderRenderer.variant = variant;
				}
			}
			// for consistency, initialize before passing to the recycler's
			// update function. plus, this ensures that custom header renderers
			// correctly handle property changes in update() instead of trying
			// to access them too early in initialize().
			if ((headerRenderer is IUIControl)) {
				cast(headerRenderer, IUIControl).initializeNow();
			}
			// save measurements after initialize, because width/height could be
			// set explicitly there, and we want to restore those values
			if (this._defaultHeaderStorage.measurements == null) {
				this._defaultHeaderStorage.measurements = new Measurements(headerRenderer);
			}
		} else {
			headerRenderer = this._defaultHeaderStorage.inactiveHeaderRenderers.shift();
		}
		this.updateHeaderRenderer(headerRenderer, state);
		if ((headerRenderer is ITriggerView)) {
			// prefer TriggerEvent.TRIGGER
			headerRenderer.addEventListener(TriggerEvent.TRIGGER, gridView_headerRenderer_triggerHandler);
		} else {
			// fall back to these events if TriggerEvent.TRIGGER isn't available
			headerRenderer.addEventListener(MouseEvent.CLICK, gridView_headerRenderer_clickHandler);
			#if (openfl >= "9.0.0")
			headerRenderer.addEventListener(TouchEvent.TOUCH_TAP, gridView_headerRenderer_touchTapHandler);
			#end
		}
		this.headerRendererToHeaderState.set(headerRenderer, state);
		this.dataToHeaderRenderer.set(state.column, headerRenderer);
		this._defaultHeaderStorage.activeHeaderRenderers.push(headerRenderer);
		return headerRenderer;
	}

	private function destroyHeaderRenderer(headerRenderer:DisplayObject, recycler:DisplayObjectRecycler<Dynamic, GridViewHeaderState, DisplayObject>):Void {
		this._headerContainer.removeChild(headerRenderer);
		if (recycler != null && recycler.destroy != null) {
			recycler.destroy(headerRenderer);
		}
	}

	private function populateCurrentHeaderState(column:GridViewColumn, columnIndex:Int, state:GridViewHeaderState):Void {
		state.owner = this;
		state.column = column;
		state.columnIndex = columnIndex;
		state.text = column.headerText;
		state.enabled = this._enabled;
	}

	private function updateHeaderRenderer(headerRenderer:DisplayObject, state:GridViewHeaderState):Void {
		if (this._defaultHeaderStorage.headerRendererRecycler.update != null) {
			this._defaultHeaderStorage.headerRendererRecycler.update(headerRenderer, state);
		}
		this.refreshHeaderRendererProperties(headerRenderer, state);
	}

	private function resetHeaderRenderer(headerRenderer:DisplayObject, state:GridViewHeaderState):Void {
		var recycler = this._defaultHeaderStorage.oldHeaderRendererRecycler != null ? this._defaultHeaderStorage.oldHeaderRendererRecycler : this._defaultHeaderStorage.headerRendererRecycler;
		if (recycler != null && recycler.reset != null) {
			recycler.reset(headerRenderer, state);
		}
		this.refreshHeaderRendererProperties(headerRenderer, RESET_HEADER_STATE);
	}

	private function refreshHeaderRendererProperties(headerRenderer:DisplayObject, state:GridViewHeaderState):Void {
		if ((headerRenderer is IUIControl)) {
			var uiControl = cast(headerRenderer, IUIControl);
			uiControl.enabled = state.enabled;
		}
		if ((headerRenderer is IGridViewHeaderRenderer)) {
			var header = cast(headerRenderer, IGridViewHeaderRenderer);
			header.column = state.column;
			header.columnIndex = state.columnIndex;
			header.gridViewOwner = state.owner;
		}
		if ((headerRenderer is ISortOrderObserver)) {
			var sortObject = cast(headerRenderer, ISortOrderObserver);
			if (this._sortedColumn == state.column) {
				sortObject.sortOrder = this._sortOrder;
			} else {
				sortObject.sortOrder = NONE;
			}
		}
		if ((headerRenderer is ILayoutIndexObject)) {
			var layoutObject = cast(headerRenderer, ILayoutIndexObject);
			layoutObject.layoutIndex = state.columnIndex;
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
		if (event.isDefaultPrevented()) {
			return;
		}
		if (this._dataProvider == null || this._dataProvider.length == 0) {
			return;
		}
		var result = this._selectedIndex;
		if ((this.layout is IKeyboardNavigationLayout)) {
			if (event.keyCode != Keyboard.UP && event.keyCode != Keyboard.DOWN && event.keyCode != Keyboard.LEFT && event.keyCode != Keyboard.RIGHT
				&& event.keyCode != Keyboard.PAGE_UP && event.keyCode != Keyboard.PAGE_DOWN && event.keyCode != Keyboard.HOME && event.keyCode != Keyboard.END) {
				return;
			}
			result = cast(this.layout, IKeyboardNavigationLayout).findNextKeyboardIndex(result, event, false, this._rowLayoutItems, null,
				this.gridViewPort.visibleWidth, this.gridViewPort.visibleHeight);
		} else {
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
		}
		if (result < 0) {
			result = 0;
		} else if (result >= this._dataProvider.length) {
			result = this._dataProvider.length - 1;
		}
		if (result == this._selectedIndex) {
			return;
		}
		event.preventDefault();
		// use the setter
		this.selectedIndex = result;
		if (this._selectedIndex != -1) {
			this.scrollToRowIndex(this._selectedIndex);
		}
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

	private function handlePendingScroll():Void {
		if (this._pendingScrollRowIndex == -1) {
			return;
		}
		var rowIndex = this._pendingScrollRowIndex;
		var duration = this._pendingScrollDuration != null ? this._pendingScrollDuration : 0.0;
		this._pendingScrollRowIndex = -1;
		this._pendingScrollDuration = null;

		if (this._dataProvider == null || this._dataProvider.length == 0) {
			return;
		}

		var targetX = this.scrollX;
		var targetY = this.scrollY;
		if ((this.layout is IScrollLayout)) {
			var scrollLayout = cast(this.layout, IScrollLayout);
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

		if (duration == 0.0) {
			this.scroller.scrollX = targetX;
			this.scroller.scrollY = targetY;
		} else {
			this.scroller.throwTo(targetX, targetY, duration);
		}
	}

	override private function baseScrollContainer_keyDownHandler(event:KeyboardEvent):Void {
		if (!this._selectable) {
			super.baseScrollContainer_keyDownHandler(event);
			return;
		}
		if (!this._enabled || event.isDefaultPrevented()) {
			return;
		}
		this.navigateWithKeyboard(event);
	}

	private function gridView_rowRenderer_triggerHandler(event:TriggerEvent):Void {
		var rowRenderer = cast(event.currentTarget, GridViewRowRenderer);
		var state = this.rowRendererToRowState.get(rowRenderer);
		this.handleSelectionChange(state.data, state.rowIndex, event.ctrlKey, event.shiftKey);
	}

	private function gridView_rowRenderer_cellTriggerHandler(event:GridViewEvent<GridViewCellState>):Void {
		this.dispatchEvent(event.clone());
	}

	private function gridView_dataProvider_changeHandler(event:Event):Void {
		if (this._ignoreDataProviderChanges) {
			return;
		}
		this.setInvalid(DATA);
	}

	private function gridView_dataProvider_addItemHandler(event:FlatCollectionEvent):Void {
		if (this._virtualCache != null) {
			this._virtualCache.insert(event.index, null);
		}
		if (this._selectedIndex == -1) {
			return;
		}
		var changed = false;
		for (i in 0...this._selectedIndices.length) {
			var selectedIndex = this._selectedIndices[i];
			if (selectedIndex >= event.index) {
				this._selectedIndices[i] = selectedIndex + 1;
				changed = true;
			}
		}
		if (changed) {
			this._selectedIndex = this._selectedIndices[0];
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
		var changed = false;
		var i = this._selectedIndices.length - 1;
		while (i >= 0) {
			var selectedIndex = this._selectedIndices[i];
			if (selectedIndex == event.index) {
				this._selectedIndices.splice(i, 1);
				this._selectedItems.splice(i, 1);
				changed = true;
			} else if (selectedIndex > event.index) {
				this._selectedIndices[i] = selectedIndex - 1;
				changed = true;
			}
			i--;
		}
		if (changed) {
			if (this._selectedIndices.length > 0) {
				this._selectedIndex = this._selectedIndices[0];
				this._selectedItem = this._dataProvider.get(this._selectedIndex);
			} else {
				this._selectedIndex = -1;
				this._selectedItem = null;
			}
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
		for (i in 0...this._selectedIndices.length) {
			var selectedIndex = this._selectedIndices[i];
			if (selectedIndex == event.index) {
				// unlike when an item is removed, the selected index is kept when
				// an item is replaced
				this._selectedItems[i] = this._dataProvider.get(selectedIndex);
				this._selectedItem = this._selectedItems[0];
				FeathersEvent.dispatch(this, Event.CHANGE);
				break;
			}
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

	@:access(feathers.controls.dataRenderers.GridViewRowRenderer)
	private function updateRowRendererForIndex(index:Int):Void {
		if (this._virtualCache != null) {
			this._virtualCache[index] = null;
		}
		var item = this._dataProvider.get(index);
		var rowRenderer = this.dataToRowRenderer.get(item);
		if (rowRenderer == null) {
			// doesn't exist yet, so we need to do a full invalidation
			this.setInvalid(DATA);
			return;
		}
		var state = this.rowRendererToRowState.get(rowRenderer);
		this.populateCurrentRowState(item, index, state);
		// in order to display the same item with modified properties, this
		// hack tricks the item renderer into thinking that it has been given
		// a different item to render.
		this.resetRowRenderer(rowRenderer, state);
		if (this._rowRendererMeasurements != null) {
			this._rowRendererMeasurements.restore(rowRenderer);
		}
		this.updateRowRenderer(rowRenderer, state);
		rowRenderer.updateCells();
		this.setInvalid(LAYOUT);
	}

	private function validateCustomColumnWidths():Void {
		if (this._customColumnWidths == null || this._customColumnWidths.length < this._columns.length) {
			return;
		}

		var minContainerWidth = this.actualWidth - this.paddingLeft - this.paddingRight;
		// same width as the viewPort so that the columns line up
		var totalContainerWidth = Math.max(this._viewPort.width + this._headerContainerLayout.paddingLeft + this._headerContainerLayout.paddingRight,
			minContainerWidth);
		var availableWidth = totalContainerWidth - this._headerContainerLayout.paddingLeft - this._headerContainerLayout.paddingRight;
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
			indices.push(i);
		}
		if (totalWidth == availableWidth) {
			return;
		}

		// make a copy so that this is detected as a change
		this._customColumnWidths = this._customColumnWidths.copy();

		var widthToDistribute = availableWidth - totalWidth;
		this.distributeWidthToIndices(widthToDistribute, indices, totalWidth);
		this.setInvalid(LAYOUT);
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
		var headerRenderer = this._headerLayoutItems[this._resizingHeaderIndex];
		var column = this._columns.get(this._resizingHeaderIndex);
		var minX = this._headerContainer.x + headerRenderer.x + column.minWidth;
		var maxX = this.actualWidth - this.rightViewPortOffset;
		var originalX = this._headerContainer.x + headerRenderer.x + headerRenderer.width;
		var newX = Math.min(Math.max(originalX + offset, minX), maxX);

		var preferredWidth = newX - headerRenderer.x - this._headerContainer.x;
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
				headerRenderer = this._headerLayoutItems[i];
				this._customColumnWidths[i] = headerRenderer.width;
				totalMinWidth += headerRenderer.width;
			} else {
				if (currentColumn.width != null) {
					totalMinWidth += currentColumn.width;
					continue;
				}
				totalMinWidth += currentColumn.minWidth;
				headerRenderer = this._headerLayoutItems[i];
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
				var headerRenderer = this._headerLayoutItems[index];
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

		if (widthToDistribute != 0.0) {
			// if we have less than a pixel left, just add it to the
			// final column and exit the loop
			this._customColumnWidths[this._customColumnWidths.length - 1] += widthToDistribute;
		}
	}

	private function layoutColumnResizeSkin(offset:Float):Void {
		if (this._currentColumnResizeSkin == null) {
			return;
		}
		var headerRenderer = this._headerLayoutItems[this._resizingHeaderIndex];
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

	private function headerResizeTouchBegin(touchID:Int, divider:InteractiveObject, stageX:Float):Void {
		if (!this._enabled || !this._resizableColumns || this._resizingHeaderIndex != -1 || this.stage == null) {
			return;
		}

		var exclusivePointer = ExclusivePointer.forStage(this.stage);
		var result = exclusivePointer.claimPointer(touchID, divider);
		if (!result) {
			return;
		}

		this._resizingHeaderTouchID = touchID;
		this._resizingHeaderIndex = this._headerDividerLayoutItems.indexOf(divider);
		this._resizingHeaderStartStageX = stageX;
		this.layoutColumnResizeSkin(0.0);
		if (touchID == ExclusivePointer.POINTER_ID_MOUSE) {
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, gridView_headerDivider_stage_mouseMoveHandler, false, 0, true);
			this.stage.addEventListener(MouseEvent.MOUSE_UP, gridView_headerDivider_stage_mouseUpHandler, false, 0, true);
		} else {
			this.stage.addEventListener(TouchEvent.TOUCH_MOVE, gridView_headerDivider_stage_touchMoveHandler, false, 0, true);
			this.stage.addEventListener(TouchEvent.TOUCH_END, gridView_headerDivider_stage_touchEndHandler, false, 0, true);
		}
	}

	private function headerResizeTouchMove(touchID:Int, stageX:Float):Void {
		if (this._resizingHeaderTouchID != touchID) {
			return;
		}

		var offset = stageX - this._resizingHeaderStartStageX;
		offset *= DisplayUtil.getConcatenatedScaleX(this);
		this.layoutColumnResizeSkin(offset);
	}

	private function headerResizeTouchEnd(touchID:Int, stageX:Float):Void {
		if (this._resizingHeaderTouchID != touchID) {
			return;
		}

		if (touchID == ExclusivePointer.POINTER_ID_MOUSE) {
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, gridView_headerDivider_stage_mouseMoveHandler);
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, gridView_headerDivider_stage_mouseUpHandler);
		} else {
			this.stage.removeEventListener(TouchEvent.TOUCH_MOVE, gridView_headerDivider_stage_touchMoveHandler);
			this.stage.removeEventListener(TouchEvent.TOUCH_END, gridView_headerDivider_stage_touchEndHandler);
		}

		if (this._currentColumnResizeSkin != null) {
			this._currentColumnResizeSkin.visible = false;
		}

		var offset = stageX - this._resizingHeaderStartStageX;
		offset *= DisplayUtil.getConcatenatedScaleX(this);
		this.calculateResizedColumnWidth(offset);

		this._resizingHeaderTouchID = -1;
		this._resizingHeaderIndex = -1;

		if (this._oldHeaderDividerMouseCursor != null) {
			Mouse.cursor = this._oldHeaderDividerMouseCursor;
			this._oldHeaderDividerMouseCursor = null;
		}
	}

	private function reverseSortCompareFunction(a:Dynamic, b:Dynamic):Int {
		return -this.sortCompareFunction(a, b);
	}

	private function sortCompareFunction(a:Dynamic, b:Dynamic):Int {
		if (this._sortedColumn.sortCompareFunction == null) {
			var aText = this._sortedColumn.itemToText(a);
			var bText = this._sortedColumn.itemToText(b);
			return defaultSortCompareFunction(aText, bText);
		}
		return this._sortedColumn.sortCompareFunction(a, b);
	}

	private function refreshSortedColumn(sortInvalid:Bool):Void {
		if (this._dataProvider == null) {
			return;
		}
		var oldIgnoreDataProviderChanges = this._ignoreDataProviderChanges;
		this._ignoreDataProviderChanges = true;
		if (this._sortOrder == ASCENDING) {
			this._dataProvider.sortCompareFunction = this.sortCompareFunction;
		} else if (this._sortOrder == DESCENDING) {
			this._dataProvider.sortCompareFunction = this.reverseSortCompareFunction;
		} else if (this._dataProvider.sortCompareFunction == this.sortCompareFunction
			|| Reflect.compareMethods(this._dataProvider.sortCompareFunction, this.sortCompareFunction)
			|| this._dataProvider.sortCompareFunction == this.reverseSortCompareFunction
			|| Reflect.compareMethods(this._dataProvider.sortCompareFunction, this.reverseSortCompareFunction)) {
			// don't clear a user-defined sort compare function
			this._dataProvider.sortCompareFunction = null;
		}
		if (sortInvalid) {
			// the sortCompareFunction might not have changed if we're sorting a
			// different column with the same function, so force a refresh.
			this._dataProvider.refresh();
		}
		this._ignoreDataProviderChanges = oldIgnoreDataProviderChanges;
	}

	private function updateSortedColumn(column:GridViewColumn):Void {
		if (!this._sortableColumns || column.defaultSortOrder == NONE) {
			return;
		}
		if (this._sortedColumn != column) {
			this.sortedColumn = column;
		} else {
			this.sortOrder = (this._sortOrder == ASCENDING) ? SortOrder.DESCENDING : SortOrder.ASCENDING;
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

	private function gridView_columns_addItemHandler(event:FlatCollectionEvent):Void {
		if (this._customColumnWidths == null) {
			return;
		}
		var column = cast(event.addedItem, GridViewColumn);
		var columnIndex = event.index;
		if (column.width != null || columnIndex > this._customColumnWidths.length) {
			return;
		}
		this._customColumnWidths.insert(columnIndex, 0.0);

		var minContainerWidth = this.actualWidth - this.paddingLeft - this.paddingRight;
		// same width as the viewPort so that the columns line up
		var totalContainerWidth = Math.max(this._viewPort.width + this._headerContainerLayout.paddingLeft + this._headerContainerLayout.paddingRight,
			minContainerWidth);
		var availableWidth = totalContainerWidth - this._headerContainerLayout.paddingLeft - this._headerContainerLayout.paddingRight;
		var totalWidth = 0.0;
		var indices:Array<Int> = [];
		for (i in 0...this._customColumnWidths.length) {
			if (i == columnIndex) {
				continue;
			}
			var column = this._columns.get(i);
			if (column.width != null) {
				// if the width is set explicitly, skip it!
				availableWidth -= column.width;
				continue;
			}
			var size = this._customColumnWidths[i];
			totalWidth += size;
			indices.push(i);
		}

		var idealColumnWidth = totalWidth / (indices.length + 1);
		this._customColumnWidths[columnIndex] = idealColumnWidth;

		// make a copy so that this is detected as a change
		this._customColumnWidths = this._customColumnWidths.copy();

		var widthToDistribute = -idealColumnWidth;
		this.distributeWidthToIndices(widthToDistribute, indices, totalWidth);
		this.setInvalid(LAYOUT);
	}

	private function gridView_columns_removeItemHandler(event:FlatCollectionEvent):Void {
		if (this._customColumnWidths == null) {
			return;
		}
		var column = cast(event.removedItem, GridViewColumn);
		var columnIndex = event.index;
		if (column.width != null || columnIndex > this._customColumnWidths.length) {
			return;
		}
		this._customColumnWidths.splice(columnIndex, 1);
		this.setInvalid(LAYOUT);
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
		var state = this.headerRendererToHeaderState.get(headerRenderer);
		this.updateSortedColumn(state.column);
		GridViewEvent.dispatchForHeader(this, GridViewEvent.HEADER_TRIGGER, state);
	}

	private function gridView_headerRenderer_clickHandler(event:MouseEvent):Void {
		if (!this._enabled) {
			return;
		}

		var headerRenderer = cast(event.currentTarget, DisplayObject);
		var state = this.headerRendererToHeaderState.get(headerRenderer);
		this.updateSortedColumn(state.column);
		GridViewEvent.dispatchForHeader(this, GridViewEvent.HEADER_TRIGGER, state);
	}

	private function gridView_headerRenderer_triggerHandler(event:TriggerEvent):Void {
		if (!this._enabled) {
			return;
		}

		var headerRenderer = cast(event.currentTarget, DisplayObject);
		var state = this.headerRendererToHeaderState.get(headerRenderer);
		this.updateSortedColumn(state.column);
		GridViewEvent.dispatchForHeader(this, GridViewEvent.HEADER_TRIGGER, state);
	}

	private function gridView_headerDivider_mouseDownHandler(event:MouseEvent):Void {
		var headerDivider = cast(event.currentTarget, InteractiveObject);
		this.headerResizeTouchBegin(ExclusivePointer.POINTER_ID_MOUSE, headerDivider, headerDivider.stage.mouseX);
	}

	private function gridView_headerDivider_stage_mouseMoveHandler(event:MouseEvent):Void {
		var stage = cast(event.currentTarget, Stage);
		this.headerResizeTouchMove(ExclusivePointer.POINTER_ID_MOUSE, stage.mouseX);
	}

	private function gridView_headerDivider_stage_mouseUpHandler(event:MouseEvent):Void {
		var stage = cast(event.currentTarget, Stage);
		this.headerResizeTouchEnd(ExclusivePointer.POINTER_ID_MOUSE, stage.mouseX);
	}

	private function gridView_headerDivider_touchBeginHandler(event:TouchEvent):Void {
		if (event.isPrimaryTouchPoint #if air && Multitouch.mapTouchToMouse #end) {
			// ignore the primary one because MouseEvent.MOUSE_DOWN will catch it
			return;
		}

		var headerDivider = cast(event.currentTarget, InteractiveObject);
		this.headerResizeTouchBegin(event.touchPointID, headerDivider, headerDivider.stage.mouseX);
	}

	private function gridView_headerDivider_stage_touchMoveHandler(event:TouchEvent):Void {
		var stage = cast(event.currentTarget, Stage);
		this.headerResizeTouchMove(event.touchPointID, stage.mouseX);
	}

	private function gridView_headerDivider_stage_touchEndHandler(event:TouchEvent):Void {
		var stage = cast(event.currentTarget, Stage);
		this.headerResizeTouchEnd(event.touchPointID, stage.mouseX);
	}

	private function gridView_headerDivider_rollOverHandler(event:MouseEvent):Void {
		if (!this._resizableColumns || this._resizingHeaderIndex != -1 || Mouse.cursor != MouseCursor.AUTO) {
			// already has the resize cursor
			return;
		}
		#if (lime && !flash)
		this._oldHeaderDividerMouseCursor = Mouse.cursor;
		Mouse.cursor = LimeMouseCursor.RESIZE_WE;
		#end
	}

	private function gridView_headerDivider_rollOutHandler(event:MouseEvent):Void {
		if (!this._resizableColumns || this._resizingHeaderIndex != -1 || this._oldHeaderDividerMouseCursor == null) {
			// keep the cursor until mouse up
			return;
		}
		Mouse.cursor = this._oldHeaderDividerMouseCursor;
		this._oldHeaderDividerMouseCursor = null;
	}
}

private class HeaderRendererStorage {
	public function new(?recycler:DisplayObjectRecycler<Dynamic, GridViewHeaderState, DisplayObject>) {
		this.headerRendererRecycler = recycler;
	}

	public var oldHeaderRendererRecycler:DisplayObjectRecycler<Dynamic, GridViewHeaderState, DisplayObject>;
	public var headerRendererRecycler:DisplayObjectRecycler<Dynamic, GridViewHeaderState, DisplayObject>;
	public var activeHeaderRenderers:Array<DisplayObject> = [];
	public var inactiveHeaderRenderers:Array<DisplayObject> = [];
	public var measurements:Measurements;
}

private class HeaderDividerStorage {
	public function new(?factory:DisplayObjectFactory<Dynamic, InteractiveObject>) {
		this.headerDividerFactory = factory;
	}

	public var customHeaderDividerVariant:String;
	public var oldHeaderDividerFactory:DisplayObjectFactory<Dynamic, InteractiveObject>;
	public var headerDividerFactory:DisplayObjectFactory<Dynamic, InteractiveObject>;
	public var activeHeaderDividers:Array<InteractiveObject> = [];
	public var inactiveHeaderDividers:Array<InteractiveObject> = [];
}

private class ColumnDividerStorage {
	public function new(?factory:DisplayObjectFactory<Dynamic, DisplayObject>) {
		this.columnDividerFactory = factory;
	}

	public var customColumnDividerVariant:String;
	public var oldColumnDividerFactory:DisplayObjectFactory<Dynamic, DisplayObject>;
	public var columnDividerFactory:DisplayObjectFactory<Dynamic, DisplayObject>;
	public var activeColumnDividers:Array<InteractiveObject> = [];
	public var inactiveColumnDividers:Array<InteractiveObject> = [];
}

/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.controls.dataRenderers.GridViewRowRenderer;
import feathers.controls.dataRenderers.IGridViewHeaderRenderer;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.controls.dataRenderers.SortOrderHeaderRenderer;
import feathers.controls.supportClasses.AdvancedLayoutViewPort;
import feathers.controls.supportClasses.BaseScrollContainer;
import feathers.core.IDataSelector;
import feathers.core.IFocusContainer;
import feathers.core.IIndexSelector;
import feathers.core.IMeasureObject;
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
import feathers.dragDrop.DragData;
import feathers.dragDrop.DragDropManager;
import feathers.dragDrop.IDragSource;
import feathers.dragDrop.IDropTarget;
import feathers.events.DragDropEvent;
import feathers.events.FeathersEvent;
import feathers.events.FlatCollectionEvent;
import feathers.events.GridViewEvent;
import feathers.events.TriggerEvent;
import feathers.layout.GridViewRowLayout;
import feathers.layout.IDragDropLayout;
import feathers.layout.IKeyboardNavigationLayout;
import feathers.layout.ILayout;
import feathers.layout.ILayoutIndexObject;
import feathers.layout.IScrollLayout;
import feathers.layout.IVirtualLayout;
import feathers.layout.Measurements;
import feathers.skins.IProgrammaticSkin;
import feathers.style.IVariantStyleObject;
import feathers.utils.AbstractDisplayObjectFactory;
import feathers.utils.AbstractDisplayObjectRecycler;
import feathers.utils.DisplayObjectFactory;
import feathers.utils.DisplayObjectRecycler;
import feathers.utils.DisplayUtil;
import feathers.utils.ExclusivePointer;
import feathers.utils.MathUtil;
import haxe.ds.ObjectMap;
import haxe.ds.StringMap;
import openfl.Lib;
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
import openfl.text.TextField;
import openfl.ui.Keyboard;
import openfl.ui.Mouse;
import openfl.ui.MouseCursor;
#if (lime && !flash && !commonjs)
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

	```haxe
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
@defaultXmlProperty("dataProvider")
@:styleContext
class GridView extends BaseScrollContainer implements IIndexSelector implements IDataSelector<Dynamic> implements IFocusContainer implements IDragSource
		implements IDropTarget {
	/**
		A variant used to style the grid view without a border. The variant is
		used by default on mobile.

		The following example uses this variant:

		```haxe
		var gridView = new GridView();
		gridView.variant = GridView.VARIANT_BORDERLESS;
		```

		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final VARIANT_BORDERLESS = "borderless";

	/**
		A variant used to style the grid view with a border. This variant is
		used by default on desktop.

		The following example uses this variant:

		```haxe
		var gridView = new GridView();
		gridView.variant = GridView.VARIANT_BORDER;
		```

		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final VARIANT_BORDER = "border";

	/**
		The variant used to style the cell renderers in a theme.

		To override this default variant, set the
		`GridView.customCellRendererVariant` property.

		@see `GridView.customCellRendererVariant`
		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_CELL_RENDERER = "gridView_cellRenderer";

	/**
		The variant used to style the column header renderers in a theme.

		@see `GridView.customHeaderRendererVariant`
		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_HEADER_RENDERER = "gridView_headerRenderer";

	/**
		The variant used to style the column header dividers in a theme.

		@see `GridView.customHeaderDividerVariant`
		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_HEADER_DIVIDER = "gridView_headerDivider";

	/**
		The variant used to style the column view port dividers in a theme.

		@see `GridView.customColumnDividerVariant`
		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_COLUMN_DIVIDER = "gridView_columnDivider";

	/**
		The default value used for the `dragFormat` property.

		@since 1.3.0
	**/
	public static final DEFAULT_DRAG_FORMAT_ITEMS = "items";

	private static final INVALIDATION_FLAG_ROW_RENDERER_FACTORY = InvalidationFlag.CUSTOM("rowRendererFactory");
	private static final INVALIDATION_FLAG_HEADER_RENDERER_FACTORY = InvalidationFlag.CUSTOM("headerRendererFactory");
	private static final INVALIDATION_FLAG_HEADER_DIVIDER_FACTORY = InvalidationFlag.CUSTOM("headerDividerFactory");
	private static final INVALIDATION_FLAG_COLUMN_DIVIDER_FACTORY = InvalidationFlag.CUSTOM("columnDividerFactory");

	private static final RESET_HEADER_STATE = new GridViewHeaderState();
	private static final RESET_ROW_STATE = new GridViewRowState();

	// A special pointer ID for the mouse.
	private static final POINTER_ID_MOUSE:Int = -1000;

	private static function defaultUpdateHeaderRenderer(headerRenderer:DisplayObject, state:GridViewHeaderState):Void {
		if ((headerRenderer is ITextControl)) {
			var textControl:ITextControl = cast headerRenderer;
			textControl.text = state.text;
		}
	}

	private static function defaultResetHeaderRenderer(headerRenderer:DisplayObject, state:GridViewHeaderState):Void {
		if ((headerRenderer is ITextControl)) {
			var textControl:ITextControl = cast headerRenderer;
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
	public function new(?dataProvider:IFlatCollection<Dynamic>, ?columns:IFlatCollection<GridViewColumn>, ?changeListener:(Event) -> Void) {
		initializeGridViewTheme();

		super();

		if (this._rowRendererFactory == null) {
			this.rowRendererFactory = DisplayObjectFactory.withClass(GridViewRowRenderer);
		}

		this.dataProvider = dataProvider;
		this.columns = columns;

		this.tabEnabled = true;
		this.focusRect = null;

		if (this.viewPort == null) {
			this.gridViewPort = new AdvancedLayoutViewPort();
			this.addChild(this.gridViewPort);
			this.viewPort = this.gridViewPort;
		}

		if (changeListener != null) {
			this.addEventListener(Event.CHANGE, changeListener);
		}
	}

	private var _headerContainer:LayoutGroup;
	private var _headerContainerLayout:GridViewRowLayout;
	private var _headerResizeContainer:Sprite;
	private var _columnDividerContainer:Sprite;
	private var _resizingHeaderIndex:Int = -1;
	private var _resizingHeaderTouchPointID:Null<Int> = null;
	private var _resizingHeaderTouchPointIsMouse:Bool = false;
	private var _resizingHeaderStartStageX:Float;
	private var _customColumnWidths:Array<Float>;

	private var _defaultHeaderStorage:HeaderRendererStorage = new HeaderRendererStorage(DisplayObjectRecycler.withClass(SortOrderHeaderRenderer));
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

	#if (flash && haxe_ver < 4.3) @:getter(tabEnabled) #end
	override private function get_tabEnabled():Bool {
		return (this._selectable || this.maxScrollY != this.minScrollY || this.maxScrollX != this.minScrollX)
			&& this._enabled
			&& this.rawTabEnabled;
	}

	private var _childFocusEnabled:Bool = true;

	/**
		@see `feathers.core.IFocusContainer.childFocusEnabled`
	**/
	public var childFocusEnabled(get, set):Bool;

	private function get_childFocusEnabled():Bool {
		return this._enabled && this._childFocusEnabled;
	}

	private function set_childFocusEnabled(value:Bool):Bool {
		if (this._childFocusEnabled == value) {
			return this._childFocusEnabled;
		}
		this._childFocusEnabled = value;
		return this._childFocusEnabled;
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

		```haxe
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
	@:bindable("dataChange")
	public var dataProvider(get, set):IFlatCollection<Dynamic>;

	private function get_dataProvider():IFlatCollection<Dynamic> {
		return this._dataProvider;
	}

	private function set_dataProvider(value:IFlatCollection<Dynamic>):IFlatCollection<Dynamic> {
		if (this._dataProvider == value) {
			return this._dataProvider;
		}
		#if (hl && haxe_ver < 4.3)
		this._virtualCache.splice(0, this._virtualCache.length);
		#else
		this._virtualCache.resize(0);
		#end
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

		// clear any auto-populated columns so that they can be updated
		if (this._autoPopulatedColumns != null) {
			this._autoPopulatedColumns = null;
			this.columns = null;
		}

		this.setInvalid(DATA);
		FeathersEvent.dispatch(this, "dataChange");
		return this._dataProvider;
	}

	private var _autoPopulatedColumns:IFlatCollection<GridViewColumn> = null;

	private var _columns:IFlatCollection<GridViewColumn> = null;

	/**
		Defines the set of columns to display for each item in the grid view's
		data provider. If `null`, the grid view will attempt to populate the
		columns automatically using
		[reflection](https://haxe.org/manual/std-reflection.html).

		The following example passes in a data provider and tells the columns
		how to interpret the data:

		```haxe
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
		this._autoPopulatedColumns = null;
		this._customColumnWidths = null;
		this.setInvalid(DATA);
		return this._columns;
	}

	/**
		Manages row renderers used by the grid view.

		In the following example, the grid view uses a custom row renderer
		class:

		```haxe
		gridView.rowRendererFactory = DisplayObjectRecycler.withFunction(() -> {
			return new GridViewRowRenderer();
		});
		```

		@since 1.3.0
	**/
	public var rowRendererFactory(get, set):AbstractDisplayObjectFactory<Dynamic, GridViewRowRenderer>;

	private function get_rowRendererFactory():AbstractDisplayObjectFactory<Dynamic, GridViewRowRenderer> {
		return this._rowRendererFactory;
	}

	private function set_rowRendererFactory(value:AbstractDisplayObjectFactory<Dynamic, GridViewRowRenderer>):AbstractDisplayObjectFactory<Dynamic,
		GridViewRowRenderer> {
		if (this._rowRendererFactory == value) {
			return this._rowRendererFactory;
		}
		this._oldRowRendererFactory = this._rowRendererFactory;
		this._rowRendererFactory = value;
		this.setInvalid(INVALIDATION_FLAG_ROW_RENDERER_FACTORY);
		return this._rowRendererFactory;
	}

	/**
		Manages header renderers used by the grid view.

		In the following example, the grid view uses a custom header renderer
		class:

		```haxe
		gridView.headerRendererRecycler = DisplayObjectRecycler.withClass(CustomHeaderRenderer);
		```

		@see `feathers.controls.dataRenderers.SortOrderHeaderRenderer`
		@see `feathers.controls.dataRenderers.LayoutGroupItemRenderer`

		@since 1.0.0
	**/
	public var headerRendererRecycler(get, set):AbstractDisplayObjectRecycler<Dynamic, GridViewHeaderState, DisplayObject>;

	private function get_headerRendererRecycler():AbstractDisplayObjectRecycler<Dynamic, GridViewHeaderState, DisplayObject> {
		return this._defaultHeaderStorage.headerRendererRecycler;
	}

	private function set_headerRendererRecycler(value:AbstractDisplayObjectRecycler<Dynamic, GridViewHeaderState,
		DisplayObject>):AbstractDisplayObjectRecycler<Dynamic, GridViewHeaderState, DisplayObject> {
		if (this._defaultHeaderStorage.headerRendererRecycler == value) {
			return this._defaultHeaderStorage.headerRendererRecycler;
		}
		this._defaultHeaderStorage.oldHeaderRendererRecycler = this._defaultHeaderStorage.headerRendererRecycler;
		this._defaultHeaderStorage.headerRendererRecycler = value;
		this.setInvalid(INVALIDATION_FLAG_HEADER_RENDERER_FACTORY);
		return this._defaultHeaderStorage.headerRendererRecycler;
	}

	private var _forceItemStateUpdate:Bool = false;

	/**
		Forces the `cellRendererRecycler.update()` method to be called with the
		`GridViewCellState` when a row validates, and forces the
		`headerRendererRecycler.update()` method to be called with the
		`GridViewHeaderState` when the grid view validates, even if the cell
		or header's state has not changed since the previous validation.

		Before Feathers UI 1.2, `update()` was called more frequently, and this
		property is provided to enable backwards compatibility, temporarily, to
		assist in migration from earlier versions of Feathers UI.

		In general, when this property needs to be enabled, its often because of
		a missed call to `dataProvider.updateAt()` (preferred) or
		`dataProvider.updateAll()` (less common).

		The `forceItemStateUpdate` property may be removed in a future major
		version, so it is best to avoid relying on it as a long-term solution.

		@since 1.2.0
	**/
	public var forceItemStateUpdate(get, set):Bool;

	private function get_forceItemStateUpdate():Bool {
		return this._forceItemStateUpdate;
	}

	private function set_forceItemStateUpdate(value:Bool):Bool {
		if (this._forceItemStateUpdate == value) {
			return this._forceItemStateUpdate;
		}
		this._forceItemStateUpdate = value;
		this.setInvalid(DATA);
		return this._forceItemStateUpdate;
	}

	/**
		A custom variant to set on all cell renderers, instead of
		`GridView.CHILD_VARIANT_CELL_RENDERER`.

		The `customCellRendererVariant` will be not be used if the result of
		`cellRendererRecycler.create()` already has a variant set.

		@see `GridView.CHILD_VARIANT_CELL_RENDERER`
		@see `feathers.style.IVariantStyleObject.variant`

		@since 1.0.0
	**/
	@:style
	public var customCellRendererVariant:String = null;

	private var _previousCustomHeaderRendererVariant:String = null;

	/**
		A custom variant to set on all header renderers, instead of
		`GridView.CHILD_VARIANT_HEADER_RENDERER`.

		The `customHeaderRendererVariant` will be not be used if the result of
		`headerRendererRecycler.create()` already has a variant set.

		@see `GridView.CHILD_VARIANT_HEADER_RENDERER`
		@see `feathers.style.IVariantStyleObject.variant`

		@since 1.0.0
	**/
	@:style
	public var customHeaderRendererVariant:String = null;

	/**
		Manages the dividers between the grid view's headers.

		In the following example, the grid view uses a custom header divider
		class:

		```haxe
		gridView.headerDividerFactory = DisplayObjectFactory.withClass(CustomHeaderDivider);
		```

		@since 1.0.0
	**/
	@:style
	public var headerDividerFactory:AbstractDisplayObjectFactory<Dynamic, InteractiveObject> = DisplayObjectFactory.withClass(Button);

	/**
		A custom variant to set on all header dividers, instead of
		`GridView.CHILD_VARIANT_HEADER_DIVIDER`.

		The `customHeaderDividerVariant` will be not be used if the result of
		`headerDividerFactory.create()` already has a variant set.

		@see `GridView.CHILD_VARIANT_HEADER_DIVIDER`
		@see `feathers.style.IVariantStyleObject.variant`

		@since 1.0.0
	**/
	@:style
	public var customHeaderDividerVariant:String = null;

	/**
		Manages the dividers between the grid view's columns.

		In the following example, the grid view uses a custom column divider
		class:

		```haxe
		gridView.columnDividerFactory = DisplayObjectFactory.withClass(CustomColumnDivider);
		```

		@since 1.0.0
	**/
	@:style
	public var columnDividerFactory:AbstractDisplayObjectFactory<Dynamic, DisplayObject> = null;

	/**
		A custom variant to set on all column dividers, instead of
		`GridView.CHILD_VARIANT_COLUMN_DIVIDER`.

		The `customColumnDividerVariant` will be not be used if the result of
		`columnDividerFactory.create()` already has a variant set.

		@see `GridView.CHILD_VARIANT_COLUMN_DIVIDER`
		@see `feathers.style.IVariantStyleObject.variant`

		@since 1.0.0
	**/
	@:style
	public var customColumnDividerVariant:String = null;

	private var _rowRendererFactory:DisplayObjectFactory<Dynamic, GridViewRowRenderer>;
	private var _oldRowRendererFactory:DisplayObjectFactory<Dynamic, GridViewRowRenderer>;
	private var _rowRendererMeasurements:Measurements;
	private var _selectedIndex:Int = -1;

	/**
		@see `feathers.core.IIndexSelector.selectedIndex`
	**/
	@:bindable("change")
	@:inspectable(defaultValue = "-1")
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
			#if (hl && haxe_ver < 4.3)
			this._selectedIndices.splice(0, this._selectedIndices.length);
			this._selectedItems.splice(0, this._selectedItems.length);
			#else
			this._selectedIndices.resize(0);
			this._selectedItems.resize(0);
			#end
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
	@:bindable("change")
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
		if (this._selectedItem == value && this._selectedIndex == index && this._selectedIndices.length == 1) {
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

		```haxe
		gridView.allowMultipleSelection = true;
		```

		@see `GridView.selectable`
		@see `GridView.selectedIndices`
		@see `GridView.selectedItems`

		@since 1.0.0
	**/
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
	@:bindable("change")
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
	@:bindable("change")
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

		The following example tells the grid view to use a horizontal layout:

		```haxe
		var layout = new VerticalListLayout();
		layout.requestedRowCount = 5.0;
		layout.gap = 20.0;
		layout.padding = 20.0;
		gridView.layout = layout;
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

		```haxe
		gridView.virtualLayout = false;
		```

		@since 1.0.0
	**/
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

		```haxe
		gridView.cellRendererRecycler = DisplayObjectRecycler.withClass(CustomCellRenderer);
		```

		@see `feathers.controls.GridViewColumn.cellRendererRecycler`
		@see `feathers.controls.dataRenderers.ItemRenderer`
		@see `feathers.controls.dataRenderers.LayoutGroupItemRenderer`

		@since 1.0.0
	**/
	public var cellRendererRecycler(get, set):AbstractDisplayObjectRecycler<Dynamic, GridViewCellState, DisplayObject>;

	private function get_cellRendererRecycler():AbstractDisplayObjectRecycler<Dynamic, GridViewCellState, DisplayObject> {
		return this._cellRendererRecycler;
	}

	private function set_cellRendererRecycler(value:AbstractDisplayObjectRecycler<Dynamic, GridViewCellState,
		DisplayObject>):AbstractDisplayObjectRecycler<Dynamic, GridViewCellState, DisplayObject> {
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

		```haxe
		gridView.sortableColumns = true;
		```

		@see `feathers.controls.GridViewColumn.sortOrder`
		@see `feathers.controls.GridViewColumn.sortCompareFunction`

		@default false

		@since 1.0.0
	**/
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

		```haxe
		gridView.resizableColumns = true;
		```

		@see `GridView.columnResizeSkin`

		@default false

		@since 1.0.0
	**/
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

	private var _currentHeaderCornerSkin:DisplayObject;

	/**
		The skin to display next to the headers when the vertical scroll bar is
		displayed, and `extendedScrollBarY` is `false`.

		@see `GridView.extendedScrollBarY`

		@since 1.3.0
	**/
	@:style
	public var headerCornerSkin:DisplayObject = null;

	private var _sortOrder:SortOrder = NONE;

	/**
		Indicates the sort order of `sortedColumn`, if `sortedColumn` is not
		`null`. Otherwise, returns `SortOrder.NONE`.

		@see `GridView.sortedColumn`.

		@since 1.0.0
	**/
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
	private var stringDataToRowRenderer = new StringMap<GridViewRowRenderer>();
	private var objectDataToRowRenderer = new ObjectMap<Dynamic, GridViewRowRenderer>();
	private var rowRendererToRowState = new ObjectMap<GridViewRowRenderer, GridViewRowState>();
	private var headerStatePool = new ObjectPool(() -> new GridViewHeaderState());
	private var rowStatePool = new ObjectPool(() -> new GridViewRowState());
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

		```haxe
		gridView.selectable = false;
		```

		@default true

		@see `GridView.selectedItem`
		@see `GridView.selectedIndex`

		@since 1.0.0
	**/
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

		@since 1.0.0
	**/
	@:style
	public var showHeaderDividersOnlyWhenResizable:Bool = false;

	private var _ignoreSelectionChange = false;
	private var _ignoreLayoutChanges = false;
	private var _ignoreHeaderLayoutChanges = false;
	private var _pendingScrollRowIndex:Int = -1;
	private var _pendingScrollDuration:Null<Float> = null;

	private var _dragDropIndicatorSkinMeasurements:Measurements;

	/**
		A skin to indicate where an item being dragged will be dropped within
		the layout, relative to the current mouse position. For this skin to be
		displayed, the `enabled` and `dropEnabled` properties must be `true`,
		and the grid view must have accepted the drop in a
		`DragDropEvent.DRAG_ENTER` event listener.

		In the following example, the grid view's index drag drop indicator skin is
		provided:

		```haxe
		gridView.dragDropIndicatorSkin = new Bitmap(bitmapData);
		```
		@since 1.3.0

		@see `GridView.dropEnabled`
	**/
	@:style
	public var dragDropIndicatorSkin:DisplayObject = null;

	private var _dragFormat:String = DEFAULT_DRAG_FORMAT_ITEMS;

	/**
		Drag and drop is restricted between components, unless they specify the
		same `dragFormat`.

		In the following example, the drag format of two grid views is customized:

		```haxe
		gridView1.dragFormat = "my-custom-format";
		gridView2.dragFormat = "my-custom-format";
		```

		@since 1.3.0

		@see `GridView.dragEnabled`
		@see `GridView.dropEnabled`
	**/
	public var dragFormat(get, set):String;

	private function get_dragFormat():String {
		return this._dragFormat;
	}

	private function set_dragFormat(value:String):String {
		if (value == null) {
			value = DEFAULT_DRAG_FORMAT_ITEMS;
		}
		if (this._dragFormat == value) {
			return this._dragFormat;
		}
		this._dragFormat = value;
		return this._dragFormat;
	}

	private var _dragEnabled = false;

	/**
		Indicates if this grid view can initiate drag and drop operations with
		mouse or touch. The `dragEnabled` property enables dragging items, but
		dropping items on the same grid view must be enabled separately with the
		`dropEnabled` property. The `removeOnDragDropComplete` indicates if the
		initiating grid view should remove the item from the data provider if it
		was successfully dropped somewhere else.

		In the following example, a grid view's items may be dragged:

		```haxe
		gridView.dragEnabled = true;
		```

		@since 1.3.0

		@see `GridView.dropEnabled`
		@see `GridView.removeOnDragDropComplete`
		@see `GridView.dragFormat`
	**/
	public var dragEnabled(get, set):Bool;

	private function get_dragEnabled():Bool {
		return this._dragEnabled;
	}

	private function set_dragEnabled(value:Bool):Bool {
		if (this._dragEnabled == value) {
			return this._dragEnabled;
		}
		if (this._dragEnabled) {
			this.removeEventListener(DragDropEvent.DRAG_COMPLETE, gridView_dragCompleteHandler);
		}
		this._dragEnabled = value;
		if (this._dragEnabled) {
			this.addEventListener(DragDropEvent.DRAG_COMPLETE, gridView_dragCompleteHandler);
		}
		return this._dragEnabled;
	}

	private var _dropEnabled = false;

	/**
		Indicates if this grid view can accept items that are dragged and
		dropped over the grid view's view port.

		In the following example, items may be dropped on the grid view:

		```haxe
		gridView.dropEnabled = true;
		```

		@since 1.3.0

		@see `GridView.dragEnabled`
		@see `GridView.removeOnDragDropComplete`
		@see `GridView.dragFormat`
	**/
	public var dropEnabled(get, set):Bool;

	private function get_dropEnabled():Bool {
		return this._dropEnabled;
	}

	private function set_dropEnabled(value:Bool):Bool {
		if (this._dropEnabled == value) {
			return this._dropEnabled;
		}
		if (this._dropEnabled) {
			this.removeEventListener(DragDropEvent.DRAG_ENTER, gridView_dragEnterHandler);
			this.removeEventListener(DragDropEvent.DRAG_EXIT, gridView_dragExitHandler);
			this.removeEventListener(DragDropEvent.DRAG_MOVE, gridView_dragMoveHandler);
			this.removeEventListener(DragDropEvent.DRAG_DROP, gridView_dragDropHandler);
		}
		this._dropEnabled = value;
		if (this._dropEnabled) {
			this.addEventListener(DragDropEvent.DRAG_ENTER, gridView_dragEnterHandler);
			this.addEventListener(DragDropEvent.DRAG_EXIT, gridView_dragExitHandler);
			this.addEventListener(DragDropEvent.DRAG_MOVE, gridView_dragMoveHandler);
			this.addEventListener(DragDropEvent.DRAG_DROP, gridView_dragDropHandler);
		}
		return this._dropEnabled;
	}

	private var _removeOnDragDropComplete = false;

	/**
		Indicates whether dragged items should be removed from this grid view's
		data provider, if they are successfully dropped somewhere else.

		@since 1.3.0

		@see `GridView.dragEnabled`
		@see `GridView.dropEnabled`
		@see `GridView.dragFormat`
	**/
	public var removeOnDragDropComplete(get, set):Bool;

	private function get_removeOnDragDropComplete():Bool {
		return this._removeOnDragDropComplete;
	}

	private function set_removeOnDragDropComplete(value:Bool):Bool {
		this._removeOnDragDropComplete = value;
		return this._removeOnDragDropComplete;
	}

	private var _dragDropLocalX = 0.0;
	private var _dragDropLocalY = 0.0;
	private var _dragMinDistance = 0.0;
	private var _dragItem:Dynamic = null;
	private var _dragRowIndex:Int = -1;
	private var _dragRowRenderer:GridViewRowRenderer;
	private var _droppedOnSelf = false;
	private var _dragDropLastUpdateTime = -1;

	/**
		The distance from the edge of the container where it may auto-scroll,
		such as if a drag and drop operation is active.

		@since 1.3.0
	**/
	public var edgeAutoScrollDistance:Float = 8.0;

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
		if (item == null) {
			return null;
		}
		var rowRenderer:GridViewRowRenderer = null;
		if ((item is String)) {
			rowRenderer = this.stringDataToRowRenderer.get(cast item);
		} else {
			rowRenderer = this.objectDataToRowRenderer.get(item);
		}
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

	/**
		Returns a `GridViewCellState` representing a specific item and column.

		@since 1.3.0
	**/
	public function itemAndColumnToCellState(item:Dynamic, column:GridViewColumn):GridViewCellState {
		if (item == null) {
			return null;
		}
		var rowRenderer:GridViewRowRenderer = null;
		if ((item is String)) {
			rowRenderer = this.stringDataToRowRenderer.get(cast item);
		} else {
			rowRenderer = this.objectDataToRowRenderer.get(item);
		}
		if (rowRenderer == null) {
			return null;
		}
		return rowRenderer.columnToCellState(column);
	}

	override public function dispose():Void {
		this.refreshInactiveHeaderRenderers(true);
		this.refreshInactiveRowRenderers(true);
		// manually clear the selection so that removing the data provider
		// doesn't result in Event.CHANGE getting dispatched
		this._selectedItem = null;
		this._selectedIndex = -1;
		this.dataProvider = null;
		this.columns = null;
		super.dispose();
	}

	private function initializeGridViewTheme():Void {
		#if !feathersui_disable_default_theme
		feathers.themes.steel.components.SteelGridViewStyles.initialize();
		#end
	}

	override private function initialize():Void {
		super.initialize();

		if (this._headerContainerLayout == null) {
			this._headerContainerLayout = new GridViewRowLayout();
			// allow the header renderer factory to set the height of headers
			this._headerContainerLayout.heightResetEnabled = false;
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

		if (stylesInvalid) {
			this.refreshHeaderCornerSkin();
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

		if (dataInvalid || layoutInvalid) {
			var oldIgnoreHeaderLayoutChanges = this._ignoreHeaderLayoutChanges;
			this._ignoreHeaderLayoutChanges = true;
			this._headerContainerLayout.customColumnWidths = this._customColumnWidths;
			this._ignoreHeaderLayoutChanges = oldIgnoreHeaderLayoutChanges;
		}

		if (layoutInvalid || stylesInvalid) {
			if (this._previousLayout != this.layout) {
				// don't keep the old layout's cache because it may not be
				// compatible with the new layout
				#if (hl && haxe_ver < 4.3)
				this._virtualCache.splice(0, this._virtualCache.length);
				#else
				this._virtualCache.resize(0);
				#end
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
		if (this._allInvalid) {
			this.gridViewPort.setInvalid();
		}

		super.update();

		this._previousCustomHeaderRendererVariant = this.customHeaderRendererVariant;

		this.validateCustomColumnWidths();
		this.layoutHeaders();
		this.layoutHeaderDividers();
		this.layoutColumnDividers();
		this.handlePendingScroll();
	}

	override private function createScroller():Void {
		super.createScroller();
		this.gridViewPort.scroller = this.scroller;
	}

	override private function refreshScrollerValues():Void {
		super.refreshScrollerValues();
		if ((this.layout is IScrollLayout)) {
			var scrollLayout:IScrollLayout = cast this.layout;
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
			var virtualLayout:IVirtualLayout = cast this.layout;
			var oldIgnoreLayoutChanges = this._ignoreLayoutChanges;
			this._ignoreLayoutChanges = true;
			virtualLayout.scrollX = this.scroller.scrollX;
			virtualLayout.scrollY = this.scroller.scrollY;
			this._ignoreLayoutChanges = oldIgnoreLayoutChanges;
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
		var newColumns:ArrayCollection<GridViewColumn> = null;
		if (this._dataProvider != null && this._dataProvider.length > 0) {
			var item = this._dataProvider.get(0);
			if ((item is String)) {
				newColumns = new ArrayCollection([new GridViewColumn()]);
			} else {
				newColumns = new ArrayCollection(Reflect.fields(item).map((fieldName) -> {
					return new GridViewColumn(fieldName, (item) -> {
						var propertyValue = Reflect.getProperty(item, fieldName);
						return Std.string(propertyValue);
					});
				}));
			}
		} else {
			newColumns = new ArrayCollection();
		}
		// use the setter
		this.runWithInvalidationFlagsOnly(() -> {
			this.columns = newColumns;
		});
		this._autoPopulatedColumns = newColumns;
	}

	private function layoutHeaders():Void {
		if (this._headerContainer == null) {
			return;
		}

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

		if (this._currentHeaderCornerSkin != null) {
			if (this.fixedScrollBars && !this.extendedScrollBarY && this.scrollBarY != null && this.scrollBarY.visible) {
				this._currentHeaderCornerSkin.x = this.scrollBarY.x;
				this._currentHeaderCornerSkin.width = this.scrollBarY.width;
				this._currentHeaderCornerSkin.y = this._headerContainer.y;
				this._currentHeaderCornerSkin.height = this._headerContainer.height;
				this._currentHeaderCornerSkin.visible = true;
			} else {
				this._currentHeaderCornerSkin.visible = false;
			}
		}
	}

	private function layoutHeaderDividers():Void {
		this._headerResizeContainer.x = this._headerContainer.x;
		this._headerResizeContainer.y = this._headerContainer.y;
		for (i in 0...this._headerDividerLayoutItems.length) {
			var headerDivider = this._headerDividerLayoutItems[i];
			headerDivider.visible = !this.showHeaderDividersOnlyWhenResizable || this.resizableColumns;
			if ((headerDivider is IValidating)) {
				(cast headerDivider : IValidating).validateNow();
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
				(cast columnDivider : IValidating).validateNow();
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

	private function refreshHeaderCornerSkin():Void {
		var oldSkin = this._currentHeaderCornerSkin;
		this._currentHeaderCornerSkin = this.getCurrentHeaderCornerSkin();
		if (this._currentHeaderCornerSkin == oldSkin) {
			return;
		}
		this.removeCurrentHeaderCornerSkin(oldSkin);
		this.addCurrentHeaderCornerSkin(this._currentHeaderCornerSkin);
	}

	private function getCurrentHeaderCornerSkin():DisplayObject {
		return this.headerCornerSkin;
	}

	private function addCurrentHeaderCornerSkin(skin:DisplayObject):Void {
		if (skin == null) {
			return;
		}
		if ((skin is IUIControl)) {
			(cast skin : IUIControl).initializeNow();
		}
		if ((skin is IProgrammaticSkin)) {
			(cast skin : IProgrammaticSkin).uiContext = this;
		}
		this.addChild(skin);
	}

	private function removeCurrentHeaderCornerSkin(skin:DisplayObject):Void {
		if (skin == null) {
			return;
		}
		if ((skin is IProgrammaticSkin)) {
			(cast skin : IProgrammaticSkin).uiContext = null;
		}
		if (skin.parent == this) {
			this.removeChild(skin);
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
		if ((this._currentColumnResizeSkin is IUIControl)) {
			(cast this._currentColumnResizeSkin : IUIControl).initializeNow();
		}
		if ((this._currentColumnResizeSkin is IProgrammaticSkin)) {
			(cast this._currentColumnResizeSkin : IProgrammaticSkin).uiContext = this;
		}
		this._currentColumnResizeSkin.visible = false;
		if ((this._currentColumnResizeSkin is InteractiveObject)) {
			(cast this._currentColumnResizeSkin : InteractiveObject).mouseEnabled = false;
		}
		if ((this._currentColumnResizeSkin is DisplayObjectContainer)) {
			(cast this._currentColumnResizeSkin : DisplayObjectContainer).mouseChildren = false;
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
			(cast skin : IProgrammaticSkin).uiContext = null;
		}
		if (skin.parent == this) {
			this.removeChild(skin);
		}
	}

	private function refreshHeaderRenderers():Void {
		var oldIgnoreHeaderLayoutChanges = this._ignoreHeaderLayoutChanges;
		this._ignoreHeaderLayoutChanges = true;
		this._headerContainerLayout.columns = cast this._columns;
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
		#if (hl && haxe_ver < 4.3)
		this._defaultHeaderDividerStorage.inactiveHeaderDividers.splice(0, this._defaultHeaderDividerStorage.inactiveHeaderDividers.length);
		#else
		this._defaultHeaderDividerStorage.inactiveHeaderDividers.resize(0);
		#end
	}

	private function refreshActiveHeaderDividers():Void {
		#if (hl && haxe_ver < 4.3)
		this._headerDividerLayoutItems.splice(0, this._headerDividerLayoutItems.length);
		#else
		this._headerDividerLayoutItems.resize(0);
		#end
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
				var variantHeaderDivider:IVariantStyleObject = cast headerDivider;
				if (variantHeaderDivider.variant == null) {
					var variant = (this.customHeaderDividerVariant != null) ? this.customHeaderDividerVariant : CHILD_VARIANT_HEADER_DIVIDER;
					variantHeaderDivider.variant = variant;
				}
			}
			if ((headerDivider is IUIControl)) {
				(cast headerDivider : IUIControl).initializeNow();
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
		#if (hl && haxe_ver < 4.3)
		this._defaultColumnDividerStorage.inactiveColumnDividers.splice(0, this._defaultColumnDividerStorage.inactiveColumnDividers.length);
		#else
		this._defaultColumnDividerStorage.inactiveColumnDividers.resize(0);
		#end
	}

	private function refreshActiveColumnDividers():Void {
		#if (hl && haxe_ver < 4.3)
		this._columnDividerLayoutItems.splice(0, this._columnDividerLayoutItems.length);
		#else
		this._columnDividerLayoutItems.resize(0);
		#end
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
				var variantColumnDivider:IVariantStyleObject = cast columnDivider;
				if (variantColumnDivider.variant == null) {
					var variant = (this.customColumnDividerVariant != null) ? this.customColumnDividerVariant : CHILD_VARIANT_COLUMN_DIVIDER;
					variantColumnDivider.variant = variant;
				}
			}
			if ((columnDivider is IUIControl)) {
				(cast columnDivider : IUIControl).initializeNow();
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
			headerRenderer.removeEventListener(Event.RESIZE, gridView_headerRenderer_resizeHandler);
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
		#if (hl && haxe_ver < 4.3)
		this._defaultHeaderStorage.inactiveHeaderRenderers.splice(0, this._defaultHeaderStorage.inactiveHeaderRenderers.length);
		#else
		this._defaultHeaderStorage.inactiveHeaderRenderers.resize(0);
		#end
	}

	private function findUnrenderedHeaderData():Void {
		// remove all old items, then fill with null
		#if (hl && haxe_ver < 4.3)
		this._rowLayoutItems.splice(0, this._rowLayoutItems.length);
		#else
		this._rowLayoutItems.resize(0);
		#end
		if (this._columns == null || this._columns.length == 0) {
			return;
		}
		this._rowLayoutItems.resize(this._columns.length);

		for (i in 0...this._columns.length) {
			var column = this._columns.get(i);
			var headerRenderer = this.dataToHeaderRenderer.get(column);
			if (headerRenderer != null) {
				var state = this.headerRendererToHeaderState.get(headerRenderer);
				var changed = this.populateCurrentHeaderState(column, i, state, this._forceItemStateUpdate);
				if (changed) {
					this.updateHeaderRenderer(headerRenderer, state);
				}
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
			this.populateCurrentHeaderState(column, index, state, true);
			var headerRenderer = this.createHeaderRenderer(state);
			headerRenderer.visible = true;
			this._headerContainer.addChildAt(headerRenderer, index);
			this._headerLayoutItems[index] = headerRenderer;
		}
		#if (hl && haxe_ver < 4.3)
		this._unrenderedHeaderData.splice(0, this._unrenderedHeaderData.length);
		#else
		this._unrenderedHeaderData.resize(0);
		#end
	}

	private function refreshRowRenderers(items:Array<DisplayObject>):Void {
		this._rowLayoutItems = items;

		var rowRendererInvalid = this.gridViewPort.isInvalid(INVALIDATION_FLAG_ROW_RENDERER_FACTORY);
		this.refreshInactiveRowRenderers(rowRendererInvalid);
		this.findUnrenderedData();
		this.recoverInactiveRowRenderers();
		this.renderUnrenderedData();
		this.freeInactiveRowRenderers();
		if (this.inactiveRowRenderers.length > 0) {
			throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: inactive row renderers should be empty after updating.');
		}
	}

	private function refreshInactiveRowRenderers(factoryInvalid:Bool):Void {
		var temp = this.inactiveRowRenderers;
		this.inactiveRowRenderers = this.activeRowRenderers;
		this.activeRowRenderers = temp;
		if (this.activeRowRenderers.length > 0) {
			throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: active row renderers should be empty before updating.');
		}
		if (factoryInvalid) {
			this.recoverInactiveRowRenderers();
			this.freeInactiveRowRenderers();
			this._oldRowRendererFactory = null;
		}
	}

	private function recoverInactiveRowRenderers():Void {
		for (rowRenderer in this.inactiveRowRenderers) {
			if (rowRenderer == null) {
				continue;
			}
			var state = this.rowRendererToRowState.get(rowRenderer);
			if (state == null) {
				continue;
			}
			var item = state.data;
			this.rowRendererToRowState.remove(rowRenderer);
			if ((item is String)) {
				this.stringDataToRowRenderer.remove(cast item);
			} else {
				this.objectDataToRowRenderer.remove(item);
			}
			rowRenderer.removeEventListener(GridViewEvent.CELL_TRIGGER, gridView_rowRenderer_cellTriggerHandler);
			rowRenderer.removeEventListener(TriggerEvent.TRIGGER, gridView_rowRenderer_triggerHandler);
			rowRenderer.removeEventListener(MouseEvent.MOUSE_DOWN, gridView_rowRenderer_mouseDownHandler);
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
		#if (hl && haxe_ver < 4.3)
		this.inactiveRowRenderers.splice(0, this.inactiveRowRenderers.length);
		#else
		this.inactiveRowRenderers.resize(0);
		#end
	}

	private function findUnrenderedData():Void {
		// remove all old items, then fill with null
		#if (hl && haxe_ver < 4.3)
		this._rowLayoutItems.splice(0, this._rowLayoutItems.length);
		#else
		this._rowLayoutItems.resize(0);
		#end
		this._visibleIndices.start = 0;
		this._visibleIndices.end = 0;
		if (this._dataProvider == null || this._dataProvider.length == 0) {
			return;
		}
		this._rowLayoutItems.resize(this._dataProvider.length);

		if (this._virtualLayout && (this.layout is IVirtualLayout)) {
			var virtualLayout:IVirtualLayout = cast this.layout;
			var oldIgnoreLayoutChanges = this._ignoreLayoutChanges;
			this._ignoreLayoutChanges = true;
			virtualLayout.scrollX = this.scroller.scrollX;
			virtualLayout.scrollY = this.scroller.scrollY;
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
			var rowRenderer:GridViewRowRenderer = null;
			if ((item is String)) {
				rowRenderer = this.stringDataToRowRenderer.get(cast item);
			} else {
				rowRenderer = this.objectDataToRowRenderer.get(item);
			}
			if (rowRenderer != null) {
				var state = this.rowRendererToRowState.get(rowRenderer);
				var changed = this.populateCurrentRowState(item, i, state, this._forceItemStateUpdate);
				if (changed) {
					this.updateRowRenderer(rowRenderer, state);
				}
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
			this.populateCurrentRowState(item, rowIndex, state, true);
			var rowRenderer = this.createRowRenderer(state);
			rowRenderer.visible = true;
			this.activeRowRenderers.push(rowRenderer);
			this.gridViewPort.addChild(rowRenderer);
			this._rowLayoutItems[rowIndex] = rowRenderer;
		}
		#if (hl && haxe_ver < 4.3)
		this._unrenderedData.splice(0, this._unrenderedData.length);
		#else
		this._unrenderedData.resize(0);
		#end
	}

	private function createRowRenderer(state:GridViewRowState):GridViewRowRenderer {
		var rowRenderer:GridViewRowRenderer = null;
		if (this.inactiveRowRenderers.length == 0) {
			rowRenderer = this._rowRendererFactory.create();
			if (this._rowRendererMeasurements == null) {
				this._rowRendererMeasurements = new Measurements(rowRenderer);
			}
			// for consistency, initialize immediately
			rowRenderer.initializeNow();
		} else {
			rowRenderer = this.inactiveRowRenderers.shift();
		}
		this.updateRowRenderer(rowRenderer, state);
		rowRenderer.gridView = this;
		rowRenderer.addEventListener(GridViewEvent.CELL_TRIGGER, gridView_rowRenderer_cellTriggerHandler);
		rowRenderer.addEventListener(TriggerEvent.TRIGGER, gridView_rowRenderer_triggerHandler);
		rowRenderer.addEventListener(MouseEvent.MOUSE_DOWN, gridView_rowRenderer_mouseDownHandler);
		this.rowRendererToRowState.set(rowRenderer, state);
		var row = state.data;
		if ((row is String)) {
			this.stringDataToRowRenderer.set(cast row, rowRenderer);
		} else {
			this.objectDataToRowRenderer.set(row, rowRenderer);
		}
		return rowRenderer;
	}

	private function destroyRowRenderer(rowRenderer:GridViewRowRenderer):Void {
		var factory = this._oldRowRendererFactory != null ? this._oldRowRendererFactory : this._rowRendererFactory;
		rowRenderer.gridView = null;
		this.gridViewPort.removeChild(rowRenderer);
		if (factory.destroy != null) {
			factory.destroy(rowRenderer);
		}
	}

	private function updateRowRenderer(rowRenderer:GridViewRowRenderer, state:GridViewRowState):Void {
		this.refreshRowRendererProperties(rowRenderer, state);
	}

	private function resetRowRenderer(rowRenderer:GridViewRowRenderer, state:GridViewRowState):Void {
		this.refreshRowRendererProperties(rowRenderer, RESET_ROW_STATE);
	}

	private function populateCurrentRowState(item:Dynamic, rowIndex:Int, state:GridViewRowState, force:Bool):Bool {
		var changed = false;
		if (force || state.owner != this) {
			state.owner = this;
			changed = true;
		}
		if (force || state.data != item) {
			state.data = item;
			changed = true;
		}
		if (force || state.rowIndex != rowIndex) {
			state.rowIndex = rowIndex;
			changed = true;
		}
		var selected = this._selectedIndices.indexOf(rowIndex) != -1;
		if (force || state.selected != selected) {
			state.selected = selected;
			changed = true;
		}
		var enabled = this._enabled;
		if (force || state.enabled != enabled) {
			state.enabled = enabled;
			changed = true;
		}
		var columns = this._columns;
		if (force || state.columns != columns) {
			state.columns = columns;
			changed = true;
		}
		var cellRendererRecycler = this._cellRendererRecycler;
		if (force || state.cellRendererRecycler != cellRendererRecycler) {
			state.cellRendererRecycler = cellRendererRecycler;
			changed = true;
		}
		var customColumnWidths = this._customColumnWidths;
		if (force || state.customColumnWidths != customColumnWidths) {
			state.customColumnWidths = customColumnWidths;
			changed = true;
		}
		var customCellRendererVariant = this.customCellRendererVariant;
		if (force || state.customCellRendererVariant != customCellRendererVariant) {
			state.customCellRendererVariant = customCellRendererVariant;
			changed = true;
		}
		var forceItemStateUpdate = this._forceItemStateUpdate;
		if (force || state.forceItemStateUpdate != forceItemStateUpdate) {
			state.forceItemStateUpdate = forceItemStateUpdate;
			changed = true;
		}
		return changed;
	}

	private function refreshRowRendererProperties(rowRenderer:GridViewRowRenderer, state:GridViewRowState):Void {
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		rowRenderer.data = state.data;
		rowRenderer.rowIndex = state.rowIndex;
		rowRenderer.selected = state.selected;
		rowRenderer.enabled = state.enabled;
		rowRenderer.columns = state.columns;
		rowRenderer.cellRendererRecycler = state.cellRendererRecycler;
		rowRenderer.customColumnWidths = state.customColumnWidths;
		rowRenderer.customCellRendererVariant = state.customCellRendererVariant;
		rowRenderer.forceCellStateUpdate = state.forceItemStateUpdate;
		this._ignoreSelectionChange = oldIgnoreSelectionChange;
	}

	private function createHeaderRenderer(state:GridViewHeaderState):DisplayObject {
		var headerRenderer:DisplayObject = null;
		if (this._defaultHeaderStorage.inactiveHeaderRenderers.length == 0) {
			headerRenderer = this._defaultHeaderStorage.headerRendererRecycler.create();
			if ((headerRenderer is IVariantStyleObject)) {
				var variantHeaderRenderer:IVariantStyleObject = cast headerRenderer;
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
				(cast headerRenderer : IUIControl).initializeNow();
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
		if ((headerRenderer is IMeasureObject)) {
			headerRenderer.addEventListener(Event.RESIZE, gridView_headerRenderer_resizeHandler);
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

	private function populateCurrentHeaderState(column:GridViewColumn, columnIndex:Int, state:GridViewHeaderState, force:Bool):Bool {
		var changed = false;
		if (force || state.owner != this) {
			state.owner = this;
			changed = true;
		}
		if (force || state.column != column) {
			state.column = column;
			changed = true;
		}
		if (force || state.columnIndex != columnIndex) {
			state.columnIndex = columnIndex;
			changed = true;
		}
		var headerText = column.headerText;
		if (force || state.text != headerText) {
			state.text = headerText;
			changed = true;
		}
		var enabled = this._enabled;
		if (force || state.enabled != enabled) {
			state.enabled = enabled;
			changed = true;
		}
		var sortOrder = (column == this._sortedColumn) ? this._sortOrder : SortOrder.NONE;
		if (force || state.sortOrder != sortOrder) {
			state.sortOrder = sortOrder;
			changed = true;
		}
		return changed;
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
			var uiControl:IUIControl = cast headerRenderer;
			uiControl.enabled = state.enabled;
		}
		if ((headerRenderer is IGridViewHeaderRenderer)) {
			var header:IGridViewHeaderRenderer = cast headerRenderer;
			header.column = state.column;
			header.columnIndex = state.columnIndex;
			header.gridViewOwner = state.owner;
		}
		if ((headerRenderer is ISortOrderObserver)) {
			var sortObject:ISortOrderObserver = cast headerRenderer;
			sortObject.sortOrder = state.sortOrder;
		}
		if ((headerRenderer is ILayoutIndexObject)) {
			var layoutObject:ILayoutIndexObject = cast headerRenderer;
			layoutObject.layoutIndex = state.columnIndex;
		}
	}

	private function refreshSelectedIndicesAfterFilterOrSort():Void {
		if (this._selectedIndex == -1) {
			return;
		}
		// the index may have changed, possibly even to -1, if the item was
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
			result = (cast this.layout : IKeyboardNavigationLayout).findNextKeyboardIndex(result, event, false, this._rowLayoutItems, null,
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
		var changed = this._selectedIndex != result;
		if (!changed && result != -1) {
			var rowRenderer:GridViewRowRenderer = null;
			var row = this._dataProvider.get(result);
			if ((row is String)) {
				rowRenderer = this.stringDataToRowRenderer.get(cast row);
			} else {
				rowRenderer = this.objectDataToRowRenderer.get(row);
			}
			if (rowRenderer == null) {
				// if we can't find the item renderer, we need to scroll
				changed = true;
			} else if ((this.layout is IScrollLayout)) {
				var scrollLayout:IScrollLayout = cast this.layout;
				var nearestScrollPosition = scrollLayout.getNearestScrollPositionForIndex(result, this._dataProvider.length, this.viewPort.visibleWidth,
					this.viewPort.visibleHeight);
				if (this.scrollX != nearestScrollPosition.x || this.scrollY != nearestScrollPosition.y) {
					changed = true;
				}
			}
		}
		if (!changed) {
			return;
		}
		event.preventDefault();
		// use the setter
		this.selectedIndex = result;
		if (this._selectedIndex != -1) {
			this.scrollToRowIndex(this._selectedIndex);
		}
		// restore focus to the container so that the wrong cell renderer
		// doesn't respond to keyboard events
		if (this._focusManager != null) {
			this._focusManager.focus = this;
		} else if (this.stage != null) {
			this.stage.focus = this;
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
		if (index != -1) {
			this.scrollToRowIndex(index);
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
			var scrollLayout:IScrollLayout = cast this.layout;
			var result = scrollLayout.getNearestScrollPositionForIndex(rowIndex, this._dataProvider.length, this.viewPort.visibleWidth,
				this.viewPort.visibleHeight);
			targetX = result.x;
			targetY = result.y;
		} else {
			var row = this._dataProvider.get(rowIndex);
			var rowRenderer:GridViewRowRenderer = null;
			if ((row is String)) {
				rowRenderer = this.stringDataToRowRenderer.get(cast row);
			} else {
				rowRenderer = this.objectDataToRowRenderer.get(row);
			}
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
			this.scroller.stop();
			this.scroller.scrollX = targetX;
			this.scroller.scrollY = targetY;
		} else {
			this.scroller.throwTo(targetX, targetY, duration);
		}
	}

	private function refreshDragDropIndexIndicator():Void {
		if (this.dragDropIndicatorSkin == null || !(this.layout is IDragDropLayout)) {
			return;
		}
		if ((this.dragDropIndicatorSkin is IUIControl)) {
			(cast this.dragDropIndicatorSkin : IUIControl).initializeNow();
		}
		if (this._dragDropIndicatorSkinMeasurements == null) {
			this._dragDropIndicatorSkinMeasurements = new Measurements(this.dragDropIndicatorSkin);
		} else {
			this._dragDropIndicatorSkinMeasurements.save(this.dragDropIndicatorSkin);
		}

		// convert to view port coordinates
		var dropX = this.scrollX + this._dragDropLocalX - this.leftViewPortOffset;
		var dropY = this.scrollY + this._dragDropLocalY - this.topViewPortOffset;
		var dropDropLayout:IDragDropLayout = cast this.layout;
		var dragDropIndex = dropDropLayout.getDragDropIndex(this._rowLayoutItems, dropX, dropY, this._viewPort.visibleWidth, this._viewPort.visibleHeight);
		var dragDropRegion = dropDropLayout.getDragDropRegion(this._rowLayoutItems, dragDropIndex, dropX, dropY, this._viewPort.visibleWidth,
			this._viewPort.visibleHeight);
		// convert back to grid view coordinates
		this.dragDropIndicatorSkin.x = dragDropRegion.x - this.scrollX + this.leftViewPortOffset;
		this.dragDropIndicatorSkin.y = dragDropRegion.y - this.scrollY + this.topViewPortOffset;
		if (dragDropRegion.width == 0.0) {
			this.dragDropIndicatorSkin.height = dragDropRegion.height;
		} else {
			this.dragDropIndicatorSkin.width = dragDropRegion.width;
		}
		this.addChild(this.dragDropIndicatorSkin);
	}

	override private function baseScrollContainer_keyDownHandler(event:KeyboardEvent):Void {
		if (!this._selectable) {
			super.baseScrollContainer_keyDownHandler(event);
			return;
		}
		if (!this._enabled || event.isDefaultPrevented()) {
			return;
		}
		if (this.stage != null && (this.stage.focus is TextField)) {
			var textField:TextField = cast this.stage.focus;
			if (textField.type == INPUT) {
				// if an input TextField has focus, don't scroll because the
				// TextField should have precedence, and the TextFeeld won't
				// call preventDefault() on the event.
				return;
			}
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

	private function gridView_rowRenderer_mouseDownHandler(event:MouseEvent):Void {
		if (!this._enabled || !this._dragEnabled || this.stage == null) {
			return;
		}
		var rowRenderer = cast(event.currentTarget, GridViewRowRenderer);
		var state = this.rowRendererToRowState.get(rowRenderer);
		if (state == null) {
			return;
		}
		this._dragRowRenderer = rowRenderer;
		this._dragItem = state.data;
		this._dragRowIndex = state.rowIndex;
		this._dragDropLocalX = this.mouseX;
		this._dragDropLocalY = this.mouseY;
		this._dragMinDistance = 6.0;
		this.stage.addEventListener(MouseEvent.MOUSE_MOVE, gridView_stage_pressAndMove_mouseMoveHandler, false, 0, true);
		this.stage.addEventListener(MouseEvent.MOUSE_UP, gridView_stage_pressAndMove_mouseUpHandler, false, 0, true);
	}

	private function gridView_stage_pressAndMove_mouseMoveHandler(event:MouseEvent):Void {
		var offsetX = this.mouseX - this._dragDropLocalX;
		var offsetY = this.mouseY - this._dragDropLocalY;
		if (offsetX > this._dragMinDistance || offsetY > this._dragMinDistance) {
			var stage = cast(event.currentTarget, Stage);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, gridView_stage_pressAndMove_mouseMoveHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, gridView_stage_pressAndMove_mouseUpHandler);

			var items:Array<Dynamic> = [];
			var draggedIndices = this._allowMultipleSelection ? this._selectedIndices.copy() : [];
			if (draggedIndices.indexOf(this._dragRowIndex) == -1) {
				draggedIndices.push(this._dragRowIndex);
			}
			draggedIndices.sort((a, b) -> {
				if (a < b) {
					return -1;
				}
				if (a > b) {
					return 1;
				}
				return 0;
			});
			for (dragIndex in draggedIndices) {
				items.push(this._dataProvider.get(dragIndex));
			}

			var dragData = new DragData();
			dragData.set(this._dragFormat, items);

			var rowState = this.rowRendererToRowState.get(this._dragRowRenderer);
			var rowRenderer = this._rowRendererFactory.create();
			this.updateRowRenderer(rowRenderer, rowState);
			rowRenderer.width = this._dragRowRenderer.width;
			rowRenderer.height = this._dragRowRenderer.height;

			DragDropManager.startDrag(this, dragData, rowRenderer, -this._dragRowRenderer.mouseX, -this._dragRowRenderer.mouseY);
		}
	}

	private function gridView_stage_pressAndMove_mouseUpHandler(event:MouseEvent):Void {
		var stage = cast(event.currentTarget, Stage);
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, gridView_stage_pressAndMove_mouseMoveHandler);
		stage.removeEventListener(MouseEvent.MOUSE_UP, gridView_stage_pressAndMove_mouseUpHandler);
		this._dragItem = null;
		this._dragRowIndex = -1;
		this._dragRowRenderer = null;
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
			#if (hl && haxe_ver < 4.3)
			this._virtualCache.splice(0, this._virtualCache.length);
			#else
			this._virtualCache.resize(0);
			#end
		}
		// use the setter
		this.selectedIndex = -1;
	}

	private function gridView_dataProvider_resetHandler(event:FlatCollectionEvent):Void {
		if (this._virtualCache != null) {
			#if (hl && haxe_ver < 4.3)
			this._virtualCache.splice(0, this._virtualCache.length);
			#else
			this._virtualCache.resize(0);
			#end
			this._virtualCache.resize(this._dataProvider.length);
		}
		// use the setter
		this.selectedIndex = -1;
	}

	private function gridView_dataProvider_sortChangeHandler(event:FlatCollectionEvent):Void {
		if (this._virtualCache != null) {
			// we don't know exactly which indices have changed, so reset the
			// whole cache.
			#if (hl && haxe_ver < 4.3)
			this._virtualCache.splice(0, this._virtualCache.length);
			#else
			this._virtualCache.resize(0);
			#end
			this._virtualCache.resize(this._dataProvider.length);
		}
		this.refreshSelectedIndicesAfterFilterOrSort();
	}

	private function gridView_dataProvider_filterChangeHandler(event:FlatCollectionEvent):Void {
		if (this._virtualCache != null) {
			// we don't know exactly which indices have changed, so reset the
			// whole cache.
			#if (hl && haxe_ver < 4.3)
			this._virtualCache.splice(0, this._virtualCache.length);
			#else
			this._virtualCache.resize(0);
			#end
			this._virtualCache.resize(this._dataProvider.length);
		}
		this.refreshSelectedIndicesAfterFilterOrSort();
	}

	@:access(feathers.controls.dataRenderers.GridViewRowRenderer)
	private function updateRowRendererForIndex(index:Int):Void {
		if (this._virtualCache != null) {
			this._virtualCache[index] = null;
		}
		var row = this._dataProvider.get(index);
		var rowRenderer:GridViewRowRenderer = null;
		if ((row is String)) {
			rowRenderer = this.stringDataToRowRenderer.get(cast row);
		} else {
			rowRenderer = this.objectDataToRowRenderer.get(row);
		}
		if (rowRenderer == null) {
			// doesn't exist yet, so we need to do a full invalidation
			this.setInvalid(DATA);
			return;
		}
		var state = this.rowRendererToRowState.get(rowRenderer);
		if (state.owner == null) {
			// a previous update is already pending
			return;
		}
		rowRenderer.updateCells();
		this.populateCurrentRowState(row, index, state, true);
		// in order to display the same item with modified properties, this
		// hack tricks the item renderer into thinking that it has been given
		// a different item to render.
		this.resetRowRenderer(rowRenderer, state);
		if (this._rowRendererMeasurements != null) {
			this._rowRendererMeasurements.restore(rowRenderer);
		}
		// ensures that the change is detected when we validate later
		state.owner = null;
		this.setInvalid(DATA);
	}

	private function validateCustomColumnWidths():Void {
		if (this._customColumnWidths == null || this._customColumnWidths.length < this._columns.length) {
			return;
		}

		if (this._customColumnWidths.length > this._columns.length) {
			this._customColumnWidths.resize(this._columns.length);
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
		var headerRenderer = this.dataToHeaderRenderer.get(column);
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
				headerRenderer = this.dataToHeaderRenderer.get(currentColumn);
				this._customColumnWidths[i] = headerRenderer.width;
				totalMinWidth += headerRenderer.width;
			} else {
				if (currentColumn.width != null) {
					totalMinWidth += currentColumn.width;
					continue;
				}
				totalMinWidth += currentColumn.minWidth;
				headerRenderer = this.dataToHeaderRenderer.get(currentColumn);
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
				var column = this._columns.get(index);
				var headerRenderer = this.dataToHeaderRenderer.get(column);
				var columnWidth = headerRenderer.width;
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
		var column = this._columns.get(this._resizingHeaderIndex);
		var headerRenderer = this.dataToHeaderRenderer.get(column);
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

	private function headerResizeTouchBegin(touchPointID:Int, isMouse:Bool, divider:InteractiveObject, stageX:Float):Void {
		if (!this._enabled || !this._resizableColumns || this._resizingHeaderIndex != -1 || this.stage == null) {
			return;
		}

		var exclusivePointer = ExclusivePointer.forStage(this.stage);
		var result = false;
		if (isMouse) {
			result = exclusivePointer.claimMouse(divider);
		} else {
			result = exclusivePointer.claimTouch(touchPointID, divider);
		}
		if (!result) {
			return;
		}

		this._resizingHeaderTouchPointID = touchPointID;
		this._resizingHeaderTouchPointIsMouse = isMouse;
		this._resizingHeaderIndex = this._headerDividerLayoutItems.indexOf(divider);
		this._resizingHeaderStartStageX = stageX;
		this.layoutColumnResizeSkin(0.0);
		if (isMouse) {
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, gridView_headerDivider_stage_mouseMoveHandler, false, 0, true);
			this.stage.addEventListener(MouseEvent.MOUSE_UP, gridView_headerDivider_stage_mouseUpHandler, false, 0, true);
		} else {
			this.stage.addEventListener(TouchEvent.TOUCH_MOVE, gridView_headerDivider_stage_touchMoveHandler, false, 0, true);
			this.stage.addEventListener(TouchEvent.TOUCH_END, gridView_headerDivider_stage_touchEndHandler, false, 0, true);
		}
	}

	private function headerResizeTouchMove(touchPointID:Int, isMouse:Bool, stageX:Float):Void {
		if (this._resizingHeaderTouchPointID == null
			|| this._resizingHeaderTouchPointID != touchPointID
			|| this._resizingHeaderTouchPointIsMouse != isMouse) {
			return;
		}

		var offset = stageX - this._resizingHeaderStartStageX;
		offset *= DisplayUtil.getConcatenatedScaleX(this);
		this.layoutColumnResizeSkin(offset);
	}

	private function headerResizeTouchEnd(touchPointID:Int, isMouse:Bool, stageX:Float):Void {
		if (this._resizingHeaderTouchPointID == null
			|| this._resizingHeaderTouchPointID != touchPointID
			|| this._resizingHeaderTouchPointIsMouse != isMouse) {
			return;
		}

		if (isMouse) {
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

		this._resizingHeaderTouchPointID = null;
		this._resizingHeaderTouchPointIsMouse = false;
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

	private function gridView_headerRenderer_resizeHandler(event:Event):Void {
		if (this._validating) {
			return;
		}
		this.setInvalid(LAYOUT);
	}

	private function gridView_headerDivider_mouseDownHandler(event:MouseEvent):Void {
		var headerDivider = cast(event.currentTarget, InteractiveObject);
		this.headerResizeTouchBegin(POINTER_ID_MOUSE, true, headerDivider, headerDivider.stage.mouseX);
	}

	private function gridView_headerDivider_stage_mouseMoveHandler(event:MouseEvent):Void {
		var stage = cast(event.currentTarget, Stage);
		this.headerResizeTouchMove(POINTER_ID_MOUSE, true, stage.mouseX);
	}

	private function gridView_headerDivider_stage_mouseUpHandler(event:MouseEvent):Void {
		var stage = cast(event.currentTarget, Stage);
		this.headerResizeTouchEnd(POINTER_ID_MOUSE, true, stage.mouseX);
	}

	private function gridView_headerDivider_touchBeginHandler(event:TouchEvent):Void {
		if (event.isPrimaryTouchPoint #if air && Multitouch.mapTouchToMouse #end) {
			// ignore the primary one because MouseEvent.MOUSE_DOWN will catch it
			return;
		}

		var headerDivider = cast(event.currentTarget, InteractiveObject);
		this.headerResizeTouchBegin(event.touchPointID, false, headerDivider, headerDivider.stage.mouseX);
	}

	private function gridView_headerDivider_stage_touchMoveHandler(event:TouchEvent):Void {
		var stage = cast(event.currentTarget, Stage);
		this.headerResizeTouchMove(event.touchPointID, false, stage.mouseX);
	}

	private function gridView_headerDivider_stage_touchEndHandler(event:TouchEvent):Void {
		var stage = cast(event.currentTarget, Stage);
		this.headerResizeTouchEnd(event.touchPointID, false, stage.mouseX);
	}

	private function gridView_headerDivider_rollOverHandler(event:MouseEvent):Void {
		if (!this._resizableColumns || this._resizingHeaderIndex != -1 || Mouse.cursor != MouseCursor.AUTO) {
			// already has the resize cursor
			return;
		}
		#if (lime && !flash && !commonjs)
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

	private function gridView_dragCompleteHandler(event:DragDropEvent):Void {
		if (!event.dropped) {
			return;
		}
		if (this._droppedOnSelf) {
			// already modified the data provider in the dragDrop handler
			this._droppedOnSelf = false;
			return;
		}
		if (!this._removeOnDragDropComplete) {
			return;
		}
		var droppedItems = cast(event.dragData.get(this._dragFormat), Array<Dynamic>);
		for (droppedItem in droppedItems) {
			this._dataProvider.remove(droppedItem);
		}
	}

	private function gridView_dragEnterHandler(event:DragDropEvent):Void {
		if (!this._enabled || !this._dropEnabled || !event.dragData.exists(this._dragFormat)) {
			return;
		}
		event.acceptDrag(this);
		this.showFocus(true);
		this._dragDropLocalX = event.localX;
		this._dragDropLocalY = event.localY;
		this.refreshDragDropIndexIndicator();
		this._dragDropLastUpdateTime = Lib.getTimer();
		this.addEventListener(Event.ENTER_FRAME, gridView_dragScroll_enterFrameHandler);
	}

	private function gridView_dragExitHandler(event:DragDropEvent):Void {
		if (this.dragDropIndicatorSkin != null) {
			this._dragDropIndicatorSkinMeasurements.restore(this.dragDropIndicatorSkin);
			if (this.dragDropIndicatorSkin.parent == this) {
				this.removeChild(this.dragDropIndicatorSkin);
			}
		}
		this.showFocus(false);
		this._dragDropLastUpdateTime = -1;
		this.removeEventListener(Event.ENTER_FRAME, gridView_dragScroll_enterFrameHandler);
	}

	private function gridView_dragScroll_enterFrameHandler(event:Event):Void {
		var currentTime = Lib.getTimer();
		var passedTime = currentTime - this._dragDropLastUpdateTime;
		this._dragDropLastUpdateTime = currentTime;

		var dragX = this._dragDropLocalX - this.leftViewPortOffset;
		var dragY = this._dragDropLocalY - this.topViewPortOffset;
		var velocity = passedTime / 2.0;
		if (this.maxScrollY > this.minScrollY) {
			if (this.scrollY < this.maxScrollY && dragY > (this._viewPort.visibleHeight - this.edgeAutoScrollDistance)) {
				velocity *= (1.0 - ((this._viewPort.visibleHeight - dragY) / this.edgeAutoScrollDistance));
			} else if (this.scrollY > this.minScrollY && dragY < this.edgeAutoScrollDistance) {
				velocity *= -(1.0 - (dragY / this.edgeAutoScrollDistance));
			} else {
				velocity = 0.0;
			}
			if (velocity != 0.0) {
				var newScrollY = this.scrollY + velocity;
				if (newScrollY > this.maxScrollY) {
					newScrollY = this.maxScrollY;
				} else if (newScrollY < this.minScrollY) {
					newScrollY = this.minScrollY;
				}
				this.scrollY = newScrollY;
			}
		}
		if (this.maxScrollX > this.minScrollX) {
			if (this.scrollX < this.maxScrollX && dragX > (this._viewPort.visibleWidth - this.edgeAutoScrollDistance)) {
				velocity *= (1.0 - ((this._viewPort.visibleWidth - dragX) / this.edgeAutoScrollDistance));
			} else if (this.scrollX > this.minScrollX && dragX < this.edgeAutoScrollDistance) {
				velocity *= -(1.0 - (dragX / this.edgeAutoScrollDistance));
			} else {
				velocity = 0.0;
			}
			if (velocity != 0.0) {
				var newScrollX = this.scrollX + velocity;
				if (newScrollX > this.maxScrollX) {
					newScrollX = this.maxScrollX;
				} else if (newScrollX < this.minScrollX) {
					newScrollX = this.minScrollX;
				}
				this.scrollX = newScrollX;
			}
		}
		this.refreshDragDropIndexIndicator();
	};

	private function gridView_dragMoveHandler(event:DragDropEvent):Void {
		if (!this._enabled || !this._dropEnabled || !event.dragData.exists(this._dragFormat)) {
			return;
		}
		this._dragDropLocalX = event.localX;
		this._dragDropLocalY = event.localY;
		this.refreshDragDropIndexIndicator();
	}

	private function gridView_dragDropHandler(event:DragDropEvent):Void {
		if (this.dragDropIndicatorSkin != null && this.dragDropIndicatorSkin.parent == this) {
			this._dragDropIndicatorSkinMeasurements.restore(this.dragDropIndicatorSkin);
			this.removeChild(this.dragDropIndicatorSkin);
		}
		this.showFocus(false);
		this._dragDropLastUpdateTime = -1;
		this.removeEventListener(Event.ENTER_FRAME, gridView_dragScroll_enterFrameHandler);
		this._droppedOnSelf = false;
		if (!this._enabled || !this._dropEnabled || !event.dragData.exists(this._dragFormat)) {
			return;
		}
		var droppedItems = cast(event.dragData.get(this._dragFormat), Array<Dynamic>);
		var dragDropIndex = this._dataProvider.length;
		if ((this.layout is IDragDropLayout)) {
			var dragDropLayout:IDragDropLayout = cast this.layout;
			var dropX = this.scrollX + event.localX - this.leftViewPortOffset;
			var dropY = this.scrollY + event.localY - this.topViewPortOffset;
			dragDropIndex = dragDropLayout.getDragDropIndex(this._rowLayoutItems, dropX, dropY, this._viewPort.visibleWidth, this._viewPort.visibleHeight);
		}
		var dropOffset = 0;
		if (event.dragSource == this) {
			for (droppedItem in droppedItems) {
				var oldIndex = this._dataProvider.indexOf(droppedItem);
				if (oldIndex < dragDropIndex) {
					dropOffset--;
				}

				// if we wait to remove this item in the dragComplete handler,
				// the wrong index might be removed.
				this._dataProvider.removeAt(oldIndex);
			}
			this._droppedOnSelf = true;
		}
		for (i in 0...droppedItems.length) {
			var droppedItem = droppedItems[i];
			this._dataProvider.addAt(droppedItem, dragDropIndex + dropOffset + i);
		}
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

private class GridViewRowState {
	public function new() {}

	public var owner:GridView;
	public var data:Dynamic;
	public var rowIndex:Int = -1;
	public var selected:Bool = false;
	public var enabled:Bool = true;
	public var columns:IFlatCollection<GridViewColumn>;
	public var cellRendererRecycler:DisplayObjectRecycler<Dynamic, GridViewCellState, DisplayObject>;
	public var customColumnWidths:Array<Float>;
	public var customCellRendererVariant:String;
	public var forceItemStateUpdate:Bool;
}

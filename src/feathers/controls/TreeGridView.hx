/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.controls.dataRenderers.HierarchicalItemRenderer;
import feathers.controls.dataRenderers.ITreeGridViewHeaderRenderer;
import feathers.controls.dataRenderers.SortOrderHeaderRenderer;
import feathers.controls.dataRenderers.TreeGridViewRowRenderer;
import feathers.controls.supportClasses.AdvancedLayoutViewPort;
import feathers.controls.supportClasses.BaseScrollContainer;
import feathers.core.IDataSelector;
import feathers.core.IFocusContainer;
import feathers.core.IMeasureObject;
import feathers.core.ITextControl;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.core.InvalidationFlag;
import feathers.data.ArrayCollection;
import feathers.data.IFlatCollection;
import feathers.data.IHierarchicalCollection;
import feathers.data.TreeGridViewCellState;
import feathers.data.TreeGridViewHeaderState;
import feathers.events.FeathersEvent;
import feathers.events.FlatCollectionEvent;
import feathers.events.HierarchicalCollectionEvent;
import feathers.events.TreeGridViewEvent;
import feathers.events.TriggerEvent;
import feathers.layout.GridViewRowLayout;
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
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.InteractiveObject;
import openfl.display.Sprite;
import openfl.display.Stage;
import openfl.errors.ArgumentError;
import openfl.errors.IllegalOperationError;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
import openfl.geom.Rectangle;
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
	Displays a hierarchical tree of items as a table. Each item is rendered as a
	row, divided into columns for each of the item's fields. Supports scrolling,
	custom cell, resizing columns, and drag and drop re-ordering of columns.

	The following example creates a tree grid view, gives it a data provider,
	tells the columns how to interpret the data, and listens for when the
	selection changes:

	```haxe
	var treeGridView = new TreeGridView();

	treeGridView.dataProvider = new ArrayHierarchicalCollection([
		{ item: "Chicken breast", dept: "Meat", price: "5.90" },
		{ item: "Butter", dept: "Dairy", price: "4.69" },
		{ item: "Broccoli", dept: "Produce", price: "2.99" },
		{ item: "Whole Wheat Bread", dept: "Bakery", price: "2.49" }
	]);
	treeGridView.columns = new ArrayCollection([
		new TreeGridViewColumn("Item", (data) -> data.item),
		new TreeGridViewColumn("Department", (data) -> data.dept),
		new TreeGridViewColumn("Price", (data) -> data.price)
	]);

	treeGridView.addEventListener(Event.CHANGE, (event:Event) -> {
		var treeGridView = cast(event.currentTarget, TreeGridView);
		trace("TreeGridView changed: " + treeGridView.selectedLocation + " " + treeGridView.selectedItem.item);
	});

	this.addChild(treeGridView);
	```

	@event openfl.events.Event.CHANGE Dispatched when either
	`TreeGridView.selectedItem` or `TreeGridView.selectedLocation` changes.

	@event feathers.events.TreeGridViewEvent.CELL_TRIGGER Dispatched when the
	user taps or clicks a cell renderer in the tree grid view. The pointer must
	remain within the bounds of the cell renderer on release, and the tree grid
	view cannot scroll before release, or the gesture will be ignored.

	@event feathers.events.TreeGridViewEvent.HEADER_TRIGGER Dispatched when the
	user taps or clicks a header renderer in the tree grid view. The pointer
	must remain within the bounds of the header renderer on release, and the
	grid view cannot scroll before release, or the gesture will be ignored.

	@event feathers.events.TreeViewEvent.BRANCH_OPEN Dispatched when a branch
	is opened.

	@event feathers.events.TreeViewEvent.BRANCH_CLOSE Dispatched when a branch
	is closed.

	@see [Tutorial: How to use the TreeGridView component](https://feathersui.com/learn/haxe-openfl/tree-grid-view/)

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
@:event(feathers.events.TreeGridViewEvent.CELL_TRIGGER)
@:event(feathers.events.TreeGridViewEvent.HEADER_TRIGGER)
@:event(feathers.events.TreeGridViewEvent.BRANCH_OPEN)
@:event(feathers.events.TreeGridViewEvent.BRANCH_CLOSE)
@:access(feathers.data.TreeGridViewHeaderState)
@defaultXmlProperty("dataProvider")
@:styleContext
class TreeGridView extends BaseScrollContainer implements IDataSelector<Dynamic> implements IFocusContainer {
	/**
		A variant used to style the tree grid view without a border. This
		variant is used by default on mobile.

		The following example uses this variant:

		```haxe
		var treeGridView = new TreeGridView();
		treeGridView.variant = TreeGridView.VARIANT_BORDERLESS;
		```

		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final VARIANT_BORDERLESS = "borderless";

	/**
		A variant used to style the tree grid view with a border. This variant
		is used by default on desktop.

		The following example uses this variant:

		```haxe
		var treeGridView = new TreeGridView();
		treeGridView.variant = TreeGridView.VARIANT_BORDER;
		```

		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final VARIANT_BORDER = "border";

	/**
		The variant used to style the cell renderers in a theme.

		To override this default variant, set the
		`TreeGridView.customCellRendererVariant` property.

		@see `TreeGridView.customCellRendererVariant`
		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_CELL_RENDERER = "treeGridView_cellRenderer";

	/**
		The variant used to style the column header renderers in a theme.

		@see `TreeGridView.customHeaderRendererVariant`
		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_HEADER_RENDERER = "treeGridView_headerRenderer";

	/**
		The variant used to style the column header dividers in a theme.

		@see `TreeGridView.customHeaderDividerVariant`
		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_HEADER_DIVIDER = "treeGridView_headerDivider";

	/**
		The variant used to style the column view port dividers in a theme.

		@see `TreeGridView.customColumnDividerVariant`
		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_COLUMN_DIVIDER = "treeGridView_columnDivider";

	private static final INVALIDATION_FLAG_HEADER_RENDERER_FACTORY = InvalidationFlag.CUSTOM("headerRendererFactory");
	private static final INVALIDATION_FLAG_HEADER_DIVIDER_FACTORY = InvalidationFlag.CUSTOM("headerDividerFactory");
	private static final INVALIDATION_FLAG_COLUMN_DIVIDER_FACTORY = InvalidationFlag.CUSTOM("columnDividerFactory");

	private static final RESET_HEADER_STATE = new TreeGridViewHeaderState();
	private static final RESET_ROW_STATE = new TreeGridViewRowState();

	// A special pointer ID for the mouse.
	private static final POINTER_ID_MOUSE:Int = -1000;

	private static function defaultUpdateHeaderRenderer(headerRenderer:DisplayObject, state:TreeGridViewHeaderState):Void {
		if ((headerRenderer is ITextControl)) {
			var textControl = cast(headerRenderer, ITextControl);
			textControl.text = state.text;
		}
	}

	private static function defaultResetHeaderRenderer(headerRenderer:DisplayObject, state:TreeGridViewHeaderState):Void {
		if ((headerRenderer is ITextControl)) {
			var textControl = cast(headerRenderer, ITextControl);
			textControl.text = null;
		}
	}

	/**
		Creates a new `TreeGridView` object.

		@since 1.0.0
	**/
	public function new(?dataProvider:IHierarchicalCollection<Dynamic>, ?columns:IFlatCollection<TreeGridViewColumn>, ?changeListener:(Event) -> Void) {
		initializeTreeGridViewTheme();

		super();

		this.dataProvider = dataProvider;
		this.columns = columns;

		this.tabEnabled = true;
		this.focusRect = null;

		if (this.viewPort == null) {
			this.treeGridViewPort = new AdvancedLayoutViewPort();
			this.addChild(this.treeGridViewPort);
			this.viewPort = this.treeGridViewPort;
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
	private var _unrenderedHeaderData:Array<TreeGridViewColumn> = [];
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

	private var openBranches:Array<Dynamic> = [];

	private var treeGridViewPort:AdvancedLayoutViewPort;
	private var _dataProvider:IHierarchicalCollection<Dynamic>;

	/**
		The collection of data displayed by the tree grid view.

		Items in the collection must be class instances or anonymous structures.
		Do not add primitive values (such as strings, booleans, or numeric
		values) directly to the collection.

		Additionally, all items in the collection must be unique object
		instances. Do not add the same instance to the collection more than
		once because a runtime exception will be thrown.

		The following example passes in a data provider and tells the columns
		how to interpret the data:

		```haxe
		treeGridView.dataProvider = new ArrayHierarchicalCollection([
			{ item: "Chicken breast", dept: "Meat", price: "5.90" },
			{ item: "Butter", dept: "Dairy", price: "4.69" },
			{ item: "Broccoli", dept: "Produce", price: "2.99" },
			{ item: "Whole Wheat Bread", dept: "Bakery", price: "2.49" }
		]);
		treeGridView.columns = new ArrayCollection([
			new TreeGridViewColumn("Item", (data) -> data.item),
			new TreeGridViewColumn("Department", (data) -> data.dept),
			new TreeGridViewColumn("Price", (data) -> data.price)
		]);
		```

		@default null

		@see `feathers.data.ArrayCollection`

		@since 1.0.0
	**/
	public var dataProvider(get, set):IHierarchicalCollection<Dynamic>;

	private function get_dataProvider():IHierarchicalCollection<Dynamic> {
		return this._dataProvider;
	}

	private function set_dataProvider(value:IHierarchicalCollection<Dynamic>):IHierarchicalCollection<Dynamic> {
		if (this._dataProvider == value) {
			return this._dataProvider;
		}
		#if (hl && haxe_ver < 4.3)
		this._virtualCache.splice(0, this._virtualCache.length);
		#else
		this._virtualCache.resize(0);
		#end
		this._totalRowLayoutCount = 0;
		#if (hl && haxe_ver < 4.3)
		this.openBranches.splice(0, this.openBranches.length);
		#else
		this.openBranches.resize(0);
		#end
		if (this._dataProvider != null) {
			this._dataProvider.removeEventListener(Event.CHANGE, treeGridView_dataProvider_changeHandler);
			this._dataProvider.removeEventListener(HierarchicalCollectionEvent.ADD_ITEM, treeGridView_dataProvider_addItemHandler);
			this._dataProvider.removeEventListener(HierarchicalCollectionEvent.REMOVE_ITEM, treeGridView_dataProvider_removeItemHandler);
			this._dataProvider.removeEventListener(HierarchicalCollectionEvent.REPLACE_ITEM, treeGridView_dataProvider_replaceItemHandler);
			this._dataProvider.removeEventListener(HierarchicalCollectionEvent.REMOVE_ALL, treeGridView_dataProvider_removeAllHandler);
			this._dataProvider.removeEventListener(HierarchicalCollectionEvent.RESET, treeGridView_dataProvider_resetHandler);
			this._dataProvider.removeEventListener(HierarchicalCollectionEvent.FILTER_CHANGE, treeGridView_dataProvider_filterChangeHandler);
			this._dataProvider.removeEventListener(HierarchicalCollectionEvent.SORT_CHANGE, treeGridView_dataProvider_sortChangeHandler);
			this._dataProvider.removeEventListener(HierarchicalCollectionEvent.UPDATE_ITEM, treeGridView_dataProvider_updateItemHandler);
			this._dataProvider.removeEventListener(HierarchicalCollectionEvent.UPDATE_ALL, treeGridView_dataProvider_updateAllHandler);
		}
		this._dataProvider = value;
		if (this._dataProvider != null) {
			this._totalRowLayoutCount = this.calculateTotalLayoutCount([]);
			this._virtualCache.resize(this._totalRowLayoutCount);
			this._dataProvider.addEventListener(Event.CHANGE, treeGridView_dataProvider_changeHandler);
			this._dataProvider.addEventListener(HierarchicalCollectionEvent.ADD_ITEM, treeGridView_dataProvider_addItemHandler);
			this._dataProvider.addEventListener(HierarchicalCollectionEvent.REMOVE_ITEM, treeGridView_dataProvider_removeItemHandler);
			this._dataProvider.addEventListener(HierarchicalCollectionEvent.REPLACE_ITEM, treeGridView_dataProvider_replaceItemHandler);
			this._dataProvider.addEventListener(HierarchicalCollectionEvent.REMOVE_ALL, treeGridView_dataProvider_removeAllHandler);
			this._dataProvider.addEventListener(HierarchicalCollectionEvent.RESET, treeGridView_dataProvider_resetHandler);
			this._dataProvider.addEventListener(HierarchicalCollectionEvent.FILTER_CHANGE, treeGridView_dataProvider_filterChangeHandler);
			this._dataProvider.addEventListener(HierarchicalCollectionEvent.SORT_CHANGE, treeGridView_dataProvider_sortChangeHandler);
			this._dataProvider.addEventListener(HierarchicalCollectionEvent.UPDATE_ITEM, treeGridView_dataProvider_updateItemHandler);
			this._dataProvider.addEventListener(HierarchicalCollectionEvent.UPDATE_ALL, treeGridView_dataProvider_updateAllHandler);
		}

		// reset the scroll position because this is a drastic change and
		// the data is probably completely different
		this.scrollX = 0.0;
		this.scrollY = 0.0;

		// clear the selection for the same reason
		this.selectedLocation = null;

		// clear any auto-populated columns so that they can be updated
		if (this._autoPopulatedColumns != null) {
			this._autoPopulatedColumns = null;
			this.columns = null;
		}

		this.setInvalid(DATA);
		return this._dataProvider;
	}

	private var _autoPopulatedColumns:IFlatCollection<TreeGridViewColumn> = null;

	private var _columns:IFlatCollection<TreeGridViewColumn> = null;

	/**
		Defines the set of columns to display for each item in the tree grid
		view's data provider. If `null`, the tree grid view will attempt to
		populate the columns automatically using
		[reflection](https://haxe.org/manual/std-reflection.html).

		The following example passes in a data provider and tells the columns
		how to interpret the data:

		```haxe
		treeGridView.dataProvider = new ArrayHierarchicalCollection([
			{ item: "Chicken breast", dept: "Meat", price: "5.90" },
			{ item: "Butter", dept: "Dairy", price: "4.69" },
			{ item: "Broccoli", dept: "Produce", price: "2.99" },
			{ item: "Whole Wheat Bread", dept: "Bakery", price: "2.49" }
		]);
		treeGridView.columns = new ArrayCollection([
			new TreeGridViewColumn("Item", (data) -> data.item),
			new TreeGridViewColumn("Department", (data) -> data.dept),
			new TreeGridViewColumn("Price", (data) -> data.price)
		]);
		```

		@default null

		@see `TreeGridView.dataProvider`
		@see `feathers.controls.TreeGridViewColumn`

		@since 1.0.0
	**/
	public var columns(get, set):IFlatCollection<TreeGridViewColumn>;

	private function get_columns():IFlatCollection<TreeGridViewColumn> {
		return this._columns;
	}

	private function set_columns(value:IFlatCollection<TreeGridViewColumn>):IFlatCollection<TreeGridViewColumn> {
		if (this._columns == value) {
			return this._columns;
		}
		if (this._columns != null) {
			this._columns.removeEventListener(Event.CHANGE, treeGridView_columns_changeHandler);
			this._columns.removeEventListener(FlatCollectionEvent.ADD_ITEM, treeGridView_columns_addItemHandler);
			this._columns.removeEventListener(FlatCollectionEvent.REMOVE_ITEM, treeGridView_columns_removeItemHandler);
		}
		this._columns = value;
		if (this._columns != null) {
			this._columns.addEventListener(Event.CHANGE, treeGridView_columns_changeHandler);
			this._columns.addEventListener(FlatCollectionEvent.ADD_ITEM, treeGridView_columns_addItemHandler);
			this._columns.addEventListener(FlatCollectionEvent.REMOVE_ITEM, treeGridView_columns_removeItemHandler);
		}
		this._autoPopulatedColumns = null;
		this.setInvalid(DATA);
		return this._columns;
	}

	/**
		Manages header renderers used by the tree grid view.

		In the following example, the tree grid view uses a custom header
		renderer class:

		```haxe
		treeGridView.headerRendererRecycler = DisplayObjectRecycler.withClass(CustomHeaderRenderer);
		```

		@since 1.0.0
	**/
	public var headerRendererRecycler(get, set):AbstractDisplayObjectRecycler<Dynamic, TreeGridViewHeaderState, DisplayObject>;

	private function get_headerRendererRecycler():AbstractDisplayObjectRecycler<Dynamic, TreeGridViewHeaderState, DisplayObject> {
		return this._defaultHeaderStorage.headerRendererRecycler;
	}

	private function set_headerRendererRecycler(value:AbstractDisplayObjectRecycler<Dynamic, TreeGridViewHeaderState,
		DisplayObject>):AbstractDisplayObjectRecycler<Dynamic, TreeGridViewHeaderState, DisplayObject> {
		if (this._defaultHeaderStorage.headerRendererRecycler == value) {
			return this._defaultHeaderStorage.headerRendererRecycler;
		}
		this._defaultHeaderStorage.oldHeaderRendererRecycler = this._defaultHeaderStorage.headerRendererRecycler;
		this._defaultHeaderStorage.headerRendererRecycler = value;
		this.setInvalid(INVALIDATION_FLAG_HEADER_RENDERER_FACTORY);
		return this._defaultHeaderStorage.headerRendererRecycler;
	}

	/**
		A custom variant to set on all cell renderers, instead of
		`TreeGridView.CHILD_VARIANT_CELL_RENDERER`.

		The `customCellRendererVariant` will be not be used if the result of
		`cellRendererRecycler.create()` already has a variant set.

		@see `TreeGridView.CHILD_VARIANT_CELL_RENDERER`
		@see `feathers.style.IVariantStyleObject.variant`

		@since 1.0.0
	**/
	@:style
	public var customCellRendererVariant:String = null;

	private var _previousCustomHeaderRendererVariant:String = null;

	/**
		A custom variant to set on all header renderers, instead of
		`TreeGridView.CHILD_VARIANT_HEADER_RENDERER`.

		The `customHeaderRendererVariant` will be not be used if the result of
		`headerRendererRecycler.create()` already has a variant set.

		@see `TreeGridView.CHILD_VARIANT_HEADER_RENDERER`
		@see `feathers.style.IVariantStyleObject.variant`

		@since 1.0.0
	**/
	@:style
	public var customHeaderRendererVariant:String = null;

	/**
		Manages the dividers between the tree grid view's headers.

		In the following example, the tree grid view uses a custom header
		divider class:

		```haxe
		treeGridView.headerDividerFactory = DisplayObjectFactory.withClass(CustomHeaderDivider);
		```

		@since 1.0.0
	**/
	@:style
	public var headerDividerFactory:AbstractDisplayObjectFactory<Dynamic, InteractiveObject> = DisplayObjectFactory.withClass(Button);

	/**
		A custom variant to set on all header dividers, instead of
		`TreeGridView.CHILD_VARIANT_HEADER_DIVIDER`.

		The `customHeaderDividerVariant` will be not be used if the result of
		`headerDividerFactory.create()` already has a variant set.

		@see `TreeGridView.CHILD_VARIANT_HEADER_DIVIDER`
		@see `feathers.style.IVariantStyleObject.variant`

		@since 1.0.0
	**/
	@:style
	public var customHeaderDividerVariant:String = null;

	/**
		Manages the dividers between the tree grid view's columns.

		In the following example, the tree grid view uses a custom column
		divider class:

		```haxe
		treeGridView.columnDividerFactory = DisplayObjectFactory.withClass(CustomColumnDivider);
		```

		@since 1.0.0
	**/
	@:style
	public var columnDividerFactory:AbstractDisplayObjectFactory<Dynamic, DisplayObject> = null;

	/**
		A custom variant to set on all column dividers, instead of
		`TreeGridView.CHILD_VARIANT_COLUMN_DIVIDER`.

		The `customColumnDividerVariant` will be not be used if the result of
		`columnDividerFactory.create()` already has a variant set.

		@see `TreeGridView.CHILD_VARIANT_COLUMN_DIVIDER`
		@see `feathers.style.IVariantStyleObject.variant`

		@since 1.0.0
	**/
	@:style
	public var customColumnDividerVariant:String = null;

	private var _rowRendererRecycler:DisplayObjectRecycler<Dynamic, Dynamic, DisplayObject> = DisplayObjectRecycler.withClass(TreeGridViewRowRenderer);
	private var _rowRendererMeasurements:Measurements;

	private var _forceItemStateUpdate:Bool = false;

	/**
		Forces the `cellRendererRecycler.update()` method to be called with the
		`TreeGridViewCellState` when a row validates, and forces the
		`headerRendererRecycler.update()` method to be called with the
		`TreeGridViewHeaderState` when the grid view validates, even if the cell
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

	private var _selectedLocation:Array<Int> = null;

	/**
		The currently selected location. Returns `null` if no location is
		selected.

		The following example selects a specific location:

		```haxe
		treeView.selectedLocation = [2, 0];
		```

		The following example clears the currently selected location:

		```haxe
		treeView.selectedLocation = null;
		```

		The following example listens for when the selection changes, and it
		prints the new selected location to the debug console:

		```haxe
		var treeView = new TreeView();
		function changeHandler(event:Event):Void
		{
			var treeView = cast(event.currentTarget, TreeView);
			trace("selection change: " + treeView.selectedLocation);
		}
		treeView.addEventListener(Event.CHANGE, changeHandler);
		```

		@default null

		@since 1.0.0
	**/
	@:bindable("change")
	public var selectedLocation(get, set):Array<Int>;

	private function get_selectedLocation():Array<Int> {
		return this._selectedLocation;
	}

	private function set_selectedLocation(value:Array<Int>):Array<Int> {
		if (!this._selectable || this._dataProvider == null) {
			value = null;
		}
		if (this._selectedLocation == value || this.compareLocations(this._selectedLocation, value) == 0) {
			return this._selectedLocation;
		}
		this._selectedLocation = value;
		// using variable because if we were to call the selectedItem setter,
		// then this change wouldn't be saved properly
		if (this._selectedLocation == null) {
			this._selectedItem = null;
		} else {
			this._selectedItem = this._dataProvider.get(this._selectedLocation);
		}
		this.setInvalid(SELECTION);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._selectedLocation;
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
			this.selectedLocation = null;
			return this._selectedItem;
		}
		var location = this._dataProvider.locationOf(value);
		if (this._selectedItem == value && this.compareLocations(this._selectedLocation, location) == 0) {
			return this._selectedItem;
		}
		this._selectedItem = value;
		this._selectedLocation = location;
		this.setInvalid(SELECTION);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._selectedItem;
	}

	private var _previousLayout:ILayout;

	/**
		The layout algorithm used to position and size the tree grid view's
		items.

		By default, if no layout is provided by the time that the tree grid view
		initializes, a default layout that displays items vertically will be
		created.

		The following example tells the list view to use a horizontal layout:

		```haxe
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
		Indicates if the tree grid view's layout is allowed to virtualize items
		or not.

		The following example disables virtual layouts:

		```haxe
		treeGridView.virtualLayout = false;
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

	private var _cellRendererRecycler:DisplayObjectRecycler<Dynamic, TreeGridViewCellState,
		DisplayObject> = DisplayObjectRecycler.withClass(HierarchicalItemRenderer);

	/**
		Manages cell renderers used by the tree grid view.

		In the following example, the tree grid view uses a custom cell renderer
		class:

		```haxe
		treeGridView.cellRendererRecycler = DisplayObjectRecycler.withClass(CustomCellRenderer);
		```

		@see `feathers.controls.TreeGridViewColumn.cellRendererRecycler`

		@since 1.0.0
	**/
	public var cellRendererRecycler(get, set):AbstractDisplayObjectRecycler<Dynamic, TreeGridViewCellState, DisplayObject>;

	private function get_cellRendererRecycler():AbstractDisplayObjectRecycler<Dynamic, TreeGridViewCellState, DisplayObject> {
		return this._cellRendererRecycler;
	}

	private function set_cellRendererRecycler(value:AbstractDisplayObjectRecycler<Dynamic, TreeGridViewCellState,
		DisplayObject>):AbstractDisplayObjectRecycler<Dynamic, TreeGridViewCellState, DisplayObject> {
		if (this._cellRendererRecycler == value) {
			return this._cellRendererRecycler;
		}
		this._cellRendererRecycler = value;
		this.setInvalid(DATA);
		return this._cellRendererRecycler;
	}

	private var _resizableColumns:Bool = false;

	/**
		Determines if the tree grid view's columns may be resized by
		mouse/touch.

		The following example enables column resizing:

		```haxe
		treeGridView.resizableColumns = true;
		```

		@see `TreeGridView.columnResizeSkin`

		@default false
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

		@see `TreeGridView.resizableColumns`

		@since 1.0.0
	**/
	@:style
	public var columnResizeSkin:DisplayObject = null;

	private var dataToHeaderRenderer = new ObjectMap<TreeGridViewColumn, DisplayObject>();
	private var headerRendererToHeaderState = new ObjectMap<DisplayObject, TreeGridViewHeaderState>();
	private var inactiveRowRenderers:Array<TreeGridViewRowRenderer> = [];
	private var activeRowRenderers:Array<TreeGridViewRowRenderer> = [];
	private var dataToRowRenderer = new ObjectMap<Dynamic, TreeGridViewRowRenderer>();
	private var rowRendererToRowState = new ObjectMap<TreeGridViewRowRenderer, TreeGridViewRowState>();
	private var headerStatePool = new ObjectPool(() -> new TreeGridViewHeaderState());
	private var rowStatePool = new ObjectPool(() -> new TreeGridViewRowState());
	private var _unrenderedLocations:Array<Array<Int>> = [];
	private var _unrenderedLayoutIndices:Array<Int> = [];
	private var _rowLayoutItems:Array<DisplayObject> = [];
	private var _totalRowLayoutCount:Int = 0;
	private var _virtualCache:Array<Dynamic> = [];
	private var _visibleIndices:VirtualLayoutRange = new VirtualLayoutRange(0, 0);
	private var _tempVisibleIndices:VirtualLayoutRange = new VirtualLayoutRange(0, 0);
	private var _selectable:Bool = true;

	/**
		Determines if items in the tree grid view may be selected. By default
		only a single item may be selected at any given time. In other words, if
		item _A_ is already selected, and the user selects item _B_, item _A_
		will be deselected automatically.

		The following example disables selection of items in the tree grid view:

		```haxe
		treeGridView.selectable = false;
		```

		@default true

		@see `TreeGridView.selectedItem`
		@see `TreeGridView.selectedLocation`
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
			this.selectedLocation = null;
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
	private var _ignoreOpenedChange = false;
	private var _ignoreLayoutChanges = false;
	private var _ignoreHeaderLayoutChanges = false;

	private var _currentDisplayIndex:Int;

	private var _pendingScrollLocation:Array<Int> = null;
	private var _pendingScrollDuration:Null<Float> = null;

	/**
		Scrolls the tree view so that the specified item renderer is completely
		visible. If the item renderer is already completely visible, does not
		update the scroll position.

		A custom animation duration may be specified. To update the scroll
		position without animation, pass a value of `0.0` for the duration.

		@since 1.0.0
	**/
	public function scrollToLocation(location:Array<Int>, ?animationDuration:Float):Void {
		if (this._dataProvider == null || this._dataProvider.getLength() == 0) {
			return;
		}
		this._pendingScrollLocation = location;
		this._pendingScrollDuration = animationDuration;
		this.setInvalid(SCROLL);
	}

	/**
		Returns the current cell renderer used to render a specific column from
		an item from the data provider. May return `null` if an item and column
		doesn't currently have a cell renderer.

		**Note:** Most tree grid views use "virtual" layouts, which means that
		only the currently-visible subset of items will have cell renderers. As
		the tree grid view scrolls, the items with cell renderers will change,
		and cell renderers may even be re-used to display different items.

		@since 1.0.0
	**/
	public function itemAndColumnToCellRenderer(item:Dynamic, column:TreeGridViewColumn):DisplayObject {
		if (item == null) {
			return null;
		}
		var rowRenderer = this.dataToRowRenderer.get(item);
		if (rowRenderer == null) {
			return null;
		}
		return rowRenderer.columnToCellRenderer(column);
	}

	/**
		Returns the current header renderer used to render a specific column.

		@see `TreeGridView.columns`

		@since 1.0.0
	**/
	public function columnToHeaderRenderer(column:TreeGridViewColumn):DisplayObject {
		return this.dataToHeaderRenderer.get(column);
	}

	/**
		Returns the current column that is rendered by a specific header
		renderer.

		@see `TreeGridView.columns`

		@since 1.0.0
	**/
	public function headerRendererToColumn(headerRenderer:DisplayObject):TreeGridViewColumn {
		var state = this.headerRendererToHeaderState.get(headerRenderer);
		if (state == null) {
			return null;
		}
		return state.column;
	}

	/**
		Indicates if a branch is currently opened or closed. If the object is
		not a branch, or does not exist in the data provider, returns `false`.

		@since 1.0.0
	**/
	public function isBranchOpen(branch:Dynamic):Bool {
		if (this._dataProvider == null || !this._dataProvider.contains(branch)) {
			return false;
		}
		return this._dataProvider.isBranch(branch) && this.openBranches.indexOf(branch) != -1;
	}

	/**
		Opens or closes a branch.

		@since 1.0.0
	**/
	public function toggleBranch(branch:Dynamic, open:Bool):Void {
		var location = (this._dataProvider != null) ? this._dataProvider.locationOf(branch) : null;
		if (location == null) {
			throw new ArgumentError("Cannot open branch because it is not in the data provider.");
		}
		if (!this._dataProvider.isBranch(branch)) {
			throw new ArgumentError("Cannot open item because it is not a branch.");
		}
		var alreadyOpen = this.openBranches.indexOf(branch) != -1;
		if ((open && alreadyOpen) || (!open && !alreadyOpen)) {
			// nothing to change
			return;
		}
		var layoutIndex = this.locationToDisplayIndex(location, false);
		this.toggleBranchInternal(branch, location, layoutIndex, open);
		this._totalRowLayoutCount = this.calculateTotalLayoutCount([]);
	}

	/**
		Opens or closes all children of a branch recursively.

		@since 1.0.0
	**/
	public function toggleChildrenOf(branch:Dynamic, open:Bool):Void {
		var location = (this._dataProvider != null) ? this._dataProvider.locationOf(branch) : null;
		if (location == null) {
			throw new ArgumentError("Cannot open branch because it is not in the data provider.");
		}
		if (!this._dataProvider.isBranch(branch)) {
			throw new ArgumentError("Cannot open item because it is not a branch.");
		}
		var layoutIndex = this.locationToDisplayIndex(location, false);
		this.toggleChildrenOfInternal(branch, location, layoutIndex, open);
		this._totalRowLayoutCount = this.calculateTotalLayoutCount([]);
	}

	override public function dispose():Void {
		this.refreshInactiveHeaderRenderers(true);
		this.refreshInactiveRowRenderers();
		this.recoverInactiveRowRenderers();
		this.freeInactiveRowRenderers();
		this.dataProvider = null;
		this.columns = null;
		super.dispose();
	}

	private function initializeTreeGridViewTheme():Void {
		#if !feathersui_disable_default_theme
		feathers.themes.steel.components.SteelTreeGridViewStyles.initialize();
		#end
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

		if (stylesInvalid || layoutInvalid) {
			this.refreshColumnResizeSkin();
		}

		if (headerRendererInvalid || stateInvalid || dataInvalid) {
			this.refreshHeaderRenderers();
		}

		if (headerDividerInvalid || stateInvalid || dataInvalid) {
			this.refreshHeaderDividers();
		}

		if (columnDividerInvalid || stateInvalid || dataInvalid) {
			this.refreshColumnDividers();
		}

		if (layoutInvalid) {
			this._headerResizeContainer.mouseEnabled = this._resizableColumns;
			this._headerResizeContainer.mouseChildren = this._resizableColumns;
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
				this._virtualCache.resize(this._totalRowLayoutCount);
			}
			this.treeGridViewPort.layout = this.layout;
			this._previousLayout = this.layout;
		}

		this.treeGridViewPort.refreshChildren = this.refreshRowRenderers;

		for (flag in this._invalidationFlags.keys()) {
			this.treeGridViewPort.setInvalid(flag);
		}
		if (this._allInvalid) {
			this.treeGridViewPort.setInvalid();
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
		this.treeGridViewPort.scroller = this.scroller;
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
		this.scroller.snapPositionsX = this.treeGridViewPort.snapPositionsX;
		this.scroller.snapPositionsY = this.treeGridViewPort.snapPositionsY;
	}

	override private function needsScrollMeasurement():Bool {
		var oldStart = this._visibleIndices.start;
		var oldEnd = this._visibleIndices.end;
		if (this._virtualLayout && (this.layout is IVirtualLayout)) {
			var virtualLayout = cast(this.layout, IVirtualLayout);
			var oldIgnoreLayoutChanges = this._ignoreLayoutChanges;
			this._ignoreLayoutChanges = true;
			virtualLayout.scrollX = this.scroller.scrollX;
			virtualLayout.scrollY = this.scroller.scrollY;
			this._ignoreLayoutChanges = oldIgnoreLayoutChanges;
			virtualLayout.getVisibleIndices(this._rowLayoutItems.length, this.treeGridViewPort.visibleWidth, this.treeGridViewPort.visibleHeight,
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
		var newColumns:ArrayCollection<TreeGridViewColumn> = null;
		if (this._dataProvider != null && this._dataProvider.getLength() > 0) {
			var item = this._dataProvider.get([0]);
			newColumns = new ArrayCollection(Reflect.fields(item)
				.map((fieldName) -> new TreeGridViewColumn(fieldName, (item) -> Std.string(Reflect.getProperty(item, fieldName)))));
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

	private function createHeaderDivider(column:TreeGridViewColumn, columnIndex:Int):InteractiveObject {
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
			headerDivider.addEventListener(MouseEvent.ROLL_OVER, treeGridView_headerDivider_rollOverHandler);
			headerDivider.addEventListener(MouseEvent.ROLL_OUT, treeGridView_headerDivider_rollOutHandler);
			headerDivider.addEventListener(MouseEvent.MOUSE_DOWN, treeGridView_headerDivider_mouseDownHandler);
			headerDivider.addEventListener(TouchEvent.TOUCH_BEGIN, treeGridView_headerDivider_touchBeginHandler);
			this._headerResizeContainer.addChildAt(headerDivider, columnIndex);
		} else {
			headerDivider = this._defaultHeaderDividerStorage.inactiveHeaderDividers.shift();
			this._headerResizeContainer.setChildIndex(headerDivider, columnIndex);
		}
		return headerDivider;
	}

	private function destroyHeaderDivider(headerDivider:InteractiveObject, factory:DisplayObjectFactory<Dynamic, InteractiveObject>):Void {
		headerDivider.removeEventListener(MouseEvent.ROLL_OVER, treeGridView_headerDivider_rollOverHandler);
		headerDivider.removeEventListener(MouseEvent.ROLL_OUT, treeGridView_headerDivider_rollOutHandler);
		headerDivider.removeEventListener(MouseEvent.MOUSE_DOWN, treeGridView_headerDivider_mouseDownHandler);
		headerDivider.removeEventListener(TouchEvent.TOUCH_BEGIN, treeGridView_headerDivider_touchBeginHandler);
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

	private function createColumnDivider(column:TreeGridViewColumn, columnIndex:Int):InteractiveObject {
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
			headerRenderer.removeEventListener(TriggerEvent.TRIGGER, treeGridView_headerRenderer_triggerHandler);
			headerRenderer.removeEventListener(MouseEvent.CLICK, treeGridView_headerRenderer_clickHandler);
			headerRenderer.removeEventListener(TouchEvent.TOUCH_TAP, treeGridView_headerRenderer_touchTapHandler);
			headerRenderer.removeEventListener(Event.RESIZE, treeGridView_headerRenderer_resizeHandler);
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
				continue;
			}
			var item = state.data;
			this.rowRendererToRowState.remove(rowRenderer);
			this.dataToRowRenderer.remove(item);
			rowRenderer.removeEventListener(TreeGridViewEvent.CELL_TRIGGER, treeGridView_rowRenderer_cellTriggerHandler);
			rowRenderer.removeEventListener(TriggerEvent.TRIGGER, treeGridView_rowRenderer_triggerHandler);
			rowRenderer.removeEventListener(Event.OPEN, treeGridView_rowRenderer_openHandler);
			rowRenderer.removeEventListener(Event.CLOSE, treeGridView_rowRenderer_closeHandler);
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
		this._rowLayoutItems.resize(this._totalRowLayoutCount);

		if (this._virtualLayout && (this.layout is IVirtualLayout)) {
			var virtualLayout = cast(this.layout, IVirtualLayout);
			var oldIgnoreLayoutChanges = this._ignoreLayoutChanges;
			this._ignoreLayoutChanges = true;
			virtualLayout.scrollX = this.scroller.scrollX;
			virtualLayout.scrollY = this.scroller.scrollY;
			virtualLayout.virtualCache = this._virtualCache;
			this._ignoreLayoutChanges = oldIgnoreLayoutChanges;
			virtualLayout.getVisibleIndices(this._rowLayoutItems.length, this.treeGridViewPort.visibleWidth, this.treeGridViewPort.visibleHeight,
				this._visibleIndices);
		} else {
			this._visibleIndices.start = 0;
			this._visibleIndices.end = this._rowLayoutItems.length - 1;
		}
		this.findUnrenderedDataForLocation([], 0);
	}

	private function findUnrenderedDataForLocation(location:Array<Int>, layoutIndex:Int):Int {
		if (this._dataProvider == null) {
			return layoutIndex;
		}
		for (i in 0...this._dataProvider.getLength(location)) {
			location.push(i);
			var item = this._dataProvider.get(location);
			if (layoutIndex < this._visibleIndices.start || layoutIndex > this._visibleIndices.end) {
				this._rowLayoutItems[layoutIndex] = null;
			} else {
				this.findRowRenderer(item, location.copy(), layoutIndex);
			}
			layoutIndex++;
			if (layoutIndex > this._visibleIndices.end) {
				// don't bother continuing if we're beyond the visible indices
				break;
			}
			if (this._dataProvider.isBranch(item) && this.openBranches.indexOf(item) != -1) {
				layoutIndex = this.findUnrenderedDataForLocation(location, layoutIndex);
				if (layoutIndex > this._visibleIndices.end) {
					// don't bother continuing if we're beyond the visible indices
					break;
				}
			}
			location.pop();
		}
		return layoutIndex;
	}

	private function findRowRenderer(item:Dynamic, location:Array<Int>, layoutIndex:Int):Void {
		var rowRenderer = this.dataToRowRenderer.get(item);
		if (rowRenderer == null) {
			this._unrenderedLocations.push(location);
			this._unrenderedLayoutIndices.push(layoutIndex);
			return;
		}
		var state = this.rowRendererToRowState.get(rowRenderer);
		var changed = this.populateCurrentRowState(item, location, layoutIndex, state, this._forceItemStateUpdate);
		if (changed) {
			this.updateRowRenderer(rowRenderer, state);
		}
		// if this item renderer used to be the typical layout item, but
		// it isn't anymore, it may have been set invisible
		rowRenderer.visible = true;
		this._rowLayoutItems[layoutIndex] = rowRenderer;
		var removed = this.inactiveRowRenderers.remove(rowRenderer);
		if (!removed) {
			throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: row renderer map contains bad data for item at location ${location}. This may be caused by duplicate items in the data provider, which is not allowed.');
		}
		this.activeRowRenderers.push(rowRenderer);
	}

	private function renderUnrenderedData():Void {
		for (location in this._unrenderedLocations) {
			var layoutIndex = this._unrenderedLayoutIndices.shift();
			var item = this._dataProvider.get(location);
			var state = this.rowStatePool.get();
			this.populateCurrentRowState(item, location, layoutIndex, state, true);
			var rowRenderer = this.createRowRenderer(state);
			rowRenderer.visible = true;
			this.treeGridViewPort.addChild(rowRenderer);
			this._rowLayoutItems[layoutIndex] = rowRenderer;
		}
		#if (hl && haxe_ver < 4.3)
		this._unrenderedLocations.splice(0, this._unrenderedLocations.length);
		#else
		this._unrenderedLocations.resize(0);
		#end
	}

	private function createRowRenderer(state:TreeGridViewRowState):TreeGridViewRowRenderer {
		var rowRenderer:TreeGridViewRowRenderer = null;
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
		rowRenderer.treeGridView = this;
		rowRenderer.addEventListener(TreeGridViewEvent.CELL_TRIGGER, treeGridView_rowRenderer_cellTriggerHandler);
		rowRenderer.addEventListener(TriggerEvent.TRIGGER, treeGridView_rowRenderer_triggerHandler);
		rowRenderer.addEventListener(Event.OPEN, treeGridView_rowRenderer_openHandler);
		rowRenderer.addEventListener(Event.CLOSE, treeGridView_rowRenderer_closeHandler);
		this.rowRendererToRowState.set(rowRenderer, state);
		this.dataToRowRenderer.set(state.data, rowRenderer);
		this.activeRowRenderers.push(rowRenderer);
		return rowRenderer;
	}

	private function destroyRowRenderer(rowRenderer:TreeGridViewRowRenderer):Void {
		rowRenderer.treeGridView = null;
		this.treeGridViewPort.removeChild(rowRenderer);
		if (this._rowRendererRecycler.destroy != null) {
			this._rowRendererRecycler.destroy(rowRenderer);
		}
	}

	private function updateRowRenderer(rowRenderer:TreeGridViewRowRenderer, state:TreeGridViewRowState):Void {
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		var oldIgnoreOpenedChange = this._ignoreOpenedChange;
		this._ignoreOpenedChange = true;
		if (this._rowRendererRecycler.update != null) {
			this._rowRendererRecycler.update(rowRenderer, state);
		}
		this._ignoreOpenedChange = oldIgnoreOpenedChange;
		this._ignoreSelectionChange = oldIgnoreSelectionChange;
		this.refreshRowRendererProperties(rowRenderer, state);
	}

	private function resetRowRenderer(rowRenderer:TreeGridViewRowRenderer, state:TreeGridViewRowState):Void {
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		var oldIgnoreOpenedChange = this._ignoreOpenedChange;
		this._ignoreOpenedChange = true;
		if (this._rowRendererRecycler.reset != null) {
			this._rowRendererRecycler.reset(rowRenderer, state);
		}
		this._ignoreOpenedChange = oldIgnoreOpenedChange;
		this._ignoreSelectionChange = oldIgnoreSelectionChange;
		this.refreshRowRendererProperties(rowRenderer, RESET_ROW_STATE);
	}

	private function populateCurrentRowState(item:Dynamic, location:Array<Int>, layoutIndex:Int, state:TreeGridViewRowState, force:Bool):Bool {
		var changed = false;
		if (force || state.owner != this) {
			state.owner = this;
			changed = true;
		}
		if (force || state.data != item) {
			state.data = item;
			changed = true;
		}
		if (force || (state.rowLocation != location && this.compareLocations(state.rowLocation, location) != 0)) {
			state.rowLocation = location;
			changed = true;
		}
		if (force || state.layoutIndex != layoutIndex) {
			state.layoutIndex = layoutIndex;
			changed = true;
		}
		var branch = this._dataProvider != null && this._dataProvider.isBranch(item);
		if (force || state.branch != branch) {
			state.branch = branch;
			changed = true;
		}
		var opened = state.branch && (this.openBranches.indexOf(item) != -1);
		if (force || state.opened != opened) {
			state.opened = opened;
			changed = true;
		}
		var selected = this.compareLocations(location, this._selectedLocation) == 0;
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

	private function populateCurrentRowCellState(item:Dynamic, location:Array<Int>, column:TreeGridViewColumn, columnIndex:Int, layoutIndex:Int,
			state:TreeGridViewCellState, force:Bool):Bool {
		var changed = false;
		if (force || state.owner != this) {
			state.owner = this;
			changed = true;
		}
		if (force || state.data != item) {
			state.data = item;
			changed = true;
		}
		if (force || (state.rowLocation != location && this.compareLocations(state.rowLocation, location) != 0)) {
			state.rowLocation = location;
			changed = true;
		}
		if (force || state.columnIndex != columnIndex) {
			state.columnIndex = columnIndex;
			changed = true;
		}
		if (force || state.column != column) {
			state.column = column;
			changed = true;
		}
		if (force || state.layoutIndex != layoutIndex) {
			state.layoutIndex = layoutIndex;
			changed = true;
		}
		var branch = this._dataProvider != null && this._dataProvider.isBranch(item);
		if (force || state.branch != branch) {
			state.branch = branch;
			changed = true;
		}
		var opened = state.branch && (this.openBranches.indexOf(item) != -1);
		if (force || state.opened != opened) {
			state.opened = opened;
			changed = true;
		}
		var selected = this.compareLocations(location, this._selectedLocation) == 0;
		if (force || state.selected != selected) {
			state.selected = selected;
			changed = true;
		}
		var enabled = this._enabled;
		if (force || state.enabled != enabled) {
			state.enabled = enabled;
			changed = true;
		}
		var text = (column != null) ? column.itemToText(item) : null;
		if (force || state.text != text) {
			state.text = text;
			changed = true;
		}
		return changed;
	}

	private function refreshRowRendererProperties(rowRenderer:TreeGridViewRowRenderer, state:TreeGridViewRowState):Void {
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		var oldIgnoreOpenedChange = this._ignoreOpenedChange;
		this._ignoreOpenedChange = true;
		rowRenderer.data = state.data;
		rowRenderer.rowLocation = state.rowLocation;
		rowRenderer.layoutIndex = state.layoutIndex;
		rowRenderer.branch = state.branch;
		rowRenderer.opened = state.opened;
		rowRenderer.selected = state.selected;
		rowRenderer.enabled = state.enabled;
		rowRenderer.columns = state.columns;
		rowRenderer.cellRendererRecycler = state.cellRendererRecycler;
		rowRenderer.customCellRendererVariant = state.customCellRendererVariant;
		rowRenderer.customColumnWidths = state.customColumnWidths;
		rowRenderer.forceCellStateUpdate = state.forceItemStateUpdate;
		this._ignoreOpenedChange = oldIgnoreOpenedChange;
		this._ignoreSelectionChange = oldIgnoreSelectionChange;
	}

	private function createHeaderRenderer(state:TreeGridViewHeaderState):DisplayObject {
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
			headerRenderer.addEventListener(TriggerEvent.TRIGGER, treeGridView_headerRenderer_triggerHandler);
		} else {
			// fall back to these events if TriggerEvent.TRIGGER isn't available
			headerRenderer.addEventListener(MouseEvent.CLICK, treeGridView_headerRenderer_clickHandler);
			#if (openfl >= "9.0.0")
			headerRenderer.addEventListener(TouchEvent.TOUCH_TAP, treeGridView_headerRenderer_touchTapHandler);
			#end
		}
		if ((headerRenderer is IMeasureObject)) {
			headerRenderer.addEventListener(Event.RESIZE, treeGridView_headerRenderer_resizeHandler);
		}
		this.headerRendererToHeaderState.set(headerRenderer, state);
		this.dataToHeaderRenderer.set(state.column, headerRenderer);
		this._defaultHeaderStorage.activeHeaderRenderers.push(headerRenderer);
		return headerRenderer;
	}

	private function destroyHeaderRenderer(headerRenderer:DisplayObject,
			recycler:DisplayObjectRecycler<Dynamic, TreeGridViewHeaderState, DisplayObject>):Void {
		this._headerContainer.removeChild(headerRenderer);
		if (recycler != null && recycler.destroy != null) {
			recycler.destroy(headerRenderer);
		}
	}

	private function populateCurrentHeaderState(column:TreeGridViewColumn, columnIndex:Int, state:TreeGridViewHeaderState, force:Bool):Bool {
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
		return changed;
	}

	private function updateHeaderRenderer(headerRenderer:DisplayObject, state:TreeGridViewHeaderState):Void {
		if (this._defaultHeaderStorage.headerRendererRecycler.update != null) {
			this._defaultHeaderStorage.headerRendererRecycler.update(headerRenderer, state);
		}
		this.refreshHeaderRendererProperties(headerRenderer, state);
	}

	private function resetHeaderRenderer(headerRenderer:DisplayObject, state:TreeGridViewHeaderState):Void {
		var recycler = this._defaultHeaderStorage.oldHeaderRendererRecycler != null ? this._defaultHeaderStorage.oldHeaderRendererRecycler : this._defaultHeaderStorage.headerRendererRecycler;
		if (recycler != null && recycler.reset != null) {
			recycler.reset(headerRenderer, state);
		}
		this.refreshHeaderRendererProperties(headerRenderer, RESET_HEADER_STATE);
	}

	private function refreshHeaderRendererProperties(headerRenderer:DisplayObject, state:TreeGridViewHeaderState):Void {
		if ((headerRenderer is IUIControl)) {
			var uiControl = cast(headerRenderer, IUIControl);
			uiControl.enabled = state.enabled;
		}
		if ((headerRenderer is ITreeGridViewHeaderRenderer)) {
			var header = cast(headerRenderer, ITreeGridViewHeaderRenderer);
			header.column = state.column;
			header.columnIndex = state.columnIndex;
			header.treeGridViewOwner = state.owner;
		}
		if ((headerRenderer is ILayoutIndexObject)) {
			var layoutObject = cast(headerRenderer, ILayoutIndexObject);
			layoutObject.layoutIndex = state.columnIndex;
		}
	}

	private function displayIndexToLocation(displayIndex:Int):Array<Int> {
		this._currentDisplayIndex = -1;
		return this.displayIndexToLocationAtBranch(displayIndex, []);
	}

	private function displayIndexToLocationAtBranch(target:Int, locationOfBranch:Array<Int>):Array<Int> {
		for (i in 0...this._dataProvider.getLength(locationOfBranch)) {
			this._currentDisplayIndex++;
			locationOfBranch[locationOfBranch.length] = i;
			if (this._currentDisplayIndex == target) {
				return locationOfBranch;
			}
			var child = this._dataProvider.get(locationOfBranch);
			if (this._dataProvider.isBranch(child)) {
				if (this.openBranches.indexOf(child) != -1) {
					var result = this.displayIndexToLocationAtBranch(target, locationOfBranch);
					if (result != null) {
						return result;
					}
				}
			}
			locationOfBranch.resize(locationOfBranch.length - 1);
		}
		return null;
	}

	private function locationToDisplayIndex(location:Array<Int>, returnNearestIfBranchNotOpen:Bool):Int {
		this._currentDisplayIndex = -1;
		var nearestNotOpenBranch:Array<Int> = null;
		if (returnNearestIfBranchNotOpen) {
			nearestNotOpenBranch = [];
		}
		return this.locationToDisplayIndexAtBranch([], location, nearestNotOpenBranch);
	}

	private function locationToDisplayIndexAtBranch(locationOfBranch:Array<Int>, locationToFind:Array<Int>, nearestNotOpenBranch:Array<Int>):Int {
		if (nearestNotOpenBranch != null) {
			nearestNotOpenBranch.push(locationToFind[locationOfBranch.length]);
		}
		for (i in 0...this._dataProvider.getLength(locationOfBranch)) {
			this._currentDisplayIndex++;
			locationOfBranch[locationOfBranch.length] = i;
			if (this.compareLocations(locationOfBranch, locationToFind) == 0) {
				return this._currentDisplayIndex;
			}
			var child = this._dataProvider.get(locationOfBranch);
			if (this._dataProvider.isBranch(child)) {
				if (this.openBranches.indexOf(child) != -1) {
					var result = this.locationToDisplayIndexAtBranch(locationOfBranch, locationToFind, nearestNotOpenBranch);
					if (result != -1) {
						return result;
					}
				} else if (nearestNotOpenBranch != null && this.compareLocations(nearestNotOpenBranch, locationOfBranch) == 0) {
					// if the location is inside a closed branch
					// return that branch
					return this._currentDisplayIndex;
				}
			}
			locationOfBranch.resize(locationOfBranch.length - 1);
		}
		if (nearestNotOpenBranch != null) {
			nearestNotOpenBranch.pop();
		}
		// location was not found!
		return -1;
	}

	private function navigateWithKeyboard(event:KeyboardEvent):Void {
		if (event.isDefaultPrevented()) {
			return;
		}
		if (this._rowLayoutItems.length == 0) {
			return;
		}
		var startIndex = this.locationToDisplayIndex(this._selectedLocation, false);
		var result = startIndex;
		if ((this.layout is IKeyboardNavigationLayout)) {
			if (event.keyCode != Keyboard.UP && event.keyCode != Keyboard.DOWN && event.keyCode != Keyboard.LEFT && event.keyCode != Keyboard.RIGHT
				&& event.keyCode != Keyboard.PAGE_UP && event.keyCode != Keyboard.PAGE_DOWN && event.keyCode != Keyboard.HOME && event.keyCode != Keyboard.END) {
				return;
			}
			result = cast(this.layout, IKeyboardNavigationLayout).findNextKeyboardIndex(result, event, false, this._rowLayoutItems, null,
				this.treeGridViewPort.visibleWidth, this.treeGridViewPort.visibleHeight);
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
					result = this._rowLayoutItems.length - 1;
				default:
					// not keyboard navigation
					return;
			}
		}
		if (result < 0) {
			result = 0;
		} else if (result >= this._rowLayoutItems.length) {
			result = this._rowLayoutItems.length - 1;
		}
		var changed = result != startIndex;
		var pendingLocation:Array<Int> = null;
		if (!changed && result != -1) {
			pendingLocation = this.displayIndexToLocation(result);
			var itemRenderer = this.dataToRowRenderer.get(this._dataProvider.get(pendingLocation));
			if (itemRenderer == null) {
				// if we can't find the item renderer, we need to scroll
				changed = true;
			}
		}
		if (!changed) {
			return;
		}
		event.preventDefault();
		if (pendingLocation == null) {
			pendingLocation = this.displayIndexToLocation(result);
		}
		// use the setter
		this.selectedLocation = pendingLocation;
		if (this._selectedLocation != null) {
			this.scrollToLocation(this._selectedLocation);
		}
		// restore focus to the container so that the wrong cell renderer
		// doesn't respond to keyboard events
		if (this._focusManager != null) {
			this._focusManager.focus = this;
		} else if (this.stage != null) {
			this.stage.focus = this;
		}
	}

	private function handlePendingScroll():Void {
		if (this._pendingScrollLocation == null) {
			return;
		}
		var location = this._pendingScrollLocation;
		var duration = this._pendingScrollDuration != null ? this._pendingScrollDuration : 0.0;
		this._pendingScrollLocation = null;
		this._pendingScrollDuration = null;

		if (this._dataProvider == null || this._dataProvider.getLength() == 0) {
			return;
		}

		var targetX = this.scrollX;
		var targetY = this.scrollY;
		if ((this.layout is IScrollLayout)) {
			var displayIndex = this.locationToDisplayIndex(location, true);
			var scrollLayout = cast(this.layout, IScrollLayout);
			var result = scrollLayout.getNearestScrollPositionForIndex(displayIndex, this._rowLayoutItems.length, this.viewPort.visibleWidth,
				this.viewPort.visibleHeight);
			targetX = result.x;
			targetY = result.y;
		} else {
			var item = this._dataProvider.get(location);
			var rowRenderer = this.dataToRowRenderer.get(item);
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

	private function toggleBranchInternal(branch:Dynamic, location:Array<Int>, layoutIndex:Int, open:Bool):Int {
		var rowRenderer = this.dataToRowRenderer.get(branch);
		var state:TreeGridViewRowState = null;
		if (rowRenderer != null) {
			state = this.rowRendererToRowState.get(rowRenderer);
		}
		var isTemporary = false;
		if (state == null) {
			// if there is no existing state, use a temporary object
			isTemporary = true;
			state = this.rowStatePool.get();
		}
		state.rowLocation = location;
		state.layoutIndex = layoutIndex;
		var alreadyOpen = this.openBranches.indexOf(branch) != -1;
		if (open && !alreadyOpen) {
			this.openBranches.push(branch);
			this.populateCurrentRowState(branch, location, layoutIndex, state, true);
			layoutIndex = insertChildrenIntoVirtualCache(location, layoutIndex);
			if (rowRenderer != null) {
				this.updateRowRenderer(rowRenderer, state);
			}
			var cellState = new TreeGridViewCellState();
			this.populateCurrentRowCellState(branch, location, null, -1, layoutIndex, cellState, true);
			TreeGridViewEvent.dispatchForCell(this, TreeGridViewEvent.BRANCH_OPEN, cellState);
		} else if (!open && alreadyOpen) {
			this.openBranches.remove(branch);
			this.populateCurrentRowState(branch, location, layoutIndex, state, true);
			removeChildrenFromVirtualCache(location, layoutIndex);
			if (rowRenderer != null) {
				this.updateRowRenderer(rowRenderer, state);
			}
			var cellState = new TreeGridViewCellState();
			this.populateCurrentRowCellState(branch, location, null, -1, layoutIndex, cellState, true);
			TreeGridViewEvent.dispatchForCell(this, TreeGridViewEvent.BRANCH_CLOSE, cellState);
		}
		if (isTemporary) {
			this.rowStatePool.release(state);
		}
		this.setInvalid(DATA);
		return layoutIndex;
	}

	private function toggleChildrenOfInternal(branch:Dynamic, location:Array<Int>, layoutIndex:Int, open:Bool):Void {
		layoutIndex = this.toggleBranchInternal(branch, location, layoutIndex, open);
		var itemCount = this._dataProvider.getLength(location);
		for (i in 0...itemCount) {
			location.push(i);
			var child = this._dataProvider.get(location);
			if (this._dataProvider.isBranch(child)) {
				this.toggleChildrenOfInternal(child, location, layoutIndex, open);
			}
			location.pop();
		}
	}

	private function refreshOpenBranchesFromDataProviderChange(removedItem:Dynamic, addedItem:Dynamic):Void {
		if (removedItem == null) {
			return;
		}
		var i = this.openBranches.length - 1;
		while (i >= 0) {
			var openBranch = this.openBranches[i];
			if (openBranch == removedItem) {
				if (removedItem != addedItem) {
					this.openBranches.splice(i, 1);
				}
				continue;
			}
			var location = this._dataProvider.locationOf(openBranch);
			if (location == null) {
				// remove references to branches that no longer exist
				this.openBranches.splice(i, 1);
			}
			i--;
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

	private function treeGridView_rowRenderer_triggerHandler(event:TriggerEvent):Void {
		if (!this._selectable) {
			return;
		}
		var rowRenderer = cast(event.currentTarget, TreeGridViewRowRenderer);
		var state = this.rowRendererToRowState.get(rowRenderer);
		// use the setter
		this.selectedLocation = state.rowLocation.copy();
	}

	private function treeGridView_rowRenderer_cellTriggerHandler(event:TreeGridViewEvent<TreeGridViewCellState>):Void {
		this.dispatchEvent(event.clone());
	}

	private function treeGridView_rowRenderer_openHandler(event:Event):Void {
		if (this._ignoreOpenedChange) {
			return;
		}
		var rowRenderer = cast(event.currentTarget, TreeGridViewRowRenderer);
		var state = this.rowRendererToRowState.get(rowRenderer);
		this.toggleBranch(state.data, true);
	}

	private function treeGridView_rowRenderer_closeHandler(event:Event):Void {
		if (this._ignoreOpenedChange) {
			return;
		}
		var rowRenderer = cast(event.currentTarget, TreeGridViewRowRenderer);
		var state = this.rowRendererToRowState.get(rowRenderer);
		this.toggleBranch(state.data, false);
	}

	private function treeGridView_dataProvider_changeHandler(event:Event):Void {
		this._totalRowLayoutCount = this.calculateTotalLayoutCount([]);
		if (this._virtualCache != null) {
			#if (hl && haxe_ver < 4.3)
			this._virtualCache.splice(0, this._virtualCache.length);
			#else
			this._virtualCache.resize(0);
			#end
			this._virtualCache.resize(this._totalRowLayoutCount);
		}
		this.setInvalid(DATA);
	}

	private function treeGridView_dataProvider_addItemHandler(event:HierarchicalCollectionEvent):Void {
		if (this._selectedLocation == null) {
			return;
		}
		if (this.compareLocations(this._selectedLocation, event.location) >= 0) {
			// use the setter
			this.selectedLocation = this._dataProvider.locationOf(this._selectedItem);
		}
	}

	private function treeGridView_dataProvider_removeItemHandler(event:HierarchicalCollectionEvent):Void {
		this.refreshOpenBranchesFromDataProviderChange(event.removedItem, event.addedItem);
		if (this._selectedLocation != null) {
			if (this.containsLocation(event.location, this._selectedLocation)) {
				// if the selected location is contained within the removed
				// location, clear the selection because it is no longer valid

				// use the setter
				this.selectedLocation = null;
			} else {
				var comparisonResult = this.compareLocations(this._selectedLocation, event.location);
				if (comparisonResult == 0) {
					// use the setter
					this.selectedLocation = null;
				} else if (comparisonResult > 0) {
					// use the setter
					this.selectedLocation = this._dataProvider.locationOf(this._selectedItem);
				}
			}
		}
	}

	private function treeGridView_dataProvider_replaceItemHandler(event:HierarchicalCollectionEvent):Void {
		this.refreshOpenBranchesFromDataProviderChange(event.removedItem, event.addedItem);
		if (this._selectedLocation != null) {
			if (this.containsLocation(event.location, this._selectedLocation)) {
				// if the selected location is contained within the replaced
				// location, clear the selection because it is no longer valid

				// use the setter
				this.selectedLocation = null;
			} else if (this.compareLocations(this._selectedLocation, event.location) == 0) {
				// unlike when an item is removed, the selected location is kept when
				// an item is replaced
				this._selectedItem = this._dataProvider.get(event.location);
				FeathersEvent.dispatch(this, Event.CHANGE);
			}
		}
	}

	private function treeGridView_dataProvider_removeAllHandler(event:HierarchicalCollectionEvent):Void {
		#if (hl && haxe_ver < 4.3)
		this.openBranches.splice(0, this.openBranches.length);
		#else
		this.openBranches.resize(0);
		#end
		// use the setter
		this.selectedLocation = null;
	}

	private function treeGridView_dataProvider_resetHandler(event:HierarchicalCollectionEvent):Void {
		#if (hl && haxe_ver < 4.3)
		this.openBranches.splice(0, this.openBranches.length);
		#else
		this.openBranches.resize(0);
		#end
		// use the setter
		this.selectedLocation = null;
	}

	private function treeGridView_dataProvider_sortChangeHandler(event:HierarchicalCollectionEvent):Void {
		this.refreshSelectedLocationAfterFilterOrSort();
	}

	private function treeGridView_dataProvider_filterChangeHandler(event:HierarchicalCollectionEvent):Void {
		this.refreshSelectedLocationAfterFilterOrSort();
	}

	@:access(feathers.controls.dataRenderers.TreeGridViewRowRenderer)
	private function updateRowRendererForLocation(location:Array<Int>):Void {
		var layoutIndex = this.locationToDisplayIndex(location, false);
		if (this._virtualCache != null && layoutIndex != -1) {
			this._virtualCache[layoutIndex] = null;
		}
		var item = this._dataProvider.get(location);
		var rowRenderer = this.dataToRowRenderer.get(item);
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
		this.populateCurrentRowState(item, location, layoutIndex, state, true);
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
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, treeGridView_headerDivider_stage_mouseMoveHandler, false, 0, true);
			this.stage.addEventListener(MouseEvent.MOUSE_UP, treeGridView_headerDivider_stage_mouseUpHandler, false, 0, true);
		} else {
			this.stage.addEventListener(TouchEvent.TOUCH_MOVE, treeGridView_headerDivider_stage_touchMoveHandler, false, 0, true);
			this.stage.addEventListener(TouchEvent.TOUCH_END, treeGridView_headerDivider_stage_touchEndHandler, false, 0, true);
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
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, treeGridView_headerDivider_stage_mouseMoveHandler);
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, treeGridView_headerDivider_stage_mouseUpHandler);
		} else {
			this.stage.removeEventListener(TouchEvent.TOUCH_MOVE, treeGridView_headerDivider_stage_touchMoveHandler);
			this.stage.removeEventListener(TouchEvent.TOUCH_END, treeGridView_headerDivider_stage_touchEndHandler);
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

	private function refreshSelectedLocationAfterFilterOrSort():Void {
		if (this._selectedLocation == null) {
			return;
		}
		// the location may have changed, possibly even to null, if the item
		// was filtered out
		this.selectedLocation = this._dataProvider.locationOf(this._selectedItem); // use the setter
	}

	private function calculateTotalLayoutCount(location:Array<Int>):Int {
		if (this._dataProvider == null) {
			return 0;
		}
		var itemCount = this._dataProvider.getLength(location);
		var result = itemCount;
		for (i in 0...itemCount) {
			location.push(i);
			var item = this._dataProvider.get(location);
			if (this._dataProvider.isBranch(item) && this.openBranches.indexOf(item) != -1) {
				result += this.calculateTotalLayoutCount(location);
			}
			location.pop();
		}
		return result;
	}

	private function insertChildrenIntoVirtualCache(location:Array<Int>, layoutIndex:Int):Int {
		var length = this._dataProvider.getLength(location);
		for (i in 0...length) {
			location.push(i);
			layoutIndex++;
			this._virtualCache.insert(layoutIndex, null);
			var item = this._dataProvider.get(location);
			if (this._dataProvider.isBranch(item) && this.openBranches.indexOf(item) != -1) {
				layoutIndex = insertChildrenIntoVirtualCache(location, layoutIndex);
			}
			location.pop();
		}
		return layoutIndex;
	}

	private function removeChildrenFromVirtualCache(location:Array<Int>, layoutIndex:Int):Void {
		var length = this._dataProvider.getLength(location);
		layoutIndex++;
		for (i in 0...length) {
			location.push(i);
			var item = this._dataProvider.get(location);
			if (this._dataProvider.isBranch(item) && this.openBranches.indexOf(item) != -1) {
				removeChildrenFromVirtualCache(location, layoutIndex);
			}
			this._virtualCache.splice(layoutIndex, 1);
			location.pop();
		}
	}

	private function containsLocation(parent:Array<Int>, possibleChild:Array<Int>):Bool {
		if (parent == null || possibleChild == null || parent.length >= possibleChild.length) {
			return false;
		}
		for (i in 0...parent.length) {
			var a = parent[i];
			var b = possibleChild[i];
			if (a != b) {
				return false;
			}
		}
		return true;
	}

	private function compareLocations(location1:Array<Int>, location2:Array<Int>):Int {
		var null1 = location1 == null;
		var null2 = location2 == null;
		if (null1 && null2) {
			return 0;
		} else if (null1) {
			return 1;
		} else if (null2) {
			return -1;
		}
		var length1 = location1.length;
		var length2 = location2.length;
		var min = length1;
		if (length2 < min) {
			min = length2;
		}
		for (i in 0...min) {
			var index1 = location1[i];
			var index2 = location2[i];
			if (index1 < index2) {
				return -1;
			}
			if (index1 > index2) {
				return 1;
			}
		}
		if (length1 < length2) {
			return -1;
		} else if (length1 > length2) {
			return 1;
		}
		return 0;
	}

	private function treeGridView_dataProvider_updateItemHandler(event:HierarchicalCollectionEvent):Void {
		this.updateRowRendererForLocation(event.location);
	}

	private function treeGridView_dataProvider_updateAllHandler(event:HierarchicalCollectionEvent):Void {
		var location:Array<Int> = [];
		for (i in 0...this._dataProvider.getLength()) {
			location[0] = i;
			this.updateRowRendererForLocation(location);
		}
	}

	private function treeGridView_columns_addItemHandler(event:FlatCollectionEvent):Void {
		if (this._customColumnWidths == null) {
			return;
		}
		var column = cast(event.addedItem, TreeGridViewColumn);
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

	private function treeGridView_columns_removeItemHandler(event:FlatCollectionEvent):Void {
		if (this._customColumnWidths == null) {
			return;
		}
		var column = cast(event.removedItem, TreeGridViewColumn);
		var columnIndex = event.index;
		if (column.width != null || columnIndex > this._customColumnWidths.length) {
			return;
		}
		this._customColumnWidths.splice(columnIndex, 1);
		this.setInvalid(LAYOUT);
	}

	private function treeGridView_columns_changeHandler(event:Event):Void {
		this.setInvalid(DATA);
	}

	private function treeGridView_headerRenderer_touchTapHandler(event:TouchEvent):Void {
		if (!this._enabled) {
			return;
		}
		if (event.isPrimaryTouchPoint #if air && Multitouch.mapTouchToMouse #end) {
			// ignore the primary one because MouseEvent.CLICK will catch it
			return;
		}

		var headerRenderer = cast(event.currentTarget, DisplayObject);
		var state = this.headerRendererToHeaderState.get(headerRenderer);
		TreeGridViewEvent.dispatchForHeader(this, TreeGridViewEvent.HEADER_TRIGGER, state);
	}

	private function treeGridView_headerRenderer_clickHandler(event:MouseEvent):Void {
		if (!this._enabled) {
			return;
		}

		var headerRenderer = cast(event.currentTarget, DisplayObject);
		var state = this.headerRendererToHeaderState.get(headerRenderer);
		TreeGridViewEvent.dispatchForHeader(this, TreeGridViewEvent.HEADER_TRIGGER, state);
	}

	private function treeGridView_headerRenderer_triggerHandler(event:TriggerEvent):Void {
		if (!this._enabled) {
			return;
		}

		var headerRenderer = cast(event.currentTarget, DisplayObject);
		var state = this.headerRendererToHeaderState.get(headerRenderer);
		TreeGridViewEvent.dispatchForHeader(this, TreeGridViewEvent.HEADER_TRIGGER, state);
	}

	private function treeGridView_headerRenderer_resizeHandler(event:Event):Void {
		if (this._validating) {
			return;
		}
		this.setInvalid(LAYOUT);
	}

	private function treeGridView_headerDivider_mouseDownHandler(event:MouseEvent):Void {
		var headerDivider = cast(event.currentTarget, InteractiveObject);
		this.headerResizeTouchBegin(POINTER_ID_MOUSE, true, headerDivider, headerDivider.stage.mouseX);
	}

	private function treeGridView_headerDivider_stage_mouseMoveHandler(event:MouseEvent):Void {
		var stage = cast(event.currentTarget, Stage);
		this.headerResizeTouchMove(POINTER_ID_MOUSE, true, stage.mouseX);
	}

	private function treeGridView_headerDivider_stage_mouseUpHandler(event:MouseEvent):Void {
		var stage = cast(event.currentTarget, Stage);
		this.headerResizeTouchEnd(POINTER_ID_MOUSE, true, stage.mouseX);
	}

	private function treeGridView_headerDivider_touchBeginHandler(event:TouchEvent):Void {
		if (event.isPrimaryTouchPoint #if air && Multitouch.mapTouchToMouse #end) {
			// ignore the primary one because MouseEvent.MOUSE_DOWN will catch it
			return;
		}

		var headerDivider = cast(event.currentTarget, InteractiveObject);
		this.headerResizeTouchBegin(event.touchPointID, false, headerDivider, headerDivider.stage.mouseX);
	}

	private function treeGridView_headerDivider_stage_touchMoveHandler(event:TouchEvent):Void {
		var stage = cast(event.currentTarget, Stage);
		this.headerResizeTouchMove(event.touchPointID, false, stage.mouseX);
	}

	private function treeGridView_headerDivider_stage_touchEndHandler(event:TouchEvent):Void {
		var stage = cast(event.currentTarget, Stage);
		this.headerResizeTouchEnd(event.touchPointID, false, stage.mouseX);
	}

	private function treeGridView_headerDivider_rollOverHandler(event:MouseEvent):Void {
		if (!this._resizableColumns || this._resizingHeaderIndex != -1 || Mouse.cursor != MouseCursor.AUTO) {
			// already has the resize cursor
			return;
		}
		#if (lime && !flash && !commonjs)
		this._oldHeaderDividerMouseCursor = Mouse.cursor;
		Mouse.cursor = LimeMouseCursor.RESIZE_WE;
		#end
	}

	private function treeGridView_headerDivider_rollOutHandler(event:MouseEvent):Void {
		if (!this._resizableColumns || this._resizingHeaderIndex != -1 || this._oldHeaderDividerMouseCursor == null) {
			// keep the cursor until mouse up
			return;
		}
		Mouse.cursor = this._oldHeaderDividerMouseCursor;
		this._oldHeaderDividerMouseCursor = null;
	}
}

private class HeaderRendererStorage {
	public function new(?recycler:DisplayObjectRecycler<Dynamic, TreeGridViewHeaderState, DisplayObject>) {
		this.headerRendererRecycler = recycler;
	}

	public var oldHeaderRendererRecycler:DisplayObjectRecycler<Dynamic, TreeGridViewHeaderState, DisplayObject>;
	public var headerRendererRecycler:DisplayObjectRecycler<Dynamic, TreeGridViewHeaderState, DisplayObject>;
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

private class TreeGridViewRowState {
	public function new() {}

	public var owner:TreeGridView;
	public var data:Dynamic;
	public var rowLocation:Array<Int> = null;
	public var layoutIndex:Int = -1;
	public var branch:Bool = false;
	public var opened:Bool = false;
	public var selected:Bool = false;
	public var enabled:Bool = true;
	public var columns:IFlatCollection<TreeGridViewColumn>;
	public var cellRendererRecycler:DisplayObjectRecycler<Dynamic, TreeGridViewCellState, DisplayObject>;
	public var customColumnWidths:Array<Float>;
	public var customCellRendererVariant:String;
	public var forceItemStateUpdate:Bool;
}

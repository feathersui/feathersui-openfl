/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.controls.dataRenderers.IDataRenderer;
import feathers.controls.dataRenderers.IListViewItemRenderer;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.controls.supportClasses.AdvancedLayoutViewPort;
import feathers.controls.supportClasses.BaseScrollContainer;
import feathers.core.IDataSelector;
import feathers.core.IFocusContainer;
import feathers.core.IIndexSelector;
import feathers.core.IMeasureObject;
import feathers.core.ITextControl;
import feathers.core.IUIControl;
import feathers.core.InvalidationFlag;
import feathers.data.IFlatCollection;
import feathers.data.ListViewItemState;
import feathers.dragDrop.DragData;
import feathers.dragDrop.DragDropManager;
import feathers.dragDrop.IDragSource;
import feathers.dragDrop.IDropTarget;
import feathers.events.DragDropEvent;
import feathers.events.FeathersEvent;
import feathers.events.FlatCollectionEvent;
import feathers.events.ListViewEvent;
import feathers.events.TriggerEvent;
import feathers.layout.IDragDropLayout;
import feathers.layout.IKeyboardNavigationLayout;
import feathers.layout.ILayout;
import feathers.layout.ILayoutIndexObject;
import feathers.layout.IScrollLayout;
import feathers.layout.IVirtualLayout;
import feathers.layout.Measurements;
import feathers.style.IVariantStyleObject;
import feathers.utils.AbstractDisplayObjectRecycler;
import feathers.utils.DisplayObjectRecycler;
import haxe.ds.ObjectMap;
import haxe.ds.StringMap;
import openfl.Lib;
import openfl.display.DisplayObject;
import openfl.display.Stage;
import openfl.errors.IllegalOperationError;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
import openfl.text.TextField;
import openfl.ui.Keyboard;
#if air
import openfl.ui.Multitouch;
#end
#if (openfl >= "9.1.0")
import openfl.utils.ObjectPool;
#else
import openfl._internal.utils.ObjectPool;
#end

/**
	Displays a one-dimensional list of items. Supports scrolling, custom item
	renderers, custom layouts, and the ability to drag and drop items to new
	positions within the list view (along with moving items between different
	list views).

	Layouts may be, and are highly encouraged to be, _virtual_, meaning that the
	list view is capable of creating a limited number of item renderers to
	display a subset of the data provider that is currently visible, instead of
	creating a renderer for every single item. This allows for optimized
	performance with very large data providers.

	The following example creates a list view, gives it a data provider, tells
	the item renderer how to interpret the data, and listens for when the
	selection changes:

	```haxe
	var listView = new ListView();

	listView.dataProvider = new ArrayCollection([
		{ text: "Milk" },
		{ text: "Eggs" },
		{ text: "Bread" },
		{ text: "Chicken" },
	]);

	listView.itemToText = (item:Dynamic) -> {
		return item.text;
	};

	listView.addEventListener(Event.CHANGE, (event:Event) -> {
		var listView = cast(event.currentTarget, ListView);
		trace("ListView changed: " + listView.selectedIndex + " " + listView.selectedItem.text);
	});

	this.addChild(listView);
	```

	@event openfl.events.Event.CHANGE Dispatched when either
	`ListView.selectedItem` or `ListView.selectedIndex` changes.

	@event feathers.events.ListViewEvent.ITEM_TRIGGER Dispatched when the user
	taps or clicks an item renderer in the list view. The pointer must remain
	within the bounds of the item renderer on release, and the list view cannot
	scroll before release, or the gesture will be ignored.

	@see [Tutorial: How to use the ListView component](https://feathersui.com/learn/haxe-openfl/list-view/)
	@see `feathers.controls.PopUpListView`
	@see `feathers.controls.ComboBox`

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
@:event(feathers.events.ListViewEvent.ITEM_TRIGGER)
@:access(feathers.data.ListViewItemState)
@defaultXmlProperty("dataProvider")
@:styleContext
class ListView extends BaseScrollContainer implements IIndexSelector implements IDataSelector<Dynamic> implements IFocusContainer implements IDragSource
		implements IDropTarget {
	/**
		A variant used to style the list view without a border. The variant is
		used by default on mobile.

		The following example uses this variant:

		```haxe
		var listView = new ListView();
		listView.variant = ListView.VARIANT_BORDERLESS;
		```

		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final VARIANT_BORDERLESS = "borderless";

	/**
		A variant used to style the list view with a border. This variant is
		used by default on desktop.

		The following example uses this variant:

		```haxe
		var listView = new ListView();
		listView.variant = ListView.VARIANT_BORDER;
		```

		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final VARIANT_BORDER = "border";

	/**
		A variant used to style the list view as a pop-up.

		The following example uses this variant:

		```haxe
		var listView = new ListView();
		listView.variant = ListView.VARIANT_POP_UP;
		```

		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final VARIANT_POP_UP = "popUp";

	/**
		The variant used to style the list view's item renderers in a theme.

		To override this default variant, set the
		`ListView.customItemRendererVariant` property.

		@see `ListView.customItemRendererVariant`
		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_ITEM_RENDERER = "listView_itemRenderer";

	/**
		The default value used for the `dragFormat` property.

		@since 1.3.0
	**/
	public static final DEFAULT_DRAG_FORMAT_ITEMS = "items";

	private static final INVALIDATION_FLAG_ITEM_RENDERER_FACTORY = InvalidationFlag.CUSTOM("itemRendererFactory");

	private static final RESET_ITEM_STATE = new ListViewItemState();

	private static function defaultUpdateItemRenderer(itemRenderer:DisplayObject, state:ListViewItemState):Void {
		if ((itemRenderer is ITextControl)) {
			var textControl:ITextControl = cast itemRenderer;
			textControl.text = state.text;
		}
	}

	private static function defaultResetItemRenderer(itemRenderer:DisplayObject, state:ListViewItemState):Void {
		if ((itemRenderer is ITextControl)) {
			var textControl:ITextControl = cast itemRenderer;
			textControl.text = null;
		}
	}

	/**
		Creates a new `ListView` object.

		@since 1.0.0
	**/
	public function new(?dataProvider:IFlatCollection<Dynamic>, ?changeListener:(Event) -> Void) {
		initializeListViewTheme();

		super();

		this.dataProvider = dataProvider;

		this.tabEnabled = true;
		this.focusRect = null;

		if (this.viewPort == null) {
			this.listViewPort = new AdvancedLayoutViewPort();
			this.addChild(this.listViewPort);
			this.viewPort = this.listViewPort;
		}

		this.addEventListener(KeyboardEvent.KEY_DOWN, listView_keyDownHandler);

		if (changeListener != null) {
			this.addEventListener(Event.CHANGE, changeListener);
		}
	}

	private var listViewPort:AdvancedLayoutViewPort;

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

	private var _dataProvider:IFlatCollection<Dynamic>;

	/**
		The collection of data displayed by the list view.

		Items in the collection must be class instances or anonymous structures.
		Do not add primitive values (such as strings, booleans, or numeric
		values) directly to the collection.

		Additionally, all items in the collection must be unique object
		instances. Do not add the same instance to the collection more than
		once because a runtime exception will be thrown.

		The following example passes in a data provider and tells the item
		renderer how to interpret the data:

		```haxe
		listView.dataProvider = new ArrayCollection([
			{ text: "Milk" },
			{ text: "Eggs" },
			{ text: "Bread" },
			{ text: "Chicken" },
		]);

		listView.itemToText = (item:Dynamic) -> {
			return item.text;
		};
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
			this._dataProvider.removeEventListener(Event.CHANGE, listView_dataProvider_changeHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.ADD_ITEM, listView_dataProvider_addItemHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.REMOVE_ITEM, listView_dataProvider_removeItemHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.REPLACE_ITEM, listView_dataProvider_replaceItemHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.REMOVE_ALL, listView_dataProvider_removeAllHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.RESET, listView_dataProvider_resetHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.SORT_CHANGE, listView_dataProvider_sortChangeHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.FILTER_CHANGE, listView_dataProvider_filterChangeHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.UPDATE_ITEM, listView_dataProvider_updateItemHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.UPDATE_ALL, listView_dataProvider_updateAllHandler);
		}
		this._dataProvider = value;
		if (this._dataProvider != null) {
			this._virtualCache.resize(this._dataProvider.length);
			this._dataProvider.addEventListener(Event.CHANGE, listView_dataProvider_changeHandler);
			this._dataProvider.addEventListener(FlatCollectionEvent.ADD_ITEM, listView_dataProvider_addItemHandler);
			this._dataProvider.addEventListener(FlatCollectionEvent.REMOVE_ITEM, listView_dataProvider_removeItemHandler);
			this._dataProvider.addEventListener(FlatCollectionEvent.REPLACE_ITEM, listView_dataProvider_replaceItemHandler);
			this._dataProvider.addEventListener(FlatCollectionEvent.REMOVE_ALL, listView_dataProvider_removeAllHandler);
			this._dataProvider.addEventListener(FlatCollectionEvent.RESET, listView_dataProvider_resetHandler);
			this._dataProvider.addEventListener(FlatCollectionEvent.SORT_CHANGE, listView_dataProvider_sortChangeHandler);
			this._dataProvider.addEventListener(FlatCollectionEvent.FILTER_CHANGE, listView_dataProvider_filterChangeHandler);
			this._dataProvider.addEventListener(FlatCollectionEvent.UPDATE_ITEM, listView_dataProvider_updateItemHandler);
			this._dataProvider.addEventListener(FlatCollectionEvent.UPDATE_ALL, listView_dataProvider_updateAllHandler);
		}

		// reset the scroll position because this is a drastic change and
		// the data is probably completely different
		this.scrollX = 0.0;
		this.scrollY = 0.0;

		// clear the selection for the same reason
		this.selectedIndex = -1; // use the setter

		this.setInvalid(DATA);
		FeathersEvent.dispatch(this, "dataChange");
		return this._dataProvider;
	}

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
		listView.allowMultipleSelection = true;
		```

		@see `ListView.selectable`
		@see `ListView.selectedIndices`
		@see `ListView.selectedItems`

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

		@see `ListView.allowMultipleSelection`
		@see `ListView.selectedItems`

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

		@see `ListView.allowMultipleSelection`
		@see `ListView.selectedIndices`

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
		The layout algorithm used to position and size the list view's items.

		By default, if no layout is provided by the time that the list view
		initializes, a default layout that displays items vertically will be
		created.

		The following example tells the list view to use a horizontal layout:

		```haxe
		var layout = new HorizontalListLayout();
		layout.gap = 20.0;
		layout.padding = 20.0;
		listView.layout = layout;
		```

		@since 1.0.0
	**/
	@:style
	public var layout:ILayout = null;

	private var _previousCustomItemRendererVariant:String = null;

	/**
		A custom variant to set on all item renderers, instead of
		`ListView.CHILD_VARIANT_ITEM_RENDERER`.

		The `customItemRendererVariant` will be not be used if the result of
		`itemRendererRecycler.create()` already has a variant set.

		@see `ListView.CHILD_VARIANT_ITEM_RENDERER`
		@see `feathers.style.IVariantStyleObject.variant`

		@since 1.0.0
	**/
	@:style
	public var customItemRendererVariant:String = null;

	/**
		Manages item renderers used by the list view.

		In the following example, the list view uses a custom item renderer
		class:

		```haxe
		listView.itemRendererRecycler = DisplayObjectRecycler.withClass(CustomItemRenderer);
		```

		@see `feathers.controls.dataRenderers.ItemRenderer`
		@see `feathers.controls.dataRenderers.LayoutGroupItemRenderer`

		@since 1.0.0
	**/
	public var itemRendererRecycler(get, set):AbstractDisplayObjectRecycler<Dynamic, ListViewItemState, DisplayObject>;

	private function get_itemRendererRecycler():AbstractDisplayObjectRecycler<Dynamic, ListViewItemState, DisplayObject> {
		return this._defaultStorage.itemRendererRecycler;
	}

	private function set_itemRendererRecycler(value:AbstractDisplayObjectRecycler<Dynamic, ListViewItemState,
		DisplayObject>):AbstractDisplayObjectRecycler<Dynamic, ListViewItemState, DisplayObject> {
		if (this._defaultStorage.itemRendererRecycler == value) {
			return this._defaultStorage.itemRendererRecycler;
		}
		this._defaultStorage.oldItemRendererRecycler = this._defaultStorage.itemRendererRecycler;
		this._defaultStorage.itemRendererRecycler = value;
		this._defaultStorage.measurements = null;
		this.setInvalid(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		return this._defaultStorage.itemRendererRecycler;
	}

	private var _forceItemStateUpdate:Bool = false;

	/**
		Forces the `itemRendererRecycler.update()` method to be called with the
		`ListViewItemState` when the list view validates, even if the item's
		state has not changed since the previous validation.

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

	private var _recyclerMap:Map<String, DisplayObjectRecycler<Dynamic, ListViewItemState, DisplayObject>> = null;

	private var _itemRendererRecyclerIDFunction:(state:ListViewItemState) -> String;

	/**
		When a list view requires multiple item renderer types, this function is
		used to determine which type of item renderer is required for a specific
		item. Returns the ID of the item renderer recycler to use for the item,
		or `null` if the default `itemRendererRecycler` should be used.

		The following example provides an `itemRendererRecyclerIDFunction`:

		```haxe
		var regularItemRecycler = DisplayObjectRecycler.withClass(ItemRenderer);
		var firstItemRecycler = DisplayObjectRecycler.withClass(MyCustomItemRenderer);

		listView.setItemRendererRecycler("regular-item", regularItemRecycler);
		listView.setItemRendererRecycler("first-item", firstItemRecycler);

		listView.itemRendererRecyclerIDFunction = function(state:ListViewItemState):String {
			if(state.index == 0) {
				return "first-item";
			}
			return "regular-item";
		};
		```

		@default null

		@see `ListView.setItemRendererRecycler()`
		@see `ListView.itemRendererRecycler

		@since 1.0.0
	**/
	public var itemRendererRecyclerIDFunction(get, set):(state:ListViewItemState) -> String;

	private function get_itemRendererRecyclerIDFunction():(state:ListViewItemState) -> String {
		return this._itemRendererRecyclerIDFunction;
	}

	private function set_itemRendererRecyclerIDFunction(value:(state:ListViewItemState) -> String):(state:ListViewItemState) -> String {
		if (this._itemRendererRecyclerIDFunction == value) {
			return this._itemRendererRecyclerIDFunction;
		}
		this._itemRendererRecyclerIDFunction = value;
		this.setInvalid(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		return this._itemRendererRecyclerIDFunction;
	}

	private var _defaultStorage = new ItemRendererStorage(null, DisplayObjectRecycler.withClass(ItemRenderer));
	private var _additionalStorage:Array<ItemRendererStorage> = null;
	private var objectDataToItemRenderer = new ObjectMap<Dynamic, DisplayObject>();
	private var stringDataToItemRenderer = new StringMap<DisplayObject>();
	private var itemRendererToItemState = new ObjectMap<DisplayObject, ListViewItemState>();
	private var itemStatePool = new ObjectPool(() -> new ListViewItemState());
	private var _unrenderedData:Array<Dynamic> = [];
	private var _virtualCache:Array<Dynamic> = [];
	private var _visibleIndices:VirtualLayoutRange = new VirtualLayoutRange(0, 0);
	private var _tempVisibleIndices:VirtualLayoutRange = new VirtualLayoutRange(0, 0);
	private var _layoutItems:Array<DisplayObject> = [];

	private var _selectable:Bool = true;

	/**
		Determines if items in the list view may be selected. By default only a
		single item may be selected at any given time. In other words, if item
		_A_ is already selected, and the user selects item _B_, item _A_ will be
		deselected automatically.

		The following example disables selection of items in the list view:

		```haxe
		listView.selectable = false;
		```

		@default true

		@see `ListView.selectedItem`
		@see `ListView.selectedIndex`

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

	private var _virtualLayout:Bool = true;

	/**
		Indicates if the list view's layout is allowed to virtualize items or
		not.

		The following example disables virtual layouts:

		```haxe
		listView.virtualLayout = false;
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

	/**
		Indicates if selection is changed with `MouseEvent.CLICK` or
		`TouchEvent.TOUCH_TAP` when the item renderer does not implement the
		`IToggle` interface. If set to `false`, all item renderers must control
		their own selection manually (not only ones that implement `IToggle`).

		The following example disables pointer selection:

		```haxe
		listView.pointerSelectionEnabled = false;
		```

		@since 1.0.0
	**/
	public var pointerSelectionEnabled:Bool = true;

	private var _pendingScrollIndex:Int = -1;
	private var _pendingScrollDuration:Null<Float> = null;

	private var _ignoreSelectionChange = false;
	private var _ignoreLayoutChanges = false;

	private var _dragDropIndicatorSkinMeasurements:Measurements;

	/**
		A skin to indicate where an item being dragged will be dropped within
		the layout, relative to the current mouse position. For this skin to be
		displayed, the `enabled` and `dropEnabled` properties must be `true`,
		and the list view must have accepted the drop in a
		`DragDropEvent.DRAG_ENTER` event listener.

		In the following example, the list view's index drag drop indicator skin is
		provided:

		```haxe
		listView.dragDropIndicatorSkin = new Bitmap(bitmapData);
		```
		@since 1.3.0

		@see `ListView.dropEnabled`
	**/
	@:style
	public var dragDropIndicatorSkin:DisplayObject = null;

	private var _dragFormat:String = DEFAULT_DRAG_FORMAT_ITEMS;

	/**
		Drag and drop is restricted between components, unless they specify the
		same `dragFormat`.

		In the following example, the drag format of two lists is customized:

		```haxe
		listView1.dragFormat = "my-custom-format";
		listView2.dragFormat = "my-custom-format";
		```

		@since 1.3.0

		@see `ListView.dragEnabled`
		@see `ListView.dropEnabled`
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
		Indicates if this list view can initiate drag and drop operations with
		mouse or touch. The `dragEnabled` property enables dragging items, but
		dropping items on the same list view must be enabled separately with the
		`dropEnabled` property. The `removeOnDragDropComplete` indicates if the
		initiating list view should remove the item from the data provider if it
		was successfully dropped somewhere else.

		In the following example, a list view's items may be dragged:

		```haxe
		listView.dragEnabled = true;
		```

		@since 1.3.0

		@see `ListView.dropEnabled`
		@see `ListView.removeOnDragDropComplete`
		@see `ListView.dragFormat`
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
			this.removeEventListener(DragDropEvent.DRAG_COMPLETE, listView_dragCompleteHandler);
		}
		this._dragEnabled = value;
		if (this._dragEnabled) {
			this.addEventListener(DragDropEvent.DRAG_COMPLETE, listView_dragCompleteHandler);
		}
		return this._dragEnabled;
	}

	private var _dropEnabled = false;

	/**
		Indicates if this list view can accept items that are dragged and
		dropped over the list view's view port.

		In the following example, items may be dropped on the list view:

		```haxe
		listView.dropEnabled = true;
		```

		@since 1.3.0

		@see `ListView.dragEnabled`
		@see `ListView.removeOnDragDropComplete`
		@see `ListView.dragFormat`
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
			this.removeEventListener(DragDropEvent.DRAG_ENTER, listView_dragEnterHandler);
			this.removeEventListener(DragDropEvent.DRAG_EXIT, listView_dragExitHandler);
			this.removeEventListener(DragDropEvent.DRAG_MOVE, listView_dragMoveHandler);
			this.removeEventListener(DragDropEvent.DRAG_DROP, listView_dragDropHandler);
		}
		this._dropEnabled = value;
		if (this._dropEnabled) {
			this.addEventListener(DragDropEvent.DRAG_ENTER, listView_dragEnterHandler);
			this.addEventListener(DragDropEvent.DRAG_EXIT, listView_dragExitHandler);
			this.addEventListener(DragDropEvent.DRAG_MOVE, listView_dragMoveHandler);
			this.addEventListener(DragDropEvent.DRAG_DROP, listView_dragDropHandler);
		}
		return this._dropEnabled;
	}

	private var _removeOnDragDropComplete = false;

	/**
		Indicates whether dragged items should be removed from this list view's
		data provider, if they are successfully dropped somewhere else.

		@since 1.3.0

		@see `ListView.dragEnabled`
		@see `ListView.dropEnabled`
		@see `ListView.dragFormat`
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
	private var _dragIndex:Int = -1;
	private var _dragItemRenderer:DisplayObject;
	private var _droppedOnSelf = false;
	private var _dragDropLastUpdateTime = -1;

	/**
		The distance from the edge of the container where it may auto-scroll,
		such as if a drag and drop operation is active.

		@since 1.3.0
	**/
	public var edgeAutoScrollDistance:Float = 8.0;

	/**
		Converts an item to text to display within list view. By default, the
		`toString()` method is called to convert an item to text. This method
		may be replaced to provide custom text.

		For example, consider the following item:

		```haxe
		{ text: "Example Item" }
		```

		If the `ListView` should display the text "Example Item", a custom
		implementation of `itemToText()` might look like this:

		```haxe
		listView.itemToText = (item:Dynamic) -> {
			return item.text;
		};
		```

		@since 1.0.0
	**/
	public dynamic function itemToText(data:Dynamic):String {
		return Std.string(data);
	}

	/**
		Determines if an item should be enabled or disabled. By default, all
		items are enabled, unless the `ListView` is disabled. This method
		may be replaced to provide a custom value for `enabled`.

		For example, consider the following item:

		```haxe
		{ text: "Example Item", disable: true }
		```

		If the `ListView` should disable an item if the `disable` field is
		`true`, a custom implementation of `itemToEnabled()` might look like
		this:

		```haxe
		listView.itemToEnabled = (item:Dynamic) -> {
			return !item.disable;
		};
		```

		@since 1.2.0
	**/
	public dynamic function itemToEnabled(data:Dynamic):Bool {
		return true;
	}

	/**
		Scrolls the list view so that the specified item renderer is completely
		visible. If the item renderer is already completely visible, does not
		update the scroll position.

		A custom animation duration may be specified. To update the scroll
		position without animation, pass a value of `0.0` for the duration.

		@since 1.0.0
	**/
	public function scrollToIndex(index:Int, ?animationDuration:Float):Void {
		if (this._dataProvider == null || this._dataProvider.length == 0) {
			return;
		}
		this._pendingScrollIndex = index;
		this._pendingScrollDuration = animationDuration;
		this.setInvalid(SCROLL);
	}

	/**
		Returns the current item renderer used to render a specific item from
		the data provider. May return `null` if an item doesn't currently have
		an item renderer.

		**Note:** Most list views use "virtual" layouts, which means that only
		the currently-visible subset of items will have an item renderer. As the
		list view scrolls, the items with item renderers will change, and item
		renderers may even be re-used to display different items.

		@since 1.0.0
	**/
	public function itemToItemRenderer(item:Dynamic):DisplayObject {
		if (item == null) {
			return null;
		}
		if ((item is String)) {
			return this.stringDataToItemRenderer.get(cast item);
		}
		return this.objectDataToItemRenderer.get(item);
	}

	/**
		Returns the current item from the data provider that is rendered by a
		specific item renderer.

		@since 1.0.0
	**/
	public function itemRendererToItem(itemRenderer:DisplayObject):Dynamic {
		if (itemRenderer == null) {
			return null;
		}
		var state = this.itemRendererToItemState.get(itemRenderer);
		if (state == null) {
			return null;
		}
		return state.data;
	}

	/**
		Returns the current item renderer used to render the item at the
		specified index in the data provider. May return `null` if an item
		doesn't currently have an item renderer.

		**Note:** Most list views use "virtual" layouts, which means that only
		the currently-visible subset of items will have an item renderer. As the
		list view scrolls, the items with item renderers will change, and item
		renderers may even be re-used to display different items.

		@since 1.0.0
	**/
	public function indexToItemRenderer(index:Int):DisplayObject {
		if (this._dataProvider == null || index < 0 || index >= this._dataProvider.length) {
			return null;
		}
		var item = this._dataProvider.get(index);
		if ((item is String)) {
			return this.stringDataToItemRenderer.get(cast item);
		}
		return this.objectDataToItemRenderer.get(item);
	}

	/**
		Returns the item renderer recycler associated with a specific ID.
		Returns `null` if no recycler is associated with the ID.

		@see `ListView.itemRendererRecyclerIDFunction`
		@see `ListView.setItemRendererRecycler()`

		@since 1.0.0
	**/
	public function getItemRendererRecycler(id:String):DisplayObjectRecycler<Dynamic, ListViewItemState, DisplayObject> {
		if (this._recyclerMap == null) {
			return null;
		}
		return this._recyclerMap.get(id);
	}

	/**
		Associates an item renderer recycler with an ID to allow multiple types
		of item renderers may be displayed in the list view. A custom
		`itemRendererRecyclerIDFunction` may be specified to return the ID of
		the recycler to use for a specific item in the data provider.

		To clear a recycler, pass in `null` for the value.

		@see `ListView.itemRendererRecyclerIDFunction`
		@see `ListView.getItemRendererRecycler()`

		@since 1.0.0
	**/
	public function setItemRendererRecycler(id:String, recycler:AbstractDisplayObjectRecycler<Dynamic, ListViewItemState, DisplayObject>):Void {
		if (this._recyclerMap == null) {
			this._recyclerMap = [];
		}
		if (recycler == null) {
			this._recyclerMap.remove(id);
			return;
		}
		this._recyclerMap.set(id, recycler);
		this.setInvalid(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
	}

	/**
		Returns a `ListViewItemState` representing a specific item.

		@since 1.3.0
	**/
	public function itemToItemState(item:Dynamic):ListViewItemState {
		if (item == null) {
			return null;
		}
		var itemState:ListViewItemState = null;
		var itemRenderer:DisplayObject = null;
		if ((item is String)) {
			itemRenderer = this.stringDataToItemRenderer.get(item);
		} else {
			itemRenderer = this.objectDataToItemRenderer.get(item);
		}
		if (itemRenderer != null) {
			itemState = this.itemRendererToItemState.get(itemRenderer);
		} else {
			var index = this._dataProvider.indexOf(item);
			if (index == -1) {
				return null;
			}
			itemState = new ListViewItemState();
			this.populateCurrentItemState(item, index, itemState, false);
		}
		return itemState;
	}

	override public function dispose():Void {
		this.refreshInactiveItemRenderers(this._defaultStorage, true);
		if (this._additionalStorage != null) {
			for (i in 0...this._additionalStorage.length) {
				var storage = this._additionalStorage[i];
				this.refreshInactiveItemRenderers(storage, true);
			}
		}
		// manually clear the selection so that removing the data provider
		// doesn't result in Event.CHANGE getting dispatched
		this._selectedItem = null;
		this._selectedIndex = -1;
		this.dataProvider = null;
		super.dispose();
	}

	private function initializeListViewTheme():Void {
		#if !feathersui_disable_default_theme
		feathers.themes.steel.components.SteelListViewStyles.initialize();
		#end
	}

	override private function update():Void {
		var layoutInvalid = this.isInvalid(LAYOUT);
		var stylesInvalid = this.isInvalid(STYLES);

		if (this._previousCustomItemRendererVariant != this.customItemRendererVariant) {
			this.setInvalidationFlag(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
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
			this.listViewPort.layout = this.layout;
			this._previousLayout = this.layout;
		}

		this.listViewPort.refreshChildren = this.refreshItemRenderers;

		for (flag in this._invalidationFlags.keys()) {
			this.listViewPort.setInvalid(flag);
		}
		if (this._allInvalid) {
			this.listViewPort.setInvalid();
		}

		super.update();

		this._previousCustomItemRendererVariant = this.customItemRendererVariant;

		this.handlePendingScroll();
	}

	override private function createScroller():Void {
		super.createScroller();
		this.listViewPort.scroller = this.scroller;
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
		this.scroller.snapPositionsX = this.listViewPort.snapPositionsX;
		this.scroller.snapPositionsY = this.listViewPort.snapPositionsY;
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
			virtualLayout.getVisibleIndices(this._layoutItems.length, this.listViewPort.visibleWidth, this.listViewPort.visibleHeight,
				this._tempVisibleIndices);
		} else {
			this._tempVisibleIndices.start = 0;
			this._tempVisibleIndices.end = this._layoutItems.length - 1;
		}
		return oldStart != this._tempVisibleIndices.start || oldEnd != this._tempVisibleIndices.end;
	}

	private function refreshItemRenderers(items:Array<DisplayObject>):Void {
		this._layoutItems = items;

		if (this._defaultStorage.itemRendererRecycler.update == null) {
			this._defaultStorage.itemRendererRecycler.update = defaultUpdateItemRenderer;
			if (this._defaultStorage.itemRendererRecycler.reset == null) {
				this._defaultStorage.itemRendererRecycler.reset = defaultResetItemRenderer;
			}
		}
		if (this._recyclerMap != null) {
			for (recycler in this._recyclerMap) {
				if (recycler.update == null) {
					if (recycler.update == null) {
						recycler.update = defaultUpdateItemRenderer;
						// don't replace reset if we didn't replace update too
						if (recycler.reset == null) {
							recycler.reset = defaultResetItemRenderer;
						}
					}
				}
			}
		}

		var itemRendererInvalid = this.listViewPort.isInvalid(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		this.refreshInactiveItemRenderers(this._defaultStorage, itemRendererInvalid);
		if (this._additionalStorage != null) {
			for (i in 0...this._additionalStorage.length) {
				var storage = this._additionalStorage[i];
				this.refreshInactiveItemRenderers(storage, itemRendererInvalid);
			}
		}
		this.findUnrenderedData();
		this.recoverInactiveItemRenderers(this._defaultStorage);
		if (this._additionalStorage != null) {
			for (i in 0...this._additionalStorage.length) {
				var storage = this._additionalStorage[i];
				this.recoverInactiveItemRenderers(storage);
			}
		}
		this.renderUnrenderedData();
		this.freeInactiveItemRenderers(this._defaultStorage);
		if (this._defaultStorage.inactiveItemRenderers.length > 0) {
			throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: inactive item renderers should be empty after updating.');
		}
		if (this._additionalStorage != null) {
			for (i in 0...this._additionalStorage.length) {
				var storage = this._additionalStorage[i];
				this.freeInactiveItemRenderers(storage);
				if (storage.inactiveItemRenderers.length > 0) {
					throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: inactive item renderers ${storage.id} should be empty after updating.');
				}
			}
		}
	}

	private function refreshInactiveItemRenderers(storage:ItemRendererStorage, factoryInvalid:Bool):Void {
		var temp = storage.inactiveItemRenderers;
		storage.inactiveItemRenderers = storage.activeItemRenderers;
		storage.activeItemRenderers = temp;
		if (storage.activeItemRenderers.length > 0) {
			throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: active item renderers should be empty before updating.');
		}
		if (factoryInvalid) {
			this.recoverInactiveItemRenderers(storage);
			this.freeInactiveItemRenderers(storage);
			storage.oldItemRendererRecycler = null;
		}
	}

	private function recoverInactiveItemRenderers(storage:ItemRendererStorage):Void {
		for (itemRenderer in storage.inactiveItemRenderers) {
			if (itemRenderer == null) {
				continue;
			}
			var state = this.itemRendererToItemState.get(itemRenderer);
			if (state == null) {
				continue;
			}
			var item = state.data;
			this.itemRendererToItemState.remove(itemRenderer);
			if ((item is String)) {
				this.stringDataToItemRenderer.remove(cast item);
			} else {
				this.objectDataToItemRenderer.remove(item);
			}
			itemRenderer.removeEventListener(TriggerEvent.TRIGGER, listView_itemRenderer_triggerHandler);
			itemRenderer.removeEventListener(MouseEvent.CLICK, listView_itemRenderer_clickHandler);
			itemRenderer.removeEventListener(TouchEvent.TOUCH_TAP, listView_itemRenderer_touchTapHandler);
			itemRenderer.removeEventListener(Event.CHANGE, listView_itemRenderer_changeHandler);
			itemRenderer.removeEventListener(Event.RESIZE, listView_itemRenderer_resizeHandler);
			itemRenderer.removeEventListener(MouseEvent.MOUSE_DOWN, listView_itemRenderer_mouseDownHandler);
			this.resetItemRenderer(itemRenderer, state, storage);
			if (storage.measurements != null) {
				storage.measurements.restore(itemRenderer);
			}
			this.itemStatePool.release(state);
		}
	}

	private function freeInactiveItemRenderers(storage:ItemRendererStorage):Void {
		var recycler = storage.oldItemRendererRecycler != null ? storage.oldItemRendererRecycler : storage.itemRendererRecycler;
		for (itemRenderer in storage.inactiveItemRenderers) {
			if (itemRenderer == null) {
				continue;
			}
			this.destroyItemRenderer(itemRenderer, recycler);
		}
		#if (hl && haxe_ver < 4.3)
		storage.inactiveItemRenderers.splice(0, storage.inactiveItemRenderers.length);
		#else
		storage.inactiveItemRenderers.resize(0);
		#end
	}

	private function findUnrenderedData():Void {
		// remove all old items, then fill with null
		#if (hl && haxe_ver < 4.3)
		this._layoutItems.splice(0, this._layoutItems.length);
		#else
		this._layoutItems.resize(0);
		#end
		this._visibleIndices.start = 0;
		this._visibleIndices.end = 0;
		if (this._dataProvider == null || this._dataProvider.length == 0) {
			return;
		}
		this._layoutItems.resize(this._dataProvider.length);

		if (this._virtualLayout && (this.layout is IVirtualLayout)) {
			var virtualLayout:IVirtualLayout = cast this.layout;
			var oldIgnoreLayoutChanges = this._ignoreLayoutChanges;
			this._ignoreLayoutChanges = true;
			virtualLayout.scrollX = this.scroller.scrollX;
			virtualLayout.scrollY = this.scroller.scrollY;
			virtualLayout.virtualCache = this._virtualCache;
			this._ignoreLayoutChanges = oldIgnoreLayoutChanges;
			virtualLayout.getVisibleIndices(this._dataProvider.length, this.listViewPort.visibleWidth, this.listViewPort.visibleHeight, this._visibleIndices);
		} else {
			this._visibleIndices.start = 0;
			this._visibleIndices.end = this._dataProvider.length - 1;
		}
		for (i in this._visibleIndices.start...this._visibleIndices.end + 1) {
			var item = this._dataProvider.get(i);
			var itemRenderer:DisplayObject = null;
			if ((item is String)) {
				itemRenderer = this.stringDataToItemRenderer.get(cast item);
			} else {
				itemRenderer = this.objectDataToItemRenderer.get(item);
			}
			if (itemRenderer != null) {
				var state = this.itemRendererToItemState.get(itemRenderer);
				var changed = this.populateCurrentItemState(item, i, state, this._forceItemStateUpdate);
				var oldRecyclerID = state.recyclerID;
				var storage = this.itemStateToStorage(state);
				if (storage.id != oldRecyclerID) {
					this._unrenderedData.push(item);
					continue;
				}
				if (changed) {
					this.updateItemRenderer(itemRenderer, state, storage);
				}
				// if this item renderer used to be the typical layout item, but
				// it isn't anymore, it may have been set invisible
				itemRenderer.visible = true;
				this._layoutItems[i] = itemRenderer;
				var removed = storage.inactiveItemRenderers.remove(itemRenderer);
				if (!removed) {
					throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: item renderer map contains bad data for item at index ${i}. This may be caused by duplicate items in the data provider, which is not allowed.');
				}
				storage.activeItemRenderers.push(itemRenderer);
			} else {
				this._unrenderedData.push(item);
			}
		}
	}

	private function populateCurrentItemState(item:Dynamic, index:Int, state:ListViewItemState, force:Bool):Bool {
		var changed = false;
		if (force || state.owner != this) {
			state.owner = this;
			changed = true;
		}
		if (force || state.data != item) {
			state.data = item;
			changed = true;
		}
		if (force || state.index != index) {
			state.index = index;
			changed = true;
		}
		var selected = this._selectedIndices.indexOf(index) != -1;
		if (force || state.selected != selected) {
			state.selected = selected;
			changed = true;
		}
		var enabled = this._enabled && itemToEnabled(item);
		if (force || state.enabled != enabled) {
			state.enabled = enabled;
			changed = true;
		}
		var text = itemToText(item);
		if (force || state.text != text) {
			state.text = text;
			changed = true;
		}
		return changed;
	}

	private function resetItemRenderer(itemRenderer:DisplayObject, state:ListViewItemState, storage:ItemRendererStorage):Void {
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		var recycler = storage.oldItemRendererRecycler != null ? storage.oldItemRendererRecycler : storage.itemRendererRecycler;
		if (recycler != null && recycler.reset != null) {
			recycler.reset(itemRenderer, state);
		}
		this._ignoreSelectionChange = oldIgnoreSelectionChange;
		this.refreshItemRendererProperties(itemRenderer, RESET_ITEM_STATE);
	}

	private function updateItemRenderer(itemRenderer:DisplayObject, state:ListViewItemState, storage:ItemRendererStorage):Void {
		state.recyclerID = storage.id;
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		if (storage.itemRendererRecycler.update != null) {
			storage.itemRendererRecycler.update(itemRenderer, state);
		}
		this._ignoreSelectionChange = oldIgnoreSelectionChange;
		this.refreshItemRendererProperties(itemRenderer, state);
	}

	private function refreshItemRendererProperties(itemRenderer:DisplayObject, state:ListViewItemState):Void {
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		if ((itemRenderer is IUIControl)) {
			var uiControl:IUIControl = cast itemRenderer;
			uiControl.enabled = state.enabled;
		}
		if ((itemRenderer is IDataRenderer)) {
			var dataRenderer:IDataRenderer = cast itemRenderer;
			// if the renderer is an IDataRenderer, this cannot be overridden
			dataRenderer.data = state.data;
		}
		if ((itemRenderer is IListViewItemRenderer)) {
			var listRenderer:IListViewItemRenderer = cast itemRenderer;
			listRenderer.index = state.index;
			listRenderer.listViewOwner = state.owner;
		}
		if ((itemRenderer is ILayoutIndexObject)) {
			var layoutIndexObject:ILayoutIndexObject = cast itemRenderer;
			layoutIndexObject.layoutIndex = state.index;
		}
		if ((itemRenderer is IToggle)) {
			var toggle:IToggle = cast itemRenderer;
			// if the renderer is an IToggle, this cannot be overridden
			toggle.selected = state.selected;
		}
		this._ignoreSelectionChange = oldIgnoreSelectionChange;
	}

	private function renderUnrenderedData():Void {
		for (item in this._unrenderedData) {
			var index = this._dataProvider.indexOf(item);
			var state = this.itemStatePool.get();
			this.populateCurrentItemState(item, index, state, true);
			var itemRenderer = this.createItemRenderer(state);
			itemRenderer.visible = true;
			this.listViewPort.addChild(itemRenderer);
			this._layoutItems[index] = itemRenderer;
		}
		#if (hl && haxe_ver < 4.3)
		this._unrenderedData.splice(0, this._unrenderedData.length);
		#else
		this._unrenderedData.resize(0);
		#end
	}

	private function createItemRenderer(state:ListViewItemState):DisplayObject {
		var storage = this.itemStateToStorage(state);
		var itemRenderer:DisplayObject = null;
		if (storage.inactiveItemRenderers.length == 0) {
			itemRenderer = storage.itemRendererRecycler.create();
			if ((itemRenderer is IVariantStyleObject)) {
				var variantItemRenderer:IVariantStyleObject = cast itemRenderer;
				if (variantItemRenderer.variant == null) {
					var variant = (this.customItemRendererVariant != null) ? this.customItemRendererVariant : CHILD_VARIANT_ITEM_RENDERER;
					variantItemRenderer.variant = variant;
				}
			}
			// for consistency, initialize before passing to the recycler's
			// update function. plus, this ensures that custom item renderers
			// correctly handle property changes in update() instead of trying
			// to access them too early in initialize().
			if ((itemRenderer is IUIControl)) {
				(cast itemRenderer : IUIControl).initializeNow();
			}
			// save measurements after initialize, because width/height could be
			// set explicitly there, and we want to restore those values
			if (storage.measurements == null) {
				storage.measurements = new Measurements(itemRenderer);
			}
		} else {
			itemRenderer = storage.inactiveItemRenderers.shift();
		}
		this.updateItemRenderer(itemRenderer, state, storage);
		if ((itemRenderer is ITriggerView)) {
			// prefer TriggerEvent.TRIGGER
			itemRenderer.addEventListener(TriggerEvent.TRIGGER, listView_itemRenderer_triggerHandler);
		} else {
			// fall back to these events if TriggerEvent.TRIGGER isn't available
			itemRenderer.addEventListener(MouseEvent.CLICK, listView_itemRenderer_clickHandler);
			#if (openfl >= "9.0.0")
			itemRenderer.addEventListener(TouchEvent.TOUCH_TAP, listView_itemRenderer_touchTapHandler);
			#end
		}
		if ((itemRenderer is IToggle)) {
			itemRenderer.addEventListener(Event.CHANGE, listView_itemRenderer_changeHandler);
		}
		if ((itemRenderer is IMeasureObject)) {
			itemRenderer.addEventListener(Event.RESIZE, listView_itemRenderer_resizeHandler);
		}
		itemRenderer.addEventListener(MouseEvent.MOUSE_DOWN, listView_itemRenderer_mouseDownHandler);
		this.itemRendererToItemState.set(itemRenderer, state);
		var item = state.data;
		if ((item is String)) {
			this.stringDataToItemRenderer.set(cast item, itemRenderer);
		} else {
			this.objectDataToItemRenderer.set(state.data, itemRenderer);
		}
		storage.activeItemRenderers.push(itemRenderer);
		return itemRenderer;
	}

	private function destroyItemRenderer(itemRenderer:DisplayObject, recycler:DisplayObjectRecycler<Dynamic, ListViewItemState, DisplayObject>):Void {
		this.listViewPort.removeChild(itemRenderer);
		if (recycler != null && recycler.destroy != null) {
			recycler.destroy(itemRenderer);
		}
	}

	private function itemStateToStorage(state:ListViewItemState):ItemRendererStorage {
		var recyclerID:String = null;
		if (this._itemRendererRecyclerIDFunction != null) {
			recyclerID = this._itemRendererRecyclerIDFunction(state);
		}
		var recycler:DisplayObjectRecycler<Dynamic, ListViewItemState, DisplayObject> = null;
		if (recyclerID != null) {
			if (this._recyclerMap != null) {
				recycler = this._recyclerMap.get(recyclerID);
			}
			if (recycler == null) {
				throw new IllegalOperationError('Item renderer recycler ID "${recyclerID}" is not registered.');
			}
		}
		if (recycler == null) {
			return this._defaultStorage;
		}
		if (this._additionalStorage == null) {
			this._additionalStorage = [];
		}
		for (i in 0...this._additionalStorage.length) {
			var storage = this._additionalStorage[i];
			if (storage.itemRendererRecycler == recycler) {
				return storage;
			}
		}
		var storage = new ItemRendererStorage(recyclerID, recycler);
		this._additionalStorage.push(storage);
		return storage;
	}

	private function refreshSelectedIndicesAfterFilterOrSort():Void {
		if (this._selectedIndex == -1) {
			return;
		}
		// the index may have changed, possibly even to -1, if the item was
		// filtered out
		this.selectedIndex = this._dataProvider.indexOf(this._selectedItem); // use the setter
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
			this.scrollToIndex(index);
		}
	}

	private function handlePendingScroll():Void {
		if (this._pendingScrollIndex == -1) {
			return;
		}
		var index = this._pendingScrollIndex;
		var duration = this._pendingScrollDuration != null ? this._pendingScrollDuration : 0.0;
		this._pendingScrollIndex = -1;
		this._pendingScrollDuration = null;

		if (this._dataProvider == null || this._dataProvider.length == 0) {
			return;
		}

		var targetX = this.scrollX;
		var targetY = this.scrollY;
		if ((this.layout is IScrollLayout)) {
			var scrollLayout:IScrollLayout = cast this.layout;
			var result = scrollLayout.getNearestScrollPositionForIndex(index, this._dataProvider.length, this.viewPort.visibleWidth,
				this.viewPort.visibleHeight);
			targetX = result.x;
			targetY = result.y;
		} else {
			var item = this._dataProvider.get(index);
			var itemRenderer:DisplayObject = null;
			if ((item is String)) {
				itemRenderer = this.stringDataToItemRenderer.get(cast item);
			} else {
				itemRenderer = this.objectDataToItemRenderer.get(item);
			}
			if (itemRenderer == null) {
				return;
			}

			var maxX = itemRenderer.x;
			var minX = maxX + itemRenderer.width - this.viewPort.visibleWidth;
			if (targetX < minX) {
				targetX = minX;
			} else if (targetX > maxX) {
				targetX = maxX;
			}

			var maxY = itemRenderer.y;
			var minY = maxY + itemRenderer.height - this.viewPort.visibleHeight;
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
		var dragDropIndex = dropDropLayout.getDragDropIndex(this._layoutItems, dropX, dropY, this._viewPort.visibleWidth, this._viewPort.visibleHeight);
		var dragDropRegion = dropDropLayout.getDragDropRegion(this._layoutItems, dragDropIndex, dropX, dropY, this._viewPort.visibleWidth,
			this._viewPort.visibleHeight);
		// convert back to list view coordinates
		this.dragDropIndicatorSkin.x = dragDropRegion.x - this.scrollX + this.leftViewPortOffset;
		this.dragDropIndicatorSkin.y = dragDropRegion.y - this.scrollY + this.topViewPortOffset;
		if (dragDropRegion.width == 0.0) {
			this.dragDropIndicatorSkin.height = dragDropRegion.height;
		} else {
			this.dragDropIndicatorSkin.width = dragDropRegion.width;
		}
		this.addChild(this.dragDropIndicatorSkin);
	}

	private function listView_itemRenderer_touchTapHandler(event:TouchEvent):Void {
		if (!this._enabled) {
			return;
		}
		if (event.isPrimaryTouchPoint #if air && Multitouch.mapTouchToMouse #end) {
			// ignore the primary one because MouseEvent.CLICK will catch it
			return;
		}

		var itemRenderer = cast(event.currentTarget, DisplayObject);
		var state = this.itemRendererToItemState.get(itemRenderer);
		ListViewEvent.dispatch(this, ListViewEvent.ITEM_TRIGGER, state);

		if (!this._selectable || !this.pointerSelectionEnabled) {
			return;
		}
		this.handleSelectionChange(state.data, state.index, event.ctrlKey, event.shiftKey);
	}

	private function listView_itemRenderer_clickHandler(event:MouseEvent):Void {
		if (!this._enabled) {
			return;
		}

		var itemRenderer = cast(event.currentTarget, DisplayObject);
		var state = this.itemRendererToItemState.get(itemRenderer);
		ListViewEvent.dispatch(this, ListViewEvent.ITEM_TRIGGER, state);

		if (!this._selectable || !this.pointerSelectionEnabled) {
			return;
		}
		this.handleSelectionChange(state.data, state.index, event.ctrlKey, event.shiftKey);
	}

	private function listView_itemRenderer_triggerHandler(event:TriggerEvent):Void {
		if (!this._enabled) {
			return;
		}

		var itemRenderer = cast(event.currentTarget, DisplayObject);
		var state = this.itemRendererToItemState.get(itemRenderer);
		ListViewEvent.dispatch(this, ListViewEvent.ITEM_TRIGGER, state);

		if (!this._selectable) {
			return;
		}
		this.handleSelectionChange(state.data, state.index, event.ctrlKey, event.shiftKey);
	}

	private function listView_itemRenderer_resizeHandler(event:Event):Void {
		if (this._validating) {
			return;
		}
		this.setInvalid(LAYOUT);
	}

	private function listView_itemRenderer_changeHandler(event:Event):Void {
		if (this._ignoreSelectionChange) {
			return;
		}
		var itemRenderer = cast(event.currentTarget, DisplayObject);
		var toggleItemRenderer = cast(itemRenderer, IToggle);
		var state = this.itemRendererToItemState.get(itemRenderer);
		if (toggleItemRenderer.selected == state.selected) {
			// nothing has changed
			return;
		}
		// if we get here, the selected property of the renderer changed
		// unexpectedly, and we need to restore its proper state
		this.setInvalid(SELECTION);
	}

	private function listView_itemRenderer_mouseDownHandler(event:MouseEvent):Void {
		if (!this._enabled || !this._dragEnabled || this.stage == null) {
			return;
		}
		var itemRenderer = cast(event.currentTarget, DisplayObject);
		var state = this.itemRendererToItemState.get(itemRenderer);
		if (state == null) {
			return;
		}
		this._dragItemRenderer = itemRenderer;
		this._dragItem = state.data;
		this._dragIndex = state.index;
		this._dragDropLocalX = this.mouseX;
		this._dragDropLocalY = this.mouseY;
		this._dragMinDistance = 6.0;
		this.stage.addEventListener(MouseEvent.MOUSE_MOVE, listView_stage_pressAndMove_mouseMoveHandler, false, 0, true);
		this.stage.addEventListener(MouseEvent.MOUSE_UP, listView_stage_pressAndMove_mouseUpHandler, false, 0, true);
	}

	private function listView_stage_pressAndMove_mouseMoveHandler(event:MouseEvent):Void {
		var offsetX = this.mouseX - this._dragDropLocalX;
		var offsetY = this.mouseY - this._dragDropLocalY;
		if (offsetX > this._dragMinDistance || offsetY > this._dragMinDistance) {
			var stage = cast(event.currentTarget, Stage);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, listView_stage_pressAndMove_mouseMoveHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, listView_stage_pressAndMove_mouseUpHandler);

			var items:Array<Dynamic> = [];
			var draggedIndices = this._allowMultipleSelection ? this._selectedIndices.copy() : [];
			if (draggedIndices.indexOf(this._dragIndex) == -1) {
				draggedIndices.push(this._dragIndex);
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

			var itemState = this.itemRendererToItemState.get(this._dragItemRenderer);
			var storage = this.itemStateToStorage(itemState);
			var itemRenderer = storage.itemRendererRecycler.create();
			this.updateItemRenderer(itemRenderer, itemState, storage);
			itemRenderer.width = this._dragItemRenderer.width;
			itemRenderer.height = this._dragItemRenderer.height;

			DragDropManager.startDrag(this, dragData, itemRenderer, -this._dragItemRenderer.mouseX, -this._dragItemRenderer.mouseY);
		}
	}

	private function listView_stage_pressAndMove_mouseUpHandler(event:MouseEvent):Void {
		var stage = cast(event.currentTarget, Stage);
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, listView_stage_pressAndMove_mouseMoveHandler);
		stage.removeEventListener(MouseEvent.MOUSE_UP, listView_stage_pressAndMove_mouseUpHandler);
		this._dragItem = null;
		this._dragIndex = -1;
		this._dragItemRenderer = null;
	}

	private function listView_dragCompleteHandler(event:DragDropEvent):Void {
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

	private function listView_dragEnterHandler(event:DragDropEvent):Void {
		if (!this._enabled || !this._dropEnabled || !event.dragData.exists(this._dragFormat)) {
			return;
		}
		event.acceptDrag(this);
		this.showFocus(true);
		this._dragDropLocalX = event.localX;
		this._dragDropLocalY = event.localY;
		this.refreshDragDropIndexIndicator();
		this._dragDropLastUpdateTime = Lib.getTimer();
		this.addEventListener(Event.ENTER_FRAME, listView_dragScroll_enterFrameHandler);
	}

	private function listView_dragExitHandler(event:DragDropEvent):Void {
		if (this.dragDropIndicatorSkin != null) {
			this._dragDropIndicatorSkinMeasurements.restore(this.dragDropIndicatorSkin);
			if (this.dragDropIndicatorSkin.parent == this) {
				this.removeChild(this.dragDropIndicatorSkin);
			}
		}
		this.showFocus(false);
		this._dragDropLastUpdateTime = -1;
		this.removeEventListener(Event.ENTER_FRAME, listView_dragScroll_enterFrameHandler);
	}

	private function listView_dragScroll_enterFrameHandler(event:Event):Void {
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

	private function listView_dragMoveHandler(event:DragDropEvent):Void {
		if (!this._enabled || !this._dropEnabled || !event.dragData.exists(this._dragFormat)) {
			return;
		}
		this._dragDropLocalX = event.localX;
		this._dragDropLocalY = event.localY;
		this.refreshDragDropIndexIndicator();
	}

	private function listView_dragDropHandler(event:DragDropEvent):Void {
		if (this.dragDropIndicatorSkin != null && this.dragDropIndicatorSkin.parent == this) {
			this._dragDropIndicatorSkinMeasurements.restore(this.dragDropIndicatorSkin);
			this.removeChild(this.dragDropIndicatorSkin);
		}
		this.showFocus(false);
		this._dragDropLastUpdateTime = -1;
		this.removeEventListener(Event.ENTER_FRAME, listView_dragScroll_enterFrameHandler);
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
			dragDropIndex = dragDropLayout.getDragDropIndex(this._layoutItems, dropX, dropY, this._viewPort.visibleWidth, this._viewPort.visibleHeight);
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

	private function listView_dataProvider_changeHandler(event:Event):Void {
		this.setInvalid(DATA);
	}

	private function listView_dataProvider_addItemHandler(event:FlatCollectionEvent):Void {
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

	private function listView_dataProvider_removeItemHandler(event:FlatCollectionEvent):Void {
		if (this._virtualCache != null) {
			this._virtualCache.remove(event.index);
		}
		if (this.selectedIndex == -1) {
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

	private function listView_dataProvider_replaceItemHandler(event:FlatCollectionEvent):Void {
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

	private function listView_dataProvider_removeAllHandler(event:FlatCollectionEvent):Void {
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

	private function listView_dataProvider_resetHandler(event:FlatCollectionEvent):Void {
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

	private function listView_dataProvider_sortChangeHandler(event:FlatCollectionEvent):Void {
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

	private function listView_dataProvider_filterChangeHandler(event:FlatCollectionEvent):Void {
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

	private function updateItemRendererForIndex(index:Int):Void {
		if (this._virtualCache != null) {
			this._virtualCache[index] = null;
		}
		var item = this._dataProvider.get(index);
		var itemRenderer:DisplayObject = null;
		if ((item is String)) {
			itemRenderer = this.stringDataToItemRenderer.get(cast item);
		} else {
			itemRenderer = this.objectDataToItemRenderer.get(item);
		}
		if (itemRenderer == null) {
			// doesn't exist yet, so we need to do a full invalidation
			this.setInvalid(DATA);
			return;
		}
		var state = this.itemRendererToItemState.get(itemRenderer);
		if (state.owner == null) {
			// a previous update is already pending
			return;
		}
		var storage = this.itemStateToStorage(state);
		this.populateCurrentItemState(item, index, state, true);
		// in order to display the same item with modified properties, this
		// hack tricks the item renderer into thinking that it has been given
		// a different item to render.
		this.resetItemRenderer(itemRenderer, state, storage);
		if (storage.measurements != null) {
			storage.measurements.restore(itemRenderer);
		}
		// ensures that the change is detected when we validate later
		state.owner = null;
		this.setInvalid(DATA);
	}

	private function listView_dataProvider_updateItemHandler(event:FlatCollectionEvent):Void {
		this.updateItemRendererForIndex(event.index);
	}

	private function listView_dataProvider_updateAllHandler(event:FlatCollectionEvent):Void {
		for (i in 0...this._dataProvider.length) {
			this.updateItemRendererForIndex(i);
		}
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
			result = cast(this.layout, IKeyboardNavigationLayout).findNextKeyboardIndex(result, event, false, this._layoutItems, null,
				this.listViewPort.visibleWidth, this.listViewPort.visibleHeight);
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
			var itemRenderer = this.itemToItemRenderer(this._dataProvider.get(result));
			if (itemRenderer == null) {
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
			this.scrollToIndex(this._selectedIndex);
		}
		// restore focus to the container so that the wrong item renderer
		// doesn't respond to keyboard events
		if (this._focusManager != null) {
			this._focusManager.focus = this;
		} else if (this.stage != null) {
			this.stage.focus = this;
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

	private function listView_keyDownHandler(event:KeyboardEvent):Void {
		if (!this._enabled || event.isDefaultPrevented()) {
			return;
		}
		if (event.keyCode == Keyboard.SPACE || event.keyCode == Keyboard.ENTER) {
			if (this._selectedItem != null) {
				var itemRenderer:DisplayObject = null;
				if ((this._selectedItem is String)) {
					itemRenderer = this.stringDataToItemRenderer.get(cast this._selectedItem);
				} else {
					itemRenderer = this.objectDataToItemRenderer.get(this._selectedItem);
				}
				var state:ListViewItemState = null;
				if (itemRenderer != null) {
					state = this.itemRendererToItemState.get(itemRenderer);
				}
				var isTemporary = false;
				if (state == null) {
					// if there is no existing state, use a temporary object
					isTemporary = true;
					state = this.itemStatePool.get();
				}
				this.populateCurrentItemState(this._selectedItem, this._selectedIndex, state, true);
				ListViewEvent.dispatch(this, ListViewEvent.ITEM_TRIGGER, state);
				if (isTemporary) {
					this.itemStatePool.release(state);
				}
			}
		}
	}
}

private class ItemRendererStorage {
	public function new(?id:String, ?recycler:DisplayObjectRecycler<Dynamic, ListViewItemState, DisplayObject>) {
		this.id = id;
		this.itemRendererRecycler = recycler;
	}

	public var id:String;
	public var oldItemRendererRecycler:DisplayObjectRecycler<Dynamic, ListViewItemState, DisplayObject>;
	public var itemRendererRecycler:DisplayObjectRecycler<Dynamic, ListViewItemState, DisplayObject>;
	public var activeItemRenderers:Array<DisplayObject> = [];
	public var inactiveItemRenderers:Array<DisplayObject> = [];
	public var measurements:Measurements;
}

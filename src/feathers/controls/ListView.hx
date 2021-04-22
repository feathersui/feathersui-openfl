/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

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
import feathers.core.IIndexSelector;
import feathers.core.InvalidationFlag;
import feathers.core.ITextControl;
import feathers.core.IUIControl;
import feathers.data.IFlatCollection;
import feathers.data.ListViewItemState;
import feathers.events.FeathersEvent;
import feathers.events.FlatCollectionEvent;
import feathers.events.ListViewEvent;
import feathers.events.TriggerEvent;
import feathers.layout.ILayout;
import feathers.layout.ILayoutIndexObject;
import feathers.layout.IScrollLayout;
import feathers.layout.IVirtualLayout;
import feathers.layout.Measurements;
import feathers.style.IVariantStyleObject;
import feathers.themes.steel.components.SteelListViewStyles;
import feathers.utils.DisplayObjectRecycler;
import haxe.ds.ObjectMap;
import openfl.display.DisplayObject;
import openfl.errors.IllegalOperationError;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
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
	renderers, and custom layouts.

	Layouts may be, and are highly encouraged to be, _virtual_, meaning that the
	list view is capable of creating a limited number of item renderers to
	display a subset of the data provider that is currently visible, instead of
	creating a renderer for every single item. This allows for optimized
	performance with very large data providers.

	The following example creates a list view, gives it a data provider, tells
	the item renderer how to interpret the data, and listens for when the
	selection changes:

	```hx
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
@:meta(DefaultProperty("dataProvider"))
@defaultXmlProperty("dataProvider")
@:styleContext
class ListView extends BaseScrollContainer implements IIndexSelector implements IDataSelector<Dynamic> {
	/**
		A variant used to style the list view without a border. The variant is
		used by default on mobile.

		The following example uses this variant:

		```hx
		var listView = new ListView();
		listView.variant = ListView.VARIANT_BORDERLESS;
		```

		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final VARIANT_BORDERLESS = "borderless";

	/**
		A variant used to style the list view with a border. This variant is
		used by default on desktop.

		The following example uses this variant:

		```hx
		var listView = new ListView();
		listView.variant = ListView.VARIANT_BORDER;
		```

		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final VARIANT_BORDER = "border";

	/**
		The variant used to style the list view's item renderers in a theme.

		To override this default variant, set the
		`ListView.customItemRendererVariant` property.

		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@see `ListView.customItemRendererVariant`

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_ITEM_RENDERER = "listView_itemRenderer";

	private static final INVALIDATION_FLAG_ITEM_RENDERER_FACTORY = InvalidationFlag.CUSTOM("itemRendererFactory");

	private static function defaultUpdateItemRenderer(itemRenderer:DisplayObject, state:ListViewItemState):Void {
		if (Std.is(itemRenderer, ITextControl)) {
			var textControl = cast(itemRenderer, ITextControl);
			textControl.text = state.text;
		}
	}

	private static function defaultResetItemRenderer(itemRenderer:DisplayObject, state:ListViewItemState):Void {
		if (Std.is(itemRenderer, ITextControl)) {
			var textControl = cast(itemRenderer, ITextControl);
			textControl.text = null;
		}
	}

	/**
		Creates a new `ListView` object.

		@since 1.0.0
	**/
	public function new(?dataProvider:IFlatCollection<Dynamic>) {
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
	}

	private var listViewPort:AdvancedLayoutViewPort;

	override private function get_focusEnabled():Bool {
		return (this._selectable || this.maxScrollY != this.minScrollY || this.maxScrollX != this.minScrollX)
			&& this._enabled
			&& this._focusEnabled;
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

		```hx
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
		return this._dataProvider;
	}

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
		return this._selectedIndex;
	}

	private var _allowMultipleSelection:Bool = false;

	/**
		Determines if multiple items may be selected at the same time. Has no
		effect if `selectable` is `false`.

		In the following example, multiple selection is enabled:

		```hx
		listView.allowMultipleSelection = true;
		```

		@see `ListView.selectable`
		@see `ListView.selectedIndices`
		@see `ListView.selectedItems`

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

		@see `ListView.allowMultipleSelection`
		@see `ListView.selectedItems`

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

		@see `ListView.allowMultipleSelection`
		@see `ListView.selectedIndices`

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
		The layout algorithm used to position and size the list view's items.

		By default, if no layout is provided by the time that the list view
		initializes, a default layout that displays items vertically will be
		created.

		The following example tells the list view to use a horizontal layout:

		```hx
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

		@since 1.0.0
	**/
	@:style
	public var customItemRendererVariant:String = null;

	/**
		Manages item renderers used by the list view.

		In the following example, the list view uses a custom item renderer
		class:

		```hx
		listView.itemRendererRecycler = DisplayObjectRecycler.withClass(CustomItemRenderer);
		```

		@since 1.0.0
	**/
	@:flash.property
	public var itemRendererRecycler(get, set):DisplayObjectRecycler<Dynamic, ListViewItemState, DisplayObject>;

	private function get_itemRendererRecycler():DisplayObjectRecycler<Dynamic, ListViewItemState, DisplayObject> {
		return this._defaultStorage.itemRendererRecycler;
	}

	private function set_itemRendererRecycler(value:DisplayObjectRecycler<Dynamic, ListViewItemState, DisplayObject>):DisplayObjectRecycler<Dynamic,
		ListViewItemState, DisplayObject> {
		if (this._defaultStorage.itemRendererRecycler == value) {
			return this._defaultStorage.itemRendererRecycler;
		}
		this._defaultStorage.oldItemRendererRecycler = this._defaultStorage.itemRendererRecycler;
		this._defaultStorage.itemRendererRecycler = value;
		this._defaultStorage.measurements = null;
		this.setInvalid(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		return this._defaultStorage.itemRendererRecycler;
	}

	private var _recyclerMap:Map<String, DisplayObjectRecycler<Dynamic, ListViewItemState, DisplayObject>> = null;

	private var _itemRendererRecyclerIDFunction:(state:ListViewItemState) -> String;

	/**
		When a list view requires multiple item renderer types, this function is
		used to determine which type of item renderer is required for a specific
		item. Returns the ID of the item renderer recycler to use for the item,
		or `null` if the default `itemRendererRecycler` should be used.

		The following example provides an `itemRendererRecyclerIDFunction`:

		```hx
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
	@:flash.property
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
	private var dataToItemRenderer = new ObjectMap<Dynamic, DisplayObject>();
	private var itemRendererToItemState = new ObjectMap<DisplayObject, ListViewItemState>();
	private var itemStatePool = new ObjectPool(() -> new ListViewItemState());
	private var _unrenderedData:Array<Dynamic> = [];
	private var _virtualCache:Array<Dynamic> = [];
	private var _visibleIndices:VirtualLayoutRange = new VirtualLayoutRange(0, 0);

	private var _selectable:Bool = true;

	/**
		Determines if items in the list view may be selected. By default only a
		single item may be selected at any given time. In other words, if item
		_A_ is already selected, and the user selects item _B_, item _A_ will be
		deselected automatically.

		The following example disables selection of items in the list view:

		```hx
		listView.selectable = false;
		```

		@default true

		@see `ListView.selectedItem`
		@see `ListView.selectedIndex`
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

	private var _virtualLayout:Bool = true;

	/**
		Indicates if the list view's layout is allowed to virtualize items or
		not.

		The following example disables virtual layouts:

		```hx
		listView.virtualLayout = false;
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

	/**
		Indicates if selection is changed with `MouseEvent.CLICK` or
		`TouchEvent.TOUCH_TAP` when the item renderer does not implement the
		`IToggle` interface. If set to `false`, all item renderers must control
		their own selection manually (not only ones that implement `IToggle`).

		The following example disables pointer selection:

		```hx
		listView.pointerSelectionEnabled = false;
		```

		@since 1.0.0
	**/
	public var pointerSelectionEnabled:Bool = true;

	private var _pendingScrollIndex:Int = -1;
	private var _pendingScrollDuration:Null<Float> = null;

	private var _ignoreSelectionChange = false;
	private var _ignoreLayoutChanges = false;

	/**
		Converts an item to text to display within list view. By default, the
		`toString()` method is called to convert an item to text. This method
		may be replaced to provide custom text.

		For example, consider the following item:

		```hx
		{ text: "Example Item" }
		```

		If the `ListView` should display the text "Example Item", a custom
		implementation of `itemToText()` might look like this:

		```hx
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
		return this.dataToItemRenderer.get(item);
	}

	/**
		Returns the current item from the data provider that is rendered by a
		specific item renderer.

		@since 1.0.0
	**/
	public function itemRendererToItem(itemRenderer:DisplayObject):Dynamic {
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
		return this.dataToItemRenderer.get(item);
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

		To clear a recycler, pass in `null` for the ID.

		@see `ListView.itemRendererRecyclerIDFunction`
		@see `ListView.getItemRendererRecycler()`

		@since 1.0.0
	**/
	public function setItemRendererRecycler(id:String, recycler:DisplayObjectRecycler<Dynamic, ListViewItemState, DisplayObject>):Void {
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

	private function initializeListViewTheme():Void {
		SteelListViewStyles.initialize();
	}

	private var _layoutItems:Array<DisplayObject> = [];

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
				this._virtualCache.resize(0);
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

		super.update();

		this._previousCustomItemRendererVariant = this.customItemRendererVariant;

		this.handlePendingScroll();
	}

	override private function refreshScrollerValues():Void {
		super.refreshScrollerValues();
		if (Std.is(this.layout, IScrollLayout)) {
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
	}

	private function refreshItemRenderers(items:Array<DisplayObject>):Void {
		this._layoutItems = items;

		if (this._defaultStorage.itemRendererRecycler.update == null) {
			this._defaultStorage.itemRendererRecycler.update = defaultUpdateItemRenderer;
			if (this._defaultStorage.itemRendererRecycler.reset == null) {
				this._defaultStorage.itemRendererRecycler.reset = defaultResetItemRenderer;
			}
		}
		if (this._additionalStorage != null) {
			for (i in 0...this._additionalStorage.length) {
				var storage = this._additionalStorage[i];
				if (storage.itemRendererRecycler.update == null) {
					storage.itemRendererRecycler.update = defaultUpdateItemRenderer;
					if (storage.itemRendererRecycler.reset == null) {
						storage.itemRendererRecycler.reset = defaultResetItemRenderer;
					}
				}
			}
		}

		var itemRendererInvalid = this.isInvalid(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
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
		var recycler = storage.oldItemRendererRecycler != null ? storage.oldItemRendererRecycler : storage.itemRendererRecycler;
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
			this.dataToItemRenderer.remove(item);
			itemRenderer.removeEventListener(TriggerEvent.TRIGGER, listView_itemRenderer_triggerHandler);
			itemRenderer.removeEventListener(MouseEvent.CLICK, listView_itemRenderer_clickHandler);
			itemRenderer.removeEventListener(TouchEvent.TOUCH_TAP, listView_itemRenderer_touchTapHandler);
			itemRenderer.removeEventListener(Event.CHANGE, listView_itemRenderer_changeHandler);
			state.owner = this;
			state.data = item;
			state.index = -1;
			state.selected = false;
			state.enabled = true;
			state.text = null;
			var oldIgnoreSelectionChange = this._ignoreSelectionChange;
			this._ignoreSelectionChange = true;
			if (recycler != null && recycler.reset != null) {
				recycler.reset(itemRenderer, state);
			}
			this._ignoreSelectionChange = oldIgnoreSelectionChange;
			this.refreshItemRendererProperties(itemRenderer, state);
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
		storage.inactiveItemRenderers.resize(0);
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

		if (this._virtualLayout && Std.is(this.layout, IVirtualLayout)) {
			var virtualLayout = cast(this.layout, IVirtualLayout);
			var oldIgnoreLayoutChanges = this._ignoreLayoutChanges;
			this._ignoreLayoutChanges = true;
			virtualLayout.virtualCache = this._virtualCache;
			this._ignoreLayoutChanges = oldIgnoreLayoutChanges;
			virtualLayout.getVisibleIndices(this._dataProvider.length, this.listViewPort.visibleWidth, this.listViewPort.visibleHeight, this._visibleIndices);
		} else {
			this._visibleIndices.start = 0;
			this._visibleIndices.end = this._dataProvider.length - 1;
		}
		for (i in this._visibleIndices.start...this._visibleIndices.end + 1) {
			var item = this._dataProvider.get(i);
			var itemRenderer = this.dataToItemRenderer.get(item);
			if (itemRenderer != null) {
				var state = this.itemRendererToItemState.get(itemRenderer);
				this.populateCurrentItemState(item, i, state);
				var oldRecyclerID = state.recyclerID;
				var storage = this.itemStateToStorage(state);
				if (storage.id != oldRecyclerID) {
					this._unrenderedData.push(item);
					continue;
				}
				this.updateItemRenderer(itemRenderer, state, storage);
				// if this item renderer used to be the typical layout item, but
				// it isn't anymore, it may have been set invisible
				itemRenderer.visible = true;
				this._layoutItems[i] = itemRenderer;
				var removed = storage.inactiveItemRenderers.remove(itemRenderer);
				if (!removed) {
					throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: item renderer map contains bad data. This may be caused by duplicate items in the data provider, which is not allowed.');
				}
				storage.activeItemRenderers.push(itemRenderer);
			} else {
				this._unrenderedData.push(item);
			}
		}
	}

	private function populateCurrentItemState(item:Dynamic, index:Int, state:ListViewItemState):Void {
		state.owner = this;
		state.data = item;
		state.index = index;
		state.selected = this._selectedIndices.indexOf(index) != -1;
		state.enabled = this._enabled;
		state.text = itemToText(item);
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
		if (Std.is(itemRenderer, IUIControl)) {
			var uiControl = cast(itemRenderer, IUIControl);
			uiControl.enabled = state.enabled;
		}
		if (Std.is(itemRenderer, IDataRenderer)) {
			var dataRenderer = cast(itemRenderer, IDataRenderer);
			// if the renderer is an IDataRenderer, this cannot be overridden
			dataRenderer.data = state.data;
		}
		if (Std.is(itemRenderer, IListViewItemRenderer)) {
			var listRenderer = cast(itemRenderer, IListViewItemRenderer);
			listRenderer.index = state.index;
		}
		if (Std.is(itemRenderer, ILayoutIndexObject)) {
			var layoutIndexObject = cast(itemRenderer, ILayoutIndexObject);
			layoutIndexObject.layoutIndex = state.index;
		}
		if (Std.is(itemRenderer, IToggle)) {
			var toggle = cast(itemRenderer, IToggle);
			// if the renderer is an IToggle, this cannot be overridden
			toggle.selected = state.selected;
		}
		this._ignoreSelectionChange = oldIgnoreSelectionChange;
	}

	private function renderUnrenderedData():Void {
		for (item in this._unrenderedData) {
			var index = this._dataProvider.indexOf(item);
			var state = this.itemStatePool.get();
			this.populateCurrentItemState(item, index, state);
			var itemRenderer = this.createItemRenderer(state);
			itemRenderer.visible = true;
			this.listViewPort.addChild(itemRenderer);
			this._layoutItems[index] = itemRenderer;
		}
		this._unrenderedData.resize(0);
	}

	private function createItemRenderer(state:ListViewItemState):DisplayObject {
		var storage = this.itemStateToStorage(state);
		var itemRenderer:DisplayObject = null;
		if (storage.inactiveItemRenderers.length == 0) {
			itemRenderer = storage.itemRendererRecycler.create();
			if (this.customItemRendererVariant != null && Std.is(itemRenderer, IVariantStyleObject)) {
				var variantItemRenderer = cast(itemRenderer, IVariantStyleObject);
				var variant = this.customItemRendererVariant != null ? this.customItemRendererVariant : CHILD_VARIANT_ITEM_RENDERER;
				if (variantItemRenderer.variant == null) {
					variantItemRenderer.variant = variant;
				}
			}
			if (storage.measurements == null) {
				storage.measurements = new Measurements(itemRenderer);
			}
			// for consistency, initialize before passing to the recycler's
			// update function. plus, this ensures that custom item renderers
			// correctly handle property changes in update() instead of trying
			// to access them too early in initialize().
			if (Std.is(itemRenderer, IUIControl)) {
				cast(itemRenderer, IUIControl).initializeNow();
			}
		} else {
			itemRenderer = storage.inactiveItemRenderers.shift();
		}
		this.updateItemRenderer(itemRenderer, state, storage);
		if (Std.is(itemRenderer, ITriggerView)) {
			// prefer TriggerEvent.TRIGGER
			itemRenderer.addEventListener(TriggerEvent.TRIGGER, listView_itemRenderer_triggerHandler);
		} else {
			// fall back to these events if TriggerEvent.TRIGGER isn't available
			itemRenderer.addEventListener(MouseEvent.CLICK, listView_itemRenderer_clickHandler);
			#if (openfl >= "9.0.0")
			itemRenderer.addEventListener(TouchEvent.TOUCH_TAP, listView_itemRenderer_touchTapHandler);
			#end
		}
		if (Std.is(itemRenderer, IToggle)) {
			itemRenderer.addEventListener(Event.CHANGE, listView_itemRenderer_changeHandler);
		}
		this.itemRendererToItemState.set(itemRenderer, state);
		this.dataToItemRenderer.set(state.data, itemRenderer);
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
		// the index may have changed, possibily even to -1, if the item was
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
		if (Std.is(this.layout, IScrollLayout)) {
			var scrollLayout = cast(this.layout, IScrollLayout);
			var result = scrollLayout.getNearestScrollPositionForIndex(index, this._dataProvider.length, this.viewPort.visibleWidth,
				this.viewPort.visibleHeight);
			targetX = result.x;
			targetY = result.y;
		} else {
			var item = this._dataProvider.get(index);
			var itemRenderer = this.dataToItemRenderer.get(item);
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
			this.scroller.scrollX = targetX;
			this.scroller.scrollY = targetY;
		} else {
			this.scroller.throwTo(targetX, targetY, duration);
		}
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

	private function listView_itemRenderer_changeHandler(event:Event):Void {
		if (this._ignoreSelectionChange) {
			return;
		}
		// if we get here, the selected property of the renderer changed
		// unexpectedly, and we need to restore its proper state
		this.setInvalid(SELECTION);
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
		if (this._selectedIndex >= event.index) {
			this._selectedIndex++;
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
		if (this._selectedIndex == event.index) {
			this._selectedIndex = -1;
			FeathersEvent.dispatch(this, Event.CHANGE);
		} else if (this._selectedIndex > event.index) {
			this._selectedIndex--;
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
		if (this._selectedIndex == event.index) {
			this._selectedItem = this._dataProvider.get(this._selectedIndex);
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
	}

	private function listView_dataProvider_removeAllHandler(event:FlatCollectionEvent):Void {
		if (this._virtualCache != null) {
			this._virtualCache.resize(0);
		}
		// use the setter
		this.selectedIndex = -1;
	}

	private function listView_dataProvider_resetHandler(event:FlatCollectionEvent):Void {
		if (this._virtualCache != null) {
			this._virtualCache.resize(0);
			this._virtualCache.resize(this._dataProvider.length);
		}
		// use the setter
		this.selectedIndex = -1;
	}

	private function listView_dataProvider_sortChangeHandler(event:FlatCollectionEvent):Void {
		if (this._virtualCache != null) {
			// we don't know exactly which indices have changed, so reset the
			// whole cache.
			this._virtualCache.resize(0);
			this._virtualCache.resize(this._dataProvider.length);
		}
		this.refreshSelectedIndicesAfterFilterOrSort();
	}

	private function listView_dataProvider_filterChangeHandler(event:FlatCollectionEvent):Void {
		if (this._virtualCache != null) {
			// we don't know exactly which indices have changed, so reset the
			// whole cache.
			this._virtualCache.resize(0);
			this._virtualCache.resize(this._dataProvider.length);
		}
		this.refreshSelectedIndicesAfterFilterOrSort();
	}

	private function updateItemRendererForIndex(index:Int):Void {
		var item = this._dataProvider.get(index);
		var itemRenderer = this.dataToItemRenderer.get(item);
		if (itemRenderer == null) {
			// doesn't exist yet, so we need to do a full invalidation
			this.setInvalid(DATA);
			return;
		}
		// in order to display the same item with modified properties, this
		// hack tricks the item renderer into thinking that it has been given
		// a different item to render.
		if (Std.is(itemRenderer, IDataRenderer)) {
			cast(itemRenderer, IDataRenderer).data = null;
		}
		var state = this.itemRendererToItemState.get(itemRenderer);
		this.populateCurrentItemState(item, index, state);
		var storage = this.itemStateToStorage(state);
		this.updateItemRenderer(itemRenderer, state, storage);
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
		event.preventDefault();
		// use the setter
		this.selectedIndex = result;
		if (this._selectedIndex != -1) {
			this.scrollToIndex(this._selectedIndex);
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

	private function listView_keyDownHandler(event:KeyboardEvent):Void {
		if (!this._enabled || event.isDefaultPrevented()) {
			return;
		}
		if (event.keyCode == Keyboard.SPACE || event.keyCode == Keyboard.ENTER) {
			if (this._selectedItem != null) {
				var itemRenderer = this.dataToItemRenderer.get(this._selectedItem);
				var state = this.itemRendererToItemState.get(itemRenderer);
				ListViewEvent.dispatch(this, ListViewEvent.ITEM_TRIGGER, state);
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

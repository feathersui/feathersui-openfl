/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.controls.dataRenderers.IDataRenderer;
import feathers.controls.dataRenderers.IGroupListViewItemRenderer;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.controls.supportClasses.AdvancedLayoutViewPort;
import feathers.controls.supportClasses.BaseScrollContainer;
import feathers.core.IDataSelector;
import feathers.core.IFocusContainer;
import feathers.core.IMeasureObject;
import feathers.core.ITextControl;
import feathers.core.IUIControl;
import feathers.core.InvalidationFlag;
import feathers.data.GroupListViewItemState;
import feathers.data.GroupListViewItemType;
import feathers.data.IHierarchicalCollection;
import feathers.events.FeathersEvent;
import feathers.events.GroupListViewEvent;
import feathers.events.HierarchicalCollectionEvent;
import feathers.events.TriggerEvent;
import feathers.layout.IKeyboardNavigationLayout;
import feathers.layout.ILayout;
import feathers.layout.ILayoutIndexObject;
import feathers.layout.IScrollLayout;
import feathers.layout.IVirtualLayout;
import feathers.layout.Measurements;
import feathers.style.IVariantStyleObject;
import feathers.themes.steel.components.SteelGroupListViewStyles;
import feathers.utils.AbstractDisplayObjectRecycler;
import feathers.utils.DisplayObjectRecycler;
import haxe.ds.ObjectMap;
import openfl.display.DisplayObject;
import openfl.errors.ArgumentError;
import openfl.errors.IllegalOperationError;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
import openfl.ui.Keyboard;
#if (openfl >= "9.1.0")
import openfl.utils.ObjectPool;
#else
import openfl._internal.utils.ObjectPool;
#end
#if air
import openfl.ui.Multitouch;
#end

/**
	Displays a list of items divided into groups or sections. Accepts a
	hierarchical tree of items, similar to `TreeView`, but limits the display to
	two levels of hierarchy at most. Supports scrolling, custom item renderers,
	and custom layouts.

	The following example creates a group list, gives it a data provider, tells
	the item renderer how to interpret the data, and listens for when the
	selection changes:

	```haxe
	var groupListView = new GroupListView();

	groupListView.dataProvider = new TreeCollection([
		new TreeNode({text: "Group A"}, [
			new TreeNode({text: "Node A1"}),
			new TreeNode({text: "Node A2"}),
			new TreeNode({text: "Node A3"}),
			new TreeNode({text: "Node A4"})
		]),
		new TreeNode({text: "Group B"}, [
			new TreeNode({text: "Node B1"}),
			new TreeNode({text: "Node B2"}),
			new TreeNode({text: "Node B3"})
		]),
		new TreeNode({text: "Group C"}, [
			new TreeNode({text: "Node C1"})
		])
	]);

	groupListView.itemToText = (item:TreeNode<Dynamic>) -> {
		return item.data.text;
	};

	groupListView.addEventListener(Event.CHANGE, (event:Event) -> {
		var groupListView = cast(event.currentTarget, GroupListView);
		trace("GroupListView changed: " + groupListView.selectedLocation + " " + groupListView.selectedItem.text);
	});

	this.addChild(groupListView);
	```

	@event openfl.events.Event.CHANGE Dispatched when either
	`GroupListView.selectedItem` or `GroupListView.selectedLocation` changes.

	@event feathers.events.GroupListViewEvent.ITEM_TRIGGER Dispatched when the user
	taps or clicks an item renderer in the list view. The pointer must remain
	within the bounds of the item renderer on release, and the list view cannot
	scroll before release, or the gesture will be ignored.

	@see [Tutorial: How to use the GroupListView component](https://feathersui.com/learn/haxe-openfl/group-list-view/)

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
@:event(feathers.events.GroupListViewEvent.ITEM_TRIGGER)
@:access(feathers.data.GroupListViewItemState)
@defaultXmlProperty("dataProvider")
@:styleContext
class GroupListView extends BaseScrollContainer implements IDataSelector<Dynamic> implements IFocusContainer {
	/**
		The variant used to style the group headers in a theme.

		To override this default variant, set the
		`GroupListView.customHeaderRendererVariant` property.

		@see `GroupListView.customHeaderRendererVariant`
		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_HEADER_RENDERER = "groupListView_headerRenderer";

	/**
		The variant used to style the group list view's item renderers in a
		theme.

		To override this default variant, set the
		`GroupListView.customItemRendererVariant` property.

		@see `GroupListView.customItemRendererVariant`
		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_ITEM_RENDERER = "groupListView_itemRenderer";

	/**
		A variant used to style the group list view without a border. The
		variant is used by default on mobile.

		The following example uses this variant:

		```haxe
		var groupListView = new GroupListView();
		groupListView.variant = GroupListView.VARIANT_BORDERLESS;
		```

		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final VARIANT_BORDERLESS = "borderless";

	/**
		A variant used to style the group list view with a border. This variant
		is used by default on desktop.

		The following example uses this variant:

		```haxe
		var groupListView = new GroupListView();
		groupListView.variant = GroupListView.VARIANT_BORDER;
		```

		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final VARIANT_BORDER = "border";

	private static final INVALIDATION_FLAG_ITEM_RENDERER_FACTORY = InvalidationFlag.CUSTOM("itemRendererFactory");
	private static final INVALIDATION_FLAG_HEADER_RENDERER_FACTORY = InvalidationFlag.CUSTOM("headerRendererFactory");

	private static final RESET_ITEM_STATE = new GroupListViewItemState();

	private static function defaultUpdateItemRenderer(itemRenderer:DisplayObject, state:GroupListViewItemState):Void {
		if ((itemRenderer is ITextControl)) {
			var textControl = cast(itemRenderer, ITextControl);
			textControl.text = state.text;
		}
	}

	private static function defaultResetItemRenderer(itemRenderer:DisplayObject, state:GroupListViewItemState):Void {
		if ((itemRenderer is ITextControl)) {
			var textControl = cast(itemRenderer, ITextControl);
			textControl.text = null;
		}
	}

	/**
		Creates a new `GroupListView` object.

		@since 1.0.0
	**/
	public function new(?dataProvider:IHierarchicalCollection<Dynamic>, ?changeListener:(Event) -> Void) {
		initializeGroupListViewTheme();

		super();

		this.dataProvider = dataProvider;

		this.tabEnabled = true;
		this.focusRect = null;

		if (this.viewPort == null) {
			this.groupViewPort = new AdvancedLayoutViewPort();
			this.addChild(this.groupViewPort);
			this.viewPort = this.groupViewPort;
		}

		this.addEventListener(KeyboardEvent.KEY_DOWN, groupListView_keyDownHandler);

		if (changeListener != null) {
			this.addEventListener(Event.CHANGE, changeListener);
		}
	}

	private var groupViewPort:AdvancedLayoutViewPort;

	@:getter(tabEnabled)
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

	private var _dataProvider:IHierarchicalCollection<Dynamic>;

	/**
		The collection of data displayed by the group list view.

		Items in the collection must be class instances or anonymous structures.
		Do not add primitive values (such as strings, booleans, or numeric
		values) directly to the collection.

		Additionally, all items in the collection must be unique object
		instances. Do not add the same instance to the collection more than
		once because a runtime exception will be thrown.

		The following example passes in a data provider and tells the item
		renderer how to interpret the data:

		```haxe
		groupListView.dataProvider = new TreeCollection([
			new TreeNode({text: "Group A"}, [
				new TreeNode({text: "Node A1"}),
				new TreeNode({text: "Node A2"}),
				new TreeNode({text: "Node A3"}),
				new TreeNode({text: "Node A4"})
			]),
			new TreeNode({text: "Group B"}, [
				new TreeNode({text: "Node B1"}),
				new TreeNode({text: "Node B2"}),
				new TreeNode({text: "Node B3"})
			]),
			new TreeNode({text: "Group C"}, [
				new TreeNode({text: "Node C1"})
			])
		]);

		groupListView.itemToText = (item:Dynamic) -> {
			return item.text;
		};
		```

		@default null

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
		#if hl
		this._virtualCache.splice(0, this._virtualCache.length);
		#else
		this._virtualCache.resize(0);
		#end
		if (this._dataProvider != null) {
			this._dataProvider.removeEventListener(Event.CHANGE, groupListView_dataProvider_changeHandler);
			this._dataProvider.removeEventListener(HierarchicalCollectionEvent.ADD_ITEM, groupListView_dataProvider_addItemHandler);
			this._dataProvider.removeEventListener(HierarchicalCollectionEvent.REMOVE_ITEM, groupListView_dataProvider_removeItemHandler);
			this._dataProvider.removeEventListener(HierarchicalCollectionEvent.REPLACE_ITEM, groupListView_dataProvider_replaceItemHandler);
			this._dataProvider.removeEventListener(HierarchicalCollectionEvent.REMOVE_ALL, groupListView_dataProvider_removeAllHandler);
			this._dataProvider.removeEventListener(HierarchicalCollectionEvent.RESET, groupListView_dataProvider_resetHandler);
			this._dataProvider.removeEventListener(HierarchicalCollectionEvent.UPDATE_ITEM, groupListView_dataProvider_updateItemHandler);
			this._dataProvider.removeEventListener(HierarchicalCollectionEvent.UPDATE_ALL, groupListView_dataProvider_updateAllHandler);
		}
		this._dataProvider = value;
		if (this._dataProvider != null) {
			var newSize = this.calculateTotalLayoutCount([]);
			this._virtualCache.resize(newSize);
			this._dataProvider.addEventListener(Event.CHANGE, groupListView_dataProvider_changeHandler);
			this._dataProvider.addEventListener(HierarchicalCollectionEvent.ADD_ITEM, groupListView_dataProvider_addItemHandler);
			this._dataProvider.addEventListener(HierarchicalCollectionEvent.REMOVE_ITEM, groupListView_dataProvider_removeItemHandler);
			this._dataProvider.addEventListener(HierarchicalCollectionEvent.REPLACE_ITEM, groupListView_dataProvider_replaceItemHandler);
			this._dataProvider.addEventListener(HierarchicalCollectionEvent.REMOVE_ALL, groupListView_dataProvider_removeAllHandler);
			this._dataProvider.addEventListener(HierarchicalCollectionEvent.RESET, groupListView_dataProvider_resetHandler);
			this._dataProvider.addEventListener(HierarchicalCollectionEvent.UPDATE_ITEM, groupListView_dataProvider_updateItemHandler);
			this._dataProvider.addEventListener(HierarchicalCollectionEvent.UPDATE_ALL, groupListView_dataProvider_updateAllHandler);
		}

		// reset the scroll position because this is a drastic change and
		// the data is probably completely different
		this.scrollX = 0.0;
		this.scrollY = 0.0;

		// clear the selection for the same reason
		this.selectedLocation = null;

		this.setInvalid(DATA);
		return this._dataProvider;
	}

	private var _selectedLocation:Array<Int> = null;

	/**
		The currently selected location. Returns `null` if no location is
		selected.

		The following example selects a specific location:

		```haxe
		groupListView.selectedLocation = [2, 0];
		```

		The following example clears the currently selected location:

		```haxe
		groupListView.selectedLocation = null;
		```

		The following example listens for when the selection changes, and it
		prints the new selected location to the debug console:

		```haxe
		var groupListView = new GroupListView();
		function changeHandler(event:Event):Void
		{
			var groupListView = cast(event.currentTarget, GroupListView);
			trace("selection change: " + groupListView.selectedLocation);
		}
		groupListView.addEventListener(Event.CHANGE, changeHandler);
		```

		@default null

		@since 1.0.0
	**/
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
		if (value != null && value.length != 2) {
			throw new ArgumentError("GroupListView selectedLocation must have a length of 2");
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
		The layout algorithm used to position and size the group list view's
		items.

		By default, if no layout is provided by the time that the group list
		view initializes, a default layout that displays items vertically will
		be created.

		The following example tells the group list view to use a horizontal
		layout:

		```haxe
		var layout = new HorizontalListLayout();
		layout.gap = 20.0;
		layout.padding = 20.0;
		groupListView.layout = layout;
		```

		@since 1.0.0
	**/
	@:style
	public var layout:ILayout = null;

	private var _previousCustomHeaderRendererVariant:String = null;

	/**
		A custom variant to set on all header renderers, instead of
		`GroupListView.CHILD_VARIANT_HEADER_RENDERER`.

		The `customHeaderRendererVariant` will be not be used if the result of
		`headerRendererRecycler.create()` already has a variant set.

		@see `GroupListView.CHILD_VARIANT_HEADER_RENDERER`
		@see `feathers.style.IVariantStyleObject.variant`

		@since 1.0.0
	**/
	@:style
	public var customHeaderRendererVariant:String = null;

	private var _previousCustomItemRendererVariant:String = null;

	/**
		A custom variant to set on all item renderers, instead of
		`GroupListView.CHILD_VARIANT_ITEM_RENDERER`.

		The `customItemRendererVariant` will be not be used if the result of
		`itemRendererRecycler.create()` already has a variant set.

		@see `GroupListView.CHILD_VARIANT_ITEM_RENDERER`
		@see `feathers.style.IVariantStyleObject.variant`

		@since 1.0.0
	**/
	@:style
	public var customItemRendererVariant:String = null;

	/**
		Manages item renderers used by the group list view.

		In the following example, the group list view uses a custom item
		renderer class:

		```haxe
		groupListView.itemRendererRecycler = DisplayObjectRecycler.withClass(CustomItemRenderer);
		```

		@since 1.0.0
	**/
	public var itemRendererRecycler(get, set):AbstractDisplayObjectRecycler<Dynamic, GroupListViewItemState, DisplayObject>;

	private function get_itemRendererRecycler():AbstractDisplayObjectRecycler<Dynamic, GroupListViewItemState, DisplayObject> {
		return this._defaultItemStorage.itemRendererRecycler;
	}

	private function set_itemRendererRecycler(value:AbstractDisplayObjectRecycler<Dynamic, GroupListViewItemState,
		DisplayObject>):AbstractDisplayObjectRecycler<Dynamic, GroupListViewItemState, DisplayObject> {
		if (this._defaultItemStorage.itemRendererRecycler == value) {
			return this._defaultItemStorage.itemRendererRecycler;
		}
		this._defaultItemStorage.oldItemRendererRecycler = this._defaultItemStorage.itemRendererRecycler;
		this._defaultItemStorage.itemRendererRecycler = value;
		this._defaultItemStorage.measurements = null;
		this.setInvalid(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		return this._defaultItemStorage.itemRendererRecycler;
	}

	/**
		Manages header renderers used by the group list view.

		In the following example, the group list view uses a custom header
		renderer class:

		```haxe
		groupListView.headerRendererRecycler = DisplayObjectRecycler.withClass(CustomHeaderRenderer);
		```

		@default null

		@since 1.0.0
	**/
	public var headerRendererRecycler(get, set):AbstractDisplayObjectRecycler<Dynamic, GroupListViewItemState, DisplayObject>;

	private function get_headerRendererRecycler():AbstractDisplayObjectRecycler<Dynamic, GroupListViewItemState, DisplayObject> {
		return this._defaultHeaderStorage.itemRendererRecycler;
	}

	private function set_headerRendererRecycler(value:AbstractDisplayObjectRecycler<Dynamic, GroupListViewItemState,
		DisplayObject>):AbstractDisplayObjectRecycler<Dynamic, GroupListViewItemState, DisplayObject> {
		if (this._defaultHeaderStorage.itemRendererRecycler == value) {
			return this._defaultHeaderStorage.itemRendererRecycler;
		}
		this._defaultHeaderStorage.oldItemRendererRecycler = this._defaultHeaderStorage.itemRendererRecycler;
		this._defaultHeaderStorage.itemRendererRecycler = value;
		this.setInvalid(INVALIDATION_FLAG_HEADER_RENDERER_FACTORY);
		return this._defaultHeaderStorage.itemRendererRecycler;
	}

	private var _itemRendererRecyclerMap:Map<String, DisplayObjectRecycler<Dynamic, GroupListViewItemState, DisplayObject>> = null;

	private var _headerRendererRecyclerMap:Map<String, DisplayObjectRecycler<Dynamic, GroupListViewItemState, DisplayObject>> = null;

	private var _itemRendererRecyclerIDFunction:(state:GroupListViewItemState) -> String;

	/**
		When a list view requires multiple item renderer types, this function is
		used to determine which type of item renderer is required for a specific
		item. Returns the ID of the item renderer recycler to use for the item,
		or `null` if the default `itemRendererRecycler` should be used.

		The following example provides an `itemRendererRecyclerIDFunction`:

		```haxe
		var regularItemRecycler = DisplayObjectRecycler.withClass(ItemRenderer);
		var firstItemRecycler = DisplayObjectRecycler.withClass(MyCustomItemRenderer);

		groupListView.setItemRendererRecycler("regular-item", regularItemRecycler);
		groupListView.setItemRendererRecycler("first-item", firstItemRecycler);

		groupListView.itemRendererRecyclerIDFunction = function(state:ListViewItemState):String {
			if(state.index == 0) {
				return "first-item";
			}
			return "regular-item";
		};
		```

		@default null

		@see `GroupListView.setItemRendererRecycler()`
		@see `GroupListView.itemRendererRecycler

		@since 1.0.0
	**/
	public var itemRendererRecyclerIDFunction(get, set):(state:GroupListViewItemState) -> String;

	private function get_itemRendererRecyclerIDFunction():(state:GroupListViewItemState) -> String {
		return this._itemRendererRecyclerIDFunction;
	}

	private function set_itemRendererRecyclerIDFunction(value:(state:GroupListViewItemState) -> String):(state:GroupListViewItemState) -> String {
		if (this._itemRendererRecyclerIDFunction == value) {
			return this._itemRendererRecyclerIDFunction;
		}
		this._itemRendererRecyclerIDFunction = value;
		if (this._itemRendererRecyclerIDFunction != null && this._additionalItemStorage == null) {
			this._additionalItemStorage = [];
		}
		this.setInvalid(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		return this._itemRendererRecyclerIDFunction;
	}

	private var _headerRendererRecyclerIDFunction:(state:GroupListViewItemState) -> String;

	/**
		When a list view requires multiple header renderer types, this function
		is used to determine which type of header renderer is required for a
		specific header. Returns the ID of the header renderer recycler to use
		for the header, or `null` if the default `headerRendererRecycler` should
		be used.

		The following example provides an `headerRendererRecyclerIDFunction`:

		```haxe
		var regularHeaderRecycler = DisplayObjectRecycler.withClass(ItemRenderer);
		var firstHeaderRecycler = DisplayObjectRecycler.withClass(MyCustomHeaderRenderer);

		groupListView.setHeaderRendererRecycler("regular-header", regularHeaderRecycler);
		groupListView.setHeaderRendererRecycler("first-header", firstHeaderRecycler);

		groupListView.headerRendererRecyclerIDFunction = function(state:GroupListViewItemState):String {
			if(state.location[0] == 0) {
				return "first-header";
			}
			return "regular-header";
		};
		```

		@default null

		@see `GroupListView.setHeaderRendererRecycler()`
		@see `GroupListView.headerRendererRecycler

		@since 1.0.0
	**/
	public var headerRendererRecyclerIDFunction(get, set):(state:GroupListViewItemState) -> String;

	private function get_headerRendererRecyclerIDFunction():(state:GroupListViewItemState) -> String {
		return this._headerRendererRecyclerIDFunction;
	}

	private function set_headerRendererRecyclerIDFunction(value:(state:GroupListViewItemState) -> String):(state:GroupListViewItemState) -> String {
		if (this._headerRendererRecyclerIDFunction == value) {
			return this._headerRendererRecyclerIDFunction;
		}
		this._headerRendererRecyclerIDFunction = value;
		if (this._headerRendererRecyclerIDFunction != null && this._additionalHeaderStorage == null) {
			this._additionalHeaderStorage = [];
		}
		this.setInvalid(INVALIDATION_FLAG_HEADER_RENDERER_FACTORY);
		return this._headerRendererRecyclerIDFunction;
	}

	private var _defaultItemStorage = new ItemRendererStorage(STANDARD, null, DisplayObjectRecycler.withClass(ItemRenderer));
	private var _defaultHeaderStorage = new ItemRendererStorage(HEADER, null, DisplayObjectRecycler.withClass(ItemRenderer));
	private var _additionalItemStorage:Array<ItemRendererStorage> = null;
	private var _additionalHeaderStorage:Array<ItemRendererStorage> = null;
	private var dataToItemRenderer = new ObjectMap<Dynamic, DisplayObject>();
	private var itemRendererToItemState = new ObjectMap<DisplayObject, GroupListViewItemState>();
	private var itemStatePool = new ObjectPool(() -> new GroupListViewItemState());
	private var _unrenderedLocations:Array<Array<Int>> = [];
	private var _unrenderedLayoutIndices:Array<Int> = [];
	private var _virtualCache:Array<Dynamic> = [];
	private var _visibleIndices:VirtualLayoutRange = new VirtualLayoutRange(0, 0);
	private var _tempVisibleIndices:VirtualLayoutRange = new VirtualLayoutRange(0, 0);
	private var _layoutItems:Array<DisplayObject> = [];
	private var _layoutHeaderIndices:Array<Int> = [];

	private var _selectable:Bool = true;

	/**
		Determines if items in the group list view may be selected. By default,
		only a single item may be selected at any given time. In other words, if
		item _A_ is already selected, and the user selects item _B_, item _A_
		will be deselected automatically.

		The following example disables selection of items in the group list
		view:

		```haxe
		groupListView.selectable = false;
		```

		@default true

		@see `GroupListView.selectedItem`
		@see `GroupListView.selectedIndex`
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

	private var _virtualLayout:Bool = true;

	/**
		Indicates if the group list view's layout is allowed to virtualize items
		or not.

		The following example disables virtual layouts:

		```haxe
		groupListView.virtualLayout = false;
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
		groupListView.pointerSelectionEnabled = false;
		```

		@since 1.0.0
	**/
	public var pointerSelectionEnabled:Bool = true;

	private var _ignoreSelectionChange = false;
	private var _ignoreLayoutChanges = false;

	/**
		Converts an item to text to display within group list view. By default,
		the `toString()` method is called to convert an item to text. This
		method may be replaced to provide custom text.

		For example, consider the following item:

		```haxe
		{ text: "Example Item" }
		```

		If the `GroupListView` should display the text "Example Item", a custom
		implementation of `itemToText()` might look like this:

		```haxe
		groupListView.itemToText = (item:Dynamic) -> {
			return item.text;
		};
		```

		@since 1.0.0
	**/
	public dynamic function itemToText(data:Dynamic):String {
		return Std.string(data);
	}

	/**
		Converts an group to text to display within a group list view header. By
		default, the `toString()` method is called to convert an item to text.
		This method may be replaced to provide custom text.

		For example, consider the following item:

		```haxe
		{ text: "Example Section" }
		```

		If the `GroupListView` should display the text "Example Item", a custom
		implementation of `itemToHeaderText()` might look like this:

		```haxe
		groupListView.itemToHeaderText = (item:Dynamic) -> {
			return item.text;
		};
		```

		@since 1.0.0
	**/
	public dynamic function itemToHeaderText(data:Dynamic):String {
		return Std.string(data);
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
		specified location in the data provider. May return `null` if an item
		doesn't currently have an item renderer.

		**Note:** Most list views use "virtual" layouts, which means that only
		the currently-visible subset of items will have an item renderer. As the
		list view scrolls, the items with item renderers will change, and item
		renderers may even be re-used to display different items.

		@since 1.0.0
	**/
	public function locationToItemRenderer(location:Array<Int>):DisplayObject {
		if (this._dataProvider == null || !this.isValidLocation(location)) {
			return null;
		}
		var item = this._dataProvider.get(location);
		return this.dataToItemRenderer.get(item);
	}

	/**
		Returns the item renderer recycler associated with a specific ID.
		Returns `null` if no recycler is associated with the ID.

		@see `GroupListView.itemRendererRecyclerIDFunction`
		@see `GroupListView.setItemRendererRecycler()`

		@since 1.0.0
	**/
	public function getItemRendererRecycler(id:String):DisplayObjectRecycler<Dynamic, GroupListViewItemState, DisplayObject> {
		if (this._itemRendererRecyclerMap == null) {
			return null;
		}
		return this._itemRendererRecyclerMap.get(id);
	}

	/**
		Associates an item renderer recycler with an ID to allow multiple types
		of item renderers may be displayed in the list view. A custom
		`itemRendererRecyclerIDFunction` may be specified to return the ID of
		the recycler to use for a specific item in the data provider.

		To clear a recycler, pass in `null` for the value.

		@see `GroupListView.itemRendererRecyclerIDFunction`
		@see `GroupListView.getItemRendererRecycler()`

		@since 1.0.0
	**/
	public function setItemRendererRecycler(id:String, recycler:AbstractDisplayObjectRecycler<Dynamic, GroupListViewItemState, DisplayObject>):Void {
		if (this._itemRendererRecyclerMap == null) {
			this._itemRendererRecyclerMap = [];
		}
		if (recycler == null) {
			this._itemRendererRecyclerMap.remove(id);
			return;
		}
		this._itemRendererRecyclerMap.set(id, recycler);
		this.setInvalid(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
	}

	/**
		Returns the header renderer recycler associated with a specific ID.
		Returns `null` if no recycler is associated with the ID.

		@see `GroupListView.headerRendererRecyclerIDFunction`
		@see `GroupListView.setHeaderRendererRecycler()`

		@since 1.0.0
	**/
	public function getHeaderRendererRecycler(id:String):DisplayObjectRecycler<Dynamic, GroupListViewItemState, DisplayObject> {
		if (this._headerRendererRecyclerMap == null) {
			return null;
		}
		return this._headerRendererRecyclerMap.get(id);
	}

	/**
		Associates an header renderer recycler with an ID to allow multiple types
		of header renderers may be displayed in the group list view. A custom
		`headerRendererRecyclerIDFunction` may be specified to return the ID of
		the recycler to use for a specific header in the data provider.

		To clear a recycler, pass in `null` for the value.

		@see `GroupListView.headerRendererRecyclerIDFunction`
		@see `GroupListView.getHeaderRendererRecycler()`

		@since 1.0.0
	**/
	public function setHeaderRendererRecycler(id:String, recycler:AbstractDisplayObjectRecycler<Dynamic, GroupListViewItemState, DisplayObject>):Void {
		if (this._headerRendererRecyclerMap == null) {
			this._headerRendererRecyclerMap = [];
		}
		if (recycler == null) {
			this._headerRendererRecyclerMap.remove(id);
			return;
		}
		this._headerRendererRecyclerMap.set(id, recycler);
		this.setInvalid(INVALIDATION_FLAG_HEADER_RENDERER_FACTORY);
	}

	private var _pendingScrollLocation:Array<Int> = null;
	private var _pendingScrollDuration:Null<Float> = null;

	/**
		Scrolls the list view so that the specified item renderer is completely
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

	private function initializeGroupListViewTheme():Void {
		SteelGroupListViewStyles.initialize();
	}

	override private function update():Void {
		var layoutInvalid = this.isInvalid(LAYOUT);
		var stylesInvalid = this.isInvalid(STYLES);

		if (this._previousCustomHeaderRendererVariant != this.customHeaderRendererVariant) {
			this.setInvalidationFlag(INVALIDATION_FLAG_HEADER_RENDERER_FACTORY);
		}
		if (this._previousCustomItemRendererVariant != this.customItemRendererVariant) {
			this.setInvalidationFlag(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		}

		if (layoutInvalid || stylesInvalid) {
			if (this._previousLayout != this.layout) {
				#if hl
				this._virtualCache.splice(0, this._virtualCache.length);
				#else
				this._virtualCache.resize(0);
				#end
				var newSize = this.calculateTotalLayoutCount([]);
				this._virtualCache.resize(newSize);
			}
			this.groupViewPort.layout = this.layout;
			this._previousLayout = this.layout;
		}

		this.groupViewPort.refreshChildren = this.refreshItemRenderers;

		for (flag in this._invalidationFlags.keys()) {
			this.groupViewPort.setInvalid(flag);
		}

		super.update();

		this._previousCustomItemRendererVariant = this.customItemRendererVariant;

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
		this.scroller.snapPositionsX = this.groupViewPort.snapPositionsX;
		this.scroller.snapPositionsY = this.groupViewPort.snapPositionsY;
	}

	override private function needsScrollMeasurement():Bool {
		var oldStart = this._visibleIndices.start;
		var oldEnd = this._visibleIndices.end;
		if (this._virtualLayout && (this.layout is IVirtualLayout)) {
			var virtualLayout = cast(this.layout, IVirtualLayout);
			virtualLayout.scrollX = this.scrollX;
			virtualLayout.scrollY = this.scrollY;
			virtualLayout.getVisibleIndices(this._layoutItems.length, this.groupViewPort.visibleWidth, this.groupViewPort.visibleHeight,
				this._tempVisibleIndices);
		} else {
			this._tempVisibleIndices.start = 0;
			this._tempVisibleIndices.end = this._layoutItems.length - 1;
		}
		return oldStart != this._tempVisibleIndices.start || oldEnd != this._tempVisibleIndices.end;
	}

	private function refreshItemRenderers(items:Array<DisplayObject>):Void {
		this._layoutItems = items;

		if (this._defaultItemStorage.itemRendererRecycler.update == null) {
			this._defaultItemStorage.itemRendererRecycler.update = defaultUpdateItemRenderer;
			if (this._defaultItemStorage.itemRendererRecycler.reset == null) {
				this._defaultItemStorage.itemRendererRecycler.reset = defaultResetItemRenderer;
			}
		}
		if (this._defaultHeaderStorage.itemRendererRecycler.update == null) {
			this._defaultHeaderStorage.itemRendererRecycler.update = defaultUpdateItemRenderer;
			if (this._defaultHeaderStorage.itemRendererRecycler.reset == null) {
				this._defaultHeaderStorage.itemRendererRecycler.reset = defaultResetItemRenderer;
			}
		}
		if (this._additionalItemStorage != null) {
			for (i in 0...this._additionalItemStorage.length) {
				var storage = this._additionalItemStorage[i];
				if (storage.itemRendererRecycler.update == null) {
					storage.itemRendererRecycler.update = defaultUpdateItemRenderer;
					if (storage.itemRendererRecycler.reset == null) {
						storage.itemRendererRecycler.reset = defaultResetItemRenderer;
					}
				}
			}
		}
		if (this._additionalHeaderStorage != null) {
			for (i in 0...this._additionalHeaderStorage.length) {
				var storage = this._additionalHeaderStorage[i];
				if (storage.itemRendererRecycler.update == null) {
					storage.itemRendererRecycler.update = defaultUpdateItemRenderer;
					if (storage.itemRendererRecycler.reset == null) {
						storage.itemRendererRecycler.reset = defaultResetItemRenderer;
					}
				}
			}
		}

		var itemRendererInvalid = this.isInvalid(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		var headerRendererInvalid = this.isInvalid(INVALIDATION_FLAG_HEADER_RENDERER_FACTORY);
		this.refreshInactiveItemRenderers(this._defaultItemStorage, itemRendererInvalid);
		if (this._additionalItemStorage != null) {
			for (i in 0...this._additionalItemStorage.length) {
				var storage = this._additionalItemStorage[i];
				this.refreshInactiveItemRenderers(storage, itemRendererInvalid);
			}
		}
		this.refreshInactiveItemRenderers(this._defaultHeaderStorage, headerRendererInvalid);
		if (this._additionalHeaderStorage != null) {
			for (i in 0...this._additionalHeaderStorage.length) {
				var storage = this._additionalHeaderStorage[i];
				this.refreshInactiveItemRenderers(storage, headerRendererInvalid);
			}
		}
		this.findUnrenderedData();
		this.recoverInactiveItemRenderers(this._defaultItemStorage);
		if (this._additionalItemStorage != null) {
			for (i in 0...this._additionalItemStorage.length) {
				var storage = this._additionalItemStorage[i];
				this.recoverInactiveItemRenderers(storage);
			}
		}
		this.recoverInactiveItemRenderers(this._defaultHeaderStorage);
		if (this._additionalHeaderStorage != null) {
			for (i in 0...this._additionalHeaderStorage.length) {
				var storage = this._additionalHeaderStorage[i];
				this.recoverInactiveItemRenderers(storage);
			}
		}
		this.renderUnrenderedData();
		this.freeInactiveItemRenderers(this._defaultItemStorage);
		if (this._defaultItemStorage.inactiveItemRenderers.length > 0) {
			throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: inactive item renderers should be empty after updating.');
		}
		if (this._additionalItemStorage != null) {
			for (i in 0...this._additionalItemStorage.length) {
				var storage = this._additionalItemStorage[i];
				this.freeInactiveItemRenderers(storage);
				if (storage.inactiveItemRenderers.length > 0) {
					throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: inactive item renderers ${storage.id} should be empty after updating.');
				}
			}
		}
		this.freeInactiveItemRenderers(this._defaultHeaderStorage);
		if (this._defaultHeaderStorage.inactiveItemRenderers.length > 0) {
			throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: inactive header renderers should be empty after updating.');
		}
		if (this._additionalHeaderStorage != null) {
			for (i in 0...this._additionalHeaderStorage.length) {
				var storage = this._additionalHeaderStorage[i];
				this.freeInactiveItemRenderers(storage);
				if (storage.inactiveItemRenderers.length > 0) {
					throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: inactive header renderers ${storage.id} should be empty after updating.');
				}
			}
		}
	}

	private function refreshInactiveItemRenderers(storage:ItemRendererStorage, factoryInvalid:Bool):Void {
		var temp = storage.inactiveItemRenderers;
		storage.inactiveItemRenderers = storage.activeItemRenderers;
		storage.activeItemRenderers = temp;
		if (storage.activeItemRenderers.length > 0) {
			throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: active ${storage.type} renderers should be empty before updating.');
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
				return;
			}
			var item = state.data;
			this.itemRendererToItemState.remove(itemRenderer);
			this.dataToItemRenderer.remove(item);
			if (storage.type == STANDARD) {
				itemRenderer.removeEventListener(TriggerEvent.TRIGGER, groupListView_itemRenderer_triggerHandler);
				itemRenderer.removeEventListener(MouseEvent.CLICK, groupListView_itemRenderer_clickHandler);
				itemRenderer.removeEventListener(TouchEvent.TOUCH_TAP, groupListView_itemRenderer_touchTapHandler);
				itemRenderer.removeEventListener(Event.CHANGE, groupListView_itemRenderer_changeHandler);
			}
			itemRenderer.removeEventListener(Event.RESIZE, groupListView_itemRenderer_resizeHandler);
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
		#if hl
		storage.inactiveItemRenderers.splice(0, storage.inactiveItemRenderers.length);
		#else
		storage.inactiveItemRenderers.resize(0);
		#end
	}

	private function findUnrenderedData():Void {
		// remove all old items, then fill with null
		#if hl
		this._layoutItems.splice(0, this._layoutItems.length);
		#else
		this._layoutItems.resize(0);
		#end
		var newSize = this.calculateTotalLayoutCount([]);
		this._layoutItems.resize(newSize);
		#if hl
		this._layoutHeaderIndices.splice(0, this._layoutHeaderIndices.length);
		#else
		this._layoutHeaderIndices.resize(0);
		#end

		if (this._virtualLayout && (this.layout is IVirtualLayout)) {
			var virtualLayout = cast(this.layout, IVirtualLayout);
			var oldIgnoreLayoutChanges = this._ignoreLayoutChanges;
			this._ignoreLayoutChanges = true;
			virtualLayout.virtualCache = this._virtualCache;
			this._ignoreLayoutChanges = oldIgnoreLayoutChanges;
			virtualLayout.getVisibleIndices(this._layoutItems.length, this.groupViewPort.visibleWidth, this.groupViewPort.visibleHeight, this._visibleIndices);
		} else {
			this._visibleIndices.start = 0;
			this._visibleIndices.end = this._layoutItems.length - 1;
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
				this._layoutItems[layoutIndex] = null;
				if (location.length == 1) {
					this._layoutHeaderIndices.push(layoutIndex);
				}
			} else {
				this.findItemRenderer(item, location.copy(), layoutIndex);
			}
			layoutIndex++;
			if (location.length == 1 && this._dataProvider.isBranch(item)) {
				layoutIndex = this.findUnrenderedDataForLocation(location, layoutIndex);
			}
			location.pop();
		}
		return layoutIndex;
	}

	private function findItemRenderer(item:Dynamic, location:Array<Int>, layoutIndex:Int):Void {
		var itemRenderer = this.dataToItemRenderer.get(item);
		if (itemRenderer == null) {
			this._unrenderedLocations.push(location);
			this._unrenderedLayoutIndices.push(layoutIndex);
			return;
		}
		var type = location.length == 1 ? HEADER : STANDARD;
		var state = this.itemRendererToItemState.get(itemRenderer);
		this.populateCurrentItemState(item, type, location, layoutIndex, state);
		var oldRecyclerID = state.recyclerID;
		var storage = this.itemStateToStorage(state);
		if (storage.id != oldRecyclerID) {
			this._unrenderedLocations.push(location);
			this._unrenderedLayoutIndices.push(layoutIndex);
			return;
		}
		this.updateItemRenderer(itemRenderer, state, storage);
		// if this item renderer used to be the typical layout item, but
		// it isn't anymore, it may have been set invisible
		itemRenderer.visible = true;
		this._layoutItems[layoutIndex] = itemRenderer;
		if (state.type == HEADER) {
			this._layoutHeaderIndices.push(layoutIndex);
		}
		var removed = storage.inactiveItemRenderers.remove(itemRenderer);
		if (!removed) {
			throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: item renderer map contains bad data for item at location ${location}. This may be caused by duplicate items in the data provider, which is not allowed.');
		}
		storage.activeItemRenderers.push(itemRenderer);
	}

	private function renderUnrenderedData():Void {
		for (location in this._unrenderedLocations) {
			var item = this._dataProvider.get(location);
			var type = location.length == 1 ? HEADER : STANDARD;
			var layoutIndex = this._unrenderedLayoutIndices.shift();
			var state = this.itemStatePool.get();
			this.populateCurrentItemState(item, type, location, layoutIndex, state);
			var itemRenderer = this.createItemRenderer(state);
			itemRenderer.visible = true;
			this.groupViewPort.addChild(itemRenderer);
			this._layoutItems[layoutIndex] = itemRenderer;
			if (type == HEADER) {
				this._layoutHeaderIndices.push(layoutIndex);
			}
		}
		#if hl
		this._unrenderedLocations.splice(0, this._unrenderedLocations.length);
		#else
		this._unrenderedLocations.resize(0);
		#end
	}

	private function createItemRenderer(state:GroupListViewItemState):DisplayObject {
		var storage = this.itemStateToStorage(state);
		var itemRenderer:DisplayObject = null;
		if (storage.inactiveItemRenderers.length == 0) {
			itemRenderer = storage.itemRendererRecycler.create();
			if ((itemRenderer is IVariantStyleObject)) {
				var variantItemRenderer = cast(itemRenderer, IVariantStyleObject);
				if (variantItemRenderer.variant == null) {
					if (state.type == HEADER) {
						var variant = (this.customHeaderRendererVariant != null) ? this.customHeaderRendererVariant : CHILD_VARIANT_HEADER_RENDERER;
						variantItemRenderer.variant = variant;
					} else {
						var variant = (this.customItemRendererVariant != null) ? this.customItemRendererVariant : CHILD_VARIANT_ITEM_RENDERER;
						variantItemRenderer.variant = variant;
					}
				}
			}
			// for consistency, initialize before passing to the recycler's
			// update function. plus, this ensures that custom item renderers
			// correctly handle property changes in update() instead of trying
			// to access them too early in initialize().
			if ((itemRenderer is IUIControl)) {
				cast(itemRenderer, IUIControl).initializeNow();
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
		if (state.type == STANDARD) {
			if ((itemRenderer is ITriggerView)) {
				itemRenderer.addEventListener(TriggerEvent.TRIGGER, groupListView_itemRenderer_triggerHandler);
			} else {
				itemRenderer.addEventListener(MouseEvent.CLICK, groupListView_itemRenderer_clickHandler);
				#if (openfl >= "9.0.0")
				itemRenderer.addEventListener(TouchEvent.TOUCH_TAP, groupListView_itemRenderer_touchTapHandler);
				#end
			}
			if ((itemRenderer is IToggle)) {
				itemRenderer.addEventListener(Event.CHANGE, groupListView_itemRenderer_changeHandler);
			}
		}
		if ((itemRenderer is IMeasureObject)) {
			itemRenderer.addEventListener(Event.RESIZE, groupListView_itemRenderer_resizeHandler);
		}
		this.itemRendererToItemState.set(itemRenderer, state);
		this.dataToItemRenderer.set(state.data, itemRenderer);
		storage.activeItemRenderers.push(itemRenderer);
		return itemRenderer;
	}

	private function destroyItemRenderer(itemRenderer:DisplayObject, recycler:DisplayObjectRecycler<Dynamic, GroupListViewItemState, DisplayObject>):Void {
		this.groupViewPort.removeChild(itemRenderer);
		if (recycler != null && recycler.destroy != null) {
			recycler.destroy(itemRenderer);
		}
	}

	private function itemOrHeaderStateToStorage(state:GroupListViewItemState, recyclerIDFunction:(GroupListViewItemState) -> String,
			recyclerMap:Map<String, DisplayObjectRecycler<Dynamic, GroupListViewItemState, DisplayObject>>, defaultStorage:ItemRendererStorage,
			additionalStorage:Array<ItemRendererStorage>):ItemRendererStorage {
		var recyclerID:String = null;

		if (recyclerIDFunction != null) {
			recyclerID = recyclerIDFunction(state);
		}

		var recycler:DisplayObjectRecycler<Dynamic, GroupListViewItemState, DisplayObject> = null;
		if (recyclerID != null) {
			if (recyclerMap != null) {
				recycler = recyclerMap.get(recyclerID);
			}
			if (recycler == null) {
				throw new IllegalOperationError('Item renderer recycler ID "${recyclerID}" is not registered.');
			}
		}
		if (recycler == null) {
			return defaultStorage;
		}

		for (i in 0...additionalStorage.length) {
			var storage = additionalStorage[i];
			if (storage.itemRendererRecycler == recycler) {
				return storage;
			}
		}
		var storage = new ItemRendererStorage(state.type, recyclerID, recycler);
		additionalStorage.push(storage);
		return storage;
	}

	private function itemStateToStorage(state:GroupListViewItemState):ItemRendererStorage {
		if (state.type == HEADER) {
			return this.itemOrHeaderStateToStorage(state, this._headerRendererRecyclerIDFunction, this._headerRendererRecyclerMap, this._defaultHeaderStorage,
				this._additionalHeaderStorage);
		}
		return this.itemOrHeaderStateToStorage(state, this._itemRendererRecyclerIDFunction, this._itemRendererRecyclerMap, this._defaultItemStorage,
			this._additionalItemStorage);
	}

	private function populateCurrentItemState(item:Dynamic, type:GroupListViewItemType, location:Array<Int>, layoutIndex:Int,
			state:GroupListViewItemState):Void {
		state.owner = this;
		state.type = type;
		state.data = item;
		state.location = location;
		state.layoutIndex = layoutIndex;
		state.selected = location.length > 1 && item == this._selectedItem;
		state.enabled = this._enabled;
		state.text = type == HEADER ? itemToHeaderText(item) : itemToText(item);
	}

	private function updateItemRenderer(itemRenderer:DisplayObject, state:GroupListViewItemState, storage:ItemRendererStorage):Void {
		state.recyclerID = storage.id;
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		if (storage.itemRendererRecycler.update != null) {
			storage.itemRendererRecycler.update(itemRenderer, state);
		}
		this._ignoreSelectionChange = oldIgnoreSelectionChange;
		this.refreshItemRendererProperties(itemRenderer, state);
	}

	private function resetItemRenderer(itemRenderer:DisplayObject, state:GroupListViewItemState, storage:ItemRendererStorage):Void {
		var recycler = storage.oldItemRendererRecycler != null ? storage.oldItemRendererRecycler : storage.itemRendererRecycler;
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		if (recycler != null && recycler.reset != null) {
			recycler.reset(itemRenderer, state);
		}
		this._ignoreSelectionChange = oldIgnoreSelectionChange;
		this.refreshItemRendererProperties(itemRenderer, RESET_ITEM_STATE);
	}

	private function refreshItemRendererProperties(itemRenderer:DisplayObject, state:GroupListViewItemState):Void {
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		if ((itemRenderer is IUIControl)) {
			var uiControl = cast(itemRenderer, IUIControl);
			uiControl.enabled = state.enabled;
		}
		if ((itemRenderer is IDataRenderer)) {
			var dataRenderer = cast(itemRenderer, IDataRenderer);
			// if the renderer is an IDataRenderer, this cannot be overridden
			dataRenderer.data = state.data;
		}
		if ((itemRenderer is ILayoutIndexObject)) {
			var layoutRenderer = cast(itemRenderer, ILayoutIndexObject);
			// if the renderer is an ILayoutIndexObject, this cannot be overridden
			layoutRenderer.layoutIndex = state.layoutIndex;
		}
		if ((itemRenderer is IGroupListViewItemRenderer)) {
			var groupListRenderer = cast(itemRenderer, IGroupListViewItemRenderer);
			groupListRenderer.location = state.location;
			groupListRenderer.groupListViewOwner = state.owner;
		}
		if ((itemRenderer is IToggle)) {
			var toggle = cast(itemRenderer, IToggle);
			// if the renderer is an IToggle, this cannot be overridden
			toggle.selected = state.selected;
		}
		this._ignoreSelectionChange = oldIgnoreSelectionChange;
	}

	private function refreshSelectedLocationAfterFilterOrSort():Void {
		if (this._selectedLocation == null) {
			return;
		}
		// the location may have changed, possibily even to null, if the item
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
			if (location.length == 1 && this._dataProvider.isBranch(item)) {
				result += this.calculateTotalLayoutCount(location);
			}
			location.pop();
		}
		return result;
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

	private var _currentDisplayIndex:Int;

	private function displayIndexToLocation(displayIndex:Int):Array<Int> {
		if (displayIndex < 0) {
			return null;
		}
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
			if (locationOfBranch.length == 1 && this._dataProvider.isBranch(child)) {
				var result = this.displayIndexToLocationAtBranch(target, locationOfBranch);
				if (result != null) {
					return result;
				}
			}
			locationOfBranch.resize(locationOfBranch.length - 1);
		}
		return null;
	}

	private function locationToDisplayIndex(location:Array<Int>):Int {
		this._currentDisplayIndex = -1;
		return this.locationToDisplayIndexAtBranch([], location);
	}

	private function locationToDisplayIndexAtBranch(locationOfBranch:Array<Int>, locationToFind:Array<Int>):Int {
		for (i in 0...this._dataProvider.getLength(locationOfBranch)) {
			this._currentDisplayIndex++;
			locationOfBranch[locationOfBranch.length] = i;
			if (this.compareLocations(locationOfBranch, locationToFind) == 0) {
				return this._currentDisplayIndex;
			}
			var child = this._dataProvider.get(locationOfBranch);
			if (locationOfBranch.length == 1 && this._dataProvider.isBranch(child)) {
				var result = this.locationToDisplayIndexAtBranch(locationOfBranch, locationToFind);
				if (result != -1) {
					return result;
				}
			}
			locationOfBranch.resize(locationOfBranch.length - 1);
		}
		// location was not found!
		return -1;
	}

	private function isValidLocation(location:Array<Int>):Bool {
		var locationOfBranch:Array<Int> = [];
		for (index in location) {
			if (index < 0) {
				return false;
			}
			if (index >= this._dataProvider.getLength(locationOfBranch)) {
				return false;
			}
			locationOfBranch.push(index);
		}
		return true;
	}

	private function navigateWithKeyboard(event:KeyboardEvent):Void {
		if (event.isDefaultPrevented()) {
			return;
		}
		if (this._layoutItems.length == 0) {
			return;
		}
		var location:Array<Int> = null;
		var startIndex = this.locationToDisplayIndex(this._selectedLocation);
		var result = startIndex;
		if ((this.layout is IKeyboardNavigationLayout)) {
			if (event.keyCode != Keyboard.UP && event.keyCode != Keyboard.DOWN && event.keyCode != Keyboard.LEFT && event.keyCode != Keyboard.RIGHT
				&& event.keyCode != Keyboard.PAGE_UP && event.keyCode != Keyboard.PAGE_DOWN && event.keyCode != Keyboard.HOME && event.keyCode != Keyboard.END) {
				return;
			}
			result = cast(this.layout, IKeyboardNavigationLayout).findNextKeyboardIndex(result, event, false, this._layoutItems, this._layoutHeaderIndices,
				this.groupViewPort.visibleWidth, this.groupViewPort.visibleHeight);
			location = this.displayIndexToLocation(result);
			if (location == null || location.length != 2) {
				return;
			}
		} else {
			var needsAnotherPass = true;
			var nextKeyCode = event.keyCode;
			var lastResult = -1;
			while (needsAnotherPass) {
				needsAnotherPass = false;
				switch (nextKeyCode) {
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
						nextKeyCode = Keyboard.DOWN;
					case Keyboard.END:
						result = this._layoutItems.length - 1;
						nextKeyCode = Keyboard.UP;
					default:
						// not keyboard navigation
						return;
				}
				if (result < 0) {
					result = 0;
				} else if (result >= this._layoutItems.length) {
					result = this._layoutItems.length - 1;
				}
				location = this.displayIndexToLocation(result);
				if (location.length != 2) {
					// keep going until we reach a non-branch
					if (result == lastResult) {
						// but don't keep trying if we got the same result more than
						// once because it means that we got stuck
						return;
					}
					needsAnotherPass = true;
				}
				lastResult = result;
			}
		}
		if (result == startIndex) {
			return;
		}
		event.preventDefault();
		// use the setter
		this.selectedLocation = location;
		if (this._selectedLocation != null) {
			this.scrollToLocation(this._selectedLocation);
		}
		// restore focus to the container so that the wrong item renderer
		// doesn't respond to keyboard events
		if (this._focusManager != null) {
			this._focusManager.focus = this;
		} else if (this.stage != null) {
			this.stage.focus = this;
		}
	}

	private function handleSelectionChange(item:Dynamic, location:Array<Int>, ctrlKey:Bool, shiftKey:Bool):Void {
		if (location == null || location.length != 2 || !this._selectable) {
			// use the setter
			this.selectedItem = null;
			return;
		}
		// use the setter
		this.selectedLocation = location;
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
			var displayIndex = this.locationToDisplayIndex(location);
			var scrollLayout = cast(this.layout, IScrollLayout);
			var result = scrollLayout.getNearestScrollPositionForIndex(displayIndex, this._layoutItems.length, this.viewPort.visibleWidth,
				this.viewPort.visibleHeight);
			targetX = result.x;
			targetY = result.y;
		} else {
			var item = this._dataProvider.get(location);
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

	private function groupListView_keyDownHandler(event:KeyboardEvent):Void {
		if (!this._enabled || event.isDefaultPrevented()) {
			return;
		}
		if (event.keyCode == Keyboard.SPACE || event.keyCode == Keyboard.ENTER) {
			if (this._selectedItem != null) {
				var itemRenderer = this.dataToItemRenderer.get(this._selectedItem);
				var state:GroupListViewItemState = null;
				if (itemRenderer != null) {
					state = this.itemRendererToItemState.get(itemRenderer);
				}
				var isTemporary = false;
				if (state == null) {
					// if there is no existing state, use a temporary object
					isTemporary = true;
					state = this.itemStatePool.get();
				}
				var type = this._selectedLocation.length == 1 ? HEADER : STANDARD;
				var layoutIndex = this.locationToDisplayIndex(this._selectedLocation);
				this.populateCurrentItemState(this._selectedItem, type, this._selectedLocation, layoutIndex, state);
				GroupListViewEvent.dispatch(this, GroupListViewEvent.ITEM_TRIGGER, state);
				if (isTemporary) {
					this.itemStatePool.release(state);
				}
			}
		}
	}

	private function groupListView_itemRenderer_touchTapHandler(event:TouchEvent):Void {
		if (!this._enabled) {
			return;
		}
		if (event.isPrimaryTouchPoint #if air && Multitouch.mapTouchToMouse #end) {
			// ignore the primary one because MouseEvent.CLICK will catch it
			return;
		}

		var itemRenderer = cast(event.currentTarget, DisplayObject);
		var state = this.itemRendererToItemState.get(itemRenderer);
		GroupListViewEvent.dispatch(this, GroupListViewEvent.ITEM_TRIGGER, state);

		if (!this._selectable || !this.pointerSelectionEnabled) {
			return;
		}
		this.handleSelectionChange(state.data, state.location, event.ctrlKey, event.shiftKey);
	}

	private function groupListView_itemRenderer_clickHandler(event:MouseEvent):Void {
		if (!this._enabled) {
			return;
		}

		var itemRenderer = cast(event.currentTarget, DisplayObject);
		var state = this.itemRendererToItemState.get(itemRenderer);
		GroupListViewEvent.dispatch(this, GroupListViewEvent.ITEM_TRIGGER, state);

		if (!this._selectable || !this.pointerSelectionEnabled) {
			return;
		}
		this.handleSelectionChange(state.data, state.location, event.ctrlKey, event.shiftKey);
	}

	private function groupListView_itemRenderer_triggerHandler(event:TriggerEvent):Void {
		if (!this._enabled) {
			return;
		}

		var itemRenderer = cast(event.currentTarget, DisplayObject);
		var state = this.itemRendererToItemState.get(itemRenderer);
		GroupListViewEvent.dispatch(this, GroupListViewEvent.ITEM_TRIGGER, state);

		if (!this._selectable) {
			return;
		}
		this.handleSelectionChange(state.data, state.location, event.ctrlKey, event.shiftKey);
	}

	private function groupListView_itemRenderer_resizeHandler(event:Event):Void {
		if (this._validating) {
			return;
		}
		this.setInvalid(LAYOUT);
	}

	private function groupListView_itemRenderer_changeHandler(event:Event):Void {
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

	private function groupListView_dataProvider_changeHandler(event:Event):Void {
		if (this._virtualCache != null) {
			#if hl
			this._virtualCache.splice(0, this._virtualCache.length);
			#else
			this._virtualCache.resize(0);
			#end
			var newSize = this.calculateTotalLayoutCount([]);
			this._virtualCache.resize(newSize);
		}
		this.setInvalid(DATA);
	}

	private function groupListView_dataProvider_addItemHandler(event:HierarchicalCollectionEvent):Void {
		if (this._selectedLocation == null) {
			return;
		}
		if (this.compareLocations(this._selectedLocation, event.location) >= 0) {
			// use the setter
			this.selectedLocation = this._dataProvider.locationOf(this._selectedItem);
		}
	}

	private function groupListView_dataProvider_removeItemHandler(event:HierarchicalCollectionEvent):Void {
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

	private function groupListView_dataProvider_replaceItemHandler(event:HierarchicalCollectionEvent):Void {
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

	private function groupListView_dataProvider_removeAllHandler(event:HierarchicalCollectionEvent):Void {
		// use the setter
		this.selectedLocation = null;
	}

	private function groupListView_dataProvider_resetHandler(event:HierarchicalCollectionEvent):Void {
		// use the setter
		this.selectedLocation = null;
	}

	private function updateItemRendererForLocation(location:Array<Int>):Void {
		var layoutIndex = this.locationToDisplayIndex(location);
		if (this._virtualCache != null) {
			this._virtualCache[layoutIndex] = null;
		}
		var item = this._dataProvider.get(location);
		var itemRenderer = this.dataToItemRenderer.get(item);
		if (itemRenderer == null) {
			// doesn't exist yet, so we need to do a full invalidation
			this.setInvalid(DATA);
			return;
		}
		var type = location.length == 1 ? HEADER : STANDARD;
		var state = this.itemRendererToItemState.get(itemRenderer);
		var storage = this.itemStateToStorage(state);
		this.populateCurrentItemState(item, type, location, layoutIndex, state);
		// in order to display the same item with modified properties, this
		// hack tricks the item renderer into thinking that it has been given
		// a different item to render.
		this.resetItemRenderer(itemRenderer, state, storage);
		if (storage.measurements != null) {
			storage.measurements.restore(itemRenderer);
		}
		this.updateItemRenderer(itemRenderer, state, storage);
		if (type == HEADER) {
			for (i in 0...this._dataProvider.getLength(location)) {
				location.push(i);
				this.updateItemRendererForLocation(location);
				location.pop();
			}
		}
		this.setInvalid(LAYOUT);
	}

	private function groupListView_dataProvider_updateItemHandler(event:HierarchicalCollectionEvent):Void {
		this.updateItemRendererForLocation(event.location);
	}

	private function groupListView_dataProvider_updateAllHandler(event:HierarchicalCollectionEvent):Void {
		var location:Array<Int> = [];
		for (i in 0...this._dataProvider.getLength()) {
			location[0] = i;
			this.updateItemRendererForLocation(location);
		}
	}
}

private class ItemRendererStorage {
	public function new(type:GroupListViewItemType, ?id:String, ?recycler:DisplayObjectRecycler<Dynamic, GroupListViewItemState, DisplayObject>) {
		this.type = type;
		this.id = id;
		this.itemRendererRecycler = recycler;
	}

	public var type:GroupListViewItemType;
	public var id:String;
	public var oldItemRendererRecycler:DisplayObjectRecycler<Dynamic, GroupListViewItemState, DisplayObject>;
	public var itemRendererRecycler:DisplayObjectRecycler<Dynamic, GroupListViewItemState, DisplayObject>;
	public var activeItemRenderers:Array<DisplayObject> = [];
	public var inactiveItemRenderers:Array<DisplayObject> = [];
	public var measurements:Measurements;
}

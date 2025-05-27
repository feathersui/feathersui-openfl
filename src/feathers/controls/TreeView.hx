/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.controls.dataRenderers.HierarchicalItemRenderer;
import feathers.controls.dataRenderers.IDataRenderer;
import feathers.controls.dataRenderers.IHierarchicalDepthItemRenderer;
import feathers.controls.dataRenderers.IHierarchicalItemRenderer;
import feathers.controls.dataRenderers.ITreeViewItemRenderer;
import feathers.controls.supportClasses.AdvancedLayoutViewPort;
import feathers.controls.supportClasses.BaseScrollContainer;
import feathers.core.IDataSelector;
import feathers.core.IFocusContainer;
import feathers.core.IMeasureObject;
import feathers.core.IOpenCloseToggle;
import feathers.core.ITextControl;
import feathers.core.IUIControl;
import feathers.core.InvalidationFlag;
import feathers.data.IHierarchicalCollection;
import feathers.data.TreeViewItemState;
import feathers.events.FeathersEvent;
import feathers.events.HierarchicalCollectionEvent;
import feathers.events.TreeViewEvent;
import feathers.events.TriggerEvent;
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
import openfl.display.DisplayObject;
import openfl.errors.ArgumentError;
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
	Displays a hierarchical tree of items. Supports scrolling, custom item
	renderers, and custom layouts.

	The following example creates a tree, gives it a data provider, tells
	the item renderer how to interpret the data, and listens for when the
	selection changes:

	```haxe
	var treeView = new TreeView();

	treeView.dataProvider = new ArrayHierarchicalCollection<TreeItemData>([
		{
			text: "Node 1",
			children: [
				{
					text: "Node 1A",
					children: [
						{text: "Node 1A-I"},
						{text: "Node 1A-II"},
						{text: "Node 1A-III"},
						{text: "Node 1A-IV"}
					]
				},
				{text: "Node 1B"},
				{text: "Node 1C"}
			]
		},
		{
			text: "Node 2",
			children: [
				{text: "Node 2A"},
				{text: "Node 2B"},
				{text: "Node 2C"}
			]
		},
		{text: "Node 3"},
		{
			text: "Node 4",
			children: [
				{text: "Node 4A"},
				{text: "Node 4B"},
				{text: "Node 4C"},
				{text: "Node 4D"},
				{text: "Node 4E"}
			]
		}
	], (item:TreeItemData) -> item.children);

	treeView.itemToText = (item:TreeItemData) -> {
		return item.text;
	};

	treeView.addEventListener(Event.CHANGE, (event:Event) -> {
		var treeView = cast(event.currentTarget, TreeView);
		trace("TreeView changed: " + treeView.selectedLocation + " " + treeView.selectedItem.text);
	});

	this.addChild(treeView);
	```

	The example above uses the following custom [Haxe typedef](https://haxe.org/manual/type-system-typedef.html).

	```haxe
	typedef TreeItemData = {
		text:String,
		?children:Array<TreeItemData>
	};
	```
		
	@event openfl.events.Event.CHANGE Dispatched when either
	`TreeView.selectedItem` or `TreeView.selectedLocation` changes.

	@event feathers.events.TreeViewEvent.ITEM_TRIGGER Dispatched when the user
	taps or clicks an item renderer in the tree view. The pointer must remain
	within the bounds of the item renderer on release, and the tree view cannot
	scroll before release, or the gesture will be ignored.

	@event feathers.events.TreeViewEvent.BRANCH_OPEN Dispatched when a branch
	is opened.

	@event feathers.events.TreeViewEvent.BRANCH_CLOSE Dispatched when a branch
	is closed.

	@event feathers.events.TreeViewEvent.BRANCH_OPENING Dispatched before a
	branch opens.

	@event feathers.events.TreeViewEvent.BRANCH_CLOSING Dispatched before a
	branch closes.

	@see [Tutorial: How to use the TreeView component](https://feathersui.com/learn/haxe-openfl/tree-view/)

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
@:event(feathers.events.TreeViewEvent.ITEM_TRIGGER)
@:event(feathers.events.TreeViewEvent.BRANCH_OPEN)
@:event(feathers.events.TreeViewEvent.BRANCH_CLOSE)
@:event(feathers.events.TreeViewEvent.BRANCH_OPENING)
@:event(feathers.events.TreeViewEvent.BRANCH_CLOSING)
@:access(feathers.data.TreeViewItemState)
@defaultXmlProperty("dataProvider")
@:styleContext
class TreeView extends BaseScrollContainer implements IDataSelector<Dynamic> implements IFocusContainer {
	/**
		A variant used to style the tree view without a border. The variant is
		used by default on mobile.

		The following example uses this variant:

		```haxe
		var treeView = new TreeView();
		treeView.variant = TreeView.VARIANT_BORDERLESS;
		```

		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final VARIANT_BORDERLESS = "borderless";

	/**
		A variant used to style the tree view with a border. This variant is
		used by default on desktop.

		The following example uses this variant:

		```haxe
		var treeView = new TreeView();
		treeView.variant = TreeView.VARIANT_BORDER;
		```

		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final VARIANT_BORDER = "border";

	/**
		The variant used to style the tree view's item renderers in a theme.

		To override this default variant, set the
		`TreeView.customItemRendererVariant` property.

		@see `TreeView.customItemRendererVariant`
		@see `feathers.style.IVariantStyleObject.variant`
		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_ITEM_RENDERER = "treeView_itemRenderer";

	private static final INVALIDATION_FLAG_ITEM_RENDERER_FACTORY = InvalidationFlag.CUSTOM("itemRendererFactory");

	private static final RESET_ITEM_STATE = new TreeViewItemState();

	private static function defaultItemToText(data:Dynamic):String {
		return Std.string(data);
	}

	private static function defaultItemToEnabled(data:Dynamic):Bool {
		return true;
	}

	private static function defaultUpdateItemRenderer(itemRenderer:DisplayObject, state:TreeViewItemState):Void {
		if ((itemRenderer is ITextControl)) {
			var textControl:ITextControl = cast itemRenderer;
			textControl.text = state.text;
		}
	}

	private static function defaultResetItemRenderer(itemRenderer:DisplayObject, state:TreeViewItemState):Void {
		if ((itemRenderer is ITextControl)) {
			var textControl:ITextControl = cast itemRenderer;
			textControl.text = null;
		}
	}

	/**
		Creates a new `TreeView` object.

		@since 1.0.0
	**/
	public function new(?dataProvider:IHierarchicalCollection<Dynamic>, ?changeListener:(Event) -> Void) {
		initializeTreeViewTheme();

		super();

		this.dataProvider = dataProvider;

		this.tabEnabled = true;
		this.focusRect = null;

		if (this.viewPort == null) {
			this.treeViewPort = new AdvancedLayoutViewPort();
			this.addChild(this.treeViewPort);
			this.viewPort = this.treeViewPort;
		}

		if (changeListener != null) {
			this.addEventListener(Event.CHANGE, changeListener);
		}
	}

	private var treeViewPort:AdvancedLayoutViewPort;

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

	private var _dataProvider:IHierarchicalCollection<Dynamic>;

	/**
		The collection of data displayed by the tree view.

		Items in the collection must be class instances or anonymous structures.
		Do not add primitive values (such as strings, booleans, or numeric
		values) directly to the collection.

		Additionally, all items in the collection must be unique object
		instances. Do not add the same instance to the collection more than
		once because a runtime exception will be thrown.

		The following example passes in a data provider and tells the item
		renderer how to interpret the data:

		```haxe
		var collection = new ArrayHierarchicalCollection([
			{
				text: "Node 1",
				children: [
					{
						text: "Node 1A",
						children: [
							{text: "Node 1A-I"},
							{text: "Node 1A-II"},
							{text: "Node 1A-III"},
							{text: "Node 1A-IV"}
						]
					},
					{text: "Node 1B"},
					{text: "Node 1C"}
				]
			},
			{
				text: "Node 2",
				children: [
					{text: "Node 2A"},
					{text: "Node 2B"},
					{text: "Node 2C"}
				]
			},
			{text: "Node 3"},
			{
				text: "Node 4",
				children: [
					{text: "Node 4A"},
					{text: "Node 4B"},
					{text: "Node 4C"},
					{text: "Node 4D"},
					{text: "Node 4E"}
				]
			}
		]);
		collection.itemToChildren = (item:Dynamic) -> {
			return item.children;
		};
		treeView.dataProvider = collection;

		treeView.itemToText = (item:Dynamic) -> {
			return item.text;
		};
		```

		@default null

		@see `feathers.data.ArrayHierarchicalCollection`

		@since 1.0.0
	**/
	@:bindable("dataChange")
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
		this._totalLayoutCount = 0;
		#if (hl && haxe_ver < 4.3)
		this.openBranches.splice(0, this.openBranches.length);
		#else
		this.openBranches.resize(0);
		#end
		if (this._dataProvider != null) {
			this._dataProvider.removeEventListener(Event.CHANGE, treeView_dataProvider_changeHandler);
			this._dataProvider.removeEventListener(HierarchicalCollectionEvent.ADD_ITEM, treeView_dataProvider_addItemHandler);
			this._dataProvider.removeEventListener(HierarchicalCollectionEvent.REMOVE_ITEM, treeView_dataProvider_removeItemHandler);
			this._dataProvider.removeEventListener(HierarchicalCollectionEvent.REPLACE_ITEM, treeView_dataProvider_replaceItemHandler);
			this._dataProvider.removeEventListener(HierarchicalCollectionEvent.REMOVE_ALL, treeView_dataProvider_removeAllHandler);
			this._dataProvider.removeEventListener(HierarchicalCollectionEvent.RESET, treeView_dataProvider_resetHandler);
			this._dataProvider.removeEventListener(HierarchicalCollectionEvent.FILTER_CHANGE, treeView_dataProvider_filterChangeHandler);
			this._dataProvider.removeEventListener(HierarchicalCollectionEvent.SORT_CHANGE, treeView_dataProvider_sortChangeHandler);
			this._dataProvider.removeEventListener(HierarchicalCollectionEvent.UPDATE_ITEM, treeView_dataProvider_updateItemHandler);
			this._dataProvider.removeEventListener(HierarchicalCollectionEvent.UPDATE_ALL, treeView_dataProvider_updateAllHandler);
		}
		this._dataProvider = value;
		if (this._dataProvider != null) {
			this._totalLayoutCount = this.calculateTotalLayoutCount([]);
			this._virtualCache.resize(this._totalLayoutCount);
			this._dataProvider.addEventListener(Event.CHANGE, treeView_dataProvider_changeHandler);
			this._dataProvider.addEventListener(HierarchicalCollectionEvent.ADD_ITEM, treeView_dataProvider_addItemHandler);
			this._dataProvider.addEventListener(HierarchicalCollectionEvent.REMOVE_ITEM, treeView_dataProvider_removeItemHandler);
			this._dataProvider.addEventListener(HierarchicalCollectionEvent.REPLACE_ITEM, treeView_dataProvider_replaceItemHandler);
			this._dataProvider.addEventListener(HierarchicalCollectionEvent.REMOVE_ALL, treeView_dataProvider_removeAllHandler);
			this._dataProvider.addEventListener(HierarchicalCollectionEvent.RESET, treeView_dataProvider_resetHandler);
			this._dataProvider.addEventListener(HierarchicalCollectionEvent.FILTER_CHANGE, treeView_dataProvider_filterChangeHandler);
			this._dataProvider.addEventListener(HierarchicalCollectionEvent.SORT_CHANGE, treeView_dataProvider_sortChangeHandler);
			this._dataProvider.addEventListener(HierarchicalCollectionEvent.UPDATE_ITEM, treeView_dataProvider_updateItemHandler);
			this._dataProvider.addEventListener(HierarchicalCollectionEvent.UPDATE_ALL, treeView_dataProvider_updateAllHandler);
		}

		// reset the scroll position because this is a drastic change and
		// the data is probably completely different
		this.scrollX = 0.0;
		this.scrollY = 0.0;

		// clear the selection for the same reason
		this.selectedLocation = null;

		this.setInvalid(DATA);
		FeathersEvent.dispatch(this, "dataChange");
		return this._dataProvider;
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
		if (value == null) {
			this._selectionAnchorIndex = -1;
			this._selectedItem = null;
			this._selectedLocation = null;
			#if (hl && haxe_ver < 4.3)
			this._selectedLocations.splice(0, this._selectedLocations.length);
			this._selectedItems.splice(0, this._selectedItems.length);
			#else
			this._selectedLocations.resize(0);
			this._selectedItems.resize(0);
			#end
			this.setInvalid(SELECTION);
			FeathersEvent.dispatch(this, Event.CHANGE);
			return this._selectedLocation;
		}
		this._selectedLocation = value;
		this._selectedItem = this._dataProvider.get(this._selectedLocation);
		this._selectedLocations.resize(1);
		this._selectedLocations[0] = this._selectedLocation.copy();
		this._selectedItems.resize(1);
		this._selectedItems[0] = this._selectedItem;
		this._selectionAnchorIndex = this.locationToDisplayIndex(this._selectedLocation, false);
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
		if (location == null) {
			// use the setter
			this.selectedLocation = null;
			return this._selectedItem;
		}
		if (this._selectedItem == value && this.compareLocations(this._selectedLocation, location) == 0) {
			return this._selectedItem;
		}
		this._selectedItem = value;
		this._selectedLocation = location;
		this._selectedLocations.resize(1);
		this._selectedLocations[0] = this._selectedLocation;
		this._selectedItems.resize(1);
		this._selectedItems[0] = this._selectedItem;
		this._selectionAnchorIndex = this.locationToDisplayIndex(this._selectedLocation, false);
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
		treeView.allowMultipleSelection = true;
		```

		@see `TreeView.selectable`
		@see `TreeView.selectedLocations`
		@see `TreeView.selectedItems`

		@since 1.4.0
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

	private var _selectedLocations:Array<Array<Int>> = [];

	/**
		Contains all of the locations that are currently selected. The most
		recently selected location will appear at the beginning of the array. In
		other words, the locations are in the reverse order that they were
		selected by the user.

		When the `selectedLocations` array contains multiple items, the
		`selectedLocation` property will return the first item from
		`selectedLocations`.

		@see `TreeView.allowMultipleSelection`
		@see `TreeView.selectedItems`

		@since 1.4.0
	**/
	@:bindable("change")
	public var selectedLocations(get, set):Array<Array<Int>>;

	private function get_selectedLocations():Array<Array<Int>> {
		return this._selectedLocations;
	}

	private function set_selectedLocations(value:Array<Array<Int>>):Array<Array<Int>> {
		if (value == null || value.length == 0 || !this._selectable || this._dataProvider == null) {
			// use the setter
			this.selectedLocation = null;
			return this._selectedLocations;
		}
		if (this._selectedLocations == value) {
			return this._selectedLocations;
		}
		if (!this._allowMultipleSelection && value.length > 1) {
			value.resize(1);
		}
		this._selectedLocations = value;
		this._selectedLocation = this._selectedLocations[0];
		this._selectedItems.resize(this._selectedLocations.length);
		for (i in 0...this._selectedLocations.length) {
			var location = this._selectedLocations[i];
			this._selectedItems[i] = this._dataProvider.get(location);
		}
		this._selectedItem = this._selectedItems[0];
		this._selectionAnchorIndex = this.locationToDisplayIndex(this._selectedLocation, false);
		this.setInvalid(SELECTION);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._selectedLocations;
	}

	private var _selectedItems:Array<Dynamic> = [];

	/**
		Contains all of the items that are currently selected. The most
		recently selected item will appear at the beginning of the array. In
		other words, the items are in the reverse order that they were
		selected by the user.

		When the `selectedItems` array contains multiple items, the
		`selectedItem` property will return the first item from `selectedItems`.

		@see `TreeView.allowMultipleSelection`
		@see `TreeView.selectedLocations`

		@since 1.4.0
	**/
	@:bindable("change")
	public var selectedItems(get, set):Array<Dynamic>;

	private function get_selectedItems():Array<Dynamic> {
		return this._selectedItems;
	}

	private function set_selectedItems(value:Array<Dynamic>):Array<Dynamic> {
		if (value == null || value.length == 0 || !this._selectable || this._dataProvider == null) {
			// use the setter
			this.selectedLocation = null;
			return this._selectedItems;
		}
		if (this._selectedItems == value) {
			return this._selectedItems;
		}
		if (!this._allowMultipleSelection && value.length > 1) {
			value.resize(1);
		}
		var locations:Array<Array<Int>> = [];
		var i = 0;
		while (i < value.length) {
			var item = value[i];
			var location = this._dataProvider.locationOf(item);
			if (location == null) {
				value.splice(i, 1);
				continue;
			}
			locations.push(location);
			i++;
		}
		this._selectedLocations = locations;
		this._selectedItems = value;
		if (value.length == 0) {
			this._selectedLocation = null;
			this._selectedItem = null;
			this._selectionAnchorIndex = -1;
		} else {
			this._selectedLocation = this._selectedLocations[0];
			this._selectedItem = this._selectedItems[0];
			this._selectionAnchorIndex = this.locationToDisplayIndex(this._selectedLocation, false);
		}
		this.setInvalid(SELECTION);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._selectedLocations;
	}

	private var _previousLayout:ILayout;

	/**
		The layout algorithm used to position and size the tree view's items.

		By default, if no layout is provided by the time that the tree view
		initializes, a default layout that displays items vertically will be
		created.

		The following example tells the tree view to use a horizontal layout:

		```haxe
		var layout = new HorizontalListLayout();
		layout.gap = 20.0;
		layout.padding = 20.0;
		treeView.layout = layout;
		```

		@since 1.0.0
	**/
	@:style
	public var layout:ILayout = null;

	private var _previousCustomItemRendererVariant:String = null;

	/**
		A custom variant to set on all item renderers, instead of
		`TreeView.CHILD_VARIANT_ITEM_RENDERER`.

		The `customItemRendererVariant` will be not be used if the result of
		`itemRendererRecycler.create()` already has a variant set.

		@see `TreeView.CHILD_VARIANT_ITEM_RENDERER`
		@see `feathers.style.IVariantStyleObject.variant`

		@since 1.0.0
	**/
	@:style
	public var customItemRendererVariant:String = null;

	/**
		Manages item renderers used by the tree view.

		In the following example, the tree view uses a custom item renderer
		class:

		```haxe
		treeView.itemRendererRecycler = DisplayObjectRecycler.withClass(CustomItemRenderer);
		```

		@see `feathers.controls.dataRenderers.HierarchicalItemRenderer`
		@see `feathers.controls.dataRenderers.LayoutGroupItemRenderer`

		@since 1.0.0
	**/
	public var itemRendererRecycler(get, set):AbstractDisplayObjectRecycler<Dynamic, TreeViewItemState, DisplayObject>;

	private function get_itemRendererRecycler():AbstractDisplayObjectRecycler<Dynamic, TreeViewItemState, DisplayObject> {
		return this._defaultStorage.itemRendererRecycler;
	}

	private function set_itemRendererRecycler(value:AbstractDisplayObjectRecycler<Dynamic, TreeViewItemState,
		DisplayObject>):AbstractDisplayObjectRecycler<Dynamic, TreeViewItemState, DisplayObject> {
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
		`TreeViewItemState` when the tree view validates, even if the item's
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

	private var _recyclerMap:Map<String, DisplayObjectRecycler<Dynamic, TreeViewItemState, DisplayObject>> = null;

	private var _itemRendererRecyclerIDFunction:(state:TreeViewItemState) -> String;

	/**
		When a tree view requires multiple item renderer types, this function is
		used to determine which type of item renderer is required for a specific
		item. Returns the ID of the item renderer recycler to use for the item,
		or `null` if the default `itemRendererRecycler` should be used.

		The following example provides an `itemRendererRecyclerIDFunction`:

		```haxe
		var regularItemRecycler = DisplayObjectRecycler.withClass(HierarchicalItemRenderer);
		var firstItemRecycler = DisplayObjectRecycler.withClass(MyCustomItemRenderer);
		treeView.setItemRendererRecycler("regular-item", regularItemRecycler);
		treeView.setItemRendererRecycler("first-item", firstItemRecycler);
		treeView.itemRendererRecyclerIDFunction = function(state:TreeViewItemState):String {
			if(state.location.length == 1 && state.location[0] == 0) {
				return "first-item";
			}
			return "regular-item";
		};
		```

		@default null

		@see `TreeView.setItemRendererRecycler()`
		@see `TreeView.itemRendererRecycler

		@since 1.0.0
	**/
	public var itemRendererRecyclerIDFunction(get, set):(state:TreeViewItemState) -> String;

	private function get_itemRendererRecyclerIDFunction():(state:TreeViewItemState) -> String {
		return this._itemRendererRecyclerIDFunction;
	}

	private function set_itemRendererRecyclerIDFunction(value:(state:TreeViewItemState) -> String):(state:TreeViewItemState) -> String {
		if (this._itemRendererRecyclerIDFunction == value) {
			return this._itemRendererRecyclerIDFunction;
		}
		this._itemRendererRecyclerIDFunction = value;
		this.setInvalid(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		return this._itemRendererRecyclerIDFunction;
	}

	private var _defaultStorage = new ItemRendererStorage(null, DisplayObjectRecycler.withClass(HierarchicalItemRenderer));
	private var _additionalStorage:Array<ItemRendererStorage> = null;
	private var objectDataToItemRenderer = new ObjectMap<Dynamic, DisplayObject>();
	private var stringDataToItemRenderer = new StringMap<DisplayObject>();
	private var itemRendererToItemState = new ObjectMap<DisplayObject, TreeViewItemState>();
	private var itemStatePool = new ObjectPool(() -> new TreeViewItemState());
	private var _unrenderedLocations:Array<Array<Int>> = [];
	private var _unrenderedLayoutIndices:Array<Int> = [];
	private var _virtualCache:Array<Dynamic> = [];
	private var _visibleIndices:VirtualLayoutRange = new VirtualLayoutRange(0, 0);
	private var _tempVisibleIndices:VirtualLayoutRange = new VirtualLayoutRange(0, 0);
	private var _layoutItems:Array<DisplayObject> = [];
	private var _totalLayoutCount:Int = 0;

	private var _selectable:Bool = true;

	/**
		Determines if items in the tree view may be selected. By default only a
		single item may be selected at any given time. In other words, if item
		_A_ is already selected, and the user selects item _B_, item _A_ will be
		deselected automatically.

		The following example disables selection of items in the tree view:

		```haxe
		treeView.selectable = false;
		```

		@default true

		@see `TreeView.selectedItem`
		@see `TreeView.selectedIndex`

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
			this.selectedLocation = null;
		}
		return this._selectable;
	}

	private var _virtualLayout:Bool = true;

	/**
		Indicates if the tree view's layout is allowed to virtualize items or
		not.

		The following example disables virtual layouts:

		```haxe
		treeView.virtualLayout = false;
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
		treeView.pointerSelectionEnabled = false;
		```

		@since 1.0.0
	**/
	public var pointerSelectionEnabled:Bool = true;

	private var _ignoreSelectionChange = false;
	private var _ignoreOpenedChange = false;
	private var _ignoreLayoutChanges = false;

	private var _currentDisplayIndex:Int;

	private var _pendingScrollLocation:Array<Int> = null;
	private var _pendingScrollDuration:Null<Float> = null;

	private var _itemToText:(Dynamic) -> String = defaultItemToText;

	/**
		Converts an item to text to display within tree view. By default, the
		`toString()` method is called to convert an item to text. This method
		may be replaced to provide custom text.

		For example, consider the following item:

		```haxe
		{ text: "Example Item" }
		```

		If the `TreeView` should display the text "Example Item", a custom
		implementation of `itemToText()` might look like this:

		```haxe
		treeView.itemToText = (item:Dynamic) -> {
			return item.text;
		};
		```

		@since 1.0.0
	**/
	public var itemToText(get, set):(Dynamic) -> String;

	private function get_itemToText():(Dynamic) -> String {
		return this._itemToText;
	}

	private function set_itemToText(value:(Dynamic) -> String):(Dynamic) -> String {
		if (value == null) {
			value = defaultItemToText;
		}
		if (this._itemToText == value || Reflect.compareMethods(this._itemToText, value)) {
			return this._itemToText;
		}
		this._itemToText = value;
		this.setInvalid(DATA);
		return this._itemToText;
	}

	private var _itemToEnabled:(Dynamic) -> Bool = defaultItemToEnabled;

	/**
		Determines if an item should be enabled or disabled. By default, all
		items are enabled, unless the `TreeView` is disabled. This method
		may be replaced to provide a custom value for `enabled`.

		For example, consider the following item:

		```haxe
		{ text: "Example Item", disable: true }
		```

		If the `TreeView` should disable an item if the `disable` field is
		`true`, a custom implementation of `itemToEnabled()` might look like
		this:

		```haxe
		treeView.itemToEnabled = (item:Dynamic) -> {
			return !item.disable;
		};
		```

		@since 1.2.0
	**/
	public var itemToEnabled(get, set):(Dynamic) -> Bool;

	private function get_itemToEnabled():(Dynamic) -> Bool {
		return this._itemToEnabled;
	}

	private function set_itemToEnabled(value:(Dynamic) -> Bool):(Dynamic) -> Bool {
		if (value == null) {
			value = defaultItemToEnabled;
		}
		if (this._itemToEnabled == value || Reflect.compareMethods(this._itemToEnabled, value)) {
			return this._itemToEnabled;
		}
		this._itemToEnabled = value;
		this.setInvalid(DATA);
		return this._itemToEnabled;
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
		return this.isBranchOpenInternal(branch);
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
		var alreadyOpen = this.isBranchOpenInternal(branch);
		if ((open && alreadyOpen) || (!open && !alreadyOpen)) {
			// nothing to change
			return;
		}
		var layoutIndex = this.locationToDisplayIndex(location, false);
		this.toggleBranchInternal(branch, location, layoutIndex, open);
		this._totalLayoutCount = this.calculateTotalLayoutCount([]);
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
		this._totalLayoutCount = this.calculateTotalLayoutCount([]);
	}

	/**
		Returns the current item renderer used to render a specific item from
		the data provider. May return `null` if an item doesn't currently have
		an item renderer.

		**Note:** Most tree views use "virtual" layouts, which means that only
		the currently-visible subset of items will have an item renderer. As the
		tree view scrolls, the items with item renderers will change, and item
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
		specified location in the data provider. May return `null` if an item
		doesn't currently have an item renderer.

		**Note:** Most tree views use "virtual" layouts, which means that only
		the currently-visible subset of items will have an item renderer. As the
		tree view scrolls, the items with item renderers will change, and item
		renderers may even be re-used to display different items.

		@since 1.0.0
	**/
	public function locationToItemRenderer(location:Array<Int>):DisplayObject {
		if (this._dataProvider == null || !this.isValidLocation(location)) {
			return null;
		}
		var item = this._dataProvider.get(location);
		if ((item is String)) {
			return this.stringDataToItemRenderer.get(cast item);
		}
		return this.objectDataToItemRenderer.get(item);
	}

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
		Returns the item renderer recycler associated with a specific ID.
		Returns `null` if no recycler is associated with the ID.

		@see `TreeView.itemRendererRecyclerIDFunction`
		@see `TreeView.setItemRendererRecycler()`

		@since 1.0.0
	**/
	public function getItemRendererRecycler(id:String):DisplayObjectRecycler<Dynamic, TreeViewItemState, DisplayObject> {
		if (this._recyclerMap == null) {
			return null;
		}
		return this._recyclerMap.get(id);
	}

	/**
		Associates an item renderer recycler with an ID to allow multiple types
		of item renderers may be displayed in the tree view. A custom
		`itemRendererRecyclerIDFunction` may be specified to return the ID of
		the recycler to use for a specific item in the data provider.

		To clear a recycler, pass in `null` for the value.

		@see `TreeView.itemRendererRecyclerIDFunction`
		@see `TreeView.getItemRendererRecycler()`

		@since 1.0.0
	**/
	public function setItemRendererRecycler(id:String, recycler:AbstractDisplayObjectRecycler<Dynamic, TreeViewItemState, DisplayObject>):Void {
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
		Returns a `TreeViewItemState` representing a specific item.

		@since 1.3.0
	**/
	public function itemToItemState(item:Dynamic):TreeViewItemState {
		if (item == null) {
			return null;
		}
		var itemState:TreeViewItemState = null;
		var itemRenderer:DisplayObject = null;
		if ((item is String)) {
			itemRenderer = this.stringDataToItemRenderer.get(cast item);
		} else {
			itemRenderer = this.objectDataToItemRenderer.get(item);
		}
		if (itemRenderer != null) {
			itemState = this.itemRendererToItemState.get(itemRenderer);
		} else {
			var location = this._dataProvider.locationOf(item);
			if (location == null) {
				return null;
			}
			itemState = new TreeViewItemState();
			var layoutIndex = this.locationToDisplayIndex(location, false);
			this.populateCurrentItemState(item, location, layoutIndex, itemState, false);
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
		this._selectedLocation = null;
		this.dataProvider = null;
		super.dispose();
	}

	private function initializeTreeViewTheme():Void {
		#if !feathersui_disable_default_theme
		feathers.themes.steel.components.SteelTreeViewStyles.initialize();
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
				this._virtualCache.resize(this._totalLayoutCount);
			}
			this.treeViewPort.layout = this.layout;
			this._previousLayout = this.layout;
		}

		this.treeViewPort.refreshChildren = this.refreshItemRenderers;

		for (flag in this._invalidationFlags.keys()) {
			this.treeViewPort.setInvalid(flag);
		}
		if (this._allInvalid) {
			this.treeViewPort.setInvalid();
		}

		super.update();

		this._previousCustomItemRendererVariant = this.customItemRendererVariant;

		this.handlePendingScroll();
	}

	override private function createScroller():Void {
		super.createScroller();
		this.treeViewPort.scroller = this.scroller;
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
		this.scroller.snapPositionsX = this.treeViewPort.snapPositionsX;
		this.scroller.snapPositionsY = this.treeViewPort.snapPositionsY;
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
			virtualLayout.getVisibleIndices(this._layoutItems.length, this.treeViewPort.visibleWidth, this.treeViewPort.visibleHeight,
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

		var itemRendererInvalid = this.treeViewPort.isInvalid(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
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
			itemRenderer.removeEventListener(TriggerEvent.TRIGGER, treeView_itemRenderer_triggerHandler);
			itemRenderer.removeEventListener(MouseEvent.CLICK, treeView_itemRenderer_clickHandler);
			itemRenderer.removeEventListener(TouchEvent.TOUCH_TAP, treeView_itemRenderer_touchTapHandler);
			itemRenderer.removeEventListener(Event.CHANGE, treeView_itemRenderer_changeHandler);
			itemRenderer.removeEventListener(Event.RESIZE, treeView_itemRenderer_resizeHandler);
			itemRenderer.removeEventListener(Event.OPEN, treeView_itemRenderer_openHandler);
			itemRenderer.removeEventListener(Event.CLOSE, treeView_itemRenderer_closeHandler);
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
		this._layoutItems.resize(this._totalLayoutCount);

		if (this._virtualLayout && (this.layout is IVirtualLayout)) {
			var virtualLayout:IVirtualLayout = cast this.layout;
			var oldIgnoreLayoutChanges = this._ignoreLayoutChanges;
			this._ignoreLayoutChanges = true;
			virtualLayout.scrollX = this.scroller.scrollX;
			virtualLayout.scrollY = this.scroller.scrollY;
			virtualLayout.virtualCache = this._virtualCache;
			this._ignoreLayoutChanges = oldIgnoreLayoutChanges;
			virtualLayout.getVisibleIndices(this._layoutItems.length, this.treeViewPort.visibleWidth, this.treeViewPort.visibleHeight, this._visibleIndices);
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
			} else {
				this.findItemRenderer(item, location.copy(), layoutIndex);
			}
			layoutIndex++;
			if (layoutIndex > this._visibleIndices.end) {
				// don't bother continuing if we're beyond the visible indices
				break;
			}
			if (this.isBranchOpenInternal(item)) {
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

	private function findItemRenderer(item:Dynamic, location:Array<Int>, layoutIndex:Int):Void {
		var itemRenderer:DisplayObject = null;
		if ((item is String)) {
			itemRenderer = this.stringDataToItemRenderer.get(cast item);
		} else {
			itemRenderer = this.objectDataToItemRenderer.get(item);
		}
		if (itemRenderer == null) {
			this._unrenderedLocations.push(location);
			this._unrenderedLayoutIndices.push(layoutIndex);
			return;
		}
		var state = this.itemRendererToItemState.get(itemRenderer);
		var changed = this.populateCurrentItemState(item, location, layoutIndex, state, this._forceItemStateUpdate);
		var oldRecyclerID = state.recyclerID;
		var storage = this.itemStateToStorage(state);
		if (storage.id != oldRecyclerID) {
			this._unrenderedLocations.push(location);
			this._unrenderedLayoutIndices.push(layoutIndex);
			return;
		}
		if (changed) {
			this.updateItemRenderer(itemRenderer, state, storage);
		}
		// if this item renderer used to be the typical layout item, but
		// it isn't anymore, it may have been set invisible
		itemRenderer.visible = true;
		this._layoutItems[layoutIndex] = itemRenderer;
		var removed = storage.inactiveItemRenderers.remove(itemRenderer);
		if (!removed) {
			throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: item renderer map contains bad data for item at location ${location}. This may be caused by duplicate items in the data provider, which is not allowed.');
		}
		storage.activeItemRenderers.push(itemRenderer);
	}

	private function populateCurrentItemState(item:Dynamic, location:Array<Int>, layoutIndex:Int, state:TreeViewItemState, force:Bool):Bool {
		var changed = false;
		if (force || state.owner != this) {
			state.owner = this;
			changed = true;
		}
		if (force || state.data != item) {
			state.data = item;
			changed = true;
		}
		if (force || (state.location != location && this.compareLocations(state.location, location) != 0)) {
			state.location = location;
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
		var opened = state.branch && this.isBranchOpenInternal(item);
		if (force || state.opened != opened) {
			state.opened = opened;
			changed = true;
		}
		var selected = Lambda.exists(this._selectedLocations, other -> this.compareLocations(other, location) == 0);
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

	private function updateItemRenderer(itemRenderer:DisplayObject, state:TreeViewItemState, storage:ItemRendererStorage):Void {
		state.recyclerID = storage.id;
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		var oldIgnoreOpenedChange = this._ignoreOpenedChange;
		this._ignoreOpenedChange = true;
		if (storage.itemRendererRecycler.update != null) {
			storage.itemRendererRecycler.update(itemRenderer, state);
		}
		this._ignoreOpenedChange = oldIgnoreOpenedChange;
		this._ignoreSelectionChange = oldIgnoreSelectionChange;
		this.refreshItemRendererProperties(itemRenderer, state);
	}

	private function resetItemRenderer(itemRenderer:DisplayObject, state:TreeViewItemState, storage:ItemRendererStorage):Void {
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		var oldIgnoreOpenedChange = this._ignoreOpenedChange;
		this._ignoreOpenedChange = true;
		var recycler = storage.oldItemRendererRecycler != null ? storage.oldItemRendererRecycler : storage.itemRendererRecycler;
		if (recycler != null && recycler.reset != null) {
			recycler.reset(itemRenderer, state);
		}
		this._ignoreOpenedChange = oldIgnoreOpenedChange;
		this._ignoreSelectionChange = oldIgnoreSelectionChange;
		this.refreshItemRendererProperties(itemRenderer, RESET_ITEM_STATE);
	}

	private function refreshItemRendererProperties(itemRenderer:DisplayObject, state:TreeViewItemState):Void {
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		var oldIgnoreOpenedChange = this._ignoreOpenedChange;
		this._ignoreOpenedChange = true;
		if ((itemRenderer is IUIControl)) {
			var uiControl:IUIControl = cast itemRenderer;
			uiControl.enabled = state.enabled;
		}
		if ((itemRenderer is IDataRenderer)) {
			var dataRenderer:IDataRenderer = cast itemRenderer;
			// if the renderer is an IDataRenderer, this cannot be overridden
			dataRenderer.data = state.data;
		}
		if ((itemRenderer is IToggle)) {
			var toggle:IToggle = cast itemRenderer;
			// if the renderer is an IToggle, this cannot be overridden
			toggle.selected = state.selected;
		}
		if ((itemRenderer is IHierarchicalItemRenderer)) {
			var hierarchicalItem:IHierarchicalItemRenderer = cast itemRenderer;
			hierarchicalItem.branch = state.branch;
		}
		if ((itemRenderer is IHierarchicalDepthItemRenderer)) {
			var depthItem:IHierarchicalDepthItemRenderer = cast itemRenderer;
			depthItem.hierarchyDepth = (state.location != null) ? (state.location.length - 1) : 0;
		}
		if ((itemRenderer is ITreeViewItemRenderer)) {
			var treeItem:ITreeViewItemRenderer = cast itemRenderer;
			treeItem.location = state.location;
			treeItem.treeViewOwner = state.owner;
		}
		if ((itemRenderer is ILayoutIndexObject)) {
			var layoutIndexObject:ILayoutIndexObject = cast itemRenderer;
			layoutIndexObject.layoutIndex = state.layoutIndex;
		}
		if ((itemRenderer is IOpenCloseToggle)) {
			var openCloseItem:IOpenCloseToggle = cast itemRenderer;
			openCloseItem.opened = state.opened;
		}
		this._ignoreOpenedChange = oldIgnoreOpenedChange;
		this._ignoreSelectionChange = oldIgnoreSelectionChange;
	}

	private function renderUnrenderedData():Void {
		for (location in this._unrenderedLocations) {
			var layoutIndex = this._unrenderedLayoutIndices.shift();
			var item = this._dataProvider.get(location);
			var state = this.itemStatePool.get();
			this.populateCurrentItemState(item, location, layoutIndex, state, true);
			var itemRenderer = this.createItemRenderer(state);
			itemRenderer.visible = true;
			this.treeViewPort.addChild(itemRenderer);
			this._layoutItems[layoutIndex] = itemRenderer;
		}
		#if (hl && haxe_ver < 4.3)
		this._unrenderedLocations.splice(0, this._unrenderedLocations.length);
		#else
		this._unrenderedLocations.resize(0);
		#end
	}

	private function createItemRenderer(state:TreeViewItemState):DisplayObject {
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
			itemRenderer.addEventListener(TriggerEvent.TRIGGER, treeView_itemRenderer_triggerHandler);
		} else {
			// fall back to these events if TriggerEvent.TRIGGER isn't available
			itemRenderer.addEventListener(MouseEvent.CLICK, treeView_itemRenderer_clickHandler);
			#if (openfl >= "9.0.0")
			itemRenderer.addEventListener(TouchEvent.TOUCH_TAP, treeView_itemRenderer_touchTapHandler);
			#end
		}
		if ((itemRenderer is IToggle)) {
			itemRenderer.addEventListener(Event.CHANGE, treeView_itemRenderer_changeHandler);
		}
		if ((itemRenderer is IMeasureObject)) {
			itemRenderer.addEventListener(Event.RESIZE, treeView_itemRenderer_resizeHandler);
		}
		if ((itemRenderer is IOpenCloseToggle)) {
			itemRenderer.addEventListener(Event.OPEN, treeView_itemRenderer_openHandler);
			itemRenderer.addEventListener(Event.CLOSE, treeView_itemRenderer_closeHandler);
		}
		this.itemRendererToItemState.set(itemRenderer, state);
		var item = state.data;
		if ((item is String)) {
			this.stringDataToItemRenderer.set(cast item, itemRenderer);
		} else {
			this.objectDataToItemRenderer.set(item, itemRenderer);
		}
		storage.activeItemRenderers.push(itemRenderer);
		return itemRenderer;
	}

	private function destroyItemRenderer(itemRenderer:DisplayObject, recycler:DisplayObjectRecycler<Dynamic, TreeViewItemState, DisplayObject>):Void {
		this.treeViewPort.removeChild(itemRenderer);
		if (recycler != null && recycler.destroy != null) {
			recycler.destroy(itemRenderer);
		}
	}

	private function itemStateToStorage(state:TreeViewItemState):ItemRendererStorage {
		var recyclerID:String = null;
		if (this._itemRendererRecyclerIDFunction != null) {
			recyclerID = this._itemRendererRecyclerIDFunction(state);
		}
		var recycler:DisplayObjectRecycler<Dynamic, TreeViewItemState, DisplayObject> = null;
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

	private function refreshSelectedLocationAfterFilterOrSort():Void {
		if (this._selectedLocation == null) {
			return;
		}
		// the location may have changed, possibly even to null, if the item
		// was filtered out
		this.selectedLocation = this._dataProvider.locationOf(this._selectedItem); // use the setter
	}

	private function isBranchOpenInternal(item:Dynamic):Bool {
		if (this._dataProvider == null) {
			return false;
		}
		if (!this._dataProvider.isBranch(item)) {
			return false;
		}
		return this.openBranches.indexOf(item) != -1;
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
			if (this.isBranchOpenInternal(item)) {
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
			if (this.isBranchOpenInternal(item)) {
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
			if (this.isBranchOpenInternal(item)) {
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
			if (this.isBranchOpenInternal(child)) {
				var result = this.displayIndexToLocationAtBranch(target, locationOfBranch);
				if (result != null) {
					return result;
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
			if (this.isBranchOpenInternal(child)) {
				var result = this.locationToDisplayIndexAtBranch(locationOfBranch, locationToFind, nearestNotOpenBranch);
				if (result != -1) {
					return result;
				}
			} else if (this._dataProvider.isBranch(child)) {
				if (nearestNotOpenBranch != null && this.compareLocations(nearestNotOpenBranch, locationOfBranch) == 0) {
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
		if (this._layoutItems.length == 0) {
			return;
		}
		var startIndex = this.locationToDisplayIndex(this._selectedLocation, false);
		var result = startIndex;
		if ((this.layout is IKeyboardNavigationLayout)) {
			if (event.keyCode != Keyboard.UP && event.keyCode != Keyboard.DOWN && event.keyCode != Keyboard.LEFT && event.keyCode != Keyboard.RIGHT
				&& event.keyCode != Keyboard.PAGE_UP && event.keyCode != Keyboard.PAGE_DOWN && event.keyCode != Keyboard.HOME && event.keyCode != Keyboard.END) {
				return;
			}
			result = (cast this.layout : IKeyboardNavigationLayout).findNextKeyboardIndex(result, event, false, this._layoutItems, null,
				this.treeViewPort.visibleWidth, this.treeViewPort.visibleHeight);
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
					result = this._layoutItems.length - 1;
				default:
					// not keyboard navigation
					return;
			}
		}
		if (result < 0) {
			result = 0;
		} else if (result >= this._layoutItems.length) {
			result = this._layoutItems.length - 1;
		}
		var changed = result != startIndex;
		var pendingLocation:Array<Int> = null;
		if (!changed && result != -1) {
			pendingLocation = this.displayIndexToLocation(result);
			var itemRenderer = this.itemToItemRenderer(this._dataProvider.get(pendingLocation));
			if (itemRenderer == null) {
				// if we can't find the item renderer, we need to scroll
				changed = true;
			} else if ((this.layout is IScrollLayout)) {
				var scrollLayout:IScrollLayout = cast this.layout;
				var nearestScrollPosition = scrollLayout.getNearestScrollPositionForIndex(result, this._layoutItems.length, this.viewPort.visibleWidth,
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
		if (pendingLocation == null) {
			pendingLocation = this.displayIndexToLocation(result);
		}
		// use the setter
		this.selectedLocation = pendingLocation;
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
			var scrollLayout:IScrollLayout = cast this.layout;
			var result = scrollLayout.getNearestScrollPositionForIndex(displayIndex, this._layoutItems.length, this.viewPort.visibleWidth,
				this.viewPort.visibleHeight);
			targetX = result.x;
			targetY = result.y;
		} else {
			var item = this._dataProvider.get(location);
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

	override private function baseScrollContainer_keyDownHandler(event:KeyboardEvent):Void {
		if (!this._selectable) {
			super.baseScrollContainer_keyDownHandler(event);
			return;
		}
		if (!this._enabled || event.isDefaultPrevented() || this._dataProvider == null) {
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
		if (event.keyCode == Keyboard.LEFT) {
			if (this._selectedItem != null) {
				if (this._dataProvider.isBranch(this._selectedItem) && this.isBranchOpenInternal(this._selectedItem)) {
					this.toggleBranch(this._selectedItem, false);
					return;
				}
				var parentLocation = this._selectedLocation.copy();
				parentLocation.pop();
				if (parentLocation.length > 0) {
					this.selectedLocation = parentLocation;
				}
			}
		}
		if (event.keyCode == Keyboard.RIGHT) {
			if (this._selectedItem != null && this._dataProvider.isBranch(this._selectedItem)) {
				if (!this.isBranchOpenInternal(this._selectedItem)) {
					this.toggleBranch(this._selectedItem, true);
					return;
				}
				var childCount = this._dataProvider.getLength(this._selectedLocation);
				if (childCount > 0) {
					var childLocation = this._selectedLocation.copy();
					childLocation.push(0);
					this.selectedLocation = childLocation;
				}
			}
		}
		if (event.keyCode == Keyboard.ENTER) {
			if (this._selectedItem != null) {
				var itemRenderer:DisplayObject = null;
				if ((this._selectedItem is String)) {
					itemRenderer = this.stringDataToItemRenderer.get(cast this._selectedItem);
				} else {
					itemRenderer = this.objectDataToItemRenderer.get(this._selectedItem);
				}
				var state:TreeViewItemState = null;
				if (itemRenderer != null) {
					state = this.itemRendererToItemState.get(itemRenderer);
				}
				var isTemporary = false;
				if (state == null) {
					// if there is no existing state, use a temporary object
					isTemporary = true;
					state = this.itemStatePool.get();
				}
				var layoutIndex = this.locationToDisplayIndex(this._selectedLocation, false);
				this.populateCurrentItemState(this._selectedItem, this._selectedLocation, layoutIndex, state, true);
				TreeViewEvent.dispatch(this, TreeViewEvent.ITEM_TRIGGER, state);
				if (isTemporary) {
					this.itemStatePool.release(state);
				}
			}
		}

		if (this._selectedLocation != null && event.keyCode == Keyboard.SPACE) {
			if (this._dataProvider.isBranch(this._selectedItem)) {
				event.preventDefault();
				this.toggleBranch(this._selectedItem, !this.isBranchOpenInternal(this._selectedItem));
			}
			return;
		}
		this.navigateWithKeyboard(event);
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

	private function toggleBranchInternal(branch:Dynamic, location:Array<Int>, layoutIndex:Int, open:Bool):Int {
		var itemRenderer:DisplayObject = null;
		if ((branch is String)) {
			// a branch can't really be a string, but let's be consistent in how
			// we look up item renderers
			itemRenderer = this.stringDataToItemRenderer.get(cast branch);
		} else {
			itemRenderer = this.objectDataToItemRenderer.get(branch);
		}
		var state:TreeViewItemState = null;
		if (itemRenderer != null) {
			state = this.itemRendererToItemState.get(itemRenderer);
		}
		var isTemporary = false;
		if (state == null) {
			// if there is no existing state, use a temporary object
			isTemporary = true;
			state = this.itemStatePool.get();
		}
		state.location = location;
		state.layoutIndex = layoutIndex;
		var alreadyOpen = this.isBranchOpenInternal(branch);
		if (open && !alreadyOpen) {
			this.populateCurrentItemState(branch, location, layoutIndex, state, true);
			var result = TreeViewEvent.dispatch(this, TreeViewEvent.BRANCH_OPENING, state, true);
			if (result) {
				this.openBranches.push(branch);
				this.populateCurrentItemState(branch, location, layoutIndex, state, true);
				layoutIndex = insertChildrenIntoVirtualCache(location, layoutIndex);
				if (itemRenderer != null) {
					var storage = this.itemStateToStorage(state);
					this.updateItemRenderer(itemRenderer, state, storage);
				}
				TreeViewEvent.dispatch(this, TreeViewEvent.BRANCH_OPEN, state);
			} else if (itemRenderer != null) {
				var storage = this.itemStateToStorage(state);
				// if the item renderer triggered the change, it needs to be set
				// to closed
				this.updateItemRenderer(itemRenderer, state, storage);
			}
		} else if (!open && alreadyOpen) {
			this.populateCurrentItemState(branch, location, layoutIndex, state, true);
			var result = TreeViewEvent.dispatch(this, TreeViewEvent.BRANCH_CLOSING, state, true);
			if (result) {
				this.openBranches.remove(branch);
				this.populateCurrentItemState(branch, location, layoutIndex, state, true);
				removeChildrenFromVirtualCache(location, layoutIndex);
				if (itemRenderer != null) {
					var storage = this.itemStateToStorage(state);
					this.updateItemRenderer(itemRenderer, state, storage);
				}
				TreeViewEvent.dispatch(this, TreeViewEvent.BRANCH_CLOSE, state);
			} else if (itemRenderer != null) {
				var storage = this.itemStateToStorage(state);
				this.updateItemRenderer(itemRenderer, state, storage);
			}
		}
		if (isTemporary) {
			this.itemStatePool.release(state);
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

	private function handleSelectionChange(item:Dynamic, location:Array<Int>, layoutIndex:Int, ctrlKey:Bool, shiftKey:Bool):Void {
		if (location == null || !this._selectable) {
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
				var selectedLocations:Array<Array<Int>> = [];
				if (layoutIndex == anchorIndex) {
					selectedLocations.unshift(location);
				} else {
					var i = anchorIndex;
					do {
						var locationFromAnchor = this.displayIndexToLocation(i);
						if (locationFromAnchor != null) {
							selectedLocations.unshift(locationFromAnchor);
						}
						i += (anchorIndex > layoutIndex) ? -1 : 1;
					} while (i != layoutIndex);
					if (layoutIndex != anchorIndex) {
						var locationFromAnchor = this.displayIndexToLocation(layoutIndex);
						if (locationFromAnchor != null) {
							selectedLocations.unshift(locationFromAnchor);
						}
					}
				}
				this.selectedLocations = selectedLocations;
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
				this._selectionAnchorIndex = layoutIndex;
			}
		} else {
			// use the setter
			this.selectedItem = item;
		}
		if (location != null) {
			this.scrollToLocation(location);
		}
	}

	private function treeView_itemRenderer_touchTapHandler(event:TouchEvent):Void {
		if (!this._enabled) {
			return;
		}
		if (event.isPrimaryTouchPoint #if air && Multitouch.mapTouchToMouse #end) {
			// ignore the primary one because MouseEvent.CLICK will catch it
			return;
		}

		var itemRenderer = cast(event.currentTarget, DisplayObject);
		if (itemRenderer.parent != this.treeViewPort) {
			return;
		}
		var state = this.itemRendererToItemState.get(itemRenderer);
		if (state == null) {
			return;
		}
		TreeViewEvent.dispatch(this, TreeViewEvent.ITEM_TRIGGER, state);

		if (!this._selectable || !this.pointerSelectionEnabled) {
			return;
		}
		this.handleSelectionChange(state.data, state.location, state.layoutIndex, event.ctrlKey, event.shiftKey);
	}

	private function treeView_itemRenderer_clickHandler(event:MouseEvent):Void {
		if (!this._enabled) {
			return;
		}
		var itemRenderer = cast(event.currentTarget, DisplayObject);
		if (itemRenderer.parent != this.treeViewPort) {
			return;
		}
		var state = this.itemRendererToItemState.get(itemRenderer);
		if (state == null) {
			return;
		}
		TreeViewEvent.dispatch(this, TreeViewEvent.ITEM_TRIGGER, state);

		if (!this._selectable || !this.pointerSelectionEnabled) {
			return;
		}
		this.handleSelectionChange(state.data, state.location, state.layoutIndex, event.ctrlKey, event.shiftKey);
	}

	private function treeView_itemRenderer_triggerHandler(event:TriggerEvent):Void {
		if (!this._enabled) {
			return;
		}
		var itemRenderer = cast(event.currentTarget, DisplayObject);
		if (itemRenderer.parent != this.treeViewPort) {
			return;
		}
		var state = this.itemRendererToItemState.get(itemRenderer);
		if (state == null) {
			return;
		}
		TreeViewEvent.dispatch(this, TreeViewEvent.ITEM_TRIGGER, state);

		if (!this._selectable || !this.pointerSelectionEnabled) {
			return;
		}
		this.handleSelectionChange(state.data, state.location, state.layoutIndex, event.ctrlKey, event.shiftKey);
	}

	private function treeView_itemRenderer_resizeHandler(event:Event):Void {
		if (this._validating) {
			return;
		}
		var itemRenderer = cast(event.currentTarget, DisplayObject);
		if (itemRenderer.parent != this.treeViewPort) {
			return;
		}
		this.setInvalid(LAYOUT);
	}

	private function treeView_itemRenderer_changeHandler(event:Event):Void {
		if (this._ignoreSelectionChange) {
			return;
		}
		var itemRenderer = cast(event.currentTarget, DisplayObject);
		if (itemRenderer.parent != this.treeViewPort) {
			return;
		}
		var state = this.itemRendererToItemState.get(itemRenderer);
		if (state == null) {
			return;
		}
		var toggleItemRenderer = cast(itemRenderer, IToggle);
		if (toggleItemRenderer.selected == state.selected) {
			// nothing has changed
			return;
		}
		// if we get here, the selected property of the renderer changed
		// unexpectedly, and we need to restore its proper state
		this.setInvalid(SELECTION);
	}

	private function treeView_itemRenderer_openHandler(event:Event):Void {
		if (this._ignoreOpenedChange) {
			return;
		}
		var itemRenderer = cast(event.currentTarget, DisplayObject);
		if (itemRenderer.parent != this.treeViewPort) {
			return;
		}
		var state = this.itemRendererToItemState.get(itemRenderer);
		if (state == null) {
			return;
		}
		this.toggleBranch(state.data, true);
	}

	private function treeView_itemRenderer_closeHandler(event:Event):Void {
		if (this._ignoreOpenedChange) {
			return;
		}
		var itemRenderer = cast(event.currentTarget, DisplayObject);
		if (itemRenderer.parent != this.treeViewPort) {
			return;
		}
		var state = this.itemRendererToItemState.get(itemRenderer);
		if (state == null) {
			return;
		}
		this.toggleBranch(state.data, false);
	}

	private function treeView_dataProvider_changeHandler(event:Event):Void {
		this._totalLayoutCount = this.calculateTotalLayoutCount([]);
		if (this._virtualCache != null) {
			#if (hl && haxe_ver < 4.3)
			this._virtualCache.splice(0, this._virtualCache.length);
			#else
			this._virtualCache.resize(0);
			#end
			this._virtualCache.resize(this._totalLayoutCount);
		}
		this.setInvalid(DATA);
	}

	private function treeView_dataProvider_addItemHandler(event:HierarchicalCollectionEvent):Void {
		if (this._selectedLocation == null) {
			return;
		}
		if (this.compareLocations(this._selectedLocation, event.location) >= 0) {
			// use the setter
			this.selectedLocation = this._dataProvider.locationOf(this._selectedItem);
		}
	}

	private function treeView_dataProvider_removeItemHandler(event:HierarchicalCollectionEvent):Void {
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

	private function treeView_dataProvider_replaceItemHandler(event:HierarchicalCollectionEvent):Void {
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

	private function treeView_dataProvider_removeAllHandler(event:HierarchicalCollectionEvent):Void {
		#if (hl && haxe_ver < 4.3)
		this.openBranches.splice(0, this.openBranches.length);
		#else
		this.openBranches.resize(0);
		#end

		// use the setter
		this.selectedLocation = null;
	}

	private function treeView_dataProvider_resetHandler(event:HierarchicalCollectionEvent):Void {
		#if (hl && haxe_ver < 4.3)
		this.openBranches.splice(0, this.openBranches.length);
		#else
		this.openBranches.resize(0);
		#end

		// use the setter
		this.selectedLocation = null;
	}

	private function treeView_dataProvider_sortChangeHandler(event:HierarchicalCollectionEvent):Void {
		this.refreshSelectedLocationAfterFilterOrSort();
	}

	private function treeView_dataProvider_filterChangeHandler(event:HierarchicalCollectionEvent):Void {
		this.refreshSelectedLocationAfterFilterOrSort();
	}

	private function updateItemRendererForLocation(location:Array<Int>):Void {
		var layoutIndex = this.locationToDisplayIndex(location, false);
		if (this._virtualCache != null && layoutIndex != -1) {
			this._virtualCache[layoutIndex] = null;
		}
		var item = this._dataProvider.get(location);
		var itemRenderer:DisplayObject = null;
		if ((item is String)) {
			itemRenderer = this.stringDataToItemRenderer.get(cast item);
		} else {
			itemRenderer = this.objectDataToItemRenderer.get(item);
		}
		if (itemRenderer == null) {
			// doesn't exist yet, so we need to do a full invalidation
			this.setInvalid(DATA);
		} else {
			var state = this.itemRendererToItemState.get(itemRenderer);
			// a previous update may already be pending
			if (state.owner != null) {
				var storage = this.itemStateToStorage(state);
				this.populateCurrentItemState(item, location, layoutIndex, state, true);
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
		}
		if (this.isBranchOpenInternal(item)) {
			for (i in 0...this._dataProvider.getLength(location)) {
				location.push(i);
				this.updateItemRendererForLocation(location);
				location.pop();
			}
		}
	}

	private function treeView_dataProvider_updateItemHandler(event:HierarchicalCollectionEvent):Void {
		this.updateItemRendererForLocation(event.location);
	}

	private function treeView_dataProvider_updateAllHandler(event:HierarchicalCollectionEvent):Void {
		// opened branches (or even the root) may not necessarily contain the
		// same number of items after updateAll(), so we should recalculate the
		// total number of items in the layout
		this._totalLayoutCount = this.calculateTotalLayoutCount([]);
		if (this._virtualCache != null) {
			#if (hl && haxe_ver < 4.3)
			this._virtualCache.splice(0, this._virtualCache.length);
			#else
			this._virtualCache.resize(0);
			#end
			this._virtualCache.resize(this._totalLayoutCount);
		}
		this.setInvalid(DATA);

		var location:Array<Int> = [];
		for (i in 0...this._dataProvider.getLength()) {
			location[0] = i;
			this.updateItemRendererForLocation(location);
		}
	}
}

private class ItemRendererStorage {
	public function new(?id:String, ?recycler:DisplayObjectRecycler<Dynamic, TreeViewItemState, DisplayObject>) {
		this.id = id;
		this.itemRendererRecycler = recycler;
	}

	public var id:String;
	public var oldItemRendererRecycler:DisplayObjectRecycler<Dynamic, TreeViewItemState, DisplayObject>;
	public var itemRendererRecycler:DisplayObjectRecycler<Dynamic, TreeViewItemState, DisplayObject>;
	public var activeItemRenderers:Array<DisplayObject> = [];
	public var inactiveItemRenderers:Array<DisplayObject> = [];
	public var measurements:Measurements;
}

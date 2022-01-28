/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

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
import feathers.themes.steel.components.SteelTreeViewStyles;
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

	```hx
	var treeView = new TreeView();

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

	treeView.itemToText = (item:TreeNode<Dynamic>) -> {
		return item.text;
	};

	treeView.addEventListener(Event.CHANGE, (event:Event) -> {
		var treeView = cast(event.currentTarget, TreeView);
		trace("TreeView changed: " + treeView.selectedLocation + " " + treeView.selectedItem.text);
	});

	this.addChild(treeView);
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

	@see [Tutorial: How to use the TreeView component](https://feathersui.com/learn/haxe-openfl/tree-view/)

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
@:event(feathers.events.TreeViewEvent.ITEM_TRIGGER)
@:event(feathers.events.TreeViewEvent.BRANCH_OPEN)
@:event(feathers.events.TreeViewEvent.BRANCH_CLOSE)
@:access(feathers.data.TreeViewItemState)
@defaultXmlProperty("dataProvider")
@:styleContext
class TreeView extends BaseScrollContainer implements IDataSelector<Dynamic> implements IFocusContainer {
	/**
		A variant used to style the tree view without a border. The variant is
		used by default on mobile.

		The following example uses this variant:

		```hx
		var treeView = new TreeView();
		treeView.variant = TreeView.VARIANT_BORDERLESS;
		```

		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final VARIANT_BORDERLESS = "borderless";

	/**
		A variant used to style the tree view with a border. This variant is
		used by default on desktop.

		The following example uses this variant:

		```hx
		var treeView = new TreeView();
		treeView.variant = TreeView.VARIANT_BORDER;
		```

		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final VARIANT_BORDER = "border";

	/**
		The variant used to style the tree view's item renderers in a theme.

		To override this default variant, set the
		`TreeView.customItemRendererVariant` property.

		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@see `TreeView.customItemRendererVariant`

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_ITEM_RENDERER = "treeView_itemRenderer";

	private static final INVALIDATION_FLAG_ITEM_RENDERER_FACTORY = InvalidationFlag.CUSTOM("itemRendererFactory");

	private static final RESET_ITEM_STATE = new TreeViewItemState();

	private static function defaultUpdateItemRenderer(itemRenderer:DisplayObject, state:TreeViewItemState):Void {
		if ((itemRenderer is ITextControl)) {
			var textControl = cast(itemRenderer, ITextControl);
			textControl.text = state.text;
		}
	}

	private static function defaultResetItemRenderer(itemRenderer:DisplayObject, state:TreeViewItemState):Void {
		if ((itemRenderer is ITextControl)) {
			var textControl = cast(itemRenderer, ITextControl);
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

		```hx
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
		this._virtualCache.resize(0);
		if (this._dataProvider != null) {
			this._dataProvider.removeEventListener(Event.CHANGE, treeView_dataProvider_changeHandler);
			this._dataProvider.removeEventListener(HierarchicalCollectionEvent.ADD_ITEM, treeView_dataProvider_addItemHandler);
			this._dataProvider.removeEventListener(HierarchicalCollectionEvent.REMOVE_ITEM, treeView_dataProvider_removeItemHandler);
			this._dataProvider.removeEventListener(HierarchicalCollectionEvent.REPLACE_ITEM, treeView_dataProvider_replaceItemHandler);
			this._dataProvider.removeEventListener(HierarchicalCollectionEvent.REMOVE_ALL, treeView_dataProvider_removeAllHandler);
			this._dataProvider.removeEventListener(HierarchicalCollectionEvent.RESET, treeView_dataProvider_resetHandler);
			this._dataProvider.removeEventListener(HierarchicalCollectionEvent.UPDATE_ITEM, treeView_dataProvider_updateItemHandler);
			this._dataProvider.removeEventListener(HierarchicalCollectionEvent.UPDATE_ALL, treeView_dataProvider_updateAllHandler);
		}
		this._dataProvider = value;
		if (this._dataProvider != null) {
			var newSize = this.calculateTotalLayoutCount([]);
			this._virtualCache.resize(newSize);
			this._dataProvider.addEventListener(Event.CHANGE, treeView_dataProvider_changeHandler);
			this._dataProvider.addEventListener(HierarchicalCollectionEvent.ADD_ITEM, treeView_dataProvider_addItemHandler);
			this._dataProvider.addEventListener(HierarchicalCollectionEvent.REMOVE_ITEM, treeView_dataProvider_removeItemHandler);
			this._dataProvider.addEventListener(HierarchicalCollectionEvent.REPLACE_ITEM, treeView_dataProvider_replaceItemHandler);
			this._dataProvider.addEventListener(HierarchicalCollectionEvent.REMOVE_ALL, treeView_dataProvider_removeAllHandler);
			this._dataProvider.addEventListener(HierarchicalCollectionEvent.RESET, treeView_dataProvider_resetHandler);
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
		return this._dataProvider;
	}

	private var _selectedLocation:Array<Int> = null;

	/**
		The currently selected location. Returns `null` if no location is
		selected.

		The following example selects a specific location:

		```hx
		treeView.selectedLocation = [2, 0];
		```

		The following example clears the currently selected location:

		```hx
		treeView.selectedLocation = null;
		```

		The following example listens for when the selection changes, and it
		prints the new selected location to the debug console:

		```hx
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
	public var selectedItem(get, set):Dynamic;

	private function get_selectedItem():Dynamic {
		return this._selectedItem;
	}

	private function set_selectedItem(value:Dynamic):Dynamic {
		if (!this._selectable || this._dataProvider == null) {
			// use the setter
			this.selectedLocation = null;
			return this._selectedItem;
		}
		// use the setter
		this.selectedLocation = this._dataProvider.locationOf(value);
		return this._selectedItem;
	}

	private var _previousLayout:ILayout;

	/**
		The layout algorithm used to position and size the tree view's items.

		By default, if no layout is provided by the time that the tree view
		initializes, a default layout that displays items vertically will be
		created.

		The following example tells the tree view to use a horizontal layout:

		```hx
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

		@since 1.0.0
	**/
	@:style
	public var customItemRendererVariant:String = null;

	/**
		Manages item renderers used by the tree view.

		In the following example, the tree view uses a custom item renderer
		class:

		```hx
		treeView.itemRendererRecycler = DisplayObjectRecycler.withClass(CustomItemRenderer);
		```

		@since 1.0.0
	**/
	public var itemRendererRecycler(get, set):DisplayObjectRecycler<Dynamic, TreeViewItemState, DisplayObject>;

	private function get_itemRendererRecycler():DisplayObjectRecycler<Dynamic, TreeViewItemState, DisplayObject> {
		return this._defaultStorage.itemRendererRecycler;
	}

	private function set_itemRendererRecycler(value:DisplayObjectRecycler<Dynamic, TreeViewItemState, DisplayObject>):DisplayObjectRecycler<Dynamic,
		TreeViewItemState, DisplayObject> {
		if (this._defaultStorage.itemRendererRecycler == value) {
			return this._defaultStorage.itemRendererRecycler;
		}
		this._defaultStorage.oldItemRendererRecycler = this._defaultStorage.itemRendererRecycler;
		this._defaultStorage.itemRendererRecycler = value;
		this._defaultStorage.measurements = null;
		this.setInvalid(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		return this._defaultStorage.itemRendererRecycler;
	}

	private var _recyclerMap:Map<String, DisplayObjectRecycler<Dynamic, TreeViewItemState, DisplayObject>> = null;

	private var _itemRendererRecyclerIDFunction:(state:TreeViewItemState) -> String;

	/**
		When a tree view requires multiple item renderer types, this function is
		used to determine which type of item renderer is required for a specific
		item. Returns the ID of the item renderer recycler to use for the item,
		or `null` if the default `itemRendererRecycler` should be used.

		The following example provides an `itemRendererRecyclerIDFunction`:

		```hx
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
	private var dataToItemRenderer = new ObjectMap<Dynamic, DisplayObject>();
	private var itemRendererToItemState = new ObjectMap<DisplayObject, TreeViewItemState>();
	private var itemStatePool = new ObjectPool(() -> new TreeViewItemState());
	private var _unrenderedLocations:Array<Array<Int>> = [];
	private var _unrenderedLayoutIndices:Array<Int> = [];
	private var _virtualCache:Array<Dynamic> = [];
	private var _visibleIndices:VirtualLayoutRange = new VirtualLayoutRange(0, 0);
	private var _tempVisibleIndices:VirtualLayoutRange = new VirtualLayoutRange(0, 0);
	private var _layoutItems:Array<DisplayObject> = [];

	private var _selectable:Bool = true;

	/**
		Determines if items in the tree view may be selected. By default only a
		single item may be selected at any given time. In other words, if item
		_A_ is already selected, and the user selects item _B_, item _A_ will be
		deselected automatically.

		The following example disables selection of items in the tree view:

		```hx
		treeView.selectable = false;
		```

		@default true

		@see `TreeView.selectedItem`
		@see `TreeView.selectedIndex`
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

		```hx
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

		```hx
		treeView.pointerSelectionEnabled = false;
		```

		@since 1.0.0
	**/
	public var pointerSelectionEnabled:Bool = true;

	private var _ignoreSelectionChange = false;
	private var _ignoreOpenedChange = false;
	private var _ignoreLayoutChanges = false;

	/**
		Converts an item to text to display within tree view. By default, the
		`toString()` method is called to convert an item to text. This method
		may be replaced to provide custom text.

		For example, consider the following item:

		```hx
		{ text: "Example Item" }
		```

		If the `TreeView` should display the text "Example Item", a custom
		implementation of `itemToText()` might look like this:

		```hx
		treeView.itemToText = (item:Dynamic) -> {
			return item.text;
		};
		```

		@since 1.0.0
	**/
	public dynamic function itemToText(data:Dynamic):String {
		return Std.string(data);
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
		if (this._dataProvider == null || !this._dataProvider.contains(branch)) {
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
		var itemRenderer = this.dataToItemRenderer.get(branch);
		var state:TreeViewItemState = null;
		if (itemRenderer != null) {
			state = this.itemRendererToItemState.get(itemRenderer);
		}
		var isTemporary = false;
		if (state == null) {
			// if there is no existing state, use a temporary object
			isTemporary = true;
			state = this.itemStatePool.get();
			state.location = this._dataProvider.locationOf(branch);
			state.layoutIndex = -1;
		}
		var location = state.location;
		var layoutIndex = state.layoutIndex;
		if (open) {
			this.openBranches.push(branch);
			this.populateCurrentItemState(branch, location, layoutIndex, state);
			insertChildrenIntoVirtualCache(location, layoutIndex);
			TreeViewEvent.dispatch(this, TreeViewEvent.BRANCH_OPEN, state);
		} else {
			this.openBranches.remove(branch);
			this.populateCurrentItemState(branch, location, layoutIndex, state);
			removeChildrenFromVirtualCache(location, layoutIndex);
			TreeViewEvent.dispatch(this, TreeViewEvent.BRANCH_CLOSE, state);
		}
		if (isTemporary) {
			this.itemStatePool.release(state);
		}
		this.setInvalid(DATA);
	}

	/**
		Opens or closes all children of a branch recursively.

		@since 1.0.0
	**/
	public function toggleChildrenOf(branch:Dynamic, open:Bool):Void {
		if (this._dataProvider == null || !this._dataProvider.contains(branch)) {
			throw new ArgumentError("Cannot open branch because it is not in the data provider.");
		}
		if (!this._dataProvider.isBranch(branch)) {
			throw new ArgumentError("Cannot open item because it is not a branch.");
		}
		this.toggleBranch(branch, open);
		var location = this._dataProvider.locationOf(branch);
		var itemCount = this._dataProvider.getLength(location);
		for (i in 0...itemCount) {
			location.push(i);
			var child = this._dataProvider.get(location);
			if (this._dataProvider.isBranch(child)) {
				this.toggleChildrenOf(child, open);
			}
			location.pop();
		}
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
		return this.dataToItemRenderer.get(item);
	}

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
	public function setItemRendererRecycler(id:String, recycler:DisplayObjectRecycler<Dynamic, TreeViewItemState, DisplayObject>):Void {
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

	private function initializeTreeViewTheme():Void {
		SteelTreeViewStyles.initialize();
	}

	override private function update():Void {
		var layoutInvalid = this.isInvalid(LAYOUT);
		var stylesInvalid = this.isInvalid(STYLES);

		if (this._previousCustomItemRendererVariant != this.customItemRendererVariant) {
			this.setInvalidationFlag(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		}

		if (layoutInvalid || stylesInvalid) {
			if (this._previousLayout != this.layout) {
				this._layoutItems.resize(0);
				var newSize = this.calculateTotalLayoutCount([]);
				this._layoutItems.resize(newSize);
			}
			this.treeViewPort.layout = this.layout;
			this._previousLayout = this.layout;
		}

		this.treeViewPort.refreshChildren = this.refreshItemRenderers;

		for (flag in this._invalidationFlags.keys()) {
			this.treeViewPort.setInvalid(flag);
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
		this.scroller.snapPositionsX = this.treeViewPort.snapPositionsX;
		this.scroller.snapPositionsY = this.treeViewPort.snapPositionsY;
	}

	override private function needsScrollMeasurement():Bool {
		var oldStart = this._visibleIndices.start;
		var oldEnd = this._visibleIndices.end;
		if (this._virtualLayout && (this.layout is IVirtualLayout)) {
			var virtualLayout = cast(this.layout, IVirtualLayout);
			virtualLayout.scrollX = this.scrollX;
			virtualLayout.scrollY = this.scrollY;
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
			itemRenderer.removeEventListener(TriggerEvent.TRIGGER, treeView_itemRenderer_triggerHandler);
			itemRenderer.removeEventListener(MouseEvent.CLICK, treeView_itemRenderer_clickHandler);
			itemRenderer.removeEventListener(TouchEvent.TOUCH_TAP, treeView_itemRenderer_touchTapHandler);
			itemRenderer.removeEventListener(Event.CHANGE, treeView_itemRenderer_changeHandler);
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
		storage.inactiveItemRenderers.resize(0);
	}

	private function findUnrenderedData():Void {
		// remove all old items, then fill with null
		this._layoutItems.resize(0);
		var newSize = this.calculateTotalLayoutCount([]);
		this._layoutItems.resize(newSize);

		if (this._virtualLayout && (this.layout is IVirtualLayout)) {
			var virtualLayout = cast(this.layout, IVirtualLayout);
			var oldIgnoreLayoutChanges = this._ignoreLayoutChanges;
			this._ignoreLayoutChanges = true;
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
			if (this._dataProvider.isBranch(item) && this.openBranches.indexOf(item) != -1) {
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
		var state = this.itemRendererToItemState.get(itemRenderer);
		this.populateCurrentItemState(item, location, layoutIndex, state);
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
		var removed = storage.inactiveItemRenderers.remove(itemRenderer);
		if (!removed) {
			throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: item renderer map contains bad data for item at location ${location}. This may be caused by duplicate items in the data provider, which is not allowed.');
		}
		storage.activeItemRenderers.push(itemRenderer);
	}

	private function populateCurrentItemState(item:Dynamic, location:Array<Int>, layoutIndex:Int, state:TreeViewItemState):Void {
		state.owner = this;
		state.data = item;
		state.location = location;
		state.layoutIndex = layoutIndex;
		state.branch = this._dataProvider != null && this._dataProvider.isBranch(item);
		state.opened = state.branch && (this.openBranches.indexOf(item) != -1);
		state.selected = item == this._selectedItem;
		state.enabled = this._enabled;
		state.text = itemToText(item);
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
			var uiControl = cast(itemRenderer, IUIControl);
			uiControl.enabled = state.enabled;
		}
		if ((itemRenderer is IDataRenderer)) {
			var dataRenderer = cast(itemRenderer, IDataRenderer);
			// if the renderer is an IDataRenderer, this cannot be overridden
			dataRenderer.data = state.data;
		}
		if ((itemRenderer is IToggle)) {
			var toggle = cast(itemRenderer, IToggle);
			// if the renderer is an IToggle, this cannot be overridden
			toggle.selected = state.selected;
		}
		if ((itemRenderer is IHierarchicalItemRenderer)) {
			var hierarchicalItem = cast(itemRenderer, IHierarchicalItemRenderer);
			hierarchicalItem.branch = state.branch;
		}
		if ((itemRenderer is IHierarchicalDepthItemRenderer)) {
			var depthItem = cast(itemRenderer, IHierarchicalDepthItemRenderer);
			depthItem.hierarchyDepth = (state.location != null) ? (state.location.length - 1) : 0;
		}
		if ((itemRenderer is ITreeViewItemRenderer)) {
			var treeItem = cast(itemRenderer, ITreeViewItemRenderer);
			treeItem.location = state.location;
			treeItem.treeViewOwner = state.owner;
		}
		if ((itemRenderer is ILayoutIndexObject)) {
			var layoutIndexObject = cast(itemRenderer, ILayoutIndexObject);
			layoutIndexObject.layoutIndex = state.layoutIndex;
		}
		if ((itemRenderer is IOpenCloseToggle)) {
			var openCloseItem = cast(itemRenderer, IOpenCloseToggle);
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
			this.populateCurrentItemState(item, location, layoutIndex, state);
			var itemRenderer = this.createItemRenderer(state);
			itemRenderer.visible = true;
			this.treeViewPort.addChild(itemRenderer);
			this._layoutItems[layoutIndex] = itemRenderer;
		}
		this._unrenderedLocations.resize(0);
	}

	private function createItemRenderer(state:TreeViewItemState):DisplayObject {
		var storage = this.itemStateToStorage(state);
		var itemRenderer:DisplayObject = null;
		if (storage.inactiveItemRenderers.length == 0) {
			itemRenderer = storage.itemRendererRecycler.create();
			if ((itemRenderer is IVariantStyleObject)) {
				var variantItemRenderer = cast(itemRenderer, IVariantStyleObject);
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
		if ((itemRenderer is IOpenCloseToggle)) {
			itemRenderer.addEventListener(Event.OPEN, treeView_itemRenderer_openHandler);
			itemRenderer.addEventListener(Event.CLOSE, treeView_itemRenderer_closeHandler);
		}
		this.itemRendererToItemState.set(itemRenderer, state);
		this.dataToItemRenderer.set(state.data, itemRenderer);
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
			if (this._dataProvider.isBranch(item) && this.openBranches.indexOf(item) != -1) {
				result += this.calculateTotalLayoutCount(location);
			}
			location.pop();
		}
		return result;
	}

	private function insertChildrenIntoVirtualCache(location:Array<Int>, layoutIndex:Int):Void {
		var length = this._dataProvider.getLength(location);
		for (i in 0...length) {
			location.push(i);
			layoutIndex++;
			this._virtualCache.insert(layoutIndex, null);
			var item = this._dataProvider.get(location);
			if (this._dataProvider.isBranch(item) && this.openBranches.indexOf(item) != -1) {
				insertChildrenIntoVirtualCache(location, layoutIndex);
			}
			location.pop();
		}
	}

	private function removeChildrenFromVirtualCache(location:Array<Int>, layoutIndex:Int):Void {
		var length = this._dataProvider.getLength(location);
		for (i in 0...length) {
			location.push(i);
			layoutIndex++;
			this._virtualCache.remove(layoutIndex);
			var item = this._dataProvider.get(location);
			if (this._dataProvider.isBranch(item) && this.openBranches.indexOf(item) != -1) {
				removeChildrenFromVirtualCache(location, layoutIndex);
			}
			location.pop();
		}
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
			result = cast(this.layout, IKeyboardNavigationLayout).findNextKeyboardIndex(result, event, false, this._layoutItems, null,
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
		if (result == startIndex) {
			return;
		}
		event.preventDefault();
		// use the setter
		this.selectedLocation = this.displayIndexToLocation(result);
		if (this._selectedLocation != null) {
			this.scrollToLocation(this._selectedLocation);
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
		if (!this._enabled || event.isDefaultPrevented() || this._dataProvider == null) {
			return;
		}
		if (event.keyCode == Keyboard.LEFT) {
			if (this._dataProvider.isBranch(this._selectedItem)) {
				if (this.openBranches.indexOf(this._selectedItem) != -1) {
					this.toggleBranch(this._selectedItem, false);
					return;
				}
			}
			var parentLocation = this._selectedLocation.copy();
			parentLocation.pop();
			if (parentLocation.length > 0) {
				this.selectedLocation = parentLocation;
			}
		}
		if (event.keyCode == Keyboard.RIGHT) {
			if (this._dataProvider.isBranch(this._selectedItem)) {
				if (this.openBranches.indexOf(this._selectedItem) == -1) {
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
				var itemRenderer = this.dataToItemRenderer.get(this._selectedItem);
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
				this.populateCurrentItemState(this._selectedItem, this._selectedLocation, layoutIndex, state);
				TreeViewEvent.dispatch(this, TreeViewEvent.ITEM_TRIGGER, state);
				if (isTemporary) {
					this.itemStatePool.release(state);
				}
			}
		}

		if (this._selectedLocation != null && event.keyCode == Keyboard.SPACE) {
			if (this._dataProvider.isBranch(this._selectedItem)) {
				event.preventDefault();
				this.toggleBranch(this._selectedItem, this.openBranches.indexOf(this._selectedItem) == -1);
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

	private function treeView_itemRenderer_touchTapHandler(event:TouchEvent):Void {
		if (!this._enabled) {
			return;
		}
		if (event.isPrimaryTouchPoint #if air && Multitouch.mapTouchToMouse #end) {
			// ignore the primary one because MouseEvent.CLICK will catch it
			return;
		}

		var itemRenderer = cast(event.currentTarget, DisplayObject);
		var state = this.itemRendererToItemState.get(itemRenderer);
		TreeViewEvent.dispatch(this, TreeViewEvent.ITEM_TRIGGER, state);

		if (!this._selectable || !this.pointerSelectionEnabled) {
			return;
		}
		// use the setter
		this.selectedLocation = state.location.copy();
	}

	private function treeView_itemRenderer_clickHandler(event:MouseEvent):Void {
		if (!this._enabled) {
			return;
		}
		var itemRenderer = cast(event.currentTarget, DisplayObject);
		var state = this.itemRendererToItemState.get(itemRenderer);
		TreeViewEvent.dispatch(this, TreeViewEvent.ITEM_TRIGGER, state);

		if (!this._selectable || !this.pointerSelectionEnabled) {
			return;
		}
		// use the setter
		this.selectedLocation = state.location.copy();
	}

	private function treeView_itemRenderer_triggerHandler(event:TriggerEvent):Void {
		if (!this._enabled) {
			return;
		}
		var itemRenderer = cast(event.currentTarget, DisplayObject);
		var state = this.itemRendererToItemState.get(itemRenderer);
		TreeViewEvent.dispatch(this, TreeViewEvent.ITEM_TRIGGER, state);

		if (!this._selectable || !this.pointerSelectionEnabled) {
			return;
		}
		// use the setter
		this.selectedLocation = state.location.copy();
	}

	private function treeView_itemRenderer_changeHandler(event:Event):Void {
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

	private function treeView_itemRenderer_openHandler(event:Event):Void {
		if (this._ignoreOpenedChange) {
			return;
		}
		var itemRenderer = cast(event.currentTarget, DisplayObject);
		var state = this.itemRendererToItemState.get(itemRenderer);
		this.toggleBranch(state.data, true);
	}

	private function treeView_itemRenderer_closeHandler(event:Event):Void {
		if (this._ignoreOpenedChange) {
			return;
		}
		var itemRenderer = cast(event.currentTarget, DisplayObject);
		var state = this.itemRendererToItemState.get(itemRenderer);
		this.toggleBranch(state.data, false);
	}

	private function treeView_dataProvider_changeHandler(event:Event):Void {
		if (this._virtualCache != null) {
			this._virtualCache.resize(0);
			var newSize = this.calculateTotalLayoutCount([]);
			this._virtualCache.resize(newSize);
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
		if (this._selectedLocation == null) {
			return;
		}

		var comparisonResult = this.compareLocations(this._selectedLocation, event.location);
		if (comparisonResult == 0) {
			// use the setter
			this.selectedLocation = null;
		} else if (comparisonResult > 0) {
			// use the setter
			this.selectedLocation = this._dataProvider.locationOf(this._selectedItem);
		}
	}

	private function treeView_dataProvider_replaceItemHandler(event:HierarchicalCollectionEvent):Void {
		if (this._selectedLocation == null) {
			return;
		}
		if (this.compareLocations(this._selectedLocation, event.location) == 0) {
			// unlike when an item is removed, the selected index is kept when
			// an item is replaced
			this._selectedItem = this._dataProvider.get(event.location);
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
	}

	private function treeView_dataProvider_removeAllHandler(event:HierarchicalCollectionEvent):Void {
		// use the setter
		this.selectedLocation = null;
	}

	private function treeView_dataProvider_resetHandler(event:HierarchicalCollectionEvent):Void {
		// use the setter
		this.selectedLocation = null;
	}

	private function updateItemRendererForLocation(location:Array<Int>):Void {
		var layoutIndex = this.locationToDisplayIndex(location, false);
		if (this._virtualCache != null && layoutIndex != -1) {
			this._virtualCache[layoutIndex] = null;
		}
		var item = this._dataProvider.get(location);
		var itemRenderer = this.dataToItemRenderer.get(item);

		if (itemRenderer == null) {
			// doesn't exist yet, so we need to do a full invalidation
			this.setInvalid(DATA);
		} else {
			var state = this.itemRendererToItemState.get(itemRenderer);
			var storage = this.itemStateToStorage(state);
			this.populateCurrentItemState(item, location, layoutIndex, state);
			// in order to display the same item with modified properties, this
			// hack tricks the item renderer into thinking that it has been given
			// a different item to render.
			this.resetItemRenderer(itemRenderer, state, storage);
			if (storage.measurements != null) {
				storage.measurements.restore(itemRenderer);
			}
			this.updateItemRenderer(itemRenderer, state, storage);
			this.setInvalid(LAYOUT);
		}
		if (this._dataProvider.isBranch(item)) {
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

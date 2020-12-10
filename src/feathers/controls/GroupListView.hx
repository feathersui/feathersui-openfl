/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

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
import feathers.core.ITextControl;
import feathers.core.IUIControl;
import feathers.data.GroupListViewItemState;
import feathers.data.GroupListViewItemType;
import feathers.data.IHierarchicalCollection;
import feathers.events.FeathersEvent;
import feathers.events.GroupListViewEvent;
import feathers.events.HierarchicalCollectionEvent;
import feathers.events.TriggerEvent;
import feathers.layout.ILayout;
import feathers.layout.IScrollLayout;
import feathers.layout.IVirtualLayout;
import feathers.style.IVariantStyleObject;
import feathers.themes.steel.components.SteelGroupListViewStyles;
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

/**
	Displays a list of items divided into groups or sections. Accepts a
	hierarchical tree of items, similar to `TreeView`, but limits the display to
	two levels of hierarchy at most. Supports scrolling, custom item renderers,
	and custom layouts.

	The following example creates a group list, gives it a data provider, tells
	the item renderer how to interpret the data, and listens for when the
	selection changes:

	```hx
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

	@see [Tutorial: How to use the GroupListView component](https://feathersui.com/learn/haxe-openfl/group-list-view/)

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
@:access(feathers.data.GroupListViewItemState)
@defaultXmlProperty("dataProvider")
@:styleContext
class GroupListView extends BaseScrollContainer implements IDataSelector<Dynamic> {
	/**
		The variant used to style the group headers in a theme.

		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_HEADER = "groupListView_header";

	/**
		A variant used to style the group list view without a border. The
		variant is used by default on mobile.

		The following example uses this variant:

		```hx
		var groupListView = new GroupListView();
		groupListView.variant = GroupListView.VARIANT_BORDERLESS;
		```

		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final VARIANT_BORDERLESS = "borderless";

	/**
		A variant used to style the group list view with a border. This variant
		is used by default on desktop.

		The following example uses this variant:

		```hx
		var groupListView = new GroupListView();
		groupListView.variant = GroupListView.VARIANT_BORDER;
		```

		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final VARIANT_BORDER = "border";

	private static final INVALIDATION_FLAG_ITEM_RENDERER_FACTORY = InvalidationFlag.CUSTOM("itemRendererFactory");

	private static function defaultUpdateItemRenderer(itemRenderer:DisplayObject, state:GroupListViewItemState):Void {
		if (Std.is(itemRenderer, ITextControl)) {
			var textControl = cast(itemRenderer, ITextControl);
			textControl.text = state.text;
		}
	}

	private static function defaultResetItemRenderer(itemRenderer:DisplayObject, state:GroupListViewItemState):Void {
		if (Std.is(itemRenderer, ITextControl)) {
			var textControl = cast(itemRenderer, ITextControl);
			textControl.text = null;
		}
	}

	/**
		Creates a new `GroupListView` object.

		@since 1.0.0
	**/
	public function new() {
		initializeGroupListViewTheme();

		super();

		this.tabEnabled = true;
		this.focusRect = null;

		if (this.viewPort == null) {
			this.groupViewPort = new AdvancedLayoutViewPort();
			this.addChild(this.groupViewPort);
			this.viewPort = this.groupViewPort;
		}
	}

	private var groupViewPort:AdvancedLayoutViewPort;

	override private function get_focusEnabled():Bool {
		return (this._selectable || this.maxScrollY != this.minScrollY || this.maxScrollX != this.minScrollX)
			&& this._enabled
			&& this._focusEnabled;
	}

	private var _dataProvider:IHierarchicalCollection<Dynamic> = null;

	/**
		The collection of data displayed by the group list view.

		The following example passes in a data provider and tells the item
		renderer how to interpret the data:

		```hx
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
	@:flash.property
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

		```hx
		groupListView.selectedLocation = [2, 0];
		```

		The following example clears the currently selected location:

		```hx
		groupListView.selectedLocation = null;
		```

		The following example listens for when the selection changes, and it
		prints the new selected location to the debug console:

		```hx
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
	@:flash.property
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
	@:flash.property
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
		The layout algorithm used to position and size the group list view's
		items.

		By default, if no layout is provided by the time that the group list
		view initializes, a default layout that displays items vertically will
		be created.

		The following example tells the group list view to use a horizontal
		layout:

		```hx
		var layout = new HorizontalListLayout();
		layout.gap = 20.0;
		layout.padding = 20.0;
		groupListView.layout = layout;
		```

		@since 1.0.0
	**/
	@:style
	public var layout:ILayout = null;

	private var _previousCustomItemRendererVariant:String = null;

	/**
		A custom variant to set on all item renderers.

		@since 1.0.0
	**/
	@:style
	public var customItemRendererVariant:String = null;

	/**
		Manages item renderers used by the group list view.

		In the following example, the group list view uses a custom item
		renderer class:

		```hx
		groupListView.itemRendererRecycler = DisplayObjectRecycler.withClass(CustomItemRenderer);
		```

		@since 1.0.0
	**/
	@:flash.property
	public var itemRendererRecycler(get, set):DisplayObjectRecycler<Dynamic, GroupListViewItemState, DisplayObject>;

	private function get_itemRendererRecycler():DisplayObjectRecycler<Dynamic, GroupListViewItemState, DisplayObject> {
		return this._defaultItemStorage.itemRendererRecycler;
	}

	private function set_itemRendererRecycler(value:DisplayObjectRecycler<Dynamic, GroupListViewItemState, DisplayObject>):DisplayObjectRecycler<Dynamic,
		GroupListViewItemState, DisplayObject> {
		if (this._defaultItemStorage.itemRendererRecycler == value) {
			return this._defaultItemStorage.itemRendererRecycler;
		}
		this._defaultItemStorage.oldItemRendererRecycler = this._defaultItemStorage.itemRendererRecycler;
		this._defaultItemStorage.itemRendererRecycler = value;
		this.setInvalid(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		return this._defaultItemStorage.itemRendererRecycler;
	}

	/**
		Manages header renderers used by the group list view.

		In the following example, the group list view uses a custom header
		renderer class:

		```hx
		groupListView.headerRendererRecycler = DisplayObjectRecycler.withClass(CustomHeaderRenderer);
		```

		@default null

		@since 1.0.0
	**/
	@:flash.property
	public var headerRendererRecycler(get, set):DisplayObjectRecycler<Dynamic, GroupListViewItemState, DisplayObject>;

	private function get_headerRendererRecycler():DisplayObjectRecycler<Dynamic, GroupListViewItemState, DisplayObject> {
		return this._defaultHeaderStorage.itemRendererRecycler;
	}

	private function set_headerRendererRecycler(value:DisplayObjectRecycler<Dynamic, GroupListViewItemState, DisplayObject>):DisplayObjectRecycler<Dynamic,
		GroupListViewItemState, DisplayObject> {
		if (this._defaultHeaderStorage.itemRendererRecycler == value) {
			return this._defaultHeaderStorage.itemRendererRecycler;
		}
		this._defaultHeaderStorage.oldItemRendererRecycler = this._defaultHeaderStorage.itemRendererRecycler;
		this._defaultHeaderStorage.itemRendererRecycler = value;
		this.setInvalid(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		return this._defaultHeaderStorage.itemRendererRecycler;
	}

	private var _defaultItemStorage = new ItemRendererStorage(STANDARD, DisplayObjectRecycler.withClass(ItemRenderer));
	private var _defaultHeaderStorage = new ItemRendererStorage(HEADER, DisplayObjectRecycler.withClass(ItemRenderer));
	private var _additionalStorage:Array<ItemRendererStorage> = null;
	private var dataToItemRenderer = new ObjectMap<Dynamic, DisplayObject>();
	private var itemRendererToData = new ObjectMap<DisplayObject, Dynamic>();
	private var itemRendererToLayoutIndex = new ObjectMap<DisplayObject, Int>();
	private var _unrenderedLocations:Array<Array<Int>> = [];
	private var _unrenderedLayoutIndices:Array<Int> = [];
	private var _virtualCache:Array<Dynamic> = [];
	private var _visibleIndices:VirtualLayoutRange = new VirtualLayoutRange(0, 0);

	private var _currentItemState = new GroupListViewItemState();

	private var _selectable:Bool = true;

	/**
		Determines if items in the group list view may be selected. By default,
		only a single item may be selected at any given time. In other words, if
		item _A_ is already selected, and the user selects item _B_, item _A_
		will be deselected automatically.

		The following example disables selection of items in the group list
		view:

		```hx
		groupListView.selectable = false;
		```

		@default true

		@see `GroupListView.selectedItem`
		@see `GroupListView.selectedIndex`
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
			this.selectedLocation = null;
		}
		return this._selectable;
	}

	private var _virtualLayout:Bool = true;

	/**
		Indicates if the group list view's layout is allowed to virtualize items
		or not.

		The following example disables virtual layouts:

		```hx
		groupListView.virtualLayout = false;
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

		```hx
		{ text: "Example Item" }
		```

		If the `GroupListView` should display the text "Example Item", a custom
		implementation of `itemToText()` might look like this:

		```hx
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

		```hx
		{ text: "Example Section" }
		```

		If the `GroupListView` should display the text "Example Item", a custom
		implementation of `itemToHeaderText()` might look like this:

		```hx
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
		return this.itemRendererToData.get(itemRenderer);
	}

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

		var targetX = this.scrollX;
		var targetY = this.scrollY;
		if (Std.is(this.layout, IScrollLayout)) {
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
		this.scroller.scrollX = targetX;
		this.scroller.scrollY = targetY;
	}

	private function initializeGroupListViewTheme():Void {
		SteelGroupListViewStyles.initialize();
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
				this._layoutItems.resize(0);
				var newSize = this.calculateTotalLayoutCount([]);
				this._layoutItems.resize(newSize);
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
		this.refreshInactiveItemRenderers(this._defaultItemStorage, itemRendererInvalid);
		this.refreshInactiveItemRenderers(this._defaultHeaderStorage, itemRendererInvalid);
		if (this._additionalStorage != null) {
			for (i in 0...this._additionalStorage.length) {
				var storage = this._additionalStorage[i];
				this.refreshInactiveItemRenderers(storage, itemRendererInvalid);
			}
		}
		this.findUnrenderedData();
		this.recoverInactiveItemRenderers(this._defaultItemStorage);
		this.recoverInactiveItemRenderers(this._defaultHeaderStorage);
		if (this._additionalStorage != null) {
			for (i in 0...this._additionalStorage.length) {
				var storage = this._additionalStorage[i];
				this.recoverInactiveItemRenderers(storage);
			}
		}
		this.renderUnrenderedData();
		this.freeInactiveItemRenderers(this._defaultItemStorage);
		this.freeInactiveItemRenderers(this._defaultHeaderStorage);
		if (this._additionalStorage != null) {
			for (i in 0...this._additionalStorage.length) {
				var storage = this._additionalStorage[i];
				this.freeInactiveItemRenderers(storage);
			}
		}
		if (this._defaultItemStorage.inactiveItemRenderers.length > 0) {
			throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: inactive item renderers should be empty after updating.');
		}
		if (this._defaultHeaderStorage.inactiveItemRenderers.length > 0) {
			throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: inactive header renderers should be empty after updating.');
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
		var recycler = storage.oldItemRendererRecycler != null ? storage.oldItemRendererRecycler : storage.itemRendererRecycler;
		for (itemRenderer in storage.inactiveItemRenderers) {
			if (itemRenderer == null) {
				continue;
			}
			var item = this.itemRendererToData.get(itemRenderer);
			if (item == null) {
				return;
			}
			this.itemRendererToData.remove(itemRenderer);
			this.itemRendererToLayoutIndex.remove(itemRenderer);
			this.dataToItemRenderer.remove(item);
			if (storage.type == STANDARD) {
				itemRenderer.removeEventListener(TriggerEvent.TRIGGER, groupListView_itemRenderer_triggerHandler);
				itemRenderer.removeEventListener(MouseEvent.CLICK, groupListView_itemRenderer_clickHandler);
				itemRenderer.removeEventListener(TouchEvent.TOUCH_TAP, groupListView_itemRenderer_touchTapHandler);
				itemRenderer.removeEventListener(Event.CHANGE, groupListView_itemRenderer_changeHandler);
			}
			this._currentItemState.owner = this;
			this._currentItemState.type = storage.type;
			this._currentItemState.data = item;
			this._currentItemState.location = null;
			this._currentItemState.layoutIndex = -1;
			this._currentItemState.selected = false;
			this._currentItemState.text = null;
			this._currentItemState.enabled = true;
			var oldIgnoreSelectionChange = this._ignoreSelectionChange;
			this._ignoreSelectionChange = true;
			if (recycler != null && recycler.reset != null) {
				recycler.reset(itemRenderer, this._currentItemState);
			}
			if (Std.is(itemRenderer, IUIControl)) {
				var uiControl = cast(itemRenderer, IUIControl);
				uiControl.enabled = this._currentItemState.enabled;
			}
			if (Std.is(itemRenderer, IToggle)) {
				var toggle = cast(itemRenderer, IToggle);
				toggle.selected = this._currentItemState.selected;
			}
			if (Std.is(itemRenderer, IDataRenderer)) {
				var dataRenderer = cast(itemRenderer, IDataRenderer);
				dataRenderer.data = this._currentItemState.data;
			}
			if (Std.is(itemRenderer, IGroupListViewItemRenderer)) {
				var groupListRenderer = cast(itemRenderer, IGroupListViewItemRenderer);
				groupListRenderer.location = this._currentItemState.location;
			}
			this._ignoreSelectionChange = oldIgnoreSelectionChange;
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

		if (this._virtualLayout && Std.is(this.layout, IVirtualLayout)) {
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
		var recycler:DisplayObjectRecycler<Dynamic, GroupListViewItemState, DisplayObject> = null;
		var storage = this.itemRendererRecyclerToStorage(type, recycler);
		this.refreshItemRendererProperties(itemRenderer, type, item, location, layoutIndex);
		// if this item renderer used to be the typical layout item, but
		// it isn't anymore, it may have been set invisible
		itemRenderer.visible = true;
		this._layoutItems[layoutIndex] = itemRenderer;
		var removed = storage.inactiveItemRenderers.remove(itemRenderer);
		if (!removed) {
			throw new IllegalOperationError('${Type.getClassName(Type.getClass(this))}: item renderer map contains bad data. This may be caused by duplicate items in the data provider, which is not allowed.');
		}
		storage.activeItemRenderers.push(itemRenderer);
	}

	private function renderUnrenderedData():Void {
		for (location in this._unrenderedLocations) {
			var layoutIndex = this._unrenderedLayoutIndices.shift();
			var item = this._dataProvider.get(location);
			var itemRenderer = this.createItemRenderer(item, location, layoutIndex);
			itemRenderer.visible = true;
			this.groupViewPort.addChild(itemRenderer);
			this._layoutItems[layoutIndex] = itemRenderer;
		}
		this._unrenderedLocations.resize(0);
	}

	private function createItemRenderer(item:Dynamic, location:Array<Int>, layoutIndex:Int):DisplayObject {
		var type = location.length == 1 ? HEADER : STANDARD;
		var recycler:DisplayObjectRecycler<Dynamic, GroupListViewItemState, DisplayObject> = null;
		var storage = this.itemRendererRecyclerToStorage(type, recycler);
		var itemRenderer:DisplayObject = null;
		if (storage.inactiveItemRenderers.length == 0) {
			itemRenderer = storage.itemRendererRecycler.create();
			if (this.customItemRendererVariant != null && Std.is(itemRenderer, IVariantStyleObject)) {
				var variantItemRenderer = cast(itemRenderer, IVariantStyleObject);
				if (variantItemRenderer.variant == null) {
					variantItemRenderer.variant = this.customItemRendererVariant;
				}
			}
		} else {
			itemRenderer = storage.inactiveItemRenderers.shift();
		}
		if (type == HEADER && Std.is(itemRenderer, IVariantStyleObject)) {
			var variantItemRenderer = cast(itemRenderer, IVariantStyleObject);
			if (variantItemRenderer.variant == null) {
				variantItemRenderer.variant = GroupListView.CHILD_VARIANT_HEADER;
			}
		}
		this.refreshItemRendererProperties(itemRenderer, type, item, location, layoutIndex);
		if (type == STANDARD) {
			if (Std.is(itemRenderer, ITriggerView)) {
				itemRenderer.addEventListener(TriggerEvent.TRIGGER, groupListView_itemRenderer_triggerHandler);
			} else {
				itemRenderer.addEventListener(MouseEvent.CLICK, groupListView_itemRenderer_clickHandler);
				#if (openfl >= "9.0.0")
				itemRenderer.addEventListener(TouchEvent.TOUCH_TAP, groupListView_itemRenderer_touchTapHandler);
				#end
			}
			if (Std.is(itemRenderer, IToggle)) {
				itemRenderer.addEventListener(Event.CHANGE, groupListView_itemRenderer_changeHandler);
			}
		}
		this.itemRendererToData.set(itemRenderer, item);
		this.itemRendererToLayoutIndex.set(itemRenderer, layoutIndex);
		this.dataToItemRenderer.set(item, itemRenderer);
		storage.activeItemRenderers.push(itemRenderer);
		return itemRenderer;
	}

	private function destroyItemRenderer(itemRenderer:DisplayObject, recycler:DisplayObjectRecycler<Dynamic, GroupListViewItemState, DisplayObject>):Void {
		this.groupViewPort.removeChild(itemRenderer);
		if (recycler != null && recycler.destroy != null) {
			recycler.destroy(itemRenderer);
		}
	}

	private function itemRendererRecyclerToStorage(type:GroupListViewItemType,
			recycler:DisplayObjectRecycler<Dynamic, GroupListViewItemState, DisplayObject>):ItemRendererStorage {
		if (recycler == null) {
			return type == HEADER ? this._defaultHeaderStorage : this._defaultItemStorage;
		}
		if (this._additionalStorage == null) {
			this._additionalStorage = [];
		}
		for (i in 0...this._additionalStorage.length) {
			var storage = this._additionalStorage[i];
			if (storage.type == type && storage.itemRendererRecycler == recycler) {
				return storage;
			}
		}
		var storage = new ItemRendererStorage(type, recycler);
		this._additionalStorage.push(storage);
		return storage;
	}

	private function populateCurrentItemState(item:Dynamic, type:GroupListViewItemType, location:Array<Int>, layoutIndex:Int):Void {
		this._currentItemState.owner = this;
		this._currentItemState.type = type;
		this._currentItemState.data = item;
		this._currentItemState.location = location;
		this._currentItemState.layoutIndex = layoutIndex;
		this._currentItemState.selected = location.length > 1 && item == this._selectedItem;
		this._currentItemState.enabled = this._enabled;
		this._currentItemState.text = type == HEADER ? itemToHeaderText(item) : itemToText(item);
	}

	private function refreshItemRendererProperties(itemRenderer:DisplayObject, type:GroupListViewItemType, item:Dynamic, location:Array<Int>,
			layoutIndex:Int):Void {
		var type = location.length == 1 ? HEADER : STANDARD;
		var recycler:DisplayObjectRecycler<Dynamic, GroupListViewItemState, DisplayObject> = null;
		var storage = this.itemRendererRecyclerToStorage(type, recycler);
		this.populateCurrentItemState(item, type, location, layoutIndex);
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		if (storage.itemRendererRecycler.update != null) {
			storage.itemRendererRecycler.update(itemRenderer, this._currentItemState);
		}
		if (Std.is(itemRenderer, IUIControl)) {
			var uiControl = cast(itemRenderer, IUIControl);
			uiControl.enabled = this._currentItemState.enabled;
		}
		if (Std.is(itemRenderer, IDataRenderer)) {
			var dataRenderer = cast(itemRenderer, IDataRenderer);
			// if the renderer is an IDataRenderer, this cannot be overridden
			dataRenderer.data = this._currentItemState.data;
		}
		if (Std.is(itemRenderer, IGroupListViewItemRenderer)) {
			var groupListRenderer = cast(itemRenderer, IGroupListViewItemRenderer);
			groupListRenderer.location = this._currentItemState.location;
		}
		if (Std.is(itemRenderer, IToggle)) {
			var toggle = cast(itemRenderer, IToggle);
			// if the renderer is an IToggle, this cannot be overridden
			toggle.selected = this._currentItemState.selected;
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

	private function insertChildrenIntoVirtualCache(location:Array<Int>, layoutIndex:Int):Void {
		var length = this._dataProvider.getLength(location);
		for (i in 0...length) {
			location.push(i);
			layoutIndex++;
			this._virtualCache.insert(layoutIndex, null);
			var item = this._dataProvider.get(location);
			if (location.length == 1 && this._dataProvider.isBranch(item)) {
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
			if (location.length == 1 && this._dataProvider.isBranch(item)) {
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

	private function dispatchItemTriggerEvent(data:Dynamic):Void {
		var location = this._dataProvider.locationOf(data);
		var type = location.length == 1 ? HEADER : STANDARD;
		var layoutIndex = this.locationToDisplayIndex(location);
		this.populateCurrentItemState(data, type, location, layoutIndex);
		GroupListViewEvent.dispatch(this, GroupListViewEvent.ITEM_TRIGGER, this._currentItemState);
	}

	private function navigateWithKeyboard(event:KeyboardEvent):Void {
		if (this._layoutItems.length == 0) {
			return;
		}
		var startIndex = this.locationToDisplayIndex(this._selectedLocation);
		var result = startIndex;
		var location:Array<Int> = null;
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
		event.stopPropagation();
		// use the setter
		this.selectedLocation = location;
		if (this._selectedLocation != null) {
			this.scrollToLocation(this._selectedLocation);
		}
	}

	override private function baseScrollContainer_keyDownHandler(event:KeyboardEvent):Void {
		if (!this._enabled || event.isDefaultPrevented()) {
			return;
		}
		this.navigateWithKeyboard(event);
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
		var item = this.itemRendererToData.get(itemRenderer);
		this.dispatchItemTriggerEvent(item);

		if (!this._selectable || !this.pointerSelectionEnabled) {
			return;
		}
		var itemRenderer = cast(event.currentTarget, DisplayObject);
		var data = this.itemRendererToData.get(itemRenderer);
		var location = this._dataProvider.locationOf(data);
		if (location == null || location.length != 2) {
			return;
		}
		// use the setter
		this.selectedLocation = location;
	}

	private function groupListView_itemRenderer_clickHandler(event:MouseEvent):Void {
		if (!this._enabled) {
			return;
		}

		var itemRenderer = cast(event.currentTarget, DisplayObject);
		var item = this.itemRendererToData.get(itemRenderer);
		this.dispatchItemTriggerEvent(item);

		if (!this._selectable || !this.pointerSelectionEnabled) {
			return;
		}
		var itemRenderer = cast(event.currentTarget, DisplayObject);
		var data = this.itemRendererToData.get(itemRenderer);
		var location = this._dataProvider.locationOf(data);
		if (location == null || location.length != 2) {
			return;
		}
		// use the setter
		this.selectedLocation = location;
	}

	private function groupListView_itemRenderer_triggerHandler(event:TriggerEvent):Void {
		if (!this._enabled) {
			return;
		}

		var itemRenderer = cast(event.currentTarget, DisplayObject);
		var item = this.itemRendererToData.get(itemRenderer);
		this.dispatchItemTriggerEvent(item);

		if (!this._selectable) {
			return;
		}
		var itemRenderer = cast(event.currentTarget, DisplayObject);
		var data = this.itemRendererToData.get(itemRenderer);
		var location = this._dataProvider.locationOf(data);
		if (location == null || location.length != 2) {
			return;
		}
		// use the setter
		this.selectedLocation = location;
	}

	private function groupListView_itemRenderer_changeHandler(event:Event):Void {
		if (this._ignoreSelectionChange) {
			return;
		}
		// if we get here, the selected property of the renderer changed
		// unexpectedly, and we need to restore its proper state
		this.setInvalid(SELECTION);
	}

	private function groupListView_dataProvider_changeHandler(event:Event):Void {
		if (this._virtualCache != null) {
			this._virtualCache.resize(0);
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

	private function groupListView_dataProvider_replaceItemHandler(event:HierarchicalCollectionEvent):Void {
		if (this._selectedLocation == null) {
			return;
		}
		if (this.compareLocations(this._selectedLocation, event.location) == 0) {
			this._selectedItem = this._dataProvider.get(event.location);
			FeathersEvent.dispatch(this, Event.CHANGE);
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
		var item = this._dataProvider.get(location);
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
		var type = location.length == 1 ? HEADER : STANDARD;
		var layoutIndex = this.locationToDisplayIndex(location);
		this.refreshItemRendererProperties(itemRenderer, type, item, location, layoutIndex);
		if (type == HEADER) {
			for (i in 0...this._dataProvider.getLength(location)) {
				location.push(i);
				this.updateItemRendererForLocation(location);
				location.pop();
			}
		}
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
	public function new(type:GroupListViewItemType, ?recycler:DisplayObjectRecycler<Dynamic, GroupListViewItemState, DisplayObject>) {
		this.type = type;
		this.itemRendererRecycler = recycler;
	}

	public var type:GroupListViewItemType;
	public var oldItemRendererRecycler:DisplayObjectRecycler<Dynamic, GroupListViewItemState, DisplayObject>;
	public var itemRendererRecycler:DisplayObjectRecycler<Dynamic, GroupListViewItemState, DisplayObject>;
	public var activeItemRenderers:Array<DisplayObject> = [];
	public var inactiveItemRenderers:Array<DisplayObject> = [];
}

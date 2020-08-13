/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import openfl.errors.ArgumentError;
import feathers.style.IVariantStyleObject;
import feathers.data.GroupListViewItemType;
import feathers.controls.dataRenderers.IDataRenderer;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.controls.supportClasses.AdvancedLayoutViewPort;
import feathers.controls.supportClasses.BaseScrollContainer;
import feathers.core.IDataSelector;
import feathers.core.ITextControl;
import feathers.core.InvalidationFlag;
import feathers.data.GroupListViewItemState;
import feathers.data.IHierarchicalCollection;
import feathers.events.FeathersEvent;
import feathers.events.HierarchicalCollectionEvent;
import feathers.layout.ILayout;
import feathers.layout.IScrollLayout;
import feathers.layout.IVirtualLayout;
import feathers.themes.steel.components.SteelGroupListViewStyles;
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

	groupListView.itemToText = (item:Dynamic) -> {
		return item.text;
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
	private static final INVALIDATION_FLAG_HEADER_RENDERER_FACTORY = InvalidationFlag.CUSTOM("headerRendererFactory");

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

	private var _oldItemRendererRecycler:DisplayObjectRecycler<Dynamic, GroupListViewItemState, DisplayObject> = null;

	private var _itemRendererRecycler:DisplayObjectRecycler<Dynamic, GroupListViewItemState, DisplayObject> = DisplayObjectRecycler.withClass(ItemRenderer);

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
		return this._itemRendererRecycler;
	}

	private function set_itemRendererRecycler(value:DisplayObjectRecycler<Dynamic, GroupListViewItemState, DisplayObject>):DisplayObjectRecycler<Dynamic,
		GroupListViewItemState, DisplayObject> {
		if (this._itemRendererRecycler == value) {
			return this._itemRendererRecycler;
		}
		this._oldItemRendererRecycler = this._itemRendererRecycler;
		this._itemRendererRecycler = value;
		this.setInvalid(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		return this._itemRendererRecycler;
	}

	private var _oldHeaderRendererRecycler:DisplayObjectRecycler<Dynamic, GroupListViewItemState, DisplayObject> = null;

	private var _headerRendererRecycler:DisplayObjectRecycler<Dynamic, GroupListViewItemState, DisplayObject> = DisplayObjectRecycler.withClass(ItemRenderer);

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
		return this._headerRendererRecycler;
	}

	private function set_headerRendererRecycler(value:DisplayObjectRecycler<Dynamic, GroupListViewItemState, DisplayObject>):DisplayObjectRecycler<Dynamic,
		GroupListViewItemState, DisplayObject> {
		if (this._headerRendererRecycler == value) {
			return this._headerRendererRecycler;
		}
		this._oldHeaderRendererRecycler = this._headerRendererRecycler;
		this._headerRendererRecycler = value;
		this.setInvalid(INVALIDATION_FLAG_HEADER_RENDERER_FACTORY);
		return this._headerRendererRecycler;
	}

	private var inactiveItemRenderers:Array<DisplayObject> = [];
	private var activeItemRenderers:Array<DisplayObject> = [];
	private var inactiveHeaderRenderers:Array<DisplayObject> = [];
	private var activeHeaderRenderers:Array<DisplayObject> = [];
	private var dataToItemRenderer = new ObjectMap<Dynamic, DisplayObject>();
	private var itemRendererToData = new ObjectMap<DisplayObject, Dynamic>();
	private var itemRendererToLayoutIndex = new ObjectMap<DisplayObject, Int>();
	private var _unrenderedLocations:Array<Array<Int>> = [];
	private var _unrenderedLayoutIndices:Array<Int> = [];
	private var _virtualCache:Array<Dynamic> = [];

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

		if (this._itemRendererRecycler.update == null) {
			this._itemRendererRecycler.update = defaultUpdateItemRenderer;
			if (this._itemRendererRecycler.reset == null) {
				this._itemRendererRecycler.reset = defaultResetItemRenderer;
			}
		}
		if (this._headerRendererRecycler.update == null) {
			this._headerRendererRecycler.update = defaultUpdateItemRenderer;
			if (this._headerRendererRecycler.reset == null) {
				this._headerRendererRecycler.reset = defaultResetItemRenderer;
			}
		}

		var temp = this.inactiveItemRenderers;
		this.inactiveItemRenderers = this.activeItemRenderers;
		this.activeItemRenderers = temp;
		if (this.activeItemRenderers.length > 0) {
			throw new IllegalOperationError(Type.getClassName(Type.getClass(this)) + ": active item renderers should be empty before updating.");
		}
		var temp = this.inactiveHeaderRenderers;
		this.inactiveHeaderRenderers = this.activeHeaderRenderers;
		this.activeHeaderRenderers = temp;
		if (this.activeHeaderRenderers.length > 0) {
			throw new IllegalOperationError(Type.getClassName(Type.getClass(this)) + ": active header renderers should be empty before updating.");
		}

		var itemRendererInvalid = this.isInvalid(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		if (itemRendererInvalid) {
			this.recoverInactiveItemRenderers(this.inactiveItemRenderers,
				this._oldItemRendererRecycler != null ? this._oldItemRendererRecycler : this._itemRendererRecycler);
			this.freeInactiveItemRenderers(this.inactiveItemRenderers,
				this._oldItemRendererRecycler != null ? this._oldItemRendererRecycler : this._itemRendererRecycler);
			this._oldItemRendererRecycler = null;
		}
		var headerRendererInvalid = this.isInvalid(INVALIDATION_FLAG_HEADER_RENDERER_FACTORY);
		if (headerRendererInvalid || itemRendererInvalid) {
			this.recoverInactiveItemRenderers(this.inactiveHeaderRenderers,
				this._oldHeaderRendererRecycler != null ? this._oldHeaderRendererRecycler : this._headerRendererRecycler);
			this.freeInactiveItemRenderers(this.inactiveHeaderRenderers,
				this._oldHeaderRendererRecycler != null ? this._oldHeaderRendererRecycler : this._headerRendererRecycler);
			this._oldHeaderRendererRecycler = null;
		}

		if (this._dataProvider == null) {
			return;
		}

		this.findUnrenderedData();
		this.recoverInactiveItemRenderers(this.inactiveItemRenderers, this._itemRendererRecycler);
		this.recoverInactiveItemRenderers(this.inactiveHeaderRenderers, this._headerRendererRecycler);
		this.renderUnrenderedData();
		this.freeInactiveItemRenderers(this.inactiveItemRenderers, this._itemRendererRecycler);
		this.freeInactiveItemRenderers(this.inactiveHeaderRenderers, this._headerRendererRecycler);
		if (this.inactiveItemRenderers.length > 0) {
			throw new IllegalOperationError(Type.getClassName(Type.getClass(this)) + ": inactive item renderers should be empty after updating.");
		}
		if (this.inactiveHeaderRenderers.length > 0) {
			throw new IllegalOperationError(Type.getClassName(Type.getClass(this)) + ": inactive header renderers should be empty after updating.");
		}
	}

	private function recoverInactiveItemRenderers(inactive:Array<DisplayObject>,
			recycler:DisplayObjectRecycler<Dynamic, GroupListViewItemState, DisplayObject>):Void {
		for (itemRenderer in inactive) {
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
			itemRenderer.removeEventListener(MouseEvent.CLICK, groupListView_itemRenderer_clickHandler);
			itemRenderer.removeEventListener(TouchEvent.TOUCH_TAP, groupListView_itemRenderer_touchTapHandler);
			if (Std.is(itemRenderer, IToggle)) {
				itemRenderer.removeEventListener(Event.CHANGE, groupListView_itemRenderer_changeHandler);
			}
			this._currentItemState.owner = this;
			this._currentItemState.type = inactive == this.inactiveHeaderRenderers ? HEADER : STANDARD;
			this._currentItemState.data = item;
			this._currentItemState.location = null;
			this._currentItemState.layoutIndex = -1;
			this._currentItemState.selected = false;
			this._currentItemState.text = null;
			var oldIgnoreSelectionChange = this._ignoreSelectionChange;
			this._ignoreSelectionChange = true;
			if (recycler != null && recycler.reset != null) {
				recycler.reset(itemRenderer, this._currentItemState);
			}
			if (Std.is(itemRenderer, IToggle)) {
				var toggle = cast(itemRenderer, IToggle);
				toggle.selected = false;
			}
			if (Std.is(itemRenderer, IDataRenderer)) {
				var dataRenderer = cast(itemRenderer, IDataRenderer);
				dataRenderer.data = null;
			}
			this._ignoreSelectionChange = oldIgnoreSelectionChange;
		}
	}

	private function freeInactiveItemRenderers(inactive:Array<DisplayObject>,
			recycler:DisplayObjectRecycler<Dynamic, GroupListViewItemState, DisplayObject>):Void {
		for (itemRenderer in inactive) {
			if (itemRenderer == null) {
				continue;
			}
			this.groupViewPort.removeChild(itemRenderer);
			if (recycler != null && recycler.destroy != null) {
				recycler.destroy(itemRenderer);
			}
		}
		inactive.resize(0);
	}

	private var _currentItemState = new GroupListViewItemState();
	private var _visibleIndices:VirtualLayoutRange = new VirtualLayoutRange(0, 0);

	private function findUnrenderedData():Void {
		// remove all old items, then fill with null
		this._layoutItems.resize(0);
		var newSize = this.calculateTotalLayoutCount([]);
		this._layoutItems.resize(newSize);

		if (this._virtualLayout && Std.is(this.layout, IVirtualLayout)) {
			var virtualLayout = cast(this.layout, IVirtualLayout);
			virtualLayout.virtualCache = this._virtualCache;
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
		this.refreshItemRendererProperties(itemRenderer, type, item, location, layoutIndex);
		// if this item renderer used to be the typical layout item, but
		// it isn't anymore, it may have been set invisible
		itemRenderer.visible = true;
		this._layoutItems[layoutIndex] = itemRenderer;
		var inactive = type == HEADER ? this.inactiveHeaderRenderers : this.inactiveItemRenderers;
		var active = location.length == 1 ? this.activeHeaderRenderers : this.activeItemRenderers;
		var removed = inactive.remove(itemRenderer);
		if (!removed) {
			throw new IllegalOperationError(Type.getClassName(Type.getClass(this))
				+ ": item renderer map contains bad data. This may be caused by duplicate items in the data provider, which is not allowed.");
		}
		active.push(itemRenderer);
	}

	private function renderUnrenderedData():Void {
		for (location in this._unrenderedLocations) {
			var layoutIndex = this._unrenderedLayoutIndices.shift();
			var item = this._dataProvider.get(location);
			var itemRenderer = this.createItemRenderer(item, location, layoutIndex);
			itemRenderer.visible = true;
			var type = location.length == 1 ? HEADER : STANDARD;
			var active = location.length == 1 ? this.activeHeaderRenderers : this.activeItemRenderers;
			active.push(itemRenderer);
			this.groupViewPort.addChild(itemRenderer);
			this._layoutItems[layoutIndex] = itemRenderer;
		}
		this._unrenderedLocations.resize(0);
	}

	private function createItemRenderer(item:Dynamic, location:Array<Int>, layoutIndex:Int):DisplayObject {
		var type = location.length == 1 ? HEADER : STANDARD;
		var inactive = type == HEADER ? this.inactiveHeaderRenderers : this.inactiveItemRenderers;
		var recycler = type == HEADER ? this._headerRendererRecycler : this._itemRendererRecycler;
		var itemRenderer:DisplayObject = null;
		if (inactive.length == 0) {
			itemRenderer = recycler.create();
		} else {
			itemRenderer = inactive.shift();
		}
		if (type == HEADER && Std.is(itemRenderer, IVariantStyleObject)) {
			var variantItemRenderer = cast(itemRenderer, IVariantStyleObject);
			if (variantItemRenderer.variant == null) {
				variantItemRenderer.variant = GroupListView.CHILD_VARIANT_HEADER;
			}
		}
		this.refreshItemRendererProperties(itemRenderer, location.length == 1 ? HEADER : STANDARD, item, location, layoutIndex);
		itemRenderer.addEventListener(MouseEvent.CLICK, groupListView_itemRenderer_clickHandler);
		// TODO: temporarily disabled until isPrimaryTouchPoint bug is fixed
		// See commit: 43d659b6afa822873ded523395e2a2a1a4567a50
		// itemRenderer.addEventListener(TouchEvent.TOUCH_TAP, itemRenderer_touchTapHandler);
		if (Std.is(itemRenderer, IToggle)) {
			itemRenderer.addEventListener(Event.CHANGE, groupListView_itemRenderer_changeHandler);
		}
		this.itemRendererToData.set(itemRenderer, item);
		this.itemRendererToLayoutIndex.set(itemRenderer, layoutIndex);
		this.dataToItemRenderer.set(item, itemRenderer);
		return itemRenderer;
	}

	private function refreshItemRendererProperties(itemRenderer:DisplayObject, type:GroupListViewItemType, item:Dynamic, location:Array<Int>,
			layoutIndex:Int):Void {
		this._currentItemState.owner = this;
		this._currentItemState.type = type;
		this._currentItemState.data = item;
		this._currentItemState.location = location;
		this._currentItemState.layoutIndex = layoutIndex;
		this._currentItemState.selected = location.length > 1 && item == this._selectedItem;
		this._currentItemState.text = type == HEADER ? itemToHeaderText(item) : itemToText(item);
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		if (type == HEADER) {
			if (this._headerRendererRecycler.update != null) {
				this._headerRendererRecycler.update(itemRenderer, this._currentItemState);
			}
		} else {
			if (this._itemRendererRecycler.update != null) {
				this._itemRendererRecycler.update(itemRenderer, this._currentItemState);
			}
		}
		if (Std.is(itemRenderer, IDataRenderer)) {
			var dataRenderer = cast(itemRenderer, IDataRenderer);
			// if the renderer is an IDataRenderer, this cannot be overridden
			dataRenderer.data = this._currentItemState.data;
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

	private function navigateWithKeyboard(event:KeyboardEvent):Void {
		if (this._layoutItems.length == 0) {
			return;
		}
		var startIndex = this.locationToDisplayIndex(this._selectedLocation);
		var result = startIndex;
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
		if (result < 0) {
			result = 0;
		} else if (result >= this._layoutItems.length) {
			result = this._layoutItems.length - 1;
		}
		event.stopPropagation();
		// use the setter
		this.selectedLocation = this.displayIndexToLocation(result);
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
		if (!this._selectable || !this.pointerSelectionEnabled) {
			return;
		}
		if (event.isPrimaryTouchPoint #if air && Multitouch.mapTouchToMouse #end) {
			// ignore the primary one because MouseEvent.CLICK will catch it
			return;
		}
		var itemRenderer = cast(event.currentTarget, DisplayObject);
		if (Std.is(itemRenderer, IToggle)) {
			// handled by Event.CHANGE listener instead
			return;
		}
		var data = this.itemRendererToData.get(itemRenderer);
		// use the setter
		this.selectedLocation = this._dataProvider.locationOf(data);
	}

	private function groupListView_itemRenderer_clickHandler(event:MouseEvent):Void {
		if (!this._selectable || !this.pointerSelectionEnabled) {
			return;
		}
		var itemRenderer = cast(event.currentTarget, DisplayObject);
		if (Std.is(itemRenderer, IToggle)) {
			// handled by Event.CHANGE listener instead
			return;
		}
		var data = this.itemRendererToData.get(itemRenderer);
		// use the setter
		this.selectedLocation = this._dataProvider.locationOf(data);
	}

	private function groupListView_itemRenderer_changeHandler(event:Event):Void {
		if (this._ignoreSelectionChange) {
			return;
		}
		var itemRenderer = cast(event.currentTarget, DisplayObject);
		if (!this._selectable) {
			var toggle = cast(itemRenderer, IToggle);
			var oldIgnoreSelectionChange = this._ignoreSelectionChange;
			this._ignoreSelectionChange = true;
			toggle.selected = false;
			this._ignoreSelectionChange = oldIgnoreSelectionChange;
			return;
		}
		var item = this.itemRendererToData.get(itemRenderer);
		var location = this._dataProvider.locationOf(item);
		if (location.length == 1) {
			var toggle = cast(itemRenderer, IToggle);
			var oldIgnoreSelectionChange = this._ignoreSelectionChange;
			this._ignoreSelectionChange = true;
			toggle.selected = false;
			this._ignoreSelectionChange = oldIgnoreSelectionChange;
			return;
		}
		// use the setter
		this.selectedItem = item;
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
}

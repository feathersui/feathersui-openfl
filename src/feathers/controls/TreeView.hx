/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.controls.dataRenderers.IDataRenderer;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.controls.supportClasses.AdvancedLayoutViewPort;
import feathers.controls.supportClasses.BaseScrollContainer;
import feathers.core.ITextControl;
import feathers.core.InvalidationFlag;
import feathers.data.IHierarchicalCollection;
import feathers.data.TreeViewItemState;
import feathers.events.FeathersEvent;
import feathers.events.HierarchicalCollectionEvent;
import feathers.layout.Direction;
import feathers.layout.ILayout;
import feathers.layout.IScrollLayout;
import feathers.layout.IVirtualLayout;
import feathers.themes.steel.components.SteelTreeViewStyles;
import feathers.utils.DisplayObjectRecycler;
import haxe.ds.ObjectMap;
import openfl.display.DisplayObject;
import openfl.errors.IllegalOperationError;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
#if air
import openfl.ui.Multitouch;
#end

/**


	@see [Tutorial: How to use the TreeView component](https://feathersui.com/learn/haxe-openfl/tree-view/)

	@since 1.0.0
**/
@:access(feathers.data.TreeViewItemState)
@defaultXmlProperty("dataProvider")
@:styleContext
class TreeView extends BaseScrollContainer {
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

	private static final INVALIDATION_FLAG_ITEM_RENDERER_FACTORY = "itemRendererFactory";

	private static function defaultUpdateItemRenderer(itemRenderer:DisplayObject, state:TreeViewItemState):Void {
		if (Std.is(itemRenderer, ITextControl)) {
			var textControl = cast(itemRenderer, ITextControl);
			textControl.text = state.text;
		}
	}

	private static function defaultResetItemRenderer(itemRenderer:DisplayObject, state:TreeViewItemState):Void {
		if (Std.is(itemRenderer, ITextControl)) {
			var textControl = cast(itemRenderer, ITextControl);
			textControl.text = null;
		}
	}

	/**
		Creates a new `TreeView` object.

		@since 1.0.0
	**/
	public function new() {
		initializeTreeViewTheme();

		super();
		if (this.viewPort == null) {
			this.treeViewPort = new AdvancedLayoutViewPort();
			this.addChild(this.treeViewPort);
			this.viewPort = this.treeViewPort;
		}
	}

	private var treeViewPort:AdvancedLayoutViewPort;

	override private function get_primaryDirection():Direction {
		if (Std.is(this.layout, IScrollLayout)) {
			return cast(this.layout, IScrollLayout).primaryDirection;
		}
		return Direction.NONE;
	}

	private var openBranches:Array<Dynamic> = [];

	/**
		The collection of data displayed by the tree view.

		@default null

		@since 1.0.0
	**/
	public var dataProvider(default, set):IHierarchicalCollection<Dynamic> = null;

	private function set_dataProvider(value:IHierarchicalCollection<Dynamic>):IHierarchicalCollection<Dynamic> {
		if (this.dataProvider == value) {
			return this.dataProvider;
		}
		this._virtualCache.resize(0);
		if (this.dataProvider != null) {
			this.dataProvider.removeEventListener(Event.CHANGE, dataProvider_changeHandler);
			this.dataProvider.removeEventListener(HierarchicalCollectionEvent.ADD_ITEM, dataProvider_addItemHandler);
			this.dataProvider.removeEventListener(HierarchicalCollectionEvent.REMOVE_ITEM, dataProvider_removeItemHandler);
			this.dataProvider.removeEventListener(HierarchicalCollectionEvent.REPLACE_ITEM, dataProvider_replaceItemHandler);
			this.dataProvider.removeEventListener(HierarchicalCollectionEvent.REMOVE_ALL, dataProvider_removeAllHandler);
			this.dataProvider.removeEventListener(HierarchicalCollectionEvent.RESET, dataProvider_resetHandler);
		}
		this.dataProvider = value;
		if (this.dataProvider != null) {
			var newSize = this.calculateTotalLayoutCount([]);
			this._virtualCache.resize(newSize);
			this.dataProvider.addEventListener(Event.CHANGE, dataProvider_changeHandler);
			this.dataProvider.addEventListener(HierarchicalCollectionEvent.ADD_ITEM, dataProvider_addItemHandler);
			this.dataProvider.addEventListener(HierarchicalCollectionEvent.REMOVE_ITEM, dataProvider_removeItemHandler);
			this.dataProvider.addEventListener(HierarchicalCollectionEvent.REPLACE_ITEM, dataProvider_replaceItemHandler);
			this.dataProvider.addEventListener(HierarchicalCollectionEvent.REMOVE_ALL, dataProvider_removeAllHandler);
			this.dataProvider.addEventListener(HierarchicalCollectionEvent.RESET, dataProvider_resetHandler);
		}
		this.setInvalid(InvalidationFlag.DATA);
		return this.dataProvider;
	}

	/**
		@since 1.0.0
	**/
	@:isVar
	public var selectedLocation(get, set):Array<Int> = null;

	private function get_selectedLocation():Array<Int> {
		return this.selectedLocation;
	}

	private function set_selectedLocation(value:Array<Int>):Array<Int> {
		if (!this.selectable || this.dataProvider == null) {
			value = null;
		}
		if (this.selectedLocation == value || this.compareLocations(this.selectedLocation, value) == 0) {
			return this.selectedLocation;
		}
		this.selectedLocation = value;
		// using @:bypassAccessor because if we were to call the selectedItem
		// setter, this change wouldn't be saved properly
		if (this.selectedLocation == null) {
			@:bypassAccessor this.selectedItem = null;
		} else {
			@:bypassAccessor this.selectedItem = this.dataProvider.get(this.selectedLocation);
		}
		this.setInvalid(InvalidationFlag.SELECTION);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this.selectedLocation;
	}

	/**
		@see `feathers.core.IDataSelector.selectedItem`
	**/
	@:isVar
	public var selectedItem(get, set):Dynamic = null;

	private function get_selectedItem():Dynamic {
		return this.selectedItem;
	}

	private function set_selectedItem(value:Dynamic):Dynamic {
		if (!this.selectable || this.dataProvider == null) {
			this.selectedLocation = null;
			return this.selectedItem;
		}
		this.selectedLocation = this.dataProvider.locationOf(value);
		return this.selectedItem;
	}

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

	/**
		Manages item renderers used by the tree view.

		In the following example, the tree view uses a custom item renderer
		class:

		```hx
		treeView.itemRendererRecycler = DisplayObjectRecycler.withClass(CustomItemRenderer);
		```

		@since 1.0.0
	**/
	public var itemRendererRecycler(default,
		set):DisplayObjectRecycler<Dynamic, TreeViewItemState, DisplayObject> = DisplayObjectRecycler.withClass(ItemRenderer);

	private function set_itemRendererRecycler(value:DisplayObjectRecycler<Dynamic, TreeViewItemState, DisplayObject>):DisplayObjectRecycler<Dynamic,
		TreeViewItemState, DisplayObject> {
		if (this.itemRendererRecycler == value) {
			return this.itemRendererRecycler;
		}
		this.itemRendererRecycler = value;
		this.setInvalid(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		return this.itemRendererRecycler;
	}

	private var inactiveItemRenderers:Array<DisplayObject> = [];
	private var activeItemRenderers:Array<DisplayObject> = [];
	private var dataToItemRenderer = new ObjectMap<Dynamic, DisplayObject>();
	private var itemRendererToData = new ObjectMap<DisplayObject, Dynamic>();
	private var _unrenderedLocations:Array<Array<Int>> = [];
	private var _unrenderedLayoutIndices:Array<Int> = [];
	private var _virtualCache:Array<Dynamic> = [];

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
	public var selectable(default, set):Bool = true;

	private function set_selectable(value:Bool):Bool {
		if (this.selectable == value) {
			return this.selectable;
		}
		this.selectable = value;
		if (!this.selectable) {
			this.selectedLocation = null;
		}
		return this.selectable;
	}

	public var virtualLayout(default, set):Bool = true;

	private function set_virtualLayout(value:Bool):Bool {
		if (this.virtualLayout = value) {
			return this.virtualLayout;
		}
		this.virtualLayout = value;
		this.setInvalid(InvalidationFlag.LAYOUT);
		return this.virtualLayout;
	}

	/**
		Indicates if selection is changed with `MouseEvent.CLICK` or
		`TouchEvent.TOUCH_TAP`. If set to `false`, the item renderers will
		control their own selection manually.
	**/
	public var pointerSelectionEnabled:Bool = true;

	private var _ignoreSelectionChange = false;

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
		treeView.itemToText = (item:Dynamic) ->
		{
			return item.text;
		};
		```

		@since 1.0.0
	**/
	public dynamic function itemToText(data:Dynamic):String {
		return Std.string(data);
	}

	private function initializeTreeViewTheme():Void {
		SteelTreeViewStyles.initialize();
	}

	private var _layoutLocations:Array<Array<Int>> = [];
	private var _layoutItems:Array<DisplayObject> = [];

	override private function update():Void {
		var layoutInvalid = this.isInvalid(InvalidationFlag.LAYOUT);
		var stylesInvalid = this.isInvalid(InvalidationFlag.STYLES);

		if (layoutInvalid || stylesInvalid) {
			this.treeViewPort.layout = this.layout;
		}

		this.treeViewPort.refreshChildren = this.refreshItemRenderers;

		for (flag in this._invalidationFlags.keys()) {
			this.treeViewPort.setInvalid(flag);
		}

		super.update();
	}

	private function refreshItemRenderers(items:Array<DisplayObject>):Void {
		this._layoutItems = items;

		if (this.itemRendererRecycler.update == null) {
			this.itemRendererRecycler.update = defaultUpdateItemRenderer;
			if (this.itemRendererRecycler.reset == null) {
				this.itemRendererRecycler.reset = defaultResetItemRenderer;
			}
		}

		var itemRendererInvalid = this.isInvalid(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		this.refreshInactiveItemRenderers(itemRendererInvalid);
		if (this.dataProvider == null) {
			return;
		}

		this.findUnrenderedData();
		this.recoverInactiveItemRenderers();
		this.renderUnrenderedData();
		this.freeInactiveItemRenderers();
		if (this.inactiveItemRenderers.length > 0) {
			throw new IllegalOperationError(Type.getClassName(Type.getClass(this)) + ": inactive item renderers should be empty after updating.");
		}
	}

	private function refreshInactiveItemRenderers(factoryInvalid:Bool):Void {
		var temp = this.inactiveItemRenderers;
		this.inactiveItemRenderers = this.activeItemRenderers;
		this.activeItemRenderers = temp;
		if (this.activeItemRenderers.length > 0) {
			throw new IllegalOperationError(Type.getClassName(Type.getClass(this)) + ": active item renderers should be empty before updating.");
		}
		if (factoryInvalid) {
			this.recoverInactiveItemRenderers();
			this.freeInactiveItemRenderers();
		}
	}

	private function recoverInactiveItemRenderers():Void {
		for (itemRenderer in this.inactiveItemRenderers) {
			if (itemRenderer == null) {
				continue;
			}
			var item = this.itemRendererToData.get(itemRenderer);
			if (item == null) {
				return;
			}
			this.itemRendererToData.remove(itemRenderer);
			this.dataToItemRenderer.remove(item);
			itemRenderer.removeEventListener(MouseEvent.CLICK, itemRenderer_clickHandler);
			itemRenderer.removeEventListener(TouchEvent.TOUCH_TAP, itemRenderer_touchTapHandler);
			itemRenderer.removeEventListener(Event.CHANGE, itemRenderer_changeHandler);
			this._currentItemState.data = item;
			this._currentItemState.location = null;
			this._currentItemState.layoutIndex = -1;
			this._currentItemState.selected = false;
			this._currentItemState.text = null;
			var oldIgnoreSelectionChange = this._ignoreSelectionChange;
			this._ignoreSelectionChange = true;
			if (this.itemRendererRecycler.reset != null) {
				this.itemRendererRecycler.reset(itemRenderer, this._currentItemState);
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

	private function freeInactiveItemRenderers():Void {
		for (itemRenderer in this.inactiveItemRenderers) {
			if (itemRenderer == null) {
				continue;
			}
			this.destroyItemRenderer(itemRenderer);
		}
		this.inactiveItemRenderers.resize(0);
	}

	private var _currentItemState = new TreeViewItemState();
	private var _visibleIndices:VirtualLayoutRange = new VirtualLayoutRange(0, 0);

	private function findUnrenderedData():Void {
		// remove all old items, then fill with null
		this._layoutItems.resize(0);
		var newSize = this.calculateTotalLayoutCount([]);
		this._layoutItems.resize(newSize);

		if (this.virtualLayout && Std.is(this.layout, IVirtualLayout)) {
			var virtualLayout = cast(this.layout, IVirtualLayout);
			virtualLayout.virtualCache = this._virtualCache;
			virtualLayout.getVisibleIndices(this._layoutItems.length, this.treeViewPort.visibleWidth, this.treeViewPort.visibleHeight, this._visibleIndices);
		} else {
			this._visibleIndices.start = 0;
			this._visibleIndices.end = this._layoutItems.length - 1;
		}
		this.findUnrenderedDataForLocation([], 0);
	}

	private function findUnrenderedDataForLocation(location:Array<Int>, layoutIndex:Int):Int {
		if (this.dataProvider == null) {
			return layoutIndex;
		}
		for (i in 0...this.dataProvider.getLength(location)) {
			location.push(i);
			var item = this.dataProvider.get(location);
			if (layoutIndex < this._visibleIndices.start || layoutIndex > this._visibleIndices.end) {
				this._layoutItems[layoutIndex] = null;
			} else {
				this.findItemRenderer(item, location.copy(), layoutIndex);
			}
			layoutIndex++;
			if (this.dataProvider.isBranch(item) && this.openBranches.indexOf(item) != -1) {
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
		this._currentItemState.data = item;
		this._currentItemState.location = location;
		this._currentItemState.layoutIndex = layoutIndex;
		this._currentItemState.selected = item == this.selectedItem;
		this._currentItemState.text = itemToText(item);
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		if (this.itemRendererRecycler.update != null) {
			this.itemRendererRecycler.update(itemRenderer, this._currentItemState);
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
		// if this item renderer used to be the typical layout item, but
		// it isn't anymore, it may have been set invisible
		itemRenderer.visible = true;
		this._layoutItems[layoutIndex] = itemRenderer;
		var removed = inactiveItemRenderers.remove(itemRenderer);
		if (!removed) {
			throw new IllegalOperationError(Type.getClassName(Type.getClass(this))
				+ ": item renderer map contains bad data. This may be caused by duplicate items in the data provider, which is not allowed.");
		}
		activeItemRenderers.push(itemRenderer);
	}

	private function renderUnrenderedData():Void {
		for (location in this._unrenderedLocations) {
			var layoutIndex = this._unrenderedLayoutIndices.shift();
			var item = this.dataProvider.get(location);
			var itemRenderer = this.createItemRenderer(item, location, layoutIndex);
			itemRenderer.visible = true;
			this.activeItemRenderers.push(itemRenderer);
			this.treeViewPort.addChild(itemRenderer);
			this._layoutItems[layoutIndex] = itemRenderer;
		}
		this._unrenderedLocations.resize(0);
	}

	private function createItemRenderer(item:Dynamic, location:Array<Int>, layoutIndex:Int):DisplayObject {
		var itemRenderer:DisplayObject = null;
		if (this.inactiveItemRenderers.length == 0) {
			itemRenderer = this.itemRendererRecycler.create();
		} else {
			itemRenderer = this.inactiveItemRenderers.shift();
		}
		this._currentItemState.data = item;
		this._currentItemState.location = location;
		this._currentItemState.layoutIndex = layoutIndex;
		this._currentItemState.branch = this.dataProvider != null && this.dataProvider.isBranch(item);
		this._currentItemState.selected = item == this.selectedItem;
		this._currentItemState.text = itemToText(item);
		if (this.itemRendererRecycler.update != null) {
			this.itemRendererRecycler.update(itemRenderer, this._currentItemState);
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
		itemRenderer.addEventListener(MouseEvent.CLICK, itemRenderer_clickHandler);
		// TODO: temporarily disabled until isPrimaryTouchPoint bug is fixed
		// See commit: 43d659b6afa822873ded523395e2a2a1a4567a50
		// itemRenderer.addEventListener(TouchEvent.TOUCH_TAP, itemRenderer_touchTapHandler);
		if (Std.is(itemRenderer, IToggle)) {
			itemRenderer.addEventListener(Event.CHANGE, itemRenderer_changeHandler);
		}
		this.itemRendererToData.set(itemRenderer, item);
		this.dataToItemRenderer.set(item, itemRenderer);
		return itemRenderer;
	}

	private function destroyItemRenderer(itemRenderer:DisplayObject):Void {
		this.treeViewPort.removeChild(itemRenderer);
		if (this.itemRendererRecycler.destroy != null) {
			this.itemRendererRecycler.destroy(itemRenderer);
		}
	}

	private function refreshSelectedLocationAfterFilterOrSort():Void {
		if (this.selectedLocation == null) {
			return;
		}
		// the location may have changed, possibily even to null, if the item
		// was filtered out
		this.selectedLocation = this.dataProvider.locationOf(this.selectedItem);
	}

	private function calculateTotalLayoutCount(location:Array<Int>):Int {
		if (this.dataProvider == null) {
			return 0;
		}
		var itemCount = this.dataProvider.getLength(location);
		var result = itemCount;
		for (i in 0...itemCount) {
			location.push(i);
			var item = this.dataProvider.get(location);
			if (this.dataProvider.isBranch(item) && this.openBranches.indexOf(item) != -1) {
				result += this.calculateTotalLayoutCount(location);
			}
			location.pop();
		}
		return result;
	}

	private function itemRenderer_touchTapHandler(event:TouchEvent):Void {
		if (!this.selectable || !this.pointerSelectionEnabled) {
			return;
		}
		if (event.isPrimaryTouchPoint #if air && Multitouch.mapTouchToMouse #end) {
			// ignore the primary one because MouseEvent.CLICK will catch it
			return;
		}
		var itemRenderer = cast(event.currentTarget, DisplayObject);
		var data = this.itemRendererToData.get(itemRenderer);
		this.selectedLocation = this.dataProvider.locationOf(data);
	}

	private function itemRenderer_clickHandler(event:MouseEvent):Void {
		if (!this.selectable || !this.pointerSelectionEnabled) {
			return;
		}
		var itemRenderer = cast(event.currentTarget, DisplayObject);
		var data = this.itemRendererToData.get(itemRenderer);
		this.selectedLocation = this.dataProvider.locationOf(data);
	}

	private function itemRenderer_changeHandler(event:Event):Void {
		if (this._ignoreSelectionChange) {
			return;
		}
		var itemRenderer = cast(event.currentTarget, DisplayObject);
		if (!this.selectable) {
			var toggle = cast(itemRenderer, IToggle);
			var oldIgnoreSelectionChange = this._ignoreSelectionChange;
			this._ignoreSelectionChange = true;
			toggle.selected = false;
			this._ignoreSelectionChange = oldIgnoreSelectionChange;
			return;
		}
		if (this.pointerSelectionEnabled) {
			var toggle = cast(itemRenderer, IToggle);
			var oldIgnoreSelectionChange = this._ignoreSelectionChange;
			this._ignoreSelectionChange = true;
			toggle.selected = !toggle.selected;
			this._ignoreSelectionChange = oldIgnoreSelectionChange;
			return;
		}
		var item = this.itemRendererToData.get(itemRenderer);
		this.selectedItem = item;
	}

	private function dataProvider_changeHandler(event:Event):Void {
		if (this._virtualCache != null) {
			this._virtualCache.resize(0);
			var newSize = this.calculateTotalLayoutCount([]);
			this._virtualCache.resize(newSize);
		}
		this.setInvalid(InvalidationFlag.DATA);
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

	private function dataProvider_addItemHandler(event:HierarchicalCollectionEvent):Void {
		if (this.selectedLocation == null) {
			return;
		}
		if (this.compareLocations(this.selectedLocation, event.location) >= 0) {
			this.selectedLocation = this.dataProvider.locationOf(this.selectedItem);
		}
	}

	private function dataProvider_removeItemHandler(event:HierarchicalCollectionEvent):Void {
		if (this.selectedLocation == null) {
			return;
		}

		var comparisonResult = this.compareLocations(this.selectedLocation, event.location);
		if (comparisonResult == 0) {
			this.selectedLocation = null;
		} else if (comparisonResult > 0) {
			this.selectedLocation = this.dataProvider.locationOf(this.selectedItem);
		}
	}

	private function dataProvider_replaceItemHandler(event:HierarchicalCollectionEvent):Void {
		if (this.selectedLocation == null) {
			return;
		}
		if (this.compareLocations(this.selectedLocation, event.location) == 0) {
			@:bypassAccessor this.selectedItem = this.dataProvider.get(event.location);
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
	}

	private function dataProvider_removeAllHandler(event:HierarchicalCollectionEvent):Void {
		this.selectedLocation = null;
	}

	private function dataProvider_resetHandler(event:HierarchicalCollectionEvent):Void {
		this.selectedLocation = null;
	}
}

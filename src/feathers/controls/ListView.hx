/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

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
import feathers.core.ITextControl;
import feathers.core.InvalidationFlag;
import feathers.data.IFlatCollection;
import feathers.data.ListViewItemState;
import feathers.events.FeathersEvent;
import feathers.events.FlatCollectionEvent;
import feathers.events.ListViewEvent;
import feathers.layout.Direction;
import feathers.layout.ILayout;
import feathers.layout.IScrollLayout;
import feathers.layout.IVirtualLayout;
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

	@see [Tutorial: How to use the ListView component](https://feathersui.com/learn/haxe-openfl/list-view/)
	@see `feathers.controls.PopUpListView`
	@see `feathers.controls.ComboBox`

	@since 1.0.0
**/
@:access(feathers.data.ListViewItemState)
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

	private static final INVALIDATION_FLAG_ITEM_RENDERER_FACTORY = "itemRendererFactory";

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
	public function new() {
		initializeListViewTheme();

		super();

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
		return (this.selectable || this.maxScrollY != this.minScrollY || this.maxScrollX != this.minScrollX)
			&& this.enabled
			&& this.focusEnabled;
	}

	override private function get_primaryDirection():Direction {
		if (Std.is(this.layout, IScrollLayout)) {
			return cast(this.layout, IScrollLayout).primaryDirection;
		}
		return Direction.NONE;
	}

	/**
		The collection of data displayed by the list view.

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
	public var dataProvider(default, set):IFlatCollection<Dynamic> = null;

	private function set_dataProvider(value:IFlatCollection<Dynamic>):IFlatCollection<Dynamic> {
		if (this.dataProvider == value) {
			return this.dataProvider;
		}
		this._virtualCache.resize(0);
		if (this.dataProvider != null) {
			this.dataProvider.removeEventListener(Event.CHANGE, listView_dataProvider_changeHandler);
			this.dataProvider.removeEventListener(FlatCollectionEvent.ADD_ITEM, listView_dataProvider_addItemHandler);
			this.dataProvider.removeEventListener(FlatCollectionEvent.REMOVE_ITEM, listView_dataProvider_removeItemHandler);
			this.dataProvider.removeEventListener(FlatCollectionEvent.REPLACE_ITEM, listView_dataProvider_replaceItemHandler);
			this.dataProvider.removeEventListener(FlatCollectionEvent.REMOVE_ALL, listView_dataProvider_removeAllHandler);
			this.dataProvider.removeEventListener(FlatCollectionEvent.RESET, listView_dataProvider_resetHandler);
			this.dataProvider.removeEventListener(FlatCollectionEvent.SORT_CHANGE, listView_dataProvider_sortChangeHandler);
			this.dataProvider.removeEventListener(FlatCollectionEvent.FILTER_CHANGE, listView_dataProvider_filterChangeHandler);
		}
		this.dataProvider = value;
		if (this.dataProvider != null) {
			this._virtualCache.resize(this.dataProvider.length);
			this.dataProvider.addEventListener(Event.CHANGE, listView_dataProvider_changeHandler);
			this.dataProvider.addEventListener(FlatCollectionEvent.ADD_ITEM, listView_dataProvider_addItemHandler);
			this.dataProvider.addEventListener(FlatCollectionEvent.REMOVE_ITEM, listView_dataProvider_removeItemHandler);
			this.dataProvider.addEventListener(FlatCollectionEvent.REPLACE_ITEM, listView_dataProvider_replaceItemHandler);
			this.dataProvider.addEventListener(FlatCollectionEvent.REMOVE_ALL, listView_dataProvider_removeAllHandler);
			this.dataProvider.addEventListener(FlatCollectionEvent.RESET, listView_dataProvider_resetHandler);
			this.dataProvider.addEventListener(FlatCollectionEvent.SORT_CHANGE, listView_dataProvider_sortChangeHandler);
			this.dataProvider.addEventListener(FlatCollectionEvent.FILTER_CHANGE, listView_dataProvider_filterChangeHandler);
		}
		this.setInvalid(InvalidationFlag.DATA);
		return this.dataProvider;
	}

	/**
		@see `feathers.core.IIndexSelector.selectedIndex`
	**/
	@:isVar
	public var selectedIndex(get, set):Int = -1;

	private function get_selectedIndex():Int {
		return this.selectedIndex;
	}

	private function set_selectedIndex(value:Int):Int {
		if (!this.selectable || this.dataProvider == null) {
			value = -1;
		}
		if (this.selectedIndex == value) {
			return this.selectedIndex;
		}
		this.selectedIndex = value;
		// using @:bypassAccessor because if we were to call the selectedItem
		// setter, this change wouldn't be saved properly
		if (this.selectedIndex == -1) {
			@:bypassAccessor this.selectedItem = null;
		} else {
			@:bypassAccessor this.selectedItem = this.dataProvider.get(this.selectedIndex);
		}
		this.setInvalid(InvalidationFlag.SELECTION);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this.selectedIndex;
	}

	/**
		@see `feathers.core.IIndexSelector.maxSelectedIndex`
	**/
	public var maxSelectedIndex(get, never):Int;

	private function get_maxSelectedIndex():Int {
		if (this.dataProvider == null) {
			return -1;
		}
		return this.dataProvider.length - 1;
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
			this.selectedIndex = -1;
			return this.selectedItem;
		}
		this.selectedIndex = this.dataProvider.indexOf(value);
		return this.selectedItem;
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

	/**
		Manages item renderers used by the list view.

		In the following example, the list view uses a custom item renderer
		class:

		```hx
		listView.itemRendererRecycler = DisplayObjectRecycler.withClass(CustomItemRenderer);
		```

		@since 1.0.0
	**/
	public var itemRendererRecycler(default,
		set):DisplayObjectRecycler<Dynamic, ListViewItemState, DisplayObject> = DisplayObjectRecycler.withClass(ItemRenderer);

	private function set_itemRendererRecycler(value:DisplayObjectRecycler<Dynamic, ListViewItemState, DisplayObject>):DisplayObjectRecycler<Dynamic,
		ListViewItemState, DisplayObject> {
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
	private var _unrenderedData:Array<Dynamic> = [];
	private var _virtualCache:Array<Dynamic> = [];

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
	public var selectable(default, set):Bool = true;

	private function set_selectable(value:Bool):Bool {
		if (this.selectable == value) {
			return this.selectable;
		}
		this.selectable = value;
		if (!this.selectable) {
			this.selectedIndex = -1;
		}
		return this.selectable;
	}

	/**
		Indicates if the list view's layout is allowed to virtualize items or
		not.

		The following example disables virtual layouts:

		```hx
		listView.virtualLayout = false;
		```

		@since 1.0.0
	**/
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

	private var _ignoreSelectionChange = false;

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
		if (this.dataProvider == null || this.dataProvider.length == 0) {
			return;
		}

		var targetX = this.scrollX;
		var targetY = this.scrollY;
		if (Std.is(this.layout, IScrollLayout)) {
			var scrollLayout = cast(this.layout, IScrollLayout);
			var result = scrollLayout.getNearestScrollPositionForIndex(index, this.dataProvider.length, this.viewPort.visibleWidth,
				this.viewPort.visibleHeight);
			targetX = result.x;
			targetY = result.y;
		} else {
			var item = this.dataProvider.get(index);
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

	private function initializeListViewTheme():Void {
		SteelListViewStyles.initialize();
	}

	private var _layoutItems:Array<DisplayObject> = [];

	override private function update():Void {
		var layoutInvalid = this.isInvalid(InvalidationFlag.LAYOUT);
		var stylesInvalid = this.isInvalid(InvalidationFlag.STYLES);

		if (layoutInvalid || stylesInvalid) {
			if (this._previousLayout != this.layout) {
				// don't keep the old layout's cache because it may not be
				// compatible with the new layout
				this._virtualCache.resize(0);
				this._virtualCache.resize(this.dataProvider.length);
			}
			this.listViewPort.layout = this.layout;
			this._previousLayout = this.layout;
		}

		this.listViewPort.refreshChildren = this.refreshItemRenderers;

		for (flag in this._invalidationFlags.keys()) {
			this.listViewPort.setInvalid(flag);
		}

		super.update();

		this._previousLayout = this.layout;
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
			itemRenderer.removeEventListener(MouseEvent.CLICK, listView_itemRenderer_clickHandler);
			itemRenderer.removeEventListener(TouchEvent.TOUCH_TAP, listView_itemRenderer_touchTapHandler);
			itemRenderer.removeEventListener(Event.CHANGE, listView_itemRenderer_changeHandler);
			this._currentItemState.data = item;
			this._currentItemState.index = -1;
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
			if (Std.is(itemRenderer, IListViewItemRenderer)) {
				var listRenderer = cast(itemRenderer, IListViewItemRenderer);
				listRenderer.index = -1;
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

	private var _currentItemState = new ListViewItemState();
	private var _visibleIndices:VirtualLayoutRange = new VirtualLayoutRange(0, 0);

	private function findUnrenderedData():Void {
		// remove all old items, then fill with null
		this._layoutItems.resize(0);
		this._layoutItems.resize(this.dataProvider.length);

		if (this.virtualLayout && Std.is(this.layout, IVirtualLayout)) {
			var virtualLayout = cast(this.layout, IVirtualLayout);
			virtualLayout.virtualCache = this._virtualCache;
			virtualLayout.getVisibleIndices(this.dataProvider.length, this.listViewPort.visibleWidth, this.listViewPort.visibleHeight, this._visibleIndices);
		} else {
			this._visibleIndices.start = 0;
			this._visibleIndices.end = this.dataProvider.length - 1;
		}
		if (this.dataProvider == null || this.dataProvider.length == 0) {
			return;
		}
		for (i in this._visibleIndices.start...this._visibleIndices.end + 1) {
			var item = this.dataProvider.get(i);
			var itemRenderer = this.dataToItemRenderer.get(item);
			if (itemRenderer != null) {
				this._currentItemState.data = item;
				this._currentItemState.index = i;
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
				if (Std.is(itemRenderer, IListViewItemRenderer)) {
					var listRenderer = cast(itemRenderer, IListViewItemRenderer);
					listRenderer.index = this._currentItemState.index;
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
				this._layoutItems[i] = itemRenderer;
				var removed = inactiveItemRenderers.remove(itemRenderer);
				if (!removed) {
					throw new IllegalOperationError(Type.getClassName(Type.getClass(this))
						+ ": item renderer map contains bad data. This may be caused by duplicate items in the data provider, which is not allowed.");
				}
				activeItemRenderers.push(itemRenderer);
			} else {
				this._unrenderedData.push(item);
			}
		}
	}

	private function renderUnrenderedData():Void {
		for (item in this._unrenderedData) {
			var index = this.dataProvider.indexOf(item);
			var itemRenderer = this.createItemRenderer(item, index);
			itemRenderer.visible = true;
			this.activeItemRenderers.push(itemRenderer);
			this.listViewPort.addChild(itemRenderer);
			this._layoutItems[index] = itemRenderer;
		}
		this._unrenderedData.resize(0);
	}

	private function createItemRenderer(item:Dynamic, index:Int):DisplayObject {
		var itemRenderer:DisplayObject = null;
		if (this.inactiveItemRenderers.length == 0) {
			itemRenderer = this.itemRendererRecycler.create();
		} else {
			itemRenderer = this.inactiveItemRenderers.shift();
		}
		this._currentItemState.data = item;
		this._currentItemState.index = index;
		this._currentItemState.selected = item == this.selectedItem;
		this._currentItemState.text = itemToText(item);
		if (this.itemRendererRecycler.update != null) {
			this.itemRendererRecycler.update(itemRenderer, this._currentItemState);
		}
		if (Std.is(itemRenderer, IListViewItemRenderer)) {
			var listRenderer = cast(itemRenderer, IListViewItemRenderer);
			listRenderer.index = this._currentItemState.index;
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
		itemRenderer.addEventListener(MouseEvent.CLICK, listView_itemRenderer_clickHandler);
		// TODO: temporarily disabled until isPrimaryTouchPoint bug is fixed
		// See commit: 43d659b6afa822873ded523395e2a2a1a4567a50
		// itemRenderer.addEventListener(TouchEvent.TOUCH_TAP, itemRenderer_touchTapHandler);
		if (Std.is(itemRenderer, IToggle)) {
			itemRenderer.addEventListener(Event.CHANGE, listView_itemRenderer_changeHandler);
		}
		this.itemRendererToData.set(itemRenderer, item);
		this.dataToItemRenderer.set(item, itemRenderer);
		return itemRenderer;
	}

	private function destroyItemRenderer(itemRenderer:DisplayObject):Void {
		this.listViewPort.removeChild(itemRenderer);
		if (this.itemRendererRecycler.destroy != null) {
			this.itemRendererRecycler.destroy(itemRenderer);
		}
	}

	private function refreshSelectedIndicesAfterFilterOrSort():Void {
		if (this.selectedIndex == -1) {
			return;
		}
		// the index may have changed, possibily even to -1, if the item was
		// filtered out
		this.selectedIndex = this.dataProvider.indexOf(this.selectedItem);
	}

	private function dispatchItemTriggerEvent(data:Dynamic):Void {
		var index = this.dataProvider.indexOf(data);
		this._currentItemState.data = data;
		this._currentItemState.index = index;
		this._currentItemState.text = this.itemToText(data);
		this._currentItemState.selected = this.selectedIndex == index;
		this.dispatchEvent(new ListViewEvent(ListViewEvent.ITEM_TRIGGER, this._currentItemState));
	}

	private function listView_itemRenderer_touchTapHandler(event:TouchEvent):Void {
		if (!this.enabled) {
			return;
		}

		var itemRenderer = cast(event.currentTarget, DisplayObject);
		var data = this.itemRendererToData.get(itemRenderer);
		this.dispatchItemTriggerEvent(data);

		if (!this.selectable || !this.pointerSelectionEnabled) {
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
		this.selectedIndex = this.dataProvider.indexOf(data);
	}

	private function listView_itemRenderer_clickHandler(event:MouseEvent):Void {
		if (!this.enabled) {
			return;
		}

		var itemRenderer = cast(event.currentTarget, DisplayObject);
		var data = this.itemRendererToData.get(itemRenderer);
		this.dispatchItemTriggerEvent(data);

		if (!this.selectable || !this.pointerSelectionEnabled) {
			return;
		}
		var itemRenderer = cast(event.currentTarget, DisplayObject);
		if (Std.is(itemRenderer, IToggle)) {
			// handled by Event.CHANGE listener instead
			return;
		}
		this.selectedItem = this.dataProvider.indexOf(data);
	}

	private function listView_itemRenderer_changeHandler(event:Event):Void {
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
		var item = this.itemRendererToData.get(itemRenderer);
		this.selectedItem = item;
	}

	private function listView_dataProvider_changeHandler(event:Event):Void {
		this.setInvalid(InvalidationFlag.DATA);
	}

	private function listView_dataProvider_addItemHandler(event:FlatCollectionEvent):Void {
		if (this._virtualCache != null) {
			this._virtualCache.insert(event.index, null);
		}
		if (this.selectedIndex == -1) {
			return;
		}
		if (this.selectedIndex >= event.index) {
			@:bypassAccessor this.selectedIndex++;
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
		if (this.selectedIndex == event.index) {
			@:bypassAccessor this.selectedIndex = -1;
			FeathersEvent.dispatch(this, Event.CHANGE);
		} else if (this.selectedIndex > event.index) {
			@:bypassAccessor this.selectedIndex--;
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
	}

	private function listView_dataProvider_replaceItemHandler(event:FlatCollectionEvent):Void {
		if (this._virtualCache != null) {
			this._virtualCache[event.index] = null;
		}
		if (this.selectedIndex == -1) {
			return;
		}
		if (this.selectedIndex == event.index) {
			@:bypassAccessor this.selectedItem = this.dataProvider.get(this.selectedIndex);
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
	}

	private function listView_dataProvider_removeAllHandler(event:FlatCollectionEvent):Void {
		if (this._virtualCache != null) {
			this._virtualCache.resize(0);
		}
		this.selectedIndex = -1;
	}

	private function listView_dataProvider_resetHandler(event:FlatCollectionEvent):Void {
		if (this._virtualCache != null) {
			this._virtualCache.resize(0);
			this._virtualCache.resize(this.dataProvider.length);
		}
		this.selectedIndex = -1;
	}

	private function listView_dataProvider_sortChangeHandler(event:FlatCollectionEvent):Void {
		if (this._virtualCache != null) {
			// we don't know exactly which indices have changed, so reset the
			// whole cache.
			this._virtualCache.resize(0);
			this._virtualCache.resize(this.dataProvider.length);
		}
		this.refreshSelectedIndicesAfterFilterOrSort();
	}

	private function listView_dataProvider_filterChangeHandler(event:FlatCollectionEvent):Void {
		if (this._virtualCache != null) {
			// we don't know exactly which indices have changed, so reset the
			// whole cache.
			this._virtualCache.resize(0);
			this._virtualCache.resize(this.dataProvider.length);
		}
		this.refreshSelectedIndicesAfterFilterOrSort();
	}

	private function navigateWithKeyboard(event:KeyboardEvent):Void {
		if (this.dataProvider == null || this.dataProvider.length == 0) {
			return;
		}
		var result = this.selectedIndex;
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
				result = this.dataProvider.length - 1;
			default:
				// not keyboard navigation
				return;
		}
		if (result < 0) {
			result = 0;
		} else if (result >= this.dataProvider.length) {
			result = this.dataProvider.length - 1;
		}
		event.stopPropagation();
		this.selectedIndex = result;
		if (this.selectedIndex != -1) {
			this.scrollToIndex(this.selectedIndex);
		}
	}

	override private function baseScrollContainer_keyDownHandler(event:KeyboardEvent):Void {
		if (!this.enabled || event.isDefaultPrevented()) {
			return;
		}
		this.navigateWithKeyboard(event);
	}

	private function listView_keyDownHandler(event:KeyboardEvent):Void {
		if (!this.enabled || event.isDefaultPrevented()) {
			return;
		}
		if (event.keyCode == Keyboard.SPACE || event.keyCode == Keyboard.ENTER) {
			if (this.selectedItem != null) {
				this.dispatchItemTriggerEvent(this.selectedItem);
			}
		}
	}
}

/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.utils.DisplayObjectRecycler;
import feathers.events.FlatCollectionEvent;
import feathers.data.ListViewItemState;
import feathers.layout.Direction;
import feathers.layout.IScrollLayout;
import feathers.core.ITextControl;
import feathers.controls.dataRenderers.IDataRenderer;
import haxe.ds.ObjectMap;
import openfl.errors.IllegalOperationError;
import feathers.themes.steel.components.SteelListViewStyles;
import openfl.display.DisplayObject;
import openfl.events.Event;
import feathers.core.InvalidationFlag;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.controls.supportClasses.LayoutViewPort;
import feathers.controls.supportClasses.BaseScrollContainer;
import feathers.layout.ILayout;
import feathers.data.IFlatCollection;
import feathers.events.FeathersEvent;
import feathers.core.IDataSelector;

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

	listView.dataProvider = new ArrayCollection(
	[
		{ text: "Milk" },
		{ text: "Eggs" },
		{ text: "Bread" },
		{ text: "Chicken" },
	]);

	listView.itemToText = (item:Dynamic) ->
	{
		return item.text;
	};

	listView.addEventListener(Event.CHANGE, (event:Event) ->
	{
		var listView = cast(event.currentTarget, ListView);
		trace("ListView changed: " + listView.selectedIndex + " " + listView.selectedItem.text);
	});

	this.addChild(listView);
	```

	@see [Tutorial: How to use the ListView component](https://feathersui.com/learn/haxe-openfl/list-view/)
	@see `feathers.controls.PopUpList`

	@since 1.0.0
**/
@:access(feathers.data.ListViewItemState)
@:styleContext
class ListView extends BaseScrollContainer implements IDataSelector<Dynamic> {
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
		if (this.viewPort == null) {
			this.listViewPort = new LayoutViewPort();
			this.addChild(this.listViewPort);
			this.viewPort = this.listViewPort;
		}
	}

	private var listViewPort:LayoutViewPort;

	override private function get_primaryDirection():Direction {
		if (Std.is(this.layout, IScrollLayout)) {
			return cast(this.layout, IScrollLayout).primaryDirection;
		}
		return Direction.NONE;
	}

	/**
		The collection of data displayed by the list.

		The following example passes in a data provider and tells the item
		renderer how to interpret the data:

		```hx
		list.dataProvider = new ArrayCollection(
		[
			{ text: "Milk" },
			{ text: "Eggs" },
			{ text: "Bread" },
			{ text: "Chicken" },
		]);

		list.itemToText = (item:Dynamic) ->
		{
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
		if (this.dataProvider != null) {
			this.dataProvider.removeEventListener(Event.CHANGE, dataProvider_changeHandler);
			this.dataProvider.removeEventListener(FlatCollectionEvent.ADD_ITEM, dataProvider_addItemHandler);
			this.dataProvider.removeEventListener(FlatCollectionEvent.REMOVE_ITEM, dataProvider_removeItemHandler);
			this.dataProvider.removeEventListener(FlatCollectionEvent.REPLACE_ITEM, dataProvider_replaceItemHandler);
			this.dataProvider.removeEventListener(FlatCollectionEvent.SORT_CHANGE, dataProvider_sortChangeHandler);
			this.dataProvider.removeEventListener(FlatCollectionEvent.FILTER_CHANGE, dataProvider_filterChangeHandler);
		}
		this.dataProvider = value;
		if (this.dataProvider != null) {
			this.dataProvider.addEventListener(Event.CHANGE, dataProvider_changeHandler);
			this.dataProvider.addEventListener(FlatCollectionEvent.ADD_ITEM, dataProvider_addItemHandler);
			this.dataProvider.addEventListener(FlatCollectionEvent.REMOVE_ITEM, dataProvider_removeItemHandler);
			this.dataProvider.addEventListener(FlatCollectionEvent.REPLACE_ITEM, dataProvider_replaceItemHandler);
			this.dataProvider.addEventListener(FlatCollectionEvent.SORT_CHANGE, dataProvider_sortChangeHandler);
			this.dataProvider.addEventListener(FlatCollectionEvent.FILTER_CHANGE, dataProvider_filterChangeHandler);
		}
		this.setInvalid(InvalidationFlag.DATA);
		return this.dataProvider;
	}

	/**
		@see `feathers.core.IDataSelector.selectedIndex`
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
		@see `feathers.core.IDataSelector.selectedItem`
	**/
	@:isVar
	public var selectedItem(get, set):Dynamic = null;

	private function get_selectedItem():Int {
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

	/**
		The layout algorithm used to position and size the list view's items.

		By default, if no layout is provided by the time that the list
		initializes, a default layout that displays items vertically will be
		created.

		The following example tells the list to use a horizontal layout:

		```hx
		var layout = new HorizontalLayout();
		layout.gap = 20.0;
		layout.padding = 20.0;
		list.layout = layout;
		```

		@since 1.0.0
	**/
	@:style
	public var layout:ILayout = null;

	/**
		Manages item renderers used by the list view.

		In the following example, the list view uses a custom item renderer:

		```hx
		list.itemRendererRecycler = new DisplayObjectRecycler(CustomItemRenderer);
		```

		@since 1.0.0
	**/
	public var itemRendererRecycler(default, set):DisplayObjectRecycler<Dynamic, ListViewItemState, DisplayObject> = new DisplayObjectRecycler(ItemRenderer);

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

	/**
		Determines if items in the list view may be selected. By default only a
		single item may be selected at any given time. In other words, if item
		_A_ is already selected, and the user selects item _B_, item _A_ will be
		deselected automatically.

		The following example disables selection of items in the list view:

		```hx
		list.selectable = false;
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
		list.itemToText = (item:Dynamic) ->
		{
			return item.text;
		};
		```

		@since 1.0.0
	**/
	public dynamic function itemToText(data:Dynamic):String {
		return Std.string(data);
	}

	private function initializeListViewTheme():Void {
		SteelListViewStyles.initialize();
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);
		var layoutInvalid = this.isInvalid(InvalidationFlag.LAYOUT);
		var selectionInvalid = this.isInvalid(InvalidationFlag.SELECTION);
		var stateInvalid = this.isInvalid(InvalidationFlag.STATE);
		var stylesInvalid = this.isInvalid(InvalidationFlag.STYLES);
		var itemRendererInvalid = this.isInvalid(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);

		if (itemRendererInvalid || selectionInvalid || stateInvalid || dataInvalid) {
			this.refreshItemRenderers();
		}

		if (layoutInvalid || stylesInvalid) {
			this.listViewPort.layout = this.layout;
		}

		super.update();
	}

	private function refreshItemRenderers():Void {
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
			itemRenderer.removeEventListener(FeathersEvent.TRIGGERED, itemRenderer_triggeredHandler);
			itemRenderer.removeEventListener(Event.CHANGE, itemRenderer_changeHandler);
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

	private function findUnrenderedData():Void {
		for (i in 0...this.dataProvider.length) {
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
				if (Std.is(itemRenderer, IToggle)) {
					var toggle = cast(itemRenderer, IToggle);
					// if the renderer is an IToggle, this cannot be overridden
					toggle.selected = this._currentItemState.selected;
				}
				this._ignoreSelectionChange = oldIgnoreSelectionChange;
				// if this item renderer used to be the typical layout item, but
				// it isn't anymore, it may have been set invisible
				itemRenderer.visible = true;
				this.listViewPort.setChildIndex(itemRenderer, i);
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
			this.listViewPort.addChildAt(itemRenderer, index);
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
		itemRenderer.addEventListener(FeathersEvent.TRIGGERED, itemRenderer_triggeredHandler);
		if (Std.is(itemRenderer, IToggle)) {
			itemRenderer.addEventListener(Event.CHANGE, itemRenderer_changeHandler);
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

	private function itemRenderer_triggeredHandler(event:FeathersEvent):Void {
		var itemRenderer:DisplayObject = cast(event.currentTarget, DisplayObject);
		var item = this.itemRendererToData.get(itemRenderer);
		// trigger before change
		FeathersEvent.dispatch(this, FeathersEvent.TRIGGERED);
	}

	private function itemRenderer_changeHandler(event:Event):Void {
		if (this._ignoreSelectionChange) {
			return;
		}
		var itemRenderer = cast(event.currentTarget, DisplayObject);
		if (!this.selectable) {
			var toggle = cast(itemRenderer, IToggle);
			toggle.selected = false;
			return;
		}
		var item = this.itemRendererToData.get(itemRenderer);
		this.selectedItem = item;
	}

	private function dataProvider_changeHandler(event:Event):Void {
		this.setInvalid(InvalidationFlag.DATA);
	}

	private function dataProvider_addItemHandler(event:FlatCollectionEvent):Void {
		if (this.selectedIndex == -1) {
			return;
		}
		if (this.selectedIndex <= event.index) {
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
	}

	private function dataProvider_removeItemHandler(event:FlatCollectionEvent):Void {
		if (this.selectedIndex == -1) {
			return;
		}
		if (this.selectedIndex == event.index) {
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
	}

	private function dataProvider_replaceItemHandler(event:FlatCollectionEvent):Void {
		if (this.selectedIndex == -1) {
			return;
		}
		if (this.selectedIndex == event.index) {
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
	}

	private function dataProvider_sortChangeHandler(event:FlatCollectionEvent):Void {
		this.refreshSelectedIndicesAfterFilterOrSort();
	}

	private function dataProvider_filterChangeHandler(event:FlatCollectionEvent):Void {
		this.refreshSelectedIndicesAfterFilterOrSort();
	}
}

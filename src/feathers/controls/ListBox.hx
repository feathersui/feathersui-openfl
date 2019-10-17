/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.data.ListBoxItemState;
import feathers.layout.Direction;
import feathers.layout.IScrollLayout;
import feathers.core.ITextControl;
import feathers.controls.dataRenderers.IDataRenderer;
import haxe.ds.ObjectMap;
import openfl.errors.IllegalOperationError;
import lime.utils.ObjectPool;
import feathers.themes.steel.components.SteelListBoxStyles;
import openfl.display.DisplayObject;
import openfl.events.Event;
import feathers.core.InvalidationFlag;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.controls.supportClasses.LayoutViewPort;
import feathers.controls.supportClasses.BaseScrollContainer;
import feathers.layout.ILayout;
import feathers.data.IFlatCollection;
import feathers.events.FeathersEvent;

/**

	@since 1.0.0
**/
@:access(feathers.data.ListBoxItemState)
@:styleContext
class ListBox extends BaseScrollContainer {
	private static final INVALIDATION_FLAG_ITEM_RENDERER_FACTORY = "itemRendererFactory";

	public function new() {
		initializeListBoxTheme();

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

		@since 1.0.0
	**/
	public var dataProvider(default, set):IFlatCollection<Dynamic> = null;

	private function set_dataProvider(value:IFlatCollection<Dynamic>):IFlatCollection<Dynamic> {
		if (this.dataProvider == value) {
			return this.dataProvider;
		}
		if (this.dataProvider != null) {
			this.dataProvider.removeEventListener(Event.CHANGE, dataProvider_changeHandler);
		}
		this.dataProvider = value;
		if (this.dataProvider != null) {
			this.dataProvider.addEventListener(Event.CHANGE, dataProvider_changeHandler);
		}
		this.setInvalid(InvalidationFlag.DATA);
		return this.dataProvider;
	}

	/**

		@since 1.0.0
	**/
	public var selectedIndex(default, set):Int = -1;

	private function set_selectedIndex(value:Int):Int {
		if (!this.selectable) {
			value = -1;
		}
		if (this.selectedIndex == value) {
			return this.selectedIndex;
		}
		this.selectedIndex = value;
		this.setInvalid(InvalidationFlag.SELECTION);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this.selectedIndex;
	}

	/**

		@since 1.0.0
	**/
	@:isVar
	public var selectedItem(get, set):Dynamic = null;

	private function get_selectedItem():Dynamic {
		if (this.selectedIndex == -1) {
			return null;
		}
		return this.dataProvider.get(this.selectedIndex);
	}

	private function set_selectedItem(value:Dynamic):Dynamic {
		if (this.dataProvider == null) {
			this.selectedIndex = -1;
			return this.selectedItem;
		}
		this.selectedIndex = this.dataProvider.indexOf(value);
		return this.selectedItem;
	}

	/**

		@since 1.0.0
	**/
	@:style
	public var layout:ILayout = null;

	private var _pool:ObjectPool<DisplayObject> = new ObjectPool(defaultItemRendererFactory);

	/**

		@since 1.0.0
	**/
	public var itemRendererFactory(get, set):() -> DisplayObject;

	private function get_itemRendererFactory():() -> DisplayObject {
		return this._pool.create;
	}

	private function set_itemRendererFactory(value:() -> DisplayObject):() -> DisplayObject {
		if (this._pool.create == value) {
			return this._pool.create;
		}
		if (value == null) {
			value = defaultItemRendererFactory;
		}
		this._pool.create = value;
		this.setInvalid(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);
		return this._pool.create;
	}

	/**
		An optional function that allows an item renderer to be customized
		based on its data.

		@since 1.0.0
	**/
	public var updateItemRenderer(default, set):(itemRenderer:Dynamic, state:ListBoxItemState) -> Void;

	private function set_updateItemRenderer(value:(Dynamic, ListBoxItemState) -> Void):(DisplayObject, ListBoxItemState) -> Void {
		if (this.updateItemRenderer == value) {
			return this.updateItemRenderer;
		}
		this.updateItemRenderer = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this.updateItemRenderer;
	}

	private function defaultUpdateItemRenderer(itemRenderer:Dynamic, state:ListBoxItemState):Void {
		if (Std.is(itemRenderer, ITextControl)) {
			var textControl = cast(itemRenderer, ITextControl);
			textControl.text = itemToText(state.data);
		}
		if (Std.is(itemRenderer, IDataRenderer)) {
			var dataRenderer = cast(itemRenderer, IDataRenderer);
			dataRenderer.data = state.data;
		}
		if (Std.is(itemRenderer, IToggle)) {
			var toggle = cast(itemRenderer, IToggle);
			toggle.selected = state.data == this.selectedItem;
		}
	}

	/**
		An optional function to clean up an item renderer before it is returned
		to the pool and made available for reuse with new data.

		@since 1.0.0
	**/
	public var cleanupItemRenderer(default, set):(itemRenderer:Dynamic, state:ListBoxItemState) -> Void;

	private function set_cleanupItemRenderer(value:(Dynamic, ListBoxItemState) -> Void):(Dynamic, ListBoxItemState) -> Void {
		if (this.cleanupItemRenderer == value) {
			return this.cleanupItemRenderer;
		}
		this.cleanupItemRenderer = value;
		// not necessary to set invalid because this affects only item renderers
		// when other things change
		return this.cleanupItemRenderer;
	}

	private function defaultCleanupItemRenderer(itemRenderer:Dynamic, state:ListBoxItemState):Void {
		if (Std.is(itemRenderer, ITextControl)) {
			var textControl = cast(itemRenderer, ITextControl);
			textControl.text = null;
		}
		if (Std.is(itemRenderer, IToggle)) {
			var toggle = cast(itemRenderer, IToggle);
			toggle.selected = false;
		}
		if (Std.is(itemRenderer, IDataRenderer)) {
			var dataRenderer = cast(itemRenderer, IDataRenderer);
			dataRenderer.data = null;
		}
	}

	private static function defaultItemRendererFactory():DisplayObject {
		return new ItemRenderer();
	}

	private var inactiveItemRenderers:Array<DisplayObject> = [];
	private var activeItemRenderers:Array<DisplayObject> = [];
	private var dataToItemRenderer = new ObjectMap<Dynamic, DisplayObject>();
	private var itemRendererToData = new ObjectMap<DisplayObject, Dynamic>();
	private var _unrenderedData:Array<Dynamic> = [];

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

	public dynamic function itemToText(data:Dynamic):String {
		return Std.string(data);
	}

	private function initializeListBoxTheme():Void {
		SteelListBoxStyles.initialize();
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
			throw new IllegalOperationError("ListBox: inactive item renderers should be empty after updating.");
		}
	}

	private function refreshInactiveItemRenderers(factoryInvalid:Bool):Void {
		var temp = this.inactiveItemRenderers;
		this.inactiveItemRenderers = this.activeItemRenderers;
		this.activeItemRenderers = temp;
		if (this.activeItemRenderers.length > 0) {
			throw new IllegalOperationError("ListBox: active item renderers should be empty before updating.");
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
			var oldIgnoreSelectionChange = this._ignoreSelectionChange;
			this._ignoreSelectionChange = true;
			if (this.cleanupItemRenderer != null) {
				this.cleanupItemRenderer(itemRenderer, item);
			} else if (this.defaultCleanupItemRenderer != null) {
				this.defaultCleanupItemRenderer(itemRenderer, this._currentItemState);
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

	private var _currentItemState = new ListBoxItemState();

	private function findUnrenderedData():Void {
		for (i in 0...this.dataProvider.length) {
			var item = this.dataProvider.get(i);
			var itemRenderer = this.dataToItemRenderer.get(item);
			if (itemRenderer != null) {
				this._currentItemState.data = item;
				this._currentItemState.index = i;
				this._currentItemState.selected = item == this.selectedItem;
				var oldIgnoreSelectionChange = this._ignoreSelectionChange;
				this._ignoreSelectionChange = true;
				if (this.updateItemRenderer != null) {
					this.updateItemRenderer(itemRenderer, this._currentItemState);
				} else if (this.defaultUpdateItemRenderer != null) {
					this.defaultUpdateItemRenderer(itemRenderer, this._currentItemState);
				}
				this._ignoreSelectionChange = oldIgnoreSelectionChange;
				// if this item renderer used to be the typical layout item, but
				// it isn't anymore, it may have been set invisible
				itemRenderer.visible = true;
				var displayObject = cast(itemRenderer, DisplayObject);
				this.listViewPort.addChildAt(displayObject, i);
				var removed = inactiveItemRenderers.remove(itemRenderer);
				if (!removed) {
					throw new IllegalOperationError("ListBox: item renderer map contains bad data. This may be caused by duplicate items in the data provider, which is not allowed.");
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
			var displayObject = cast(itemRenderer, DisplayObject);
			this.listViewPort.addChildAt(displayObject, index);
		}
		this._unrenderedData.resize(0);
	}

	private function createItemRenderer(item:Dynamic, index:Int):DisplayObject {
		var itemRenderer:DisplayObject = null;
		if (this.inactiveItemRenderers.length == 0) {
			itemRenderer = this._pool.create();
		} else {
			itemRenderer = this.inactiveItemRenderers.shift();
		}
		this._currentItemState.data = item;
		this._currentItemState.index = index;
		this._currentItemState.selected = item == this.selectedItem;
		if (this.updateItemRenderer != null) {
			this.updateItemRenderer(itemRenderer, this._currentItemState);
		} else if (this.defaultUpdateItemRenderer != null) {
			this.defaultUpdateItemRenderer(itemRenderer, this._currentItemState);
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
		var displayObject = cast(itemRenderer, DisplayObject);
		this.listViewPort.removeChild(displayObject);
		this._pool.clean(itemRenderer);
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
}

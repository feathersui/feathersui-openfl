/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import haxe.ds.ObjectMap;
import openfl.errors.IllegalOperationError;
import lime.utils.ObjectPool;
import feathers.skins.RectangleSkin;
import feathers.layout.VerticalListFixedRowLayout;
import feathers.style.Theme;
import feathers.themes.DefaultTheme;
import openfl.display.DisplayObject;
import openfl.events.Event;
import feathers.core.InvalidationFlag;
import feathers.controls.dataRenderers.IListBoxItemRenderer;
import feathers.controls.dataRenderers.ListBoxItemRenderer;
import feathers.controls.supportClasses.LayoutViewPort;
import feathers.controls.supportClasses.BaseScrollContainer;
import feathers.layout.ILayout;
import feathers.data.IFlatCollection;
import feathers.events.FeathersEvent;

/**

	@since 1.0.0
**/
@:access(feathers.themes.DefaultTheme)
@:styleContext
class ListBox extends BaseScrollContainer {
	private static final INVALIDATION_FLAG_ITEM_RENDERER_FACTORY = "itemRendererFactory";

	public function new() {
		var theme = Std.downcast(Theme.fallbackTheme, DefaultTheme);
		if (theme != null && theme.styleProvider.getStyleFunction(ListBox, null) == null) {
			theme.styleProvider.setStyleFunction(ListBox, null, setListBoxStyles);
		}
		super();
		if (this.viewPort == null) {
			this.listViewPort = new LayoutViewPort();
			this.addChild(this.listViewPort);
			this.viewPort = this.listViewPort;
		}
	}

	private var listViewPort:LayoutViewPort;

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
		if (this.selectedIndex == value) {
			return this.selectedIndex;
		}
		this.selectedIndex = value;
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

	private var _pool:ObjectPool<IListBoxItemRenderer> = new ObjectPool(defaultItemRendererFactory);

	/**

		@since 1.0.0
	**/
	public var itemRendererFactory(get, set):() -> IListBoxItemRenderer;

	private function get_itemRendererFactory():() -> IListBoxItemRenderer {
		return this._pool.create;
	}

	private function set_itemRendererFactory(value:() -> IListBoxItemRenderer):() -> IListBoxItemRenderer {
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
	public var prepareItemRenderer(default, set):(IListBoxItemRenderer, Dynamic) -> Void = null;

	private function set_prepareItemRenderer(value:(IListBoxItemRenderer, Dynamic) -> Void):(IListBoxItemRenderer, Dynamic) -> Void {
		if (this.prepareItemRenderer == value) {
			return this.prepareItemRenderer;
		}
		this.prepareItemRenderer = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this.prepareItemRenderer;
	}

	/**
		An optional function to clean up an item renderer before it is returned
		to the pool and possibly re-used for new data.

		@since 1.0.0
	**/
	public var cleanupItemRenderer(default, set):(IListBoxItemRenderer) -> Void;

	private function set_cleanupItemRenderer(value:(IListBoxItemRenderer) -> Void):(IListBoxItemRenderer) -> Void {
		if (this.cleanupItemRenderer == value) {
			return this.cleanupItemRenderer;
		}
		this.cleanupItemRenderer = value;
		// not necessary to set invalid because this affects only item renderers
		// when other things change
		return this.cleanupItemRenderer;
	}

	private static function defaultItemRendererFactory():IListBoxItemRenderer {
		return new ListBoxItemRenderer();
	}

	private var inactiveItemRenderers:Array<IListBoxItemRenderer> = [];
	private var activeItemRenderers:Array<IListBoxItemRenderer> = [];
	private var itemRendererMap = new ObjectMap<Dynamic, IListBoxItemRenderer>();
	private var _unrenderedData:Array<Dynamic> = [];

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);
		var layoutInvalid = this.isInvalid(InvalidationFlag.LAYOUT);
		var stylesInvalid = this.isInvalid(InvalidationFlag.STYLES);
		var itemRendererInvalid = this.isInvalid(INVALIDATION_FLAG_ITEM_RENDERER_FACTORY);

		if (itemRendererInvalid || dataInvalid) {
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
			if (itemRenderer == null || itemRenderer.index != -1) {
				continue;
			}
			this.itemRendererMap.remove(itemRenderer.data);
			if (this.cleanupItemRenderer != null) {
				this.cleanupItemRenderer(itemRenderer);
			}
			itemRenderer.data = null;
			itemRenderer.index = -1;
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

	private function findUnrenderedData():Void {
		for (i in 0...this.dataProvider.length) {
			var item = this.dataProvider.get(i);
			var itemRenderer:IListBoxItemRenderer = this.itemRendererMap.get(item);
			if (itemRenderer != null) {
				// the index may have changed if items were added, removed, or
				// re-ordered in the data provider
				itemRenderer.index = i;
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

	private function createItemRenderer(item:Dynamic, index:Int):IListBoxItemRenderer {
		var itemRenderer:IListBoxItemRenderer = null;
		if (this.inactiveItemRenderers.length == 0) {
			itemRenderer = this._pool.create();
		} else {
			itemRenderer = this.inactiveItemRenderers.shift();
		}
		itemRenderer.index = index;
		itemRenderer.data = item;
		if (this.prepareItemRenderer != null) {
			this.prepareItemRenderer(itemRenderer, item);
		}
		itemRenderer.addEventListener(FeathersEvent.TRIGGERED, itemRenderer_triggeredHandler);
		this.itemRendererMap.set(item, itemRenderer);
		return itemRenderer;
	}

	private function destroyItemRenderer(itemRenderer:IListBoxItemRenderer):Void {
		itemRenderer.removeEventListener(FeathersEvent.TRIGGERED, itemRenderer_triggeredHandler);
		var displayObject = cast(itemRenderer, DisplayObject);
		this.listViewPort.removeChild(displayObject);
		this._pool.clean(itemRenderer);
	}

	private function itemRenderer_triggeredHandler(event:FeathersEvent):Void {
		var itemRenderer:IListBoxItemRenderer = cast(event.currentTarget, IListBoxItemRenderer);
		// trigger before change
		FeathersEvent.dispatch(this, FeathersEvent.TRIGGERED);
		this.selectedIndex = itemRenderer.index;
	}

	private function dataProvider_changeHandler(event:Event):Void {
		this.setInvalid(InvalidationFlag.DATA);
	}

	private static function setListBoxStyles(listBox:ListBox):Void {
		var defaultTheme:DefaultTheme = Std.downcast(Theme.fallbackTheme, DefaultTheme);
		if (defaultTheme == null) {
			return;
		}

		if (listBox.layout == null) {
			listBox.layout = new VerticalListFixedRowLayout();
		}

		if (listBox.backgroundSkin == null) {
			var backgroundSkin = new RectangleSkin();
			backgroundSkin.fill = defaultTheme.getContainerFill();
			// backgroundSkin.border = defaultTheme.getContainerBorder();
			backgroundSkin.width = 160.0;
			backgroundSkin.height = 160.0;
			listBox.backgroundSkin = backgroundSkin;
		}
	}
}

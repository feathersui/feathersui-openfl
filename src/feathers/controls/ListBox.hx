/*
	Feathers
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;
import feathers.core.FeathersControl;
import feathers.core.InvalidationFlag;
import feathers.core.IValidating;
import feathers.core.IStateContext;
import feathers.core.IStateObserver;
import feathers.core.IUIControl;
import feathers.controls.dataRenderers.IListBoxItemRenderer;
import feathers.controls.dataRenderers.ListBoxItemRenderer;
import feathers.controls.supportClasses.LayoutViewPort;
import feathers.controls.supportClasses.BaseScrollContainer;
import feathers.layout.ILayout;
import feathers.layout.Measurements;
import feathers.layout.VerticalListFixedRowLayout;
import feathers.data.IFlatCollection;
import feathers.events.FeathersEvent;
import feathers.style.IStyleProvider;
import feathers.style.IStyleObject;
import feathers.style.FunctionStyleProvider;
import feathers.utils.Scroller;

class ListBox extends BaseScrollContainer {
	public function new() {
		super();
		if (this.viewPort == null) {
			this.listViewPort = new LayoutViewPort();
			this.addChild(this.listViewPort);
			this.viewPort = this.listViewPort;
		}
	}

	private var listViewPort:LayoutViewPort;

	override private function get_styleContext():Class<IStyleObject> {
		return ListBox;
	}

	public var dataProvider(default, set):IFlatCollection<Dynamic> = null;

	private function set_dataProvider(value:IFlatCollection<Dynamic>):IFlatCollection<Dynamic> {
		if (this.dataProvider == value) {
			return this.dataProvider;
		}
		this.dataProvider = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this.dataProvider;
	}

	public var selectedIndex(default, set):Int = -1;

	private function set_selectedIndex(value:Int):Int {
		if (this.selectedIndex == value) {
			return this.selectedIndex;
		}
		this.selectedIndex = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this.selectedIndex;
	}

	public var selectedItem(get, null):Dynamic = null;

	private function get_selectedItem():Dynamic {
		if (this.selectedIndex == -1) {
			return null;
		}
		return this.dataProvider.get(this.selectedIndex);
	}

	@style
	public var layout(default, set):ILayout = null;

	private function set_layout(value:ILayout):ILayout {
		if (!this.setStyle("layout")) {
			return this.layout;
		}
		if (this.layout == value) {
			return this.layout;
		}
		this.layout = value;
		this.setInvalid(InvalidationFlag.LAYOUT);
		return this.layout;
	}

	private var activeItemRenderers:Array<IListBoxItemRenderer> = [];

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);
		var layoutInvalid = this.isInvalid(InvalidationFlag.LAYOUT);

		if (dataInvalid) {
			this.refreshItemRenderers();
		}

		if (layoutInvalid) {
			this.listViewPort.layout = this.layout;
		}

		super.update();
	}

	private function refreshItemRenderers():Void {
		this.clearItemRenderers();
		if (this.dataProvider == null) {
			return;
		}
		for (i in 0...this.dataProvider.length) {
			var item = this.dataProvider.get(i);
			var itemRenderer = this.createItemRenderer(item, i);
			this.activeItemRenderers.push(itemRenderer);
			var displayObject = cast(itemRenderer, DisplayObject);
			this.listViewPort.addChild(displayObject);
		}
	}

	private function clearItemRenderers():Void {
		for (itemRenderer in this.activeItemRenderers) {
			this.destroyItemRenderer(itemRenderer);
			var displayObject = cast(itemRenderer, DisplayObject);
			this.listViewPort.removeChild(displayObject);
			this.activeItemRenderers.remove(itemRenderer);
		}
	}

	private function createItemRenderer(item:Dynamic, index:Int):IListBoxItemRenderer {
		var itemRenderer:ListBoxItemRenderer = new ListBoxItemRenderer();
		itemRenderer.index = index;
		itemRenderer.data = item;
		itemRenderer.addEventListener(MouseEvent.CLICK, itemRenderer_clickHandler);
		return itemRenderer;
	}

	private function destroyItemRenderer(itemRenderer:IListBoxItemRenderer):Void {
		itemRenderer.removeEventListener(MouseEvent.CLICK, itemRenderer_clickHandler);
		itemRenderer.data = null;
		itemRenderer.index = -1;
	}

	private function itemRenderer_clickHandler(event:MouseEvent):Void {
		var itemRenderer:IListBoxItemRenderer = cast(event.currentTarget, IListBoxItemRenderer);
		this.selectedIndex = itemRenderer.index;
	}
}

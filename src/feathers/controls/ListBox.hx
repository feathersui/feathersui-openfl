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
import feathers.layout.ILayout;
import feathers.layout.Measurements;
import feathers.layout.VerticalListFixedRowLayout;
import feathers.data.IFlatCollection;
import feathers.events.FeathersEvent;
import feathers.style.IStyleProvider;
import feathers.style.IStyleObject;
import feathers.style.CallbackStyleProvider;
import feathers.utils.Scroller;

class ListBox extends FeathersControl {
	private static var ListBox_defaultStyleProvider = null;

	public function new() {
		super();
	}

	private var viewPort:LayoutViewPort;
	private var scroller:Scroller;

	override private function get_styleContext():Class<IStyleObject> {
		return ListBox;
	}

	override private function get_defaultStyleProvider():IStyleProvider {
		if (ListBox_defaultStyleProvider == null) {
			ListBox_defaultStyleProvider = new CallbackStyleProvider(function(target:ListBox):Void {
				if (target.layout == null) {
					target.layout = new VerticalListFixedRowLayout();
				}
			});
		}
		return ListBox_defaultStyleProvider;
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

	private var _currentBackgroundSkin:DisplayObject = null;
	private var _backgroundSkinMeasurements:Measurements = null;

	/**
		The default background skin to display behind all content added to the
		group. The background skin is resized to fill the complete width and
		height of the group.

		The following example gives the group a background skin:

		```hx
		group.backgroundSkin = new Bitmap(bitmapData);
		```

		@default null

		@see `LayoutGroup.backgroundDisabledSkin`

		@since 1.0.0
	**/
	@style
	public var backgroundSkin(default, set):DisplayObject = null;

	private function set_backgroundSkin(value:DisplayObject):DisplayObject {
		if (!this.setStyle("backgroundSkin")) {
			return this.backgroundSkin;
		}
		if (this.backgroundSkin == value) {
			return this.backgroundSkin;
		}
		if (this.backgroundSkin != null && this.backgroundSkin == this._currentBackgroundSkin) {
			this.removeCurrentBackgroundSkin(this.backgroundSkin);
			this._currentBackgroundSkin = null;
		}
		this.backgroundSkin = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.backgroundSkin;
	}

	/**
		The default background skin to display behind all content added to the
		group. The background skin is resized to fill the complete width and
		height of the group.

		The following example gives the group a disabled background skin:

		```hx
		group.backgroundDisabledSkin = new Bitmap(bitmapData);
		group.enabled = false;
		```

		@default null

		@see `LayoutGroup.backgroundSkin`

		@since 1.0.0
	**/
	@style
	public var backgroundDisabledSkin(default, set):DisplayObject = null;

	private function set_backgroundDisabledSkin(value:DisplayObject):DisplayObject {
		if (!this.setStyle("backgroundDisabledSkin")) {
			return this.backgroundDisabledSkin;
		}
		if (this.backgroundDisabledSkin == value) {
			return this.backgroundDisabledSkin;
		}
		if (this.backgroundDisabledSkin != null && this.backgroundDisabledSkin == this._currentBackgroundSkin) {
			this.removeCurrentBackgroundSkin(this.backgroundDisabledSkin);
			this._currentBackgroundSkin = null;
		}
		this.backgroundDisabledSkin = value;
		this.setInvalid(InvalidationFlag.STYLES);
		return this.backgroundDisabledSkin;
	}

	private var activeItemRenderers:Array<IListBoxItemRenderer> = [];
	private var _currentScrollRect:Rectangle;
	private var _scrollRect1:Rectangle = new Rectangle();
	private var _scrollRect2:Rectangle = new Rectangle();

	override private function initialize():Void {
		if (this.scroller == null) {
			this.scroller = new Scroller();
		}
		if (this.viewPort == null) {
			this.viewPort = new LayoutViewPort();
			this.addChild(this.viewPort);
		}
		this.scroller.target = this;
		this.scroller.addEventListener(Event.SCROLL, listBox_scroller_scrollHandler);
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);

		if (dataInvalid) {
			this.refreshItemRenderers();
		}

		var stylesInvalid = this.isInvalid(InvalidationFlag.STYLES);
		var sizeInvalid = this.isInvalid(InvalidationFlag.SIZE);
		var layoutInvalid = this.isInvalid(InvalidationFlag.LAYOUT);

		if (layoutInvalid) {
			this.viewPort.layout = this.layout;
		}

		if (stylesInvalid) {
			this.refreshBackgroundSkin();
		}

		sizeInvalid = this.autoSizeIfNeeded() || sizeInvalid;

		this.refreshViewPortLayout();
		this.refreshScrollRect();
		this.refreshScroller();
		this.refreshBackgroundLayout();
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
			this.viewPort.addChild(displayObject);
		}
	}

	private function clearItemRenderers():Void {
		for (itemRenderer in this.activeItemRenderers) {
			this.destroyItemRenderer(itemRenderer);
			var displayObject = cast(itemRenderer, DisplayObject);
			this.viewPort.removeChild(displayObject);
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

	private function refreshViewPortLayout():Void {
		this.viewPort.visibleWidth = this.actualWidth;
		this.viewPort.visibleHeight = this.actualHeight;
		this.viewPort.minVisibleWidth = this.actualMinWidth;
		this.viewPort.minVisibleHeight = this.actualMinHeight;
		this.viewPort.maxVisibleWidth = this.actualMaxWidth;
		this.viewPort.maxVisibleHeight = this.actualMaxHeight;
		this.viewPort.validateNow();
	}

	private function refreshScroller():Void {
		this.scroller.setDimensions(this.viewPort.visibleWidth, this.viewPort.visibleHeight, this.viewPort.width, this.viewPort.height);
	}

	private function autoSizeIfNeeded():Bool {
		return false;
	}

	private function refreshBackgroundSkin():Void {
		var oldSkin = this._currentBackgroundSkin;
		this._currentBackgroundSkin = this.getCurrentBackgroundSkin();
		if (this._currentBackgroundSkin == oldSkin) {
			return;
		}
		this.removeCurrentBackgroundSkin(oldSkin);
		if (this._currentBackgroundSkin == null) {
			this._backgroundSkinMeasurements = null;
			return;
		}
		if (Std.is(this._currentBackgroundSkin, IUIControl)) {
			cast(this._currentBackgroundSkin, IUIControl).initializeNow();
		}
		if (this._backgroundSkinMeasurements == null) {
			this._backgroundSkinMeasurements = new Measurements(this._currentBackgroundSkin);
		} else {
			this._backgroundSkinMeasurements.save(this._currentBackgroundSkin);
		}
		if (Std.is(this, IStateContext) && Std.is(this._currentBackgroundSkin, IStateObserver)) {
			cast(this._currentBackgroundSkin, IStateObserver).stateContext = cast(this, IStateContext);
		}
		this.addChildAt(this._currentBackgroundSkin, 0);
	}

	private function getCurrentBackgroundSkin():DisplayObject {
		if (!this.enabled && this.backgroundDisabledSkin != null) {
			return this.backgroundDisabledSkin;
		}
		return this.backgroundSkin;
	}

	private function removeCurrentBackgroundSkin(skin:DisplayObject):Void {
		if (skin == null) {
			return;
		}
		if (Std.is(skin, IStateObserver)) {
			cast(skin, IStateObserver).stateContext = null;
		}
		if (skin.parent == this) {
			// we need to restore these values so that they won't be lost the
			// next time that this skin is used for measurement
			this.removeChild(skin);
		}
	}

	private function refreshBackgroundLayout():Void {
		if (this._currentBackgroundSkin == null) {
			return;
		}
		this._currentBackgroundSkin.x = 0;
		this._currentBackgroundSkin.y = 0;

		// don't set the width or height explicitly unless necessary because if
		// our explicit dimensions are cleared later, the measurement may not be
		// accurate anymore
		if (this._currentBackgroundSkin.width != this.actualWidth) {
			this._currentBackgroundSkin.width = this.actualWidth;
		}
		if (this._currentBackgroundSkin.height != this.actualHeight) {
			this._currentBackgroundSkin.height = this.actualHeight;
		}
		if (Std.is(this._currentBackgroundSkin, IValidating)) {
			cast(this._currentBackgroundSkin, IValidating).validateNow();
		}
	}

	private function refreshScrollRect():Void {
		// instead of creating a new Rectangle every time, we're going to swap
		// between two of them to avoid excessive garbage collection
		var scrollRect = this._scrollRect1;
		if (this._currentScrollRect == scrollRect) {
			scrollRect = this._scrollRect2;
		}
		this._currentScrollRect = scrollRect;
		scrollRect.setTo(scroller.scrollX, scroller.scrollY, this.actualWidth, this.actualHeight);
		this.viewPort.scrollRect = scrollRect;
	}

	private function itemRenderer_clickHandler(event:MouseEvent):Void {
		var itemRenderer:IListBoxItemRenderer = cast(event.currentTarget, IListBoxItemRenderer);
		this.selectedIndex = itemRenderer.index;
	}

	private function listBox_scroller_scrollHandler(event:Event):Void {
		this.refreshScrollRect();
	}
}

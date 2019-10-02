/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.supportClasses;

import feathers.layout.RelativePosition;
import feathers.core.IMeasureObject;
import feathers.core.IValidating;
import feathers.core.IStateObserver;
import feathers.core.IStateContext;
import feathers.core.IUIControl;
import openfl.events.Event;
import feathers.layout.Measurements;
import openfl.display.DisplayObject;
import feathers.utils.Scroller;
import feathers.core.InvalidationFlag;
import feathers.core.FeathersControl;
import openfl.geom.Rectangle;

/**
	A base class for scrolling containers.

	@since 1.0.0
**/
class BaseScrollContainer extends FeathersControl {
	private static final INVALIDATION_FLAG_SCROLL_BAR_FACTORY = "scrollBarFactory";

	private function new() {
		super();
	}

	/**
		@since 1.0.0
	**/
	@:dox(show)
	private var viewPort:IViewPort;

	private var scroller:Scroller;
	private var _currentBackgroundSkin:DisplayObject = null;
	private var _backgroundSkinMeasurements:Measurements = null;

	private var topViewPortOffset:Float = 0.0;
	private var rightViewPortOffset:Float = 0.0;
	private var bottomViewPortOffset:Float = 0.0;
	private var leftViewPortOffset:Float = 0.0;

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
	@:style
	public var backgroundSkin:DisplayObject = null;

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
	@:style
	public var backgroundDisabledSkin:DisplayObject = null;

	private var horizontalScrollBar:IScrollBar;
	private var verticalScrollBar:IScrollBar;

	public var horizontalScrollBarFactory(default, set):() -> IScrollBar = null;

	private function set_horizontalScrollBarFactory(value:() -> IScrollBar):() -> IScrollBar {
		if (this.horizontalScrollBarFactory == value) {
			return this.horizontalScrollBarFactory;
		}
		this.horizontalScrollBarFactory = value;
		this.setInvalid(INVALIDATION_FLAG_SCROLL_BAR_FACTORY);
		return this.horizontalScrollBarFactory;
	}

	public var verticalScrollBarFactory(default, set):() -> IScrollBar = null;

	private function set_verticalScrollBarFactory(value:() -> IScrollBar):() -> IScrollBar {
		if (this.verticalScrollBarFactory == value) {
			return this.verticalScrollBarFactory;
		}
		this.verticalScrollBarFactory = value;
		this.setInvalid(INVALIDATION_FLAG_SCROLL_BAR_FACTORY);
		return this.verticalScrollBarFactory;
	}

	public var scrollX(get, never):Float;

	private function get_scrollX():Float {
		if (this.scroller == null) {
			return 0.0;
		}
		return this.scroller.scrollX;
	}

	public var scrollY(get, never):Float;

	private function get_scrollY():Float {
		if (this.scroller == null) {
			return 0.0;
		}
		return this.scroller.scrollY;
	}

	public var minScrollX(get, never):Float;

	private function get_minScrollX():Float {
		if (this.scroller == null) {
			return 0.0;
		}
		return this.scroller.minScrollX;
	}

	public var minScrollY(get, never):Float;

	private function get_minScrollY():Float {
		if (this.scroller == null) {
			return 0.0;
		}
		return this.scroller.minScrollY;
	}

	public var maxScrollX(get, never):Float;

	private function get_maxScrollX():Float {
		if (this.scroller == null) {
			return 0.0;
		}
		return this.scroller.maxScrollX;
	}

	public var maxScrollY(get, never):Float;

	private function get_maxScrollY():Float {
		if (this.scroller == null) {
			return 0.0;
		}
		return this.scroller.maxScrollY;
	}

	public var scrollPolicyX(default, set):ScrollPolicy = ScrollPolicy.AUTO;

	private function set_scrollPolicyX(value:ScrollPolicy):ScrollPolicy {
		if (this.scrollPolicyX == value) {
			return this.scrollPolicyX;
		}
		this.scrollPolicyX = value;
		this.setInvalid(InvalidationFlag.SCROLL);
		return this.scrollPolicyX;
	}

	public var scrollPolicyY(default, set):ScrollPolicy = ScrollPolicy.AUTO;

	private function set_scrollPolicyY(value:ScrollPolicy):ScrollPolicy {
		if (this.scrollPolicyY == value) {
			return this.scrollPolicyY;
		}
		this.scrollPolicyY = value;
		this.setInvalid(InvalidationFlag.SCROLL);
		return this.scrollPolicyY;
	}

	@:style
	public var elasticEdges:Bool = true;

	@:style
	public var horizontalScrollBarPosition:RelativePosition = RelativePosition.BOTTOM;

	@:style
	public var verticalScrollBarPosition:RelativePosition = RelativePosition.RIGHT;

	private var _currentScrollRect:Rectangle;
	private var _scrollRect1:Rectangle = new Rectangle();
	private var _scrollRect2:Rectangle = new Rectangle();

	override private function initialize():Void {
		if (this.scroller == null) {
			this.scroller = new Scroller();
		}
		this.scroller.target = this;
		this.scroller.addEventListener(Event.SCROLL, scroller_scrollHandler);
	}

	override private function update():Void {
		var stylesInvalid = this.isInvalid(InvalidationFlag.STYLES);
		var sizeInvalid = this.isInvalid(InvalidationFlag.SIZE);
		var stateInvalid = this.isInvalid(InvalidationFlag.STATE);
		var scrollInvalid = this.isInvalid(InvalidationFlag.SCROLL);
		var scrollBarFactoryInvalid = this.isInvalid(INVALIDATION_FLAG_SCROLL_BAR_FACTORY);

		if (stylesInvalid || stateInvalid) {
			this.refreshBackgroundSkin();
		}

		if (scrollBarFactoryInvalid) {
			this.createScrollBars();
		}

		this.refreshOffsets();
		sizeInvalid = this.autoSizeIfNeeded() || sizeInvalid;

		this.refreshViewPortLayout();
		this.refreshScrollRect();
		this.refreshScroller();
		this.refreshScrollBarValues();
		this.layoutChildren();
	}

	private function createScrollBars():Void {
		if (this.horizontalScrollBar != null) {
			this.horizontalScrollBar.removeEventListener(Event.CHANGE, horizontalScrollBar_changeHandler);
			this.removeChild(cast(this.horizontalScrollBar, DisplayObject));
			this.horizontalScrollBar = null;
		}
		if (this.verticalScrollBar != null) {
			this.verticalScrollBar.removeEventListener(Event.CHANGE, verticalScrollBar_changeHandler);
			this.removeChild(cast(this.verticalScrollBar, DisplayObject));
			this.verticalScrollBar = null;
		}
		if (this.horizontalScrollBarFactory != null) {
			this.horizontalScrollBar = this.horizontalScrollBarFactory();
			this.horizontalScrollBar.addEventListener(Event.CHANGE, horizontalScrollBar_changeHandler);
			this.addChild(cast(this.horizontalScrollBar, DisplayObject));
		}
		if (this.verticalScrollBarFactory != null) {
			this.verticalScrollBar = this.verticalScrollBarFactory();
			this.verticalScrollBar.addEventListener(Event.CHANGE, verticalScrollBar_changeHandler);
			this.addChild(cast(this.verticalScrollBar, DisplayObject));
		}
	}

	private function refreshOffsets():Void {
		this.topViewPortOffset = 0.0;
		this.rightViewPortOffset = 0.0;
		this.bottomViewPortOffset = 0.0;
		this.leftViewPortOffset = 0.0;
	}

	private function refreshViewPortLayout():Void {
		this.viewPort.x = this.leftViewPortOffset;
		this.viewPort.y = this.topViewPortOffset;
		this.viewPort.visibleWidth = this.actualWidth - this.leftViewPortOffset - this.rightViewPortOffset;
		this.viewPort.visibleHeight = this.actualHeight - this.topViewPortOffset - this.bottomViewPortOffset;
		this.viewPort.minVisibleWidth = this.actualMinWidth - this.leftViewPortOffset - this.rightViewPortOffset;
		this.viewPort.minVisibleHeight = this.actualMinHeight - this.topViewPortOffset - this.bottomViewPortOffset;
		this.viewPort.maxVisibleWidth = this.actualMaxWidth - this.leftViewPortOffset - this.rightViewPortOffset;
		this.viewPort.maxVisibleHeight = this.actualMaxHeight - this.topViewPortOffset - this.bottomViewPortOffset;
		this.viewPort.validateNow();
	}

	private function refreshScroller():Void {
		this.scroller.scrollPolicyX = this.scrollPolicyX;
		this.scroller.scrollPolicyY = this.scrollPolicyY;
		this.scroller.elasticEdges = this.elasticEdges;
		this.scroller.setDimensions(this.viewPort.visibleWidth, this.viewPort.visibleHeight, this.viewPort.width, this.viewPort.height);
	}

	private function refreshScrollBarValues():Void {
		if (this.horizontalScrollBar != null) {
			this.horizontalScrollBar.minimum = this.scroller.minScrollX;
			this.horizontalScrollBar.maximum = this.scroller.maxScrollX;
			this.horizontalScrollBar.value = this.scroller.scrollX;
			this.horizontalScrollBar.page = (this.scroller.maxScrollX - this.scroller.minScrollX) * this.viewPort.visibleWidth / this.viewPort.width;
			this.horizontalScrollBar.step = 0.0;
		}
		if (this.verticalScrollBar != null) {
			this.verticalScrollBar.minimum = this.scroller.minScrollY;
			this.verticalScrollBar.maximum = this.scroller.maxScrollY;
			this.verticalScrollBar.value = this.scroller.scrollY;
			this.verticalScrollBar.page = (this.scroller.maxScrollY - this.scroller.minScrollY) * this.viewPort.visibleHeight / this.viewPort.height;
			this.verticalScrollBar.step = 0.0;
		}
	}

	private function autoSizeIfNeeded():Bool {
		var needsWidth = this.explicitWidth == null;
		var needsHeight = this.explicitHeight == null;
		var needsMinWidth = this.explicitMinWidth == null;
		var needsMinHeight = this.explicitMinHeight == null;
		var needsMaxWidth = this.explicitMaxWidth == null;
		var needsMaxHeight = this.explicitMaxHeight == null;
		if (!needsWidth && !needsHeight && !needsMinWidth && !needsMinHeight && !needsMaxWidth && !needsMaxHeight) {
			return false;
		}

		if (this._currentBackgroundSkin != null) {
			this._backgroundSkinMeasurements.resetTargetFluidlyForParent(this._currentBackgroundSkin, this);
		}

		var measureSkin:IMeasureObject = null;
		if (Std.is(this._currentBackgroundSkin, IMeasureObject)) {
			measureSkin = cast(this._currentBackgroundSkin, IMeasureObject);
		}

		if (Std.is(this._currentBackgroundSkin, IValidating)) {
			cast(this._currentBackgroundSkin, IValidating).validateNow();
		}

		this.viewPort.validateNow();

		var newWidth = this.explicitWidth;
		if (needsWidth) {
			newWidth = this.viewPort.visibleWidth + this.leftViewPortOffset + this.rightViewPortOffset;
			if (this._currentBackgroundSkin != null) {
				newWidth = Math.max(newWidth, this._currentBackgroundSkin.width);
			}
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			newHeight = this.viewPort.visibleHeight + this.topViewPortOffset + this.bottomViewPortOffset;
			if (this._currentBackgroundSkin != null) {
				newHeight = Math.max(newHeight, this._currentBackgroundSkin.height);
			}
		}

		var newMinWidth = this.explicitMinWidth;
		if (needsMinWidth) {
			newMinWidth = this.viewPort.minVisibleWidth + this.leftViewPortOffset + this.rightViewPortOffset;
			if (measureSkin != null) {
				newMinWidth = Math.max(newMinWidth, measureSkin.minWidth);
			} else if (this._backgroundSkinMeasurements != null) {
				newMinWidth = Math.max(newMinWidth, this._backgroundSkinMeasurements.minWidth);
			}
		}

		var newMinHeight = this.explicitMinHeight;
		if (needsMinHeight) {
			newMinHeight = this.viewPort.minVisibleHeight + this.topViewPortOffset + this.bottomViewPortOffset;
			if (measureSkin != null) {
				newMinHeight = Math.max(newMinHeight, measureSkin.minHeight);
			} else if (this._backgroundSkinMeasurements != null) {
				newMinHeight = Math.max(newMinHeight, this._backgroundSkinMeasurements.minHeight);
			}
		}
		var newMaxWidth = this.explicitMaxWidth;
		if (needsMaxWidth) {
			newMaxWidth = this.viewPort.maxVisibleWidth + this.leftViewPortOffset + this.rightViewPortOffset;
			if (measureSkin != null) {
				newMaxWidth = Math.min(newMaxWidth, measureSkin.maxWidth);
			} else if (this._backgroundSkinMeasurements != null) {
				newMaxWidth = Math.min(newMaxWidth, this._backgroundSkinMeasurements.maxWidth);
			}
		}

		var newMaxHeight = this.explicitMaxHeight;
		if (needsMaxHeight) {
			newMaxHeight = this.viewPort.maxVisibleHeight + this.topViewPortOffset + this.bottomViewPortOffset;
			if (measureSkin != null) {
				newMaxHeight = Math.min(newMaxHeight, measureSkin.maxHeight);
			} else if (this._backgroundSkinMeasurements != null) {
				newMaxHeight = Math.min(newMaxHeight, this._backgroundSkinMeasurements.maxHeight);
			}
		}

		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight, newMaxWidth, newMaxHeight);
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
			cast(this._currentBackgroundSkin, IStateObserver).stateContext = cast(this, IStateContext<Dynamic>);
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

	private function layoutChildren():Void {
		this.layoutBackgroundSkin();
		this.layoutScrollBars();
	}

	private function layoutBackgroundSkin():Void {
		if (this._currentBackgroundSkin == null) {
			return;
		}
		this._currentBackgroundSkin.x = 0.0;
		this._currentBackgroundSkin.y = 0.0;

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

	private function layoutScrollBars():Void {
		var visibleWidth = this.actualWidth - this.leftViewPortOffset - this.rightViewPortOffset;
		var visibleHeight = this.actualHeight - this.topViewPortOffset - this.bottomViewPortOffset;

		if (this.horizontalScrollBar != null && Std.is(this.horizontalScrollBar, IValidating)) {
			cast(this.horizontalScrollBar, IValidating).validateNow();
		}
		if (this.verticalScrollBar != null && Std.is(this.verticalScrollBar, IValidating)) {
			cast(this.verticalScrollBar, IValidating).validateNow();
		}

		if (this.horizontalScrollBar != null) {
			switch (this.horizontalScrollBarPosition) {
				case RelativePosition.TOP:
					this.horizontalScrollBar.y = 0;
				default:
					this.horizontalScrollBar.y = this.topViewPortOffset + visibleHeight;
			}
			this.horizontalScrollBar.y -= this.horizontalScrollBar.height;
			this.horizontalScrollBar.x = this.leftViewPortOffset;
			this.horizontalScrollBar.width = visibleWidth;
		}
		if (this.verticalScrollBar != null) {
			switch (this.verticalScrollBarPosition) {
				case RelativePosition.LEFT:
					this.verticalScrollBar.x = 0;
				default:
					this.verticalScrollBar.x = this.leftViewPortOffset + visibleWidth;
			}
			this.verticalScrollBar.x -= this.verticalScrollBar.width;
			this.verticalScrollBar.y = this.topViewPortOffset;
			this.verticalScrollBar.height = visibleHeight;
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
		var displayViewPort = cast(this.viewPort, DisplayObject);
		displayViewPort.scrollRect = scrollRect;
	}

	private function scroller_scrollHandler(event:Event):Void {
		this.refreshScrollRect();
		this.refreshScrollBarValues();
	}

	private function horizontalScrollBar_changeHandler(event:Event):Void {
		this.scroller.scrollX = this.horizontalScrollBar.value;
	}

	private function verticalScrollBar_changeHandler(event:Event):Void {
		this.scroller.scrollY = this.verticalScrollBar.value;
	}
}

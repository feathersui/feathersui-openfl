/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.supportClasses;

import openfl.display.DisplayObjectContainer;
import openfl.events.MouseEvent;
import openfl.display.InteractiveObject;
import feathers.events.FeathersEvent;
import motion.easing.Quart;
import motion.easing.IEasing;
import motion.actuators.SimpleActuator;
import motion.Actuate;
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

	private static function defaultScrollBarXFactory():IScrollBar {
		return new HScrollBar();
	}

	private static function defaultScrollBarYFactory():IScrollBar {
		return new VScrollBar();
	}

	private function new() {
		super();
	}

	/**
		@since 1.0.0
	**/
	@:dox(show)
	private var viewPort(default, set):IViewPort;

	private function set_viewPort(value:IViewPort):IViewPort {
		if (this.viewPort == value) {
			return this.viewPort;
		}
		this.viewPort = value;
		if (this.scroller != null) {
			this.scroller.target = cast(this.viewPort, InteractiveObject);
		}
		return this.viewPort;
	}

	private var scroller:Scroller;

	private var _scrollerDraggingX = false;
	private var _scrollerDraggingY = false;
	private var _scrollBarXHover = false;
	private var _scrollBarYHover = false;

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

	private var scrollBarX:IScrollBar;
	private var scrollBarY:IScrollBar;

	@:style
	public var fixedScrollBars:Null<Bool> = false;

	@:style
	public var autoHideScrollBars:Null<Bool> = true;

	public var scrollBarXFactory(default, set):() -> IScrollBar = defaultScrollBarXFactory;

	private function set_scrollBarXFactory(value:() -> IScrollBar):() -> IScrollBar {
		if (this.scrollBarXFactory == value) {
			return this.scrollBarXFactory;
		}
		this.scrollBarXFactory = value;
		this.setInvalid(INVALIDATION_FLAG_SCROLL_BAR_FACTORY);
		return this.scrollBarXFactory;
	}

	public var scrollBarYFactory(default, set):() -> IScrollBar = defaultScrollBarYFactory;

	private function set_scrollBarYFactory(value:() -> IScrollBar):() -> IScrollBar {
		if (this.scrollBarYFactory == value) {
			return this.scrollBarYFactory;
		}
		this.scrollBarYFactory = value;
		this.setInvalid(INVALIDATION_FLAG_SCROLL_BAR_FACTORY);
		return this.scrollBarYFactory;
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
	public var scrollBarXPosition:RelativePosition = RelativePosition.BOTTOM;

	@:style
	public var scrollBarYPosition:RelativePosition = RelativePosition.RIGHT;

	private var _hideScrollBarX:SimpleActuator<Dynamic, Dynamic> = null;
	private var _hideScrollBarY:SimpleActuator<Dynamic, Dynamic> = null;

	@:style
	public var hideScrollBarDuration:Float = 0.2;

	@:style
	public var hideScrollBarEase:IEasing = Quart.easeOut;

	private var _currentScrollRect:Rectangle;
	private var _scrollRect1:Rectangle = new Rectangle();
	private var _scrollRect2:Rectangle = new Rectangle();

	override private function initialize():Void {
		if (this.scroller == null) {
			this.scroller = new Scroller();
		}
		this.scroller.target = cast(this.viewPort, InteractiveObject);
		this.scroller.addEventListener(Event.SCROLL, scroller_scrollHandler);
		this.scroller.addEventListener(FeathersEvent.SCROLL_START, scroller_scrollStartHandler);
		this.scroller.addEventListener(FeathersEvent.SCROLL_COMPLETE, scroller_scrollCompleteHandler);
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
		if (this.scrollBarX != null) {
			this.scrollBarX.removeEventListener(Event.CHANGE, scrollBarX_changeHandler);
			this.scrollBarX.removeEventListener(MouseEvent.ROLL_OVER, scrollBarX_rollOverHandler);
			this.scrollBarX.removeEventListener(MouseEvent.ROLL_OUT, scrollBarX_rollOutHandler);
			this.scrollBarX.removeEventListener(FeathersEvent.SCROLL_START, scrollBarX_scrollStartHandler);
			this.scrollBarX.removeEventListener(FeathersEvent.SCROLL_COMPLETE, scrollBarX_scrollCompleteHandler);
			this.removeChild(cast(this.scrollBarX, DisplayObject));
			this.scrollBarX = null;
		}
		if (this.scrollBarY != null) {
			this.scrollBarY.removeEventListener(Event.CHANGE, scrollBarY_changeHandler);
			this.scrollBarY.removeEventListener(MouseEvent.ROLL_OVER, scrollBarY_rollOverHandler);
			this.scrollBarY.removeEventListener(MouseEvent.ROLL_OUT, scrollBarY_rollOutHandler);
			this.scrollBarY.removeEventListener(FeathersEvent.SCROLL_START, scrollBarY_scrollStartHandler);
			this.scrollBarY.removeEventListener(FeathersEvent.SCROLL_COMPLETE, scrollBarY_scrollCompleteHandler);
			this.removeChild(cast(this.scrollBarY, DisplayObject));
			this.scrollBarY = null;
		}
		var scrollBarXFactory = this.scrollBarXFactory;
		if (scrollBarXFactory == null) {
			scrollBarXFactory = defaultScrollBarXFactory;
		}
		this.scrollBarX = scrollBarXFactory();
		if (this.autoHideScrollBars) {
			this.scrollBarX.alpha = 0.0;
		}
		this.scrollBarX.addEventListener(Event.CHANGE, scrollBarX_changeHandler);
		this.scrollBarX.addEventListener(MouseEvent.ROLL_OVER, scrollBarX_rollOverHandler);
		this.scrollBarX.addEventListener(MouseEvent.ROLL_OUT, scrollBarX_rollOutHandler);
		this.scrollBarX.addEventListener(FeathersEvent.SCROLL_START, scrollBarX_scrollStartHandler);
		this.scrollBarX.addEventListener(FeathersEvent.SCROLL_COMPLETE, scrollBarX_scrollCompleteHandler);
		this.addChild(cast(this.scrollBarX, DisplayObject));

		var scrollBarYFactory = this.scrollBarYFactory;
		if (scrollBarYFactory == null) {
			scrollBarYFactory = defaultScrollBarYFactory;
		}
		this.scrollBarY = scrollBarYFactory();
		if (this.autoHideScrollBars) {
			this.scrollBarY.alpha = 0.0;
		}
		this.scrollBarY.addEventListener(Event.CHANGE, scrollBarY_changeHandler);
		this.scrollBarY.addEventListener(MouseEvent.ROLL_OVER, scrollBarY_rollOverHandler);
		this.scrollBarY.addEventListener(MouseEvent.ROLL_OUT, scrollBarY_rollOutHandler);
		this.scrollBarY.addEventListener(FeathersEvent.SCROLL_START, scrollBarY_scrollStartHandler);
		this.scrollBarY.addEventListener(FeathersEvent.SCROLL_COMPLETE, scrollBarY_scrollCompleteHandler);
		this.addChild(cast(this.scrollBarY, DisplayObject));
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
		if (this.scrollBarX != null) {
			this.scrollBarX.minimum = this.scroller.minScrollX;
			this.scrollBarX.maximum = this.scroller.maxScrollX;
			this.scrollBarX.value = this.scroller.scrollX;
			this.scrollBarX.page = (this.scroller.maxScrollX - this.scroller.minScrollX) * this.viewPort.visibleWidth / this.viewPort.width;
			this.scrollBarX.step = 0.0;
			var displayScrollBarX = cast(this.scrollBarX, DisplayObjectContainer);
			displayScrollBarX.visible = (this.scrollPolicyX == ON && this.fixedScrollBars)
				|| (this.scrollPolicyX != OFF && this.scroller.minScrollX != this.scroller.maxScrollX);
		}
		if (this.scrollBarY != null) {
			this.scrollBarY.minimum = this.scroller.minScrollY;
			this.scrollBarY.maximum = this.scroller.maxScrollY;
			this.scrollBarY.value = this.scroller.scrollY;
			this.scrollBarY.page = (this.scroller.maxScrollY - this.scroller.minScrollY) * this.viewPort.visibleHeight / this.viewPort.height;
			this.scrollBarY.step = 0.0;
			var displayScrollBarY = cast(this.scrollBarY, DisplayObjectContainer);
			displayScrollBarY.visible = (this.scrollPolicyY == ON && this.fixedScrollBars)
				|| (this.scrollPolicyY != OFF && this.scroller.minScrollY != this.scroller.maxScrollY);
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

		if (this.scrollBarX != null && Std.is(this.scrollBarX, IValidating)) {
			cast(this.scrollBarX, IValidating).validateNow();
		}
		if (this.scrollBarY != null && Std.is(this.scrollBarY, IValidating)) {
			cast(this.scrollBarY, IValidating).validateNow();
		}

		if (this.scrollBarX != null) {
			switch (this.scrollBarXPosition) {
				case RelativePosition.TOP:
					this.scrollBarX.y = 0;
				default:
					this.scrollBarX.y = this.topViewPortOffset + visibleHeight;
			}
			this.scrollBarX.y -= this.scrollBarX.height;
			this.scrollBarX.x = this.leftViewPortOffset;
			this.scrollBarX.width = visibleWidth;
		}
		if (this.scrollBarY != null) {
			switch (this.scrollBarYPosition) {
				case RelativePosition.LEFT:
					this.scrollBarY.x = 0;
				default:
					this.scrollBarY.x = this.leftViewPortOffset + visibleWidth;
			}
			this.scrollBarY.x -= this.scrollBarY.width;
			this.scrollBarY.y = this.topViewPortOffset;
			this.scrollBarY.height = visibleHeight;
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

	private function revealScrollBarX():Void {
		if (this.scrollBarX == null || this.scroller.minScrollX == this.scroller.maxScrollX) {
			return;
		}
		if (this._hideScrollBarX != null) {
			Actuate.stop(this._hideScrollBarX);
		}
		this.scrollBarX.alpha = 1.0;
	}

	private function revealScrollBarY():Void {
		if (this.scrollBarY == null || this.scroller.minScrollY == this.scroller.maxScrollY) {
			return;
		}
		if (this._hideScrollBarY != null) {
			Actuate.stop(this._hideScrollBarY);
		}
		this.scrollBarY.alpha = 1.0;
	}

	private function hideScrollBarX():Void {
		if (this.scrollBarX == null || this._hideScrollBarX != null) {
			return;
		}
		if (this.scrollBarX.alpha == 0.0) {
			// already hidden
			return;
		}
		if (this.hideScrollBarDuration == 0.0) {
			this.scrollBarX.alpha = 0.0;
			return;
		}
		var tween = Actuate.tween(this.scrollBarX, this.hideScrollBarDuration, {alpha: 0.0});
		this._hideScrollBarX = cast(tween, SimpleActuator<Dynamic, Dynamic>);
		this._hideScrollBarX.ease(this.hideScrollBarEase);
		this._hideScrollBarX.autoVisible(false);
		this._hideScrollBarX.onComplete(this.hideScrollBarX_onComplete);
	}

	private function hideScrollBarY():Void {
		if (this.scrollBarY == null || this._hideScrollBarY != null) {
			return;
		}
		if (this.scrollBarY.alpha == 0.0) {
			// already hidden
			return;
		}
		if (this.hideScrollBarDuration == 0.0) {
			this.scrollBarY.alpha = 0.0;
			return;
		}
		var tween = Actuate.tween(this.scrollBarY, this.hideScrollBarDuration, {alpha: 0.0});
		this._hideScrollBarY = cast(tween, SimpleActuator<Dynamic, Dynamic>);
		this._hideScrollBarY.ease(this.hideScrollBarEase);
		this._hideScrollBarY.autoVisible(false);
		this._hideScrollBarY.onComplete(this.hideScrollBarY_onComplete);
	}

	private function checkForRevealScrollBars():Void {
		if (!this._scrollerDraggingX && this.scroller.draggingX) {
			this._scrollerDraggingX = true;
			this.revealScrollBarX();
		}
		if (!this._scrollerDraggingY && this.scroller.draggingY) {
			this._scrollerDraggingY = true;
			this.revealScrollBarY();
		}
	}

	private function scroller_scrollStartHandler(event:Event):Void {
		this._scrollerDraggingX = false;
		this._scrollerDraggingY = false;
		this.checkForRevealScrollBars();
	}

	private function scroller_scrollHandler(event:Event):Void {
		this.checkForRevealScrollBars();
		this.refreshScrollRect();
		this.refreshScrollBarValues();
	}

	private function scroller_scrollCompleteHandler(event:Event):Void {
		this._scrollerDraggingX = false;
		this._scrollerDraggingY = false;
		if (!this._scrollBarXHover && !this.fixedScrollBars && this.autoHideScrollBars) {
			this.hideScrollBarX();
		}
		if (!this._scrollBarYHover && !this.fixedScrollBars && this.autoHideScrollBars) {
			this.hideScrollBarY();
		}
	}

	private function scrollBarX_changeHandler(event:Event):Void {
		this.scroller.scrollX = this.scrollBarX.value;
	}

	private function scrollBarY_changeHandler(event:Event):Void {
		this.scroller.scrollY = this.scrollBarY.value;
	}

	private function scrollBarX_rollOverHandler(event:MouseEvent):Void {
		this._scrollBarXHover = true;
		this.revealScrollBarX();
	}

	private function scrollBarX_rollOutHandler(event:MouseEvent):Void {
		if (!this._scrollBarXHover) {
			return;
		}
		this._scrollBarXHover = false;
		if (!this._scrollerDraggingX && !this.fixedScrollBars && this.autoHideScrollBars) {
			this.hideScrollBarX();
		}
	}

	private function scrollBarY_rollOverHandler(event:MouseEvent):Void {
		this._scrollBarYHover = true;
		this.revealScrollBarY();
	}

	private function scrollBarY_rollOutHandler(event:MouseEvent):Void {
		if (!this._scrollBarYHover) {
			return;
		}
		this._scrollBarYHover = false;
		if (!this._scrollerDraggingY && !this.fixedScrollBars && this.autoHideScrollBars) {
			this.hideScrollBarY();
		}
	}

	private function scrollBarX_scrollStartHandler(event:FeathersEvent):Void {
		this.scroller.stop();
		this._scrollerDraggingX = true;
	}

	private function scrollBarX_scrollCompleteHandler(event:FeathersEvent):Void {
		this._scrollerDraggingX = false;
		if (!this._scrollBarXHover && !this.fixedScrollBars && this.autoHideScrollBars) {
			this.hideScrollBarX();
		}
	}

	private function scrollBarY_scrollStartHandler(event:FeathersEvent):Void {
		this.scroller.stop();
		this._scrollerDraggingY = true;
	}

	private function scrollBarY_scrollCompleteHandler(event:FeathersEvent):Void {
		this._scrollerDraggingY = false;
		if (!this._scrollBarYHover && !this.fixedScrollBars && this.autoHideScrollBars) {
			this.hideScrollBarY();
		}
	}

	private function hideScrollBarX_onComplete():Void {
		this._hideScrollBarX = null;
	}

	private function hideScrollBarY_onComplete():Void {
		this._hideScrollBarY = null;
	}
}

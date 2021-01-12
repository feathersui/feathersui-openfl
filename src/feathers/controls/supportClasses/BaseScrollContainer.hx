/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.supportClasses;

import openfl.events.TouchEvent;
import feathers.utils.ExclusivePointer;
import feathers.core.FeathersControl;
import feathers.core.IFocusObject;
import feathers.core.IMeasureObject;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.events.ScrollEvent;
import feathers.layout.Measurements;
import feathers.layout.RelativePosition;
import feathers.skins.IProgrammaticSkin;
import feathers.utils.MathUtil;
import feathers.utils.MeasurementsUtil;
import feathers.utils.Scroller;
import motion.Actuate;
import motion.actuators.SimpleActuator;
import motion.easing.IEasing;
import motion.easing.Quart;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.InteractiveObject;
import openfl.errors.IllegalOperationError;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;
import openfl.ui.Keyboard;

/**
	A base class for scrolling containers.

	@since 1.0.0
**/
@:event(feathers.events.ScrollEvent.SCROLL)
@:event(feathers.events.ScrollEvent.SCROLL_START)
@:event(feathers.events.ScrollEvent.SCROLL_COMPLETE)
class BaseScrollContainer extends FeathersControl implements IFocusObject {
	private static final INVALIDATION_FLAG_SCROLL_BAR_FACTORY = InvalidationFlag.CUSTOM("scrollBarFactory");

	private static function defaultScrollBarXFactory():IScrollBar {
		return new HScrollBar();
	}

	private static function defaultScrollBarYFactory():IScrollBar {
		return new VScrollBar();
	}

	private function new() {
		super();

		this.focusRect = null;

		this.addEventListener(KeyboardEvent.KEY_DOWN, baseScrollContainer_keyDownHandler);
		this.addEventListener(Event.ADDED_TO_STAGE, baseScrollContainer_addedToStageHandler);
		this.addEventListener(Event.REMOVED_FROM_STAGE, baseScrollContainer_removedFromStageHandler);
	}

	private var _viewPort:IViewPort;

	/**
		The display object rendered and scrolled within the container, provided
		by a subclass of `BaseScrollContainer`.

		@since 1.0.0
	**/
	@:dox(show)
	private var viewPort(get, set):IViewPort;

	private function get_viewPort():IViewPort {
		return this._viewPort;
	}

	private function set_viewPort(value:IViewPort):IViewPort {
		if (this._viewPort == value) {
			return this._viewPort;
		}
		if (this._viewPort != null) {
			this._viewPort.removeEventListener(Event.RESIZE, viewPort_resizeHandler);
		}
		if (this.scroller != null) {
			this.scroller.target = null;
		}
		this._viewPort = value;
		if (this.scroller != null && this.stage != null) {
			this.scroller.target = cast(this._viewPort, InteractiveObject);
		}
		if (this._viewPort != null) {
			this._viewPort.addEventListener(Event.RESIZE, viewPort_resizeHandler);
		}
		return this._viewPort;
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
	private var chromeMeasuredWidth:Float = 0.0;
	private var chromeMeasuredMinWidth:Float = 0.0;
	private var chromeMeasuredMaxWidth:Float = Math.POSITIVE_INFINITY;
	private var chromeMeasuredHeight:Float = 0.0;
	private var chromeMeasuredMinHeight:Float = 0.0;
	private var chromeMeasuredMaxHeight:Float = Math.POSITIVE_INFINITY;

	override private function get_focusEnabled():Bool {
		return (this.maxScrollY != this.minScrollY || this.maxScrollX != this.minScrollX) && super.focusEnabled;
	}

	/**
		The minimum space, in pixels, between the container's top edge and the
		container's content.

		In the following example, the container's top padding is set to 20
		pixels:

		```hx
		container.paddingTop = 20.0;
		```

		@since 1.0.0
	**/
	@:style
	public var paddingTop:Float = 0.0;

	/**
		The minimum space, in pixels, between the container's right edge and the
		container's content.

		In the following example, the container's right padding is set to 20
		pixels:

		```hx
		container.paddingRight = 20.0;
		```

		@since 1.0.0
	**/
	@:style
	public var paddingRight:Float = 0.0;

	/**
		The minimum space, in pixels, between the container's bottom edge and
		the container's content.

		In the following example, the container's bottom padding is set to 20
		pixels:

		```hx
		container.paddingBottom = 20.0;
		```

		@since 1.0.0
	**/
	@:style
	public var paddingBottom:Float = 0.0;

	/**
		The minimum space, in pixels, between the container's left edge and the
		container's content.

		In the following example, the container's left padding is set to 20
		pixels:

		```hx
		container.paddingLeft = 20.0;
		```

		@since 1.0.0
	**/
	@:style
	public var paddingLeft:Float = 0.0;

	/**
		The default background skin to display behind all content added to the
		group. The background skin is resized to fill the complete width and
		height of the group.

		The following example passes a bitmap for the container to use as a
		background skin:

		```hx
		group.backgroundSkin = new Bitmap(bitmapData);
		```

		@see `BaseScrollContainer.disabledBackgroundSkin`

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
		group.disabledBackgroundSkin = new Bitmap(bitmapData);
		group.enabled = false;
		```

		@see `BaseScrollContainer.backgroundSkin`

		@since 1.0.0
	**/
	@:style
	public var disabledBackgroundSkin:DisplayObject = null;

	private var scrollBarX:IScrollBar;
	private var scrollBarY:IScrollBar;

	private var _ignoreScrollBarXChange:Bool = false;
	private var _ignoreScrollBarYChange:Bool = false;

	/**
		Determines if the scroll bars are fixed to the edges of the container,
		without overlapping the container's content, or if the scroll bars are
		floating above the container's content.

		In the following example, the scroll bars are fixed:

		```hx
		container.fixedScrollBars = true;
		```

		This property has no effect if `showScrollBars` is `false`.

		@since 1.0.0
	**/
	@:style
	public var fixedScrollBars:Bool = false;

	/**
		Determines if scroll bars are displayed or not.

		In the following example, the scroll bars are hidden:

		```hx
		container.showScrollBars = false;
		```

		@since 1.0.0
	**/
	@:style
	public var showScrollBars:Bool = true;

	/**
		Determines if the scroll bars should be automatically hidden after
		scrolling has ended, whether it was through user interaction or
		animation.

		In the following example, scroll bar auto-hiding is disabled:

		```hx
		container.autoHideScrollBars = false;
		```

		This property has no effect if `fixedScrollBars` is `true`. Fixed scroll
		bars are always visible. Similarly, if `showScrollBars` is `false`, then
		the scroll bars are always hidden.

		@since 1.0.0
	**/
	@:style
	public var autoHideScrollBars:Bool = true;

	private var showScrollBarX = false;
	private var showScrollBarY = false;

	private var _scrollBarXFactory:() -> IScrollBar = defaultScrollBarXFactory;

	/**
		Creates the horizontal scroll bar. The horizontal scroll bar may be any
		implementation of `IScrollBar`, but typically, the
		`feathers.controls.HScrollBar` component is used.

		In the following example, a custom horizontal scroll bar factory is
		passed to the container:

		```hx
		scroller.scrollBarXFactory = () ->
		{
			return new HScrollBar();
		};
		```

		@see `feathers.controls.HScrollBar`

		@since 1.0.0
	**/
	@:flash.property
	public var scrollBarXFactory(get, set):() -> IScrollBar;

	private function get_scrollBarXFactory():() -> IScrollBar {
		return this._scrollBarXFactory;
	}

	private function set_scrollBarXFactory(value:() -> IScrollBar):() -> IScrollBar {
		if (this._scrollBarXFactory == value) {
			return this._scrollBarXFactory;
		}
		this._scrollBarXFactory = value;
		this.setInvalid(INVALIDATION_FLAG_SCROLL_BAR_FACTORY);
		return this._scrollBarXFactory;
	}

	private var _scrollBarYFactory:() -> IScrollBar = defaultScrollBarYFactory;

	/**
		Creates the vertical scroll bar. The vertical scroll bar may be any
		implementation of `IScrollBar`, but typically, the
		`feathers.controls.VScrollBar` component is used.

		In the following example, a custom vertical scroll bar factory is
		passed to the container:

		```hx
		scroller.scrollBarYFactory = () ->
		{
			return new VScrollBar();
		};
		```

		@see `feathers.controls.VScrollBar`

		@since 1.0.0
	**/
	@:flash.property
	public var scrollBarYFactory(get, set):() -> IScrollBar;

	private function get_scrollBarYFactory():() -> IScrollBar {
		return this._scrollBarYFactory;
	}

	private function set_scrollBarYFactory(value:() -> IScrollBar):() -> IScrollBar {
		if (this._scrollBarYFactory == value) {
			return this._scrollBarYFactory;
		}
		this._scrollBarYFactory = value;
		this.setInvalid(INVALIDATION_FLAG_SCROLL_BAR_FACTORY);
		return this._scrollBarYFactory;
	}

	private var _temporaryScrollX = 0.0;

	/**
		The number of pixels the container has been scrolled horizontally (on
		the x-axis).

		When the value of `scrollX` changes, the container dispatches an event
		of type `ScrollEvent.SCROLL`. This event is dispatched when other
		scroll position properties change too.

		In the following example, the horizontal scroll position is modified
		immediately, without being animated:

		```hx
		container.scrollX = 100.0;
		```

		@see `BaseScrollContainer.minScrollX`
		@see `BaseScrollContainer.maxScrollX`
		@see `feathers.events.ScrollEvent.SCROLL`

		@since 1.0.0
	**/
	@:flash.property
	public var scrollX(get, set):Float;

	private function get_scrollX():Float {
		if (this.scroller == null) {
			return this._temporaryScrollX;
		}
		return this.scroller.scrollX;
	}

	private function set_scrollX(value:Float):Float {
		if (this.scroller == null) {
			this._temporaryScrollX = value;
			return this._temporaryScrollX;
		}
		this.scroller.scrollX = value;
		return this.scroller.scrollX;
	}

	private var _temporaryScrollY = 0.0;

	/**
		The number of pixels the container has been scrolled vertically (on the
		y-axis).

		When the value of `scrollY` changes, the container dispatches an event
		of type `ScrollEvent.SCROLL`. This event is dispatched when other
		scroll position properties change too.

		In the following example, the vertical scroll position is modified
		immediately, without being animated:

		```hx
		container.scrollY = 100.0;
		```

		@see `BaseScrollContainer.minScrollY`
		@see `BaseScrollContainer.maxScrollY`
		@see `feathers.events.ScrollEvent.SCROLL`

		@since 1.0.0
	**/
	@:flash.property
	public var scrollY(get, set):Float;

	private function get_scrollY():Float {
		if (this.scroller == null) {
			return this._temporaryScrollY;
		}
		return this.scroller.scrollY;
	}

	private function set_scrollY(value:Float):Float {
		if (this.scroller == null) {
			this._temporaryScrollY = value;
			return this._temporaryScrollY;
		}
		this.scroller.scrollY = value;
		return this.scroller.scrollY;
	}

	/**
		The number of pixels the container may be scrolled horizontally in the
		leftward direction. This value is automatically calculated based on the
		bounds of the container's viewport.

		The `scrollX` property may have a lower value than the minimum if the
		`elasticEdges` property is enabled. However, once the user stops
		interacting with the container, it will automatically animate back to
		the minimum position.

		@see `BaseScrollContainer.scrollX`
		@see `BaseScrollContainer.maxScrollX`

		@since 1.0.0
	**/
	@:flash.property
	public var minScrollX(get, never):Float;

	private function get_minScrollX():Float {
		if (this.scroller == null) {
			return 0.0;
		}
		return this.scroller.minScrollX;
	}

	/**
		The number of pixels the container may be scrolled vertically in the
		upward direction. This value is automatically calculated based on the
		bounds of the container's viewport.

		The `scrollY` property may have a lower value than the minimum if the
		`elasticEdges` property is enabled. However, once the user stops
		interacting with the container, it will automatically animate back to
		the minimum position.

		@see `BaseScrollContainer.scrollY`
		@see `BaseScrollContainer.maxScrollY`

		@since 1.0.0
	**/
	@:flash.property
	public var minScrollY(get, never):Float;

	private function get_minScrollY():Float {
		if (this.scroller == null) {
			return 0.0;
		}
		return this.scroller.minScrollY;
	}

	/**
		The number of pixels the container may be scrolled horizontally in the
		rightward direction. This value is automatically calculated based on the
		bounds of the container's viewport.

		The `scrollX` property may have a higher value than the maximum if the
		`elasticEdges` property is enabled. However, once the user stops
		interacting with the container, it will automatically animate back to
		the maximum position.

		@see `BaseScrollContainer.scrollX`
		@see `BaseScrollContainer.maxScrollX`

		@since 1.0.0
	**/
	@:flash.property
	public var maxScrollX(get, never):Float;

	private function get_maxScrollX():Float {
		if (this.scroller == null) {
			return 0.0;
		}
		return this.scroller.maxScrollX;
	}

	/**
		The number of pixels the container may be scrolled vertically in the
		downward direction. This value is automatically calculated based on the
		bounds of the container's viewport.

		The `scrollY` property may have a higher value than the maximum if the
		`elasticEdges` property is enabled. However, once the user stops
		interacting with the container, it will automatically animate back to
		the maximum position.

		@see `BaseScrollContainer.scrollY`
		@see `BaseScrollContainer.minScrollY`

		@since 1.0.0
	**/
	@:flash.property
	public var maxScrollY(get, never):Float;

	private function get_maxScrollY():Float {
		if (this.scroller == null) {
			return 0.0;
		}
		return this.scroller.maxScrollY;
	}

	private var _scrollStepX:Float = 0.0;

	/**
		The number of pixels the horizontal scroll position can be adjusted by
		a step (such as with the left/right keyboard arrow keys, or a step
		button on the horizontal scroll bar).

		In the following example, the horizontal scroll step is set to 20 pixels:

		```hx
		container.scrollStepX = 20.0;
		```

		@since 1.0.0
	**/
	@:flash.property
	public var scrollStepX(get, set):Float;

	private function get_scrollStepX():Float {
		return this._scrollStepX;
	}

	private function set_scrollStepX(value:Float):Float {
		if (this._scrollStepX == value) {
			return this._scrollStepX;
		}
		this._scrollStepX = value;
		this.setInvalid(SCROLL);
		return this._scrollStepX;
	}

	private var _scrollStepY:Float = 0.0;

	/**
		The number of pixels the vertical scroll position can be adjusted by
		a step (such as with the up/down keyboard arrow keys, or a step button
		on the vertical scroll bar).

		In the following example, the vertical scroll step is set to 20 pixels:

		```hx
		container.scrollStepY = 20.0;
		```

		@since 1.0.0
	**/
	@:flash.property
	public var scrollStepY(get, set):Float;

	private function get_scrollStepY():Float {
		return this._scrollStepY;
	}

	private function set_scrollStepY(value:Float):Float {
		if (this._scrollStepY == value) {
			return this._scrollStepY;
		}
		this._scrollStepY = value;
		this.setInvalid(SCROLL);
		return this._scrollStepY;
	}

	private var _scrollPolicyX:ScrollPolicy = AUTO;

	/**
		Determines whether the container may scroll horizontally (on the x-axis)
		or not.

		In the following example, horizontal scrolling is disabled:

		```hx
		container.scrollPolicyX = OFF;
		```

		@see `BaseScrollContainer.scrollPolicyY`

		@since 1.0.0
	**/
	@:flash.property
	public var scrollPolicyX(get, set):ScrollPolicy;

	private function get_scrollPolicyX():ScrollPolicy {
		return this._scrollPolicyX;
	}

	private function set_scrollPolicyX(value:ScrollPolicy):ScrollPolicy {
		if (this._scrollPolicyX == value) {
			return this._scrollPolicyX;
		}
		this._scrollPolicyX = value;
		this.setInvalid(SCROLL);
		return this._scrollPolicyX;
	}

	private var _scrollPolicyY:ScrollPolicy = AUTO;

	/**
		Determines whether the container may scroll vertically (on the y-axis)
		or not.

		In the following example, vertical scrolling is disabled:

		```hx
		container.scrollPolicyY = OFF;
		```

		@see `BaseScrollContainer.scrollPolicyX`

		@since 1.0.0
	**/
	@:flash.property
	public var scrollPolicyY(get, set):ScrollPolicy;

	private function get_scrollPolicyY():ScrollPolicy {
		return this._scrollPolicyY;
	}

	private function set_scrollPolicyY(value:ScrollPolicy):ScrollPolicy {
		if (this._scrollPolicyY == value) {
			return this._scrollPolicyY;
		}
		this._scrollPolicyY = value;
		this.setInvalid(SCROLL);
		return this._scrollPolicyY;
	}

	/**
		When simulating touch, mouse events are treated as if they were mouse
		events instead, allowing the user to click and drag the container with
		momentum scrolling using the mouse instead of touch.

		Generally, this is intended for testing during development and should
		not be used in production.

		```hx
		container.simulateTouch = true;
		```

		@since 1.0.0
	**/
	@:style
	public var simulateTouch:Bool = false;

	/**
		Determines if the scrolling can go beyond the edges of the viewport when
		dragging with a touch.

		In the following example, elastic edges are disabled:

		```hx
		container.elasticEdges = false;
		```

		@since 1.0.0
	**/
	@:style
	public var elasticEdges:Bool = true;

	/**
		Determines the edge of the container where the horizontal scroll bar
		will be positioned (either on the top or the bottom).

		In the following example, the horizontal scroll bar is positioned on the
		top edge of the container:

		```hx
		container.scrollBarXPosition = TOP;
		```

		@see `feathers.layout.RelativePosition.BOTTOM`
		@see `feathers.layout.RelativePosition.TOP`

		@since 1.0.0
	**/
	@:style
	public var scrollBarXPosition:RelativePosition = BOTTOM;

	/**
		Determines the edge of the container where the vertical scroll bar
		will be positioned (either on the left or the right).

		In the following example, the vertical scroll bar is positioned on the
		left edge of the container:

		```hx
		container.scrollBarYPosition = LEFT;
		```

		@see `feathers.layout.RelativePosition.RIGHT`
		@see `feathers.layout.RelativePosition.LEFT`

		@since 1.0.0
	**/
	@:style
	public var scrollBarYPosition:RelativePosition = RIGHT;

	private var _hideScrollBarX:SimpleActuator<Dynamic, Dynamic> = null;
	private var _hideScrollBarY:SimpleActuator<Dynamic, Dynamic> = null;

	/**
		The duration, measured in seconds, of the animation when a scroll bar
		fades out.

		In the following example, the duration of the animation that hides the
		scroll bars is set to 500 milliseconds:

		```hx
		container.hideScrollBarDuration = 0.5;
		```

		@since 1.0.0
	**/
	@:style
	public var hideScrollBarDuration:Float = 0.2;

	/**
		The easing function used for hiding the scroll bars, if applicable.

		In the following example, the ease of the animation that hides the
		scroll bars is customized:

		```hx
		container.hideScrollBarEase = Elastic.easeOut;
		```

		@since 1.0.0
	**/
	@:style
	public var hideScrollBarEase:IEasing = Quart.easeOut;

	private var _currentScrollRect:Rectangle;
	private var _scrollRect1:Rectangle = new Rectangle();
	private var _scrollRect2:Rectangle = new Rectangle();

	private var _ignoreScrollerChanges = false;
	private var _viewPortBoundsChanged = false;
	private var _ignoreViewPortResizing = false;
	private var _previousViewPortWidth = 0.0;
	private var _previousViewPortHeight = 0.0;

	private var measureViewPort(get, never):Bool;

	private function get_measureViewPort():Bool {
		return true;
	}

	override private function initialize():Void {
		if (this.scroller == null) {
			this.scroller = new Scroller();
		}
		this.scroller.scrollX = this._temporaryScrollX;
		this.scroller.scrollY = this._temporaryScrollY;
		this.scroller.addEventListener(Event.SCROLL, baseScrollContainer_scroller_scrollHandler);
		this.scroller.addEventListener(ScrollEvent.SCROLL_START, baseScrollContainer_scroller_scrollStartHandler);
		this.scroller.addEventListener(ScrollEvent.SCROLL_COMPLETE, baseScrollContainer_scroller_scrollCompleteHandler);
	}

	override private function update():Void {
		var stylesInvalid = this.isInvalid(STYLES);
		var sizeInvalid = this.isInvalid(SIZE);
		var stateInvalid = this.isInvalid(STATE);
		var scrollBarFactoryInvalid = this.isInvalid(INVALIDATION_FLAG_SCROLL_BAR_FACTORY);

		var oldIgnoreScrollerChanges = this._ignoreScrollerChanges;
		this._ignoreScrollerChanges = true;

		if (stylesInvalid || stateInvalid) {
			this.refreshBackgroundSkin();
		}

		if (scrollBarFactoryInvalid) {
			this.createScrollBars();
		}

		this.refreshEnabled();
		this.refreshScrollerValues();

		this.refreshViewPort();

		this.refreshScrollRect();
		this.refreshScrollBarValues();
		this.layoutChildren();

		this._ignoreScrollerChanges = oldIgnoreScrollerChanges;
	}

	private function needsMeasurement():Bool {
		return (this.isInvalid(SCROLL) && this._viewPort.requiresMeasurementOnScroll)
			|| this.isInvalid(DATA)
			|| this.isInvalid(SIZE)
			|| this.isInvalid(STYLES)
			|| this.isInvalid(INVALIDATION_FLAG_SCROLL_BAR_FACTORY)
			|| this.isInvalid(STATE)
			|| this.isInvalid(LAYOUT);
	}

	private function createScrollBars():Void {
		if (this.scrollBarX != null) {
			this.scrollBarX.removeEventListener(Event.CHANGE, scrollBarX_changeHandler);
			this.scrollBarX.removeEventListener(MouseEvent.ROLL_OVER, scrollBarX_rollOverHandler);
			this.scrollBarX.removeEventListener(MouseEvent.ROLL_OUT, scrollBarX_rollOutHandler);
			this.scrollBarX.removeEventListener(ScrollEvent.SCROLL_START, scrollBarX_scrollStartHandler);
			this.scrollBarX.removeEventListener(ScrollEvent.SCROLL_COMPLETE, scrollBarX_scrollCompleteHandler);
			this.removeChild(cast(this.scrollBarX, DisplayObject));
			this.scrollBarX = null;
		}
		if (this.scrollBarY != null) {
			this.scrollBarY.removeEventListener(Event.CHANGE, scrollBarY_changeHandler);
			this.scrollBarY.removeEventListener(MouseEvent.ROLL_OVER, scrollBarY_rollOverHandler);
			this.scrollBarY.removeEventListener(MouseEvent.ROLL_OUT, scrollBarY_rollOutHandler);
			this.scrollBarY.removeEventListener(ScrollEvent.SCROLL_START, scrollBarY_scrollStartHandler);
			this.scrollBarY.removeEventListener(ScrollEvent.SCROLL_COMPLETE, scrollBarY_scrollCompleteHandler);
			this.removeChild(cast(this.scrollBarY, DisplayObject));
			this.scrollBarY = null;
		}
		var scrollBarXFactory = this._scrollBarXFactory;
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
		this.scrollBarX.addEventListener(ScrollEvent.SCROLL_START, scrollBarX_scrollStartHandler);
		this.scrollBarX.addEventListener(ScrollEvent.SCROLL_COMPLETE, scrollBarX_scrollCompleteHandler);
		this.addChild(cast(this.scrollBarX, DisplayObject));

		var scrollBarYFactory = this._scrollBarYFactory;
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
		this.scrollBarY.addEventListener(ScrollEvent.SCROLL_START, scrollBarY_scrollStartHandler);
		this.scrollBarY.addEventListener(ScrollEvent.SCROLL_COMPLETE, scrollBarY_scrollCompleteHandler);
		this.addChild(cast(this.scrollBarY, DisplayObject));
	}

	private function refreshEnabled():Void {
		this._viewPort.enabled = this._enabled;
		if (this.scrollBarX != null) {
			this.scrollBarX.enabled = this._enabled;
		}
		if (this.scrollBarY != null) {
			this.scrollBarY.enabled = this._enabled;
		}
	}

	private function refreshViewPort():Void {
		if (Std.is(this.scrollBarX, IValidating)) {
			cast(this.scrollBarX, IValidating).validateNow();
		}
		if (Std.is(this.scrollBarY, IValidating)) {
			cast(this.scrollBarY, IValidating).validateNow();
		}

		this._viewPort.scrollX = this.scrollX;
		this._viewPort.scrollY = this.scrollY;

		if (!this.needsMeasurement()) {
			this._viewPort.validateNow();
			this.scroller.setDimensions(this._viewPort.visibleWidth, this._viewPort.visibleHeight, this._viewPort.width, this._viewPort.height);
			return;
		}

		// it's possible that the view port's size from the previous update is
		// no longer appropriate for calculating offsets (example: when the
		// explicit size of the container is made smaller between updates).
		// when this happens, the container may display the scroll bars when
		// they're not actually required.
		// calling refreshViewPortBoundsForMeasurement() before the loop will
		// ensure that the view port size is initialized to a valid range.
		this.refreshViewPortBoundsForMeasurement();
		var loopCount = 0;
		do {
			this._viewPortBoundsChanged = false;
			// if we don't need to do any measurement, we can skip
			// this stuff and improve performance
			if (this.measureViewPort) {
				this.resetViewPortOffsets();
				this.calculateViewPortOffsets(true, false);
				this.refreshViewPortBoundsForMeasurement();
			}
			this.resetViewPortOffsets();
			this.calculateViewPortOffsets(false, false);

			this.measure();

			// just in case measure() is overridden, we need to call
			// this again and use actualWidth/Height instead of
			// explicitWidth/Height.
			this.resetViewPortOffsets();
			this.calculateViewPortOffsets(false, true);

			this.refreshViewPortBoundsForLayout();
			this.scroller.setDimensions(this._viewPort.visibleWidth, this._viewPort.visibleHeight, this._viewPort.width, this._viewPort.height);

			loopCount++;
			if (loopCount >= 10) {
				// if it still fails after ten tries, we've probably entered
				// an infinite loop. it could be things like rounding errors,
				// layout issues, or custom item renderers that don't measure
				// correctly
				throw new IllegalOperationError(Type.getClassName(Type.getClass(this))
					+
					" stuck in an infinite loop during measurement and validation. This may be an issue with the layout or children, such as custom item renderers.");
			}
		} while (this._viewPortBoundsChanged);

		this._previousViewPortWidth = this._viewPort.width;
		this._previousViewPortHeight = this._viewPort.height;
	}

	private function resetViewPortOffsets():Void {
		this.topViewPortOffset = 0.0;
		this.rightViewPortOffset = 0.0;
		this.bottomViewPortOffset = 0.0;
		this.leftViewPortOffset = 0.0;
		this.chromeMeasuredWidth = 0.0;
		this.chromeMeasuredMinWidth = 0.0;
		this.chromeMeasuredMaxWidth = Math.POSITIVE_INFINITY;
		this.chromeMeasuredHeight = 0.0;
		this.chromeMeasuredMinHeight = 0.0;
		this.chromeMeasuredMaxHeight = Math.POSITIVE_INFINITY;
	}

	private function calculateViewPortOffsets(forceScrollBars:Bool, useActualBounds:Bool):Void {
		// in fixed mode, if we determine that scrolling is required, we
		// remember the offsets for later. if scrolling is not needed, then
		// we will ignore the offsets from here forward
		this.calculateViewPortOffsetsForFixedScrollBarX(forceScrollBars && this.showScrollBars && this.scrollPolicyX != OFF, useActualBounds);
		this.calculateViewPortOffsetsForFixedScrollBarY(forceScrollBars && this.showScrollBars && this.scrollPolicyY != OFF, useActualBounds);
		// we need to double check the horizontal scroll bar if the scroll
		// bars are fixed because adding a vertical scroll bar may require a
		// horizontal one too.
		if (this.fixedScrollBars && this.showScrollBarY && !this.showScrollBarX) {
			this.calculateViewPortOffsetsForFixedScrollBarX(forceScrollBars && this.showScrollBars && this.scrollPolicyX != OFF, useActualBounds);
		}
	}

	private function calculateViewPortOffsetsForFixedScrollBarX(forceScrollBars:Bool, useActualBounds:Bool):Void {
		if (this.scrollBarX != null && (this.measureViewPort || useActualBounds)) {
			var availableWidth = useActualBounds ? this.actualWidth : this.explicitWidth;
			if (availableWidth != null) {
				availableWidth -= (this.paddingLeft + this.paddingRight + this.leftViewPortOffset + this.rightViewPortOffset);
				if (availableWidth < 0.0) {
					availableWidth = 0.0;
				}
			}
			if (!useActualBounds && !forceScrollBars && availableWidth == null) {
				// even if explicitWidth is null, the view port might measure
				// a view port width smaller than its content width
				availableWidth = this._viewPort.visibleWidth;
			}
			var maxAvailableWidth = this.explicitMaxWidth;
			if (maxAvailableWidth != null) {
				maxAvailableWidth -= (this.paddingLeft + this.paddingRight + this.leftViewPortOffset + this.rightViewPortOffset);
				if (maxAvailableWidth < 0.0) {
					maxAvailableWidth = 0.0;
				}
			}
			if (!this.showScrollBars) {
				this.showScrollBarX = false;
				return;
			}
			var totalContentWidth = this._viewPort.width;
			if (forceScrollBars
				|| this._scrollPolicyX == ON
				|| (((totalContentWidth > availableWidth && !MathUtil.fuzzyEquals(totalContentWidth, availableWidth))
					|| (maxAvailableWidth != null && totalContentWidth > maxAvailableWidth)
					&& !MathUtil.fuzzyEquals(totalContentWidth, maxAvailableWidth))
					&& this._scrollPolicyX != OFF)) {
				this.showScrollBarX = true;
				if (this.fixedScrollBars) {
					if (this.scrollBarXPosition == TOP) {
						this.topViewPortOffset += this.scrollBarX.height;
					} else {
						this.bottomViewPortOffset += this.scrollBarX.height;
					}
				}
			} else {
				this.showScrollBarX = false;
			}
		} else {
			this.showScrollBarX = false;
		}
	}

	private function calculateViewPortOffsetsForFixedScrollBarY(forceScrollBars:Bool, useActualBounds:Bool):Void {
		if (this.scrollBarY != null && (this.measureViewPort || useActualBounds)) {
			var availableHeight = useActualBounds ? this.actualHeight : this.explicitHeight;
			if (availableHeight != null) {
				availableHeight -= (this.paddingTop + this.paddingBottom + this.topViewPortOffset + this.bottomViewPortOffset);
				if (availableHeight < 0.0) {
					availableHeight = 0.0;
				}
			}
			if (!useActualBounds && !forceScrollBars && availableHeight == null) {
				// even if explicitHeight is null, the view port might measure
				// a view port height smaller than its content height
				availableHeight = this._viewPort.visibleHeight;
			}
			var maxAvailableHeight = this.explicitMaxHeight;
			if (maxAvailableHeight != null) {
				maxAvailableHeight -= (this.paddingTop + this.paddingBottom + this.topViewPortOffset + this.bottomViewPortOffset);
				if (maxAvailableHeight < 0.0) {
					maxAvailableHeight = 0.0;
				}
			}
			if (!this.showScrollBars) {
				this.showScrollBarY = false;
				return;
			}
			var totalContentHeight = this._viewPort.height;
			if (forceScrollBars
				|| this._scrollPolicyY == ON
				|| (((totalContentHeight > availableHeight && !MathUtil.fuzzyEquals(totalContentHeight, availableHeight))
					|| (maxAvailableHeight != null
						&& totalContentHeight > maxAvailableHeight
						&& !MathUtil.fuzzyEquals(totalContentHeight, maxAvailableHeight)))
					&& this._scrollPolicyY != OFF)) {
				this.showScrollBarY = true;
				if (this.fixedScrollBars) {
					if (this.scrollBarYPosition == LEFT) {
						this.leftViewPortOffset += this.scrollBarY.width;
					} else {
						this.rightViewPortOffset += this.scrollBarY.width;
					}
				}
			} else {
				this.showScrollBarY = false;
			}
		} else {
			this.showScrollBarY = false;
		}
	}

	private function refreshViewPortBoundsForMeasurement():Void {
		var oldIgnoreViewPortResizing = this._ignoreViewPortResizing;
		// setting some of the properties below may result in a resize
		// event, which forces another layout pass for the view port and
		// hurts performance (because it needs to break out of an
		// infinite loop)
		this._ignoreViewPortResizing = true;

		this._viewPort.x = this.paddingLeft + this.leftViewPortOffset;
		this._viewPort.y = this.paddingTop + this.topViewPortOffset;
		if (this.explicitWidth == null) {
			this._viewPort.visibleWidth = null;
		} else {
			var visibleWidth = this.explicitWidth - this.leftViewPortOffset - this.rightViewPortOffset - this.paddingLeft - this.paddingRight;
			if (visibleWidth < 0.0) {
				visibleWidth = 0.0;
			}
			this._viewPort.visibleWidth = visibleWidth;
		}
		if (this.explicitHeight == null) {
			this._viewPort.visibleHeight = null;
		} else {
			var visibleHeight = this.explicitHeight - this.topViewPortOffset - this.bottomViewPortOffset - this.paddingTop - this.paddingBottom;
			if (visibleHeight < 0.0) {
				visibleHeight = 0.0;
			}
			this._viewPort.visibleHeight = visibleHeight;
		}
		if (this.explicitMinWidth == null) {
			this._viewPort.minVisibleWidth = null;
		} else {
			var minVisibleWidth = this.explicitMinWidth - this.leftViewPortOffset - this.rightViewPortOffset - this.paddingLeft - this.paddingRight;
			if (minVisibleWidth < 0.0) {
				minVisibleWidth = 0.0;
			}
			this._viewPort.minVisibleWidth = minVisibleWidth;
		}
		if (this.explicitMinHeight == null) {
			this._viewPort.minVisibleHeight = null;
		} else {
			var minVisibleHeight = this.explicitMinHeight - this.topViewPortOffset - this.bottomViewPortOffset - this.paddingTop - this.paddingBottom;
			if (minVisibleHeight < 0.0) {
				minVisibleHeight = 0.0;
			}
			this._viewPort.minVisibleHeight = minVisibleHeight;
		}
		if (this.explicitMaxWidth == null) {
			this._viewPort.maxVisibleWidth = Math.POSITIVE_INFINITY;
		} else {
			var maxVisibleWidth = this.explicitMaxWidth - this.leftViewPortOffset - this.rightViewPortOffset - this.paddingLeft - this.paddingRight;
			if (maxVisibleWidth < 0.0) {
				maxVisibleWidth = 0.0;
			}
			this._viewPort.maxVisibleWidth = maxVisibleWidth;
		}
		if (this.explicitMaxHeight == null) {
			this._viewPort.maxVisibleHeight = Math.POSITIVE_INFINITY;
		} else {
			var maxVisibleHeight = this.explicitMaxHeight - this.topViewPortOffset - this.bottomViewPortOffset - this.paddingTop - this.paddingBottom;
			if (maxVisibleHeight < 0.0) {
				maxVisibleHeight = 0.0;
			}
			this._viewPort.maxVisibleHeight = maxVisibleHeight;
		}
		this._viewPort.validateNow();

		// we don't want to listen for a resize event from the view port
		// while it is validating this time. during the next validation is
		// where it matters if the view port resizes.
		this._ignoreViewPortResizing = oldIgnoreViewPortResizing;
	}

	private function refreshViewPortBoundsForLayout():Void {
		var oldIgnoreViewPortResizing = this._ignoreViewPortResizing;
		// setting some of the properties below may result in a resize
		// event, which forces another layout pass for the view port and
		// hurts performance (because it needs to break out of an
		// infinite loop)
		this._ignoreViewPortResizing = true;

		var visibleWidth = this.actualWidth - this.leftViewPortOffset - this.rightViewPortOffset - this.paddingLeft - this.paddingRight;
		if (visibleWidth < 0.0) {
			visibleWidth = 0.0;
		}
		var visibleHeight = this.actualHeight - this.topViewPortOffset - this.bottomViewPortOffset - this.paddingTop - this.paddingBottom;
		if (visibleHeight < 0.0) {
			visibleHeight = 0.0;
		}
		var minVisibleWidth = this.actualMinWidth - this.leftViewPortOffset - this.rightViewPortOffset - this.paddingLeft - this.paddingRight;
		if (minVisibleWidth < 0.0) {
			minVisibleWidth = 0.0;
		}
		var minVisibleHeight = this.actualMinHeight - this.topViewPortOffset - this.bottomViewPortOffset - this.paddingTop - this.paddingBottom;
		if (minVisibleHeight < 0.0) {
			minVisibleHeight = 0.0;
		}
		var maxVisibleWidth = this.actualMaxWidth - this.leftViewPortOffset - this.rightViewPortOffset - this.paddingLeft - this.paddingRight;
		if (maxVisibleWidth < 0.0) {
			maxVisibleWidth = 0.0;
		}
		var maxVisibleHeight = this.actualMaxHeight - this.topViewPortOffset - this.bottomViewPortOffset - this.paddingTop - this.paddingBottom;
		if (maxVisibleHeight < 0.0) {
			maxVisibleHeight = 0.0;
		}

		this._viewPort.x = this.paddingLeft + this.leftViewPortOffset;
		this._viewPort.y = this.paddingTop + this.topViewPortOffset;
		this._viewPort.visibleWidth = visibleWidth;
		this._viewPort.visibleHeight = visibleHeight;
		this._viewPort.minVisibleWidth = minVisibleWidth;
		this._viewPort.minVisibleHeight = minVisibleHeight;
		this._viewPort.maxVisibleWidth = maxVisibleWidth;
		this._viewPort.maxVisibleHeight = maxVisibleHeight;

		// this time, we care whether a resize event is dispatched while the
		// view port is validating because it means we'll need to try another
		// measurement pass. we restore the flag before calling validate().
		this._ignoreViewPortResizing = oldIgnoreViewPortResizing;

		this._viewPort.validateNow();
		this.scroller.setDimensions(this._viewPort.visibleWidth, this._viewPort.visibleHeight, this._viewPort.width, this._viewPort.height);
	}

	private function refreshScrollerValues():Void {
		this.scroller.enabledX = this._enabled && this._scrollPolicyX != OFF;
		this.scroller.enabledY = this._enabled && this._scrollPolicyY != OFF;
		this.scroller.elasticEdges = this.elasticEdges;
		this.scroller.simulateTouch = this.simulateTouch;
	}

	private function refreshScrollBarValues():Void {
		if (this.scrollBarX != null) {
			// ignore change events that we cause because it could affect how
			// elasticity works in the scroller
			var oldIgnoreScrollBarXChange = this._ignoreScrollBarXChange;
			this._ignoreScrollBarXChange = true;
			this.scrollBarX.minimum = this.scroller.minScrollX;
			this.scrollBarX.maximum = this.scroller.maxScrollX;
			this.scrollBarX.value = this.scroller.scrollX;
			this.scrollBarX.page = (this.scroller.maxScrollX - this.scroller.minScrollX) * this._viewPort.visibleWidth / this._viewPort.width;
			this.scrollBarX.step = this._scrollStepX;
			var displayScrollBarX = cast(this.scrollBarX, DisplayObjectContainer);
			displayScrollBarX.visible = this.showScrollBarX;
			if (this.fixedScrollBars || !this.autoHideScrollBars) {
				// if autoHideScrollBars was true before, the scroll bars may
				// have been hidden, and we need to show them again
				this.scrollBarX.alpha = 1.0;
			}
			this._ignoreScrollBarXChange = oldIgnoreScrollBarXChange;
		}
		if (this.scrollBarY != null) {
			// ignore change events that we cause because it could affect how
			// elasticity works in the scroller
			var oldIgnoreScrollBarYChange = this._ignoreScrollBarYChange;
			this._ignoreScrollBarYChange = true;
			this.scrollBarY.minimum = this.scroller.minScrollY;
			this.scrollBarY.maximum = this.scroller.maxScrollY;
			this.scrollBarY.value = this.scroller.scrollY;
			this.scrollBarY.page = (this.scroller.maxScrollY - this.scroller.minScrollY) * this._viewPort.visibleHeight / this._viewPort.height;
			this.scrollBarY.step = this._scrollStepY;
			var displayScrollBarY = cast(this.scrollBarY, DisplayObjectContainer);
			displayScrollBarY.visible = this.showScrollBarY;
			if (this.fixedScrollBars || !this.autoHideScrollBars) {
				// if autoHideScrollBars was true before, the scroll bars may
				// have been hidden, and we need to show them again
				this.scrollBarY.alpha = 1.0;
			}
			this._ignoreScrollBarYChange = oldIgnoreScrollBarYChange;
		}
	}

	private function measure():Bool {
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
			MeasurementsUtil.resetFluidlyWithParent(this._backgroundSkinMeasurements, this._currentBackgroundSkin, this);
		}

		var measureSkin:IMeasureObject = null;
		if (Std.is(this._currentBackgroundSkin, IMeasureObject)) {
			measureSkin = cast(this._currentBackgroundSkin, IMeasureObject);
		}

		if (Std.is(this._currentBackgroundSkin, IValidating)) {
			cast(this._currentBackgroundSkin, IValidating).validateNow();
		}

		var newWidth = this.explicitWidth;
		if (needsWidth) {
			if (this.measureViewPort) {
				newWidth = this._viewPort.visibleWidth;
			} else {
				newWidth = 0.0;
			}
			newWidth += this.leftViewPortOffset + this.rightViewPortOffset;
			newWidth = Math.max(newWidth, this.chromeMeasuredWidth);
			newWidth += this.paddingLeft + this.paddingRight;
			if (this._currentBackgroundSkin != null) {
				newWidth = Math.max(newWidth, this._currentBackgroundSkin.width);
			}
		}

		var newHeight = this.explicitHeight;
		if (needsHeight) {
			if (this.measureViewPort) {
				newHeight = this._viewPort.visibleHeight;
			} else {
				newHeight = 0.0;
			}
			newHeight += this.topViewPortOffset + this.bottomViewPortOffset;
			newHeight = Math.max(newHeight, this.chromeMeasuredHeight);
			newHeight += this.paddingTop + this.paddingBottom;
			if (this._currentBackgroundSkin != null) {
				newHeight = Math.max(newHeight, this._currentBackgroundSkin.height);
			}
		}

		var newMinWidth = this.explicitMinWidth;
		if (needsMinWidth) {
			if (this.measureViewPort) {
				newMinWidth = this._viewPort.minVisibleWidth;
			} else {
				newMinWidth = 0.0;
			}
			newMinWidth += this.leftViewPortOffset + this.rightViewPortOffset;
			newMinWidth = Math.max(newMinWidth, this.chromeMeasuredMinWidth);
			newMinWidth += this.paddingLeft + this.paddingRight;
			if (measureSkin != null) {
				newMinWidth = Math.max(newMinWidth, measureSkin.minWidth);
			} else if (this._backgroundSkinMeasurements != null) {
				newMinWidth = Math.max(newMinWidth, this._backgroundSkinMeasurements.minWidth);
			}
		}

		var newMinHeight = this.explicitMinHeight;
		if (needsMinHeight) {
			if (this.measureViewPort) {
				newMinHeight = this._viewPort.minVisibleHeight;
			} else {
				newMinHeight = 0.0;
			}
			newMinHeight += this.topViewPortOffset + this.bottomViewPortOffset;
			newMinHeight = Math.max(newMinHeight, this.chromeMeasuredMinHeight);
			newMinHeight += this.paddingTop + this.paddingBottom;
			if (measureSkin != null) {
				newMinHeight = Math.max(newMinHeight, measureSkin.minHeight);
			} else if (this._backgroundSkinMeasurements != null) {
				newMinHeight = Math.max(newMinHeight, this._backgroundSkinMeasurements.minHeight);
			}
		}
		var newMaxWidth = this.explicitMaxWidth;
		if (needsMaxWidth) {
			if (this.measureViewPort) {
				newMaxWidth = this._viewPort.maxVisibleWidth;
			} else {
				newMaxWidth = Math.POSITIVE_INFINITY;
			}
			newMaxWidth += this.leftViewPortOffset + this.rightViewPortOffset;
			newMaxWidth = Math.min(newMaxWidth, this.chromeMeasuredMaxWidth);
			newMaxWidth += this.paddingLeft + this.paddingRight;
			if (measureSkin != null) {
				newMaxWidth = Math.min(newMaxWidth, measureSkin.maxWidth);
			} else if (this._backgroundSkinMeasurements != null) {
				newMaxWidth = Math.min(newMaxWidth, this._backgroundSkinMeasurements.maxWidth);
			}
		}

		var newMaxHeight = this.explicitMaxHeight;
		if (needsMaxHeight) {
			if (this.measureViewPort) {
				newMaxHeight = this._viewPort.maxVisibleHeight;
			} else {
				newMaxHeight = Math.POSITIVE_INFINITY;
			}
			newMaxHeight += this.topViewPortOffset + this.bottomViewPortOffset;
			newMaxHeight = Math.min(newMaxHeight, this.chromeMeasuredMaxHeight);
			newMaxHeight += this.paddingTop + this.paddingBottom;
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
		if (Std.is(this._currentBackgroundSkin, IProgrammaticSkin)) {
			cast(this._currentBackgroundSkin, IProgrammaticSkin).uiContext = this;
		}
		this.addChildAt(this._currentBackgroundSkin, 0);
	}

	private function getCurrentBackgroundSkin():DisplayObject {
		if (!this._enabled && this.disabledBackgroundSkin != null) {
			return this.disabledBackgroundSkin;
		}
		return this.backgroundSkin;
	}

	private function removeCurrentBackgroundSkin(skin:DisplayObject):Void {
		if (skin == null) {
			return;
		}
		if (Std.is(skin, IProgrammaticSkin)) {
			cast(skin, IProgrammaticSkin).uiContext = null;
		}
		// we need to restore these values so that they won't be lost the
		// next time that this skin is used for measurement
		this._backgroundSkinMeasurements.restore(skin);
		if (skin.parent == this) {
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
		var visibleWidth = this.actualWidth - this.leftViewPortOffset - this.rightViewPortOffset - this.paddingLeft - this.paddingRight;
		if (visibleWidth < 0.0) {
			visibleWidth = 0.0;
		}
		var visibleHeight = this.actualHeight - this.topViewPortOffset - this.bottomViewPortOffset - this.paddingTop - this.paddingBottom;
		if (visibleHeight < 0.0) {
			visibleHeight = 0.0;
		}

		if (this.scrollBarX != null && Std.is(this.scrollBarX, IValidating)) {
			cast(this.scrollBarX, IValidating).validateNow();
		}
		if (this.scrollBarY != null && Std.is(this.scrollBarY, IValidating)) {
			cast(this.scrollBarY, IValidating).validateNow();
		}

		if (this.scrollBarX != null) {
			switch (this.scrollBarXPosition) {
				case TOP:
					this.scrollBarX.y = this.paddingTop;
				default:
					this.scrollBarX.y = this.paddingTop + this.topViewPortOffset + visibleHeight;
			}
			this.scrollBarX.x = this.paddingLeft + this.leftViewPortOffset;
			if (!this.fixedScrollBars) {
				this.scrollBarX.y -= this.scrollBarX.height;
				if ((this.showScrollBarY || this._hideScrollBarY != null) && this.scrollBarY != null) {
					var scrollBarXWidth = visibleWidth - this.scrollBarY.width;
					if (scrollBarXWidth < 0.0) {
						scrollBarXWidth = 0.0;
					}
					this.scrollBarX.width = scrollBarXWidth;
				} else {
					this.scrollBarX.width = visibleWidth;
				}
			} else {
				this.scrollBarX.width = visibleWidth;
			}
		}
		if (this.scrollBarY != null) {
			switch (this.scrollBarYPosition) {
				case LEFT:
					this.scrollBarY.x = this.paddingLeft;
				default:
					this.scrollBarY.x = this.paddingLeft + this.leftViewPortOffset + visibleWidth;
			}
			this.scrollBarY.y = this.paddingTop + this.topViewPortOffset;
			if (!this.fixedScrollBars) {
				this.scrollBarY.x -= this.scrollBarY.width;
				if ((this.showScrollBarX || this._hideScrollBarX != null) && this.scrollBarX != null) {
					var scrollBarYHeight = visibleHeight - this.scrollBarX.height;
					if (scrollBarYHeight < 0.0) {
						scrollBarYHeight = 0.0;
					}
					this.scrollBarY.height = scrollBarYHeight;
				} else {
					this.scrollBarY.height = visibleHeight;
				}
			} else {
				this.scrollBarY.height = visibleHeight;
			}
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
		var scrollRectWidth = this.actualWidth - this.leftViewPortOffset - this.rightViewPortOffset - this.paddingLeft - this.paddingRight;
		if (scrollRectWidth < 0.0) {
			scrollRectWidth = 0.0;
		}
		var scrollRectHeight = this.actualHeight - this.topViewPortOffset - this.bottomViewPortOffset - this.paddingTop - this.paddingBottom;
		if (scrollRectHeight < 0.0) {
			scrollRectHeight = 0.0;
		}
		scrollRect.setTo(scroller.scrollX, scroller.scrollY, scrollRectWidth, scrollRectHeight);
		var displayViewPort = cast(this._viewPort, DisplayObject);
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
		var tween = Actuate.update((alpha:Float) -> {
			this.scrollBarX.alpha = alpha;
		}, this.hideScrollBarDuration, [this.scrollBarX.alpha], [0.0], true);
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
		var tween = Actuate.update((alpha:Float) -> {
			this.scrollBarY.alpha = alpha;
		}, this.hideScrollBarDuration, [this.scrollBarY.alpha], [0.0], true);
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

	private function scrollWithKeyboard(event:KeyboardEvent):Void {
		if (this._scrollPolicyY == OFF && this._scrollPolicyX == OFF) {
			return;
		}

		var stepX = this._scrollStepX;
		if (stepX <= 0.0) {
			stepX = 1.0;
		}
		var stepY = this._scrollStepY;
		if (stepY <= 0.0) {
			stepY = 1.0;
		}
		var newScrollX = this.scrollX;
		var newScrollY = this.scrollY;
		switch (event.keyCode) {
			case Keyboard.UP:
				newScrollY = this.scrollY - stepY;
			case Keyboard.DOWN:
				newScrollY = this.scrollY + stepY;
			case Keyboard.LEFT:
				newScrollX = this.scrollX - stepX;
			case Keyboard.RIGHT:
				newScrollX = this.scrollX + stepX;
			case Keyboard.PAGE_UP:
				newScrollY = this.scrollY - this._viewPort.visibleHeight;
			case Keyboard.PAGE_DOWN:
				newScrollY = this.scrollY + this._viewPort.visibleHeight;
			case Keyboard.HOME:
				newScrollY = this.minScrollY;
			case Keyboard.END:
				newScrollY = this.maxScrollY;
			default:
				// not keyboard scrolling
				return;
		}
		if (newScrollY < this.minScrollY) {
			newScrollY = this.minScrollY;
		} else if (newScrollY > this.maxScrollY) {
			newScrollY = this.maxScrollY;
		}
		if (newScrollX < this.minScrollX) {
			newScrollX = this.minScrollX;
		} else if (newScrollX > this.maxScrollX) {
			newScrollX = this.maxScrollX;
		}

		event.stopPropagation();
		if (this.scrollY != newScrollY && this._scrollPolicyY != OFF) {
			this.scrollY = newScrollY;
		}
		if (this.scrollX != newScrollX && this._scrollPolicyX != OFF) {
			this.scrollX = newScrollX;
		}
	}

	private function baseScrollContainer_addedToStageHandler(event:Event):Void {
		this.scroller.target = cast(this._viewPort, InteractiveObject);
	}

	private function baseScrollContainer_removedFromStageHandler(event:Event):Void {
		this.scroller.target = null;
	}

	private function baseScrollContainer_keyDownHandler(event:KeyboardEvent):Void {
		if (!this._enabled || event.isDefaultPrevented()) {
			return;
		}

		this.scrollWithKeyboard(event);
	}

	private function baseScrollContainer_scroller_scrollStartHandler(event:ScrollEvent):Void {
		var pointerID = this.scroller.pointerID;
		if (pointerID != -1) {
			var exclusivePointer = ExclusivePointer.forStage(this.stage);
			var result = exclusivePointer.claimPointer(pointerID, this);
			if (!result) {
				this.scroller.stop();
				return;
			}
			this._viewPort.addEventListener(MouseEvent.MOUSE_DOWN, baseScrollContainer_viewPort_mouseDownHandler);
			this._viewPort.addEventListener(TouchEvent.TOUCH_BEGIN, baseScrollContainer_viewPort_touchBeginHandler);
		}
		this._scrollerDraggingX = false;
		this._scrollerDraggingY = false;
		this.checkForRevealScrollBars();
		ScrollEvent.dispatch(this, ScrollEvent.SCROLL_START);
	}

	private function baseScrollContainer_scroller_scrollHandler(event:Event):Void {
		if (this._ignoreScrollerChanges) {
			return;
		}
		this.checkForRevealScrollBars();
		if (this._viewPort.requiresMeasurementOnScroll) {
			this.setInvalid(SCROLL);
		} else {
			this.refreshScrollRect();
			this.refreshScrollBarValues();
		}
		ScrollEvent.dispatch(this, ScrollEvent.SCROLL);
	}

	private function baseScrollContainer_scroller_scrollCompleteHandler(event:ScrollEvent):Void {
		this._viewPort.removeEventListener(MouseEvent.MOUSE_DOWN, baseScrollContainer_viewPort_mouseDownHandler);
		this._viewPort.removeEventListener(TouchEvent.TOUCH_BEGIN, baseScrollContainer_viewPort_touchBeginHandler);
		this._scrollerDraggingX = false;
		this._scrollerDraggingY = false;
		if (!this._scrollBarXHover && !this.fixedScrollBars && this.autoHideScrollBars) {
			this.hideScrollBarX();
		}
		if (!this._scrollBarYHover && !this.fixedScrollBars && this.autoHideScrollBars) {
			this.hideScrollBarY();
		}
		ScrollEvent.dispatch(this, ScrollEvent.SCROLL_COMPLETE);
	}

	private function reclaimPointer(pointerID:Int):Void {
		if (this.scroller.pointerID != pointerID) {
			return;
		}
		if (pointerID == -1) {
			return;
		}
		var exclusivePointer = ExclusivePointer.forStage(this.stage);
		var claim = exclusivePointer.getClaim(pointerID);
		if (claim != null) {
			return;
		}
		exclusivePointer.claimPointer(pointerID, this);
	}

	private function baseScrollContainer_viewPort_mouseDownHandler(event:MouseEvent):Void {
		this.reclaimPointer(Scroller.POINTER_ID_MOUSE);
	}

	private function baseScrollContainer_viewPort_touchBeginHandler(event:TouchEvent):Void {
		this.reclaimPointer(event.touchPointID);
	}

	private function scrollBarX_changeHandler(event:Event):Void {
		if (this._ignoreScrollBarXChange) {
			return;
		}
		this.scroller.scrollX = this.scrollBarX.value;
	}

	private function scrollBarY_changeHandler(event:Event):Void {
		if (this._ignoreScrollBarYChange) {
			return;
		}
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

	private function scrollBarX_scrollStartHandler(event:ScrollEvent):Void {
		this.scroller.stop();
		this._scrollerDraggingX = true;
		ScrollEvent.dispatch(this, ScrollEvent.SCROLL_START);
	}

	private function scrollBarX_scrollCompleteHandler(event:ScrollEvent):Void {
		this._scrollerDraggingX = false;
		if (!this._scrollBarXHover && !this.fixedScrollBars && this.autoHideScrollBars) {
			this.hideScrollBarX();
		}
		ScrollEvent.dispatch(this, ScrollEvent.SCROLL_COMPLETE);
	}

	private function scrollBarY_scrollStartHandler(event:ScrollEvent):Void {
		this.scroller.stop();
		this._scrollerDraggingY = true;
		ScrollEvent.dispatch(this, ScrollEvent.SCROLL_START);
	}

	private function scrollBarY_scrollCompleteHandler(event:ScrollEvent):Void {
		this._scrollerDraggingY = false;
		if (!this._scrollBarYHover && !this.fixedScrollBars && this.autoHideScrollBars) {
			this.hideScrollBarY();
		}
		ScrollEvent.dispatch(this, ScrollEvent.SCROLL_COMPLETE);
	}

	private function hideScrollBarX_onComplete():Void {
		this._hideScrollBarX = null;
	}

	private function hideScrollBarY_onComplete():Void {
		this._hideScrollBarY = null;
	}

	private function viewPort_resizeHandler(event:Event):Void {
		// using fuzzy comparison here because floating point errors can creep
		// in and cause an infinite loop
		if (this._ignoreViewPortResizing
			|| (MathUtil.fuzzyEquals(this._viewPort.width, this._previousViewPortWidth)
				&& MathUtil.fuzzyEquals(this._viewPort.height, this._previousViewPortHeight))) {
			return;
		}
		this._previousViewPortWidth = this._viewPort.width;
		this._previousViewPortHeight = this._viewPort.height;
		if (this._validating) {
			this._viewPortBoundsChanged = true;
		} else {
			this.setInvalid(SIZE);
		}
	}
}

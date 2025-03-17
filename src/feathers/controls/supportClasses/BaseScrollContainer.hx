/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.supportClasses;

import feathers.core.FeathersControl;
import feathers.core.IFocusObject;
import feathers.core.IMeasureObject;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.core.InvalidationFlag;
import feathers.events.ScrollEvent;
import feathers.layout.Measurements;
import feathers.layout.RelativePosition;
import feathers.skins.IProgrammaticSkin;
import feathers.skins.RectangleSkin;
import feathers.utils.AbstractDisplayObjectFactory;
import feathers.utils.DisplayObjectFactory;
import feathers.utils.DisplayUtil;
import feathers.utils.ExclusivePointer;
import feathers.utils.MathUtil;
import feathers.utils.MeasurementsUtil;
import feathers.utils.Scroller;
import motion.Actuate;
import motion.actuators.SimpleActuator;
import motion.easing.IEasing;
import motion.easing.Quart;
import openfl.Lib;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.InteractiveObject;
import openfl.errors.ArgumentError;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
import openfl.geom.Rectangle;
import openfl.text.TextField;
import openfl.ui.Keyboard;

/**
	A base class for scrolling containers.

	@event feathers.events.ScrollEvent.SCROLL Dispatched when the scroll
	position changes, or when the minimum or maximum scroll positions change.

	@event feathers.events.ScrollEvent.SCROLL_START Dispatched when scrolling
	begins.

	@event feathers.events.ScrollEvent.SCROLL_COMPLETE Dispatched when scrolling
	ends.

	@since 1.0.0
**/
@:event(feathers.events.ScrollEvent.SCROLL)
@:event(feathers.events.ScrollEvent.SCROLL_START)
@:event(feathers.events.ScrollEvent.SCROLL_COMPLETE)
class BaseScrollContainer extends FeathersControl implements IFocusObject {
	private static final INVALIDATION_FLAG_SCROLLER_FACTORY = InvalidationFlag.CUSTOM("scrollerFactory");
	private static final INVALIDATION_FLAG_SCROLL_BAR_FACTORY = InvalidationFlag.CUSTOM("scrollBarFactory");

	private static final defaultScrollBarXFactory = DisplayObjectFactory.withClass(HScrollBar);
	private static final defaultScrollBarYFactory = DisplayObjectFactory.withClass(VScrollBar);

	private function new() {
		super();

		this.tabEnabled = true;
		this.tabChildren = true;
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
		if (this._viewPort != null) {
			this._viewPort.addEventListener(Event.RESIZE, viewPort_resizeHandler);
		}
		this.setInvalid(SCROLL);
		return this._viewPort;
	}

	private var scroller:Scroller;

	private var _scrollerDraggingX = false;
	private var _scrollerDraggingY = false;
	private var _scrollBarXHover = false;
	private var _scrollBarYHover = false;

	private var _currentBackgroundSkin:DisplayObject = null;
	private var _backgroundSkinMeasurements:Measurements = null;

	private var _currentMaskSkin:DisplayObject = null;
	private var _currentViewPortMaskSkin:DisplayObject = null;
	private var _fallbackViewPortMaskSkin:DisplayObject = null;

	private var topViewPortOffset:Float = 0.0;
	private var rightViewPortOffset:Float = 0.0;
	private var bottomViewPortOffset:Float = 0.0;
	private var leftViewPortOffset:Float = 0.0;
	private var chromeMeasuredWidth:Float = 0.0;
	private var chromeMeasuredMinWidth:Float = 0.0;
	private var chromeMeasuredMaxWidth:Float = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround for swf
	private var chromeMeasuredHeight:Float = 0.0;
	private var chromeMeasuredMinHeight:Float = 0.0;
	private var chromeMeasuredMaxHeight:Float = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround for swf

	#if (flash && haxe_ver < 4.3) @:getter(tabEnabled) #end
	override private function get_tabEnabled():Bool {
		return (this.maxScrollY != this.minScrollY || this.maxScrollX != this.minScrollX) && this.rawTabEnabled;
	}

	/**
		The minimum space, in pixels, between the container's top edge and the
		container's content.

		In the following example, the container's top padding is set to 20
		pixels:

		```haxe
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

		```haxe
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

		```haxe
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

		```haxe
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

		```haxe
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

		```haxe
		group.disabledBackgroundSkin = new Bitmap(bitmapData);
		group.enabled = false;
		```

		@see `BaseScrollContainer.backgroundSkin`

		@since 1.0.0
	**/
	@:style
	public var disabledBackgroundSkin:DisplayObject = null;

	/**
		A skin to mask the content of the container. The skin is resized to
		the full dimensions of the container. It is passed to the `mask`
		property.

		This property masks the entire container, including any chrome such as
		scroll bars or headers and footers. To mask only the scrollable region,
		use `viewPortMaskSkin` instead.

		The following example passes a `RectangleSkin` with a `cornerRadius` for
		the container's mask skin:

		```haxe
		var maskSkin = new RectangleSkin();
		maskSkin.fill = SolidColor(0xff0000);
		maskSkin.cornerRadius = 10.0;
		container.maskSkin = maskSkin;
		```

		@default null

		@see [`openfl.display.DisplayObject.mask`](https://api.openfl.org/openfl/display/DisplayObject.html#mask)
		@see `BaseScrollContainer.viewPortMaskSkin`

		@since 1.0.0
	**/
	@:style
	public var maskSkin:DisplayObject = null;

	/**
		A skin to mask the view port (the scrollable region) of the container.
		The skin is resized to the dimensions of the view port only, and it does
		not affect any other chrome, such as scroll bars or a header or footer.
		It is passed to the `mask` property.

		The following example passes a `RectangleSkin` with a `cornerRadius` for
		the container view port's mask skin:

		```haxe
		var maskSkin = new RectangleSkin();
		maskSkin.fill = SolidColor(0xff0000);
		maskSkin.cornerRadius = 10.0;
		container.viewPortMaskSkin = maskSkin;
		```

		@default null

		@see [`openfl.display.DisplayObject.mask`](https://api.openfl.org/openfl/display/DisplayObject.html#mask)
		@see `BaseScrollContainer.maskSkin`

		@since 1.0.0
	**/
	@:style
	public var viewPortMaskSkin:DisplayObject = null;

	private var _currentScrollBarsCornerSkin:DisplayObject;

	/**
		An optional skin to display between the scroll bars, when both are
		visible. Appears in the bottom right corner when `scrollBarYPosition` is
		`RIGHT`, and the bottom left corner when `scrollBarYPosition` is `LEFT`.

		The following example passes a bitmap for the container to use as a
		background skin:

		```haxe
		group.scrollBarsCornerSkin = new Bitmap(bitmapData);
		```

		@see `BaseScrollContainer.scrollBarYPosition`

		@since 1.3.0
	**/
	@:style
	public var scrollBarsCornerSkin:DisplayObject = null;

	private var scrollBarX:IScrollBar;
	private var scrollBarY:IScrollBar;

	private var _ignoreScrollBarXChange:Bool = false;
	private var _ignoreScrollBarYChange:Bool = false;

	/**
		Determines if the scroll bars are fixed to the edges of the container,
		without overlapping the container's content, or if the scroll bars are
		floating above the container's content.

		In the following example, the scroll bars are fixed:

		```haxe
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

		```haxe
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

		```haxe
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

	private var _oldScrollBarXFactory:DisplayObjectFactory<Dynamic, HScrollBar>;

	private var _scrollBarXFactory:DisplayObjectFactory<Dynamic, HScrollBar>;

	/**
		Creates the horizontal scroll bar. The horizontal scroll bar may be any
		implementation of `IScrollBar`, but typically, the
		`feathers.controls.HScrollBar` component is used.

		In the following example, a custom horizontal scroll bar factory is
		passed to the container:

		```haxe
		container.scrollBarXFactory = () ->
		{
			return new HScrollBar();
		};
		```

		@see `feathers.controls.HScrollBar`

		@since 1.0.0
	**/
	public var scrollBarXFactory(get, set):AbstractDisplayObjectFactory<Dynamic, HScrollBar>;

	private function get_scrollBarXFactory():AbstractDisplayObjectFactory<Dynamic, HScrollBar> {
		return this._scrollBarXFactory;
	}

	private function set_scrollBarXFactory(value:AbstractDisplayObjectFactory<Dynamic, HScrollBar>):AbstractDisplayObjectFactory<Dynamic, HScrollBar> {
		if (this._scrollBarXFactory == value) {
			return this._scrollBarXFactory;
		}
		this._scrollBarXFactory = value;
		this.setInvalid(INVALIDATION_FLAG_SCROLL_BAR_FACTORY);
		return this._scrollBarXFactory;
	}

	private var _oldScrollBarYFactory:DisplayObjectFactory<Dynamic, VScrollBar>;

	private var _scrollBarYFactory:DisplayObjectFactory<Dynamic, VScrollBar>;

	/**
		Creates the vertical scroll bar. The vertical scroll bar may be any
		implementation of `IScrollBar`, but typically, the
		`feathers.controls.VScrollBar` component is used.

		In the following example, a custom vertical scroll bar factory is
		passed to the container:

		```haxe
		container.scrollBarYFactory = () ->
		{
			return new VScrollBar();
		};
		```

		@see `feathers.controls.VScrollBar`

		@since 1.0.0
	**/
	public var scrollBarYFactory(get, set):AbstractDisplayObjectFactory<Dynamic, VScrollBar>;

	private function get_scrollBarYFactory():AbstractDisplayObjectFactory<Dynamic, VScrollBar> {
		return this._scrollBarYFactory;
	}

	private function set_scrollBarYFactory(value:AbstractDisplayObjectFactory<Dynamic, VScrollBar>):AbstractDisplayObjectFactory<Dynamic, VScrollBar> {
		if (this._scrollBarYFactory == value) {
			return this._scrollBarYFactory;
		}
		this._scrollBarYFactory = value;
		this.setInvalid(INVALIDATION_FLAG_SCROLL_BAR_FACTORY);
		return this._scrollBarYFactory;
	}

	private var _scrollerFactory:() -> Scroller;

	/**
		Creates the `Scroller` utility that manages touch and mouse wheel
		scrolling.

		In the following example, a custom scroller factory is passed to the
		container:

		```haxe
		container.scrollerFactory = () ->
		{
			var scroller = new Scroller();
			scroller.elasticEdges = false;
			return scroller;
		};
		```

		@since 1.0.0
	**/
	public var scrollerFactory(get, set):() -> Scroller;

	private function get_scrollerFactory():() -> Scroller {
		return this._scrollerFactory;
	}

	private function set_scrollerFactory(value:() -> Scroller):() -> Scroller {
		if (this._scrollerFactory == value) {
			return this._scrollerFactory;
		}
		this._scrollerFactory = value;
		this.setInvalid(INVALIDATION_FLAG_SCROLLER_FACTORY);
		return this._scrollerFactory;
	}

	private var _temporaryScrollX:Null<Float> = null;
	private var _temporaryRestrictedScrollX:Null<Float> = null;

	/**
		The number of pixels the container has been scrolled horizontally (on
		the x-axis).

		When setting `scrollX`, the new value will be automatically clamped to
		the range between `minScrollX` and `maxScrollX`. To programmatically set
		a `scrollX` to a value outside of that range, set `unrestrictedScrollX`
		instead.

		When the value of `scrollX` changes, the container dispatches an event
		of type `ScrollEvent.SCROLL`. This event is dispatched when other
		scroll position properties change too.

		In the following example, the horizontal scroll position is modified
		immediately, without being animated:

		```haxe
		container.scrollX = 100.0;
		```

		@see `BaseScrollContainer.minScrollX`
		@see `BaseScrollContainer.maxScrollX`
		@see `feathers.events.ScrollEvent.SCROLL`

		@since 1.0.0
	**/
	@:bindable("scroll")
	public var scrollX(get, set):Float;

	private function get_scrollX():Float {
		if (this.scroller == null) {
			if (this._temporaryRestrictedScrollX != null) {
				return this._temporaryRestrictedScrollX;
			}
			if (this._temporaryScrollX != null) {
				return this._temporaryScrollX;
			}
			return 0.0;
		}
		return this.scroller.scrollX;
	}

	private function set_scrollX(value:Float):Float {
		if (this.scroller == null) {
			this._temporaryScrollX = value;
			this._temporaryRestrictedScrollX = null;
			ScrollEvent.dispatch(this, ScrollEvent.SCROLL, false, false, this._temporaryScrollX, this._temporaryScrollY);
			return this._temporaryScrollX;
		}
		this.scroller.scrollX = value;
		return this.scroller.scrollX;
	}

	/**
		Setting `scrollX` will clamp the value between `minScrollX` and
		`maxScrollX`, but setting `unrestrictedScrollX` will allow values
		outside of that range.

		@see `BaseScrollContainer.scrollX`

		@since 1.0.0
	**/
	@:bindable("scroll")
	public var restrictedScrollX(get, set):Float;

	private function get_restrictedScrollX():Float {
		if (this.scroller == null) {
			return this.scrollX;
		}
		return this.scroller.restrictedScrollX;
	}

	private function set_restrictedScrollX(value:Float):Float {
		if (this.scroller == null) {
			this._temporaryRestrictedScrollX = value;
			this._temporaryScrollX = null;
			ScrollEvent.dispatch(this, ScrollEvent.SCROLL, false, false, this._temporaryScrollX, this._temporaryScrollY);
			return this._temporaryRestrictedScrollX;
		}
		this.scroller.restrictedScrollX = value;
		return this.scroller.restrictedScrollX;
	}

	private var _temporaryScrollY:Null<Float> = null;
	private var _temporaryRestrictedScrollY:Null<Float> = null;

	/**
		The number of pixels the container has been scrolled vertically (on the
		y-axis).

		When the value of `scrollY` changes, the container dispatches an event
		of type `ScrollEvent.SCROLL`. This event is dispatched when other
		scroll position properties change too.

		In the following example, the vertical scroll position is modified
		immediately, without being animated:

		```haxe
		container.scrollY = 100.0;
		```

		@see `BaseScrollContainer.minScrollY`
		@see `BaseScrollContainer.maxScrollY`
		@see `feathers.events.ScrollEvent.SCROLL`

		@since 1.0.0
	**/
	@:bindable("scroll")
	public var scrollY(get, set):Float;

	private function get_scrollY():Float {
		if (this.scroller == null) {
			if (this._temporaryRestrictedScrollY != null) {
				return this._temporaryRestrictedScrollY;
			}
			if (this._temporaryScrollY != null) {
				return this._temporaryScrollY;
			}
			return 0.0;
		}
		return this.scroller.scrollY;
	}

	private function set_scrollY(value:Float):Float {
		if (this.scroller == null) {
			this._temporaryScrollY = value;
			this._temporaryRestrictedScrollY = null;
			ScrollEvent.dispatch(this, ScrollEvent.SCROLL, false, false, this._temporaryScrollX, this._temporaryScrollY);
			return this._temporaryScrollY;
		}
		this.scroller.scrollY = value;
		return this.scroller.scrollY;
	}

	/**
		Setting `restrictedScrollY` will clamp the value to the range between
		`minScrollY` and `maxScrollY`.

		@see `BaseScrollContainer.scrollY`

		@since 1.0.0
	**/
	@:bindable("scroll")
	public var restrictedScrollY(get, set):Float;

	private function get_restrictedScrollY():Float {
		if (this.scroller == null) {
			this.scrollY;
		}
		return this.scroller.restrictedScrollY;
	}

	private function set_restrictedScrollY(value:Float):Float {
		if (this.scroller == null) {
			this._temporaryRestrictedScrollY = value;
			this._temporaryScrollY = null;
			ScrollEvent.dispatch(this, ScrollEvent.SCROLL, false, false, this._temporaryScrollX, this._temporaryScrollY);
			return this._temporaryRestrictedScrollY;
		}
		this.scroller.restrictedScrollY = value;
		return this.scroller.restrictedScrollY;
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
	public var maxScrollY(get, never):Float;

	private function get_maxScrollY():Float {
		if (this.scroller == null) {
			return 0.0;
		}
		return this.scroller.maxScrollY;
	}

	private var _scrollStepX:Float = 1.0;

	/**
		The number of pixels the horizontal scroll position can be adjusted by
		a step (such as with the left/right keyboard arrow keys, or a step
		button on the horizontal scroll bar).

		In the following example, the horizontal scroll step is set to 20 pixels:

		```haxe
		container.scrollStepX = 20.0;
		```

		@since 1.0.0
	**/
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

	private var _scrollStepY:Float = 1.0;

	/**
		The number of pixels the vertical scroll position can be adjusted by
		a step (such as with the up/down keyboard arrow keys, or a step button
		on the vertical scroll bar).

		In the following example, the vertical scroll step is set to 20 pixels:

		```haxe
		container.scrollStepY = 20.0;
		```

		@since 1.0.0
	**/
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

		```haxe
		container.scrollPolicyX = OFF;
		```

		@see `BaseScrollContainer.scrollPolicyY`

		@since 1.0.0
	**/
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

		```haxe
		container.scrollPolicyY = OFF;
		```

		@see `BaseScrollContainer.scrollPolicyX`

		@since 1.0.0
	**/
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
		Determines the edge of the container where the horizontal scroll bar
		will be positioned (either on the top or the bottom).

		In the following example, the horizontal scroll bar is positioned on the
		top edge of the container:

		```haxe
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

		```haxe
		container.scrollBarYPosition = LEFT;
		```

		@see `feathers.layout.RelativePosition.RIGHT`
		@see `feathers.layout.RelativePosition.LEFT`

		@since 1.0.0
	**/
	@:style
	public var scrollBarYPosition:RelativePosition = RIGHT;

	/**
		The minimum time, in seconds, that the scroll bars will be shown, if
		`autoHideScrollBars` is enabled.

		In the following example, the minimum duration to show scroll bars is
		increased:

		```haxe
		container.showScrollBarMinimumDuration = 1.0;
		```

		@see `BaseScrollContainer.autoHideScrollBars`

		@since 1.0.0
	**/
	@:style
	public var showScrollBarMinimumDuration:Float = 0.5;

	private var _scrollBarXRevealTime:Int;
	private var _scrollBarYRevealTime:Int;
	private var _hideScrollBarX:SimpleActuator<Dynamic, Dynamic> = null;
	private var _hideScrollBarY:SimpleActuator<Dynamic, Dynamic> = null;

	/**
		The duration, measured in seconds, of the animation when a scroll bar
		fades out.

		In the following example, the duration of the animation that hides the
		scroll bars is set to 500 milliseconds:

		```haxe
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

		```haxe
		container.hideScrollBarEase = Elastic.easeOut;
		```

		@since 1.0.0
	**/
	@:style
	public var hideScrollBarEase:IEasing = Quart.easeOut;

	/**
		If enabled, the scroll position will always be adjusted to the nearest
		pixel in stage coordinates.

		In the following example, the scroll position is snapped to pixels:

		```haxe
		container.scrollPixelSnapping = true;
		```

		@since 1.0.0
	**/
	@:style
	public var scrollPixelSnapping:Bool = false;

	private var _prevMinScrollX:Float = 0.0;
	private var _prevMaxScrollX:Float = 0.0;
	private var _prevMinScrollY:Float = 0.0;
	private var _prevMaxScrollY:Float = 0.0;

	private var _currentScrollRect:Rectangle;
	private var _scrollRect1:Rectangle = new Rectangle();
	private var _scrollRect2:Rectangle = new Rectangle();

	private var _ignoreScrollerChanges = false;
	private var _settingScrollerDimensions = false;
	private var _ignoreViewPortResizing = false;

	private var measureViewPort(get, never):Bool;

	private function get_measureViewPort():Bool {
		return true;
	}

	private var _scrollMode:ScrollMode = MASK;

	/**
		Determines how scrolling is rendered by the container.

		In the following example, scroll mode is changed to use a `scrollRect`:

		```haxe
		container.scrollMode = SCROLL_RECT;
		```

		@since 1.0.0
	**/
	public var scrollMode(get, set):ScrollMode;

	private function get_scrollMode():ScrollMode {
		return this._scrollMode;
	}

	private function set_scrollMode(value:ScrollMode):ScrollMode {
		if (this._scrollMode == value) {
			return this._scrollMode;
		}
		this._scrollMode = value;
		this.setInvalid(LAYOUT);
		return this._scrollMode;
	}

	/**
		Sets all four padding properties to the same value.

		@see `BaseScrollContainer.paddingTop`
		@see `BaseScrollContainer.paddingRight`
		@see `BaseScrollContainer.paddingBottom`
		@see `BaseScrollContainer.paddingLeft`

		@since 1.0.0
	**/
	public function setPadding(value:Float):Void {
		this.paddingTop = value;
		this.paddingRight = value;
		this.paddingBottom = value;
		this.paddingLeft = value;
	}

	/**
		Returns the visible bounds of the view port within the container's local
		coordinate system.

		@since 1.0.0
	**/
	public function getViewPortVisibleBounds(result:Rectangle = null):Rectangle {
		var viewPortX = this.leftViewPortOffset + this.paddingLeft;
		var viewPortY = this.topViewPortOffset + this.paddingTop;
		if (result == null) {
			result = new Rectangle(viewPortX, viewPortY, this._viewPort.visibleWidth, this._viewPort.visibleHeight);
		} else {
			result.setTo(viewPortX, viewPortY, this._viewPort.visibleWidth, this._viewPort.visibleHeight);
		}
		return result;
	}

	override public function dispose():Void {
		this.destroyScroller();
		this.destroyScrollBarX();
		this.destroyScrollBarY();
		super.dispose();
	}

	override private function update():Void {
		var stylesInvalid = this.isInvalid(STYLES);
		var sizeInvalid = this.isInvalid(SIZE);
		var stateInvalid = this.isInvalid(STATE);
		var scrollerInvalid = this.isInvalid(INVALIDATION_FLAG_SCROLLER_FACTORY);
		var scrollBarFactoryInvalid = this.isInvalid(INVALIDATION_FLAG_SCROLL_BAR_FACTORY);

		var oldIgnoreScrollerChanges = this._ignoreScrollerChanges;
		this._ignoreScrollerChanges = true;

		if (scrollerInvalid) {
			this.createScroller();
		}

		if (stylesInvalid || stateInvalid) {
			this.refreshBackgroundSkin();
		}

		if (stylesInvalid) {
			this.refreshMaskSkin();
			this.refreshViewPortMaskSkin();
			this.refreshScrollBarsCornerSkin();
		}

		if (scrollBarFactoryInvalid) {
			this.createScrollBars();
		}

		this.refreshEnabled();
		this.refreshScrollerValues();

		this.refreshViewPort();

		this.applyTemporaryScrollPositions();

		this.refreshScrollRect();
		this.refreshScrollBarValues();
		this.layoutChildren();

		this._ignoreScrollerChanges = oldIgnoreScrollerChanges;
	}

	private function applyTemporaryScrollPositions():Void {
		if (this._temporaryScrollX != null) {
			this.scroller.scrollX = this._temporaryScrollX;
		} else if (this._temporaryRestrictedScrollX != null) {
			this.scroller.restrictedScrollX = this._temporaryRestrictedScrollX;
		}
		if (this._temporaryScrollY != null) {
			this.scroller.scrollY = this._temporaryScrollY;
		} else if (this._temporaryRestrictedScrollY != null) {
			this.scroller.restrictedScrollY = this._temporaryRestrictedScrollY;
		}
		this._temporaryScrollX = null;
		this._temporaryScrollY = null;
		this._temporaryRestrictedScrollX = null;
		this._temporaryRestrictedScrollY = null;
	}

	private function needsMeasurement():Bool {
		return (this.isInvalid(SCROLL) && this.needsScrollMeasurement())
			|| this.isInvalid(DATA)
			|| this.isInvalid(SIZE)
			|| this.isInvalid(STYLES)
			|| this.isInvalid(INVALIDATION_FLAG_SCROLL_BAR_FACTORY)
			|| this.isInvalid(STATE)
			|| this.isInvalid(LAYOUT);
	}

	private function needsScrollMeasurement():Bool {
		return false;
	}

	private function createScroller():Void {
		this.destroyScroller();
		this.scroller = (this._scrollerFactory != null) ? this._scrollerFactory() : new Scroller();
		this.scroller.addEventListener(Event.SCROLL, baseScrollContainer_scroller_scrollHandler);
		this.scroller.addEventListener(ScrollEvent.SCROLL_START, baseScrollContainer_scroller_scrollStartHandler);
		this.scroller.addEventListener(ScrollEvent.SCROLL_COMPLETE, baseScrollContainer_scroller_scrollCompleteHandler);
	}

	private function destroyScroller():Void {
		if (this.scroller == null) {
			return;
		}
		this._temporaryScrollX = this.scroller.scrollX;
		this._temporaryScrollY = this.scroller.scrollY;
		this._temporaryRestrictedScrollX = null;
		this._temporaryRestrictedScrollY = null;
		this.scroller.target = null;
		this.scroller.removeEventListener(Event.SCROLL, baseScrollContainer_scroller_scrollHandler);
		this.scroller.removeEventListener(ScrollEvent.SCROLL_START, baseScrollContainer_scroller_scrollStartHandler);
		this.scroller.removeEventListener(ScrollEvent.SCROLL_COMPLETE, baseScrollContainer_scroller_scrollCompleteHandler);
		this.scroller = null;
		this.setInvalidationFlag(INVALIDATION_FLAG_SCROLLER_FACTORY);
	}

	private function createScrollBars():Void {
		this.createScrollBarX();
		this.createScrollBarY();
	}

	private function createScrollBarX():Void {
		this.destroyScrollBarX();
		var factory = this._scrollBarXFactory != null ? this._scrollBarXFactory : defaultScrollBarXFactory;
		this._oldScrollBarXFactory = factory;
		this.scrollBarX = factory.create();
		if (this.autoHideScrollBars) {
			this.scrollBarX.alpha = 0.0;
		}
		this.scrollBarX.addEventListener(Event.CHANGE, scrollBarX_changeHandler);
		this.scrollBarX.addEventListener(MouseEvent.ROLL_OVER, scrollBarX_rollOverHandler);
		this.scrollBarX.addEventListener(MouseEvent.ROLL_OUT, scrollBarX_rollOutHandler);
		this.scrollBarX.addEventListener(ScrollEvent.SCROLL_START, scrollBarX_scrollStartHandler);
		this.scrollBarX.addEventListener(ScrollEvent.SCROLL_COMPLETE, scrollBarX_scrollCompleteHandler);
		this.addChild(cast(this.scrollBarX, DisplayObject));
	}

	private function destroyScrollBarX():Void {
		if (this.scrollBarX == null) {
			return;
		}
		this.scrollBarX.removeEventListener(Event.CHANGE, scrollBarX_changeHandler);
		this.scrollBarX.removeEventListener(MouseEvent.ROLL_OVER, scrollBarX_rollOverHandler);
		this.scrollBarX.removeEventListener(MouseEvent.ROLL_OUT, scrollBarX_rollOutHandler);
		this.scrollBarX.removeEventListener(ScrollEvent.SCROLL_START, scrollBarX_scrollStartHandler);
		this.scrollBarX.removeEventListener(ScrollEvent.SCROLL_COMPLETE, scrollBarX_scrollCompleteHandler);
		this.removeChild(cast(this.scrollBarX, DisplayObject));
		if (this._oldScrollBarXFactory.destroy != null) {
			this._oldScrollBarXFactory.destroy(this.scrollBarX);
		}
		this._oldScrollBarXFactory = null;
		this.scrollBarX = null;
	}

	private function createScrollBarY():Void {
		this.destroyScrollBarY();
		var factory = this._scrollBarYFactory != null ? this._scrollBarYFactory : defaultScrollBarYFactory;
		this._oldScrollBarYFactory = factory;
		this.scrollBarY = factory.create();
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

	private function destroyScrollBarY():Void {
		if (this.scrollBarY == null) {
			return;
		}
		this.scrollBarY.removeEventListener(Event.CHANGE, scrollBarY_changeHandler);
		this.scrollBarY.removeEventListener(MouseEvent.ROLL_OVER, scrollBarY_rollOverHandler);
		this.scrollBarY.removeEventListener(MouseEvent.ROLL_OUT, scrollBarY_rollOutHandler);
		this.scrollBarY.removeEventListener(ScrollEvent.SCROLL_START, scrollBarY_scrollStartHandler);
		this.scrollBarY.removeEventListener(ScrollEvent.SCROLL_COMPLETE, scrollBarY_scrollCompleteHandler);
		this.removeChild(cast(this.scrollBarY, DisplayObject));
		if (this._oldScrollBarYFactory.destroy != null) {
			this._oldScrollBarYFactory.destroy(this.scrollBarY);
		}
		this._oldScrollBarYFactory = null;
		this.scrollBarY = null;
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

	private function restrictScrollAfterRefreshViewPort():Void {
		if (this.scroller.scrolling) {
			return;
		}
		// by checking for the minimum or maximum changing, ensures that
		// scrollX/Y can be set out of range on purpose
		var currentScrollX = this.scroller.scrollX;
		var currentScrollY = this.scroller.scrollY;
		if (this._prevMinScrollX != this.scroller.minScrollX && currentScrollX < this.scroller.minScrollX) {
			this.scroller.restrictedScrollX = currentScrollX;
		} else if (this._prevMaxScrollX != this.scroller.maxScrollX && currentScrollX > this.scroller.maxScrollX) {
			this.scroller.restrictedScrollX = currentScrollX;
		}
		if (this._prevMinScrollY != this.scroller.minScrollY && currentScrollY < this.scroller.minScrollY) {
			this.scroller.restrictedScrollY = currentScrollY;
		} else if (this._prevMaxScrollY != this.scroller.maxScrollY && currentScrollY > this.scroller.maxScrollY) {
			this.scroller.restrictedScrollY = currentScrollY;
		}
		if (currentScrollX != this.scroller.scrollX || currentScrollY != this.scroller.scrollY) {
			// the scroll event from the scroller will be ignored at this point
			// so we need to manually dispatch it
			ScrollEvent.dispatch(this, ScrollEvent.SCROLL, false, false, this.scroller.scrollX, this.scroller.scrollY);
		}
	}

	private function refreshViewPort():Void {
		if ((this.scrollBarX is IValidating)) {
			(cast this.scrollBarX : IValidating).validateNow();
		}
		if ((this.scrollBarY is IValidating)) {
			(cast this.scrollBarY : IValidating).validateNow();
		}

		this._viewPort.scrollX = this.scrollX;
		this._viewPort.scrollY = this.scrollY;

		this._prevMinScrollX = this.scroller.minScrollX;
		this._prevMaxScrollX = this.scroller.maxScrollX;
		this._prevMinScrollY = this.scroller.minScrollY;
		this._prevMaxScrollY = this.scroller.maxScrollY;

		if (!this.needsMeasurement()) {
			this._viewPort.validateNow();
			var oldSettingScrollerDimensions = this._settingScrollerDimensions;
			this._settingScrollerDimensions = true;
			this.scroller.setDimensions(this._viewPort.visibleWidth, this._viewPort.visibleHeight, this._viewPort.width, this._viewPort.height);
			this._settingScrollerDimensions = oldSettingScrollerDimensions;
			this.restrictScrollAfterRefreshViewPort();
			return;
		}

		this.resetViewPortOffsets();
		this.calculateViewPortOffsets(false, false);
		this.refreshViewPortBoundsForMeasurement();
		if (this.scrollPolicyX == AUTO) {
			var oldShowScrollBarX = this.showScrollBarX;
			this.calculateViewPortOffsetsForFixedScrollBarX(false);
			if (this.fixedScrollBars && this.showScrollBarX != oldShowScrollBarX) {
				this.refreshViewPortBoundsForMeasurement();
			}
		}
		if (this.scrollPolicyY == AUTO) {
			var oldShowScrollBarY = this.showScrollBarY;
			this.calculateViewPortOffsetsForFixedScrollBarY(false);
			if (this.fixedScrollBars && this.showScrollBarY != oldShowScrollBarY) {
				this.refreshViewPortBoundsForMeasurement();
			}
		}
		if (this.fixedScrollBars && !this.showScrollBarX && this.showScrollBarY && this.scrollPolicyX == AUTO && this.scrollPolicyY == AUTO) {
			var oldShowScrollBarX = this.showScrollBarX;
			this.calculateViewPortOffsetsForFixedScrollBarX(false);
			if (this.showScrollBarX != oldShowScrollBarX) {
				this.refreshViewPortBoundsForMeasurement();
			}
		}

		var oldSettingScrollerDimensions = this._settingScrollerDimensions;
		this._settingScrollerDimensions = true;
		this.scroller.setDimensions(this._viewPort.visibleWidth, this._viewPort.visibleHeight, this._viewPort.width, this._viewPort.height);
		this._settingScrollerDimensions = oldSettingScrollerDimensions;

		this.measure();

		this.resetViewPortOffsets();
		this.calculateViewPortOffsets(false, true);
		this.refreshViewPortBoundsForLayout();
		if (this.scrollPolicyX == AUTO) {
			var oldShowScrollBarX = this.showScrollBarX;
			this.calculateViewPortOffsetsForFixedScrollBarX(true);
			if (this.fixedScrollBars && this.showScrollBarX != oldShowScrollBarX) {
				this.refreshViewPortBoundsForLayout();
			}
		}
		if (this.scrollPolicyY == AUTO) {
			var oldShowScrollBarY = this.showScrollBarY;
			this.calculateViewPortOffsetsForFixedScrollBarY(true);
			if (this.fixedScrollBars && this.showScrollBarY != oldShowScrollBarY) {
				this.refreshViewPortBoundsForLayout();
			}
		}
		if (this.fixedScrollBars && !this.showScrollBarX && this.showScrollBarY && this.scrollPolicyX == AUTO && this.scrollPolicyY == AUTO) {
			var oldShowScrollBarX = this.showScrollBarX;
			this.calculateViewPortOffsetsForFixedScrollBarX(true);
			if (this.showScrollBarX != oldShowScrollBarX) {
				this.refreshViewPortBoundsForLayout();
			}
		}

		var oldSettingScrollerDimensions = this._settingScrollerDimensions;
		this._settingScrollerDimensions = true;
		this.scroller.setDimensions(this._viewPort.visibleWidth, this._viewPort.visibleHeight, this._viewPort.width, this._viewPort.height);
		this._settingScrollerDimensions = oldSettingScrollerDimensions;

		this.restrictScrollAfterRefreshViewPort();
	}

	private function resetViewPortOffsets():Void {
		// if scrolling was already required from a previous update, chances are
		// that it will be required in this update. default to keeping it the
		// same because that's much better for performance. in the uncommon case
		// where this assumption is incorrect, it will be fixed during view port
		// measurement.
		this.showScrollBarX = this.showScrollBars
			&& (this._scrollPolicyX == ON || (this._scrollPolicyX == AUTO && this.scroller.minScrollX != this.scroller.maxScrollX));
		this.showScrollBarY = this.showScrollBars
			&& (this._scrollPolicyX == ON || (this._scrollPolicyY == AUTO && this.scroller.minScrollY != this.scroller.maxScrollY));
		this.topViewPortOffset = (this.fixedScrollBars && this.showScrollBarX && this.scrollBarXPosition == TOP) ? this.scrollBarX.height : 0.0;
		this.bottomViewPortOffset = (this.fixedScrollBars && this.showScrollBarX && this.scrollBarXPosition == BOTTOM) ? this.scrollBarX.height : 0.0;
		this.leftViewPortOffset = (this.fixedScrollBars && this.showScrollBarY && this.scrollBarYPosition == LEFT) ? this.scrollBarY.width : 0.0;
		this.rightViewPortOffset = (this.fixedScrollBars && this.showScrollBarY && this.scrollBarYPosition == RIGHT) ? this.scrollBarY.width : 0.0;
		this.chromeMeasuredWidth = 0.0;
		this.chromeMeasuredMinWidth = 0.0;
		this.chromeMeasuredMaxWidth = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround for swf
		this.chromeMeasuredHeight = 0.0;
		this.chromeMeasuredMinHeight = 0.0;
		this.chromeMeasuredMaxHeight = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround for swf
	}

	private function calculateViewPortOffsets(forceScrollBars:Bool, useActualBounds:Bool):Void {}

	private function calculateViewPortOffsetsForFixedScrollBarX(useActualBounds:Bool):Void {
		if (this.scrollBarX == null) {
			return;
		}
		var newShowScrollBarX = false;
		if (this.showScrollBars && this.scrollPolicyX != OFF) {
			newShowScrollBarX = this.scrollPolicyX == ON;
			if (!newShowScrollBarX && this.scrollPolicyX == AUTO) {
				var availableWidth = useActualBounds ? this.actualWidth : this.explicitWidth;
				if (availableWidth != null) {
					availableWidth -= (this.paddingLeft + this.paddingRight + this.leftViewPortOffset + this.rightViewPortOffset);
					if (availableWidth < 0.0) {
						availableWidth = 0.0;
					}
				}
				if (availableWidth == null && !useActualBounds) {
					// even if explicitWidth is null, the view port might measure
					// a view port width smaller than its content width
					availableWidth = this._viewPort.visibleWidth;
				}
				var totalContentWidth = this._viewPort.width;
				newShowScrollBarX = availableWidth != null
					&& totalContentWidth > availableWidth
					&& !MathUtil.fuzzyEquals(totalContentWidth, availableWidth);
				if (!newShowScrollBarX) {
					var maxAvailableWidth = this.explicitMaxWidth;
					if (maxAvailableWidth != null) {
						maxAvailableWidth -= (this.paddingLeft + this.paddingRight + this.leftViewPortOffset + this.rightViewPortOffset);
						if (maxAvailableWidth < 0.0) {
							maxAvailableWidth = 0.0;
						}
					}
					newShowScrollBarX = maxAvailableWidth != null
						&& totalContentWidth > maxAvailableWidth
						&& !MathUtil.fuzzyEquals(totalContentWidth, maxAvailableWidth);
				}
			}
		}
		if (this.showScrollBarX == newShowScrollBarX) {
			return;
		}
		this.showScrollBarX = newShowScrollBarX;
		if (!this.fixedScrollBars) {
			// offsets aren't affected if the scroll bars are not fixed
			// because the content appears under the floating scroll bars
			return;
		}
		var offset = this.scrollBarX.height;
		if (!this.showScrollBarX) {
			offset = -offset;
		}
		if (this.scrollBarXPosition == TOP) {
			this.topViewPortOffset += offset;
		} else {
			this.bottomViewPortOffset += offset;
		}
	}

	private function calculateViewPortOffsetsForFixedScrollBarY(useActualBounds:Bool):Void {
		if (this.scrollBarY == null) {
			return;
		}
		var newShowScrollBarY = false;
		if (this.showScrollBars && this.scrollPolicyY != OFF) {
			newShowScrollBarY = this.scrollPolicyY == ON;
			if (!newShowScrollBarY && this.scrollPolicyY == AUTO) {
				var availableHeight = useActualBounds ? this.actualHeight : this.explicitHeight;
				if (availableHeight != null) {
					availableHeight -= (this.paddingTop + this.paddingBottom + this.topViewPortOffset + this.bottomViewPortOffset);
					if (availableHeight < 0.0) {
						availableHeight = 0.0;
					}
				}
				if (availableHeight == null && !useActualBounds) {
					// even if explicitHeight is null, the view port might measure
					// a view port height smaller than its content height
					availableHeight = this._viewPort.visibleHeight;
				}
				var totalContentHeight = this._viewPort.height;
				newShowScrollBarY = availableHeight != null
					&& totalContentHeight > availableHeight
					&& !MathUtil.fuzzyEquals(totalContentHeight, availableHeight);
				if (!newShowScrollBarY) {
					var maxAvailableHeight = this.explicitMaxHeight;
					if (maxAvailableHeight != null) {
						maxAvailableHeight -= (this.paddingTop + this.paddingBottom + this.topViewPortOffset + this.bottomViewPortOffset);
						if (maxAvailableHeight < 0.0) {
							maxAvailableHeight = 0.0;
						}
					}
					newShowScrollBarY = maxAvailableHeight != null
						&& totalContentHeight > maxAvailableHeight
						&& !MathUtil.fuzzyEquals(totalContentHeight, maxAvailableHeight);
				}
			}
		}
		if (this.showScrollBarY == newShowScrollBarY) {
			return;
		}
		this.showScrollBarY = newShowScrollBarY;
		if (!this.fixedScrollBars) {
			// offsets aren't affected if the scroll bars are not fixed
			// because the content appears under the floating scroll bars
			return;
		}
		var offset = this.scrollBarY.width;
		if (!this.showScrollBarY) {
			offset = -offset;
		}
		if (this.scrollBarYPosition == LEFT) {
			this.leftViewPortOffset += offset;
		} else {
			this.rightViewPortOffset += offset;
		}
	}

	private function refreshViewPortBoundsForMeasurement():Void {
		var oldIgnoreViewPortResizing = this._ignoreViewPortResizing;
		// setting some of the properties below may result in a resize
		// event, which forces another layout pass for the view port and
		// hurts performance (because it needs to break out of an
		// infinite loop)
		this._ignoreViewPortResizing = true;

		var viewPortX = this.paddingLeft + this.leftViewPortOffset;
		var viewPortY = this.paddingTop + this.topViewPortOffset;
		if (this._scrollMode == MASK || this._scrollMode == MASKLESS || this._currentViewPortMaskSkin != null) {
			viewPortX -= scrollX;
			viewPortY -= scrollY;
		}
		this._viewPort.x = viewPortX;
		this._viewPort.y = viewPortY;
		if (this.explicitWidth != null) {
			var visibleWidth = this.explicitWidth - this.leftViewPortOffset - this.rightViewPortOffset - this.paddingLeft - this.paddingRight;
			if (visibleWidth < 0.0) {
				visibleWidth = 0.0;
			}
			this._viewPort.visibleWidth = visibleWidth;
		} else {
			this._viewPort.visibleWidth = null;
		}
		if (this.explicitHeight != null) {
			var visibleHeight = this.explicitHeight - this.topViewPortOffset - this.bottomViewPortOffset - this.paddingTop - this.paddingBottom;
			if (visibleHeight < 0.0) {
				visibleHeight = 0.0;
			}
			this._viewPort.visibleHeight = visibleHeight;
		} else {
			this._viewPort.visibleHeight = null;
		}
		if (this.explicitMinWidth != null) {
			var minVisibleWidth = this.explicitMinWidth - this.leftViewPortOffset - this.rightViewPortOffset - this.paddingLeft - this.paddingRight;
			if (minVisibleWidth < 0.0) {
				minVisibleWidth = 0.0;
			}
			this._viewPort.minVisibleWidth = minVisibleWidth;
		} else {
			this._viewPort.minVisibleWidth = null;
		}
		if (this.explicitMinHeight != null) {
			var minVisibleHeight = this.explicitMinHeight - this.topViewPortOffset - this.bottomViewPortOffset - this.paddingTop - this.paddingBottom;
			if (minVisibleHeight < 0.0) {
				minVisibleHeight = 0.0;
			}
			this._viewPort.minVisibleHeight = minVisibleHeight;
		} else {
			this._viewPort.minVisibleHeight = null;
		}
		if (this.explicitMaxWidth != null) {
			var maxVisibleWidth = this.explicitMaxWidth - this.leftViewPortOffset - this.rightViewPortOffset - this.paddingLeft - this.paddingRight;
			if (maxVisibleWidth < 0.0) {
				maxVisibleWidth = 0.0;
			}
			this._viewPort.maxVisibleWidth = maxVisibleWidth;
		} else if (this._backgroundSkinMeasurements != null && this._backgroundSkinMeasurements.maxWidth != null) {
			var maxVisibleWidth = this._backgroundSkinMeasurements.maxWidth - this.leftViewPortOffset - this.rightViewPortOffset - this.paddingLeft
				- this.paddingRight;
			if (maxVisibleWidth < 0.0) {
				maxVisibleWidth = 0.0;
			}
			this._viewPort.maxVisibleWidth = maxVisibleWidth;
		} else {
			this._viewPort.maxVisibleWidth = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround for swf
		}
		if (this.explicitMaxHeight != null) {
			var maxVisibleHeight = this.explicitMaxHeight - this.topViewPortOffset - this.bottomViewPortOffset - this.paddingTop - this.paddingBottom;
			if (maxVisibleHeight < 0.0) {
				maxVisibleHeight = 0.0;
			}
			this._viewPort.maxVisibleHeight = maxVisibleHeight;
		} else if (this._backgroundSkinMeasurements != null && this._backgroundSkinMeasurements.maxHeight != null) {
			var maxVisibleHeight = this._backgroundSkinMeasurements.maxHeight - this.topViewPortOffset - this.bottomViewPortOffset - this.paddingTop
				- this.paddingBottom;
			if (maxVisibleHeight < 0.0) {
				maxVisibleHeight = 0.0;
			}
			this._viewPort.maxVisibleHeight = maxVisibleHeight;
		} else {
			this._viewPort.maxVisibleHeight = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround for swf
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

		var viewPortX = this.paddingLeft + this.leftViewPortOffset;
		var viewPortY = this.paddingTop + this.topViewPortOffset;
		if (this._scrollMode == MASK || this._scrollMode == MASKLESS || this._currentViewPortMaskSkin != null) {
			viewPortX -= scrollX;
			viewPortY -= scrollY;
		}
		this._viewPort.x = viewPortX;
		this._viewPort.y = viewPortY;
		this._viewPort.visibleWidth = visibleWidth;
		this._viewPort.visibleHeight = visibleHeight;
		this._viewPort.minVisibleWidth = minVisibleWidth;
		this._viewPort.minVisibleHeight = minVisibleHeight;
		this._viewPort.maxVisibleWidth = maxVisibleWidth;
		this._viewPort.maxVisibleHeight = maxVisibleHeight;

		// this time, we care whether a resize event is dispatched while the
		// view port is validating because it means we'll need to try another
		// measurement pass. we restore the flag before calling validate().

		this._viewPort.validateNow();
		this._ignoreViewPortResizing = oldIgnoreViewPortResizing;
	}

	private function refreshScrollerValues():Void {
		if (this.stage != null) {
			this.scroller.target = cast(this._viewPort, InteractiveObject);
		}
		this.scroller.enabledX = this._enabled && this._scrollPolicyX != OFF;
		this.scroller.enabledY = this._enabled && this._scrollPolicyY != OFF;
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
		if ((this._currentBackgroundSkin is IMeasureObject)) {
			measureSkin = cast this._currentBackgroundSkin;
		}

		if ((this._currentBackgroundSkin is IValidating)) {
			(cast this._currentBackgroundSkin : IValidating).validateNow();
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
			} else if (this._backgroundSkinMeasurements != null && this._backgroundSkinMeasurements.minWidth != null) {
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
			} else if (this._backgroundSkinMeasurements != null && this._backgroundSkinMeasurements.minHeight != null) {
				newMinHeight = Math.max(newMinHeight, this._backgroundSkinMeasurements.minHeight);
			}
		}
		var newMaxWidth = this.explicitMaxWidth;
		if (needsMaxWidth) {
			if (this.measureViewPort) {
				newMaxWidth = this._viewPort.maxVisibleWidth;
			} else {
				newMaxWidth = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround for swf
			}
			newMaxWidth += this.leftViewPortOffset + this.rightViewPortOffset;
			newMaxWidth = Math.min(newMaxWidth, this.chromeMeasuredMaxWidth);
			newMaxWidth += this.paddingLeft + this.paddingRight;
			if (measureSkin != null) {
				newMaxWidth = Math.min(newMaxWidth, measureSkin.maxWidth);
			} else if (this._backgroundSkinMeasurements != null && this._backgroundSkinMeasurements.maxWidth != null) {
				newMaxWidth = Math.min(newMaxWidth, this._backgroundSkinMeasurements.maxWidth);
			}
		}

		var newMaxHeight = this.explicitMaxHeight;
		if (needsMaxHeight) {
			if (this.measureViewPort) {
				newMaxHeight = this._viewPort.maxVisibleHeight;
			} else {
				newMaxHeight = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround for swf
			}
			newMaxHeight += this.topViewPortOffset + this.bottomViewPortOffset;
			newMaxHeight = Math.min(newMaxHeight, this.chromeMeasuredMaxHeight);
			newMaxHeight += this.paddingTop + this.paddingBottom;
			if (measureSkin != null) {
				newMaxHeight = Math.min(newMaxHeight, measureSkin.maxHeight);
			} else if (this._backgroundSkinMeasurements != null && this._backgroundSkinMeasurements.maxHeight != null) {
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
		this.addCurrentBackgroundSkin(this._currentBackgroundSkin);
	}

	private function getCurrentBackgroundSkin():DisplayObject {
		if (!this._enabled && this.disabledBackgroundSkin != null) {
			return this.disabledBackgroundSkin;
		}
		return this.backgroundSkin;
	}

	private function addCurrentBackgroundSkin(skin:DisplayObject):Void {
		if (skin == null) {
			this._backgroundSkinMeasurements = null;
			return;
		}
		if ((skin is IUIControl)) {
			(cast skin : IUIControl).initializeNow();
		}
		if (this._backgroundSkinMeasurements == null) {
			this._backgroundSkinMeasurements = new Measurements(skin);
		} else {
			this._backgroundSkinMeasurements.save(skin);
		}
		if ((skin is IProgrammaticSkin)) {
			(cast skin : IProgrammaticSkin).uiContext = this;
		}
		this.addChildAt(skin, 0);
	}

	private function removeCurrentBackgroundSkin(skin:DisplayObject):Void {
		if (skin == null) {
			return;
		}
		if ((skin is IProgrammaticSkin)) {
			(cast skin : IProgrammaticSkin).uiContext = null;
		}
		// we need to restore these values so that they won't be lost the
		// next time that this skin is used for measurement
		this._backgroundSkinMeasurements.restore(skin);
		if (skin.parent == this) {
			this.removeChild(skin);
		}
	}

	private function refreshMaskSkin():Void {
		var oldSkin = this._currentMaskSkin;
		this._currentMaskSkin = this.getCurrentMaskSkin();
		if (this._currentMaskSkin == oldSkin) {
			return;
		}
		this.removeCurrentMaskSkin(oldSkin);
		this.addCurrentMaskSkin(this._currentMaskSkin);
	}

	private function getCurrentMaskSkin():DisplayObject {
		return this.maskSkin;
	}

	private function addCurrentMaskSkin(skin:DisplayObject):Void {
		if (skin == null) {
			return;
		}
		if ((skin is IUIControl)) {
			(cast skin : IUIControl).initializeNow();
		}
		if ((skin is IProgrammaticSkin)) {
			(cast skin : IProgrammaticSkin).uiContext = this;
		}
		this.addChild(skin);
		this.mask = skin;
	}

	private function removeCurrentMaskSkin(skin:DisplayObject):Void {
		if (skin == null) {
			return;
		}
		if ((skin is IProgrammaticSkin)) {
			(cast skin : IProgrammaticSkin).uiContext = null;
		}
		if (skin.parent == this) {
			this.removeChild(skin);
		}
		this.mask = null;
	}

	private function refreshViewPortMaskSkin():Void {
		var oldSkin = this._currentViewPortMaskSkin;
		this._currentViewPortMaskSkin = this.getCurrentViewPortMaskSkin();
		if (this._currentViewPortMaskSkin == oldSkin) {
			return;
		}
		this.removeCurrentViewPortMaskSkin(oldSkin);
		this.addCurrentViewPortMaskSkin(this._currentViewPortMaskSkin);
	}

	private function getCurrentViewPortMaskSkin():DisplayObject {
		if (this.viewPortMaskSkin != null) {
			return this.viewPortMaskSkin;
		}
		if (this._scrollMode == MASK) {
			if (this._fallbackViewPortMaskSkin == null) {
				this._fallbackViewPortMaskSkin = new RectangleSkin(SolidColor(0xff00ff));
			}
			return this._fallbackViewPortMaskSkin;
		}
		return null;
	}

	private function addCurrentViewPortMaskSkin(skin:DisplayObject):Void {
		if (skin == null) {
			return;
		}
		if ((skin is IUIControl)) {
			(cast skin : IUIControl).initializeNow();
		}
		if ((skin is IProgrammaticSkin)) {
			(cast skin : IProgrammaticSkin).uiContext = this;
		}
		this.addChild(skin);
		cast(this._viewPort, DisplayObject).mask = skin;
	}

	private function removeCurrentViewPortMaskSkin(skin:DisplayObject):Void {
		if (skin == null) {
			return;
		}
		if ((skin is IProgrammaticSkin)) {
			(cast skin : IProgrammaticSkin).uiContext = null;
		}
		if (skin.parent == this) {
			this.removeChild(skin);
		}
		cast(this._viewPort, DisplayObject).mask = null;
	}

	private function refreshScrollBarsCornerSkin():Void {
		var oldSkin = this._currentScrollBarsCornerSkin;
		this._currentScrollBarsCornerSkin = this.getCurrentScrollBarsCornerSkin();
		if (this._currentScrollBarsCornerSkin == oldSkin) {
			return;
		}
		this.removeCurrentScrollBarsCornerSkin(oldSkin);
		this.addCurrentScrollBarsCornerSkin(this._currentScrollBarsCornerSkin);
	}

	private function getCurrentScrollBarsCornerSkin():DisplayObject {
		return this.scrollBarsCornerSkin;
	}

	private function addCurrentScrollBarsCornerSkin(skin:DisplayObject):Void {
		if (skin == null) {
			return;
		}
		if ((skin is IUIControl)) {
			(cast skin : IUIControl).initializeNow();
		}
		if ((skin is IProgrammaticSkin)) {
			(cast skin : IProgrammaticSkin).uiContext = this;
		}
		this.addChild(skin);
	}

	private function removeCurrentScrollBarsCornerSkin(skin:DisplayObject):Void {
		if (skin == null) {
			return;
		}
		if ((skin is IProgrammaticSkin)) {
			(cast skin : IProgrammaticSkin).uiContext = null;
		}
		if (skin.parent == this) {
			this.removeChild(skin);
		}
	}

	private function layoutChildren():Void {
		this.layoutBackgroundSkin();
		this.layoutMaskSkin();
		this.layoutViewPortMaskSkin();
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
		if ((this._currentBackgroundSkin is IValidating)) {
			(cast this._currentBackgroundSkin : IValidating).validateNow();
		}
	}

	private function layoutMaskSkin():Void {
		if (this._currentMaskSkin == null) {
			return;
		}

		this._currentMaskSkin.x = 0.0;
		this._currentMaskSkin.y = 0.0;
		this._currentMaskSkin.width = this.actualWidth;
		this._currentMaskSkin.height = this.actualHeight;
		if ((this._currentMaskSkin is IValidating)) {
			(cast this._currentMaskSkin : IValidating).validateNow();
		}
	}

	private function layoutViewPortMaskSkin():Void {
		if (this._currentViewPortMaskSkin == null) {
			return;
		}

		var maskX = this.paddingLeft + this.leftViewPortOffset;
		var maskY = this.paddingTop + this.topViewPortOffset;
		var maskWidth = this._viewPort.visibleWidth;
		var maskHeight = this._viewPort.visibleHeight;
		if (this.fixedScrollBars && this.scrollBarY.visible) {
			maskWidth += this.scrollBarY.width;
			if (this.scrollBarYPosition == LEFT) {
				maskX -= this.scrollBarY.width;
			}
		}
		if (this.fixedScrollBars && this.scrollBarX.visible) {
			maskHeight += this.scrollBarX.height;
			if (this.scrollBarXPosition == TOP) {
				maskX -= this.scrollBarX.height;
			}
		}
		this._currentViewPortMaskSkin.x = maskX;
		this._currentViewPortMaskSkin.y = maskY;
		this._currentViewPortMaskSkin.width = maskWidth;
		this._currentViewPortMaskSkin.height = maskHeight;
		if ((this._currentViewPortMaskSkin is IValidating)) {
			(cast this._currentViewPortMaskSkin : IValidating).validateNow();
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

		if (this.scrollBarX != null && (this.scrollBarX is IValidating)) {
			(cast this.scrollBarX : IValidating).validateNow();
		}
		if (this.scrollBarY != null && (this.scrollBarY is IValidating)) {
			(cast this.scrollBarY : IValidating).validateNow();
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

		if (this._currentScrollBarsCornerSkin != null) {
			if (this.fixedScrollBars && this.scrollBarX != null && this.scrollBarY != null && this.scrollBarX.visible && this.scrollBarY.visible) {
				this._currentScrollBarsCornerSkin.x = this.scrollBarY.x;
				this._currentScrollBarsCornerSkin.width = this.scrollBarY.width;
				this._currentScrollBarsCornerSkin.y = this.scrollBarX.y;
				this._currentScrollBarsCornerSkin.height = this.scrollBarX.height;
				this._currentScrollBarsCornerSkin.visible = true;
			} else {
				this._currentScrollBarsCornerSkin.visible = false;
			}
		}
	}

	private function refreshScrollRect():Void {
		var scrollX = scroller.scrollX;
		var scrollY = scroller.scrollY;
		if (this.scrollPixelSnapping) {
			var scaleFactorX = DisplayUtil.getConcatenatedScaleX(this);
			var scaleFactorY = DisplayUtil.getConcatenatedScaleY(this);
			scrollX = Math.round(scrollX / scaleFactorX) * scaleFactorX;
			scrollY = Math.round(scrollY / scaleFactorY) * scaleFactorY;
		}

		if (this._scrollMode == MASK || this._scrollMode == MASKLESS || this._currentViewPortMaskSkin != null) {
			var displayViewPort = cast(this._viewPort, DisplayObject);
			displayViewPort.scrollRect = null;
			this._viewPort.x = this.paddingLeft + this.leftViewPortOffset - scrollX;
			this._viewPort.y = this.paddingTop + this.topViewPortOffset - scrollY;
		} else if (this._scrollMode == SCROLL_RECT) {
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
			scrollRect.setTo(scrollX, scrollY, scrollRectWidth, scrollRectHeight);
			var displayViewPort = cast(this._viewPort, DisplayObject);
			displayViewPort.scrollRect = scrollRect;
		} else {
			throw new ArgumentError("Unknown scrollMode: " + this._scrollMode);
		}
	}

	private function revealScrollBarX():Void {
		if (this.scrollBarX == null || this.scroller.minScrollX == this.scroller.maxScrollX) {
			return;
		}
		if (this._hideScrollBarX != null) {
			Actuate.stop(this._hideScrollBarX);
		}
		this.scrollBarX.alpha = 1.0;
		this._scrollBarXRevealTime = Lib.getTimer();
	}

	private function revealScrollBarY():Void {
		if (this.scrollBarY == null || this.scroller.minScrollY == this.scroller.maxScrollY) {
			return;
		}
		if (this._hideScrollBarY != null) {
			Actuate.stop(this._hideScrollBarY);
		}
		this.scrollBarY.alpha = 1.0;
		this._scrollBarYRevealTime = Lib.getTimer();
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
		this._hideScrollBarX = cast tween;
		this._hideScrollBarX.ease(this.hideScrollBarEase);
		this._hideScrollBarX.autoVisible(false);
		var visibleTime = (Lib.getTimer() - this._scrollBarXRevealTime) / 1000.0;
		if (visibleTime < this.showScrollBarMinimumDuration) {
			this._hideScrollBarX.delay(this.showScrollBarMinimumDuration - visibleTime);
		}
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
		this._hideScrollBarY = cast tween;
		this._hideScrollBarY.ease(this.hideScrollBarEase);
		this._hideScrollBarY.autoVisible(false);
		var visibleTime = (Lib.getTimer() - this._scrollBarYRevealTime) / 1000.0;
		if (visibleTime < this.showScrollBarMinimumDuration) {
			this._hideScrollBarY.delay(this.showScrollBarMinimumDuration - visibleTime);
		}
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

		var scrolled = false;
		if (this.scrollY != newScrollY && this._scrollPolicyY != OFF) {
			scrolled = true;
			this.scrollY = newScrollY;
		}
		if (this.scrollX != newScrollX && this._scrollPolicyX != OFF) {
			scrolled = true;
			this.scrollX = newScrollX;
		}
		if (scrolled) {
			event.preventDefault();
		}
	}

	private function baseScrollContainer_addedToStageHandler(event:Event):Void {
		// ensure that target gets set, if it hasn't been already
		this.setInvalid(SCROLL);
	}

	private function baseScrollContainer_removedFromStageHandler(event:Event):Void {
		if (this.scroller != null) {
			this.scroller.target = null;
		}
	}

	private function baseScrollContainer_keyDownHandler(event:KeyboardEvent):Void {
		if (!this._enabled || event.isDefaultPrevented()) {
			return;
		}
		if (this.stage != null && (this.stage.focus is TextField)) {
			var textField:TextField = cast this.stage.focus;
			if (textField.type == INPUT) {
				// if an input TextField has focus, don't scroll because the
				// TextField should have precedence, and the TextFeeld won't
				// call preventDefault() on the event.
				return;
			}
		}
		this.scrollWithKeyboard(event);
	}

	private function baseScrollContainer_scroller_scrollStartHandler(event:ScrollEvent):Void {
		var touchPointID = this.scroller.touchPointID;
		if (this.scroller.touchPointIsSimulated) {
			var exclusivePointer = ExclusivePointer.forStage(this.stage);
			var result = exclusivePointer.claimMouse(this);
			if (!result) {
				this.scroller.stop();
				return;
			}
		} else if (touchPointID != null) {
			var exclusivePointer = ExclusivePointer.forStage(this.stage);
			var result = exclusivePointer.claimTouch(touchPointID, this);
			if (!result) {
				this.scroller.stop();
				return;
			}
		}
		this._viewPort.addEventListener(MouseEvent.MOUSE_DOWN, baseScrollContainer_viewPort_mouseDownHandler);
		this._viewPort.addEventListener(TouchEvent.TOUCH_BEGIN, baseScrollContainer_viewPort_touchBeginHandler);
		this._scrollerDraggingX = false;
		this._scrollerDraggingY = false;
		this.checkForRevealScrollBars();
		ScrollEvent.dispatch(this, ScrollEvent.SCROLL_START, false, false, this.scroller.scrollX, this.scroller.scrollY);
	}

	private function baseScrollContainer_scroller_scrollHandler(event:Event):Void {
		if (this._ignoreScrollerChanges) {
			if (this._settingScrollerDimensions && this.needsScrollMeasurement()) {
				// the scroller changed its position while we were updating its
				// dimensions. if it will affect the layout, we have no choice
				// but to validate again later.
				this.setInvalid(SCROLL);
			} else {
				// the view port should always be updated with scroll changes
				this._viewPort.scrollX = this.scrollX;
				this._viewPort.scrollY = this.scrollY;
			}
			return;
		}
		this.checkForRevealScrollBars();
		if (this.needsScrollMeasurement()) {
			this.setInvalid(SCROLL);
		} else {
			this._viewPort.scrollX = this.scrollX;
			this._viewPort.scrollY = this.scrollY;
			this.refreshScrollRect();
			this.refreshScrollBarValues();
		}
		ScrollEvent.dispatch(this, ScrollEvent.SCROLL, false, false, this.scroller.scrollX, this.scroller.scrollY);
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
		ScrollEvent.dispatch(this, ScrollEvent.SCROLL_COMPLETE, false, false, this.scroller.scrollX, this.scroller.scrollY);
	}

	private function reclaimMouse():Void {
		if (!this.scroller.touchPointIsSimulated) {
			return;
		}
		var exclusivePointer = ExclusivePointer.forStage(this.stage);
		var claim = exclusivePointer.getMouseClaim();
		if (claim != null) {
			return;
		}
		exclusivePointer.claimMouse(this);
	}

	private function reclaimTouch(touchPointID:Int):Void {
		if (this.scroller.touchPointIsSimulated || this.scroller.touchPointID == null || this.scroller.touchPointID != touchPointID) {
			return;
		}
		var exclusivePointer = ExclusivePointer.forStage(this.stage);
		var claim = exclusivePointer.getTouchClaim(touchPointID);
		if (claim != null) {
			return;
		}
		exclusivePointer.claimTouch(touchPointID, this);
	}

	private function baseScrollContainer_viewPort_mouseDownHandler(event:MouseEvent):Void {
		this.reclaimMouse();
	}

	private function baseScrollContainer_viewPort_touchBeginHandler(event:TouchEvent):Void {
		this.reclaimTouch(event.touchPointID);
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
		ScrollEvent.dispatch(this, ScrollEvent.SCROLL_START, false, false, this.scroller.scrollX, this.scroller.scrollY);
	}

	private function scrollBarX_scrollCompleteHandler(event:ScrollEvent):Void {
		this._scrollerDraggingX = false;
		if (!this._scrollBarXHover && !this.fixedScrollBars && this.autoHideScrollBars) {
			this.hideScrollBarX();
		}
		ScrollEvent.dispatch(this, ScrollEvent.SCROLL_COMPLETE, false, false, this.scroller.scrollX, this.scroller.scrollY);
	}

	private function scrollBarY_scrollStartHandler(event:ScrollEvent):Void {
		this.scroller.stop();
		this._scrollerDraggingY = true;
		ScrollEvent.dispatch(this, ScrollEvent.SCROLL_START, false, false, this.scroller.scrollX, this.scroller.scrollY);
	}

	private function scrollBarY_scrollCompleteHandler(event:ScrollEvent):Void {
		this._scrollerDraggingY = false;
		if (!this._scrollBarYHover && !this.fixedScrollBars && this.autoHideScrollBars) {
			this.hideScrollBarY();
		}
		ScrollEvent.dispatch(this, ScrollEvent.SCROLL_COMPLETE, false, false, this.scroller.scrollX, this.scroller.scrollY);
	}

	private function hideScrollBarX_onComplete():Void {
		this._hideScrollBarX = null;
	}

	private function hideScrollBarY_onComplete():Void {
		this._hideScrollBarY = null;
	}

	private function viewPort_resizeHandler(event:Event):Void {
		if (this._ignoreViewPortResizing) {
			return;
		}
		this.setInvalid(SIZE);
	}
}

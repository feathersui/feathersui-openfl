/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.utils;

import feathers.events.ScrollEvent;
import motion.Actuate;
import motion.actuators.SimpleActuator;
import motion.easing.IEasing;
import motion.easing.Quart;
import openfl.display.DisplayObjectContainer;
import openfl.display.InteractiveObject;
import openfl.display.Stage;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
#if html5
import js.Lib;
import js.html.WheelEvent;
#end
#if air
import openfl.ui.Multitouch;
#end

/**
	Utility that provides touch and mouse wheel scrolling capabilities for any
	interactive display object.

	@event feathers.events.ScrollEvent.SCROLL

	@event feathers.events.ScrollEvent.SCROLL_START

	@event feathers.events.ScrollEvent.SCROLL_COMPLETE

	@since 1.0.0
**/
@:event(feathers.events.ScrollEvent.SCROLL)
@:event(feathers.events.ScrollEvent.SCROLL_START)
@:event(feathers.events.ScrollEvent.SCROLL_COMPLETE)
@:access(motion.actuators.SimpleActuator)
class Scroller extends EventDispatcher {
	private static final MINIMUM_VELOCITY = 0.02;

	/**
		A special pointer ID for the mouse.

		@since 1.0.0
	**/
	public static final POINTER_ID_MOUSE = -1000;

	/**
		Creates a new `Scroller` object with the given arguments.

		@since 1.0.0
	**/
	public function new(?target:InteractiveObject) {
		super();
		this.target = target;
	}

	/**
		Determines if the target can be scrolled horizontally (on the x-axis).

		@since 1.0.0
	**/
	public var enabledX = true;

	/**
		Determines if the target can be scrolled vertically (on the y-axis).

		@since 1.0.0
	**/
	public var enabledY = true;

	private var _scrollX:Float = 0.0;

	/**
		The current horizontal scroll position.

		When the value of the `scrollX` property changes, the scroller will
		dispatch an event of type `ScrollEvent.SCROLL`. This event is dispatched
		when other scroll position properties change too.

		@see `feathers.events.ScrollEvent.SCROLL`

		@since 1.0.0
	**/
	@:flash.property
	public var scrollX(get, set):Float;

	private function get_scrollX():Float {
		return this._scrollX;
	}

	private function set_scrollX(value:Float):Float {
		if (this._scrollX == value) {
			return this._scrollX;
		}
		this._scrollX = value;
		ScrollEvent.dispatch(this, ScrollEvent.SCROLL);
		return this._scrollX;
	}

	private var _scrollY:Float = 0.0;

	/**
		The current vertical scroll position.

		When the value of the `scrollY` property changes, the scroller will
		dispatch an event of type `ScrollEvent.SCROLL`. This event is dispatched
		when other scroll position properties change too.

		@see `feathers.events.ScrollEvent.SCROLL`

		@since 1.0.0
	**/
	@:flash.property
	public var scrollY(get, set):Float;

	private function get_scrollY():Float {
		return this._scrollY;
	}

	private function set_scrollY(value:Float):Float {
		if (this._scrollY == value) {
			return this._scrollY;
		}
		this._scrollY = value;
		ScrollEvent.dispatch(this, ScrollEvent.SCROLL);
		return this._scrollY;
	}

	/**
		Setting `restrictedScrollX` will clamp the value to the range between
		`minScrollX` and `maxScrollX`.

		@since 1.0.0
	**/
	public var restrictedScrollX(get, set):Float;

	private function get_restrictedScrollX():Float {
		return this._scrollX;
	}

	private function set_restrictedScrollX(value:Float):Float {
		if (value < this._minScrollX) {
			value = this._minScrollX;
		} else if (value > this._maxScrollX) {
			value = this._maxScrollX;
		}
		if (this._scrollX == value) {
			return this._scrollX;
		}
		this._scrollX = value;
		ScrollEvent.dispatch(this, ScrollEvent.SCROLL);
		return this._scrollX;
	}

	/**
		Setting `restrictedScrollY` will clamp the value to the range  between
		`minScrollY` and `maxScrollY`.

		@since 1.0.0
	**/
	public var restrictedScrollY(get, set):Float;

	private function get_restrictedScrollY():Float {
		return this._scrollY;
	}

	private function set_restrictedScrollY(value:Float):Float {
		if (value < this._minScrollY) {
			value = this._minScrollY;
		} else if (value > this._maxScrollY) {
			value = this._maxScrollY;
		}
		if (this._scrollY == value) {
			return this._scrollY;
		}
		this._scrollY = value;
		ScrollEvent.dispatch(this, ScrollEvent.SCROLL);
		return this._scrollY;
	}

	private var _minScrollX:Float = 0.0;

	/**
		The minimum horizontal scroll position.

		@since 1.0.0
	**/
	@:flash.property
	public var minScrollX(get, never):Float;

	private function get_minScrollX():Float {
		return this._minScrollX;
	}

	private var _minScrollY:Float = 0.0;

	/**
		The minimum vertical scroll position.

		@since 1.0.0
	**/
	@:flash.property
	public var minScrollY(get, never):Float;

	private function get_minScrollY():Float {
		return this._minScrollY;
	}

	private var _maxScrollX:Float = 0.0;

	/**
		The maximum horizontal scroll position.

		@since 1.0.0
	**/
	@:flash.property
	public var maxScrollX(get, never):Float;

	private function get_maxScrollX():Float {
		return this._maxScrollX;
	}

	private var _maxScrollY:Float = 0.0;

	/**
		The maximum vertical scroll position.

		@since 1.0.0
	**/
	@:flash.property
	public var maxScrollY(get, never):Float;

	private function get_maxScrollY():Float {
		return this._maxScrollY;
	}

	private var _visibleWidth:Float = 0.0;

	/**
		The width of the target's scrollable region.

		@default 0.0

		@since 1.0.0
	**/
	@:flash.property
	public var visibleWidth(get, never):Float;

	private function get_visibleWidth():Float {
		return this._visibleWidth;
	}

	private var _visibleHeight:Float = 0.0;

	/**
		The height of the target's scrollable region.

		@default 0.0

		@since 1.0.0
	**/
	@:flash.property
	public var visibleHeight(get, never):Float;

	private function get_visibleHeight():Float {
		return this._visibleHeight;
	}

	private var _contentWidth:Float = 0.0;

	/**
		The width of the target's content. Will not scroll unless the width
		of the content is larger than the width of the target.

		@default 0.0

		@since 1.0.0
	**/
	@:flash.property
	public var contentWidth(get, never):Float;

	private function get_contentWidth():Float {
		return this._contentWidth;
	}

	private var _contentHeight:Float = 0.0;

	/**
		The height of the target's content. Will not scroll unless the height
		of the content is larger than the height of the target.

		@default 0.0

		@since 1.0.0
	**/
	@:flash.property
	public var contentHeight(get, never):Float;

	private function get_contentHeight():Float {
		return this._contentHeight;
	}

	private var _scrolling:Bool = false;

	/**
		Determines if scrolling is currently active.

		@since 1.0.0
	**/
	@:flash.property
	public var scrolling(get, never):Bool;

	private function get_scrolling():Bool {
		return this._scrolling;
	}

	private var _draggingX:Bool = false;

	/**
		Determines if a touch is dragging the target horizontally (on the x-axis).

		@since 1.0.0
	**/
	@:flash.property
	public var draggingX(get, never):Bool;

	private function get_draggingX():Bool {
		return this._draggingX;
	}

	private var _draggingY:Bool = false;

	/**
		Determines if a touch is dragging the target vertically (on the y-axis).

		@since 1.0.0
	**/
	@:flash.property
	public var draggingY(get, never):Bool;

	private function get_draggingY():Bool {
		return this._draggingY;
	}

	/**
		The minimum distance, measured in pixels, that the target must be
		dragged to begin scrolling.

		@default 6.0

		@since 1.0.0
	**/
	public var minDragDistance:Float = 6.0;

	/**
		Determines if the scrolling can go beyond the edges of the viewport and
		snap back to the minimum or maximum when released.

		@default true

		@see `Scroller.elasticity`

		@since 1.0.0
	**/
	public var elasticEdges:Bool = true;

	/**
		Forces elasticity on the top edge, even if the height of the target's
		content is not larger than the width height the target.

		If `elasticEdges` is `false`, this property is ignored.

		@default false

		@see `Scroller.elasticEdges`

		@since 1.0.0
	**/
	public var forceElasticTop:Bool = false;

	/**
		Forces elasticity on the right edge, even if the width of the target's
		content is not larger than the width of the target.

		If `elasticEdges` is `false`, this property is ignored.

		@default false

		@see `Scroller.elasticEdges`

		@since 1.0.0
	**/
	public var forceElasticRight:Bool = false;

	/**
		Forces elasticity on the bottom edge, even if the height of the target's
		content is not larger than the width height the target.

		If `elasticEdges` is `false`, this property is ignored.

		@default false

		@see `Scroller.elasticEdges`

		@since 1.0.0
	**/
	public var forceElasticBottom:Bool = false;

	/**
		Forces elasticity on the left edge, even if the width of the target's
		content is not larger than the width of the target.

		If `elasticEdges` is `false`, this property is ignored.

		@default false

		@see `Scroller.elasticEdges`

		@since 1.0.0
	**/
	public var forceElasticLeft:Bool = false;

	/**
		 If the scroll position goes outside the minimum or maximum bounds when
		the scroller's content is being actively dragged, the scrolling will be
		constrained using this multiplier. A value of `0.0` means that the
		scroller will not go beyond its minimum or maximum bounds. A value of
		`1.0` means that going beyond the minimum or maximum bounds is
		completely unrestrained.

		If `elasticEdges` is `false`, this property is ignored.

		@see Scroller.elasticEdges

		@default 0.33

		@since 1.0.0
	**/
	public var elasticity:Float = 0.33;

	/**
		If the scroll position goes outside the minimum or maximum bounds when
		when the scroller's content is "thrown", the scrolling will be
		constrained using this multiplier. A value of `0.0` means that the
		scroller will not go beyond its minimum or maximum bounds. A value of
		`1.0` means that going beyond the minimum or maximum bounds is
		completely unrestrained.

		If `elasticEdges` is `false`, this property is ignored.

		@see Scroller.elasticEdges
		@see Scroller.elasticity

		@default 0.05

		@since 1.0.0
	**/
	public var throwElasticity:Float = 0.05;

	/**
		The duration, measured in seconds, of the animation when a the scroller
		snaps back to the minimum or maximum position after going out of bounds.

		If `elasticEdges` is `false`, this property is ignored.

		@default 0.5

		@since 1.0.0
	**/
	public var elasticSnapDuration:Float = 0.5;

	/**
		The easing function to use when animating the scroll position.

		@default motion.easing.Quart.easeOut

		@since 1.0.0
	**/
	public var ease:IEasing = Quart.easeOut;

	/**
		The easing function to use when the scroll position goes outside of
		the minimum or maximum edge and bounces back.

		@see `Scroller.ease`

		@since 1.0.0
	**/
	public var bounceEase:IEasing = null;

	/**
		The distance to scroll when the mouse wheel is scrolled horizontally.

		@default 10.0

		@since 1.0.0
	**/
	public var mouseWheelDeltaX:Float = 10.0;

	/**
		The distance to scroll when the mouse wheel is scrolled vertically.

		@default 10.0

		@since 1.0.0
	**/
	public var mouseWheelDeltaY:Float = 10.0;

	/**
		Determines if rotating the mouse wheel vertically changes the `scrollX`
		position instead of `scrollY`.

		@since 1.0.0
	**/
	public var mouseWheelYScrollsX:Bool = false;

	private var _mouseWheelDeltaMode:Int = 1;

	/**
		The duration, measured in seconds, of the animation when scrolling with
		the mouse wheel.

		@default 0.0

		@since 1.0.0
	**/
	public var mouseWheelDuration:Float = 0.0;

	/**
		Determines if mouse events should be treated like touch events.

		@default false

		@since 1.0.0
	**/
	public var simulateTouch:Bool = false;

	private var _decelerationRate:Float = 0.998;

	/**
		This value is used to decelerate the scroller when "thrown". The
		velocity of a throw is multiplied by this value once per millisecond to
		decelerate. A value greater than `0.0` and less than `1.0` is expected.

		@default 0.998

		@since 1.0.0
	**/
	@:flash.property
	public var decelerationRate(get, set):Float;

	private function get_decelerationRate():Float {
		return this._decelerationRate;
	}

	private function set_decelerationRate(value:Float):Float {
		if (this._decelerationRate == value) {
			return this._decelerationRate;
		}
		this._decelerationRate = value;
		this._logDecelerationRate = Math.log(this._decelerationRate);
		this._fixedThrowDuration = -0.1 / Math.log(Math.pow(this._decelerationRate, 1000.0 / 60.0));
		return this._decelerationRate;
	}

	/**
		If not `null`, and the scroller is dragged with touch, the `scrollX`
		position is snapped to the nearest position in the array when the drag
		completes.

		@since 1.0.0
	**/
	public var snapPositionsX:Array<Float> = null;

	/**
		If not `null`, and the scroller is dragged with touch, the `scrollY`
		position is snapped to the nearest position in the array when the drag
		completes.

		@since 1.0.0
	**/
	public var snapPositionsY:Array<Float> = null;

	// this value is precalculated. See the `decelerationRate` setter for the dynamic calculation.
	private var _logDecelerationRate:Float = -0.0020020026706730793;
	private var _fixedThrowDuration:Float = 2.996998998998728;
	private var restoreMouseChildren:Bool = false;
	private var startTouchX:Float = 0.0;
	private var startTouchY:Float = 0.0;
	private var startScrollX:Float = 0.0;
	private var startScrollY:Float = 0.0;
	private var savedScrollMoves:Array<Float> = [];
	private var animateScrollX:SimpleActuator<Dynamic, Dynamic> = null;
	private var animateScrollY:SimpleActuator<Dynamic, Dynamic> = null;
	private var _animateScrollXEase:IEasing = null;
	private var _animateScrollYEase:IEasing = null;
	private var animateScrollXEndRatio:Float = 1.0;
	private var animateScrollYEndRatio:Float = 1.0;
	private var targetScrollX:Float = 0.0;
	private var targetScrollY:Float = 0.0;
	private var snappingToEdge:Bool = false;

	private var _target:InteractiveObject;

	/**
		The container used for scrolling.

		@since 1.0.0
	**/
	@:flash.property
	public var target(get, set):InteractiveObject;

	private function get_target():InteractiveObject {
		return this._target;
	}

	private function set_target(value:InteractiveObject):InteractiveObject {
		if (this._target == value) {
			return this._target;
		}
		if (this._target != null) {
			this.cleanupAfterDrag();
			this._target.removeEventListener(Event.REMOVED_FROM_STAGE, scroller_target_removedFromStageHandler);
			this._target.removeEventListener(MouseEvent.MOUSE_DOWN, scroller_target_mouseDownHandler);
			this._target.removeEventListener(MouseEvent.MOUSE_DOWN, scroller_target_mouseDownCaptureHandler, true);
			this._target.removeEventListener(MouseEvent.MOUSE_WHEEL, scroller_target_mouseWheelHandler);
			#if html5
			var window = cast(Lib.global, js.html.Window);
			window.removeEventListener("wheel", scroller_window_wheelCaptureHandler, {capture: true});
			#end
			this._target.removeEventListener(TouchEvent.TOUCH_BEGIN, scroller_target_touchBeginHandler);
			this._target.removeEventListener(TouchEvent.TOUCH_BEGIN, scroller_target_touchBeginCaptureHandler, true);
			this._target.removeEventListener(MouseEvent.CLICK, scroller_target_clickCaptureHandler, true);
			this._target.removeEventListener(TouchEvent.TOUCH_TAP, scroller_target_touchTapCaptureHandler, true);
		}
		this._target = value;
		if (this._target != null) {
			this._target.addEventListener(MouseEvent.MOUSE_DOWN, scroller_target_mouseDownHandler, false, 0, true);
			this._target.addEventListener(MouseEvent.MOUSE_DOWN, scroller_target_mouseDownCaptureHandler, true, 0, true);
			this._target.addEventListener(MouseEvent.MOUSE_WHEEL, scroller_target_mouseWheelHandler, false, 0, true);
			#if html5
			var window = cast(Lib.global, js.html.Window);
			window.addEventListener("wheel", scroller_window_wheelCaptureHandler, {capture: true});
			#end
			this._target.addEventListener(TouchEvent.TOUCH_BEGIN, scroller_target_touchBeginHandler, false, 0, true);
			this._target.addEventListener(TouchEvent.TOUCH_BEGIN, scroller_target_touchBeginCaptureHandler, true, 0, true);
			this._target.addEventListener(MouseEvent.CLICK, scroller_target_clickCaptureHandler, true, 0, true);
			#if (openfl >= "9.0.0")
			this._target.addEventListener(TouchEvent.TOUCH_TAP, scroller_target_touchTapCaptureHandler, true, 0, true);
			#end
		}
		return this._target;
	}

	private var _previousPointerID:Int = -1;
	private var _pointerID:Int = -1;

	/**
		The pointer that is currently dragging the scroll target. Returns `-1`
		if no pointer is currently associated with the drag.
	**/
	@:flash.property
	public var pointerID(get, never):Int;

	private function get_pointerID():Int {
		return this._pointerID;
	}

	/**
		Updates the dimensions of both the target and its content.

		@since 1.0.0
	**/
	public function setDimensions(?visibleWidth:Null<Float>, ?visibleHeight:Null<Float>, ?contentWidth:Null<Float>, ?contentHeight:Null<Float>):Void {
		this._visibleWidth = visibleWidth != null ? visibleWidth : 0.0;
		this._visibleHeight = visibleHeight != null ? visibleHeight : 0.0;
		this._contentWidth = contentWidth != null ? contentWidth : 0.0;
		this._contentHeight = contentHeight != null ? contentHeight : 0.0;
		this.calculateMinAndMax();
	}

	/**
		Applies the `minScrollX` and `maxScrollX` restrictions to the current
		`scrollX`, and applies the `minScrollY` and `maxScrollY` restrictions to
		the current `scrollY`.

		@since 1.0.0
	**/
	public function applyScrollRestrictions():Void {
		var scrollChanged = false;
		if (this._scrollX < this._minScrollX) {
			this._scrollX = this._minScrollX;
			scrollChanged = true;
		} else if (this._scrollX > this._maxScrollX) {
			this._scrollX = this._maxScrollX;
			scrollChanged = true;
		}
		if (this._scrollY < this._minScrollY) {
			this._scrollY = this._minScrollY;
			scrollChanged = true;
		} else if (this._scrollY > this._maxScrollY) {
			this._scrollY = this._maxScrollY;
			scrollChanged = true;
		}
		if (scrollChanged) {
			ScrollEvent.dispatch(this, ScrollEvent.SCROLL);
		}
	}

	/**
		Immediately stops any animation that affects the scrolling.

		@since 1.0.0
	**/
	public function stop():Void {
		if (this.animateScrollX != null) {
			Actuate.stop(this.animateScrollX, null, false, false);
			this.animateScrollX = null;
			this._animateScrollXEase = null;
		}
		if (this.animateScrollY != null) {
			Actuate.stop(this.animateScrollY, null, false, false);
			this.animateScrollY = null;
			this._animateScrollYEase = null;
		}
		this.cleanupAfterDrag();
		this._draggingX = false;
		this._draggingY = false;
		this.completeScroll();
	}

	/**
		Immediately throws the scroller to the specified position, with optional
		animation. If you want to throw in only one direction, pass in `null`
		for the value that you do not want to change.

		@since 1.0.0
	**/
	public function throwTo(scrollX:Null<Float>, scrollY:Null<Float>, duration:Null<Float> = null, ease:IEasing = null):Void {
		if (duration == null) {
			duration = this._fixedThrowDuration;
		}
		if (ease == null) {
			ease = this.ease;
		}
		var scrollChanged = false;
		if (scrollX != null) {
			if (this.animateScrollX != null) {
				Actuate.stop(this.animateScrollX, null, false, false);
				this.animateScrollX = null;
				this._animateScrollXEase = null;
			}
			if (this._scrollX != scrollX) {
				scrollChanged = true;
				this.startScroll();
				if (duration == 0.0) {
					// use the setter
					this.scrollX = scrollX;
				} else {
					this.startScrollX = this._scrollX;
					this.targetScrollX = scrollX;
					this._animateScrollXEase = ease;
					var tween = Actuate.update((scrollX:Float) -> {
						if (scrollX == null && this._scrollX != null && this.targetScrollX != null) {
							// workaround for jgranick/actuate#108
							scrollX = this.targetScrollX;
						}
						// use the setter
						this.scrollX = scrollX;
					}, duration, [this._scrollX], [this.targetScrollX], true);
					this.animateScrollX = cast(tween, SimpleActuator<Dynamic, Dynamic>);
					this.animateScrollX.ease(this._animateScrollXEase);
					this.animateScrollX.onComplete(this.animateScrollX_onComplete);
					this.refreshAnimateScrollXEndRatio();
				}
			} else {
				this.finishScrollX();
			}
		}
		if (scrollY != null) {
			if (this.animateScrollY != null) {
				Actuate.stop(this.animateScrollY, null, false, false);
				this.animateScrollY = null;
				this._animateScrollYEase = null;
			}
			if (this._scrollY != scrollY) {
				scrollChanged = true;
				this.startScroll();
				if (duration == 0.0) {
					// use the setter
					this.scrollY = scrollY;
				} else {
					this.startScrollY = this._scrollY;
					this.targetScrollY = scrollY;
					this._animateScrollYEase = ease;
					var tween = Actuate.update((scrollY:Float) -> {
						if (scrollY == null && this._scrollY != null && this.targetScrollY != null) {
							// workaround for jgranick/actuate#108
							scrollY = this.targetScrollY;
						}
						// use the setter
						this.scrollY = scrollY;
					}, duration, [this._scrollY], [this.targetScrollY], true);
					this.animateScrollY = cast(tween, SimpleActuator<Dynamic, Dynamic>);
					this.animateScrollY.ease(this._animateScrollYEase);
					this.animateScrollY.onComplete(this.animateScrollY_onComplete);
					this.refreshAnimateScrollYEndRatio();
				}
			} else {
				this.finishScrollY();
			}
		}
		if (scrollChanged && duration == 0.0) {
			this.completeScroll();
		}
	}

	private function throwWithVelocity(velocityX:Null<Float>, velocityY:Null<Float>):Void {
		var targetX:Null<Float> = null;
		var targetY:Null<Float> = null;
		if (velocityX != null) {
			if (Math.abs(velocityX) <= MINIMUM_VELOCITY) {
				this.finishScrollX();
			} else if (this.snapPositionsX != null) {
				for (i in 0...this.snapPositionsX.length) {
					var posX = this.snapPositionsX[i];
					if (velocityX < 0.0) {
						targetX = posX;
						if (posX > this._scrollX) {
							break;
						}
					}
					if (velocityX > 0.0) {
						targetX = (i == 0) ? posX : this.snapPositionsX[i - 1];
						if (posX >= this._scrollX) {
							break;
						}
					}
				}
			} else {
				targetX = this._scrollX + this.calculateDistanceFromVelocity(velocityX);
			}
		}
		if (velocityY != null) {
			if (Math.abs(velocityY) <= MINIMUM_VELOCITY) {
				this.finishScrollY();
			} else if (this.snapPositionsY != null) {
				for (i in 0...this.snapPositionsY.length) {
					var posY = this.snapPositionsY[i];
					if (velocityY < 0.0) {
						targetY = posY;
						if (posY > this._scrollY) {
							break;
						}
					}
					if (velocityY > 0.0) {
						targetY = (i == 0) ? posY : this.snapPositionsY[i - 1];
						if (posY >= this._scrollY) {
							break;
						}
					}
				}
			} else {
				targetY = this._scrollY + this.calculateDistanceFromVelocity(velocityY);
			}
		}
		this.throwTo(targetX, targetY, this._fixedThrowDuration);
	}

	private function calculateDistanceFromVelocity(velocity:Float):Float {
		return (velocity - MINIMUM_VELOCITY) / this._logDecelerationRate;
	}

	private function refreshAnimateScrollXEndRatio():Void {
		var distance = Math.abs(this.targetScrollX - this.startScrollX);
		var ratioOutOfBounds = 0.0;
		if (this.targetScrollX > this._maxScrollX) {
			ratioOutOfBounds = (this.targetScrollX - this._maxScrollX) / distance;
		} else if (this.targetScrollX < this._minScrollX) {
			ratioOutOfBounds = (this._minScrollX - this.targetScrollX) / distance;
		}
		if (ratioOutOfBounds > 0.0) {
			if (this.elasticEdges) {
				this.animateScrollXEndRatio = (1.0 - ratioOutOfBounds) + (ratioOutOfBounds * this.throwElasticity);
			} else {
				this.animateScrollXEndRatio = 1.0 - ratioOutOfBounds;
			}
		} else {
			this.animateScrollXEndRatio = 1.0;
		}
		if (this.animateScrollX != null) {
			if (this.animateScrollXEndRatio < 1.0) {
				this.animateScrollX.onUpdate(this.animateScrollX_endRatio_onUpdate);
			} else {
				this.animateScrollX.onUpdate(null);
			}
		}
	}

	private function refreshAnimateScrollYEndRatio():Void {
		var distance = Math.abs(this.targetScrollY - this.startScrollY);
		var ratioOutOfBounds = 0.0;
		if (this.targetScrollY > this._maxScrollY) {
			ratioOutOfBounds = (this.targetScrollY - this._maxScrollY) / distance;
		} else if (this.targetScrollY < this._minScrollY) {
			ratioOutOfBounds = (this._minScrollY - this.targetScrollY) / distance;
		}
		if (ratioOutOfBounds > 0.0) {
			if (this.elasticEdges) {
				this.animateScrollYEndRatio = (1.0 - ratioOutOfBounds) + (ratioOutOfBounds * this.throwElasticity);
			} else {
				this.animateScrollYEndRatio = 1.0 - ratioOutOfBounds;
			}
		} else {
			this.animateScrollYEndRatio = 1.0;
		}
		if (this.animateScrollY != null) {
			if (this.animateScrollYEndRatio < 1.0) {
				this.animateScrollY.onUpdate(this.animateScrollY_endRatio_onUpdate);
			} else {
				this.animateScrollY.onUpdate(null);
			}
		}
	}

	private function calculateMinAndMax():Void {
		var oldMinScrollX = this._minScrollX;
		var oldMaxScrollX = this._maxScrollX;
		var oldMinScrollY = this._minScrollY;
		var oldMaxScrollY = this._maxScrollY;
		this._minScrollX = 0.0;
		this._minScrollY = 0.0;
		this._maxScrollX = Math.max(this._contentWidth, this._visibleWidth) - this._visibleWidth;
		this._maxScrollY = Math.max(this._contentHeight, this._visibleHeight) - this._visibleHeight;
		if (oldMinScrollX != this._minScrollX || oldMaxScrollX != this._maxScrollX) {
			this.refreshAnimateScrollXEndRatio();
		}
		if (oldMinScrollY != this._minScrollY || oldMaxScrollY != this._maxScrollY) {
			this.refreshAnimateScrollYEndRatio();
		}
	}

	private function startScroll():Void {
		if (this._scrolling) {
			return;
		}
		this._scrolling = true;
		if ((this._target is DisplayObjectContainer)) {
			var container = cast(this._target, DisplayObjectContainer);
			this.restoreMouseChildren = container.mouseChildren;
			container.mouseChildren = false;
		}
		ScrollEvent.dispatch(this, ScrollEvent.SCROLL_START);
	}

	private function completeScroll():Void {
		if (!this._scrolling || this._draggingX || this._draggingY || this.animateScrollX != null || this.animateScrollY != null) {
			return;
		}
		this._scrolling = false;
		if ((this._target is DisplayObjectContainer)) {
			var container = cast(this._target, DisplayObjectContainer);
			container.mouseChildren = this.restoreMouseChildren;
		}
		ScrollEvent.dispatch(this, ScrollEvent.SCROLL_COMPLETE);
	}

	private function finishScrollX():Void {
		this._draggingX = false;

		var targetScrollX:Null<Float> = null;
		if (this.snapPositionsX != null) {
			var minOffsetX = Math.POSITIVE_INFINITY;
			for (snapX in this.snapPositionsX) {
				var offsetX = Math.abs(snapX - this._scrollX);
				if (minOffsetX > offsetX) {
					minOffsetX = offsetX;
					targetScrollX = snapX;
				}
			}
			if (targetScrollX == this._scrollX) {
				targetScrollX = null;
			}
		}
		if (this._scrollX < this._minScrollX) {
			targetScrollX = this._minScrollX;
		} else if (this._scrollX > this._maxScrollX) {
			targetScrollX = this._maxScrollX;
		}

		if (targetScrollX == null) {
			this.completeScroll();
		} else {
			this.throwTo(targetScrollX, null, this.elasticSnapDuration, this.bounceEase);
		}
	}

	private function finishScrollY():Void {
		this._draggingY = false;

		var targetScrollY:Null<Float> = null;
		if (this.snapPositionsY != null) {
			var minOffsetY = Math.POSITIVE_INFINITY;
			for (snapY in this.snapPositionsY) {
				var offsetY = Math.abs(snapY - this._scrollY);
				if (minOffsetY > offsetY) {
					minOffsetY = offsetY;
					targetScrollY = snapY;
				}
			}
			if (targetScrollY == this._scrollY) {
				targetScrollY = null;
			}
		}
		if (this._scrollY < this._minScrollY) {
			targetScrollY = this._minScrollY;
		} else if (this._scrollY > this._maxScrollY) {
			targetScrollY = this._maxScrollY;
		}

		if (targetScrollY == null) {
			this.completeScroll();
		} else {
			this.throwTo(null, targetScrollY, this.elasticSnapDuration, this.bounceEase);
		}
	}

	private function animateScrollX_endRatio_onUpdate():Void {
		var time = (openfl.Lib.getTimer() / 1000.0);
		var currentTime = time - this.animateScrollX.startTime;
		var ratio = currentTime / this.animateScrollX.duration;
		ratio = this._animateScrollXEase.calculate(ratio);
		if (ratio >= this.animateScrollXEndRatio && currentTime < this.animateScrollX.duration) {
			// check that the currentTime is less than totalTime because if
			// the tween is complete, we don't want it set to null before
			// the onComplete callback
			if (!this.elasticEdges) {
				if (this._scrollX < this._minScrollX) {
					// use the setter
					this.scrollX = this._minScrollX;
				} else if (this._scrollX > this._maxScrollX) {
					// use the setter
					this.scrollX = this._maxScrollX;
				}
			}
			Actuate.stop(this.animateScrollX, null, false, false);
			this.animateScrollX = null;
			this._animateScrollXEase = null;
			this.finishScrollX();
			return;
		}
	}

	private function animateScrollX_onComplete():Void {
		this.animateScrollX = null;
		this._animateScrollXEase = null;
		this.finishScrollX();
	}

	private function animateScrollY_endRatio_onUpdate():Void {
		var time = (openfl.Lib.getTimer() / 1000.0);
		var currentTime = time - this.animateScrollY.startTime;
		var ratio = currentTime / this.animateScrollY.duration;
		ratio = this._animateScrollYEase.calculate(ratio);
		if (ratio >= this.animateScrollYEndRatio && currentTime < this.animateScrollY.duration) {
			// check that the currentTime is less than totalTime because if
			// the tween is complete, we don't want it set to null before
			// the onComplete callback
			if (!this.elasticEdges) {
				if (this._scrollY < this._minScrollY) {
					// use the setter
					this.scrollY = this._minScrollY;
				} else if (this._scrollY > this._maxScrollY) {
					// use the setter
					this.scrollY = this._maxScrollY;
				}
			}
			Actuate.stop(this.animateScrollY, null, false, false);
			this.animateScrollY = null;
			this._animateScrollYEase = null;
			this.finishScrollY();
			return;
		}
	}

	private function animateScrollY_onComplete():Void {
		this.animateScrollY = null;
		this._animateScrollYEase = null;
		this.finishScrollY();
	}

	private function cleanupAfterDrag():Void {
		if (this._pointerID == -1) {
			return;
		}
		this._previousPointerID = this._scrolling ? this._pointerID : -1;
		this._pointerID = -1;
		this._target.removeEventListener(Event.REMOVED_FROM_STAGE, scroller_target_removedFromStageHandler);
		if (this._target.stage != null) {
			this._target.stage.removeEventListener(MouseEvent.MOUSE_MOVE, scroller_target_stage_mouseMoveHandler);
			this._target.stage.removeEventListener(MouseEvent.MOUSE_UP, scroller_target_stage_mouseUpHandler);
			this._target.stage.removeEventListener(TouchEvent.TOUCH_MOVE, scroller_target_stage_touchMoveHandler);
			this._target.stage.removeEventListener(TouchEvent.TOUCH_END, scroller_target_stage_touchEndHandler);
		}
	}

	private function scroller_target_removedFromStageHandler(event:Event):Void {
		this.cleanupAfterDrag();
	}

	private function touchBegin(touchPointID:Int, stageX:Float, stageY:Float, ?simulatedTouch:Bool):Void {
		if (simulatedTouch && !this.simulateTouch) {
			return;
		}
		if (this._pointerID != -1) {
			// we already have an active touch, and we can only accept one
			return;
		}
		// if we're animating already, stop it
		if (this.animateScrollX != null) {
			Actuate.stop(this.animateScrollX, null, false, false);
			this.animateScrollX = null;
			this._animateScrollXEase = null;
		}
		if (this.animateScrollY != null) {
			Actuate.stop(this.animateScrollY, null, false, false);
			this.animateScrollY = null;
			this._animateScrollYEase = null;
		}

		this._target.addEventListener(Event.REMOVED_FROM_STAGE, scroller_target_removedFromStageHandler, false, 0, true);
		this._target.stage.addEventListener(MouseEvent.MOUSE_MOVE, scroller_target_stage_mouseMoveHandler, false, 0, true);
		this._target.stage.addEventListener(MouseEvent.MOUSE_UP, scroller_target_stage_mouseUpHandler, false, 0, true);
		this._target.stage.addEventListener(TouchEvent.TOUCH_MOVE, scroller_target_stage_touchMoveHandler, false, 0, true);
		this._target.stage.addEventListener(TouchEvent.TOUCH_END, scroller_target_stage_touchEndHandler, false, 0, true);
		if ((this._target is DisplayObjectContainer)) {
			var container = cast(this._target, DisplayObjectContainer);
			// if we were already scrolling, disable the pointer immediately.
			// otherwise, wait until dragging starts
			if (this._scrolling) {
				container.mouseChildren = false;
			}
		}
		this._previousPointerID = -1;
		this._pointerID = touchPointID;
		this.startTouchX = stageX;
		this.startTouchY = stageY;
		this.startScrollX = this._scrollX;
		this.startScrollY = this._scrollY;
		this.savedScrollMoves.resize(0);
	}

	private function touchMove(touchPointID:Int, stageX:Float, stageY:Float):Void {
		if (this._pointerID != touchPointID) {
			return;
		}

		var touchOffsetX = stageX - this.startTouchX;
		var touchOffsetY = stageY - this.startTouchY;
		var scaleX = 1.0;
		var scaleY = 1.0;
		var current = this._target;
		while (current != current.stage) {
			scaleX /= current.scaleX;
			scaleY /= current.scaleY;
			current = current.parent;
		}
		touchOffsetX *= scaleX;
		touchOffsetY *= scaleY;

		var canDragX = this.canDragX();
		var canDragY = this.canDragY();
		if (!this._draggingX && canDragX && Math.abs(touchOffsetX) > this.minDragDistance) {
			this.startTouchX = stageX;
			touchOffsetX = 0.0;
			this._draggingX = true;
			// don't start dragging until we've moved a minimum distance
			// we'll also reset the start position at this point, so that there
			// isn't a sudden jump
			if (!this._draggingY) {
				this.startScroll();
				if (this._pointerID == -1) {
					// cancelled externally by SCROLL_START listener
					return;
				}
			}
		}
		if (!this._draggingY && canDragY && Math.abs(touchOffsetY) > this.minDragDistance) {
			this.startTouchY = stageY;
			touchOffsetY = 0.0;
			this._draggingY = true;
			if (!this._draggingX) {
				this.startScroll();
				if (this._pointerID == -1) {
					// cancelled externally by SCROLL_START listener
					return;
				}
			}
		}

		if (!this._draggingX && !this._draggingY) {
			return;
		}

		var scrollX = this.startScrollX;
		if (canDragX) {
			scrollX -= touchOffsetX;
			if (this.elasticEdges) {
				var minElasticScrollX = this._minScrollX;
				if (minElasticScrollX > this.startScrollX) {
					minElasticScrollX = this.startScrollX;
				}
				var maxElasticScrollX = this._maxScrollX;
				if (maxElasticScrollX < this.startScrollX) {
					maxElasticScrollX = this.startScrollX;
				}
				if (scrollX < this._minScrollX) {
					if (this._maxScrollX > this._minScrollX || this.forceElasticLeft) {
						scrollX = scrollX - (scrollX - minElasticScrollX) * (1.0 - this.elasticity);
					} else {
						// not elastic
						scrollX = this._minScrollX;
					}
				} else if (scrollX > this._maxScrollX) {
					if (this._maxScrollX > this._minScrollX || this.forceElasticRight) {
						scrollX = scrollX - (scrollX - maxElasticScrollX) * (1.0 - this.elasticity);
					} else {
						// not elastic
						scrollX = this._maxScrollX;
					}
				}
			} else {
				// not elastic
				if (scrollX < this._minScrollX) {
					scrollX = this._minScrollX;
				} else if (scrollX > this._maxScrollX) {
					scrollX = this._maxScrollX;
				}
			}
		}
		var scrollY = this.startScrollY;
		if (canDragY) {
			scrollY -= touchOffsetY;
			if (this.elasticEdges) {
				var minElasticScrollY = this._minScrollY;
				if (minElasticScrollY > this.startScrollY) {
					minElasticScrollY = this.startScrollY;
				}
				var maxElasticScrollY = this._maxScrollY;
				if (maxElasticScrollY < this.startScrollY) {
					maxElasticScrollY = this.startScrollY;
				}
				if (scrollY < this._minScrollY) {
					if (this._maxScrollY > this._minScrollY || this.forceElasticTop) {
						scrollY = scrollY - (scrollY - minElasticScrollY) * (1.0 - this.elasticity);
					} else {
						// not elastic
						scrollY = this._minScrollY;
					}
				} else if (scrollY > this._maxScrollY) {
					if (this._maxScrollY > this._minScrollY || this.forceElasticBottom) {
						scrollY = scrollY - (scrollY - maxElasticScrollY) * (1.0 - this.elasticity);
					} else {
						// not elastic
						scrollY = this._maxScrollY;
					}
				}
			} else {
				// not elastic
				if (scrollY < this._minScrollY) {
					scrollY = this._minScrollY;
				} else if (scrollY > this._maxScrollY) {
					scrollY = this._maxScrollY;
				}
			}
		}

		this.scrollX = scrollX;
		this.scrollY = scrollY;

		if (this.savedScrollMoves.length > 60) {
			this.savedScrollMoves.resize(30);
		}

		this.savedScrollMoves.push(scrollX);
		this.savedScrollMoves.push(scrollY);
		this.savedScrollMoves.push(openfl.Lib.getTimer());
	}

	private function touchEnd(touchPointID:Int):Void {
		if (this._pointerID != touchPointID) {
			return;
		}

		this.cleanupAfterDrag();

		var finishingX = !this.canDragX();
		var finishingY = !this.canDragY();
		if (this._scrollX < this._minScrollX || this._scrollX > this._maxScrollX) {
			finishingX = true;
			this.finishScrollX();
		}
		if (this._scrollY < this._minScrollY || this._scrollY > this._maxScrollY) {
			finishingY = true;
			this.finishScrollY();
		}

		if (finishingX && finishingY) {
			return;
		}

		if (!this._draggingX && !this._draggingY) {
			return;
		}

		// find scroll position measured 100ms ago, if possible
		var targetTime = openfl.Lib.getTimer() - 100;
		var endIndex = this.savedScrollMoves.length - 1;
		var startIndex = endIndex;
		var i = endIndex;
		while (endIndex > 0 && this.savedScrollMoves[i] > targetTime) {
			startIndex = i;
			i -= 3;
		}

		// the scroll position hasn't changed, so don't scroll
		if (startIndex == endIndex) {
			if (!finishingX && this._draggingX) {
				this.finishScrollX();
			}
			if (!finishingY && this._draggingY) {
				this.finishScrollY();
			}
			return;
		}

		var timeOffset = this.savedScrollMoves[endIndex] - this.savedScrollMoves[startIndex];
		var velocityX:Null<Float> = null;
		var velocityY:Null<Float> = null;
		// while it's unlikely to happen, it's not impossible that the time
		// offset ends up being zero. if we divide by zero, the velocity is
		// infinity, which is bad, so skip it.
		if (timeOffset > 0.0) {
			if (!finishingX && this._draggingX) {
				var movedX = this._scrollX - this.savedScrollMoves[startIndex - 2];
				velocityX = -movedX / timeOffset;
			}
			if (!finishingY && this._draggingY) {
				var movedY = this._scrollY - this.savedScrollMoves[startIndex - 1];
				velocityY = -movedY / timeOffset;
			}
		}
		if (velocityX != null || velocityY != null) {
			this.throwWithVelocity(velocityX, velocityY);
		}
		if (velocityX == null && this._draggingX) {
			this.finishScrollX();
		}
		if (velocityY == null && this._draggingY) {
			this.finishScrollY();
		}
	}

	private function canDragX():Bool {
		return this.enabledX && (this._maxScrollX > this._minScrollX || this.forceElasticLeft || this.forceElasticRight);
	}

	private function canDragY():Bool {
		return this.enabledY && (this._maxScrollY > this._minScrollY || this.forceElasticTop || this.forceElasticBottom);
	}

	private function scroller_target_touchBeginCaptureHandler(event:TouchEvent):Void {
		if (!this._scrolling) {
			return;
		}
		event.stopImmediatePropagation();
		this.scroller_target_touchBeginHandler(event);
	}

	private function scroller_target_touchBeginHandler(event:TouchEvent):Void {
		if (this.simulateTouch && event.isPrimaryTouchPoint #if air && Multitouch.mapTouchToMouse #end) {
			// ignore the primary one because MouseEvent.MOUSE_DOWN will catch it
			return;
		}
		this.touchBegin(event.touchPointID, event.stageX, event.stageY);
	}

	private function scroller_target_mouseDownCaptureHandler(event:MouseEvent):Void {
		if (!this._scrolling) {
			return;
		}
		event.stopImmediatePropagation();
		this.scroller_target_mouseDownHandler(event);
	}

	private function scroller_target_mouseDownHandler(event:MouseEvent):Void {
		var stage = this._target.stage;
		if (stage == null) {
			return;
		}
		this.touchBegin(POINTER_ID_MOUSE, stage.mouseX, stage.mouseY, true);
	}

	private function scroller_target_stage_touchMoveHandler(event:TouchEvent):Void {
		this.touchMove(event.touchPointID, event.stageX, event.stageY);
	}

	private function scroller_target_stage_mouseMoveHandler(event:MouseEvent):Void {
		var stage = cast(event.currentTarget, Stage);
		this.touchMove(POINTER_ID_MOUSE, stage.mouseX, stage.mouseY);
	}

	private function scroller_target_stage_touchEndHandler(event:TouchEvent):Void {
		this.touchEnd(event.touchPointID);
	}

	private function scroller_target_clickCaptureHandler(event:MouseEvent):Void {
		if (this._previousPointerID == -1) {
			return;
		}
		this._previousPointerID = -1;
		event.stopImmediatePropagation();
	}

	private function scroller_target_touchTapCaptureHandler(event:TouchEvent):Void {
		if (this._previousPointerID != event.touchPointID) {
			return;
		}
		if (event.isPrimaryTouchPoint #if air && Multitouch.mapTouchToMouse #end) {
			// ignore the primary one because MouseEvent.CLICK will catch it
			this._previousPointerID = POINTER_ID_MOUSE;
			return;
		}
		this._previousPointerID = -1;
		event.stopImmediatePropagation();
	}

	private function scroller_target_stage_mouseUpHandler(event:MouseEvent):Void {
		this.touchEnd(POINTER_ID_MOUSE);
	}

	#if html5
	private function scroller_window_wheelCaptureHandler(event:WheelEvent):Void {
		this._mouseWheelDeltaMode = event.deltaMode;
	}
	#end

	private function scroller_target_mouseWheelHandler(event:MouseEvent):Void {
		if (this._scrolling) {
			// if we're already scrolling, we need to handle the event, even
			// if the position doesn't technically change

			// can't use preventDefault(), so don't let it bubble
			event.stopImmediatePropagation();
			this.stop();
		}
		var deltaLines = event.delta;
		switch (this._mouseWheelDeltaMode) {
			case 0: // pixels
				deltaLines = Std.int(deltaLines / 40);
			case 2: // pages
				deltaLines = deltaLines * 16;
		}
		var newScrollX:Null<Float> = null;
		var newScrollY:Null<Float> = null;
		if (this.mouseWheelYScrollsX) {
			var targetScrollX = this._scrollX;
			if (this.animateScrollX != null) {
				targetScrollX = this.targetScrollX;
			}
			newScrollX = targetScrollX - (deltaLines * this.mouseWheelDeltaX);
			if (newScrollX < this._minScrollX) {
				newScrollX = this._minScrollX;
			} else if (newScrollX > this._maxScrollX) {
				newScrollX = this._maxScrollX;
			}
		} else {
			var targetScrollY = this._scrollY;
			if (this.animateScrollY != null) {
				targetScrollY = this.targetScrollY;
			}
			newScrollY = targetScrollY - (deltaLines * this.mouseWheelDeltaY);
			if (newScrollY < this._minScrollY) {
				newScrollY = this._minScrollY;
			} else if (newScrollY > this._maxScrollY) {
				newScrollY = this._maxScrollY;
			}
		}
		if ((newScrollX == null || newScrollX == this._scrollX) && (newScrollY == null || newScrollY == this._scrollY)) {
			return;
		}
		if (!this._scrolling) {
			// if we weren't scrolling before, we are now
			event.stopImmediatePropagation();
			this.stop();
		}
		if (newScrollX != null) {
			this._draggingX = true;
		}
		if (newScrollY != null) {
			this._draggingY = true;
		}
		if (this.mouseWheelDuration > 0.0) {
			this.throwTo(newScrollX, newScrollY, this.mouseWheelDuration, this.ease);
		} else {
			this.startScroll();
			// use the setters
			if (newScrollX != null) {
				this.scrollX = newScrollX;
			}
			if (newScrollY != null) {
				this.scrollY = newScrollY;
			}
			this._draggingX = false;
			this._draggingY = false;
			this.completeScroll();
		}
	}
}

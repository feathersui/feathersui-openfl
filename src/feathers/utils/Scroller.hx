/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.utils;

import feathers.events.ScrollEvent;
import motion.Actuate;
import motion.actuators.SimpleActuator;
import motion.easing.IEasing;
import motion.easing.Quart;
import openfl.Lib;
import openfl.display.DisplayObjectContainer;
import openfl.display.InteractiveObject;
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

	@since 1.0.0
**/
@:access(motion.actuators.SimpleActuator)
class Scroller extends EventDispatcher {
	private static final MINIMUM_VELOCITY = 0.02;
	private static final TOUCH_ID_MOUSE = -1000;

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
	public var enabledX(default, default) = true;

	/**
		Determines if the target can be scrolled vertically (on the y-axis).

		@since 1.0.0
	**/
	public var enabledY(default, default) = true;

	/**
		The current horizontal scroll position.

		When the value of the `scrollX` property changes, the scroller will
		dispatch an event of type `ScrollEvent.SCROLL`. This event is dispatched
		when other scroll position properties change too.

		@see `feathers.events.ScrollEvent.SCROLL`

		@since 1.0.0
	**/
	public var scrollX(default, set):Float = 0.0;

	private function set_scrollX(value:Float):Float {
		if (this.scrollX == value) {
			return this.scrollX;
		}
		this.scrollX = value;
		ScrollEvent.dispatch(this, ScrollEvent.SCROLL);
		return this.scrollX;
	}

	/**
		The current vertical scroll position.

		When the value of the `scrollY` property changes, the scroller will
		dispatch an event of type `ScrollEvent.SCROLL`. This event is dispatched
		when other scroll position properties change too.

		@see `feathers.events.ScrollEvent.SCROLL`

		@since 1.0.0
	**/
	public var scrollY(default, set):Float = 0.0;

	private function set_scrollY(value:Float):Float {
		if (this.scrollY == value) {
			return this.scrollY;
		}
		this.scrollY = value;
		ScrollEvent.dispatch(this, ScrollEvent.SCROLL);
		return this.scrollY;
	}

	/**
		The minimum horizontal scroll position.

		@since 1.0.0
	**/
	public var minScrollX(default, null):Float = 0.0;

	/**
		The minimum vertical scroll position.

		@since 1.0.0
	**/
	public var minScrollY(default, null):Float = 0.0;

	/**
		The maximum horizontal scroll position.

		@since 1.0.0
	**/
	public var maxScrollX(default, null):Float = 0.0;

	/**
		The maximum vertical scroll position.

		@since 1.0.0
	**/
	public var maxScrollY(default, null):Float = 0.0;

	/**
		The width of the target's scrollable region.

		@default 0.0

		@since 1.0.0
	**/
	public var visibleWidth(default, null):Float = 0.0;

	/**
		The height of the target's scrollable region.

		@default 0.0

		@since 1.0.0
	**/
	public var visibleHeight(default, null):Float = 0.0;

	/**
		The width of the target's content. Will not scroll unless the width
		of the content is larger than the width of the target.

		@default 0.0

		@since 1.0.0
	**/
	public var contentWidth(default, null):Float = 0.0;

	/**
		The height of the target's content. Will not scroll unless the height
		of the content is larger than the height of the target.

		@default 0.0

		@since 1.0.0
	**/
	public var contentHeight(default, null):Float = 0.0;

	/**
		Determines if scrolling is currently active.

		@since 1.0.0
	**/
	public var scrolling(default, null):Bool = false;

	/**
		Determines if a touch is dragging the target horizontally (on the x-axis).

		@since 1.0.0
	**/
	public var draggingX(default, null):Bool = false;

	/**
		Determines if a touch is dragging the target vertically (on the y-axis).

		@since 1.0.0
	**/
	public var draggingY(default, null):Bool = false;

	/**
		The minimum distance, measured in pixels, that the target must be
		dragged to begin scrolling.

		@default 6.0

		@since 1.0.0
	**/
	public var minDragDistance(default, default):Float = 6.0;

	/**
		Determines if the scrolling can go beyond the edges of the viewport and
		snap back to the minimum or maximum when released.

		@default true

		@see `Scroller.elasticity`

		@since 1.0.0
	**/
	public var elasticEdges(default, default):Bool = true;

	/**
		Forces elasticity on the top edge, even if the height of the target's
		content is not larger than the width height the target.

		If `elasticEdges` is `false`, this property is ignored.

		@default false

		@see `Scroller.elasticEdges`

		@since 1.0.0
	**/
	public var forceElasticTop(default, default):Bool = false;

	/**
		Forces elasticity on the right edge, even if the width of the target's
		content is not larger than the width of the target.

		If `elasticEdges` is `false`, this property is ignored.

		@default false

		@see `Scroller.elasticEdges`

		@since 1.0.0
	**/
	public var forceElasticRight(default, default):Bool = false;

	/**
		Forces elasticity on the bottom edge, even if the height of the target's
		content is not larger than the width height the target.

		If `elasticEdges` is `false`, this property is ignored.

		@default false

		@see `Scroller.elasticEdges`

		@since 1.0.0
	**/
	public var forceElasticBottom(default, default):Bool = false;

	/**
		Forces elasticity on the left edge, even if the width of the target's
		content is not larger than the width of the target.

		If `elasticEdges` is `false`, this property is ignored.

		@default false

		@see `Scroller.elasticEdges`

		@since 1.0.0
	**/
	public var forceElasticLeft(default, default):Bool = false;

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
	public var elasticity(default, default):Float = 0.33;

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
	public var throwElasticity(default, default):Float = 0.05;

	/**
		The duration, measured in seconds, of the animation when a the scroller
		snaps back to the minimum or maximum position after going out of bounds.

		If `elasticEdges` is `false`, this property is ignored.

		@default 0.5

		@since 1.0.0
	**/
	public var elasticSnapDuration(default, default):Float = 0.5;

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
		The distance to scroll when the mouse wheel is scrolled.

		@default 10.0

		@since 1.0.0
	**/
	public var mouseWheelDelta:Float = 10.0;

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

	/**
		This value is used to decelerate the scroller when "thrown". The
		velocity of a throw is multiplied by this value once per millisecond to
		decelerate. A value greater than `0.0` and less than `1.0` is expected.

		@default 0.998

		@since 1.0.0
	**/
	public var decelerationRate(default, set):Float = 0.998;

	private function set_decelerationRate(value:Float):Float {
		if (this.decelerationRate == value) {
			return this.decelerationRate;
		}
		this.decelerationRate = value;
		this._logDecelerationRate = Math.log(this.decelerationRate);
		this._fixedThrowDuration = -0.1 / Math.log(Math.pow(this.decelerationRate, 1000.0 / 60.0));
		return this.decelerationRate;
	}

	// this value is precalculated. See the `decelerationRate` setter for the dynamic calculation.
	private var _logDecelerationRate:Float = -0.0020020026706730793;
	private var _fixedThrowDuration:Float = 2.996998998998728;
	private var restoreMouseChildren:Bool = false;
	private var touchPointID:Int = -1;
	private var previousTouchPointID:Int = -1;
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

	/**
		The container used for scrolling.

		@since 1.0.0
	**/
	public var target(default, set):InteractiveObject;

	private function set_target(value:InteractiveObject):InteractiveObject {
		if (this.target == value) {
			return this.target;
		}
		if (this.target != null) {
			this.cleanupAfterDrag();
			this.target.removeEventListener(Event.REMOVED_FROM_STAGE, target_removedFromStageHandler);
			this.target.removeEventListener(MouseEvent.MOUSE_DOWN, target_mouseDownHandler);
			this.target.removeEventListener(MouseEvent.MOUSE_DOWN, target_mouseDownCaptureHandler, true);
			this.target.removeEventListener(MouseEvent.MOUSE_WHEEL, target_mouseWheelHandler);
			#if html5
			var window = cast(Lib.global, js.html.Window);
			window.removeEventListener("wheel", window_wheelCaptureHandler, {capture: true});
			#end
			this.target.removeEventListener(TouchEvent.TOUCH_BEGIN, target_touchBeginHandler);
			this.target.removeEventListener(TouchEvent.TOUCH_BEGIN, target_touchBeginCaptureHandler, true);
			this.target.removeEventListener(MouseEvent.CLICK, target_clickCaptureHandler, true);
			this.target.removeEventListener(TouchEvent.TOUCH_TAP, target_touchTapCaptureHandler, true);
		}
		this.target = value;
		if (this.target != null) {
			this.target.addEventListener(MouseEvent.MOUSE_DOWN, target_mouseDownHandler, false, 0, true);
			this.target.addEventListener(MouseEvent.MOUSE_DOWN, target_mouseDownCaptureHandler, true, 0, true);
			this.target.addEventListener(MouseEvent.MOUSE_WHEEL, target_mouseWheelHandler, false, 0, true);
			#if html5
			var window = cast(Lib.global, js.html.Window);
			window.addEventListener("wheel", window_wheelCaptureHandler, {capture: true});
			#end
			this.target.addEventListener(TouchEvent.TOUCH_BEGIN, target_touchBeginHandler, false, 0, true);
			this.target.addEventListener(TouchEvent.TOUCH_BEGIN, target_touchBeginCaptureHandler, true, 0, true);
			this.target.addEventListener(MouseEvent.CLICK, target_clickCaptureHandler, true, 0, true);
			// TODO: temporarily disabled until isPrimaryTouchPoint bug is fixed
			// See commit: 43d659b6afa822873ded523395e2a2a1a4567a50
			// this.target.addEventListener(TouchEvent.TOUCH_TAP, target_touchTapCaptureHandler, true, 0, true);
		}
		return this.target;
	}

	/**
		Updates the dimensions of both the target and its content.

		@since 1.0.0
	**/
	public function setDimensions(?visibleWidth:Null<Float>, ?visibleHeight:Null<Float>, ?contentWidth:Null<Float>, ?contentHeight:Null<Float>):Void {
		this.visibleWidth = visibleWidth != null ? visibleWidth : 0.0;
		this.visibleHeight = visibleHeight != null ? visibleHeight : 0.0;
		this.contentWidth = contentWidth != null ? contentWidth : 0.0;
		this.contentHeight = contentHeight != null ? contentHeight : 0.0;
		this.calculateMinAndMax();
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
		this.draggingX = false;
		this.draggingY = false;
		this.completeScroll();
	}

	private function throwWithVelocity(velocityX:Null<Float>, velocityY:Null<Float>):Void {
		var targetX:Null<Float> = null;
		var targetY:Null<Float> = null;
		if (velocityX != null) {
			if (Math.abs(velocityX) <= MINIMUM_VELOCITY) {
				this.finishScrollX();
			} else {
				targetX = this.scrollX + this.calculateDistanceFromVelocity(velocityX);
			}
		}
		if (velocityY != null) {
			if (Math.abs(velocityY) <= MINIMUM_VELOCITY) {
				this.finishScrollY();
			} else {
				targetY = this.scrollY + this.calculateDistanceFromVelocity(velocityY);
			}
		}
		this.throwTo(targetX, targetY, this._fixedThrowDuration);
	}

	private function calculateDistanceFromVelocity(velocity:Float):Float {
		return (velocity - MINIMUM_VELOCITY) / this._logDecelerationRate;
	}

	/**
		Immediately throws the scroller to the specified position, with optional
		animation. If you want to throw in only one direction, pass in `null`
		for the value that you do not want to change.
	**/
	private function throwTo(scrollX:Null<Float>, scrollY:Null<Float>, duration:Null<Float> = null, ease:IEasing = null):Void {
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
			if (this.scrollX != scrollX) {
				scrollChanged = true;
				this.startScroll();
				if (duration == 0) {
					this.scrollX = scrollX;
				} else {
					this.startScrollX = this.scrollX;
					this.targetScrollX = scrollX;
					this._animateScrollXEase = ease;
					var tween = Actuate.update((scrollX : Float) -> {
						this.scrollX = scrollX;
					}, duration, [this.scrollX], [this.targetScrollX], true);
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
			if (this.scrollY != scrollY) {
				scrollChanged = true;
				this.startScroll();
				if (duration == 0) {
					this.scrollY = scrollY;
				} else {
					this.startScrollY = this.scrollY;
					this.targetScrollY = scrollY;
					this._animateScrollYEase = ease;
					var tween = Actuate.update((scrollY : Float) -> {
						this.scrollY = scrollY;
					}, duration, [this.scrollY], [this.targetScrollY], true);
					this.animateScrollY = cast(tween, SimpleActuator<Dynamic, Dynamic>);
					this.animateScrollY.ease(this._animateScrollYEase);
					this.animateScrollY.onComplete(this.animateScrollY_onComplete);
					this.refreshAnimateScrollYEndRatio();
				}
			} else {
				this.finishScrollY();
			}
		}
		if (scrollChanged && duration == 0) {
			this.completeScroll();
		}
	}

	private function refreshAnimateScrollXEndRatio():Void {
		var distance = Math.abs(this.targetScrollX - this.startScrollX);
		var ratioOutOfBounds = 0.0;
		if (this.targetScrollX > this.maxScrollX) {
			ratioOutOfBounds = (this.targetScrollX - this.maxScrollX) / distance;
		} else if (this.targetScrollX < this.minScrollX) {
			ratioOutOfBounds = (this.minScrollX - this.targetScrollX) / distance;
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
		if (this.targetScrollY > this.maxScrollY) {
			ratioOutOfBounds = (this.targetScrollY - this.maxScrollY) / distance;
		} else if (this.targetScrollY < this.minScrollY) {
			ratioOutOfBounds = (this.minScrollY - this.targetScrollY) / distance;
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
		var oldMaxScrollX = this.maxScrollX;
		var oldMaxScrollY = this.maxScrollY;
		this.minScrollX = 0.0;
		this.minScrollY = 0.0;
		this.maxScrollX = Math.max(this.contentWidth, this.visibleWidth) - this.visibleWidth;
		this.maxScrollY = Math.max(this.contentHeight, this.visibleHeight) - this.visibleHeight;
		if (oldMaxScrollX != this.maxScrollX) {
			this.refreshAnimateScrollXEndRatio();
		}
		if (oldMaxScrollY != this.maxScrollY) {
			this.refreshAnimateScrollYEndRatio();
		}
	}

	private function startScroll():Void {
		if (this.scrolling) {
			return;
		}
		this.scrolling = true;
		if (Std.is(this.target, DisplayObjectContainer)) {
			var container = cast(this.target, DisplayObjectContainer);
			this.restoreMouseChildren = container.mouseChildren;
			container.mouseChildren = false;
		}
		ScrollEvent.dispatch(this, ScrollEvent.SCROLL_START);
	}

	private function completeScroll():Void {
		if (!this.scrolling || this.draggingX || this.draggingY || this.animateScrollX != null || this.animateScrollY != null) {
			return;
		}
		this.scrolling = false;
		if (Std.is(this.target, DisplayObjectContainer)) {
			var container = cast(this.target, DisplayObjectContainer);
			container.mouseChildren = this.restoreMouseChildren;
		}
		ScrollEvent.dispatch(this, ScrollEvent.SCROLL_COMPLETE);
	}

	private function finishScrollX():Void {
		this.draggingX = false;

		var targetScrollX:Null<Float> = null;
		if (this.scrollX < this.minScrollX) {
			targetScrollX = this.minScrollX;
		} else if (this.scrollX > this.maxScrollX) {
			targetScrollX = this.maxScrollX;
		}

		if (targetScrollX == null) {
			this.completeScroll();
		} else {
			this.throwTo(targetScrollX, null, this.elasticSnapDuration, this.bounceEase);
		}
	}

	private function finishScrollY():Void {
		this.draggingY = false;

		var targetScrollY:Null<Float> = null;
		if (this.scrollY < this.minScrollY) {
			targetScrollY = this.minScrollY;
		} else if (this.scrollY > this.maxScrollY) {
			targetScrollY = this.maxScrollY;
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
				if (this.scrollX < this.minScrollX) {
					this.scrollX = this.minScrollX;
				} else if (this.scrollX > this.maxScrollX) {
					this.scrollX = this.maxScrollX;
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
				if (this.scrollY < this.minScrollY) {
					this.scrollY = this.minScrollY;
				} else if (this.scrollY > this.maxScrollY) {
					this.scrollY = this.maxScrollY;
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
		if (this.touchPointID == -1) {
			return;
		}
		this.previousTouchPointID = this.scrolling ? this.touchPointID : -1;
		this.touchPointID = -1;
		this.target.removeEventListener(Event.REMOVED_FROM_STAGE, target_removedFromStageHandler);
		if (this.target.stage != null) {
			this.target.stage.removeEventListener(MouseEvent.MOUSE_MOVE, target_stage_mouseMoveHandler);
			this.target.stage.removeEventListener(MouseEvent.MOUSE_UP, target_stage_mouseUpHandler);
			this.target.stage.removeEventListener(TouchEvent.TOUCH_MOVE, target_stage_touchMoveHandler);
			this.target.stage.removeEventListener(TouchEvent.TOUCH_END, target_stage_touchEndHandler);
		}
	}

	private function target_removedFromStageHandler(event:Event):Void {
		this.cleanupAfterDrag();
	}

	private function touchBegin(touchPointID:Int, stageX:Float, stageY:Float, ?simulatedTouch:Bool):Void {
		if (simulatedTouch && !this.simulateTouch) {
			return;
		}
		if (this.touchPointID != -1) {
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

		this.target.addEventListener(Event.REMOVED_FROM_STAGE, target_removedFromStageHandler, false, 0, true);
		this.target.stage.addEventListener(MouseEvent.MOUSE_MOVE, target_stage_mouseMoveHandler, false, 0, true);
		this.target.stage.addEventListener(MouseEvent.MOUSE_UP, target_stage_mouseUpHandler, false, 0, true);
		this.target.stage.addEventListener(TouchEvent.TOUCH_MOVE, target_stage_touchMoveHandler, false, 0, true);
		this.target.stage.addEventListener(TouchEvent.TOUCH_END, target_stage_touchEndHandler, false, 0, true);
		if (Std.is(this.target, DisplayObjectContainer)) {
			var container = cast(this.target, DisplayObjectContainer);
			// if we were already scrolling, disable the pointer immediately.
			// otherwise, wait until dragging starts
			if (this.scrolling) {
				container.mouseChildren = false;
			}
		}
		this.previousTouchPointID = -1;
		this.touchPointID = touchPointID;
		this.startTouchX = stageX;
		this.startTouchY = stageY;
		this.startScrollX = this.scrollX;
		this.startScrollY = this.scrollY;
		this.savedScrollMoves = [];
	}

	private function touchMove(touchPointID:Int, stageX:Float, stageY:Float):Void {
		if (this.touchPointID != touchPointID) {
			return;
		}

		var touchOffsetX = stageX - this.startTouchX;
		var touchOffsetY = stageY - this.startTouchY;
		var scaleX = 1.0;
		var scaleY = 1.0;
		var current = this.target;
		while (current != current.stage) {
			scaleX /= current.scaleX;
			scaleY /= current.scaleY;
			current = current.parent;
		}
		touchOffsetX *= scaleX;
		touchOffsetY *= scaleY;

		var canDragX = this.canDragX();
		var canDragY = this.canDragY();
		if (!this.draggingX && canDragX && Math.abs(touchOffsetX) > this.minDragDistance) {
			this.startTouchX = stageX;
			touchOffsetX = 0.0;
			this.draggingX = true;
			// don't start dragging until we've moved a minimum distance
			// we'll also reset the start position at this point, so that there
			// isn't a sudden jump
			if (!this.draggingY) {
				this.startScroll();
			}
		}
		if (!this.draggingY && canDragY && Math.abs(touchOffsetY) > this.minDragDistance) {
			this.startTouchY = stageY;
			touchOffsetY = 0.0;
			this.draggingY = true;
			if (!this.draggingX) {
				this.startScroll();
			}
		}

		if (!this.draggingX && !this.draggingY) {
			return;
		}

		var scrollX = this.startScrollX;
		if (canDragX) {
			scrollX -= touchOffsetX;
			if (this.elasticEdges) {
				if (scrollX < this.minScrollX) {
					if (this.maxScrollX > this.minScrollX || this.forceElasticLeft) {
						scrollX = scrollX - (scrollX - this.minScrollX) * (1.0 - this.elasticity);
					} else {
						scrollX = this.minScrollX;
					}
				} else if (scrollX > this.maxScrollX) {
					if (this.maxScrollX > this.minScrollX || this.forceElasticRight) {
						scrollX = scrollX - (scrollX - this.maxScrollX) * (1.0 - this.elasticity);
					} else {
						scrollX = this.maxScrollX;
					}
				}
			} else {
				if (scrollX < this.minScrollX) {
					scrollX = this.minScrollX;
				} else if (scrollX > this.maxScrollX) {
					scrollX = this.maxScrollX;
				}
			}
		}
		var scrollY = this.startScrollY;
		if (canDragY) {
			scrollY -= touchOffsetY;
			if (this.elasticEdges) {
				if (scrollY < this.minScrollY) {
					if (this.maxScrollY > this.minScrollY || this.forceElasticTop) {
						scrollY = scrollY - (scrollY - this.minScrollY) * (1.0 - this.elasticity);
					} else {
						scrollY = this.minScrollY;
					}
				} else if (scrollY > this.maxScrollY) {
					if (this.maxScrollY > this.minScrollY || this.forceElasticBottom) {
						scrollY = scrollY - (scrollY - this.maxScrollY) * (1.0 - this.elasticity);
					} else {
						scrollY = this.maxScrollY;
					}
				}
			} else {
				if (scrollY < this.minScrollY) {
					scrollY = this.minScrollY;
				} else if (scrollY > this.maxScrollY) {
					scrollY = this.maxScrollY;
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
		if (this.touchPointID != touchPointID) {
			return;
		}

		this.cleanupAfterDrag();

		var finishingX = !this.canDragX();
		var finishingY = !this.canDragY();
		if (this.scrollX < this.minScrollX || this.scrollX > this.maxScrollX) {
			finishingX = true;
			this.finishScrollX();
		}
		if (this.scrollY < this.minScrollY || this.scrollY > this.maxScrollY) {
			finishingY = true;
			this.finishScrollY();
		}

		if (finishingX && finishingY) {
			return;
		}

		if (!this.draggingX && !this.draggingY) {
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
			if (!finishingX && this.draggingX) {
				this.finishScrollX();
			}
			if (!finishingY && this.draggingY) {
				this.finishScrollY();
			}
			return;
		}

		var timeOffset = this.savedScrollMoves[endIndex] - this.savedScrollMoves[startIndex];
		var velocityX:Null<Float> = null;
		var velocityY:Null<Float> = null;
		if (!finishingX && this.draggingX) {
			var movedX = this.scrollX - this.savedScrollMoves[startIndex - 2];
			velocityX = -movedX / timeOffset;
		}
		if (!finishingY && this.draggingY) {
			var movedY = this.scrollY - this.savedScrollMoves[startIndex - 1];
			velocityY = -movedY / timeOffset;
		}

		if (velocityX != null || velocityY != null) {
			this.throwWithVelocity(velocityX, velocityY);
		}
		if (velocityX == null && this.draggingX) {
			this.finishScrollX();
		}
		if (velocityY == null && this.draggingY) {
			this.draggingY = false;
			this.finishScrollY();
		}
	}

	private function canDragX():Bool {
		return this.enabledX && (this.maxScrollX > this.minScrollX || this.forceElasticLeft || this.forceElasticRight);
	}

	private function canDragY():Bool {
		return this.enabledY && (this.maxScrollY > this.minScrollY || this.forceElasticTop || this.forceElasticBottom);
	}

	private function target_touchBeginCaptureHandler(event:TouchEvent):Void {
		if (!this.scrolling) {
			return;
		}
		event.stopImmediatePropagation();
		this.target_touchBeginHandler(event);
	}

	private function target_touchBeginHandler(event:TouchEvent):Void {
		this.touchBegin(event.touchPointID, event.stageX, event.stageY);
	}

	private function target_mouseDownCaptureHandler(event:MouseEvent):Void {
		if (!this.scrolling) {
			return;
		}
		event.stopImmediatePropagation();
		this.target_mouseDownHandler(event);
	}

	private function target_mouseDownHandler(event:MouseEvent):Void {
		this.touchBegin(TOUCH_ID_MOUSE, event.stageX, event.stageY, true);
	}

	private function target_stage_touchMoveHandler(event:TouchEvent):Void {
		this.touchMove(event.touchPointID, event.stageX, event.stageY);
	}

	private function target_stage_mouseMoveHandler(event:MouseEvent):Void {
		this.touchMove(TOUCH_ID_MOUSE, event.stageX, event.stageY);
	}

	private function target_stage_touchEndHandler(event:TouchEvent):Void {
		this.touchEnd(event.touchPointID);
	}

	private function target_clickCaptureHandler(event:MouseEvent):Void {
		if (this.previousTouchPointID == -1) {
			return;
		}
		this.previousTouchPointID = -1;
		event.stopImmediatePropagation();
	}

	private function target_touchTapCaptureHandler(event:TouchEvent):Void {
		if (this.previousTouchPointID != event.touchPointID) {
			return;
		}
		if (event.isPrimaryTouchPoint #if air && Multitouch.mapTouchToMouse #end) {
			// ignore the primary one because MouseEvent.CLICK will catch it
			this.previousTouchPointID = TOUCH_ID_MOUSE;
			return;
		}
		this.previousTouchPointID = -1;
		event.stopImmediatePropagation();
	}

	private function target_stage_mouseUpHandler(event:MouseEvent):Void {
		this.touchEnd(TOUCH_ID_MOUSE);
	}

	#if html5
	private function window_wheelCaptureHandler(event:WheelEvent):Void {
		this._mouseWheelDeltaMode = event.deltaMode;
	}
	#end

	private function target_mouseWheelHandler(event:MouseEvent):Void {
		// can't use preventDefault(), so don't let it bubble
		var targetScrollY = this.scrollY;
		if (this.animateScrollY != null) {
			targetScrollY = this.targetScrollY;
		}
		event.stopImmediatePropagation();
		this.stop();
		var deltaLines = event.delta;
		switch (this._mouseWheelDeltaMode) {
			case 0: // pixels
				deltaLines = Std.int(deltaLines / 40);
			case 2: // pages
				deltaLines = deltaLines * 16;
		}
		var newScrollY = targetScrollY - (deltaLines * this.mouseWheelDelta);
		if (newScrollY < this.minScrollY) {
			newScrollY = this.minScrollY;
		} else if (newScrollY > this.maxScrollY) {
			newScrollY = this.maxScrollY;
		}
		if (this.scrollY == newScrollY) {
			return;
		}
		if (this.mouseWheelDuration > 0.0) {
			this.throwTo(null, newScrollY, this.mouseWheelDuration, this.ease);
		} else {
			this.scrollY = newScrollY;
		}
	}
}

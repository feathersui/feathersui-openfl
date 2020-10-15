/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.utils;

import feathers.events.FeathersEvent;
import feathers.layout.RelativePosition;
import motion.Actuate;
import motion.actuators.SimpleActuator;
import motion.easing.IEasing;
import motion.easing.Quart;
import openfl.display.DisplayObjectContainer;
import openfl.display.InteractiveObject;
import openfl.errors.ArgumentError;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
import openfl.geom.Point;
#if air
import openfl.ui.Multitouch;
#end

@:event(openfl.events.Event.OPEN)
@:event(openfl.events.Event.CLOSE)
@:event(feathers.events.FeathersEvent.OPENING)
@:event(feathers.events.FeathersEvent.CLOSING)
@:event(openfl.events.Event.CANCEL)
@:event(openfl.events.Event.CHANGE)

/**
	Utility that provides a pull gesture with touch events.

	@since 1.0.0
**/
class EdgePuller extends EventDispatcher {
	private static final MINIMUM_VELOCITY = 0.02;
	private static final TOUCH_ID_MOUSE = -1000;

	/**
		Creates a new `EdgePuller` object with the given arguments.

		@since 1.0.0
	**/
	public function new(?target:InteractiveObject, pullableEdge:RelativePosition = LEFT, maxPullDistance:Null<Float> = null) {
		super();
		this.target = target;
		this.pullableEdge = pullableEdge;
		this.maxPullDistance = maxPullDistance;
	}

	/**
		Determines if the target can be pulled or not.

		@since 1.0.0
	**/
	public var enabled:Bool = true;

	private var _active:Bool = false;

	/**
		Determines if the pull gesture is active.

		@since 1.0.0
	**/
	@:flash.property
	public var active(get, never):Bool;

	private function get_active():Bool {
		return this._active;
	}

	private var _dragging:Bool = false;

	/**
		Determines if a touch is currently dragging the target.

		@since 1.0.0
	**/
	@:flash.property
	public var dragging(get, never):Bool;

	private function get_dragging():Bool {
		return this._dragging;
	}

	/**
		The minimum distance, measured in pixels, that the target must be
		dragged to begin a pull gesture.

		@default 6.0

		@since 1.0.0
	**/
	public var minDragDistance:Float = 6.0;

	/**
		The easing function to use when animating the pull distance.

		@default motion.easing.Quart.easeOut

		@since 1.0.0
	**/
	public var ease:IEasing = Quart.easeOut;

	/**
		Determines if mouse events should be treated like touch events.

		@default false

		@since 1.0.0
	**/
	public var simulateTouch:Bool = false;

	private var _target:InteractiveObject;

	/**
		The target used for detecting pull gestures.

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
			this._target.removeEventListener(MouseEvent.MOUSE_DOWN, edgePuller_target_mouseDownHandler);
			this._target.removeEventListener(MouseEvent.MOUSE_DOWN, edgePuller_target_mouseDownCaptureHandler, true);
			this._target.removeEventListener(TouchEvent.TOUCH_BEGIN, edgePuller_target_touchBeginHandler);
			this._target.removeEventListener(TouchEvent.TOUCH_BEGIN, edgePuller_target_touchBeginCaptureHandler, true);
			this._target.removeEventListener(Event.ADDED_TO_STAGE, edgePuller_target_addedToStageHandler);
			this._target.removeEventListener(Event.REMOVED_FROM_STAGE, edgePuller_target_removedFromStageHandler);
			this.removeStageEvents();
		}
		this._target = value;
		if (this._target != null) {
			this._target.addEventListener(MouseEvent.MOUSE_DOWN, edgePuller_target_mouseDownHandler, false, 0, true);
			this._target.addEventListener(MouseEvent.MOUSE_DOWN, edgePuller_target_mouseDownCaptureHandler, true, 0, true);
			this._target.addEventListener(TouchEvent.TOUCH_BEGIN, edgePuller_target_touchBeginHandler, false, 0, true);
			this._target.addEventListener(TouchEvent.TOUCH_BEGIN, edgePuller_target_touchBeginCaptureHandler, true, 0, true);
			this._target.addEventListener(Event.ADDED_TO_STAGE, edgePuller_target_addedToStageHandler, false, 0, true);
			this._target.addEventListener(Event.REMOVED_FROM_STAGE, edgePuller_target_removedFromStageHandler, false, 0, true);
			this.addStageEvents();
		}
		return this._target;
	}

	private var _maxPullDistance:Null<Float> = null;

	/**
		The maximum distance the edge of the `target` may be pulled, measured in
		pixels. If `null`, the maximum pull distance will be equal to the full
		size of the `target`.

		@see `EdgePuller.pullDistance`

		@since 1.0.0
	**/
	@:flash.property
	public var maxPullDistance(get, set):Null<Float>;

	private function get_maxPullDistance():Null<Float> {
		return this._maxPullDistance;
	}

	private function set_maxPullDistance(value:Null<Float>):Null<Float> {
		if (this._maxPullDistance == value) {
			return this._maxPullDistance;
		}
		this._maxPullDistance = value;
		return this._maxPullDistance;
	}

	private var _pullDistance:Float = 0.0;

	/**
		The current distance that the edge has been pulled, from `0.0` to
		`maxPullDistance`, measured in pixels.

		@see `EdgePuller.maxPullDistance`

		@since 1.0.0
	**/
	@:flash.property
	public var pullDistance(get, never):Float;

	private function get_pullDistance():Float {
		return this._pullDistance;
	}

	private var _activeBorderSize:Null<Float> = null;

	/**
		The size, measured in pixels, of the active border where the pull
		gesture may begin. If `null`, the full bounds of the target may start
		a pull gesture.

		@since 1.0.0
	**/
	@:flash.property
	public var activeBorderSize(get, set):Null<Float>;

	private function get_activeBorderSize():Null<Float> {
		return this._activeBorderSize;
	}

	private function set_activeBorderSize(value:Null<Float>):Null<Float> {
		if (this._activeBorderSize == value) {
			return this._activeBorderSize;
		}
		this._activeBorderSize = value;
		return this._activeBorderSize;
	}

	private var _pullableEdge:RelativePosition = RelativePosition.LEFT;

	/**
		The edge of the target where the pull originates.

		@default `feathers.layout.RelativePosition.LEFT`

		@since 1.0.0
	**/
	@:flash.property
	public var pullableEdge(get, set):RelativePosition;

	private function get_pullableEdge():RelativePosition {
		return this._pullableEdge;
	}

	private function set_pullableEdge(value:RelativePosition):RelativePosition {
		if (this._pullableEdge == value) {
			return this._pullableEdge;
		}
		this._pullableEdge = value;
		return this._pullableEdge;
	}

	private var _pendingOpened:Null<Bool> = null;

	private var _opened:Bool = false;

	/**
		Indicates if the pull gesture is in the open position.

		@since 1.0.0
	**/
	@:flash.property
	public var opened(get, set):Bool;

	private function get_opened():Bool {
		if (this._pendingOpened != null) {
			return this._pendingOpened;
		}
		return this._opened;
	}

	private function set_opened(value:Bool):Bool {
		if (this._pendingOpened != null) {
			if (this._pendingOpened == value) {
				return this._pendingOpened;
			}
		} else if (this._opened == value) {
			return this._opened;
		}
		this._pendingOpened = value;
		if (this._pendingOpened) {
			this.throwTo(this.getMaxPullDistance());
		} else {
			this.throwTo(0.0);
		}
		return this._pendingOpened;
	}

	private var _snapDuration:Float = 0.5;

	/**
		The duration of the snap animation, measured in seconds.

		@default 0.5
	**/
	@:flash.property
	public var snapDuration(get, set):Float;

	private function get_snapDuration():Float {
		return this._snapDuration;
	}

	private function set_snapDuration(value:Float):Float {
		if (this._snapDuration == value) {
			return this._snapDuration;
		}
		this._snapDuration = value;
		return this._snapDuration;
	}

	private var _pointerID:Int = -1;

	/**
		The pointer that is currently dragging the target. Returns `-1`
		if no pointer is currently associated with the drag.
	**/
	@:flash.property
	public var pointerID(get, never):Int;

	private function get_pointerID():Int {
		return this._pointerID;
	}

	private var _restoreMouseChildren:Bool = false;
	private var _startTouch:Float = 0.0;
	private var _startPullDistance:Float = 0.0;
	private var _targetPullDistance:Float = 0.0;
	private var _savedTouchMoves:Array<Float> = [];
	private var _animatePull:SimpleActuator<Dynamic, Dynamic> = null;

	private function setOpened(value:Bool):Bool {
		this._pendingOpened = null;
		if (this._opened == value) {
			return this._opened;
		}
		this._opened = value;
		if (this._opened) {
			FeathersEvent.dispatch(this, Event.OPEN);
		} else {
			FeathersEvent.dispatch(this, Event.CLOSE);
		}
		return this._opened;
	}

	private function setPullDistance(value:Float):Float {
		if (this._pullDistance == value) {
			return this._pullDistance;
		}
		this._pullDistance = value;
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._pullDistance;
	}

	private function getMaxPullDistance():Float {
		if (this._maxPullDistance != null) {
			return this._maxPullDistance;
		}
		return switch (this._pullableEdge) {
			case TOP: this._target.height;
			case RIGHT: this._target.width;
			case BOTTOM: this._target.height;
			case LEFT: this._target.width;
			default:
				throw new ArgumentError("Unknown pullable edge position: " + this._pullableEdge);
		};
	}

	private function getTouchPosition(stageX:Float, stageY:Float):Float {
		return switch (this._pullableEdge) {
			case TOP: stageY;
			case RIGHT: stageX;
			case BOTTOM: stageY;
			case LEFT: stageX;
			default:
				throw new ArgumentError("Unknown pullable edge position: " + this._pullableEdge);
		};
	}

	private function getTouchScale():Float {
		return switch (this._pullableEdge) {
			case TOP: DisplayUtil.getConcatenatedScaleY(this._target);
			case RIGHT: DisplayUtil.getConcatenatedScaleX(this._target);
			case BOTTOM: DisplayUtil.getConcatenatedScaleY(this._target);
			case LEFT: DisplayUtil.getConcatenatedScaleX(this._target);
			default:
				throw new ArgumentError("Unknown pullable edge position: " + this._pullableEdge);
		};
	}

	private function isInActiveBorder(stageX:Float, stageY:Float, activeBorderSize:Float):Bool {
		var point = new Point(stageX, stageY);
		point = this._target.globalToLocal(point);
		return switch (this._pullableEdge) {
			case TOP: point.y >= 0.0 && point.y < activeBorderSize;
			case RIGHT: point.x >= (this._target.width - activeBorderSize) && point.x < this._target.width;
			case BOTTOM: point.y >= (this._target.height - activeBorderSize) && point.y < this._target.height;
			case LEFT: point.x >= 0.0 && point.x < activeBorderSize;
			default:
				throw new ArgumentError("Unknown pullable edge position: " + this._pullableEdge);
		};
	}

	private function checkMinDrag(touchOffset:Float):Bool {
		if (this._opened) {
			return switch (this._pullableEdge) {
				case TOP: touchOffset < -this.minDragDistance;
				case RIGHT: touchOffset > this.minDragDistance;
				case BOTTOM: touchOffset > this.minDragDistance;
				case LEFT: touchOffset < -this.minDragDistance;
				default:
					throw new ArgumentError("Unknown pullable edge position: " + this._pullableEdge);
			};
		}
		return switch (this._pullableEdge) {
			case TOP: touchOffset > this.minDragDistance;
			case RIGHT: touchOffset < -this.minDragDistance;
			case BOTTOM: touchOffset < -this.minDragDistance;
			case LEFT: touchOffset > this.minDragDistance;
			default:
				throw new ArgumentError("Unknown pullable edge position: " + this._pullableEdge);
		};
	}

	private function touchBegin(touchPointID:Int, stageX:Float, stageY:Float, ?simulatedTouch:Bool):Void {
		if (!this.enabled) {
			return;
		}
		if (simulatedTouch && !this.simulateTouch) {
			return;
		}
		if (this._pointerID != -1) {
			// we already have an active touch, and we can only accept one
			return;
		}

		if (!this._opened && this._activeBorderSize != null) {
			if (!this.isInActiveBorder(stageX, stageY, this._activeBorderSize)) {
				return;
			}
		}

		// if we're animating already, stop it
		if (this._animatePull != null) {
			Actuate.stop(this._animatePull, null, false, false);
			this._animatePull = null;
		}

		this._target.stage.addEventListener(MouseEvent.MOUSE_MOVE, edgePuller_target_stage_mouseMoveHandler, false, 0, true);
		this._target.stage.addEventListener(MouseEvent.MOUSE_UP, edgePuller_target_stage_mouseUpHandler, false, 0, true);
		this._target.stage.addEventListener(TouchEvent.TOUCH_MOVE, edgePuller_target_stage_touchMoveHandler, false, 0, true);
		this._target.stage.addEventListener(TouchEvent.TOUCH_END, edgePuller_target_stage_touchEndHandler, false, 0, true);
		if (Std.is(this._target, DisplayObjectContainer)) {
			var container = cast(this._target, DisplayObjectContainer);
			// if we were already scrolling, disable the pointer immediately.
			// otherwise, wait until dragging starts
			if (this._active) {
				container.mouseChildren = false;
			}
		}
		this._pendingOpened = null;
		this._pointerID = touchPointID;
		this._startTouch = this.getTouchPosition(stageX, stageY);
		this._startPullDistance = this._pullDistance;
		this._savedTouchMoves.resize(0);
	}

	private function touchMove(touchPointID:Int, stageX:Float, stageY:Float):Void {
		if (this._opened && this._pointerID == -1) {
			return;
		}
		if (this._pointerID != touchPointID) {
			return;
		}

		var touchPosition = this.getTouchPosition(stageX, stageY);
		var touchOffset = touchPosition - this._startTouch;
		var touchScale = this.getTouchScale();
		touchOffset *= touchScale;

		if (!this._dragging && this.enabled && this.checkMinDrag(touchOffset)) {
			this._startTouch = touchPosition;
			touchOffset = 0.0;
			this._dragging = this.startPull();
			// don't start dragging until we've moved a minimum distance
			// we'll also reset the start position at this point, so that there
			// isn't a sudden jump
		}

		if (!this._dragging) {
			return;
		}

		var maxPullDistance = this.getMaxPullDistance();
		var pullDistance = this._startPullDistance;
		if (this._pullableEdge == RIGHT || this._pullableEdge == BOTTOM) {
			pullDistance -= touchOffset;
		} else {
			pullDistance += touchOffset;
		}
		if (pullDistance < 0.0) {
			pullDistance = 0.0;
		} else if (pullDistance > maxPullDistance) {
			pullDistance = maxPullDistance;
		}

		this.setPullDistance(pullDistance);

		if (this._savedTouchMoves.length > 60) {
			this._savedTouchMoves.resize(30);
		}

		this._savedTouchMoves.push(pullDistance);
		this._savedTouchMoves.push(openfl.Lib.getTimer());
	}

	private function touchEnd(touchPointID:Int):Void {
		if (this._pointerID != touchPointID) {
			return;
		}

		this.cleanupAfterDrag();

		if (!this._dragging) {
			return;
		}

		// find scroll position measured 100ms ago, if possible
		var targetTime = openfl.Lib.getTimer() - 100;
		var endIndex = this._savedTouchMoves.length - 1;
		var startIndex = endIndex;
		var i = endIndex;
		while (endIndex > 0 && this._savedTouchMoves[i] > targetTime) {
			startIndex = i;
			i -= 2;
		}

		var velocity = 0.0;
		if (this._dragging && startIndex != endIndex) {
			var timeOffset = this._savedTouchMoves[endIndex] - this._savedTouchMoves[startIndex];
			var moved = this._pullDistance - this._savedTouchMoves[startIndex - 1];
			velocity = moved / timeOffset;
		}

		if (velocity != 0.0 || this._dragging) {
			this.throwWithVelocity(velocity);
		} else {
			this.completeDrag();
		}
	}

	private function startPull():Bool {
		if (this._active) {
			// already active, and that's fine
			return true;
		}
		this._active = true;
		var result = true;
		if (this._opened) {
			result = FeathersEvent.dispatch(this, FeathersEvent.CLOSING, false, true);
		} else {
			result = FeathersEvent.dispatch(this, FeathersEvent.OPENING, false, true);
		}
		if (!result) {
			this._active = false;
			this._dragging = false;
			this.cleanupAfterDrag();
			return false;
		}
		if (Std.is(this._target, DisplayObjectContainer)) {
			var container = cast(this._target, DisplayObjectContainer);
			this._restoreMouseChildren = container.mouseChildren;
			container.mouseChildren = false;
		}
		FeathersEvent.dispatch(this, Event.CHANGE);
		return true;
	}

	private function completeDrag():Void {
		this._dragging = false;
		this.completePull();
	}

	private function completePull():Void {
		if (!this._active || this._dragging || this._animatePull != null) {
			return;
		}
		this._active = false;
		if (Std.is(this._target, DisplayObjectContainer)) {
			var container = cast(this._target, DisplayObjectContainer);
			container.mouseChildren = this._restoreMouseChildren;
		}
		var oldOpened = this._opened;
		var newOpened = this._pullDistance != 0.0;
		this.setOpened(newOpened);
		if (newOpened == oldOpened) {
			FeathersEvent.dispatch(this, Event.CANCEL);
		}
	}

	private function addStageEvents():Void {
		if (this._target == null || this._target.stage == null) {
			return;
		}
		this._target.stage.addEventListener(TouchEvent.TOUCH_BEGIN, edgePuller_target_stage_touchBeginHandler, false, 0, true);
		this._target.stage.addEventListener(MouseEvent.MOUSE_DOWN, edgePuller_target_stage_mouseDownHandler, false, 0, true);
	}

	private function removeStageEvents():Void {
		if (this._target == null || this._target.stage == null) {
			return;
		}
		this._target.stage.removeEventListener(TouchEvent.TOUCH_BEGIN, edgePuller_target_stage_touchBeginHandler);
		this._target.stage.removeEventListener(MouseEvent.MOUSE_DOWN, edgePuller_target_stage_mouseDownHandler);
	}

	private function cleanupAfterDrag():Void {
		if (this._pointerID == -1) {
			return;
		}
		this._pointerID = -1;
		if (this._target.stage != null) {
			this._target.stage.removeEventListener(MouseEvent.MOUSE_MOVE, edgePuller_target_stage_mouseMoveHandler);
			this._target.stage.removeEventListener(MouseEvent.MOUSE_UP, edgePuller_target_stage_mouseUpHandler);
			this._target.stage.removeEventListener(TouchEvent.TOUCH_MOVE, edgePuller_target_stage_touchMoveHandler);
			this._target.stage.removeEventListener(TouchEvent.TOUCH_END, edgePuller_target_stage_touchEndHandler);
		}
	}

	private function throwWithVelocity(velocity:Float):Void {
		var maxPullDistance = this.getMaxPullDistance();
		var targetPosition = 0.0;
		if (Math.abs(velocity) <= MINIMUM_VELOCITY) {
			targetPosition = (this._pullDistance < (maxPullDistance / 2.0)) ? 0.0 : maxPullDistance;
		} else {
			targetPosition = (velocity < 0.0) ? 0.0 : maxPullDistance;
		}
		this.throwTo(targetPosition);
	}

	private function throwTo(targetPosition:Null<Float>):Void {
		var pullChanged = false;
		if (targetPosition != null) {
			if (this._animatePull != null) {
				Actuate.stop(this._animatePull, null, false, false);
				this._animatePull = null;
			}
			if (this._pullDistance != targetPosition) {
				pullChanged = true;
				if (!this.startPull()) {
					// opening/closing event was cancelled
					return;
				}
				this._startPullDistance = this._pullDistance;
				this._targetPullDistance = targetPosition;
				if (this._snapDuration > 0.0) {
					var tween = Actuate.update((pullDistance : Float) -> {
						// use the setter
						this.setPullDistance(pullDistance);
					}, this._snapDuration, [this._startPullDistance], [this._targetPullDistance],
						true);
					this._animatePull = cast(tween, SimpleActuator<Dynamic, Dynamic>);
					this._animatePull.ease(this.ease);
					this._animatePull.onComplete(this.animatePull_onComplete);
				} else {
					this.setPullDistance(this._targetPullDistance);
					this.completeDrag();
				}
			} else {
				this.completeDrag();
			}
		}
	}

	private function animatePull_onComplete():Void {
		this._animatePull = null;
		this.completeDrag();
	}

	private function edgePuller_target_addedToStageHandler(event:Event):Void {
		this.addStageEvents();
	}

	private function edgePuller_target_removedFromStageHandler(event:Event):Void {
		this.removeStageEvents();
		this.cleanupAfterDrag();
	}

	private function edgePuller_target_touchBeginCaptureHandler(event:TouchEvent):Void {
		if (!this._active) {
			return;
		}
		event.stopImmediatePropagation();
		this.edgePuller_target_touchBeginHandler(event);
	}

	private function edgePuller_target_touchBeginHandler(event:TouchEvent):Void {
		if (this.simulateTouch && event.isPrimaryTouchPoint #if air && Multitouch.mapTouchToMouse #end) {
			// ignore the primary one because MouseEvent.MOUSE_DOWN will catch it
			return;
		}
		this.touchBegin(event.touchPointID, event.stageX, event.stageY);
	}

	private function edgePuller_target_mouseDownCaptureHandler(event:MouseEvent):Void {
		if (!this._active) {
			return;
		}
		event.stopImmediatePropagation();
		this.edgePuller_target_mouseDownHandler(event);
	}

	private function edgePuller_target_mouseDownHandler(event:MouseEvent):Void {
		if (this._opened) {
			return;
		}
		this.touchBegin(TOUCH_ID_MOUSE, event.stageX, event.stageY, true);
	}

	private function edgePuller_target_stage_touchMoveHandler(event:TouchEvent):Void {
		this.touchMove(event.touchPointID, event.stageX, event.stageY);
	}

	private function edgePuller_target_stage_mouseMoveHandler(event:MouseEvent):Void {
		this.touchMove(TOUCH_ID_MOUSE, event.stageX, event.stageY);
	}

	private function edgePuller_target_stage_touchEndHandler(event:TouchEvent):Void {
		this.touchEnd(event.touchPointID);
	}

	private function edgePuller_target_stage_mouseUpHandler(event:MouseEvent):Void {
		this.touchEnd(TOUCH_ID_MOUSE);
	}

	private function edgePuller_target_stage_touchBeginHandler(event:TouchEvent):Void {
		if (!this._opened || !this.enabled || this._pointerID != -1) {
			return;
		}
		var maxPullDistance = this.getMaxPullDistance();
		if (!this.isInActiveBorder(event.stageX, event.stageY, maxPullDistance)) {
			this._pointerID = event.touchPointID;
			this._target.stage.addEventListener(TouchEvent.TOUCH_MOVE, edgePuller_target_stage_touchMoveHandler2, false, 0, true);
			this._target.stage.addEventListener(TouchEvent.TOUCH_END, edgePuller_target_stage_touchEndHandler2, false, 0, true);
			return;
		}
		this.touchBegin(TOUCH_ID_MOUSE, event.stageX, event.stageY, true);
	}

	private function edgePuller_target_stage_touchMoveHandler2(event:TouchEvent):Void {
		if (event.touchPointID != this._pointerID) {
			return;
		}
		var maxPullDistance = this.getMaxPullDistance();
		var point = new Point(event.stageX, event.stageY);
		point = this._target.globalToLocal(point);
		switch (this._pullableEdge) {
			case TOP:
				if (point.y > maxPullDistance || point.y < 0.0) {
					return;
				}
			case RIGHT:
				if (point.x < (this._target.width - maxPullDistance) || point.x > this._target.width) {
					return;
				}
			case BOTTOM:
				if (point.y < (this._target.height - maxPullDistance) || point.y > this._target.height) {
					return;
				}
			case LEFT:
				if (point.x > maxPullDistance || point.x < 0.0) {
					return;
				}
			default:
				throw new ArgumentError("Unknown pullable edge position: " + this._pullableEdge);
		}
		this._target.stage.removeEventListener(TouchEvent.TOUCH_MOVE, edgePuller_target_stage_touchMoveHandler2);
		this._target.stage.removeEventListener(TouchEvent.TOUCH_END, edgePuller_target_stage_touchEndHandler2);
		this._pointerID = -1;
		this.touchBegin(event.touchPointID, event.stageX, event.stageY, true);
	}

	private function edgePuller_target_stage_touchEndHandler2(event:TouchEvent):Void {
		if (event.touchPointID != this._pointerID) {
			return;
		}
		this._target.stage.removeEventListener(TouchEvent.TOUCH_MOVE, edgePuller_target_stage_touchMoveHandler2);
		this._target.stage.removeEventListener(TouchEvent.TOUCH_END, edgePuller_target_stage_touchEndHandler2);
		this._pointerID = -1;
	}

	private function edgePuller_target_stage_mouseDownHandler(event:MouseEvent):Void {
		if (!this._opened || !this.enabled || this._pointerID != -1 || !this.simulateTouch) {
			return;
		}
		var maxPullDistance = this.getMaxPullDistance();
		if (!this.isInActiveBorder(event.stageX, event.stageY, maxPullDistance)) {
			this._pointerID = TOUCH_ID_MOUSE;
			this._target.stage.addEventListener(MouseEvent.MOUSE_MOVE, edgePuller_target_stage_mouseMoveHandler2, false, 0, true);
			this._target.stage.addEventListener(MouseEvent.MOUSE_UP, edgePuller_target_stage_mouseUpHandler2, false, 0, true);
			return;
		}
		this.touchBegin(TOUCH_ID_MOUSE, event.stageX, event.stageY, true);
	}

	private function edgePuller_target_stage_mouseMoveHandler2(event:MouseEvent):Void {
		if (TOUCH_ID_MOUSE != this._pointerID) {
			return;
		}
		var maxPullDistance = this.getMaxPullDistance();
		var point = new Point(event.stageX, event.stageY);
		point = this._target.globalToLocal(point);
		switch (this._pullableEdge) {
			case TOP:
				if (point.y > maxPullDistance || point.y < 0.0) {
					return;
				}
			case RIGHT:
				if (point.x < (this._target.width - maxPullDistance) || point.x > this._target.width) {
					return;
				}
			case BOTTOM:
				if (point.y < (this._target.height - maxPullDistance) || point.y > this._target.height) {
					return;
				}
			case LEFT:
				if (point.x > maxPullDistance || point.x < 0.0) {
					return;
				}
			default:
				throw new ArgumentError("Unknown pullable edge position: " + this._pullableEdge);
		}
		this._target.stage.removeEventListener(MouseEvent.MOUSE_MOVE, edgePuller_target_stage_mouseMoveHandler2);
		this._target.stage.removeEventListener(MouseEvent.MOUSE_UP, edgePuller_target_stage_mouseUpHandler2);
		this._pointerID = -1;
		this.touchBegin(TOUCH_ID_MOUSE, event.stageX, event.stageY, true);
	}

	private function edgePuller_target_stage_mouseUpHandler2(event:MouseEvent):Void {
		if (TOUCH_ID_MOUSE != this._pointerID) {
			return;
		}
		this._target.stage.removeEventListener(MouseEvent.MOUSE_MOVE, edgePuller_target_stage_mouseMoveHandler2);
		this._target.stage.removeEventListener(MouseEvent.MOUSE_UP, edgePuller_target_stage_mouseUpHandler2);
		this._pointerID = -1;
	}
}

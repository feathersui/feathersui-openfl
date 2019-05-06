package feathers.utils;

import motion.easing.IEasing;
import motion.easing.Quart;
import motion.actuators.SimpleActuator;
import motion.Actuate;
import feathers.controls.ScrollPolicy;
import feathers.events.FeathersEvent;
import openfl.display.Stage;
import openfl.Lib;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.display.DisplayObjectContainer;
import openfl.events.MouseEvent;
import openfl.display.InteractiveObject;

@:access(motion.actuators.SimpleActuator)
class Scroller extends EventDispatcher {
	private static final MINIMUM_VELOCITY:Float = 0.02;

	public function new(?target:InteractiveObject) {
		super();
		this.target = target;
	}

	public var scrollX(default, set):Float = 0.0;

	private function set_scrollX(value:Float):Float {
		if (this.scrollX == value) {
			return this.scrollX;
		}
		this.scrollX = value;
		FeathersEvent.dispatch(this, Event.SCROLL);
		return this.scrollX;
	}

	public var scrollY(default, set):Float = 0.0;

	private function set_scrollY(value:Float):Float {
		if (this.scrollY == value) {
			return this.scrollY;
		}
		this.scrollY = value;
		FeathersEvent.dispatch(this, Event.SCROLL);
		return this.scrollY;
	}

	public var minScrollX(default, null):Float = 0.0;
	public var minScrollY(default, null):Float = 0.0;
	public var maxScrollX(default, null):Float = 0.0;
	public var maxScrollY(default, null):Float = 0.0;
	public var visibleWidth(default, null):Float = 0.0;
	public var visibleHeight(default, null):Float = 0.0;
	public var contentWidth(default, null):Float = 0.0;
	public var contentHeight(default, null):Float = 0.0;
	public var scrolling(default, null):Bool = false;
	public var draggingX(default, null):Bool = false;
	public var draggingY(default, null):Bool = false;
	public var minDragDistance(default, default):Float = 6.0;
	public var friction(default, default):Float = 0.95;
	public var scrollPolicyX(default, default):ScrollPolicy = ScrollPolicy.AUTO;
	public var scrollPolicyY(default, default):ScrollPolicy = ScrollPolicy.AUTO;
	public var elasticEdges(default, default):Bool = true;
	public var elasticity(default, default):Float = 0.33;
	public var throwElasticity(default, default):Float = 0.05;
	public var elasticSnapDuration(default, default):Float = 0.5;
	public var decelerationRate(default, set):Float = 0.998;
	public var ease:IEasing = Quart.easeOut;

	private function set_decelerationRate(value:Float):Float {
		if (this.decelerationRate == value) {
			return this.decelerationRate;
		}
		this.decelerationRate = value;
		this._logDecelerationRate = Math.log(this.decelerationRate);
		this._fixedThrowDuration = -0.1 / Math.log(Math.pow(this.decelerationRate, 1000 / 60));
		return this.decelerationRate;
	}

	// this value is precalculated. See the `decelerationRate` setter for the dynamic calculation.
	private var _logDecelerationRate:Float = -0.0020020026706730793;
	private var _fixedThrowDuration:Float = 2.996998998998728;
	private var restoreMouseChildren:Bool;
	private var touchID:Int = -1;
	private var startTouchX:Float;
	private var startTouchY:Float;
	private var startScrollX:Float;
	private var startScrollY:Float;
	private var savedScrollMoves:Array<Float> = [];
	private var lastTouchMoveTime:Float;
	private var animateScrollX:SimpleActuator<Dynamic, Dynamic> = null;
	private var animateScrollY:SimpleActuator<Dynamic, Dynamic> = null;
	private var animateScrollXEndRatio:Float = 1.0;
	private var animateScrollYEndRatio:Float = 1.0;
	private var targetScrollX:Float;
	private var targetScrollY:Float;
	private var snappingToEdge:Bool;
	private var stage:Stage;

	public var target(default, set):InteractiveObject;

	private function set_target(value:InteractiveObject):InteractiveObject {
		if (this.target == value) {
			return this.target;
		}
		if (this.target != null) {
			this.target.removeEventListener(Event.REMOVED_FROM_STAGE, target_removedFromStageHandler);
			this.target.removeEventListener(MouseEvent.MOUSE_DOWN, target_mouseDownHandler);
		}
		this.target = value;
		if (this.target != null) {
			this.target.addEventListener(MouseEvent.MOUSE_DOWN, target_mouseDownHandler, false, 0, true);
		}
		return this.target;
	}

	public function setDimensions(?visibleWidth:Null<Float>, ?visibleHeight:Null<Float>, ?contentWidth:Null<Float>, ?contentHeight:Null<Float>):Void {
		if (visibleWidth != null) {
			this.visibleWidth = visibleWidth;
		}
		if (visibleHeight != null) {
			this.visibleHeight = visibleHeight;
		}
		if (contentWidth != null) {
			this.contentWidth = contentWidth;
		}
		if (contentHeight != null) {
			this.contentHeight = contentHeight;
		}
		this.calculateMinAndMax();
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
	private function throwTo(scrollX:Null<Float>, scrollY:Null<Float>, duration:Null<Float> = null):Void {
		if (duration == null) {
			duration = this._fixedThrowDuration;
		}
		var scrollChanged = false;
		if (scrollX != null) {
			if (this.animateScrollX != null) {
				Actuate.stop(this.animateScrollX, null, false, false);
				this.animateScrollX = null;
			}
			if (this.scrollX != scrollX) {
				scrollChanged = true;
				this.startScroll();
				if (duration == 0) {
					this.scrollX = scrollX;
				} else {
					this.startScrollX = this.scrollX;
					this.targetScrollX = scrollX;
					var tween = Actuate.tween(this, duration, {scrollX: this.targetScrollX}, true);
					this.animateScrollX = cast(tween, SimpleActuator<Dynamic, Dynamic>);
					this.animateScrollX.ease(this.ease);
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
			}
			if (this.scrollY != scrollY) {
				scrollChanged = true;
				this.startScroll();
				if (duration == 0) {
					this.scrollY = scrollY;
				} else {
					this.startScrollY = this.scrollY;
					this.targetScrollY = scrollY;
					var tween = Actuate.tween(this, duration, {scrollY: this.targetScrollY}, true);
					this.animateScrollY = cast(tween, SimpleActuator<Dynamic, Dynamic>);
					this.animateScrollY.ease(this.ease);
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
			container.mouseChildren = false;
		}
		FeathersEvent.dispatch(this, FeathersEvent.SCROLL_START);
	}

	private function completeScroll():Void {
		if (!this.scrolling || this.draggingX || this.draggingY || this.animateScrollX != null || this.animateScrollY != null) {
			return;
		}
		this.scrolling = false;
		FeathersEvent.dispatch(this, FeathersEvent.SCROLL_COMPLETE);
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
		} else if (Math.abs(targetScrollX - this.scrollX) < 1.0) {
			// this distance is too small to animate. just finish now.
			this.scrollX = targetScrollX;
			this.completeScroll();
		} else {
			this.throwTo(targetScrollX, null, this.elasticSnapDuration);
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
		} else if (Math.abs(targetScrollY - this.scrollY) < 1.0) {
			// this distance is too small to animate. just finish now.
			this.scrollY = targetScrollY;
			this.completeScroll();
		} else {
			this.throwTo(null, targetScrollY, this.elasticSnapDuration);
		}
	}

	private function animateScrollX_endRatio_onUpdate():Void {
		var currentTime = (Lib.getTimer() / 1000.0) - this.animateScrollX.startTime;
		var ratio = currentTime / this.animateScrollX.duration;
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
			this.finishScrollX();
			return;
		}
	}

	private function animateScrollX_onComplete():Void {
		this.animateScrollX = null;
		this.finishScrollX();
	}

	private function animateScrollY_endRatio_onUpdate():Void {
		var time = (Lib.getTimer() / 1000.0);
		var currentTime = time - this.animateScrollY.startTime;
		var ratio = currentTime / this.animateScrollY.duration;
		ratio = this.ease.calculate(ratio);
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
			this.finishScrollY();
			return;
		}
	}

	private function animateScrollY_onComplete():Void {
		this.animateScrollY = null;
		this.finishScrollY();
	}

	private function cleanupPointerListeners():Void {
		this.touchID = -1;
		this.target.removeEventListener(Event.REMOVED_FROM_STAGE, target_removedFromStageHandler);
		this.target.stage.removeEventListener(MouseEvent.MOUSE_MOVE, target_stage_mouseMoveHandler);
		this.target.stage.removeEventListener(MouseEvent.MOUSE_UP, target_stage_mouseUpHandler);
	}

	private function target_removedFromStageHandler(event:Event):Void {
		this.cleanupPointerListeners();
	}

	private function target_mouseDownHandler(event:MouseEvent):Void {
		if (this.touchID != -1) {
			return;
		}
		// if we're animating already, stop it
		if (this.animateScrollX != null && this.scrollPolicyX != ScrollPolicy.OFF) {
			Actuate.stop(this.animateScrollX, null, false, false);
			this.animateScrollX = null;
		}
		if (this.animateScrollY != null && this.scrollPolicyY != ScrollPolicy.OFF) {
			Actuate.stop(this.animateScrollY, null, false, false);
			this.animateScrollY = null;
		}

		this.target.addEventListener(Event.REMOVED_FROM_STAGE, target_removedFromStageHandler, false, 0, true);
		this.target.stage.addEventListener(MouseEvent.MOUSE_MOVE, target_stage_mouseMoveHandler, false, 0, true);
		this.target.stage.addEventListener(MouseEvent.MOUSE_UP, target_stage_mouseUpHandler, false, 0, true);
		if (Std.is(this.target, DisplayObjectContainer)) {
			var container = cast(this.target, DisplayObjectContainer);
			this.restoreMouseChildren = container.mouseChildren;
		}
		this.touchID = 0;
		this.startTouchX = event.stageX;
		this.startTouchY = event.stageY;
		this.startScrollX = this.scrollX;
		this.startScrollY = this.scrollY;
		this.savedScrollMoves = [];
	}

	private function canDragX():Bool {
		if (this.scrollPolicyX == ScrollPolicy.OFF) {
			return false;
		}
		return this.scrollPolicyX == ScrollPolicy.ON || this.maxScrollX > this.minScrollX;
	}

	private function canDragY():Bool {
		if (this.scrollPolicyY == ScrollPolicy.OFF) {
			return false;
		}
		return this.scrollPolicyY == ScrollPolicy.ON || this.maxScrollY > this.minScrollY;
	}

	private function target_stage_mouseMoveHandler(event:MouseEvent):Void {
		var touchOffsetX = event.stageX - this.startTouchX;
		var touchOffsetY = event.stageY - this.startTouchY;
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
			this.startTouchX = event.stageX;
			this.draggingX = true;
			// don't start dragging until we've moved a minimum distance
			// we'll also reset the start position at this point, so that there
			// isn't a sudden jump
			if (!draggingY) {
				this.startScroll();
			}
		}
		if (!this.draggingY && canDragY && Math.abs(touchOffsetY) > this.minDragDistance) {
			this.startTouchY = event.stageY;
			this.draggingY = true;
			if (!draggingX) {
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
					scrollX = scrollX - (scrollX - this.minScrollX) * (1.0 - this.elasticity);
				} else if (scrollX > this.maxScrollX) {
					scrollX = scrollX - (scrollX - this.maxScrollX) * (1.0 - this.elasticity);
				}
			}
		}
		var scrollY = this.startScrollY;
		if (canDragY) {
			scrollY -= touchOffsetY;
			if (this.elasticEdges) {
				if (scrollY < this.minScrollY) {
					scrollY = scrollY - (scrollY - this.minScrollY) * (1.0 - this.elasticity);
				} else if (scrollY > this.maxScrollY) {
					scrollY = scrollY - (scrollY - this.maxScrollY) * (1.0 - this.elasticity);
				}
			}
		}

		this.scrollX = scrollX;
		this.scrollY = scrollY;

		if (this.savedScrollMoves.length > 60) {
			do {
				this.savedScrollMoves.shift();
			} while (this.savedScrollMoves.length > 30);
		}

		this.lastTouchMoveTime = Lib.getTimer();
		this.savedScrollMoves.push(scrollX);
		this.savedScrollMoves.push(scrollY);
		this.savedScrollMoves.push(this.lastTouchMoveTime);
	}

	private function target_stage_mouseUpHandler(event:MouseEvent):Void {
		this.cleanupPointerListeners();
		if (Std.is(this.target, DisplayObjectContainer)) {
			var container = cast(this.target, DisplayObjectContainer);
			container.mouseChildren = this.restoreMouseChildren;
		}

		if (!this.draggingX && !this.draggingY) {
			return;
		}

		var endIndex = this.savedScrollMoves.length - 1;
		var startIndex = endIndex;

		// find scroll position measured 100ms ago, if possible
		var i = endIndex;
		while (endIndex > 0 && this.savedScrollMoves[i] > (this.lastTouchMoveTime - 100)) {
			startIndex = i;
			i -= 3;
		}

		if (startIndex == endIndex) {
			return;
		}

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
	}
}

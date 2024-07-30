/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.motion.transitions;

import feathers.motion.effects.EffectInterruptBehavior;
import feathers.motion.effects.IEffectContext;
import feathers.motion.effects.actuate.ActuateEffectContext;
import feathers.motion.effects.actuate.ActuateForEffects;
import motion.Actuate;
import motion.easing.IEasing;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.Shape;
import openfl.errors.ArgumentError;

/**
	Creates transitions for view navigators that wipe a display object out of
	view, revealing another display object under the first. Both display objects
	remain stationary while the effect animates a mask. The mask may be animated
	up, right, down, or left (or at an arbitrary angle).

	@see [Transitions for Feathers UI navigators](https://feathersui.com/learn/haxe-openfl/navigator-transitions/)

	@since 1.0.0
**/
class WipeTransitionBuilder {
	private static final VIEW_REQUIRED_ERROR:String = "Cannot transition if both old view and new view are null.";

	/**
		Creates a new `WipeTransitionBuilder` object.

		@since 1.0.0
	**/
	public function new(angleDegrees:Float = 0.0, duration:Float = 0.5, ?ease:IEasing) {
		this._angle = angleDegrees;
		this._duration = duration;
		this._ease = ease;
	}

	private var _angle:Float;
	private var _duration:Float;
	private var _ease:IEasing;
	private var _interruptBehavior:EffectInterruptBehavior;

	/**
		Sets the angle, measured in degrees, that the mask is translated
		during the transition.

		@see `WipeTransitionBuilder.setRadians()`
		@see `WipeTransitionBuilder.setUp()`
		@see `WipeTransitionBuilder.setDown()`
		@see `WipeTransitionBuilder.setLeft()`
		@see `WipeTransitionBuilder.setRight()`

		@since 1.0.0
	**/
	public function setAngle(angleDegrees:Float):WipeTransitionBuilder {
		this._angle = angleDegrees;
		return this;
	}

	/**
		Shortcut for `setAngle(angleRadians * 180.0 / Math.PI)`.

		@since 1.0.0
	**/
	public function setRadians(angleRadians:Float):WipeTransitionBuilder {
		return inline setAngle(angleRadians * 180.0 / Math.PI);
	}

	/**
		Shortcut for `setAngle(90.0)`.

		@since 1.0.0
	**/
	public function setUp():WipeTransitionBuilder {
		return inline setAngle(90.0);
	}

	/**
		Shortcut for `setAngle(270.0)`.

		@since 1.0.0
	**/
	public function setDown():WipeTransitionBuilder {
		return inline setAngle(270.0);
	}

	/**
		Shortcut for `setAngle(180.0)`.

		@since 1.0.0
	**/
	public function setLeft():WipeTransitionBuilder {
		return inline setAngle(180.0);
	}

	/**
		Shortcut for `setAngle(0.0)`.

		@since 1.0.0
	**/
	public function setRight():WipeTransitionBuilder {
		return inline setAngle(0.0);
	}

	/**
		Sets the duration of the animation, measured in seconds.

		@since 1.0.0
	**/
	public function setDuration(duration:Float):WipeTransitionBuilder {
		this._duration = duration;
		return this;
	}

	/**
		Sets the easing function used for the animation.

		@since 1.0.0
	**/
	public function setEase(ease:IEasing):WipeTransitionBuilder {
		this._ease = ease;
		return this;
	}

	/**
		Sets the behavior of the transition when it is interrupted (whether it
		stops at the current position or jumps immediately to the end).

		@since 1.0.0
	**/
	public function setInterruptBehavior(interruptBehavior:EffectInterruptBehavior):WipeTransitionBuilder {
		this._interruptBehavior = interruptBehavior;
		return this;
	}

	/**
		Returns the transition function.

		@since 1.0.0
	**/
	public function build():(DisplayObject, DisplayObject) -> IEffectContext {
		var angle = this._angle % 360.0;
		if (angle < 0.0) {
			angle += 360.0;
		}
		var duration = this._duration;
		var ease = this._ease;
		var interruptBehavior = this._interruptBehavior;
		return (oldView:DisplayObject, newView:DisplayObject) -> {
			if (oldView == null && newView == null) {
				throw new ArgumentError(VIEW_REQUIRED_ERROR);
			}
			var parent:DisplayObjectContainer = null;
			var width = 0.0;
			var height = 0.0;
			var oldViewMask:Shape = null;
			var newViewMask:Shape = null;
			var oldViewOldMask:DisplayObject = null;
			var newViewOldMask:DisplayObject = null;
			if (oldView != null) {
				parent = oldView.parent;
				width = oldView.width;
				height = oldView.height;
				oldViewOldMask = oldView.mask;
				oldViewMask = new Shape();
			}
			if (newView != null) {
				parent = newView.parent;
				width = Math.max(width, newView.width);
				height = Math.max(height, newView.height);
				newViewOldMask = newView.mask;
				newViewMask = new Shape();
			}

			var radians90 = Math.PI / 2.0;
			var radiansAngle = (angle % 90) * Math.PI / 180.0;
			var sin90 = Math.sin(radians90);
			var sinAngle = Math.sin(radiansAngle);
			var sinOther = Math.sin(radians90 - radiansAngle);

			var maskWidth = 0.0;
			var maskHeight = 0.0;
			var startX = 0.0;
			var startY = 0.0;
			var endX = 0.0;
			var endY = 0.0;
			if (angle >= 0.0 && angle < 90.0) {
				var mW1 = height * sinOther / sin90;
				var mW2 = width * sinAngle / sin90;

				var mH1 = height * sinAngle / sin90;
				var mH2 = width * sinOther / sin90;

				maskWidth = mW1 + mW2;
				maskHeight = mH1 + mH2;

				var xStartOffset = mW1 * sinAngle / sin90;
				var yStartOffset = mW1 * sinOther / sin90;

				var xEndOffset = mW2 * sinAngle / sin90;
				var yEndOffset = mW2 * sinOther / sin90;

				startX = -xStartOffset;
				startY = height - yStartOffset;
				endX = width - xEndOffset;
				endY = -yEndOffset;
			} else if (angle >= 90.0 && angle < 180.0) {
				var mW1 = width * sinOther / sin90;
				var mW2 = height * sinAngle / sin90;

				var mH1 = width * sinAngle / sin90;
				var mH2 = height * sinOther / sin90;

				maskWidth = mW1 + mW2;
				maskHeight = mH1 + mH2;

				var xStartOffset = mH1 * sinAngle / sin90;
				var yStartOffset = mH1 * sinOther / sin90;

				var yEndOffset = mW2 * sinAngle / sin90;
				var xEndOffset = mW2 * sinOther / sin90;

				startX = xStartOffset;
				startY = height + yStartOffset;
				endX = -xEndOffset;
				endY = yEndOffset;
			} else if (angle >= 180.0 && angle < 270.0) {
				var mW1 = width * sinAngle / sin90;
				var mW2 = height * sinOther / sin90;

				var mH1 = width * sinOther / sin90;
				var mH2 = height * sinAngle / sin90;

				maskWidth = mW1 + mW2;
				maskHeight = mH1 + mH2;

				var xStartOffset = mH2 * sinOther / sin90;
				var yStartOffset = mH2 * sinAngle / sin90;

				var xEndOffset = mW1 * sinAngle / sin90;
				var yEndOffset = mW1 * sinOther / sin90;

				startX = width + xStartOffset;
				startY = height - yStartOffset;
				endX = xEndOffset;
				endY = height + yEndOffset;
			} else if (angle >= 270.0 && angle < 360.0) {
				var mW1 = width * sinOther / sin90;
				var mW2 = height * sinAngle / sin90;

				var mH1 = height * sinOther / sin90;
				var mH2 = width * sinAngle / sin90;

				maskWidth = mW1 + mW2;
				maskHeight = mH1 + mH2;

				var xStartOffset = mH2 * sinAngle / sin90;
				var yStartOffset = mH2 * sinOther / sin90;

				var xEndOffset = mW2 * sinOther / sin90;
				var yEndOffset = mW2 * sinAngle / sin90;

				startX = width - xStartOffset;
				startY = -yStartOffset;
				endX = width + xEndOffset;
				endY = height - yEndOffset;
			}

			if (oldViewMask != null) {
				oldViewMask.rotation = 90.0 - angle;
				oldViewMask.graphics.beginFill(0xff00ff);
				oldViewMask.graphics.drawRect(0.0, 0.0, maskWidth, maskHeight);
				oldViewMask.graphics.endFill();
				oldViewMask.x = endX;
				oldViewMask.y = endY;
				parent.addChild(oldViewMask);
				oldView.mask = oldViewMask;
			}
			if (newViewMask != null) {
				newViewMask.rotation = 90.0 - angle;
				newViewMask.graphics.beginFill(0xff00ff);
				newViewMask.graphics.drawRect(0.0, 0.0, maskWidth, maskHeight);
				newViewMask.graphics.endFill();
				newViewMask.x = startX;
				newViewMask.y = startY;
				parent.addChild(newViewMask);
				newView.mask = newViewMask;
			}

			var actuator = ActuateForEffects.update((x:Float, y:Float) -> {
				if (newViewMask != null) {
					newViewMask.x = x;
					newViewMask.y = y;
				}
				if (oldViewMask != null) {
					oldViewMask.x = x + (endX - startX);
					oldViewMask.y = y + (endY - startY);
				}
			}, duration, [startX, startY], [endX, endY]);
			if (ease != null) {
				actuator.ease(ease);
			}
			actuator.onComplete(() -> {
				if (oldView != null) {
					oldView.mask = oldViewOldMask;
				}
				if (newView != null) {
					newView.mask = newViewOldMask;
				}
				if (oldViewMask != null) {
					parent.removeChild(oldViewMask);
				}
				if (newViewMask != null) {
					parent.removeChild(newViewMask);
				}
			});
			Actuate.pause(actuator);
			return new ActuateEffectContext(null, actuator, interruptBehavior);
		};
	}
}

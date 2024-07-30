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
import openfl.errors.ArgumentError;

/**
	Creates animated transitions for view navigators that slide a new display
	object into view by animating the `x` and `y` properties, while covering an
	existing display object that remains stationary below. The display object
	may slide up, right, down, or left (or at an arbitrary angle).

	@see [Transitions for Feathers UI navigators](https://feathersui.com/learn/haxe-openfl/navigator-transitions/)

	@since 1.0.0
**/
class CoverTransitionBuilder {
	private static final VIEW_REQUIRED_ERROR:String = "Cannot transition if both old view and new view are null.";

	/**
		Creates a new `CoverTransitionBuilder` object.

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
		Sets the angle, measured in degrees, that the new view is translated
		during the transition.

		@see `CoverTransitionBuilder.setRadians()`
		@see `CoverTransitionBuilder.setUp()`
		@see `CoverTransitionBuilder.setDown()`
		@see `CoverTransitionBuilder.setLeft()`
		@see `CoverTransitionBuilder.setRight()`

		@since 1.0.0
	**/
	public function setAngle(angleDegrees:Float):CoverTransitionBuilder {
		this._angle = angleDegrees;
		return this;
	}

	/**
		Shortcut for `setAngle(angleRadians * 180.0 / Math.PI)`.

		@since 1.0.0
	**/
	public function setRadians(angleRadians:Float):CoverTransitionBuilder {
		return inline setAngle(angleRadians * 180.0 / Math.PI);
	}

	/**
		Shortcut for `setAngle(90.0)`.

		@since 1.0.0
	**/
	public function setUp():CoverTransitionBuilder {
		return inline setAngle(90.0);
	}

	/**
		Shortcut for `setAngle(270.0)`.

		@since 1.0.0
	**/
	public function setDown():CoverTransitionBuilder {
		return inline setAngle(270.0);
	}

	/**
		Shortcut for `setAngle(180.0)`.

		@since 1.0.0
	**/
	public function setLeft():CoverTransitionBuilder {
		return inline setAngle(180.0);
	}

	/**
		Shortcut for `setAngle(0.0)`.

		@since 1.0.0
	**/
	public function setRight():CoverTransitionBuilder {
		return inline setAngle(0.0);
	}

	/**
		Sets the duration of the animation, measured in seconds.

		@since 1.0.0
	**/
	public function setDuration(duration:Float):CoverTransitionBuilder {
		this._duration = duration;
		return this;
	}

	/**
		Sets the easing function used for the animation.

		@since 1.0.0
	**/
	public function setEase(ease:IEasing):CoverTransitionBuilder {
		this._ease = ease;
		return this;
	}

	/**
		Sets the behavior of the transition when it is interrupted (whether it
		stops at the current position or jumps immediately to the end).

		@since 1.0.0
	**/
	public function setInterruptBehavior(interruptBehavior:EffectInterruptBehavior):CoverTransitionBuilder {
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
			if (oldView != null) {
				parent = oldView.parent;
				width = oldView.width;
				height = oldView.height;
			}
			if (newView != null) {
				parent = newView.parent;
				width = Math.max(width, newView.width);
				height = Math.max(height, newView.height);
			}
			var endX = 0.0;
			var endY = 0.0;
			if (angle >= 0.0 && angle < 45.0) {
				// E to NE
				endX = width;
				// c = b / cos(α)
				// a = -sqrt(c^2 - b^2()
				var hy = width / Math.cos(angle * Math.PI / 180.0);
				endY = -Math.sqrt(hy * hy - width * width);
			} else if (angle >= 45.0 && angle < 90.0) {
				// NE to N
				endY = -height;
				// c = a / sin(α)
				// b = sqrt(c^2 - a^2)
				var hy = height / Math.sin(angle * Math.PI / 180.0);
				endX = Math.sqrt(hy * hy - height * height);
			} else if (angle >= 90.0 && angle < 135.0) {
				// N to NW
				endY = -height;
				var hy = height / Math.cos((angle - 90.0) * Math.PI / 180.0);
				endX = -Math.sqrt(hy * hy - height * height);
			} else if (angle >= 135.0 && angle < 180.0) {
				// NW to W
				endX = -width;
				var hy = width / Math.sin((angle - 90.0) * Math.PI / 180.0);
				endY = -Math.sqrt(hy * hy - width * width);
			} else if (angle >= 180.0 && angle < 225.0) {
				// W to SW
				endX = -width;
				var hy = width / Math.cos((angle - 180.0) * Math.PI / 180.0);
				endY = Math.sqrt(hy * hy - width * width);
			} else if (angle >= 225.0 && angle < 270.0) {
				// SW to S
				endY = height;
				var hy = height / Math.sin((angle - 180.0) * Math.PI / 180.0);
				endX = -Math.sqrt(hy * hy - height * height);
			} else if (angle >= 270.0 && angle < 315.0) {
				// S to SE
				endY = height;
				var hy = height / Math.cos((angle - 270.0) * Math.PI / 180.0);
				endX = Math.sqrt(hy * hy - height * height);
			} else { // angle >= 315.0 && angle < 360.0
				// SE to E
				endX = width;
				var hy = width / Math.sin((angle - 270.0) * Math.PI / 180.0);
				endY = Math.sqrt(hy * hy - width * width);
			}
			var startX = -endX;
			var startY = -endY;
			if (oldView != null) {
				oldView.x = 0.0;
				oldView.y = 0.0;
			}
			if (newView != null) {
				newView.x = startX;
				newView.y = startY;
			}
			if (parent != null && oldView != null && newView != null) {
				var oldViewIndex = parent.getChildIndex(oldView);
				var newViewIndex = parent.getChildIndex(newView);
				if (oldViewIndex > newViewIndex) {
					// old view should be on bottom to be covered by new view
					parent.swapChildren(oldView, newView);
				}
			}
			var actuator = ActuateForEffects.update((x:Float, y:Float) -> {
				if (newView != null) {
					newView.x = x;
					newView.y = y;
				}
			}, duration, [startX, startY], [0.0, 0.0]);
			if (ease != null) {
				actuator.ease(ease);
			}
			Actuate.pause(actuator);
			return new ActuateEffectContext(null, actuator, interruptBehavior);
		};
	}
}

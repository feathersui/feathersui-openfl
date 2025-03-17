/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

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
	Creates animated transitions for view navigators that fade a display object
	to a solid color.

	@see [Transitions for Feathers UI navigators](https://feathersui.com/learn/haxe-openfl/navigator-transitions/)

	@since 1.0.0
**/
class ColorFadeTransitionBuilder {
	private static final VIEW_REQUIRED_ERROR:String = "Cannot transition if both old view and new view are null.";

	/**
		Creates a new `ColorFadeTransitionBuilder` object.

		@since 1.0.0
	**/
	public function new(color:UInt = 0x000000, duration:Float = 0.5, ?ease:IEasing) {
		this._color = color;
		this._duration = duration;
		this._ease = ease;
	}

	private var _color:UInt;
	private var _duration:Float;
	private var _ease:IEasing;
	private var _interruptBehavior:EffectInterruptBehavior;

	/**
		Shortcut for `setColor(0x000000)`.

		@since 1.0.0
	**/
	public function setBlack():ColorFadeTransitionBuilder {
		this._color = 0x000000;
		return this;
	}

	/**
		Shortcut for `setColor(0xffffff)`.

		@since 1.0.0
	**/
	public function setWhite():ColorFadeTransitionBuilder {
		this._color = 0xffffff;
		return this;
	}

	/**
		Sets the color that the views fade between.

		@see `ColorFadeTransitionBuilder.setBlack()`
		@see `ColorFadeTransitionBuilder.setWhite()`

		@since 1.0.0
	**/
	public function setColor(color:UInt):ColorFadeTransitionBuilder {
		this._color = color;
		return this;
	}

	/**
		Sets the duration of the animation, measured in seconds.

		@since 1.0.0
	**/
	public function setDuration(duration:Float):ColorFadeTransitionBuilder {
		this._duration = duration;
		return this;
	}

	/**
		Sets the easing function used for the animation.

		@since 1.0.0
	**/
	public function setEase(ease:IEasing):ColorFadeTransitionBuilder {
		this._ease = ease;
		return this;
	}

	/**
		Sets the behavior of the transition when it is interrupted (whether it
		stops at the current position or jumps immediately to the end).

		@since 1.0.0
	**/
	public function setInterruptBehavior(interruptBehavior:EffectInterruptBehavior):ColorFadeTransitionBuilder {
		this._interruptBehavior = interruptBehavior;
		return this;
	}

	/**
		Returns the transition function.

		@since 1.0.0
	**/
	public function build():(DisplayObject, DisplayObject) -> IEffectContext {
		var color = this._color;
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
				newView.visible = false;
			}

			var overlay = new Shape();
			overlay.graphics.beginFill(color);
			overlay.graphics.drawRect(0.0, 0.0, width, height);
			overlay.graphics.endFill();
			overlay.alpha = 0.0;
			parent.addChild(overlay);

			var actuator = ActuateForEffects.update((ratio:Float) -> {
				if (ratio < 0.5) {
					if (oldView != null) {
						oldView.visible = true;
					}
					if (newView != null) {
						newView.visible = false;
					}
					overlay.alpha = ratio * 2.0;
				} else {
					if (oldView != null) {
						oldView.visible = false;
					}
					if (newView != null) {
						newView.visible = true;
					}
					overlay.alpha = (1.0 - ratio) * 2.0;
				}
			}, duration, [0.0], [1.0]);
			if (ease != null) {
				actuator.ease(ease);
			}
			actuator.onComplete(() -> {
				if (oldView != null) {
					oldView.visible = true;
				}
				if (newView != null) {
					newView.visible = true;
				}
				parent.removeChild(overlay);
			});
			Actuate.pause(actuator);
			return new ActuateEffectContext(null, actuator, interruptBehavior);
		};
	}
}

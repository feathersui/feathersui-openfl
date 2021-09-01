/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

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
	Creates animated transitions for view navigators that modify the opacity of
	one or both views in transition. Animates the `alpha` property of a display
	object to make it fade in or out.

	@see [Transitions for Feathers UI navigators](https://feathersui.com/learn/haxe-openfl/navigator-transitions/)

	@since 1.0.0
**/
class FadeTransitionBuilder {
	private static final VIEW_REQUIRED_ERROR:String = "Cannot transition if both old view and new view are null.";

	/**
		Creates a new `FadeTransitionBuilder` object.

		@since 1.0.0
	**/
	public function new(fadeIn:Bool = true, fadeOut:Bool = true, duration:Float = 0.5, ?ease:IEasing) {
		this._fadeIn = fadeIn;
		this._fadeOut = fadeOut;
		this._duration = duration;
		this._ease = ease;
	}

	private var _fadeIn:Bool;
	private var _fadeOut:Bool;
	private var _duration:Float;
	private var _ease:IEasing;
	private var _interruptBehavior:EffectInterruptBehavior;

	/**
		@since 1.0.0
	**/
	public function setFadeIn(fadeIn:Bool):FadeTransitionBuilder {
		this._fadeIn = fadeIn;
		return this;
	}

	/**
		@since 1.0.0
	**/
	public function setFadeOut(fadeOut:Bool):FadeTransitionBuilder {
		this._fadeOut = fadeOut;
		return this;
	}

	/**
		Sets the duration of the animation, measured in seconds.

		@since 1.0.0
	**/
	public function setDuration(duration:Float):FadeTransitionBuilder {
		this._duration = duration;
		return this;
	}

	/**
		Sets the easing function used for the animation.

		@since 1.0.0
	**/
	public function setEase(ease:IEasing):FadeTransitionBuilder {
		this._ease = ease;
		return this;
	}

	/**
		Sets the behavior of the transition when it is interrupted (whether it
		stops at the current position or jumps immediately to the end).

		@since 1.0.0
	**/
	public function setInterruptBehavior(interruptBehavior:EffectInterruptBehavior):FadeTransitionBuilder {
		this._interruptBehavior = interruptBehavior;
		return this;
	}

	/**
		Returns the transition function.

		@since 1.0.0
	**/
	public function build():(DisplayObject, DisplayObject) -> IEffectContext {
		var fadeIn = this._fadeIn;
		var fadeOut = this._fadeOut;
		var duration = this._duration;
		var ease = this._ease;
		var interruptBehavior = this._interruptBehavior;
		return (oldView:DisplayObject, newView:DisplayObject) -> {
			if (oldView == null && newView == null) {
				throw new ArgumentError(VIEW_REQUIRED_ERROR);
			}
			var parent:DisplayObjectContainer = null;
			var oldStartAlpha = 1.0;
			var oldEndAlpha = 0.0;
			var newStartAlpha = 0.0;
			var newEndAlpha = 1.0;
			if (oldView != null) {
				parent = oldView.parent;
				oldStartAlpha = oldView.alpha;
				oldEndAlpha = fadeOut ? 0.0 : oldStartAlpha;
			}
			if (newView != null) {
				parent = newView.parent;
				newStartAlpha = fadeIn ? 0.0 : newView.alpha;
				newEndAlpha = fadeIn ? 1.0 : newStartAlpha;
				newView.alpha = newStartAlpha;
			}
			if (parent != null && oldView != null && newView != null) {
				var oldViewIndex = parent.getChildIndex(oldView);
				var newViewIndex = parent.getChildIndex(newView);
				if (fadeIn && oldViewIndex > newViewIndex) {
					// old view should be on bottom when fading in new view
					parent.setChildIndex(oldView, newViewIndex);
				} else if (!fadeIn && fadeOut && newViewIndex > oldViewIndex) {
					// new view should be on bottom when fading out old view
					parent.setChildIndex(newView, oldViewIndex);
				}
			}
			var actuator = ActuateForEffects.update((alpha1:Float, alpha2:Float) -> {
				if (oldView != null) {
					oldView.alpha = alpha1;
				}
				if (newView != null) {
					newView.alpha = alpha2;
				}
			}, duration, [oldStartAlpha, newStartAlpha], [oldEndAlpha, newEndAlpha]);
			if (ease != null) {
				actuator.ease(ease);
			}
			Actuate.pause(actuator);
			return new ActuateEffectContext(null, actuator, interruptBehavior);
		};
	}
}

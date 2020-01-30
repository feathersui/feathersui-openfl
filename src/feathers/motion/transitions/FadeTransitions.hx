/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.motion.transitions;

import motion.Actuate;
import motion.easing.IEasing;
import openfl.display.DisplayObject;
import openfl.errors.ArgumentError;
import feathers.motion.effects.actuate.ActuateEffectContext;
import feathers.motion.effects.actuate.ActuateForEffects;
import feathers.motion.effects.EffectInterruptBehavior;
import feathers.motion.effects.IEffectContext;

/**
	Creates animated transitions for view navigators that modify the opacity of
	one or both views in transition. Animates the `alpha` property of a display
	object to make it fade in or out.

	@see [Transitions for Feathers UI navigators](https://feathersui.com/learn/haxe-openfl/navigator-transitions/)

	@since 1.0.0
**/
class FadeTransitions {
	private static final VIEW_REQUIRED_ERROR:String = "Cannot transition if both old view and new view are null.";

	/**
		Creates a transition function for a view navigator that crossfades the
		views. In other words, the old view fades out, animating the `alpha`
		property from `1.0` to `0.0`. Simultaneously, the new view fades in,
		animating its `alpha` property from `0.0` to `1.0`.

		@since 1.0.0
	**/
	public static function crossFade(duration:Float = 0.5, ?ease:IEasing,
			?interruptBehavior:EffectInterruptBehavior):(DisplayObject, DisplayObject) -> IEffectContext {
		return function(oldView:DisplayObject, newView:DisplayObject):IEffectContext {
			if (oldView == null && newView == null) {
				throw new ArgumentError(VIEW_REQUIRED_ERROR);
			}
			var oldViewIndex = -1;
			if (oldView != null) {
				oldView.alpha = 1.0;
				oldViewIndex = oldView.parent.getChildIndex(oldView);
			}
			if (newView != null) {
				newView.alpha = 0.0;
				var parent = newView.parent;
				// make sure the new view is on top of the old view
				if (parent.getChildIndex(newView) < oldViewIndex) {
					parent.swapChildren(oldView, newView);
				}
			}
			var actuator = ActuateForEffects.update(function(oldViewAlpha:Float, newViewAlpha:Float):Void {
				if (oldView != null) {
					oldView.alpha = oldViewAlpha;
				}
				if (newView != null) {
					newView.alpha = newViewAlpha;
				}
			}, duration, [1.0, 0.0], [0.0, 1.0]);
			if (ease != null) {
				actuator.ease(ease);
			}
			actuator.onComplete(function():Void {
				if (oldView != null) {
					oldView.alpha = 1.0;
				}
				if (newView != null) {
					newView.alpha = 1.0;
				}
			});
			Actuate.pause(actuator);
			return new ActuateEffectContext(null, actuator, interruptBehavior);
		};
	}
}

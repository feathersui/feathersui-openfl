/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.motion.transitions;

import feathers.motion.effects.EffectInterruptBehavior;
import feathers.motion.effects.IEffectContext;
import motion.easing.IEasing;
import openfl.display.DisplayObject;

/**
	Creates animated transitions for view navigators that modify the opacity of
	one or both views in transition. Animates the `alpha` property of a display
	object to make it fade in or out.

	@see [Transitions for Feathers UI navigators](https://feathersui.com/learn/haxe-openfl/navigator-transitions/)

	@since 1.0.0
**/
@:deprecated("FadeTransitions replaced by feathers.motion.transitions.FadeTransitionBuilder")
class FadeTransitions {
	/**
		Creates a transition function for a view navigator that crossfades the
		views. In other words, the old view fades out, animating the `alpha`
		property from `1.0` to `0.0`. Simultaneously, the new view fades in,
		animating its `alpha` property from `0.0` to `1.0`.

		@since 1.0.0
	**/
	@:deprecated("FadeTransitions.crossFade() replaced by feathers.motion.transitions.FadeTransitionBuilder")
	public static function crossFade(duration:Float = 0.5, ?ease:IEasing,
			?interruptBehavior:EffectInterruptBehavior):(DisplayObject, DisplayObject) -> IEffectContext {
		return new FadeTransitionBuilder().setFadeIn(true)
			.setFadeOut(true)
			.setDuration(duration)
			.setEase(ease)
			.setInterruptBehavior(interruptBehavior)
			.build();
	}
}

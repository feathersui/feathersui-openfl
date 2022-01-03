/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.motion.transitions;

import feathers.motion.effects.EffectInterruptBehavior;
import feathers.motion.effects.IEffectContext;
import motion.easing.IEasing;
import openfl.display.DisplayObject;

/**
	Creates animated transitions for view navigators that moves two adjacent
	views in the same direction (replacing one with the other), as if one view
	is pushing the other out of the way. Looks similar to a classic slide
	carousel. Animates the `x` or `y` property of the views. The views may move
	up, down, right, or left.

	@see [Transitions for Feathers UI navigators](https://feathersui.com/learn/haxe-openfl/navigator-transitions/)

	@since 1.0.0
**/
@:deprecated("SlideTransitions replaced by feathers.motion.transitions.SlideTransitionBuilder")
class SlideTransitions {
	/**
		Creates a transition function for a view navigator that slides the views
		to the left, with the new view appearing from the right side and the old
		view disappearing on the left side.

		@since 1.0.0
	**/
	@:deprecated("SlideTransitions.left() replaced by setLeft() from feathers.motion.transitions.SlideTransitionBuilder")
	public static function left(duration:Float = 0.5, ?ease:IEasing,
			?interruptBehavior:EffectInterruptBehavior):(DisplayObject, DisplayObject) -> IEffectContext {
		return new SlideTransitionBuilder().setLeft()
			.setDuration(duration)
			.setEase(ease)
			.setInterruptBehavior(interruptBehavior)
			.build();
	}

	/**
		Creates a transition function for a view navigator that slides the views
		to the right, with the new view appearing from the left side and the old
		view disappearing on the right side.

		@since 1.0.0
	**/
	@:deprecated("SlideTransitions.right() replaced by setRight() from feathers.motion.transitions.SlideTransitionBuilder")
	public static function right(duration:Float = 0.5, ?ease:IEasing,
			?interruptBehavior:EffectInterruptBehavior):(DisplayObject, DisplayObject) -> IEffectContext {
		return new SlideTransitionBuilder().setRight()
			.setDuration(duration)
			.setEase(ease)
			.setInterruptBehavior(interruptBehavior)
			.build();
	}

	/**
		Creates a transition function for a view navigator that slides the views
		upwards, with the new view appearing from the bottom and the old view
		disappearing on the top.

		@since 1.0.0
	**/
	@:deprecated("SlideTransitions.left() replaced by setUp() from feathers.motion.transitions.SlideTransitionBuilder")
	public static function up(duration:Float = 0.5, ?ease:IEasing,
			?interruptBehavior:EffectInterruptBehavior):(DisplayObject, DisplayObject) -> IEffectContext {
		return new SlideTransitionBuilder().setUp()
			.setDuration(duration)
			.setEase(ease)
			.setInterruptBehavior(interruptBehavior)
			.build();
	}

	/**
		Creates a transition function for a view navigator that slides the views
		downwards, with the new view appearing from the top and the old view
		disappearing on the bottom.

		@since 1.0.0
	**/
	@:deprecated("SlideTransitions.left() replaced by setDown() from feathers.motion.transitions.SlideTransitionBuilder")
	public static function down(duration:Float = 0.5, ?ease:IEasing,
			?interruptBehavior:EffectInterruptBehavior):(DisplayObject, DisplayObject) -> IEffectContext {
		return new SlideTransitionBuilder().setDown()
			.setDuration(duration)
			.setEase(ease)
			.setInterruptBehavior(interruptBehavior)
			.build();
	}
}

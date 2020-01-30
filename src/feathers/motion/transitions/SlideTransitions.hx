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
	Creates animated transitions for view navigators that moves two adjacent
	views in the same direction (replacing one with the other), as if one view
	is pushing the other out of the way. Looks similar to a classic slide
	carousel. Animates the `x` or `y` property of the views. The views may move
	up, down, right, or left.

	@see [Transitions for Feathers UI navigators](https://feathersui.com/learn/haxe-openfl/navigator-transitions/)

	@since 1.0.0
**/
class SlideTransitions {
	private static final VIEW_REQUIRED_ERROR:String = "Cannot transition if both old view and new view are null.";

	/**
		Creates a transition function for a view navigator that slides the views
		to the left, with the new view appearing from the right side and the old
		view disappearing on the left side.

		@since 1.0.0
	**/
	public static function left(duration:Float = 0.5, ?ease:IEasing,
			?interruptBehavior:EffectInterruptBehavior):(DisplayObject, DisplayObject) -> IEffectContext {
		return function(oldView:DisplayObject, newView:DisplayObject):IEffectContext {
			if (oldView == null && newView == null) {
				throw new ArgumentError(VIEW_REQUIRED_ERROR);
			}
			var width = 0.0;
			if (oldView != null) {
				width = oldView.width;
			}
			if (newView != null) {
				width = Math.max(width, newView.width);
				newView.x = width;
			}
			var actuator = ActuateForEffects.update(function(x:Float):Void {
				if (oldView != null) {
					oldView.x = x;
				}
				if (newView != null) {
					newView.x = x + width;
				}
			}, duration, [0.0], [-width]);
			if (ease != null) {
				actuator.ease(ease);
			}
			Actuate.pause(actuator);
			return new ActuateEffectContext(null, actuator, interruptBehavior);
		};
	}

	/**
		Creates a transition function for a view navigator that slides the views
		to the right, with the new view appearing from the left side and the old
		view disappearing on the right side.

		@since 1.0.0
	**/
	public static function right(duration:Float = 0.5, ?ease:IEasing,
			?interruptBehavior:EffectInterruptBehavior):(DisplayObject, DisplayObject) -> IEffectContext {
		return function(oldView:DisplayObject, newView:DisplayObject):IEffectContext {
			if (oldView == null && newView == null) {
				throw new ArgumentError(VIEW_REQUIRED_ERROR);
			}
			var width = 0.0;
			if (oldView != null) {
				width = oldView.width;
			}
			if (newView != null) {
				width = Math.max(width, newView.width);
				newView.x = -width;
			}
			var actuator = ActuateForEffects.update(function(x:Float):Void {
				if (oldView != null) {
					oldView.x = x;
				}
				if (newView != null) {
					newView.x = x - width;
				}
			}, duration, [0.0], [width]);
			if (ease != null) {
				actuator.ease(ease);
			}
			Actuate.pause(actuator);
			return new ActuateEffectContext(null, actuator, interruptBehavior);
		};
	}

	/**
		Creates a transition function for a view navigator that slides the views
		upwards, with the new view appearing from the bottom and the old view
		disappearing on the top.

		@since 1.0.0
	**/
	public static function up(duration:Float = 0.5, ?ease:IEasing,
			?interruptBehavior:EffectInterruptBehavior):(DisplayObject, DisplayObject) -> IEffectContext {
		return function(oldView:DisplayObject, newView:DisplayObject):IEffectContext {
			if (oldView == null && newView == null) {
				throw new ArgumentError(VIEW_REQUIRED_ERROR);
			}
			var height = 0.0;
			if (oldView != null) {
				height = oldView.height;
			}
			if (newView != null) {
				height = Math.max(height, newView.height);
				newView.y = height;
			}
			var actuator = ActuateForEffects.update(function(y:Float):Void {
				if (oldView != null) {
					oldView.y = y;
				}
				if (newView != null) {
					newView.y = y + height;
				}
			}, duration, [0.0], [-height]);
			if (ease != null) {
				actuator.ease(ease);
			}
			Actuate.pause(actuator);
			return new ActuateEffectContext(null, actuator, interruptBehavior);
		};
	}

	/**
		Creates a transition function for a view navigator that slides the views
		downwards, with the new view appearing from the top and the old view
		disappearing on the bottom.

		@since 1.0.0
	**/
	public static function down(duration:Float = 0.5, ?ease:IEasing,
			?interruptBehavior:EffectInterruptBehavior):(DisplayObject, DisplayObject) -> IEffectContext {
		return function(oldView:DisplayObject, newView:DisplayObject):IEffectContext {
			if (oldView == null && newView == null) {
				throw new ArgumentError(VIEW_REQUIRED_ERROR);
			}
			var height = 0.0;
			if (oldView != null) {
				height = oldView.height;
			}
			if (newView != null) {
				height = Math.max(height, newView.height);
				newView.y = -height;
			}
			var actuator = ActuateForEffects.update(function(y:Float):Void {
				if (oldView != null) {
					oldView.y = y;
				}
				if (newView != null) {
					newView.y = y - height;
				}
			}, duration, [0.0], [height]);
			if (ease != null) {
				actuator.ease(ease);
			}
			Actuate.pause(actuator);
			return new ActuateEffectContext(null, actuator, interruptBehavior);
		};
	}
}

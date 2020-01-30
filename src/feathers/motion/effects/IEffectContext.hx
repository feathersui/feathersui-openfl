/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.motion.effects;

import openfl.events.IEventDispatcher;

/**
	Gives a component the ability to control an effect.

	@since 1.0.0
**/
interface IEffectContext extends IEventDispatcher {
	/**
		The effect's target object, which may be modified in some way, such as
		animating one of the target's properties.

		@since 1.0.0
	**/
	var target(default, never):Dynamic;

	/**
		The total running time of the effect, measured in seconds.

		@since 1.0.0
	**/
	var duration(default, never):Float;

	/**
		The current position of the effect, in the range of `0.0` to `1.0`.

		@see `IEffectContext.duration`

		@since 1.0.0
	**/
	var position(default, set):Float;

	/**
		Starts playing the effect from the current position.

		@since 1.0.0
	**/
	function play():Void;

	/**
		Starts playing the effect from its current position back to the
		beginning (completing at a position of `0.0`).

		@since 1.0.0
	**/
	function playReverse():Void;

	/**
		Pauses an effect that is playing at the current position.

		@since 1.0.0
	**/
	function pause():Void;

	/**
		Stops the effect at its current position and forces `Event.COMPLETE` to
		be dispatched.

		@see `IEffectContext.toEnd`

		@since 1.0.0
	**/
	function stop():Void;

	/**
		Advances the effect immediately to the end and forces `Event.COMPLETE`
		to be dispatched.

		@see `IEffectContext.stop`

		@since 1.0.0
	**/
	function toEnd():Void;

	/**
		Interrupts the playing effect, but it will be allowed to determine on
		its own whether this call behaves like `stop()` or if it behaves like
		`toEnd()` instead.

		@see `IEffectContext.stop`
		@see `IEffectContext.toEnd`

		@since 1.0.0
	**/
	function interrupt():Void;
}

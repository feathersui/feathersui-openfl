/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.motion.effects;

import feathers.events.FeathersEvent;
import openfl.errors.RangeError;
import openfl.events.Event;
import openfl.events.EventDispatcher;

/**
	An effect that does nothing and simply completes immediately.

	@since 1.0.0
**/
class NoOpEffectContext extends EventDispatcher implements IEffectContext {
	/**
		Creates a new `NoOpEffectContext` object from the given arguments.

		@since 1.0.0
	**/
	public function new(target:Dynamic) {
		super();
		this.target = target;
	}

	/**
		The object targeted by the affect.

		@since 1.0.0
	**/
	public var target(default, null):Dynamic;

	/**
		The duration of this effect is always `0.0` seconds.

		@since 1.0.0
	**/
	public var duration(default, null):Float = 0.0;

	/**
		The position of this effect is always `0.0`.

		@since 1.0.0
	**/
	public var position(default, set):Float = 0.0;

	private function set_position(value:Float):Float {
		if (value != 0.0) {
			throw new RangeError("Position must always be 0.0");
		}
		return this.position;
	}

	/**
		Plays the effect.

		@since 1.0.0
	**/
	public function play():Void {
		this.toEnd();
	}

	/**
		Pauses the effect.

		@since 1.0.0
	**/
	public function pause():Void {}

	/**
		Plays the effect in reverse.

		@since 1.0.0
	**/
	public function playReverse():Void {
		this.toEnd();
	}

	/**
		Stops the effect.

		@since 1.0.0
	**/
	public function stop():Void {
		this.toEnd();
	}

	/**
		Immediately advances the effect to the end.

		@since 1.0.0
	**/
	public function toEnd():Void {
		FeathersEvent.dispatch(this, Event.COMPLETE);
	}

	/**
		Interrupts the effect, if it is playing.

		@since 1.0.0
	**/
	public function interrupt():Void {
		this.toEnd();
	}
}

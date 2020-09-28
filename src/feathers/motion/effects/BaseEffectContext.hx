/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.motion.effects;

import openfl.events.Event;
import feathers.events.FeathersEvent;
import motion.Actuate;
import motion.actuators.IGenericActuator;
import motion.easing.IEasing;
import openfl.events.EventDispatcher;

@:event(openfl.events.Event.COMPLETE)

/**
	An abstract base class for `IEffectContext` implementations.

	@see [Effects and animation for Feathers UI components](https://feathersui.com/learn/haxe-openfl/effects-and-animation/)

	@since 1.0.0
**/
class BaseEffectContext extends EventDispatcher implements IEffectContext {
	private function new(target:Dynamic, duration:Float, ?ease:IEasing) {
		super();
		this._target = target;
		this._duration = duration;
		this._ease = ease;
	}

	private var _target:Dynamic;

	/**
		The effect's target object, which may be modified in some way, such as
		animating one of the target's properties.

		@since 1.0.0
	**/
	@:flash.property
	public var target(get, never):Dynamic;

	private function get_target():Dynamic {
		return this._target;
	}

	private var _duration:Float = 0.0;

	/**
		The total running time of the effect, measured in seconds.

		@since 1.0.0
	**/
	@:flash.property
	public var duration(get, never):Float;

	private function get_duration():Float {
		return this._duration;
	}

	private var _position:Float = 0.0;

	/**
		The current position of the effect, in the range of `0.0` to `1.0`.

		@see `BaseEffectContext.duration`

		@since 1.0.0
	**/
	@:flash.property
	public var position(get, set):Float;

	private function get_position():Float {
		return this._position;
	}

	private function set_position(value:Float):Float {
		if (this._position == value) {
			return this._position;
		}
		this._position = value;
		this.updateEffect();
		return this._position;
	}

	private var _ease:IEasing;

	/**
		The easing function to use for animation.

		@since 1.0.0
	**/
	@:flash.property
	public var ease(get, never):IEasing;

	private function get_ease():IEasing {
		return this._ease;
	}

	private var _playing:Bool = false;
	private var _reversed:Bool = false;
	private var _animatePlayback:IGenericActuator;

	/**
		Starts playing the effect from the current position.

		@since 1.0.0
	**/
	public function play():Void {
		if (this._playing && !this._reversed) {
			// already playing in the correct direction
			return;
		}
		if (this._animatePlayback != null) {
			Actuate.stop(this._animatePlayback, null, false, false);
			this._animatePlayback = null;
		}
		this._playing = true;
		this._reversed = false;

		var duration = this._duration * (1.0 - this._position);
		// using Actuate.update() instead of Actuate.tween() because tween()
		// fails when using -dce full
		this._animatePlayback = Actuate.update(function(value:Float):Void {
			position = value;
		}, duration, [this._position], [1.0]);
		this._animatePlayback.ease(this._ease);
		this._animatePlayback.onComplete(this.animatePlayback_onComplete);
	}

	/**
		Starts playing the effect from its current position back to the
		beginning (completing at a position of `0.0`).

		@since 1.0.0
	**/
	public function playReverse():Void {
		if (this._playing && this._reversed) {
			// already playing in the correct direction
			return;
		}
		if (this._animatePlayback != null) {
			Actuate.stop(this._animatePlayback, null, false, false);
			this._animatePlayback = null;
		}
		this._playing = true;
		this._reversed = true;

		var duration = this._duration * this._position;
		// using Actuate.update() instead of Actuate.tween() because tween()
		// fails when using -dce full
		this._animatePlayback = Actuate.update(function(value:Float):Void {
			position = value;
		}, duration, [this._position], [0.0]);
		this._animatePlayback.ease(this._ease);
		this._animatePlayback.onComplete(this.animatePlayback_onComplete);
	}

	/**
		Pauses an effect that is playing at the current position.

		@since 1.0.0
	**/
	public function pause():Void {
		if (!this._playing) {
			// already paused
			return;
		}
		if (this._animatePlayback != null) {
			Actuate.stop(this._animatePlayback, null, false, false);
			this._animatePlayback = null;
		}
		this._playing = false;
	}

	/**
		Stops the effect at its current position and forces `Event.COMPLETE` to
		be dispatched.

		@see `BaseEffectContext.toEnd`

		@since 1.0.0
	**/
	public function stop():Void {
		this.pause();
		this.cleanupEffect();
		FeathersEvent.dispatch(this, Event.COMPLETE);
	}

	/**
		Advances the effect immediately to the end and forces `Event.COMPLETE`
		to be dispatched.

		@see `BaseEffectContext.stop`

		@since 1.0.0
	**/
	public function toEnd():Void {
		this.pause();
		this._position = 1.0;
		this.cleanupEffect();
		FeathersEvent.dispatch(this, Event.COMPLETE);
	}

	/**
		Interrupts the playing effect, but it will be allowed to determine on
		its own whether this call behaves like `stop()` or if it behaves like
		`toEnd()` instead.

		@see `BaseEffectContext.stop`
		@see `BaseEffectContext.toEnd`

		@since 1.0.0
	**/
	public function interrupt():Void {
		// by default, go to the end. subclasses may override this method
		// to customize the behavior, if needed.
		this.toEnd();
	}

	/**
		Called when the effect is initialized. Subclasses may override this
		method to customize the effect's behavior.

		@since 1.0.0
	**/
	@:dox(show)
	private function prepareEffect():Void {}

	/**
		Called when the effect's position is updated. Subclasses may override
		this method to customize the effect's behavior.

		@since 1.0.0
	**/
	@:dox(show)
	private function updateEffect():Void {}

	/**
		Called when the effect completes or is interrupted. Subclasses may
		override this method to customize the effect's behavior.

		@since 1.0.0
	**/
	@:dox(show)
	private function cleanupEffect():Void {}

	private function animatePlayback_onComplete():Void {
		this._animatePlayback = null;
		this.cleanupEffect();
		FeathersEvent.dispatch(this, Event.COMPLETE);
	}
}

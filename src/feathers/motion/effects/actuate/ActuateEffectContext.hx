/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.motion.effects.actuate;

import motion.easing.Linear;

/**
	A Feathers UI effect context that uses the
	[Actuate](https://lib.haxe.org/p/actuate/) library.

	To create actuators for use with `ActuateEffectContext`, use the static
	functions from the `ActuateForEffects` class instead of the standard
	`Actuate` class. `ActuateEffectContext` requires special actuators with
	several extra properties that don't exist on the default `IGenericActuator`
	interface returned by the methods on `Actuate`.

	In the following example, a custom effect is created with
	`ActuateForEffects` and `ActuateEffectContext`:

	```haxe
	var customFadeOutEffect = function(target:Dynamic):IEffectContext
	{
		var actuator = ActuateForEffects.tween(target, 1.0, {alpha: 0.0});
		return new ActuateEffectContext(target, actuator);
	};
	```

	@see `feathers.motion.effects.actuate.ActuateForEffects`
	@see [Actuate on Haxelib](https://lib.haxe.org/p/actuate/)
	@see [@jgranick/actuate on Github](https://github.com/jgranick/actuate)
	@see [Effects and animation for Feathers UI components](https://feathersui.com/learn/haxe-openfl/effects-and-animation/)

	@since 1.0.0
**/
class ActuateEffectContext extends BaseEffectContext {
	/**
		Creates a new `ActuateEffectContext` object from the given arguments.

		@since 1.0.0
	**/
	public function new(target:Dynamic, actuator:IReadableGenericActuator, interruptBehavior:EffectInterruptBehavior = END) {
		this._actuator = actuator;
		this.interruptBehavior = interruptBehavior;

		var originalEase = this._actuator.getEase();

		// we want setting the position property to be linear, but when
		// play() or playReverse() is called, we'll use the saved transition
		this._actuator.ease(Linear.easeNone);

		this._onComplete = this._actuator.getOnComplete();
		this._onCompleteParams = this._actuator.getOnCompleteParams();
		this._actuator.onComplete(null, null);

		if (target == null) {
			target = this._actuator.getTarget();
		}

		super(target, this._actuator.getDuration(), originalEase);
	}

	private var _actuator:IReadableGenericActuator;

	/**
		The actuator that is controlled by the effect.

		@see `feathers.motion.effects.actuate.ActuateForEffects`

		@since 1.0.0
	**/
	public var actuator(get, never):IReadableGenericActuator;

	private function get_actuator():IReadableGenericActuator {
		return this._actuator;
	}

	/**
		Indicates how the effect behaves when it is interrupted. Interrupted
		effects can either advance directly to the end or stop at the current
		position.

		@default `feathers.motion.EffectInterruptBehavior.END`

		@see `feathers.motion.EffectInterruptBehavior.END`
		@see `feathers.motion.EffectInterruptBehavior.STOP`
		@see `ActuateEffectContext.interrupt`

		@since 1.0.0
	**/
	public var interruptBehavior:EffectInterruptBehavior;

	private var _onComplete:Dynamic;
	private var _onCompleteParams:Array<Dynamic>;

	override public function interrupt():Void {
		if (this.interruptBehavior == STOP) {
			this.stop();
			return;
		}
		this.toEnd();
	}

	override private function updateEffect():Void {
		this._actuator.goto(this.position);
	}

	override private function cleanupEffect():Void {
		if (this._onComplete != null) {
			var params = this._onCompleteParams;
			if (params == null) {
				params = [];
			}
			Reflect.callMethod(this._onComplete, this._onComplete, params);
		}
	}
}

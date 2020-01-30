/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.motion.effects.actuate;

import motion.Actuate;

/**
	A wrapper around [Actuate](https://lib.haxe.org/p/actuate/) that is used to
	create special actuators for custom Feathers UI effects.

	In the following example, a custom effect is created with
	`ActuateForEffects` and `ActuateEffectContext`:

	```hx
	var customFadeOutEffect = function(target:Dynamic):IEffectContext
	{
		var actuator = ActuateForEffects.tween(target, 1.0, {alpha: 0.0});
		return new ActuateEffectContext(target, actuator);
	};
	```

	@see `feathers.motion.effects.actuate.ActuateEffectContext`
	@see [Actuate on Haxelib](https://lib.haxe.org/p/actuate/)
	@see [@jgranick/actuate on Github](https://github.com/jgranick/actuate)
	@see [Effects and animation for Feathers UI components](https://feathersui.com/learn/haxe-openfl/effects-and-animation/)

	@since 1.0.0
**/
class ActuateForEffects {
	/**
		Similar to `Actuate.tween()`, but it creates a special type of actuator
		that may be used with `ActuateEffectContext` to create custom Feathers
		effects.

		@since 1.0.0
	**/
	public static function tween(target:Dynamic, duration:Float, properties:Dynamic, overwrite:Bool = true):IReadableGenericActuator {
		var result = Actuate.tween(target, duration, properties, overwrite, SimpleEffectActuator);
		return cast(result, IReadableGenericActuator);
	}

	/**
		Similar to `Actuate.update()`, but it creates a special type of actuator
		that may be used with `ActuateEffectContext` to create custom Feathers
		effects.

		@since 1.0.0
	**/
	public static function update(target:Dynamic, duration:Float, start:Dynamic, end:Dynamic, overwrite:Bool = true):IReadableGenericActuator {
		var properties:Dynamic = {start: start, end: end};
		var result = Actuate.tween(target, duration, properties, overwrite, MethodEffectActuator);
		return cast(result, IReadableGenericActuator);
	}
}

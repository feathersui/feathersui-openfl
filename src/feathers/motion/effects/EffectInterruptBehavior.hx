/*
	Feathers
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.motion.effects;

/**
	Constants for determining how an effect behaves when it is interrupted.

	@see `feathers.motion.effectClasses.IEffectContext.interrupt()`
	@see [Effects and animation for Feathers components](../../../help/effects.html)

	@since 1.0.0
**/
@:enum
abstract EffectInterruptBehavior(String) {
	/**
		When the effect is interrupted, it immediately advances to the end.

		@since 1.0.0
	**/
	var END = "end";

	/**
		When the effect is interrupted, it stops at its current position.

		@since 1.0.0
	**/
	var STOP = "stop";
}

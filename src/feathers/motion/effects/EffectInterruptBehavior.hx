/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.motion.effects;

/**
	Constants for determining how an effect behaves when it is interrupted.

	@see `feathers.motion.effectClasses.IEffectContext.interrupt()`
	@see [Effects and animation for Feathers UI components](https://feathersui.com/learn/haxe-openfl/effects-and-animation/)

	@since 1.0.0
**/
enum EffectInterruptBehavior {
	/**
		When the effect is interrupted, it immediately advances to the end.

		@since 1.0.0
	**/
	END;

	/**
		When the effect is interrupted, it stops at its current position.

		@since 1.0.0
	**/
	STOP;
}

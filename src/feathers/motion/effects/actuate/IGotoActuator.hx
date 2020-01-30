/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.motion.effects.actuate;

import motion.actuators.IGenericActuator;

/**
	Extends `IGenericActuator` to add a `goto()` method that allows the
	actuator's position to be updated manually.

	@since 1.0.0
**/
interface IGotoActuator extends IGenericActuator {
	/**
		Updates the position using a value between `0.0` and `1.0`.

		@since 1.0.0
	**/
	function goto(position:Float):Void;
}

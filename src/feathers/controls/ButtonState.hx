/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

/**
	States for button components.

	@since 1.0.0
**/
@:enum
abstract ButtonState(String) {
	/**
		The up state, when there is no interaction.

		@since 1.0.0
	**/
	var UP = "up";

	/**
		The hover state, when the mouse is over the component. This state is not
		used with touch.

		@since 1.0.0
	**/
	var HOVER = "hover";

	/**
		The down state, on mouse down or touch begin.

		@since 1.0.0
	**/
	var DOWN = "down";

	/**
		The disabled state, when the component's `enabled` property is `false`.

		@since 1.0.0
	**/
	var DISABLED = "disabled";

	@:to
	public function toString() {
		return this;
	}
}

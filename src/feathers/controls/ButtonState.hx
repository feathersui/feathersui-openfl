/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

/**
	States for `Button` components.

	@see `feathers.controls.Button`

	@since 1.0.0
**/
enum ButtonState {
	/**
		The up state, when there is no interaction.

		@since 1.0.0
	**/
	UP;

	/**
		The hover state, when the mouse is over the component. This state is not
		used with touch.

		@since 1.0.0
	**/
	HOVER;

	/**
		The down state, on mouse down or touch begin.

		@since 1.0.0
	**/
	DOWN;

	/**
		The disabled state, when the component's `enabled` property is `false`.

		@since 1.0.0
	**/
	DISABLED;
}

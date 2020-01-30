/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

/**
	States for toggle button components, including controls like `ToggleButton`,
	`Check`, `Radio`, and data renderers.

	@see `feathers.controls.ToggleButton`
	@see `feathers.controls.Check`
	@see `feathers.controls.Radio`

	@since 1.0.0
**/
enum ToggleButtonState {
	/**
		The up state, when there is no interaction.

		@since 1.0.0
	**/
	UP(selected:Bool);

	/**
		The hover state, when the mouse is over the component. This state is not
		used with touch.

		@since 1.0.0
	**/
	HOVER(selected:Bool);

	/**
		The down state, on mouse down or touch begin.

		@since 1.0.0
	**/
	DOWN(selected:Bool);

	/**
		The disabled state, when the component's `enabled` property is `false`.

		@since 1.0.0
	**/
	DISABLED(selected:Bool);
}

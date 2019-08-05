/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

/**
	States for toggle button components, including controls like `ToggleButton`,
	`CheckBox`, `Radio`, and data renderers.

	@since 1.0.0
**/
@:enum
abstract ToggleButtonState(String) {
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

	/**
		The up state, when the component is selected.

		@since 1.0.0
	**/
	var UP_AND_SELECTED = "upAndSelected";

	/**
		The hover state, when the component is selected.

		@since 1.0.0
	**/
	var HOVER_AND_SELECTED = "hoverAndSelected";

	/**
		The down state, when the component is selected.

		@since 1.0.0
	**/
	var DOWN_AND_SELECTED = "downAndSelected";

	/**
		The disabled state, when the component is selected.

		@since 1.0.0
	**/
	var DISABLED_AND_SELECTED = "disabledAndSelected";

	@:to
	public function toString() {
		return this;
	}
}

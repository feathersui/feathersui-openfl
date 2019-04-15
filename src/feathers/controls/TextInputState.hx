/*
	Feathers
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

/**
	States for text input components.

	@see `feathers.controls.TextInput`

	@since 1.0.0
**/
@:enum
abstract TextInputState(String) {
	/**
		The default state, when the input is enabled.

		@since 1.0.0
	**/
	var ENABLED = "enabled";

	/**
		The disabled state, when the input is not enabled.

		@since 1.0.0
	**/
	var DISABLED = "disabled";

	/**
		The focused state, when the input is currently in focus and the user can
		type on the keyboard.

		@since 1.0.0
	**/
	var FOCUSED = "down";

	/**
		The state when the input has an error string and is not focused.

		@since 1.0.0
	**/
	var ERROR = "error";

	@:to
	public function toString() {
		return this;
	}
}

/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

/**
	A user interface control that displays text.

	@since 1.0.0
**/
interface ITextControl extends IUIControl {
	/**
		The text to display.

		@since 1.0.0
	**/
	@:flash.property
	public var text(get, set):String;

	/**
		The baseline of the text, measured from the top of the control. May be
		used in layouts.

		Note: This property may not return the correct value when the control is
		in an invalid state. To be safe, call `validateNow()` before accessing
		this value.

		@since 1.0.0
	**/
	@:flash.property
	public var baseline(get, never):Float;
}

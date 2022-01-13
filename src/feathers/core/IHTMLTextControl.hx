/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

/**
	A user interface control that displays HTML text.

	@since 1.0.0
**/
interface IHTMLTextControl extends IUIControl {
	/**
		The HTML text to display.

		@since 1.0.0
	**/
	public var htmlText(get, set):String;
}

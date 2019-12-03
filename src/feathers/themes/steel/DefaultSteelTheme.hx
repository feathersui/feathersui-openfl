/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel;

/**
	@since 1.0.0
**/
class DefaultSteelTheme extends BaseSteelTheme {
	/**
		Creates a new `DefaultSteelTheme` object with the given arguments.

		@since 1.0.0
	**/
	public function new(?themeColor:Int, ?darkThemeColor:Int) {
		super(themeColor, darkThemeColor);
		// the default steel theme doesn't automatically add all style providers
		// instead, they're added as components are used by the app
		// this prevents unused code from being included in the final output
	}
}

/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.TextInputState;
import feathers.controls.TextInput;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

/**
	Initialize "steel" styles for the `TextInput` component.

	@since 1.0.0
**/
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelTextInputStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}
		if (theme.styleProvider.getStyleFunction(TextInput, null) == null) {
			theme.styleProvider.setStyleFunction(TextInput, null, setStyles);
		}
	}

	private static function setStyles(input:TextInput):Void {
		var theme = Std.downcast(Theme.getTheme(input), BaseSteelTheme);
		if (theme == null) {
			return;
		}

		if (input.backgroundSkin == null) {
			var inputSkin = new RectangleSkin();
			inputSkin.cornerRadius = 6.0;
			inputSkin.width = 160.0;
			inputSkin.fill = theme.getInsetFill();
			inputSkin.border = theme.getInsetBorder();
			inputSkin.setBorderForState(TextInputState.FOCUSED, theme.getThemeBorder());
			input.backgroundSkin = inputSkin;
		}

		if (input.textFormat == null) {
			input.textFormat = theme.getTextFormat();
		}
		if (input.disabledTextFormat == null) {
			input.disabledTextFormat = theme.getDisabledTextFormat();
		}

		input.paddingTop = 6.0;
		input.paddingRight = 10.0;
		input.paddingBottom = 6.0;
		input.paddingLeft = 10.0;
	}
}

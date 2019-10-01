/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.ButtonState;
import feathers.controls.Button;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

/**
	Initialize "steel" styles for the `Button` component.

	@since 1.0.0
**/
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelButtonStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(Button, null) != null) {
			return;
		}

		styleProvider.setStyleFunction(Button, null, function(button:Button):Void {
			if (button.backgroundSkin == null) {
				var skin = new RectangleSkin();
				skin.fill = theme.getButtonFill();
				skin.setFillForState(ButtonState.DOWN, theme.getReversedActiveThemeFill());
				skin.setFillForState(ButtonState.DISABLED, theme.getButtonDisabledFill());
				skin.border = theme.getButtonBorder();
				skin.setBorderForState(ButtonState.DOWN, theme.getActiveFillBorder());
				skin.cornerRadius = 6.0;
				button.backgroundSkin = skin;
			}

			if (button.textFormat == null) {
				button.textFormat = theme.getTextFormat();
			}
			if (button.disabledTextFormat == null) {
				button.disabledTextFormat = theme.getDisabledTextFormat();
			}

			if (button.getTextFormatForState(ButtonState.DOWN) == null) {
				button.setTextFormatForState(ButtonState.DOWN, theme.getActiveTextFormat());
			}

			button.paddingTop = 4.0;
			button.paddingRight = 10.0;
			button.paddingBottom = 4.0;
			button.paddingLeft = 10.0;
			button.gap = 6.0;
		});
	}
}

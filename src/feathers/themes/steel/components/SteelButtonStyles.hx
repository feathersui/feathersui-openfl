/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

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
@:dox(hide)
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
		if (styleProvider.getStyleFunction(Button, null) == null) {
			styleProvider.setStyleFunction(Button, null, function(button:Button):Void {
				if (button.backgroundSkin == null) {
					var skin = new RectangleSkin();
					skin.fill = theme.getButtonFill();
					skin.setFillForState(DOWN, theme.getReversedActiveThemeFill());
					skin.setFillForState(DISABLED, theme.getButtonDisabledFill());
					skin.border = theme.getButtonBorder();
					skin.setBorderForState(DOWN, theme.getActiveFillBorder());
					skin.cornerRadius = 6.0;
					button.backgroundSkin = skin;
				}

				if (button.focusRectSkin == null) {
					var skin = new RectangleSkin();
					skin.fill = null;
					skin.border = theme.getFocusBorder();
					skin.cornerRadius = 6.0;
					button.focusRectSkin = skin;
				}

				if (button.textFormat == null) {
					button.textFormat = theme.getTextFormat();
				}
				if (button.getTextFormatForState(DOWN) == null) {
					button.setTextFormatForState(DOWN, theme.getActiveTextFormat());
				}
				if (button.getTextFormatForState(DISABLED) == null) {
					button.setTextFormatForState(DISABLED, theme.getDisabledTextFormat());
				}

				button.paddingTop = 4.0;
				button.paddingRight = 10.0;
				button.paddingBottom = 4.0;
				button.paddingLeft = 10.0;
				button.gap = 6.0;
			});
		}
	}
}

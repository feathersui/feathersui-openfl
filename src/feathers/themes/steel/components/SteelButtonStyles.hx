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
					skin.cornerRadius = 3.0;
					button.backgroundSkin = skin;
				}

				if (button.focusRectSkin == null) {
					var focusRectSkin = new RectangleSkin();
					focusRectSkin.fill = null;
					focusRectSkin.border = theme.getFocusBorder();
					focusRectSkin.cornerRadius = 3.0;
					button.focusRectSkin = focusRectSkin;
				}

				if (button.textFormat == null) {
					button.textFormat = theme.getTextFormat();
				}
				if (button.disabledTextFormat == null) {
					button.disabledTextFormat = theme.getDisabledTextFormat();
				}

				button.paddingTop = 4.0;
				button.paddingRight = 10.0;
				button.paddingBottom = 4.0;
				button.paddingLeft = 10.0;
				button.gap = 4.0;
			});
		}
		if (styleProvider.getStyleFunction(Button, Button.VARIANT_PRIMARY) == null) {
			styleProvider.setStyleFunction(Button, Button.VARIANT_PRIMARY, function(button:Button):Void {
				if (button.backgroundSkin == null) {
					var skin = new RectangleSkin();
					skin.fill = theme.getActiveThemeFill();
					skin.setFillForState(DOWN, theme.getReversedActiveThemeFill());
					skin.setFillForState(DISABLED, theme.getButtonDisabledFill());
					skin.border = theme.getActiveFillBorder();
					skin.disabledBorder = theme.getButtonBorder();
					skin.cornerRadius = 3.0;
					button.backgroundSkin = skin;
				}

				if (button.focusRectSkin == null) {
					var focusRectSkin = new RectangleSkin();
					focusRectSkin.fill = null;
					focusRectSkin.border = theme.getFocusBorder();
					focusRectSkin.cornerRadius = 3.0;
					button.focusRectSkin = focusRectSkin;
				}

				if (button.textFormat == null) {
					button.textFormat = theme.getTextFormat();
				}
				if (button.disabledTextFormat == null) {
					button.disabledTextFormat = theme.getDisabledTextFormat();
				}

				button.paddingTop = 4.0;
				button.paddingRight = 10.0;
				button.paddingBottom = 4.0;
				button.paddingLeft = 10.0;
				button.gap = 4.0;
			});
		}
		if (styleProvider.getStyleFunction(Button, Button.VARIANT_DANGER) == null) {
			styleProvider.setStyleFunction(Button, Button.VARIANT_DANGER, function(button:Button):Void {
				if (button.backgroundSkin == null) {
					var skin = new RectangleSkin();
					skin.fill = theme.getDangerFill();
					skin.setFillForState(DOWN, theme.getReversedDangerFill());
					skin.setFillForState(DISABLED, theme.getButtonDisabledFill());
					skin.border = theme.getDangerBorder();
					skin.disabledBorder = theme.getButtonBorder();
					skin.cornerRadius = 3.0;
					button.backgroundSkin = skin;
				}

				if (button.focusRectSkin == null) {
					var focusRectSkin = new RectangleSkin();
					focusRectSkin.fill = null;
					focusRectSkin.border = theme.getFocusBorder();
					focusRectSkin.cornerRadius = 3.0;
					button.focusRectSkin = focusRectSkin;
				}

				if (button.textFormat == null) {
					button.textFormat = theme.getTextFormat();
				}
				if (button.disabledTextFormat == null) {
					button.disabledTextFormat = theme.getDisabledTextFormat();
				}

				button.paddingTop = 4.0;
				button.paddingRight = 10.0;
				button.paddingBottom = 4.0;
				button.paddingLeft = 10.0;
				button.gap = 4.0;
			});
		}
	}
}

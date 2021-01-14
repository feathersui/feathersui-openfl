/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.ToggleButtonState;
import feathers.controls.ToggleButton;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

/**
	Initialize "steel" styles for the `ToggleButton` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelToggleButtonStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(ToggleButton, null) == null) {
			styleProvider.setStyleFunction(ToggleButton, null, function(button:ToggleButton):Void {
				if (button.backgroundSkin == null) {
					var skin = new RectangleSkin();
					skin.fill = theme.getButtonFill();
					skin.disabledFill = theme.getButtonDisabledFill();
					skin.selectedFill = theme.getThemeFill();
					skin.setFillForState(DOWN(false), theme.getReversedActiveThemeFill());
					skin.setFillForState(DOWN(false), theme.getReversedActiveThemeFill());
					skin.border = theme.getButtonBorder();
					skin.selectedBorder = theme.getSelectedBorder();
					skin.setBorderForState(DOWN(false), theme.getActiveFillBorder());
					skin.setBorderForState(DOWN(true), theme.getActiveFillBorder());
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

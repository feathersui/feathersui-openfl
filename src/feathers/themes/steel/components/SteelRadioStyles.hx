/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.Radio;
import feathers.controls.ToggleButtonState;
import feathers.skins.CircleSkin;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;
import openfl.display.Shape;

/**
	Initialize "steel" styles for the `Radio` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelRadioStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(Radio, null) == null) {
			styleProvider.setStyleFunction(Radio, null, function(radio:Radio):Void {
				if (radio.textFormat == null) {
					radio.textFormat = theme.getTextFormat();
				}
				if (radio.disabledTextFormat == null) {
					radio.disabledTextFormat = theme.getDisabledTextFormat();
				}

				var icon = new CircleSkin();
				icon.width = 24.0;
				icon.height = 24.0;
				icon.minWidth = 24.0;
				icon.minHeight = 24.0;
				icon.border = theme.getInsetBorder(2.0);
				icon.setBorderForState(ToggleButtonState.DOWN(false), theme.getThemeBorder(2.0));
				icon.fill = theme.getInsetFill();
				icon.disabledFill = theme.getDisabledInsetFill();
				radio.icon = icon;

				var selectedIcon = new CircleSkin();
				selectedIcon.width = 24.0;
				selectedIcon.height = 24.0;
				selectedIcon.minWidth = 24.0;
				selectedIcon.minHeight = 24.0;
				selectedIcon.border = theme.getInsetBorder(2.0);
				selectedIcon.setBorderForState(ToggleButtonState.DOWN(true), theme.getThemeBorder(2.0));
				selectedIcon.fill = theme.getInsetFill();
				selectedIcon.disabledFill = theme.getDisabledInsetFill();

				var symbol = new Shape();
				symbol.graphics.beginFill(theme.themeColor);
				symbol.graphics.drawCircle(12.0, 12.0, 6.0);
				symbol.graphics.endFill();
				selectedIcon.addChild(symbol);

				radio.selectedIcon = selectedIcon;

				var disabledAndSelectedIcon = new CircleSkin();
				disabledAndSelectedIcon.width = 24.0;
				disabledAndSelectedIcon.height = 24.0;
				disabledAndSelectedIcon.minWidth = 24.0;
				disabledAndSelectedIcon.minHeight = 24.0;
				disabledAndSelectedIcon.border = theme.getInsetBorder(2.0);
				disabledAndSelectedIcon.fill = theme.getDisabledInsetFill();

				var disabledSymbol = new Shape();
				disabledSymbol.graphics.beginFill(theme.disabledTextColor);
				disabledSymbol.graphics.drawCircle(12.0, 12.0, 6.0);
				disabledSymbol.graphics.endFill();
				disabledAndSelectedIcon.addChild(disabledSymbol);

				radio.setIconForState(ToggleButtonState.DISABLED(true), disabledAndSelectedIcon);

				if (radio.focusRectSkin == null) {
					var skin = new RectangleSkin();
					skin.fill = null;
					skin.border = theme.getFocusBorder();
					skin.cornerRadius = 6.0;
					radio.focusRectSkin = skin;
				}

				radio.gap = 6.0;
			});
		}
	}
}

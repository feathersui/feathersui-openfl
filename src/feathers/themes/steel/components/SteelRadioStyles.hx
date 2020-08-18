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

				if (radio.backgroundSkin == null) {
					var backgroundSkin = new RectangleSkin();
					backgroundSkin.fill = SolidColor(0x000000, 0.0);
					backgroundSkin.border = null;
					radio.backgroundSkin = backgroundSkin;
				}

				var icon = new CircleSkin();
				icon.width = 20.0;
				icon.height = 20.0;
				icon.minWidth = 20.0;
				icon.minHeight = 20.0;
				icon.border = theme.getInsetBorder();
				icon.disabledBorder = theme.getDisabledInsetBorder();
				icon.setBorderForState(ToggleButtonState.DOWN(false), theme.getSelectedInsetBorder());
				icon.fill = theme.getInsetFill();
				icon.disabledFill = theme.getDisabledInsetFill();
				radio.icon = icon;

				var selectedIcon = new CircleSkin();
				selectedIcon.width = 20.0;
				selectedIcon.height = 20.0;
				selectedIcon.minWidth = 20.0;
				selectedIcon.minHeight = 20.0;
				selectedIcon.border = theme.getSelectedInsetBorder();
				selectedIcon.disabledBorder = theme.getDisabledInsetBorder();
				selectedIcon.setBorderForState(DOWN(true), theme.getSelectedInsetBorder());
				selectedIcon.fill = theme.getReversedActiveThemeFill();
				selectedIcon.disabledFill = theme.getDisabledInsetFill();

				var symbol = new Shape();
				symbol.graphics.beginFill(theme.textColor);
				symbol.graphics.drawCircle(10.0, 10.0, 4.0);
				symbol.graphics.endFill();
				selectedIcon.addChild(symbol);

				radio.selectedIcon = selectedIcon;

				var disabledAndSelectedIcon = new CircleSkin();
				disabledAndSelectedIcon.width = 20.0;
				disabledAndSelectedIcon.height = 20.0;
				disabledAndSelectedIcon.minWidth = 20.0;
				disabledAndSelectedIcon.minHeight = 20.0;
				disabledAndSelectedIcon.border = theme.getDisabledInsetBorder(2.0);
				disabledAndSelectedIcon.fill = theme.getDisabledInsetFill();

				var disabledSymbol = new Shape();
				disabledSymbol.graphics.beginFill(theme.disabledTextColor);
				disabledSymbol.graphics.drawCircle(10.0, 10.0, 4.0);
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

				radio.horizontalAlign = LEFT;
				radio.gap = 4.0;
			});
		}
	}
}

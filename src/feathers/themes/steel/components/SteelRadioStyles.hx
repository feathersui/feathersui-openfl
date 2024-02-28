/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.Radio;
import feathers.controls.ToggleButtonState;
import feathers.skins.CircleSkin;
import feathers.skins.MultiSkin;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;
import feathers.utils.DeviceUtil;
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
				var isDesktop = DeviceUtil.isDesktop();

				if (radio.textFormat == null) {
					radio.textFormat = theme.getTextFormat();
				}
				if (radio.disabledTextFormat == null) {
					radio.disabledTextFormat = theme.getDisabledTextFormat();
				}

				if (radio.backgroundSkin == null) {
					var backgroundSkin = new RectangleSkin();
					backgroundSkin.fill = SolidColor(0x000000, 0.0);
					backgroundSkin.border = None;
					radio.backgroundSkin = backgroundSkin;
				}

				if (radio.icon == null) {
					var icon = new MultiSkin();
					radio.icon = icon;

					var defaultIcon = new CircleSkin();
					if (isDesktop) {
						defaultIcon.width = 16.0;
						defaultIcon.height = 16.0;
						defaultIcon.minWidth = 16.0;
						defaultIcon.minHeight = 16.0;
					} else {
						defaultIcon.width = 20.0;
						defaultIcon.height = 20.0;
						defaultIcon.minWidth = 20.0;
						defaultIcon.minHeight = 20.0;
					}
					defaultIcon.border = theme.getInsetBorder();
					defaultIcon.disabledBorder = theme.getDisabledInsetBorder();
					defaultIcon.setBorderForState(DOWN(false), theme.getSelectedInsetBorder());
					defaultIcon.fill = theme.getInsetFill();
					defaultIcon.disabledFill = theme.getDisabledInsetFill();
					icon.defaultView = defaultIcon;

					var selectedIcon = new CircleSkin();
					if (isDesktop) {
						selectedIcon.width = 16.0;
						selectedIcon.height = 16.0;
						selectedIcon.minWidth = 16.0;
						selectedIcon.minHeight = 16.0;
					} else {
						selectedIcon.width = 20.0;
						selectedIcon.height = 20.0;
						selectedIcon.minWidth = 20.0;
						selectedIcon.minHeight = 20.0;
					}
					selectedIcon.border = theme.getSelectedInsetBorder();
					selectedIcon.disabledBorder = theme.getDisabledInsetBorder();
					selectedIcon.setBorderForState(DOWN(true), theme.getSelectedInsetBorder());
					selectedIcon.fill = theme.getReversedActiveThemeFill();
					selectedIcon.disabledFill = theme.getDisabledInsetFill();
					var symbol = new Shape();
					symbol.graphics.beginFill(theme.textColor);
					if (isDesktop) {
						symbol.graphics.drawCircle(8.0, 8.0, 3.0);
					} else {
						symbol.graphics.drawCircle(10.0, 10.0, 4.0);
					}
					symbol.graphics.endFill();
					selectedIcon.addChild(symbol);
					icon.selectedView = selectedIcon;

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
					icon.setViewForState(DISABLED(true), disabledAndSelectedIcon);
				}

				if (radio.focusRectSkin == null) {
					var focusRectSkin = new RectangleSkin();
					focusRectSkin.fill = None;
					focusRectSkin.border = theme.getFocusBorder();
					focusRectSkin.cornerRadius = 3.0;
					radio.focusRectSkin = focusRectSkin;

					radio.focusPaddingTop = 3.0;
					radio.focusPaddingRight = 3.0;
					radio.focusPaddingBottom = 3.0;
					radio.focusPaddingLeft = 3.0;
				}

				radio.horizontalAlign = LEFT;
				radio.gap = theme.smallPadding;
			});
		}
	}
}

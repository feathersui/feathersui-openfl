/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.skins.MultiSkin;
import openfl.display.Shape;
import feathers.controls.ToggleButtonState;
import feathers.skins.RectangleSkin;
import feathers.controls.Check;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

/**
	Initialize "steel" styles for the `Check` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelCheckStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(Check, null) == null) {
			styleProvider.setStyleFunction(Check, null, function(check:Check):Void {
				if (check.textFormat == null) {
					check.textFormat = theme.getTextFormat();
				}
				if (check.disabledTextFormat == null) {
					check.disabledTextFormat = theme.getDisabledTextFormat();
				}

				if (check.backgroundSkin == null) {
					var backgroundSkin = new RectangleSkin();
					backgroundSkin.fill = SolidColor(0x000000, 0.0);
					backgroundSkin.border = null;
					check.backgroundSkin = backgroundSkin;
				}

				if (check.icon == null) {
					var icon = new MultiSkin();
					check.icon = icon;

					var defaultIcon = new RectangleSkin();
					defaultIcon.width = 20.0;
					defaultIcon.height = 20.0;
					defaultIcon.minWidth = 20.0;
					defaultIcon.minHeight = 20.0;
					defaultIcon.border = theme.getInsetBorder();
					defaultIcon.disabledBorder = theme.getDisabledInsetBorder();
					defaultIcon.setBorderForState(DOWN(false), theme.getSelectedInsetBorder());
					defaultIcon.fill = theme.getInsetFill();
					defaultIcon.disabledFill = theme.getDisabledInsetFill();
					icon.defaultView = defaultIcon;

					var selectedIcon = new RectangleSkin();
					selectedIcon.width = 20.0;
					selectedIcon.height = 20.0;
					selectedIcon.minWidth = 20.0;
					selectedIcon.minHeight = 20.0;
					selectedIcon.border = theme.getSelectedInsetBorder();
					selectedIcon.disabledBorder = theme.getDisabledInsetBorder();
					selectedIcon.setBorderForState(DOWN(true), theme.getSelectedInsetBorder());
					selectedIcon.fill = theme.getReversedActiveThemeFill();
					selectedIcon.disabledFill = theme.getDisabledInsetFill();
					var checkMark = new Shape();
					checkMark.graphics.beginFill(theme.textColor);
					checkMark.graphics.drawRect(-1.0, -8.0, 3.0, 14.0);
					checkMark.graphics.endFill();
					checkMark.graphics.beginFill(theme.textColor);
					checkMark.graphics.drawRect(-5.0, 3.0, 5.0, 3.0);
					checkMark.graphics.endFill();
					checkMark.rotation = 45.0;
					checkMark.x = 10.0;
					checkMark.y = 10.0;
					selectedIcon.addChild(checkMark);
					icon.selectedView = selectedIcon;

					var disabledAndSelectedIcon = new RectangleSkin();
					disabledAndSelectedIcon.width = 20.0;
					disabledAndSelectedIcon.height = 20.0;
					disabledAndSelectedIcon.minWidth = 20.0;
					disabledAndSelectedIcon.minHeight = 20.0;
					disabledAndSelectedIcon.border = theme.getDisabledInsetBorder();
					disabledAndSelectedIcon.fill = theme.getDisabledInsetFill();
					var disabledCheckMark = new Shape();
					disabledCheckMark.graphics.beginFill(theme.disabledTextColor);
					disabledCheckMark.graphics.drawRect(-1.0, -8.0, 3.0, 14.0);
					disabledCheckMark.graphics.endFill();
					disabledCheckMark.graphics.beginFill(theme.disabledTextColor);
					disabledCheckMark.graphics.drawRect(-5.0, 3.0, 5.0, 3.0);
					disabledCheckMark.graphics.endFill();
					disabledCheckMark.rotation = 45.0;
					disabledCheckMark.x = 10.0;
					disabledCheckMark.y = 10.0;
					disabledAndSelectedIcon.addChild(disabledCheckMark);
					icon.setViewForState(DISABLED(true), disabledAndSelectedIcon);
				}

				if (check.focusRectSkin == null) {
					var focusRectSkin = new RectangleSkin();
					focusRectSkin.fill = null;
					focusRectSkin.border = theme.getFocusBorder();
					focusRectSkin.cornerRadius = 3.0;
					check.focusRectSkin = focusRectSkin;

					check.focusPaddingTop = 3.0;
					check.focusPaddingRight = 3.0;
					check.focusPaddingBottom = 3.0;
					check.focusPaddingLeft = 3.0;
				}

				check.horizontalAlign = LEFT;
				check.gap = 4.0;
			});
		}
	}
}

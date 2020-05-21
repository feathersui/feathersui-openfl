/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

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

				var icon = new RectangleSkin();
				icon.width = 24.0;
				icon.height = 24.0;
				icon.minWidth = 24.0;
				icon.minHeight = 24.0;
				icon.border = theme.getInsetBorder(2.0);
				icon.setBorderForState(DOWN(false), theme.getThemeBorder(2.0));
				icon.fill = theme.getInsetFill();
				icon.disabledFill = theme.getDisabledInsetFill();
				check.icon = icon;

				var selectedIcon = new RectangleSkin();
				selectedIcon.width = 24.0;
				selectedIcon.height = 24.0;
				selectedIcon.minWidth = 24.0;
				selectedIcon.minHeight = 24.0;
				selectedIcon.border = theme.getInsetBorder(2.0);
				selectedIcon.setBorderForState(DOWN(false), theme.getThemeBorder(2.0));
				selectedIcon.fill = theme.getInsetFill();
				selectedIcon.disabledFill = theme.getDisabledInsetFill();

				var checkMark = new Shape();
				checkMark.graphics.beginFill(theme.themeColor);
				checkMark.graphics.drawRect(-0.0, -10.0, 4.0, 18.0);
				checkMark.graphics.drawRect(-6.0, 4.0, 6.0, 4.0);
				checkMark.graphics.endFill();
				checkMark.rotation = 45.0;
				checkMark.x = 12.0;
				checkMark.y = 12.0;
				selectedIcon.addChild(checkMark);

				check.selectedIcon = selectedIcon;

				var disabledAndSelectedIcon = new RectangleSkin();
				disabledAndSelectedIcon.width = 24.0;
				disabledAndSelectedIcon.height = 24.0;
				disabledAndSelectedIcon.minWidth = 24.0;
				disabledAndSelectedIcon.minHeight = 24.0;
				disabledAndSelectedIcon.border = theme.getInsetBorder(2.0);
				disabledAndSelectedIcon.fill = theme.getDisabledInsetFill();

				var disabledCheckMark = new Shape();
				disabledCheckMark.graphics.beginFill(theme.disabledTextColor);
				disabledCheckMark.graphics.drawRect(-0.0, -10.0, 4.0, 18.0);
				disabledCheckMark.graphics.endFill();
				disabledCheckMark.graphics.beginFill(theme.disabledTextColor);
				disabledCheckMark.graphics.drawRect(-6.0, 4.0, 6.0, 4.0);
				disabledCheckMark.graphics.endFill();
				disabledCheckMark.rotation = 45.0;
				disabledCheckMark.x = 12.0;
				disabledCheckMark.y = 12.0;
				disabledAndSelectedIcon.addChild(disabledCheckMark);

				check.setIconForState(ToggleButtonState.DISABLED(true), disabledAndSelectedIcon);

				if (check.focusRectSkin == null) {
					var skin = new RectangleSkin();
					skin.fill = null;
					skin.border = theme.getFocusBorder();
					skin.cornerRadius = 6.0;
					check.focusRectSkin = skin;
				}

				check.gap = 6.0;
			});
		}
	}
}

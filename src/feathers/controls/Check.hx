/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.themes.DefaultTheme;
import feathers.style.Theme;
import openfl.display.Shape;
import feathers.skins.RectangleSkin;

/**
	@since 1.0.0
**/
@:access(feathers.themes.DefaultTheme)
@:styleContext
class Check extends ToggleButton {
	public function new() {
		var theme = Std.downcast(Theme.fallbackTheme, DefaultTheme);
		if (theme != null && theme.styleProvider.getStyleFunction(Check, null) == null) {
			theme.styleProvider.setStyleFunction(Check, null, setCheckStyles);
		}
		super();
	}

	private static function setCheckStyles(check:Check):Void {
		var defaultTheme:DefaultTheme = Std.downcast(Theme.fallbackTheme, DefaultTheme);
		if (defaultTheme == null) {
			return;
		}

		if (check.textFormat == null) {
			check.textFormat = defaultTheme.getTextFormat();
		}
		if (check.disabledTextFormat == null) {
			check.disabledTextFormat = defaultTheme.getDisabledTextFormat();
		}

		var icon = new RectangleSkin();
		icon.width = 24.0;
		icon.height = 24.0;
		icon.minWidth = 24.0;
		icon.minHeight = 24.0;
		icon.border = defaultTheme.getInsetBorder(2.0);
		icon.setBorderForState(ToggleButtonState.DOWN(false), defaultTheme.getThemeBorder(2.0));
		icon.fill = defaultTheme.getInsetFill();
		icon.disabledFill = defaultTheme.getDisabledInsetFill();
		check.icon = icon;

		var selectedIcon = new RectangleSkin();
		selectedIcon.width = 24.0;
		selectedIcon.height = 24.0;
		selectedIcon.minWidth = 24.0;
		selectedIcon.minHeight = 24.0;
		selectedIcon.border = defaultTheme.getInsetBorder(2.0);
		selectedIcon.setBorderForState(ToggleButtonState.DOWN(false), defaultTheme.getThemeBorder(2.0));
		selectedIcon.fill = defaultTheme.getInsetFill();
		selectedIcon.disabledFill = defaultTheme.getDisabledInsetFill();

		var checkMark = new Shape();
		checkMark.graphics.beginFill(defaultTheme.themeColor);
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
		disabledAndSelectedIcon.border = defaultTheme.getInsetBorder(2.0);
		disabledAndSelectedIcon.fill = defaultTheme.getDisabledInsetFill();

		var disabledCheckMark = new Shape();
		disabledCheckMark.graphics.beginFill(defaultTheme.disabledTextColor);
		disabledCheckMark.graphics.drawRect(-0.0, -10.0, 4.0, 18.0);
		disabledCheckMark.graphics.endFill();
		disabledCheckMark.graphics.beginFill(defaultTheme.disabledTextColor);
		disabledCheckMark.graphics.drawRect(-6.0, 4.0, 6.0, 4.0);
		disabledCheckMark.graphics.endFill();
		disabledCheckMark.rotation = 45.0;
		disabledCheckMark.x = 12.0;
		disabledCheckMark.y = 12.0;
		disabledAndSelectedIcon.addChild(disabledCheckMark);

		check.setIconForState(ToggleButtonState.DISABLED(true), disabledAndSelectedIcon);

		if (check.gap == null) {
			check.gap = 6.0;
		}
	}
}

/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.skins.HorizontalLineSkin;
import feathers.controls.HRule;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

/**
	Initialize "steel" styles for the `HRule` component.

	@since 1.4.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelHRuleStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(HRule, null) == null) {
			styleProvider.setStyleFunction(HRule, null, function(hRule:HRule):Void {
				if (hRule.backgroundSkin == null) {
					var backgroundSkin = new HorizontalLineSkin();
					backgroundSkin.fill = None;
					backgroundSkin.border = theme.getInsetBorder();
					backgroundSkin.disabledBorder = theme.getDisabledInsetBorder();
					backgroundSkin.verticalAlign = MIDDLE;
					backgroundSkin.width = 12.0;
					backgroundSkin.height = 3.0;
					hRule.backgroundSkin = backgroundSkin;
				}
			});
		}
	}
}

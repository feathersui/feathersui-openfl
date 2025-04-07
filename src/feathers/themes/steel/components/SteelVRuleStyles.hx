/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.skins.VerticalLineSkin;
import feathers.controls.VRule;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

/**
	Initialize "steel" styles for the `VRule` component.

	@since 1.4.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelVRuleStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(VRule, null) == null) {
			styleProvider.setStyleFunction(VRule, null, function(vRule:VRule):Void {
				if (vRule.backgroundSkin == null) {
					var backgroundSkin = new VerticalLineSkin();
					backgroundSkin.fill = None;
					backgroundSkin.border = theme.getInsetBorder();
					backgroundSkin.disabledBorder = theme.getDisabledInsetBorder();
					backgroundSkin.horizontalAlign = CENTER;
					backgroundSkin.width = 3.0;
					backgroundSkin.height = 12.0;
					vRule.backgroundSkin = backgroundSkin;
				}
			});
		}
	}
}

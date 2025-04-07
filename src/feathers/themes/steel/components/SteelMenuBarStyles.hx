/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.MenuBar;
import feathers.controls.VRule;
import feathers.layout.HorizontalLayout;
import feathers.skins.VerticalLineSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

/**
	Initialize "steel" styles for the `MenuBar` component.

	@since 1.4.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelMenuBarStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(MenuBar, null) == null) {
			styleProvider.setStyleFunction(MenuBar, null, function(menuBar:MenuBar):Void {
				if (menuBar.layout == null) {
					var layout = new HorizontalLayout();
					layout.gap = theme.mediumPadding;
					layout.verticalAlign = MIDDLE;
					menuBar.layout = layout;
				}
			});
		}
		if (styleProvider.getStyleFunction(VRule, MenuBar.CHILD_VARIANT_ITEM_RENDERER) == null) {
			styleProvider.setStyleFunction(VRule, MenuBar.CHILD_VARIANT_ITEM_RENDERER, function(vRule:VRule):Void {
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

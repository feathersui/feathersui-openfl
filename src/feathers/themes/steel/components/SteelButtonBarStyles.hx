/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.ButtonBar;
import feathers.layout.HorizontalLayout;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

/**
	Initialize "steel" styles for the `ButtonBar` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelButtonBarStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;

		if (styleProvider.getStyleFunction(ButtonBar, null) == null) {
			styleProvider.setStyleFunction(ButtonBar, null, function(tabBar:ButtonBar):Void {
				if (tabBar.layout == null) {
					var layout = new HorizontalLayout();
					layout.gap = 6.0;
					tabBar.layout = layout;
				}
			});
		}
	}
}

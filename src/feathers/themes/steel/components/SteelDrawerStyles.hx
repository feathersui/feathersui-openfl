/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.Drawer;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

/**
	Initialize "steel" styles for the `Drawer` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelDrawerStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(Drawer, null) == null) {
			styleProvider.setStyleFunction(Drawer, null, function(drawer:Drawer):Void {
				if (drawer.overlaySkin == null) {
					var overlaySkin = new RectangleSkin();
					overlaySkin.fill = theme.getOverlayFill();
					overlaySkin.border = None;
					overlaySkin.width = 1.0;
					overlaySkin.height = 1.0;
					drawer.overlaySkin = overlaySkin;
				}
			});
		}
	}
}

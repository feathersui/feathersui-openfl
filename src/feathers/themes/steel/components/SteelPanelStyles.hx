/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.Panel;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.SteelTheme;

/**
	Initialize "steel" styles for the `Panel` component.

	@since 1.0.0
**/
@:access(feathers.themes.steel.SteelTheme)
class SteelPanelStyles {
	public static function initialize():Void {
		var theme = Std.downcast(Theme.fallbackTheme, SteelTheme);
		if (theme != null && theme.styleProvider.getStyleFunction(Panel, null) == null) {
			theme.styleProvider.setStyleFunction(Panel, null, setStyles);
		}
	}

	private static function setStyles(panel:Panel):Void {
		var theme = Std.downcast(Theme.fallbackTheme, SteelTheme);
		if (theme == null) {
			return;
		}

		if (panel.backgroundSkin == null) {
			var backgroundSkin = new RectangleSkin();
			backgroundSkin.fill = theme.getContainerFill();
			panel.backgroundSkin = backgroundSkin;
		}
	}
}

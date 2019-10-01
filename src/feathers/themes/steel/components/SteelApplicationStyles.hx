/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.Application;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.SteelTheme;

/**
	Initialize "steel" styles for the `Application` component.

	@since 1.0.0
**/
@:access(feathers.themes.steel.SteelTheme)
class SteelApplicationStyles {
	public static function initialize():Void {
		var theme = Std.downcast(Theme.fallbackTheme, SteelTheme);
		if (theme != null && theme.styleProvider.getStyleFunction(Application, null) == null) {
			theme.styleProvider.setStyleFunction(Application, null, setStyles);
		}
	}

	private static function setStyles(app:Application):Void {
		var theme = Std.downcast(Theme.fallbackTheme, SteelTheme);
		if (theme == null) {
			return;
		}

		if (app.backgroundSkin == null) {
			var skin = new RectangleSkin();
			skin.fill = theme.getRootFill();
			app.backgroundSkin = skin;
		}
	}
}

/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.skins.RectangleSkin;
import feathers.controls.Header;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

/**
	Initialize "steel" styles for the `Header` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelHeaderStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(Header, null) == null) {
			styleProvider.setStyleFunction(Header, null, function(header:Header):Void {
				if (header.backgroundSkin == null) {
					var backgroundSkin = new RectangleSkin();
					backgroundSkin.fill = theme.getHeaderFill();
					backgroundSkin.width = 44.0;
					backgroundSkin.height = 44.0;
					backgroundSkin.minHeight = 44.0;
					header.backgroundSkin = backgroundSkin;
				}
				if (header.textFormat == null) {
					header.textFormat = theme.getHeaderTextFormat();
				}
				if (header.disabledTextFormat == null) {
					header.disabledTextFormat = theme.getDisabledHeaderTextFormat();
				}

				header.paddingTop = 10.0;
				header.paddingRight = 10.0;
				header.paddingBottom = 10.0;
				header.paddingLeft = 10.0;
				header.minGap = 10.0;
			});
		}
	}
}

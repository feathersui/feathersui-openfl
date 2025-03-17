/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.utils.DeviceUtil;
import feathers.controls.Header;
import feathers.skins.RectangleSkin;
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
				var isDesktop = DeviceUtil.isDesktop();
				if (header.backgroundSkin == null) {
					var backgroundSkin = new RectangleSkin();
					backgroundSkin.fill = theme.getHeaderFill();
					backgroundSkin.border = None;
					if (isDesktop) {
						backgroundSkin.width = 32.0;
						backgroundSkin.height = 32.0;
						backgroundSkin.minHeight = 32.0;
					} else {
						backgroundSkin.width = 44.0;
						backgroundSkin.height = 44.0;
						backgroundSkin.minHeight = 44.0;
					}
					header.backgroundSkin = backgroundSkin;
				}
				if (header.textFormat == null) {
					header.textFormat = theme.getHeaderTextFormat();
				}
				if (header.disabledTextFormat == null) {
					header.disabledTextFormat = theme.getDisabledHeaderTextFormat();
				}

				if (isDesktop) {
					header.paddingTop = theme.mediumPadding;
					header.paddingRight = theme.largePadding;
					header.paddingBottom = theme.mediumPadding;
					header.paddingLeft = theme.largePadding;
					header.minGap = theme.mediumPadding;
				} else {
					header.paddingTop = theme.largePadding;
					header.paddingRight = theme.largePadding;
					header.paddingBottom = theme.largePadding;
					header.paddingLeft = theme.largePadding;
					header.minGap = theme.largePadding;
				}
			});
		}
	}
}

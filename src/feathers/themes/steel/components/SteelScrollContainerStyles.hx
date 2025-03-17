/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.ScrollContainer;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;
import feathers.utils.DeviceUtil;

/**
	Initialize "steel" styles for the `ScrollContainer` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelScrollContainerStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(ScrollContainer, null) == null) {
			styleProvider.setStyleFunction(ScrollContainer, null, function(container:ScrollContainer):Void {
				var isDesktop = DeviceUtil.isDesktop();

				container.autoHideScrollBars = !isDesktop;
				container.fixedScrollBars = isDesktop;

				if (container.backgroundSkin == null) {
					var backgroundSkin = new RectangleSkin();
					backgroundSkin.fill = theme.getContainerFill();
					backgroundSkin.border = None;
					container.backgroundSkin = backgroundSkin;
				}

				if (container.scrollBarsCornerSkin == null) {
					var scrollBarsCornerSkin = new RectangleSkin();
					scrollBarsCornerSkin.fill = theme.getContainerFill();
					scrollBarsCornerSkin.border = None;
					container.scrollBarsCornerSkin = scrollBarsCornerSkin;
				}

				if (container.focusRectSkin == null) {
					var focusRectSkin = new RectangleSkin();
					focusRectSkin.fill = None;
					focusRectSkin.border = theme.getFocusBorder();
					container.focusRectSkin = focusRectSkin;
				}
			});
		}
	}
}

/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.utils.DeviceUtil;
import feathers.controls.ScrollContainer;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

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
					container.backgroundSkin = backgroundSkin;
				}

				if (container.focusRectSkin == null) {
					var skin = new RectangleSkin();
					skin.fill = null;
					skin.border = theme.getFocusBorder();
					container.focusRectSkin = skin;
				}
			});
		}
	}
}

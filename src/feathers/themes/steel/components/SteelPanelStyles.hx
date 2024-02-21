/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.Panel;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;
import feathers.utils.DeviceUtil;

/**
	Initialize "steel" styles for the `Panel` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelPanelStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(Panel, null) == null) {
			styleProvider.setStyleFunction(Panel, null, function(panel:Panel):Void {
				var isDesktop = DeviceUtil.isDesktop();

				panel.autoHideScrollBars = !isDesktop;
				panel.fixedScrollBars = isDesktop;

				if (panel.backgroundSkin == null) {
					var backgroundSkin = new RectangleSkin();
					backgroundSkin.fill = theme.getContainerFill();
					backgroundSkin.border = None;
					panel.backgroundSkin = backgroundSkin;
				}

				if (panel.scrollBarsCornerSkin == null) {
					var scrollBarsCornerSkin = new RectangleSkin();
					scrollBarsCornerSkin.fill = theme.getContainerFill();
					scrollBarsCornerSkin.border = None;
					panel.scrollBarsCornerSkin = scrollBarsCornerSkin;
				}
			});
		}
	}
}

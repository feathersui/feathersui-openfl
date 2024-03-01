/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.utils.DeviceUtil;
import feathers.controls.LayoutGroup;
import feathers.layout.HorizontalLayout;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

/**
	Initialize "steel" styles for the `LayoutGroup` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelLayoutGroupStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(LayoutGroup, LayoutGroup.VARIANT_TOOL_BAR) == null) {
			styleProvider.setStyleFunction(LayoutGroup, LayoutGroup.VARIANT_TOOL_BAR, function(group:LayoutGroup):Void {
				var isDesktop = DeviceUtil.isDesktop();
				if (group.backgroundSkin == null) {
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
					group.backgroundSkin = backgroundSkin;
				}
				if (group.layout == null) {
					var layout = new HorizontalLayout();
					layout.horizontalAlign = LEFT;
					layout.verticalAlign = MIDDLE;
					layout.paddingTop = theme.smallPadding;
					layout.paddingRight = theme.largePadding;
					layout.paddingBottom = theme.smallPadding;
					layout.paddingLeft = theme.largePadding;
					layout.gap = theme.smallPadding;
					group.layout = layout;
				}
			});
		}
	}
}

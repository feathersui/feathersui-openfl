/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.skins.TriangleSkin;
import feathers.controls.dataRenderers.GridViewHeaderRenderer;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;
import feathers.utils.DeviceUtil;

/**
	Initialize "steel" styles for the `GridViewHeaderRenderer` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelGridViewHeaderRendererStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(GridViewHeaderRenderer, null) == null) {
			styleProvider.setStyleFunction(GridViewHeaderRenderer, null, function(itemRenderer:GridViewHeaderRenderer):Void {
				var isDesktop = DeviceUtil.isDesktop();

				if (itemRenderer.backgroundSkin == null) {
					var skin = new RectangleSkin();
					skin.fill = theme.getSubHeadingFill();
					if (isDesktop) {
						skin.width = 22.0;
						skin.height = 22.0;
						skin.minWidth = 22.0;
						skin.minHeight = 22.0;
					} else {
						skin.width = 44.0;
						skin.height = 44.0;
						skin.minWidth = 44.0;
						skin.minHeight = 44.0;
					}
					itemRenderer.backgroundSkin = skin;
				}

				if (itemRenderer.sortAscendingIcon == null) {
					var sortAscendingIcon = new TriangleSkin();
					sortAscendingIcon.pointPosition = TOP;
					sortAscendingIcon.fill = SolidColor(theme.textColor);
					sortAscendingIcon.disabledFill = SolidColor(theme.disabledTextColor);
					sortAscendingIcon.width = 8.0;
					sortAscendingIcon.height = 4.0;
					itemRenderer.sortAscendingIcon = sortAscendingIcon;
				}

				if (itemRenderer.sortDescendingIcon == null) {
					var sortDescendingIcon = new TriangleSkin();
					sortDescendingIcon.pointPosition = BOTTOM;
					sortDescendingIcon.fill = SolidColor(theme.textColor);
					sortDescendingIcon.disabledFill = SolidColor(theme.disabledTextColor);
					sortDescendingIcon.width = 8.0;
					sortDescendingIcon.height = 4.0;
					itemRenderer.sortDescendingIcon = sortDescendingIcon;
				}

				if (itemRenderer.textFormat == null) {
					itemRenderer.textFormat = theme.getTextFormat();
				}
				if (itemRenderer.disabledTextFormat == null) {
					itemRenderer.disabledTextFormat = theme.getDisabledTextFormat();
				}
				if (itemRenderer.secondaryTextFormat == null) {
					itemRenderer.secondaryTextFormat = theme.getDetailTextFormat();
				}
				if (itemRenderer.disabledSecondaryTextFormat == null) {
					itemRenderer.disabledSecondaryTextFormat = theme.getDisabledDetailTextFormat();
				}

				itemRenderer.paddingTop = 4.0;
				itemRenderer.paddingRight = 10.0;
				itemRenderer.paddingBottom = 4.0;
				itemRenderer.paddingLeft = 10.0;
				itemRenderer.gap = 4.0;

				itemRenderer.horizontalAlign = LEFT;
			});
		}
	}
}

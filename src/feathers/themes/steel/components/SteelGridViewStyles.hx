/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.utils.DeviceUtil;
import feathers.controls.GridView;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

/**
	Initialize "steel" styles for the `GridView` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelGridViewStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		function styleGridViewWithWithBorderVariant(gridView:GridView):Void {
			var isDesktop = DeviceUtil.isDesktop();

			gridView.autoHideScrollBars = !isDesktop;
			gridView.fixedScrollBars = isDesktop;

			if (gridView.backgroundSkin == null) {
				var backgroundSkin = new RectangleSkin();
				backgroundSkin.fill = theme.getContainerFill();
				backgroundSkin.border = theme.getContainerBorder();
				backgroundSkin.width = 160.0;
				backgroundSkin.height = 160.0;
				gridView.backgroundSkin = backgroundSkin;
			}

			if (gridView.focusRectSkin == null) {
				var skin = new RectangleSkin();
				skin.fill = null;
				skin.border = theme.getFocusBorder();
				gridView.focusRectSkin = skin;
			}

			gridView.paddingTop = 1.0;
			gridView.paddingRight = 1.0;
			gridView.paddingBottom = 1.0;
			gridView.paddingLeft = 1.0;
		}

		function styleGridViewWithWithBorderlessVariant(gridView:GridView):Void {
			var isDesktop = DeviceUtil.isDesktop();

			gridView.autoHideScrollBars = !isDesktop;
			gridView.fixedScrollBars = isDesktop;

			if (gridView.backgroundSkin == null) {
				var backgroundSkin = new RectangleSkin();
				backgroundSkin.fill = theme.getContainerFill();
				backgroundSkin.width = 160.0;
				backgroundSkin.height = 160.0;
				gridView.backgroundSkin = backgroundSkin;
			}

			if (gridView.focusRectSkin == null) {
				var skin = new RectangleSkin();
				skin.fill = null;
				skin.border = theme.getFocusBorder();
				gridView.focusRectSkin = skin;
			}
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(GridView, null) == null) {
			styleProvider.setStyleFunction(GridView, null, function(gridView:GridView):Void {
				var isDesktop = DeviceUtil.isDesktop();
				if (isDesktop) {
					styleGridViewWithWithBorderVariant(gridView);
				} else {
					styleGridViewWithWithBorderlessVariant(gridView);
				}
			});
		}
		if (styleProvider.getStyleFunction(GridView, GridView.VARIANT_BORDER) == null) {
			styleProvider.setStyleFunction(GridView, GridView.VARIANT_BORDER, styleGridViewWithWithBorderVariant);
		}
		if (styleProvider.getStyleFunction(GridView, GridView.VARIANT_BORDERLESS) == null) {
			styleProvider.setStyleFunction(GridView, GridView.VARIANT_BORDERLESS, styleGridViewWithWithBorderlessVariant);
		}
	}
}

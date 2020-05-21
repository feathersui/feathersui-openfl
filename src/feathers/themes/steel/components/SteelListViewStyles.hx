/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.utils.DeviceUtil;
import feathers.layout.VerticalListLayout;
import feathers.controls.ListView;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

/**
	Initialize "steel" styles for the `ListView` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelListViewStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		function styleListViewWithWithBorderVariant(listView:ListView):Void {
			var isDesktop = DeviceUtil.isDesktop();

			listView.autoHideScrollBars = !isDesktop;
			listView.fixedScrollBars = isDesktop;

			if (listView.layout == null) {
				listView.layout = new VerticalListLayout();
			}

			if (listView.backgroundSkin == null) {
				var backgroundSkin = new RectangleSkin();
				backgroundSkin.fill = theme.getContainerFill();
				backgroundSkin.border = theme.getContainerBorder();
				backgroundSkin.width = 160.0;
				backgroundSkin.height = 160.0;
				listView.backgroundSkin = backgroundSkin;
			}

			if (listView.focusRectSkin == null) {
				var skin = new RectangleSkin();
				skin.fill = null;
				skin.border = theme.getFocusBorder();
				listView.focusRectSkin = skin;
			}

			listView.paddingTop = 1.0;
			listView.paddingRight = 1.0;
			listView.paddingBottom = 1.0;
			listView.paddingLeft = 1.0;
		}

		function styleListViewWithWithBorderlessVariant(listView:ListView):Void {
			var isDesktop = DeviceUtil.isDesktop();

			listView.autoHideScrollBars = !isDesktop;
			listView.fixedScrollBars = isDesktop;

			if (listView.layout == null) {
				listView.layout = new VerticalListLayout();
			}

			if (listView.backgroundSkin == null) {
				var backgroundSkin = new RectangleSkin();
				backgroundSkin.fill = theme.getContainerFill();
				backgroundSkin.width = 160.0;
				backgroundSkin.height = 160.0;
				listView.backgroundSkin = backgroundSkin;
			}

			if (listView.focusRectSkin == null) {
				var skin = new RectangleSkin();
				skin.fill = null;
				skin.border = theme.getFocusBorder();
				listView.focusRectSkin = skin;
			}
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(ListView, null) == null) {
			styleProvider.setStyleFunction(ListView, null, function(listView:ListView):Void {
				var isDesktop = DeviceUtil.isDesktop();
				if (isDesktop) {
					styleListViewWithWithBorderVariant(listView);
				} else {
					styleListViewWithWithBorderlessVariant(listView);
				}
			});
		}
		if (styleProvider.getStyleFunction(ListView, ListView.VARIANT_BORDER) == null) {
			styleProvider.setStyleFunction(ListView, ListView.VARIANT_BORDER, styleListViewWithWithBorderVariant);
		}
		if (styleProvider.getStyleFunction(ListView, ListView.VARIANT_BORDERLESS) == null) {
			styleProvider.setStyleFunction(ListView, ListView.VARIANT_BORDERLESS, styleListViewWithWithBorderlessVariant);
		}
	}
}

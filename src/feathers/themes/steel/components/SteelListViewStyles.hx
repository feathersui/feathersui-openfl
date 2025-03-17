/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.ListView;
import feathers.layout.VerticalListLayout;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;
import feathers.utils.DeviceUtil;

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

		function styleListViewWithBorderVariant(listView:ListView):Void {
			var isDesktop = DeviceUtil.isDesktop();

			listView.autoHideScrollBars = !isDesktop;
			listView.fixedScrollBars = isDesktop;

			if (listView.layout == null) {
				var layout = new VerticalListLayout();
				layout.requestedRowCount = 5.0;
				listView.layout = layout;
			}

			if (listView.backgroundSkin == null) {
				var backgroundSkin = new RectangleSkin();
				backgroundSkin.fill = theme.getContainerFill();
				backgroundSkin.border = theme.getContainerBorder();
				backgroundSkin.width = 10.0;
				backgroundSkin.height = 10.0;
				listView.backgroundSkin = backgroundSkin;
			}

			if (listView.focusRectSkin == null) {
				var focusRectSkin = new RectangleSkin();
				focusRectSkin.fill = None;
				focusRectSkin.border = theme.getFocusBorder();
				listView.focusRectSkin = focusRectSkin;
			}

			if (listView.dragDropIndicatorSkin == null) {
				var dragDropIndicatorSkin = new RectangleSkin();
				dragDropIndicatorSkin.fill = theme.getActiveThemeFill();
				dragDropIndicatorSkin.border = None;
				dragDropIndicatorSkin.width = 2.0;
				dragDropIndicatorSkin.height = 2.0;
				listView.dragDropIndicatorSkin = dragDropIndicatorSkin;
			}

			listView.paddingTop = theme.borderThickness;
			listView.paddingRight = theme.borderThickness;
			listView.paddingBottom = theme.borderThickness;
			listView.paddingLeft = theme.borderThickness;
		}

		function styleListViewWithBorderlessVariant(listView:ListView):Void {
			var isDesktop = DeviceUtil.isDesktop();

			listView.autoHideScrollBars = !isDesktop;
			listView.fixedScrollBars = isDesktop;

			if (listView.layout == null) {
				var layout = new VerticalListLayout();
				layout.requestedRowCount = 5.0;
				listView.layout = layout;
			}

			if (listView.backgroundSkin == null) {
				var backgroundSkin = new RectangleSkin();
				backgroundSkin.fill = theme.getContainerFill();
				backgroundSkin.border = None;
				backgroundSkin.width = 10.0;
				backgroundSkin.height = 10.0;
				listView.backgroundSkin = backgroundSkin;
			}

			if (listView.focusRectSkin == null) {
				var focusRectSkin = new RectangleSkin();
				focusRectSkin.fill = None;
				focusRectSkin.border = theme.getFocusBorder();
				listView.focusRectSkin = focusRectSkin;
			}
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(ListView, null) == null) {
			styleProvider.setStyleFunction(ListView, null, function(listView:ListView):Void {
				var isDesktop = DeviceUtil.isDesktop();
				if (isDesktop) {
					styleListViewWithBorderVariant(listView);
				} else {
					styleListViewWithBorderlessVariant(listView);
				}
			});
		}
		if (styleProvider.getStyleFunction(ListView, ListView.VARIANT_BORDER) == null) {
			styleProvider.setStyleFunction(ListView, ListView.VARIANT_BORDER, styleListViewWithBorderVariant);
		}
		if (styleProvider.getStyleFunction(ListView, ListView.VARIANT_BORDERLESS) == null) {
			styleProvider.setStyleFunction(ListView, ListView.VARIANT_BORDERLESS, styleListViewWithBorderlessVariant);
		}
		if (styleProvider.getStyleFunction(ListView, ListView.VARIANT_POP_UP) == null) {
			styleProvider.setStyleFunction(ListView, ListView.VARIANT_POP_UP, function(listView:ListView):Void {
				if (listView.layout == null) {
					var layout = new VerticalListLayout();
					layout.requestedMinRowCount = 1.0;
					layout.requestedMaxRowCount = 5.0;
					listView.layout = layout;
				}

				styleListViewWithBorderVariant(listView);
			});
		}
	}
}

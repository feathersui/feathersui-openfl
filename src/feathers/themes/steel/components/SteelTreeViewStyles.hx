/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.TreeView;
import feathers.layout.VerticalListLayout;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;
import feathers.utils.DeviceUtil;

/**
	Initialize "steel" styles for the `TreeView` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelTreeViewStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		function styleTreeViewWithBorderVariant(treeView:TreeView):Void {
			var isDesktop = DeviceUtil.isDesktop();

			treeView.autoHideScrollBars = !isDesktop;
			treeView.fixedScrollBars = isDesktop;

			if (treeView.layout == null) {
				var layout = new VerticalListLayout();
				layout.requestedRowCount = 5.0;
				treeView.layout = layout;
			}

			if (treeView.backgroundSkin == null) {
				var backgroundSkin = new RectangleSkin();
				backgroundSkin.fill = theme.getContainerFill();
				backgroundSkin.border = theme.getContainerBorder();
				backgroundSkin.width = 10.0;
				backgroundSkin.height = 10.0;
				treeView.backgroundSkin = backgroundSkin;
			}

			if (treeView.focusRectSkin == null) {
				var focusRectSkin = new RectangleSkin();
				focusRectSkin.fill = null;
				focusRectSkin.border = theme.getFocusBorder();
				treeView.focusRectSkin = focusRectSkin;
			}

			treeView.paddingTop = 1.0;
			treeView.paddingRight = 1.0;
			treeView.paddingBottom = 1.0;
			treeView.paddingLeft = 1.0;
		}

		function styleTreeViewWithBorderlessVariant(treeView:TreeView):Void {
			var isDesktop = DeviceUtil.isDesktop();

			treeView.autoHideScrollBars = !isDesktop;
			treeView.fixedScrollBars = isDesktop;

			if (treeView.layout == null) {
				treeView.layout = new VerticalListLayout();
			}

			if (treeView.backgroundSkin == null) {
				var backgroundSkin = new RectangleSkin();
				backgroundSkin.fill = theme.getContainerFill();
				backgroundSkin.width = 10.0;
				backgroundSkin.height = 10.0;
				treeView.backgroundSkin = backgroundSkin;
			}

			if (treeView.focusRectSkin == null) {
				var skin = new RectangleSkin();
				skin.fill = null;
				skin.border = theme.getFocusBorder();
				treeView.focusRectSkin = skin;
			}
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(TreeView, null) == null) {
			styleProvider.setStyleFunction(TreeView, null, function(treeView:TreeView):Void {
				var isDesktop = DeviceUtil.isDesktop();
				if (isDesktop) {
					styleTreeViewWithBorderVariant(treeView);
				} else {
					styleTreeViewWithBorderlessVariant(treeView);
				}
			});
		}
		if (styleProvider.getStyleFunction(TreeView, TreeView.VARIANT_BORDER) == null) {
			styleProvider.setStyleFunction(TreeView, TreeView.VARIANT_BORDER, styleTreeViewWithBorderVariant);
		}
		if (styleProvider.getStyleFunction(TreeView, TreeView.VARIANT_BORDERLESS) == null) {
			styleProvider.setStyleFunction(TreeView, TreeView.VARIANT_BORDERLESS, styleTreeViewWithBorderlessVariant);
		}
	}
}

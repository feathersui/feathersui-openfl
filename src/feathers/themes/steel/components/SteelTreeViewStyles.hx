/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.utils.DeviceUtil;
import feathers.layout.VerticalListLayout;
import feathers.controls.TreeView;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

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

		function styleTreeViewWithWithBorderVariant(treeView:TreeView):Void {
			var isDesktop = DeviceUtil.isDesktop();

			treeView.autoHideScrollBars = !isDesktop;
			treeView.fixedScrollBars = isDesktop;

			if (treeView.layout == null) {
				treeView.layout = new VerticalListLayout();
			}

			if (treeView.backgroundSkin == null) {
				var backgroundSkin = new RectangleSkin();
				backgroundSkin.fill = theme.getContainerFill();
				backgroundSkin.border = theme.getContainerBorder();
				backgroundSkin.width = 160.0;
				backgroundSkin.height = 160.0;
				treeView.backgroundSkin = backgroundSkin;
			}

			if (treeView.focusRectSkin == null) {
				var skin = new RectangleSkin();
				skin.fill = null;
				skin.border = theme.getFocusBorder();
				treeView.focusRectSkin = skin;
			}

			treeView.paddingTop = 1.0;
			treeView.paddingRight = 1.0;
			treeView.paddingBottom = 1.0;
			treeView.paddingLeft = 1.0;
		}

		function styleTreeViewWithWithBorderlessVariant(treeView:TreeView):Void {
			var isDesktop = DeviceUtil.isDesktop();

			treeView.autoHideScrollBars = !isDesktop;
			treeView.fixedScrollBars = isDesktop;

			if (treeView.layout == null) {
				treeView.layout = new VerticalListLayout();
			}

			if (treeView.backgroundSkin == null) {
				var backgroundSkin = new RectangleSkin();
				backgroundSkin.fill = theme.getContainerFill();
				backgroundSkin.width = 160.0;
				backgroundSkin.height = 160.0;
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
					styleTreeViewWithWithBorderVariant(treeView);
				} else {
					styleTreeViewWithWithBorderlessVariant(treeView);
				}
			});
		}
		if (styleProvider.getStyleFunction(TreeView, TreeView.VARIANT_BORDER) == null) {
			styleProvider.setStyleFunction(TreeView, TreeView.VARIANT_BORDER, styleTreeViewWithWithBorderVariant);
		}
		if (styleProvider.getStyleFunction(TreeView, TreeView.VARIANT_BORDERLESS) == null) {
			styleProvider.setStyleFunction(TreeView, TreeView.VARIANT_BORDERLESS, styleTreeViewWithWithBorderlessVariant);
		}
	}
}

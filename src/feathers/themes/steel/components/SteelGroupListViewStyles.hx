/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.GroupListView;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.layout.VerticalListLayout;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;
import feathers.utils.DeviceUtil;

/**
	Initialize "steel" styles for the `GroupListView` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelGroupListViewStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		function styleGroupListViewWithBorderVariant(listView:GroupListView):Void {
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

			listView.paddingTop = theme.borderThickness;
			listView.paddingRight = theme.borderThickness;
			listView.paddingBottom = theme.borderThickness;
			listView.paddingLeft = theme.borderThickness;
		}

		function styleGroupListViewWithBorderlessVariant(listView:GroupListView):Void {
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
				var skin = new RectangleSkin();
				skin.fill = None;
				skin.border = theme.getFocusBorder();
				listView.focusRectSkin = skin;
			}
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(GroupListView, null) == null) {
			styleProvider.setStyleFunction(GroupListView, null, function(listView:GroupListView):Void {
				var isDesktop = DeviceUtil.isDesktop();
				if (isDesktop) {
					styleGroupListViewWithBorderVariant(listView);
				} else {
					styleGroupListViewWithBorderlessVariant(listView);
				}
			});
		}
		if (styleProvider.getStyleFunction(GroupListView, GroupListView.VARIANT_BORDER) == null) {
			styleProvider.setStyleFunction(GroupListView, GroupListView.VARIANT_BORDER, styleGroupListViewWithBorderVariant);
		}
		if (styleProvider.getStyleFunction(GroupListView, GroupListView.VARIANT_BORDERLESS) == null) {
			styleProvider.setStyleFunction(GroupListView, GroupListView.VARIANT_BORDERLESS, styleGroupListViewWithBorderlessVariant);
		}

		if (styleProvider.getStyleFunction(ItemRenderer, GroupListView.CHILD_VARIANT_HEADER_RENDERER) == null) {
			styleProvider.setStyleFunction(ItemRenderer, GroupListView.CHILD_VARIANT_HEADER_RENDERER, function(itemRenderer:ItemRenderer):Void {
				if (itemRenderer.backgroundSkin == null) {
					var skin = new RectangleSkin();
					skin.fill = theme.getSubHeadingFill();
					skin.border = None;
					skin.width = 22.0;
					skin.height = 22.0;
					skin.minWidth = 22.0;
					skin.minHeight = 22.0;
					itemRenderer.backgroundSkin = skin;
				}

				if (itemRenderer.textFormat == null) {
					itemRenderer.textFormat = theme.getTextFormat();
				}
				if (itemRenderer.disabledTextFormat == null) {
					itemRenderer.disabledTextFormat = theme.getDisabledTextFormat();
				}
				if (itemRenderer.secondaryTextFormat == null) {
					itemRenderer.secondaryTextFormat = theme.getSecondaryDetailTextFormat();
				}
				if (itemRenderer.disabledSecondaryTextFormat == null) {
					itemRenderer.disabledSecondaryTextFormat = theme.getDisabledDetailTextFormat();
				}

				itemRenderer.paddingTop = theme.smallPadding;
				itemRenderer.paddingRight = theme.largePadding;
				itemRenderer.paddingBottom = theme.smallPadding;
				itemRenderer.paddingLeft = theme.largePadding;
				itemRenderer.gap = theme.smallPadding;

				itemRenderer.horizontalAlign = LEFT;
			});
		}
	}
}

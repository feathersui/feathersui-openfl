/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.HRule;
import feathers.controls.Menu;
import feathers.controls.ToggleButtonState;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.layout.VerticalListLayout;
import feathers.skins.HorizontalLineSkin;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;
import feathers.utils.DeviceUtil;

/**
	Initialize "steel" styles for the `Menu` component.

	@since 1.4.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelMenuStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(Menu, null) == null) {
			styleProvider.setStyleFunction(Menu, null, function(menu:Menu):Void {
				var isDesktop = DeviceUtil.isDesktop();

				menu.autoHideScrollBars = !isDesktop;
				menu.fixedScrollBars = isDesktop;

				if (menu.layout == null) {
					var layout = new VerticalListLayout();
					layout.requestedMinRowCount = 1.0;
					layout.setPadding(theme.mediumPadding);
					menu.layout = layout;
				}

				if (menu.backgroundSkin == null) {
					var backgroundSkin = new RectangleSkin();
					backgroundSkin.fill = theme.getContainerFill();
					backgroundSkin.border = theme.getContainerBorder();
					backgroundSkin.width = 10.0;
					backgroundSkin.height = 10.0;
					backgroundSkin.cornerRadius = 4.0;
					menu.backgroundSkin = backgroundSkin;
				}

				if (menu.focusRectSkin == null) {
					var focusRectSkin = new RectangleSkin();
					focusRectSkin.fill = None;
					focusRectSkin.border = theme.getFocusBorder();
					menu.focusRectSkin = focusRectSkin;
				}

				menu.paddingTop = theme.borderThickness;
				menu.paddingRight = theme.borderThickness;
				menu.paddingBottom = theme.borderThickness;
				menu.paddingLeft = theme.borderThickness;
			});
		}
		if (styleProvider.getStyleFunction(ItemRenderer, Menu.CHILD_VARIANT_ITEM_RENDERER) == null) {
			styleProvider.setStyleFunction(ItemRenderer, Menu.CHILD_VARIANT_ITEM_RENDERER, function(itemRenderer:ItemRenderer):Void {
				var isDesktop = DeviceUtil.isDesktop();

				if (itemRenderer.backgroundSkin == null) {
					var skin = new RectangleSkin();
					skin.fill = SolidColor(0xff00ff, 0.0);
					skin.border = None;
					skin.selectedFill = theme.getActiveThemeFill();
					skin.setFillForState(ToggleButtonState.HOVER(false), theme.getActiveThemeFill());
					skin.setFillForState(ToggleButtonState.DOWN(false), theme.getActiveThemeFill());
					skin.cornerRadius = 3.0;
					if (isDesktop) {
						skin.width = 26.0;
						skin.height = 26.0;
						skin.minWidth = 26.0;
						skin.minHeight = 26.0;
					} else {
						skin.width = 44.0;
						skin.height = 44.0;
						skin.minWidth = 44.0;
						skin.minHeight = 44.0;
					}
					itemRenderer.backgroundSkin = skin;
				}

				var styleFunction = styleProvider.getStyleFunction(ItemRenderer, null);
				if (styleFunction != null) {
					styleFunction(itemRenderer);
				}
			});
		}
		if (styleProvider.getStyleFunction(HRule, Menu.CHILD_VARIANT_ITEM_RENDERER) == null) {
			styleProvider.setStyleFunction(HRule, Menu.CHILD_VARIANT_ITEM_RENDERER, function(hRule:HRule):Void {
				if (hRule.backgroundSkin == null) {
					var backgroundSkin = new HorizontalLineSkin();
					backgroundSkin.fill = None;
					backgroundSkin.border = theme.getInsetBorder();
					backgroundSkin.disabledBorder = theme.getDisabledInsetBorder();
					backgroundSkin.verticalAlign = MIDDLE;
					backgroundSkin.width = 12.0;
					backgroundSkin.height = 6.0;
					hRule.backgroundSkin = backgroundSkin;
				}
			});
		}
	}
}

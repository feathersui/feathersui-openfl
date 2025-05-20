/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.MenuBar;
import feathers.controls.ToggleButton;
import feathers.controls.ToggleButtonState;
import feathers.controls.VRule;
import feathers.layout.HorizontalLayout;
import feathers.skins.RectangleSkin;
import feathers.skins.VerticalLineSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;
import feathers.utils.DeviceUtil;

/**
	Initialize "steel" styles for the `MenuBar` component.

	@since 1.4.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelMenuBarStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(MenuBar, null) == null) {
			styleProvider.setStyleFunction(MenuBar, null, function(menuBar:MenuBar):Void {
				var isDesktop = DeviceUtil.isDesktop();
				if (menuBar.backgroundSkin == null) {
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
					menuBar.backgroundSkin = backgroundSkin;
				}
				if (menuBar.layout == null) {
					var layout = new HorizontalLayout();
					layout.gap = theme.mediumPadding;
					layout.verticalAlign = MIDDLE;
					menuBar.layout = layout;
				}
			});
		}
		if (styleProvider.getStyleFunction(ToggleButton, MenuBar.CHILD_VARIANT_ITEM_RENDERER) == null) {
			styleProvider.setStyleFunction(ToggleButton, MenuBar.CHILD_VARIANT_ITEM_RENDERER, function(button:ToggleButton):Void {
				if (button.backgroundSkin == null) {
					var skin = new RectangleSkin();
					skin.fill = SolidColor(0xff00ff, 0.0);
					skin.selectedFill = theme.getReversedActiveThemeFill();
					skin.setFillForState(DOWN(false), theme.getReversedActiveThemeFill());
					skin.border = SolidColor(1.0, 0xff00ff, 0.0);
					skin.selectedBorder = theme.getActiveFillBorder();
					skin.setBorderForState(DOWN(false), theme.getActiveFillBorder());
					skin.cornerRadius = 3.0;
					button.backgroundSkin = skin;
				}

				if (button.textFormat == null) {
					button.textFormat = theme.getTextFormat();
				}
				if (button.disabledTextFormat == null) {
					button.disabledTextFormat = theme.getDisabledTextFormat();
				}

				button.paddingTop = theme.smallPadding;
				button.paddingRight = theme.largePadding;
				button.paddingBottom = theme.smallPadding;
				button.paddingLeft = theme.largePadding;
				button.gap = theme.smallPadding;
			});
		}
		if (styleProvider.getStyleFunction(VRule, MenuBar.CHILD_VARIANT_ITEM_RENDERER) == null) {
			styleProvider.setStyleFunction(VRule, MenuBar.CHILD_VARIANT_ITEM_RENDERER, function(vRule:VRule):Void {
				if (vRule.backgroundSkin == null) {
					var backgroundSkin = new VerticalLineSkin();
					backgroundSkin.fill = None;
					backgroundSkin.border = theme.getInsetBorder();
					backgroundSkin.disabledBorder = theme.getDisabledInsetBorder();
					backgroundSkin.horizontalAlign = CENTER;
					backgroundSkin.width = 3.0;
					backgroundSkin.height = 12.0;
					vRule.backgroundSkin = backgroundSkin;
				}
			});
		}
	}
}

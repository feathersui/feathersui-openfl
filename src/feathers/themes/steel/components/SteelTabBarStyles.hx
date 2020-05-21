/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.TabBar;
import feathers.controls.ToggleButton;
import feathers.controls.ToggleButtonState;
import feathers.layout.HorizontalLayout;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;
import feathers.utils.DeviceUtil;

/**
	Initialize "steel" styles for the `TabBar` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelTabBarStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;

		if (styleProvider.getStyleFunction(TabBar, null) == null) {
			styleProvider.setStyleFunction(TabBar, null, function(tabBar:TabBar):Void {
				var isDesktop = DeviceUtil.isDesktop();

				if (tabBar.backgroundSkin == null) {
					var skin = new RectangleSkin();
					skin.fill = theme.getControlFill();
					skin.disabledFill = theme.getControlDisabledFill();
					tabBar.backgroundSkin = skin;
				}
				if (tabBar.focusRectSkin == null) {
					var skin = new RectangleSkin();
					skin.fill = null;
					skin.border = theme.getFocusBorder();
					skin.cornerRadius = 6.0;
					tabBar.focusRectSkin = skin;
				}
				if (tabBar.layout == null) {
					var layout = new HorizontalLayout();
					if (!isDesktop) {
						layout.horizontalAlign = CENTER;
					}
					tabBar.layout = layout;
				}
			});
		}

		if (styleProvider.getStyleFunction(ToggleButton, TabBar.CHILD_VARIANT_TAB) == null) {
			styleProvider.setStyleFunction(ToggleButton, TabBar.CHILD_VARIANT_TAB, function(button:ToggleButton):Void {
				var isDesktop = DeviceUtil.isDesktop();

				if (button.backgroundSkin == null) {
					var skin = new RectangleSkin();
					skin.fill = theme.getButtonFill();
					skin.selectedFill = theme.getThemeFill();
					skin.setFillForState(ToggleButtonState.DOWN(false), theme.getReversedActiveThemeFill());
					skin.setFillForState(ToggleButtonState.DISABLED(false), theme.getButtonDisabledFill());
					skin.setFillForState(ToggleButtonState.DOWN(false), theme.getReversedActiveThemeFill());
					skin.border = theme.getButtonBorder();
					skin.selectedBorder = theme.getActiveFillBorder();
					skin.setBorderForState(ToggleButtonState.DOWN(false), theme.getActiveFillBorder());
					if (isDesktop) {
						skin.maxWidth = 100.0;
						skin.minWidth = 20.0;
					} else {
						skin.minWidth = 44.0;
						skin.minHeight = 44.0;
					}
					button.backgroundSkin = skin;
				}

				if (button.textFormat == null) {
					button.textFormat = theme.getTextFormat();
				}
				if (button.disabledTextFormat == null) {
					button.disabledTextFormat = theme.getDisabledTextFormat();
				}
				if (button.selectedTextFormat == null) {
					button.selectedTextFormat = theme.getActiveTextFormat();
				}

				if (button.getTextFormatForState(ToggleButtonState.DOWN(false)) == null) {
					button.setTextFormatForState(ToggleButtonState.DOWN(false), theme.getActiveTextFormat());
				}

				button.paddingTop = 4.0;
				button.paddingRight = 10.0;
				button.paddingBottom = 4.0;
				button.paddingLeft = 10.0;
				button.gap = 6.0;
			});
		}
	}
}

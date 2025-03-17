/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.PageIndicator;
import feathers.controls.ToggleButton;
import feathers.controls.ToggleButtonState;
import feathers.layout.HorizontalLayout;
import feathers.skins.CircleSkin;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

/**
	Initialize "steel" styles for the `PageIndicator` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelPageIndicatorStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;

		if (styleProvider.getStyleFunction(PageIndicator, null) == null) {
			styleProvider.setStyleFunction(PageIndicator, null, function(pages:PageIndicator):Void {
				if (pages.focusRectSkin == null) {
					var focusRectSkin = new RectangleSkin();
					focusRectSkin.fill = None;
					focusRectSkin.border = theme.getFocusBorder();
					focusRectSkin.cornerRadius = 3.0;
					pages.focusRectSkin = focusRectSkin;
				}
				if (pages.layout == null) {
					var layout = new HorizontalLayout();
					layout.gap = theme.largePadding;
					layout.paddingTop = theme.smallPadding;
					layout.paddingRight = theme.smallPadding;
					layout.paddingBottom = theme.smallPadding;
					layout.paddingLeft = theme.smallPadding;
					layout.horizontalAlign = CENTER;
					layout.verticalAlign = MIDDLE;
					pages.layout = layout;
				}
			});
		}

		if (styleProvider.getStyleFunction(ToggleButton, PageIndicator.CHILD_VARIANT_TOGGLE_BUTTON) == null) {
			styleProvider.setStyleFunction(ToggleButton, PageIndicator.CHILD_VARIANT_TOGGLE_BUTTON, function(button:ToggleButton):Void {
				if (button.backgroundSkin == null) {
					var skin = new CircleSkin();
					skin.fill = theme.getButtonFill();
					skin.disabledFill = theme.getButtonDisabledFill();
					skin.selectedFill = theme.getThemeFill();
					skin.setFillForState(ToggleButtonState.DOWN(false), theme.getReversedActiveThemeFill());
					skin.setFillForState(ToggleButtonState.DOWN(false), theme.getReversedActiveThemeFill());
					skin.border = theme.getButtonBorder();
					skin.disabledBorder = theme.getButtonDisabledBorder();
					skin.selectedBorder = theme.getSelectedInsetBorder();
					skin.setBorderForState(ToggleButtonState.DOWN(false), theme.getActiveFillBorder());
					skin.minWidth = 10.0;
					skin.minHeight = 10.0;
					button.backgroundSkin = skin;
				}
			});
		}
	}
}

/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.BasicButton;
import feathers.controls.Button;
import feathers.controls.ButtonState;
import feathers.controls.HScrollBar;
import feathers.skins.RectangleSkin;
import feathers.skins.TriangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;
import feathers.utils.DeviceUtil;

/**
	Initialize "steel" styles for the `HScrollBar` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelHScrollBarStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(HScrollBar, null) == null) {
			styleProvider.setStyleFunction(HScrollBar, null, function(scrollBar:HScrollBar):Void {
				var isDesktop = DeviceUtil.isDesktop();

				if (scrollBar.thumbSkin == null) {
					var thumbSkin = new RectangleSkin();
					thumbSkin.fill = theme.getScrollBarThumbFill();
					thumbSkin.disabledFill = theme.getScrollBarThumbDisabledFill();
					thumbSkin.border = None;
					var size = isDesktop ? 6.0 : 4.0;
					thumbSkin.width = size;
					thumbSkin.height = size;
					thumbSkin.minWidth = size;
					thumbSkin.minHeight = size;
					thumbSkin.cornerRadius = size / 2.0;

					var thumb = new BasicButton();
					thumb.keepDownStateOnRollOut = true;
					thumb.backgroundSkin = thumbSkin;
					scrollBar.thumbSkin = thumb;
				}

				if (isDesktop && scrollBar.trackSkin == null) {
					var trackSkin = new RectangleSkin();
					trackSkin.fill = theme.getControlFill();
					trackSkin.disabledFill = theme.getControlDisabledFill();
					trackSkin.border = None;
					trackSkin.width = 12.0;
					trackSkin.height = 12.0;
					trackSkin.minWidth = 12.0;
					trackSkin.minHeight = 12.0;
					scrollBar.trackSkin = trackSkin;
				}

				scrollBar.paddingTop = theme.xsmallPadding;
				scrollBar.paddingRight = theme.xsmallPadding;
				scrollBar.paddingBottom = theme.xsmallPadding;
				scrollBar.paddingLeft = theme.xsmallPadding;
			});
		}

		if (styleProvider.getStyleFunction(Button, HScrollBar.CHILD_VARIANT_DECREMENT_BUTTON) == null) {
			styleProvider.setStyleFunction(Button, HScrollBar.CHILD_VARIANT_DECREMENT_BUTTON, function(button:Button):Void {
				if (button.backgroundSkin == null) {
					var skin = new RectangleSkin();
					skin.fill = theme.getControlFill();
					skin.disabledFill = theme.getControlDisabledFill();
					skin.setFillForState(ButtonState.DOWN, theme.getReversedActiveThemeFill());
					skin.border = None;
					skin.width = 12.0;
					skin.height = 12.0;
					button.backgroundSkin = skin;
				}

				if (button.icon == null) {
					var icon = new TriangleSkin();
					icon.pointPosition = LEFT;
					icon.fill = SolidColor(theme.scrollBarThumbFillColor);
					icon.disabledFill = SolidColor(theme.scrollBarThumbDisabledFillColor);
					icon.width = 4.0;
					icon.height = 8.0;
					button.icon = icon;
				}

				button.showText = false;

				button.paddingTop = theme.xsmallPadding;
				button.paddingRight = theme.xsmallPadding;
				button.paddingBottom = theme.xsmallPadding;
				button.paddingLeft = theme.xsmallPadding;
				button.gap = theme.xsmallPadding;
			});
		}

		if (styleProvider.getStyleFunction(Button, HScrollBar.CHILD_VARIANT_INCREMENT_BUTTON) == null) {
			styleProvider.setStyleFunction(Button, HScrollBar.CHILD_VARIANT_INCREMENT_BUTTON, function(button:Button):Void {
				if (button.backgroundSkin == null) {
					var skin = new RectangleSkin();
					skin.fill = theme.getControlFill();
					skin.disabledFill = theme.getControlDisabledFill();
					skin.setFillForState(ButtonState.DOWN, theme.getReversedActiveThemeFill());
					skin.border = None;
					skin.width = 12.0;
					skin.height = 12.0;
					button.backgroundSkin = skin;
				}

				if (button.icon == null) {
					var icon = new TriangleSkin();
					icon.pointPosition = RIGHT;
					icon.fill = SolidColor(theme.scrollBarThumbFillColor);
					icon.disabledFill = SolidColor(theme.scrollBarThumbDisabledFillColor);
					icon.width = 4.0;
					icon.height = 8.0;
					button.icon = icon;
				}

				button.showText = false;

				button.paddingTop = theme.xsmallPadding;
				button.paddingRight = theme.xsmallPadding;
				button.paddingBottom = theme.xsmallPadding;
				button.paddingLeft = theme.xsmallPadding;
				button.gap = theme.xsmallPadding;
			});
		}
	}
}

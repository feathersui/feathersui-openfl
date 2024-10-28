/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.Collapsible;
import feathers.controls.ToggleButton;
import feathers.controls.ToggleButtonState;
import feathers.skins.MultiSkin;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;
import feathers.utils.DeviceUtil;
import openfl.display.Shape;

/**
	Initialize "steel" styles for the `Collapsible` component.

	@since 1.3.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelCollapsibleStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;

		if (styleProvider.getStyleFunction(ToggleButton, Collapsible.CHILD_VARIANT_HEADER) == null) {
			styleProvider.setStyleFunction(ToggleButton, Collapsible.CHILD_VARIANT_HEADER, function(button:ToggleButton):Void {
				var isDesktop = DeviceUtil.isDesktop();
				if (button.backgroundSkin == null) {
					var skin = new RectangleSkin();
					skin.fill = theme.getButtonFill();
					skin.disabledFill = theme.getButtonDisabledFill();
					skin.setFillForState(ToggleButtonState.DOWN(false), theme.getReversedActiveThemeFill());
					skin.setFillForState(ToggleButtonState.DOWN(true), theme.getReversedActiveThemeFill());
					skin.border = theme.getButtonBorder();
					skin.disabledBorder = theme.getButtonDisabledBorder();
					skin.setBorderForState(ToggleButtonState.DOWN(false), theme.getActiveFillBorder());
					skin.setBorderForState(ToggleButtonState.DOWN(true), theme.getActiveFillBorder());
					skin.cornerRadius = 0.0;
					skin.minWidth = 22.0;
					skin.minHeight = 22.0;
					button.backgroundSkin = skin;
				}

				if (button.icon == null) {
					var icon = new MultiSkin();
					button.icon = icon;

					var defaultIcon = new Shape();
					drawDisclosureClosedIcon(defaultIcon, theme.textColor, isDesktop);
					icon.defaultView = defaultIcon;

					var disabledIcon = new Shape();
					drawDisclosureClosedIcon(disabledIcon, theme.disabledTextColor, isDesktop);
					icon.disabledView = disabledIcon;

					var selectedIcon = new Shape();
					drawDisclosureOpenIcon(selectedIcon, theme.textColor, isDesktop);
					icon.selectedView = selectedIcon;

					var selectedDisabledIcon = new Shape();
					drawDisclosureOpenIcon(selectedDisabledIcon, theme.disabledTextColor, isDesktop);
					icon.setViewForState(DISABLED(true), selectedDisabledIcon);
				}

				if (button.focusRectSkin == null) {
					var focusRectSkin = new RectangleSkin();
					focusRectSkin.fill = None;
					focusRectSkin.border = theme.getFocusBorder();
					button.focusRectSkin = focusRectSkin;
				}

				if (button.textFormat == null) {
					button.textFormat = theme.getTextFormat();
				}
				if (button.disabledTextFormat == null) {
					button.disabledTextFormat = theme.getDisabledTextFormat();
				}

				if (isDesktop) {
					button.paddingTop = theme.smallPadding;
					button.paddingRight = theme.mediumPadding;
					button.paddingBottom = theme.smallPadding;
					button.paddingLeft = theme.mediumPadding;
				} else {
					button.paddingTop = theme.smallPadding;
					button.paddingRight = theme.largePadding;
					button.paddingBottom = theme.smallPadding;
					button.paddingLeft = theme.largePadding;
				}
				button.gap = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround for swf
				button.minGap = theme.smallPadding;
				button.iconPosition = RIGHT;
				button.horizontalAlign = LEFT;
				button.verticalAlign = MIDDLE;
			});
		}
	}

	private static function drawDisclosureClosedIcon(icon:Shape, color:UInt, isDesktop:Bool):Void {
		icon.graphics.beginFill(0xff00ff, 0.0);
		if (isDesktop) {
			icon.graphics.drawRect(0.0, 0.0, 16.0, 16.0);
		} else {
			icon.graphics.drawRect(0.0, 0.0, 20.0, 20.0);
		}
		icon.graphics.endFill();
		icon.graphics.beginFill(color);
		if (isDesktop) {
			icon.graphics.moveTo(4.0, 6.0);
			icon.graphics.lineTo(12.0, 6.0);
			icon.graphics.lineTo(8.0, 10.0);
			icon.graphics.lineTo(4.0, 6.0);
		} else {
			icon.graphics.moveTo(4.0, 6.0);
			icon.graphics.lineTo(16.0, 6.0);
			icon.graphics.lineTo(10.0, 14.0);
			icon.graphics.lineTo(4.0, 6.0);
		}
		icon.graphics.endFill();
		icon.graphics.beginFill(color);
		icon.graphics.endFill();
	}

	private static function drawDisclosureOpenIcon(icon:Shape, color:UInt, isDesktop:Bool):Void {
		icon.graphics.beginFill(0xff00ff, 0.0);
		if (isDesktop) {
			icon.graphics.drawRect(0.0, 0.0, 16.0, 16.0);
		} else {
			icon.graphics.drawRect(0.0, 0.0, 20.0, 20.0);
		}
		icon.graphics.endFill();
		icon.graphics.beginFill(color);
		if (isDesktop) {
			icon.graphics.moveTo(4.0, 10.0);
			icon.graphics.lineTo(12.0, 10.0);
			icon.graphics.lineTo(8.0, 6.0);
			icon.graphics.lineTo(4.0, 10.0);
		} else {
			icon.graphics.moveTo(4.0, 14.0);
			icon.graphics.lineTo(16.0, 14.0);
			icon.graphics.lineTo(10.0, 6.0);
			icon.graphics.lineTo(4.0, 14.0);
		}
		icon.graphics.endFill();
	}
}

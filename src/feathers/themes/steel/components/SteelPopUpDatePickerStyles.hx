/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.utils.DeviceUtil;
import feathers.controls.Button;
import feathers.controls.ButtonState;
import feathers.controls.DatePicker;
import feathers.controls.PopUpDatePicker;
import feathers.controls.TextInput;
import feathers.controls.TextInputState;
import feathers.skins.RectangleSkin;
import feathers.skins.TabSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;
import openfl.display.Shape;

/**
	Initialize "steel" styles for the `PopUpDatePicker` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelPopUpDatePickerStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(Button, PopUpDatePicker.CHILD_VARIANT_BUTTON) == null) {
			styleProvider.setStyleFunction(Button, PopUpDatePicker.CHILD_VARIANT_BUTTON, function(button:Button):Void {
				var isDesktop = DeviceUtil.isDesktop();
				if (button.backgroundSkin == null) {
					var skin = new TabSkin();
					skin.cornerRadiusPosition = RIGHT;
					skin.fill = theme.getButtonFill();
					skin.disabledFill = theme.getButtonDisabledFill();
					skin.setFillForState(ButtonState.DOWN, theme.getReversedActiveThemeFill());
					skin.border = theme.getButtonBorder();
					skin.disabledBorder = theme.getButtonDisabledBorder();
					skin.setBorderForState(ButtonState.DOWN, theme.getActiveFillBorder());
					skin.cornerRadius = 3.0;
					button.backgroundSkin = skin;
				}

				if (button.icon == null) {
					var icon = new Shape();
					drawIcon(icon, theme.textColor);
					button.icon = icon;

					if (button.getIconForState(ButtonState.DISABLED) == null) {
						var disabledIcon = new Shape();
						drawIcon(disabledIcon, theme.disabledTextColor);
						button.setIconForState(ButtonState.DISABLED, disabledIcon);
					}
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
				button.gap = theme.smallPadding;
			});
		}
		if (styleProvider.getStyleFunction(TextInput, PopUpDatePicker.CHILD_VARIANT_TEXT_INPUT) == null) {
			styleProvider.setStyleFunction(TextInput, PopUpDatePicker.CHILD_VARIANT_TEXT_INPUT, function(input:TextInput):Void {
				var isDesktop = DeviceUtil.isDesktop();
				if (input.backgroundSkin == null) {
					var inputSkin = new TabSkin();
					inputSkin.cornerRadiusPosition = LEFT;
					inputSkin.cornerRadius = 3.0;
					inputSkin.drawBaseBorder = false;
					if (isDesktop) {
						inputSkin.width = 120.0;
					} else {
						inputSkin.width = 160.0;
					}
					inputSkin.fill = theme.getInsetFill();
					inputSkin.disabledFill = theme.getDisabledInsetFill();
					inputSkin.border = theme.getInsetBorder();
					inputSkin.disabledBorder = theme.getDisabledInsetBorder();
					inputSkin.setBorderForState(TextInputState.FOCUSED, theme.getThemeBorder());
					input.backgroundSkin = inputSkin;
				}

				if (input.textFormat == null) {
					input.textFormat = theme.getTextFormat();
				}
				if (input.disabledTextFormat == null) {
					input.disabledTextFormat = theme.getDisabledTextFormat();
				}
				if (input.promptTextFormat == null) {
					input.promptTextFormat = theme.getSecondaryTextFormat();
				}

				if (isDesktop) {
					input.paddingTop = theme.smallPadding;
					input.paddingRight = theme.mediumPadding;
					input.paddingBottom = theme.smallPadding;
					input.paddingLeft = theme.mediumPadding;
				} else {
					input.paddingTop = theme.mediumPadding;
					input.paddingRight = theme.largePadding;
					input.paddingBottom = theme.mediumPadding;
					input.paddingLeft = theme.largePadding;
				}
			});
		}
		if (styleProvider.getStyleFunction(DatePicker, PopUpDatePicker.CHILD_VARIANT_DATE_PICKER) == null) {
			styleProvider.setStyleFunction(DatePicker, PopUpDatePicker.CHILD_VARIANT_DATE_PICKER, function(datePicker:DatePicker):Void {
				if (datePicker.backgroundSkin == null) {
					var backgroundSkin = new RectangleSkin();
					backgroundSkin.fill = theme.getContainerFill();
					backgroundSkin.border = theme.getContainerBorder();
					backgroundSkin.cornerRadius = 4.0;
					datePicker.backgroundSkin = backgroundSkin;
				}

				datePicker.setPadding(theme.mediumPadding);
				datePicker.headerGap = theme.xsmallPadding;
			});
		}
	}

	private static function drawIcon(icon:Shape, iconColor:Int):Void {
		// outline
		icon.graphics.lineStyle(1.0, iconColor);
		icon.graphics.drawRect(0.5, 1.5, 11.0, 10.0);
		icon.graphics.moveTo(3.0, 0.5);
		icon.graphics.lineTo(3.0, 1.5);
		icon.graphics.moveTo(9.0, 0.5);
		icon.graphics.lineTo(9.0, 1.5);

		// fills
		icon.graphics.lineStyle();
		icon.graphics.beginFill(iconColor);

		// header
		icon.graphics.drawRect(1.0, 2.0, 11.0, 2.0);

		// first row
		icon.graphics.drawRect(2.0, 5.0, 2.0, 2.0);
		icon.graphics.drawRect(5.0, 5.0, 2.0, 2.0);
		icon.graphics.drawRect(8.0, 5.0, 2.0, 2.0);

		// second row
		icon.graphics.drawRect(2.0, 8.0, 2.0, 2.0);
		icon.graphics.drawRect(5.0, 8.0, 2.0, 2.0);
		icon.graphics.drawRect(8.0, 8.0, 2.0, 2.0);

		icon.graphics.endFill();
	}
}

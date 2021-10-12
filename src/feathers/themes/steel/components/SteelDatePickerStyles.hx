/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.ButtonState;
import openfl.display.Shape;
import feathers.controls.Button;
import feathers.controls.DatePicker;
import feathers.controls.Label;
import feathers.skins.RectangleSkin;
import feathers.skins.TriangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

/**
	Initialize "steel" styles for the `DatePicker` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelDatePickerStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(DatePicker, null) == null) {
			styleProvider.setStyleFunction(DatePicker, null, function(datePicker:DatePicker):Void {
				if (datePicker.backgroundSkin == null) {
					var backgroundSkin = new RectangleSkin();
					backgroundSkin.fill = theme.getContainerFill();
					datePicker.backgroundSkin = backgroundSkin;
				}

				datePicker.headerGap = 2.0;
			});
		}
		if (styleProvider.getStyleFunction(Label, DatePicker.CHILD_VARIANT_CURRENT_MONTH_VIEW) == null) {
			styleProvider.setStyleFunction(Label, DatePicker.CHILD_VARIANT_CURRENT_MONTH_VIEW, function(button:Label):Void {
				if (button.textFormat == null) {
					button.textFormat = theme.getTextFormat();
				}
				if (button.disabledTextFormat == null) {
					button.disabledTextFormat = theme.getDisabledTextFormat();
				}
			});
		}
		if (styleProvider.getStyleFunction(Button, DatePicker.CHILD_VARIANT_DECREMENT_MONTH_BUTTON) == null) {
			styleProvider.setStyleFunction(Button, DatePicker.CHILD_VARIANT_DECREMENT_MONTH_BUTTON, function(button:Button):Void {
				if (button.backgroundSkin == null) {
					var skin = new RectangleSkin();
					skin.fill = theme.getButtonFill();
					skin.setFillForState(DOWN, theme.getReversedActiveThemeFill());
					skin.setFillForState(DISABLED, theme.getButtonDisabledFill());
					skin.border = theme.getButtonBorder();
					skin.setBorderForState(DOWN, theme.getActiveFillBorder());
					skin.cornerRadius = 3.0;
					button.backgroundSkin = skin;
				}

				if (button.icon == null) {
					var icon = new Shape();
					icon.graphics.beginFill(0xff00ff, 0.0);
					icon.graphics.drawRect(0.0, 0.0, 8.0, 8.0);
					icon.graphics.endFill();
					icon.graphics.beginFill(theme.textColor);
					icon.graphics.moveTo(2.0, 4.0);
					icon.graphics.lineTo(6.0, 0.0);
					icon.graphics.lineTo(6.0, 8.0);
					icon.graphics.lineTo(2.0, 4.0);
					icon.graphics.endFill();
					button.icon = icon;
				}

				if (button.getIconForState(DISABLED) == null) {
					var disabledIcon = new Shape();
					disabledIcon.graphics.beginFill(0xff00ff, 0.0);
					disabledIcon.graphics.drawRect(0.0, 0.0, 8.0, 8.0);
					disabledIcon.graphics.endFill();
					disabledIcon.graphics.beginFill(theme.disabledTextColor);
					disabledIcon.graphics.moveTo(2.0, 4.0);
					disabledIcon.graphics.lineTo(6.0, 0.0);
					disabledIcon.graphics.lineTo(6.0, 8.0);
					disabledIcon.graphics.lineTo(2.0, 4.0);
					disabledIcon.graphics.endFill();
					button.setIconForState(DISABLED, disabledIcon);
				}

				button.setPadding(4.0);
				button.gap = 4.0;
			});
		}
		if (styleProvider.getStyleFunction(Button, DatePicker.CHILD_VARIANT_INCREMENT_MONTH_BUTTON) == null) {
			styleProvider.setStyleFunction(Button, DatePicker.CHILD_VARIANT_INCREMENT_MONTH_BUTTON, function(button:Button):Void {
				if (button.backgroundSkin == null) {
					var skin = new RectangleSkin();
					skin.fill = theme.getButtonFill();
					skin.setFillForState(DOWN, theme.getReversedActiveThemeFill());
					skin.setFillForState(DISABLED, theme.getButtonDisabledFill());
					skin.border = theme.getButtonBorder();
					skin.setBorderForState(DOWN, theme.getActiveFillBorder());
					skin.cornerRadius = 3.0;
					button.backgroundSkin = skin;
				}

				if (button.icon == null) {
					var icon = new Shape();
					icon.graphics.beginFill(0xff00ff, 0.0);
					icon.graphics.drawRect(0.0, 0.0, 8.0, 8.0);
					icon.graphics.endFill();
					icon.graphics.beginFill(theme.textColor);
					icon.graphics.moveTo(2.0, 0.0);
					icon.graphics.lineTo(6.0, 4.0);
					icon.graphics.lineTo(2.0, 8.0);
					icon.graphics.lineTo(2.0, 0.0);
					icon.graphics.endFill();
					button.icon = icon;
				}

				if (button.getIconForState(DISABLED) == null) {
					var disabledIcon = new Shape();
					disabledIcon.graphics.beginFill(0xff00ff, 0.0);
					disabledIcon.graphics.drawRect(0.0, 0.0, 8.0, 8.0);
					disabledIcon.graphics.endFill();
					disabledIcon.graphics.beginFill(theme.disabledTextColor);
					disabledIcon.graphics.moveTo(2.0, 0.0);
					disabledIcon.graphics.lineTo(6.0, 4.0);
					disabledIcon.graphics.lineTo(2.0, 8.0);
					disabledIcon.graphics.lineTo(2.0, 0.0);
					disabledIcon.graphics.endFill();
					button.setIconForState(DISABLED, disabledIcon);
				}

				button.setPadding(4.0);
				button.gap = 4.0;
			});
		}
		if (styleProvider.getStyleFunction(Button, DatePicker.CHILD_VARIANT_DECREMENT_YEAR_BUTTON) == null) {
			styleProvider.setStyleFunction(Button, DatePicker.CHILD_VARIANT_DECREMENT_YEAR_BUTTON, function(button:Button):Void {
				if (button.backgroundSkin == null) {
					var skin = new RectangleSkin();
					skin.fill = theme.getButtonFill();
					skin.setFillForState(DOWN, theme.getReversedActiveThemeFill());
					skin.setFillForState(DISABLED, theme.getButtonDisabledFill());
					skin.border = theme.getButtonBorder();
					skin.setBorderForState(DOWN, theme.getActiveFillBorder());
					skin.cornerRadius = 3.0;
					button.backgroundSkin = skin;
				}

				if (button.icon == null) {
					var icon = new Shape();
					icon.graphics.beginFill(theme.textColor);
					icon.graphics.moveTo(0.0, 4.0);
					icon.graphics.lineTo(4.0, 0.0);
					icon.graphics.lineTo(4.0, 8.0);
					icon.graphics.lineTo(0.0, 4.0);
					icon.graphics.moveTo(4.0, 4.0);
					icon.graphics.lineTo(8.0, 0.0);
					icon.graphics.lineTo(8.0, 8.0);
					icon.graphics.lineTo(4.0, 4.0);
					icon.graphics.endFill();
					button.icon = icon;
				}

				if (button.getIconForState(DISABLED) == null) {
					var disabledIcon = new Shape();
					disabledIcon.graphics.beginFill(theme.disabledTextColor);
					disabledIcon.graphics.moveTo(0.0, 4.0);
					disabledIcon.graphics.lineTo(4.0, 0.0);
					disabledIcon.graphics.lineTo(4.0, 8.0);
					disabledIcon.graphics.lineTo(0.0, 4.0);
					disabledIcon.graphics.moveTo(4.0, 4.0);
					disabledIcon.graphics.lineTo(8.0, 0.0);
					disabledIcon.graphics.lineTo(8.0, 8.0);
					disabledIcon.graphics.lineTo(4.0, 4.0);
					disabledIcon.graphics.endFill();
					button.setIconForState(DISABLED, disabledIcon);
				}

				button.setPadding(4.0);
				button.gap = 4.0;
			});
		}
		if (styleProvider.getStyleFunction(Button, DatePicker.CHILD_VARIANT_INCREMENT_YEAR_BUTTON) == null) {
			styleProvider.setStyleFunction(Button, DatePicker.CHILD_VARIANT_INCREMENT_YEAR_BUTTON, function(button:Button):Void {
				if (button.backgroundSkin == null) {
					var skin = new RectangleSkin();
					skin.fill = theme.getButtonFill();
					skin.setFillForState(DOWN, theme.getReversedActiveThemeFill());
					skin.setFillForState(DISABLED, theme.getButtonDisabledFill());
					skin.border = theme.getButtonBorder();
					skin.setBorderForState(DOWN, theme.getActiveFillBorder());
					skin.cornerRadius = 3.0;
					button.backgroundSkin = skin;
				}

				if (button.icon == null) {
					var icon = new Shape();
					icon.graphics.beginFill(theme.textColor);
					icon.graphics.moveTo(0.0, 0.0);
					icon.graphics.lineTo(4.0, 4.0);
					icon.graphics.lineTo(0.0, 8.0);
					icon.graphics.lineTo(0.0, 0.0);
					icon.graphics.moveTo(4.0, 0.0);
					icon.graphics.lineTo(8.0, 4.0);
					icon.graphics.lineTo(4.0, 8.0);
					icon.graphics.lineTo(4.0, 0.0);
					icon.graphics.endFill();
					button.icon = icon;
				}

				if (button.getIconForState(DISABLED) == null) {
					var disabledIcon = new Shape();
					disabledIcon.graphics.beginFill(theme.disabledTextColor);
					disabledIcon.graphics.moveTo(0.0, 0.0);
					disabledIcon.graphics.lineTo(4.0, 4.0);
					disabledIcon.graphics.lineTo(0.0, 8.0);
					disabledIcon.graphics.lineTo(0.0, 0.0);
					disabledIcon.graphics.moveTo(4.0, 0.0);
					disabledIcon.graphics.lineTo(8.0, 4.0);
					disabledIcon.graphics.lineTo(4.0, 8.0);
					disabledIcon.graphics.lineTo(4.0, 0.0);
					disabledIcon.graphics.endFill();
					button.setIconForState(DISABLED, disabledIcon);
				}

				button.setPadding(4.0);
				button.gap = 4.0;
			});
		}
	}
}

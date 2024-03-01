/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.Button;
import feathers.controls.ButtonState;
import feathers.controls.DatePicker;
import feathers.controls.Label;
import feathers.controls.ToggleButtonState;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;
import feathers.utils.DeviceUtil;
import openfl.display.Shape;

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
					backgroundSkin.border = None;
					backgroundSkin.fill = theme.getContainerFill();
					datePicker.backgroundSkin = backgroundSkin;
				}

				if (datePicker.focusRectSkin == null) {
					var focusRectSkin = new RectangleSkin();
					focusRectSkin.fill = None;
					focusRectSkin.border = theme.getFocusBorder();
					datePicker.focusRectSkin = focusRectSkin;
				}

				datePicker.focusPaddingTop = 3.0;
				datePicker.focusPaddingRight = 3.0;
				datePicker.focusPaddingBottom = 3.0;
				datePicker.focusPaddingLeft = 3.0;

				datePicker.headerGap = theme.xsmallPadding;
			});
		}
		if (styleProvider.getStyleFunction(Label, DatePicker.CHILD_VARIANT_MONTH_TITLE_VIEW) == null) {
			styleProvider.setStyleFunction(Label, DatePicker.CHILD_VARIANT_MONTH_TITLE_VIEW, function(view:Label):Void {
				if (view.textFormat == null) {
					view.textFormat = theme.getTextFormat();
				}
				if (view.disabledTextFormat == null) {
					view.disabledTextFormat = theme.getDisabledTextFormat();
				}
			});
		}
		if (styleProvider.getStyleFunction(Button, DatePicker.CHILD_VARIANT_DECREMENT_MONTH_BUTTON) == null) {
			styleProvider.setStyleFunction(Button, DatePicker.CHILD_VARIANT_DECREMENT_MONTH_BUTTON, function(button:Button):Void {
				var isDesktop = DeviceUtil.isDesktop();
				if (button.backgroundSkin == null) {
					var skin = new RectangleSkin();
					skin.fill = theme.getButtonFill();
					skin.setFillForState(ButtonState.DOWN, theme.getReversedActiveThemeFill());
					skin.setFillForState(ButtonState.DISABLED, theme.getButtonDisabledFill());
					skin.border = theme.getButtonBorder();
					skin.disabledBorder = theme.getButtonDisabledBorder();
					skin.setBorderForState(ButtonState.DOWN, theme.getActiveFillBorder());
					skin.cornerRadius = 3.0;
					if (isDesktop) {
						skin.width = 20.0;
						skin.height = 20.0;
					} else {
						skin.width = 24.0;
						skin.height = 24.0;
					}
					button.backgroundSkin = skin;
				}

				if (button.icon == null) {
					var icon = new Shape();
					drawDecrementMonthIcon(icon, theme.textColor);
					button.icon = icon;
				}

				if (button.getIconForState(ButtonState.DISABLED) == null) {
					var disabledIcon = new Shape();
					drawDecrementMonthIcon(disabledIcon, theme.disabledTextColor);
					button.setIconForState(ButtonState.DISABLED, disabledIcon);
				}

				button.setPadding(theme.smallPadding);
				button.gap = theme.smallPadding;
			});
		}
		if (styleProvider.getStyleFunction(Button, DatePicker.CHILD_VARIANT_INCREMENT_MONTH_BUTTON) == null) {
			styleProvider.setStyleFunction(Button, DatePicker.CHILD_VARIANT_INCREMENT_MONTH_BUTTON, function(button:Button):Void {
				var isDesktop = DeviceUtil.isDesktop();
				if (button.backgroundSkin == null) {
					var skin = new RectangleSkin();
					skin.fill = theme.getButtonFill();
					skin.setFillForState(ButtonState.DOWN, theme.getReversedActiveThemeFill());
					skin.setFillForState(ButtonState.DISABLED, theme.getButtonDisabledFill());
					skin.border = theme.getButtonBorder();
					skin.disabledBorder = theme.getButtonDisabledBorder();
					skin.setBorderForState(ButtonState.DOWN, theme.getActiveFillBorder());
					skin.cornerRadius = 3.0;
					if (isDesktop) {
						skin.width = 20.0;
						skin.height = 20.0;
					} else {
						skin.width = 24.0;
						skin.height = 24.0;
					}
					button.backgroundSkin = skin;
				}

				if (button.icon == null) {
					var icon = new Shape();
					drawIncrementMonthIcon(icon, theme.textColor);
					button.icon = icon;
				}

				if (button.getIconForState(ButtonState.DISABLED) == null) {
					var disabledIcon = new Shape();
					drawIncrementMonthIcon(disabledIcon, theme.disabledTextColor);
					button.setIconForState(ButtonState.DISABLED, disabledIcon);
				}

				button.setPadding(theme.smallPadding);
				button.gap = theme.smallPadding;
			});
		}
		if (styleProvider.getStyleFunction(Button, DatePicker.CHILD_VARIANT_DECREMENT_YEAR_BUTTON) == null) {
			styleProvider.setStyleFunction(Button, DatePicker.CHILD_VARIANT_DECREMENT_YEAR_BUTTON, function(button:Button):Void {
				var isDesktop = DeviceUtil.isDesktop();
				if (button.backgroundSkin == null) {
					var skin = new RectangleSkin();
					skin.fill = theme.getButtonFill();
					skin.setFillForState(ButtonState.DOWN, theme.getReversedActiveThemeFill());
					skin.setFillForState(ButtonState.DISABLED, theme.getButtonDisabledFill());
					skin.border = theme.getButtonBorder();
					skin.disabledBorder = theme.getButtonDisabledBorder();
					skin.setBorderForState(ButtonState.DOWN, theme.getActiveFillBorder());
					skin.cornerRadius = 3.0;
					if (isDesktop) {
						skin.width = 20.0;
						skin.height = 20.0;
					} else {
						skin.width = 24.0;
						skin.height = 24.0;
					}
					button.backgroundSkin = skin;
				}

				if (button.icon == null) {
					var icon = new Shape();
					drawDecrementYearIcon(icon, theme.textColor);
					button.icon = icon;
				}

				if (button.getIconForState(ButtonState.DISABLED) == null) {
					var disabledIcon = new Shape();
					drawDecrementYearIcon(disabledIcon, theme.disabledTextColor);
					button.setIconForState(ButtonState.DISABLED, disabledIcon);
				}

				button.setPadding(theme.smallPadding);
				button.gap = theme.smallPadding;
			});
		}
		if (styleProvider.getStyleFunction(Button, DatePicker.CHILD_VARIANT_INCREMENT_YEAR_BUTTON) == null) {
			styleProvider.setStyleFunction(Button, DatePicker.CHILD_VARIANT_INCREMENT_YEAR_BUTTON, function(button:Button):Void {
				var isDesktop = DeviceUtil.isDesktop();
				if (button.backgroundSkin == null) {
					var skin = new RectangleSkin();
					skin.fill = theme.getButtonFill();
					skin.setFillForState(ButtonState.DOWN, theme.getReversedActiveThemeFill());
					skin.setFillForState(ButtonState.DISABLED, theme.getButtonDisabledFill());
					skin.border = theme.getButtonBorder();
					skin.disabledBorder = theme.getButtonDisabledBorder();
					skin.setBorderForState(ButtonState.DOWN, theme.getActiveFillBorder());
					skin.cornerRadius = 3.0;
					if (isDesktop) {
						skin.width = 20.0;
						skin.height = 20.0;
					} else {
						skin.width = 24.0;
						skin.height = 24.0;
					}
					button.backgroundSkin = skin;
				}

				if (button.icon == null) {
					var icon = new Shape();
					drawIncrementYearIcon(icon, theme.textColor);
					button.icon = icon;
				}

				if (button.getIconForState(ButtonState.DISABLED) == null) {
					var disabledIcon = new Shape();
					drawIncrementYearIcon(disabledIcon, theme.disabledTextColor);
					button.setIconForState(ButtonState.DISABLED, disabledIcon);
				}

				button.setPadding(theme.smallPadding);
				button.gap = theme.smallPadding;
			});
		}
		if (styleProvider.getStyleFunction(Label, DatePicker.CHILD_VARIANT_WEEKDAY_LABEL) == null) {
			styleProvider.setStyleFunction(Label, DatePicker.CHILD_VARIANT_WEEKDAY_LABEL, function(label:Label):Void {
				if (label.textFormat == null) {
					label.textFormat = theme.getSecondaryTextFormat(CENTER);
				}
				if (label.disabledTextFormat == null) {
					label.disabledTextFormat = theme.getDisabledTextFormat(CENTER);
				}
				label.verticalAlign = MIDDLE;
			});
		}
		if (styleProvider.getStyleFunction(ItemRenderer, DatePicker.CHILD_VARIANT_DATE_RENDERER) == null) {
			styleProvider.setStyleFunction(ItemRenderer, DatePicker.CHILD_VARIANT_DATE_RENDERER, function(dateRenderer:ItemRenderer):Void {
				var isDesktop = DeviceUtil.isDesktop();
				if (dateRenderer.backgroundSkin == null) {
					var backgroundSkin = new RectangleSkin();
					backgroundSkin.fill = SolidColor(0xff00ff, 0.0);
					backgroundSkin.selectedFill = theme.getActiveThemeFill();
					backgroundSkin.setFillForState(ToggleButtonState.DOWN(false), theme.getReversedActiveThemeFill());
					backgroundSkin.border = None;
					backgroundSkin.selectedBorder = theme.getSelectedBorder();
					backgroundSkin.setBorderForState(ToggleButtonState.DOWN(false), theme.getActiveFillBorder());
					if (isDesktop) {
						backgroundSkin.width = 20.0;
						backgroundSkin.height = 20.0;
					} else {
						backgroundSkin.width = 32.0;
						backgroundSkin.height = 32.0;
					}
					backgroundSkin.cornerRadius = 4.0;
					dateRenderer.backgroundSkin = backgroundSkin;
				}

				if (dateRenderer.textFormat == null) {
					dateRenderer.textFormat = theme.getTextFormat();
				}
				if (dateRenderer.disabledTextFormat == null) {
					dateRenderer.disabledTextFormat = theme.getDisabledTextFormat();
				}
				if (dateRenderer.secondaryTextFormat == null) {
					dateRenderer.secondaryTextFormat = theme.getSecondaryDetailTextFormat();
				}
				if (dateRenderer.disabledSecondaryTextFormat == null) {
					dateRenderer.disabledSecondaryTextFormat = theme.getDisabledDetailTextFormat();
				}

				dateRenderer.horizontalAlign = CENTER;
				dateRenderer.verticalAlign = MIDDLE;

				dateRenderer.paddingTop = theme.xsmallPadding;
				dateRenderer.paddingRight = theme.xsmallPadding;
				dateRenderer.paddingBottom = theme.xsmallPadding;
				dateRenderer.paddingLeft = theme.xsmallPadding;
			});
		}
		if (styleProvider.getStyleFunction(ItemRenderer, DatePicker.CHILD_VARIANT_MUTED_DATE_RENDERER) == null) {
			styleProvider.setStyleFunction(ItemRenderer, DatePicker.CHILD_VARIANT_MUTED_DATE_RENDERER, function(dateRenderer:ItemRenderer):Void {
				var isDesktop = DeviceUtil.isDesktop();
				if (dateRenderer.backgroundSkin == null) {
					var backgroundSkin = new RectangleSkin();
					backgroundSkin.fill = SolidColor(0xff00ff, 0.0);
					backgroundSkin.selectedFill = theme.getActiveThemeFill();
					backgroundSkin.setFillForState(ToggleButtonState.DOWN(false), theme.getReversedActiveThemeFill());
					backgroundSkin.border = None;
					backgroundSkin.selectedBorder = theme.getSelectedBorder();
					backgroundSkin.setBorderForState(ToggleButtonState.DOWN(false), theme.getActiveFillBorder());
					if (isDesktop) {
						backgroundSkin.width = 20.0;
						backgroundSkin.height = 20.0;
					} else {
						backgroundSkin.width = 32.0;
						backgroundSkin.height = 32.0;
					}
					backgroundSkin.cornerRadius = 4.0;
					dateRenderer.backgroundSkin = backgroundSkin;
				}

				if (dateRenderer.textFormat == null) {
					dateRenderer.textFormat = theme.getSecondaryTextFormat();
				}
				if (dateRenderer.disabledTextFormat == null) {
					dateRenderer.disabledTextFormat = theme.getDisabledTextFormat();
				}
				if (dateRenderer.secondaryTextFormat == null) {
					dateRenderer.secondaryTextFormat = theme.getSecondaryDetailTextFormat();
				}
				if (dateRenderer.disabledSecondaryTextFormat == null) {
					dateRenderer.disabledSecondaryTextFormat = theme.getDisabledDetailTextFormat();
				}

				dateRenderer.horizontalAlign = CENTER;
				dateRenderer.verticalAlign = MIDDLE;

				dateRenderer.paddingTop = theme.xsmallPadding;
				dateRenderer.paddingRight = theme.xsmallPadding;
				dateRenderer.paddingBottom = theme.xsmallPadding;
				dateRenderer.paddingLeft = theme.xsmallPadding;
			});
		}
	}

	private static function drawDecrementMonthIcon(icon:Shape, color:UInt):Void {
		icon.graphics.beginFill(0xff00ff, 0.0);
		icon.graphics.drawRect(0.0, 0.0, 8.0, 8.0);
		icon.graphics.endFill();
		icon.graphics.beginFill(color);
		icon.graphics.moveTo(2.0, 4.0);
		icon.graphics.lineTo(6.0, 0.0);
		icon.graphics.lineTo(6.0, 8.0);
		icon.graphics.lineTo(2.0, 4.0);
		icon.graphics.endFill();
	}

	private static function drawIncrementMonthIcon(icon:Shape, color:UInt):Void {
		icon.graphics.beginFill(0xff00ff, 0.0);
		icon.graphics.drawRect(0.0, 0.0, 8.0, 8.0);
		icon.graphics.endFill();
		icon.graphics.beginFill(color);
		icon.graphics.moveTo(2.0, 0.0);
		icon.graphics.lineTo(6.0, 4.0);
		icon.graphics.lineTo(2.0, 8.0);
		icon.graphics.lineTo(2.0, 0.0);
		icon.graphics.endFill();
	}

	private static function drawDecrementYearIcon(icon:Shape, color:UInt):Void {
		icon.graphics.beginFill(color);
		icon.graphics.moveTo(0.0, 4.0);
		icon.graphics.lineTo(4.0, 0.0);
		icon.graphics.lineTo(4.0, 8.0);
		icon.graphics.lineTo(0.0, 4.0);
		icon.graphics.moveTo(4.0, 4.0);
		icon.graphics.lineTo(8.0, 0.0);
		icon.graphics.lineTo(8.0, 8.0);
		icon.graphics.lineTo(4.0, 4.0);
		icon.graphics.endFill();
	}

	private static function drawIncrementYearIcon(icon:Shape, color:UInt):Void {
		icon.graphics.beginFill(color);
		icon.graphics.moveTo(0.0, 0.0);
		icon.graphics.lineTo(4.0, 4.0);
		icon.graphics.lineTo(0.0, 8.0);
		icon.graphics.lineTo(0.0, 0.0);
		icon.graphics.moveTo(4.0, 0.0);
		icon.graphics.lineTo(8.0, 4.0);
		icon.graphics.lineTo(4.0, 8.0);
		icon.graphics.lineTo(4.0, 0.0);
		icon.graphics.endFill();
	}
}

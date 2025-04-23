/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.utils.DeviceUtil;
import feathers.controls.Button;
import feathers.controls.ButtonState;
import feathers.controls.ComboBox;
import feathers.controls.ListView;
import feathers.controls.TextInput;
import feathers.controls.TextInputState;
import feathers.skins.TabSkin;
import feathers.skins.TriangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

/**
	Initialize "steel" styles for the `ComboBox` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelComboBoxStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;

		if (styleProvider.getStyleFunction(ComboBox, null) == null) {
			styleProvider.setStyleFunction(ComboBox, null, function(comboBox:ComboBox):Void {});
		}

		if (styleProvider.getStyleFunction(Button, ComboBox.CHILD_VARIANT_BUTTON) == null) {
			styleProvider.setStyleFunction(Button, ComboBox.CHILD_VARIANT_BUTTON, function(button:Button):Void {
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
					var icon = new TriangleSkin();
					icon.pointPosition = BOTTOM;
					icon.fill = SolidColor(theme.textColor);
					icon.disabledFill = SolidColor(theme.disabledTextColor);
					icon.width = 8.0;
					icon.height = 4.0;
					button.icon = icon;
				}

				button.paddingTop = theme.smallPadding;
				button.paddingRight = theme.largePadding;
				button.paddingBottom = theme.smallPadding;
				button.paddingLeft = theme.largePadding;
				button.gap = theme.smallPadding;
			});
		}

		if (styleProvider.getStyleFunction(TextInput, ComboBox.CHILD_VARIANT_TEXT_INPUT) == null) {
			styleProvider.setStyleFunction(TextInput, ComboBox.CHILD_VARIANT_TEXT_INPUT, function(input:TextInput):Void {
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

		if (styleProvider.getStyleFunction(ListView, ComboBox.CHILD_VARIANT_LIST_VIEW) == null) {
			styleProvider.setStyleFunction(ListView, ComboBox.CHILD_VARIANT_LIST_VIEW, function(listView:ListView):Void {
				theme.styleProvider.getStyleFunction(ListView, ListView.VARIANT_POP_UP)(listView);
			});
		}
	}
}

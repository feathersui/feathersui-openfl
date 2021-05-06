/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.ButtonState;
import feathers.skins.TabSkin;
import feathers.controls.NumericStepper;
import feathers.controls.Button;
import feathers.controls.TextInput;
import feathers.controls.TextInputState;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

/**
	Initialize "steel" styles for the `NumericStepper` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelNumericStepperStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;

		if (styleProvider.getStyleFunction(Button, NumericStepper.CHILD_VARIANT_DECREMENT_BUTTON) == null) {
			styleProvider.setStyleFunction(Button, NumericStepper.CHILD_VARIANT_DECREMENT_BUTTON, function(button:Button):Void {
				if (button.backgroundSkin == null) {
					var skin = new TabSkin();
					skin.cornerRadiusPosition = LEFT;
					skin.drawBaseBorder = false;
					skin.fill = theme.getButtonFill();
					skin.setFillForState(DOWN, theme.getReversedActiveThemeFill());
					skin.setFillForState(DISABLED, theme.getButtonDisabledFill());
					skin.border = theme.getButtonBorder();
					skin.setBorderForState(DOWN, theme.getActiveFillBorder());
					skin.cornerRadius = 3.0;
					button.backgroundSkin = skin;
				}

				if (button.textFormat == null) {
					button.textFormat = theme.getTextFormat();
				}
				if (button.disabledTextFormat == null) {
					button.disabledTextFormat = theme.getDisabledTextFormat();
				}

				button.paddingTop = 4.0;
				button.paddingRight = 10.0;
				button.paddingBottom = 4.0;
				button.paddingLeft = 10.0;
				button.gap = 4.0;
			});
		}

		if (styleProvider.getStyleFunction(Button, NumericStepper.CHILD_VARIANT_INCREMENT_BUTTON) == null) {
			styleProvider.setStyleFunction(Button, NumericStepper.CHILD_VARIANT_INCREMENT_BUTTON, function(button:Button):Void {
				if (button.backgroundSkin == null) {
					var skin = new TabSkin();
					skin.cornerRadiusPosition = RIGHT;
					skin.drawBaseBorder = false;
					skin.fill = theme.getButtonFill();
					skin.setFillForState(DOWN, theme.getReversedActiveThemeFill());
					skin.setFillForState(DISABLED, theme.getButtonDisabledFill());
					skin.border = theme.getButtonBorder();
					skin.setBorderForState(DOWN, theme.getActiveFillBorder());
					skin.cornerRadius = 3.0;
					button.backgroundSkin = skin;
				}

				if (button.textFormat == null) {
					button.textFormat = theme.getTextFormat();
				}
				if (button.disabledTextFormat == null) {
					button.disabledTextFormat = theme.getDisabledTextFormat();
				}

				button.paddingTop = 4.0;
				button.paddingRight = 10.0;
				button.paddingBottom = 4.0;
				button.paddingLeft = 10.0;
				button.gap = 4.0;
			});
		}

		if (styleProvider.getStyleFunction(TextInput, NumericStepper.CHILD_VARIANT_TEXT_INPUT) == null) {
			styleProvider.setStyleFunction(TextInput, NumericStepper.CHILD_VARIANT_TEXT_INPUT, function(input:TextInput):Void {
				if (input.backgroundSkin == null) {
					var inputSkin = new RectangleSkin();
					inputSkin.width = 80.0;
					inputSkin.fill = theme.getInsetFill();
					inputSkin.border = theme.getInsetBorder();
					inputSkin.disabledFill = theme.getDisabledInsetFill();
					inputSkin.setBorderForState(FOCUSED, theme.getThemeBorder());
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

				input.paddingTop = 6.0;
				input.paddingRight = 10.0;
				input.paddingBottom = 6.0;
				input.paddingLeft = 10.0;
			});
		}
	}
}

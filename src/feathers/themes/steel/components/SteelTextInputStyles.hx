/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.utils.DeviceUtil;
import feathers.controls.TextCallout;
import feathers.controls.TextInput;
import feathers.controls.TextInputState;
import feathers.skins.PillSkin;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

/**
	Initialize "steel" styles for the `TextInput` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelTextInputStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(TextInput, null) == null) {
			styleProvider.setStyleFunction(TextInput, null, function(input:TextInput):Void {
				var isDesktop = DeviceUtil.isDesktop();
				if (input.backgroundSkin == null) {
					var inputSkin = new RectangleSkin();
					inputSkin.cornerRadius = 3.0;
					if (isDesktop) {
						inputSkin.width = 120.0;
					} else {
						inputSkin.width = 160.0;
					}
					inputSkin.fill = theme.getInsetFill();
					inputSkin.border = theme.getInsetBorder();
					inputSkin.disabledFill = theme.getDisabledInsetFill();
					inputSkin.setBorderForState(FOCUSED, theme.getThemeBorder());
					inputSkin.setBorderForState(ERROR, theme.getDangerBorder());
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
		if (styleProvider.getStyleFunction(TextInput, TextInput.VARIANT_SEARCH) == null) {
			styleProvider.setStyleFunction(TextInput, TextInput.VARIANT_SEARCH, function(input:TextInput):Void {
				var isDesktop = DeviceUtil.isDesktop();
				if (input.backgroundSkin == null) {
					var inputSkin = new PillSkin();
					inputSkin.capDirection = HORIZONTAL;
					if (isDesktop) {
						inputSkin.width = 120.0;
					} else {
						inputSkin.width = 160.0;
					}
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

				if (isDesktop) {
					input.paddingTop = theme.smallPadding;
					input.paddingRight = theme.largePadding;
					input.paddingBottom = theme.smallPadding;
					input.paddingLeft = theme.largePadding;
				} else {
					input.paddingTop = theme.mediumPadding;
					input.paddingRight = theme.largePadding;
					input.paddingBottom = theme.mediumPadding;
					input.paddingLeft = theme.largePadding;
				}
			});
		}
		if (styleProvider.getStyleFunction(TextCallout, TextInput.CHILD_VARIANT_ERROR_CALLOUT) == null) {
			styleProvider.setStyleFunction(TextCallout, TextInput.CHILD_VARIANT_ERROR_CALLOUT, function(callout:TextCallout):Void {
				theme.styleProvider.getStyleFunction(TextCallout, TextCallout.VARIANT_DANGER)(callout);
			});
		}
	}
}

/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.TextArea;
import feathers.controls.TextCallout;
import feathers.controls.TextInputState;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;
import feathers.utils.DeviceUtil;

/**
	Initialize "steel" styles for the `TextArea` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelTextAreaStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(TextArea, null) == null) {
			styleProvider.setStyleFunction(TextArea, null, function(textArea:TextArea):Void {
				var isDesktop = DeviceUtil.isDesktop();

				textArea.autoHideScrollBars = !isDesktop;
				textArea.fixedScrollBars = isDesktop;

				if (textArea.backgroundSkin == null) {
					var backgroundSkin = new RectangleSkin();
					backgroundSkin.cornerRadius = 3.0;
					backgroundSkin.width = 160.0;
					backgroundSkin.height = 120.0;
					backgroundSkin.fill = theme.getInsetFill();
					backgroundSkin.border = theme.getInsetBorder();
					backgroundSkin.setBorderForState(FOCUSED, theme.getThemeBorder());
					backgroundSkin.setBorderForState(ERROR, theme.getDangerBorder());
					textArea.backgroundSkin = backgroundSkin;
				}

				if (textArea.textFormat == null) {
					textArea.textFormat = theme.getTextFormat();
				}
				if (textArea.disabledTextFormat == null) {
					textArea.disabledTextFormat = theme.getDisabledTextFormat();
				}
				if (textArea.promptTextFormat == null) {
					textArea.promptTextFormat = theme.getSecondaryTextFormat();
				}

				textArea.paddingTop = 1.0;
				textArea.paddingRight = 1.0;
				textArea.paddingBottom = 1.0;
				textArea.paddingLeft = 1.0;

				textArea.textPaddingTop = theme.smallPadding;
				textArea.textPaddingRight = 9.0;
				textArea.textPaddingBottom = theme.smallPadding + 1;
				textArea.textPaddingLeft = 9.0;
			});
		}
		if (styleProvider.getStyleFunction(TextCallout, TextArea.CHILD_VARIANT_ERROR_CALLOUT) == null) {
			styleProvider.setStyleFunction(TextCallout, TextArea.CHILD_VARIANT_ERROR_CALLOUT, function(callout:TextCallout):Void {
				theme.styleProvider.getStyleFunction(TextCallout, TextCallout.VARIANT_DANGER)(callout);
			});
		}
	}
}

/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.utils.DeviceUtil;
import feathers.controls.TextArea;
import feathers.controls.TextInputState;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

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
					backgroundSkin.cornerRadius = 6.0;
					backgroundSkin.width = 160.0;
					backgroundSkin.height = 120.0;
					backgroundSkin.fill = theme.getInsetFill();
					backgroundSkin.border = theme.getInsetBorder();
					backgroundSkin.setBorderForState(FOCUSED, theme.getThemeBorder());
					textArea.backgroundSkin = backgroundSkin;
				}

				if (textArea.textFormat == null) {
					textArea.textFormat = theme.getTextFormat();
				}
				if (textArea.getTextFormatForState(DISABLED) == null) {
					textArea.setTextFormatForState(DISABLED, theme.getDisabledTextFormat());
				}

				textArea.paddingTop = 1.0;
				textArea.paddingRight = 1.0;
				textArea.paddingBottom = 1.0;
				textArea.paddingLeft = 1.0;

				textArea.textPaddingTop = 4.0;
				textArea.textPaddingRight = 9.0;
				textArea.textPaddingBottom = 5.0;
				textArea.textPaddingLeft = 9.0;
			});
		}
	}
}

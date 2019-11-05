/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.TextCallout;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

/**
	Initialize "steel" styles for the `TextCallout` component.

	@since 1.0.0
**/
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelTextCalloutStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(TextCallout, null) == null) {
			styleProvider.setStyleFunction(TextCallout, null, function(label:TextCallout):Void {
				if (label.textFormat == null) {
					label.textFormat = theme.getTextFormat();
				}
				if (label.disabledTextFormat == null) {
					label.disabledTextFormat = theme.getDisabledTextFormat();
				}
			});
		}
	}
}

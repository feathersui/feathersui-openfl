/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.FormItem;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

/**
	Initialize "steel" styles for the `FormItem` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelFormItemStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(FormItem, null) == null) {
			styleProvider.setStyleFunction(FormItem, null, function(formItem:FormItem):Void {
				if (formItem.textFormat == null) {
					formItem.textFormat = theme.getTextFormat();
				}
				if (formItem.disabledTextFormat == null) {
					formItem.disabledTextFormat = theme.getDisabledTextFormat();
				}

				formItem.gap = 6.0;
			});
		}
	}
}

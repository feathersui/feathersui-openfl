/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.Label;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

/**
	Initialize "steel" styles for the `Label` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelLabelStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(Label, null) == null) {
			styleProvider.setStyleFunction(Label, null, function(label:Label):Void {
				if (label.textFormat == null) {
					label.textFormat = theme.getTextFormat();
				}
				if (label.disabledTextFormat == null) {
					label.disabledTextFormat = theme.getDisabledTextFormat();
				}
			});
		}
		if (styleProvider.getStyleFunction(Label, Label.VARIANT_HEADING) == null) {
			styleProvider.setStyleFunction(Label, Label.VARIANT_HEADING, function(label:Label):Void {
				if (label.textFormat == null) {
					label.textFormat = theme.getHeaderTextFormat();
				}
				if (label.disabledTextFormat == null) {
					label.disabledTextFormat = theme.getDisabledHeaderTextFormat();
				}
			});
		}
		if (styleProvider.getStyleFunction(Label, Label.VARIANT_DETAIL) == null) {
			styleProvider.setStyleFunction(Label, Label.VARIANT_DETAIL, function(label:Label):Void {
				if (label.textFormat == null) {
					label.textFormat = theme.getDetailTextFormat();
				}
				if (label.disabledTextFormat == null) {
					label.disabledTextFormat = theme.getDisabledDetailTextFormat();
				}
			});
		}
	}
}

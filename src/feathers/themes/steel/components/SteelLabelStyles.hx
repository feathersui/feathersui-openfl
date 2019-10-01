/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.Label;
import feathers.style.Theme;
import feathers.themes.steel.SteelTheme;

/**
	Initialize "steel" styles for the `Label` component.

	@since 1.0.0
**/
@:access(feathers.themes.steel.SteelTheme)
class SteelLabelStyles {
	public static function initialize():Void {
		var theme = Std.downcast(Theme.fallbackTheme, SteelTheme);
		if (theme != null && theme.styleProvider.getStyleFunction(Label, null) == null) {
			theme.styleProvider.setStyleFunction(Label, null, setStyles);
		}
		if (theme != null && theme.styleProvider.getStyleFunction(Label, Label.VARIANT_HEADING) == null) {
			theme.styleProvider.setStyleFunction(Label, Label.VARIANT_HEADING, setHeadingStyles);
		}
		if (theme != null && theme.styleProvider.getStyleFunction(Label, Label.VARIANT_DETAIL) == null) {
			theme.styleProvider.setStyleFunction(Label, Label.VARIANT_DETAIL, setDetailStyles);
		}
	}

	private static function setStyles(label:Label):Void {
		var theme = Std.downcast(Theme.fallbackTheme, SteelTheme);
		if (theme == null) {
			return;
		}

		if (label.textFormat == null) {
			label.textFormat = theme.getTextFormat();
		}
		if (label.disabledTextFormat == null) {
			label.disabledTextFormat = theme.getDisabledTextFormat();
		}
	}

	private static function setHeadingStyles(label:Label):Void {
		var theme = Std.downcast(Theme.fallbackTheme, SteelTheme);
		if (theme == null) {
			return;
		}

		if (label.textFormat == null) {
			label.textFormat = theme.getHeaderTextFormat();
		}
		if (label.disabledTextFormat == null) {
			label.disabledTextFormat = theme.getDisabledHeaderTextFormat();
		}
	}

	private static function setDetailStyles(label:Label):Void {
		var theme = Std.downcast(Theme.fallbackTheme, SteelTheme);
		if (theme == null) {
			return;
		}

		if (label.textFormat == null) {
			label.textFormat = theme.getDetailTextFormat();
		}
		if (label.disabledTextFormat == null) {
			label.disabledTextFormat = theme.getDisabledDetailTextFormat();
		}
	}
}

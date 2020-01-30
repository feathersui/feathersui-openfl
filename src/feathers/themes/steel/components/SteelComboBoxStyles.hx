/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.layout.RelativePosition;
import feathers.controls.ButtonState;
import openfl.display.Shape;
import feathers.layout.HorizontalAlign;
import feathers.controls.Button;
import feathers.controls.ComboBox;
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
		if (styleProvider.getStyleFunction(Button, ComboBox.CHILD_VARIANT_BUTTON) == null) {
			styleProvider.setStyleFunction(Button, ComboBox.CHILD_VARIANT_BUTTON, function(button:Button):Void {
				theme.styleProvider.getStyleFunction(Button, null)(button);

				var icon = new Shape();
				icon.graphics.beginFill(theme.textColor);
				icon.graphics.moveTo(0.0, 0.0);
				icon.graphics.lineTo(4.0, 4.0);
				icon.graphics.lineTo(8.0, 0.0);
				button.icon = icon;

				var downIcon = new Shape();
				downIcon.graphics.beginFill(theme.activeTextColor);
				downIcon.graphics.moveTo(0.0, 0.0);
				downIcon.graphics.lineTo(4.0, 4.0);
				downIcon.graphics.lineTo(8.0, 0.0);
				button.setIconForState(ButtonState.DOWN, downIcon);
			});
		}
	}
}

/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.layout.RelativePosition;
import feathers.controls.ButtonState;
import openfl.display.Shape;
import feathers.layout.HorizontalAlign;
import feathers.controls.Button;
import feathers.controls.PopUpList;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.SteelTheme;

/**
	Initialize "steel" styles for the `PopUpList` component.

	@since 1.0.0
**/
@:access(feathers.themes.steel.SteelTheme)
class SteelPopUpListStyles {
	public static function initialize():Void {
		var theme = Std.downcast(Theme.fallbackTheme, SteelTheme);
		if (theme != null && theme.styleProvider.getStyleFunction(Button, PopUpList.CHILD_VARIANT_BUTTON) == null) {
			theme.styleProvider.setStyleFunction(Button, PopUpList.CHILD_VARIANT_BUTTON, setButtonStyles);
		}
	}

	private static function setButtonStyles(button:Button):Void {
		var theme = Std.downcast(Theme.fallbackTheme, SteelTheme);
		if (theme == null) {
			return;
		}

		theme.styleProvider.getStyleFunction(Button, null)(button);

		button.horizontalAlign = HorizontalAlign.LEFT;
		button.gap = Math.POSITIVE_INFINITY;

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

		button.iconPosition = RelativePosition.RIGHT;
	}
}

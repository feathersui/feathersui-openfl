/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.BasicButton;
import feathers.controls.ButtonState;
import feathers.controls.HScrollThumb;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

/**
	Initialize "steel" styles for the `HScrollThumb` component.

	@since 1.0.0
**/
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelHScrollThumbStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(HScrollThumb, null) != null) {
			return;
		}

		styleProvider.setStyleFunction(HScrollThumb, null, function(slider:HScrollThumb):Void {
			if (slider.thumbSkin == null) {
				var thumbSkin = new RectangleSkin();
				thumbSkin.fill = theme.getButtonFill();
				thumbSkin.border = theme.getButtonBorder();
				thumbSkin.setFillForState(ButtonState.DOWN, theme.getButtonDownFill());
				thumbSkin.setFillForState(ButtonState.DISABLED, theme.getButtonDisabledFill());
				thumbSkin.width = 12.0;
				thumbSkin.height = 12.0;
				thumbSkin.minWidth = 12.0;
				thumbSkin.minHeight = 12.0;
				thumbSkin.cornerRadius = 12.0;

				var thumb:BasicButton = new BasicButton();
				thumb.keepDownStateOnRollOut = true;
				thumb.backgroundSkin = thumbSkin;
				slider.thumbSkin = thumb;
			}
		});
	}
}

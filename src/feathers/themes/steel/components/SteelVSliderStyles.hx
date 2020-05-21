/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.Button;
import feathers.controls.ButtonState;
import feathers.skins.CircleSkin;
import feathers.controls.BasicButton;
import feathers.controls.VSlider;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

/**
	Initialize "steel" styles for the `VSlider` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelVSliderStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(VSlider, null) == null) {
			styleProvider.setStyleFunction(VSlider, null, function(slider:VSlider):Void {
				if (slider.thumbSkin == null) {
					var thumb = new Button();
					thumb.styleProvider = null;
					thumb.keepDownStateOnRollOut = true;

					var backgroundSkin = new CircleSkin();
					backgroundSkin.fill = theme.getButtonFill();
					backgroundSkin.border = theme.getButtonBorder();
					backgroundSkin.setFillForState(ButtonState.DOWN, theme.getButtonDownFill());
					backgroundSkin.setFillForState(ButtonState.DISABLED, theme.getButtonDisabledFill());
					backgroundSkin.width = 24.0;
					backgroundSkin.height = 24.0;
					thumb.backgroundSkin = backgroundSkin;

					var focusRectSkin = new CircleSkin();
					focusRectSkin.fill = null;
					focusRectSkin.border = theme.getFocusBorder();
					thumb.focusRectSkin = focusRectSkin;

					slider.thumbSkin = thumb;
				}

				if (slider.trackSkin == null) {
					var trackSkin = new RectangleSkin();
					trackSkin.fill = theme.getActiveThemeFill();
					trackSkin.border = theme.getActiveFillBorder();
					trackSkin.cornerRadius = 6.0;
					trackSkin.width = 8.0;
					trackSkin.height = 100.0;
					slider.trackSkin = trackSkin;

					// if the track skin is already styled, don't style the secondary
					// track skin with its default either
					if (slider.secondaryTrackSkin == null) {
						var secondaryTrackSkin = new RectangleSkin();
						secondaryTrackSkin.fill = theme.getInsetFill();
						secondaryTrackSkin.border = theme.getInsetBorder();
						secondaryTrackSkin.cornerRadius = 6.0;
						secondaryTrackSkin.width = 8.0;
						secondaryTrackSkin.height = 100.0;
						slider.secondaryTrackSkin = secondaryTrackSkin;
					}
				}
			});
		}
	}
}

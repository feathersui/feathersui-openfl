/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.BasicButton;
import feathers.skins.CircleSkin;
import feathers.controls.ButtonState;
import feathers.controls.HSlider;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

/**
	Initialize "steel" styles for the `HSlider` component.

	@since 1.0.0
**/
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelHSliderStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}
		if (theme.styleProvider.getStyleFunction(HSlider, null) == null) {
			theme.styleProvider.setStyleFunction(HSlider, null, setStyles);
		}
	}

	private static function setStyles(slider:HSlider):Void {
		var theme = Std.downcast(Theme.getTheme(slider), BaseSteelTheme);
		if (theme == null) {
			return;
		}

		if (slider.thumbSkin == null) {
			var thumbSkin = new CircleSkin();
			thumbSkin.fill = theme.getButtonFill();
			thumbSkin.border = theme.getButtonBorder();
			thumbSkin.setFillForState(ButtonState.DOWN, theme.getButtonDownFill());
			thumbSkin.setFillForState(ButtonState.DISABLED, theme.getButtonDisabledFill());
			thumbSkin.width = 24.0;
			thumbSkin.height = 24.0;
			var thumb:BasicButton = new BasicButton();
			thumb.keepDownStateOnRollOut = true;
			thumb.backgroundSkin = thumbSkin;
			slider.thumbSkin = thumb;
		}

		if (slider.trackSkin == null) {
			var trackSkin = new RectangleSkin();
			trackSkin.fill = theme.getActiveThemeFill();
			trackSkin.border = theme.getActiveFillBorder();
			trackSkin.cornerRadius = 6.0;
			trackSkin.width = 100.0;
			trackSkin.height = 8.0;
			slider.trackSkin = trackSkin;

			// if the track skin is already styled, don't style the secondary
			// track skin with its default either
			if (slider.secondaryTrackSkin == null) {
				var secondaryTrackSkin = new RectangleSkin();
				secondaryTrackSkin.fill = theme.getInsetFill();
				secondaryTrackSkin.border = theme.getInsetBorder();
				secondaryTrackSkin.cornerRadius = 6.0;
				secondaryTrackSkin.width = 100.0;
				secondaryTrackSkin.height = 8.0;
				slider.secondaryTrackSkin = secondaryTrackSkin;
			}
		}
	}
}

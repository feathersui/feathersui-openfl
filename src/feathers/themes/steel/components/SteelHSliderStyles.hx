/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.utils.DeviceUtil;
import feathers.controls.Button;
import feathers.controls.ButtonState;
import feathers.controls.HSlider;
import feathers.skins.CircleSkin;
import feathers.skins.TabSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

/**
	Initialize "steel" styles for the `HSlider` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelHSliderStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(HSlider, null) == null) {
			styleProvider.setStyleFunction(HSlider, null, function(slider:HSlider):Void {
				var isDesktop = DeviceUtil.isDesktop();
				if (slider.thumbSkin == null) {
					var thumb = new Button();
					thumb.styleProvider = null;
					thumb.keepDownStateOnRollOut = true;

					var backgroundSkin = new CircleSkin();
					backgroundSkin.fill = theme.getButtonFill();
					backgroundSkin.disabledFill = theme.getButtonDisabledFill();
					backgroundSkin.setFillForState(ButtonState.DOWN, theme.getButtonDownFill());
					backgroundSkin.border = theme.getButtonBorder();
					backgroundSkin.disabledBorder = theme.getButtonDisabledBorder();
					if (isDesktop) {
						backgroundSkin.width = 20.0;
						backgroundSkin.height = 20.0;
					} else {
						backgroundSkin.width = 24.0;
						backgroundSkin.height = 24.0;
					}
					thumb.backgroundSkin = backgroundSkin;

					var focusRectSkin = new CircleSkin();
					focusRectSkin.fill = None;
					focusRectSkin.border = theme.getFocusBorder();
					thumb.focusRectSkin = focusRectSkin;

					slider.thumbSkin = thumb;
				}

				if (slider.trackSkin == null) {
					var trackSkin = new TabSkin();
					trackSkin.fill = theme.getActiveThemeFill();
					trackSkin.disabledFill = theme.getControlDisabledFill();
					trackSkin.border = theme.getActiveFillBorder();
					trackSkin.disabledBorder = theme.getDisabledInsetBorder();
					trackSkin.cornerRadius = 8.0;
					trackSkin.cornerRadiusPosition = LEFT;
					trackSkin.width = 100.0;
					trackSkin.height = 8.0;
					slider.trackSkin = trackSkin;

					// if the track skin is already styled, don't style the secondary
					// track skin with its default either
					if (slider.secondaryTrackSkin == null) {
						var secondaryTrackSkin = new TabSkin();
						secondaryTrackSkin.fill = theme.getInsetFill();
						secondaryTrackSkin.disabledFill = theme.getDisabledInsetFill();
						secondaryTrackSkin.border = theme.getInsetBorder();
						secondaryTrackSkin.disabledBorder = theme.getDisabledInsetBorder();
						secondaryTrackSkin.cornerRadius = 8.0;
						secondaryTrackSkin.cornerRadiusPosition = RIGHT;
						secondaryTrackSkin.width = 100.0;
						secondaryTrackSkin.height = 8.0;
						slider.secondaryTrackSkin = secondaryTrackSkin;
					}
				}
			});
		}
	}
}

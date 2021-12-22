/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.CalendarGrid;
import feathers.controls.Label;
import feathers.controls.ToggleButton;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;
import feathers.utils.DeviceUtil;

/**
	Initialize "steel" styles for the `CalendarGrid` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelCalendarGridStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(ToggleButton, CalendarGrid.CHILD_VARIANT_DATE_TOGGLE_BUTTON) == null) {
			styleProvider.setStyleFunction(ToggleButton, CalendarGrid.CHILD_VARIANT_DATE_TOGGLE_BUTTON, function(button:ToggleButton):Void {
				var isDesktop = DeviceUtil.isDesktop();
				if (button.backgroundSkin == null) {
					var backgroundSkin = new RectangleSkin();
					backgroundSkin.selectedFill = theme.getActiveThemeFill();
					backgroundSkin.selectedBorder = theme.getActiveFillBorder();
					if (isDesktop) {
						backgroundSkin.width = 20.0;
						backgroundSkin.height = 20.0;
					} else {
						backgroundSkin.width = 32.0;
						backgroundSkin.height = 32.0;
					}
					backgroundSkin.cornerRadius = 4.0;
					button.backgroundSkin = backgroundSkin;
				}

				button.textFormat = theme.getTextFormat();
				button.disabledTextFormat = theme.getDisabledTextFormat();

				button.horizontalAlign = CENTER;
				button.verticalAlign = MIDDLE;

				button.paddingTop = 2.0;
				button.paddingRight = 2.0;
				button.paddingBottom = 2.0;
				button.paddingLeft = 2.0;
			});
		}
		if (styleProvider.getStyleFunction(ToggleButton, CalendarGrid.CHILD_VARIANT_MUTED_DATE_TOGGLE_BUTTON) == null) {
			styleProvider.setStyleFunction(ToggleButton, CalendarGrid.CHILD_VARIANT_MUTED_DATE_TOGGLE_BUTTON, function(button:ToggleButton):Void {
				var isDesktop = DeviceUtil.isDesktop();
				if (button.backgroundSkin == null) {
					var backgroundSkin = new RectangleSkin();
					backgroundSkin.selectedFill = theme.getActiveThemeFill();
					backgroundSkin.selectedBorder = theme.getActiveFillBorder();
					if (isDesktop) {
						backgroundSkin.width = 20.0;
						backgroundSkin.height = 20.0;
					} else {
						backgroundSkin.width = 32.0;
						backgroundSkin.height = 32.0;
					}
					button.backgroundSkin = backgroundSkin;
				}

				button.textFormat = theme.getSecondaryTextFormat();
				button.disabledTextFormat = theme.getDisabledTextFormat();

				button.horizontalAlign = CENTER;
				button.verticalAlign = MIDDLE;

				button.paddingTop = 2.0;
				button.paddingRight = 2.0;
				button.paddingBottom = 2.0;
				button.paddingLeft = 2.0;
			});
		}
		if (styleProvider.getStyleFunction(Label, CalendarGrid.CHILD_VARIANT_WEEKDAY_LABEL) == null) {
			styleProvider.setStyleFunction(Label, CalendarGrid.CHILD_VARIANT_WEEKDAY_LABEL, function(label:Label):Void {
				if (label.textFormat == null) {
					label.textFormat = theme.getSecondaryTextFormat(CENTER);
				}
				if (label.disabledTextFormat == null) {
					label.disabledTextFormat = theme.getDisabledTextFormat(CENTER);
				}
				label.verticalAlign = MIDDLE;
			});
		}
	}
}

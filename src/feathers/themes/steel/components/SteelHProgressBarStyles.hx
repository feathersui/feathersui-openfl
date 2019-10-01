/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.HProgressBar;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.SteelTheme;

/**
	Initialize "steel" styles for the `HProgressBar` component.

	@since 1.0.0
**/
@:access(feathers.themes.steel.SteelTheme)
class SteelHProgressBarStyles {
	public static function initialize():Void {
		var theme = Std.downcast(Theme.fallbackTheme, SteelTheme);
		if (theme != null && theme.styleProvider.getStyleFunction(HProgressBar, null) == null) {
			theme.styleProvider.setStyleFunction(HProgressBar, null, setStyles);
		}
	}

	private static function setStyles(progress:HProgressBar):Void {
		var defaultTheme = Std.downcast(Theme.fallbackTheme, SteelTheme);
		if (defaultTheme == null) {
			return;
		}

		if (progress.fillSkin == null) {
			var fillSkin = new RectangleSkin();
			fillSkin.fill = defaultTheme.getActiveThemeFill();
			// fillSkin.disabledFill = defaultTheme.getButtonDisabledFill();
			fillSkin.border = defaultTheme.getActiveFillBorder();
			fillSkin.cornerRadius = 6.0;
			fillSkin.width = 8.0;
			fillSkin.height = 8.0;
			progress.fillSkin = fillSkin;
		}

		if (progress.backgroundSkin == null) {
			var backgroundSkin = new RectangleSkin();
			backgroundSkin.fill = defaultTheme.getInsetFill();
			backgroundSkin.border = defaultTheme.getInsetBorder();
			backgroundSkin.cornerRadius = 6.0;
			backgroundSkin.width = 200.0;
			backgroundSkin.height = 8.0;
			progress.backgroundSkin = backgroundSkin;
		}
	}
}

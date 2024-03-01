/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.skins.activity.DotsActivitySkin;
import feathers.controls.ActivityIndicator;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

/**
	Initialize "steel" styles for the `ActivityIndicator` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelActivityIndicatorStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(ActivityIndicator, null) == null) {
			styleProvider.setStyleFunction(ActivityIndicator, null, function(indicator:ActivityIndicator):Void {
				if (indicator.activitySkin == null) {
					var activitySkin = new DotsActivitySkin();
					activitySkin.numDots = 8;
					activitySkin.dotRadius = 3.0;
					activitySkin.endDotRadius = null;
					activitySkin.dotColor = theme.textColor;
					activitySkin.endDotColor = null;
					activitySkin.dotAlpha = 1.0;
					activitySkin.endDotAlpha = 0.0;
					var size = 1.1 * activitySkin.dotRadius * activitySkin.numDots;
					activitySkin.width = size;
					activitySkin.height = size;
					indicator.activitySkin = activitySkin;
				}
			});
		}
	}
}

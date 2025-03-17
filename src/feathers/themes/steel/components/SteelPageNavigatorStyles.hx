/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.navigators.PageNavigator;
import feathers.motion.transitions.SlideTransitionBuilder;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

/**
	Initialize "steel" styles for the `PageNavigator` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelPageNavigatorStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;

		if (styleProvider.getStyleFunction(PageNavigator, null) == null) {
			styleProvider.setStyleFunction(PageNavigator, null, function(navigator:PageNavigator):Void {
				navigator.pageIndicatorPosition = BOTTOM;

				navigator.previousTransition = new SlideTransitionBuilder().setRight().build();
				navigator.nextTransition = new SlideTransitionBuilder().setLeft().build();
			});
		}
	}
}

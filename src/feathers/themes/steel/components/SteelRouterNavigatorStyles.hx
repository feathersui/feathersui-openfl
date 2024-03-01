/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.navigators.RouterNavigator;
import feathers.motion.transitions.SlideTransitionBuilder;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

/**
	Initialize "steel" styles for the `RouterNavigator` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelRouterNavigatorStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;

		if (styleProvider.getStyleFunction(RouterNavigator, null) == null) {
			styleProvider.setStyleFunction(RouterNavigator, null, function(navigator:RouterNavigator):Void {
				navigator.backTransition = new SlideTransitionBuilder().setRight().build();
				navigator.forwardTransition = new SlideTransitionBuilder().setLeft().build();
			});
		}
	}
}

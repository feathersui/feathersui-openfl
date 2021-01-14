/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.motion.transitions.SlideTransitions;
import feathers.controls.navigators.RouterNavigator;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;
import feathers.utils.DeviceUtil;

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
				navigator.backTransition = SlideTransitions.right();
				navigator.forwardTransition = SlideTransitions.left();
			});
		}
	}
}

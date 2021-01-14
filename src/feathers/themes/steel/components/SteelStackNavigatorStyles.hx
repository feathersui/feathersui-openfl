/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.motion.transitions.SlideTransitions;
import feathers.controls.navigators.StackNavigator;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;
import feathers.utils.DeviceUtil;

/**
	Initialize "steel" styles for the `StackNavigator` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelStackNavigatorStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;

		if (styleProvider.getStyleFunction(StackNavigator, null) == null) {
			styleProvider.setStyleFunction(StackNavigator, null, function(navigator:StackNavigator):Void {
				navigator.popTransition = SlideTransitions.right();
				navigator.pushTransition = SlideTransitions.left();
			});
		}
	}
}

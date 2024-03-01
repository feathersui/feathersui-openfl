/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.HDividedBox;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

/**
	Initialize "steel" styles for the `HDividedBox` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelHDividedBoxStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(HDividedBox, null) == null) {
			styleProvider.setStyleFunction(HDividedBox, null, function(dividedBox:HDividedBox):Void {
				if (dividedBox.resizeDraggingSkin == null) {
					var resizeDraggingSkin = new RectangleSkin();
					resizeDraggingSkin.fill = theme.getThemeFill();
					resizeDraggingSkin.border = None;
					resizeDraggingSkin.width = 2.0;
					resizeDraggingSkin.height = 2.0;
					dividedBox.resizeDraggingSkin = resizeDraggingSkin;
				}
			});
		}
	}
}

/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.VDividedBox;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

/**
	Initialize "steel" styles for the `VDividedBox` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelVDividedBoxStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(VDividedBox, null) == null) {
			styleProvider.setStyleFunction(VDividedBox, null, function(dividedBox:VDividedBox):Void {
				if (dividedBox.resizeDraggingSkin == null) {
					var resizeDraggingSkin = new RectangleSkin();
					resizeDraggingSkin.fill = theme.getThemeFill();
					resizeDraggingSkin.border = null;
					resizeDraggingSkin.width = 2.0;
					resizeDraggingSkin.height = 2.0;
					dividedBox.resizeDraggingSkin = resizeDraggingSkin;
				}
			});
		}
	}
}

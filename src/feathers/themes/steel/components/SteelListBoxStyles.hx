/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.layout.VerticalListFixedRowLayout;
import feathers.controls.ListBox;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.SteelTheme;

/**
	Initialize "steel" styles for the `ListBox` component.

	@since 1.0.0
**/
@:access(feathers.themes.steel.SteelTheme)
class SteelListBoxStyles {
	public static function initialize():Void {
		var theme = Std.downcast(Theme.fallbackTheme, SteelTheme);
		if (theme != null && theme.styleProvider.getStyleFunction(ListBox, null) == null) {
			theme.styleProvider.setStyleFunction(ListBox, null, setStyles);
		}
	}

	private static function setStyles(listBox:ListBox):Void {
		var defaultTheme = Std.downcast(Theme.fallbackTheme, SteelTheme);
		if (defaultTheme == null) {
			return;
		}

		if (listBox.layout == null) {
			listBox.layout = new VerticalListFixedRowLayout();
		}

		if (listBox.backgroundSkin == null) {
			var backgroundSkin = new RectangleSkin();
			backgroundSkin.fill = defaultTheme.getContainerFill();
			// backgroundSkin.border = defaultTheme.getContainerBorder();
			backgroundSkin.width = 160.0;
			backgroundSkin.height = 160.0;
			listBox.backgroundSkin = backgroundSkin;
		}
	}
}

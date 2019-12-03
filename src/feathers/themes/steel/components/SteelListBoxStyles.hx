/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.utils.DeviceUtil;
import feathers.layout.VerticalListFixedRowLayout;
import feathers.controls.ListBox;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

/**
	Initialize "steel" styles for the `ListBox` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelListBoxStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(ListBox, null) != null) {
			return;
		}

		styleProvider.setStyleFunction(ListBox, null, function(listBox:ListBox):Void {
			var isDesktop = DeviceUtil.isDesktop();

			listBox.autoHideScrollBars = !isDesktop;
			listBox.fixedScrollBars = isDesktop;

			if (listBox.layout == null) {
				listBox.layout = new VerticalListFixedRowLayout();
			}

			if (listBox.backgroundSkin == null) {
				var backgroundSkin = new RectangleSkin();
				backgroundSkin.fill = theme.getContainerFill();
				// backgroundSkin.border = theme.getContainerBorder();
				backgroundSkin.width = 160.0;
				backgroundSkin.height = 160.0;
				listBox.backgroundSkin = backgroundSkin;
			}
		});
	}
}

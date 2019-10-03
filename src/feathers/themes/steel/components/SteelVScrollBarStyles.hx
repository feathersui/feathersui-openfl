/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.BasicButton;
import feathers.controls.VScrollBar;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

/**
	Initialize "steel" styles for the `VScrollBar` component.

	@since 1.0.0
**/
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelVScrollBarStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(VScrollBar, null) != null) {
			return;
		}

		styleProvider.setStyleFunction(VScrollBar, null, function(scrollBar:VScrollBar):Void {
			if (scrollBar.thumbSkin == null) {
				var thumbSkin = new RectangleSkin();
				thumbSkin.fill = theme.getOverlayFill();
				thumbSkin.width = 4.0;
				thumbSkin.height = 4.0;
				thumbSkin.minWidth = 4.0;
				thumbSkin.minHeight = 4.0;
				thumbSkin.cornerRadius = 4.0;

				var thumb:BasicButton = new BasicButton();
				thumb.keepDownStateOnRollOut = true;
				thumb.backgroundSkin = thumbSkin;
				scrollBar.thumbSkin = thumb;
			}

			scrollBar.paddingTop = 2.0;
			scrollBar.paddingRight = 2.0;
			scrollBar.paddingBottom = 2.0;
			scrollBar.paddingLeft = 2.0;
		});
	}
}

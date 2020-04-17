/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.BasicButton;
import feathers.controls.VScrollBar;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;
import feathers.utils.DeviceUtil;

/**
	Initialize "steel" styles for the `VScrollBar` component.

	@since 1.0.0
**/
@:dox(hide)
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
		if (styleProvider.getStyleFunction(VScrollBar, null) == null) {
			styleProvider.setStyleFunction(VScrollBar, null, function(scrollBar:VScrollBar):Void {
				var isDesktop = DeviceUtil.isDesktop();

				if (scrollBar.thumbSkin == null) {
					var thumbSkin = new RectangleSkin();
					thumbSkin.fill = theme.getOverlayFill();
					var size = isDesktop ? 6.0 : 4.0;
					thumbSkin.width = size;
					thumbSkin.height = size;
					thumbSkin.minWidth = size;
					thumbSkin.minHeight = size;
					thumbSkin.cornerRadius = size;

					var thumb = new BasicButton();
					thumb.keepDownStateOnRollOut = true;
					thumb.backgroundSkin = thumbSkin;
					scrollBar.thumbSkin = thumb;
				}

				if (isDesktop && scrollBar.trackSkin == null) {
					var trackSkin = new RectangleSkin();
					trackSkin.fill = theme.getControlFill();
					trackSkin.width = 12.0;
					trackSkin.height = 12.0;
					trackSkin.minWidth = 12.0;
					trackSkin.minHeight = 12.0;
					scrollBar.trackSkin = trackSkin;
				}

				scrollBar.paddingTop = 2.0;
				scrollBar.paddingRight = 2.0;
				scrollBar.paddingBottom = 2.0;
				scrollBar.paddingLeft = 2.0;
			});
		}
	}
}

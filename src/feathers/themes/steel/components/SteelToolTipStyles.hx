/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.core.DefaultToolTipManager;
import feathers.skins.RectangleSkin;
import feathers.controls.Label;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

/**
	Initialize "steel" styles for the default tool tip label.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelToolTipStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(Label, DefaultToolTipManager.CHILD_VARIANT_TOOL_TIP) == null) {
			styleProvider.setStyleFunction(Label, DefaultToolTipManager.CHILD_VARIANT_TOOL_TIP, function(label:Label):Void {
				if (label.backgroundSkin == null) {
					var backgroundSkin = new RectangleSkin();
					backgroundSkin.border = theme.getBorder();
					backgroundSkin.fill = theme.getContainerFill();
					backgroundSkin.cornerRadius = 2.0;
					label.backgroundSkin = backgroundSkin;
				}
				if (label.textFormat == null) {
					label.textFormat = theme.getTextFormat();
				}
				if (label.disabledTextFormat == null) {
					label.disabledTextFormat = theme.getDisabledDetailTextFormat();
				}

				label.wordWrap = true;

				label.paddingTop = 2.0;
				label.paddingRight = 2.0;
				label.paddingBottom = 2.0;
				label.paddingLeft = 2.0;
			});
		}
	}
}

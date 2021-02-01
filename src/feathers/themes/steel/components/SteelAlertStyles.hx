/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.Alert;
import feathers.controls.ButtonBar;
import feathers.layout.HorizontalDistributedLayout;
import feathers.layout.HorizontalLayout;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;
import feathers.utils.DeviceUtil;

/**
	Initialize "steel" styles for the `Alert` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelAlertStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(Alert, null) == null) {
			styleProvider.setStyleFunction(Alert, null, function(alert:Alert):Void {
				var isDesktop = DeviceUtil.isDesktop();

				alert.autoHideScrollBars = !isDesktop;
				alert.fixedScrollBars = isDesktop;

				if (alert.backgroundSkin == null) {
					var backgroundSkin = new RectangleSkin();
					backgroundSkin.fill = theme.getContainerFill();
					backgroundSkin.maxWidth = 276.0;
					alert.backgroundSkin = backgroundSkin;
				}
				if (alert.layout == null) {
					var layout = new HorizontalLayout();
					layout.paddingTop = 10.0;
					layout.paddingRight = 10.0;
					layout.paddingBottom = 10.0;
					layout.paddingLeft = 10.0;
					layout.gap = 6.0;
					alert.layout = layout;
				}
			});
		}

		if (styleProvider.getStyleFunction(ButtonBar, Alert.CHILD_VARIANT_BUTTON_BAR) == null) {
			styleProvider.setStyleFunction(ButtonBar, Alert.CHILD_VARIANT_BUTTON_BAR, function(buttonBar:ButtonBar):Void {
				if (buttonBar.layout == null) {
					var layout = new HorizontalDistributedLayout();
					layout.paddingTop = 10.0;
					layout.paddingRight = 10.0;
					layout.paddingBottom = 10.0;
					layout.paddingLeft = 10.0;
					layout.gap = 6.0;
					buttonBar.layout = layout;
				}
			});
		}
	}
}

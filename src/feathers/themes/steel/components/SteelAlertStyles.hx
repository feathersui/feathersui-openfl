/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.Alert;
import feathers.controls.ButtonBar;
import feathers.controls.Label;
import feathers.layout.HorizontalDistributedLayout;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
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
					backgroundSkin.border = None;
					backgroundSkin.fill = theme.getContainerFill();
					backgroundSkin.maxWidth = 276.0;
					alert.backgroundSkin = backgroundSkin;
				}
				if (alert.layout == null) {
					var layout = new HorizontalLayout();
					layout.paddingTop = theme.largePadding;
					layout.paddingRight = theme.largePadding;
					layout.paddingBottom = theme.largePadding;
					layout.paddingLeft = theme.largePadding;
					layout.gap = theme.mediumPadding;
					layout.percentWidthResetEnabled = true;
					alert.layout = layout;
				}
			});
		}

		if (styleProvider.getStyleFunction(ButtonBar, Alert.CHILD_VARIANT_BUTTON_BAR) == null) {
			styleProvider.setStyleFunction(ButtonBar, Alert.CHILD_VARIANT_BUTTON_BAR, function(buttonBar:ButtonBar):Void {
				if (buttonBar.layout == null) {
					var layout = new HorizontalDistributedLayout();
					layout.paddingTop = theme.largePadding;
					layout.paddingRight = theme.largePadding;
					layout.paddingBottom = theme.largePadding;
					layout.paddingLeft = theme.largePadding;
					layout.gap = theme.mediumPadding;
					buttonBar.layout = layout;
				}
			});
		}

		if (styleProvider.getStyleFunction(Label, Alert.CHILD_VARIANT_MESSAGE_LABEL) == null) {
			styleProvider.setStyleFunction(Label, Alert.CHILD_VARIANT_MESSAGE_LABEL, function(label:Label):Void {
				if (label.textFormat == null) {
					label.textFormat = theme.getTextFormat();
				}
				if (label.disabledTextFormat == null) {
					label.disabledTextFormat = theme.getDisabledTextFormat();
				}
				if (label.layoutData == null) {
					label.layoutData = HorizontalLayoutData.fillHorizontal();
				}
				label.wordWrap = true;
			});
		}
	}
}

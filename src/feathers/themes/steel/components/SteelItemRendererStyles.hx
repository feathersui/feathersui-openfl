/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.layout.HorizontalAlign;
import feathers.controls.ToggleButtonState;
import feathers.skins.UnderlineSkin;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

/**
	Initialize "steel" styles for the `ItemRenderer` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelItemRendererStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(ItemRenderer, null) == null) {
			styleProvider.setStyleFunction(ItemRenderer, null, function(itemRenderer:ItemRenderer):Void {
				if (itemRenderer.backgroundSkin == null) {
					var skin = new UnderlineSkin();
					skin.fill = theme.getContainerFill();
					skin.border = theme.getDividerBorder();
					skin.selectedFill = theme.getActiveThemeFill();
					skin.setFillForState(ToggleButtonState.DOWN(false), theme.getActiveThemeFill());
					skin.width = 44.0;
					skin.height = 44.0;
					skin.minWidth = 44.0;
					skin.minHeight = 44.0;
					itemRenderer.backgroundSkin = skin;
				}

				if (itemRenderer.textFormat == null) {
					itemRenderer.textFormat = theme.getTextFormat();
				}
				if (itemRenderer.disabledTextFormat == null) {
					itemRenderer.disabledTextFormat = theme.getDisabledTextFormat();
				}
				if (itemRenderer.selectedTextFormat == null) {
					itemRenderer.selectedTextFormat = theme.getActiveTextFormat();
				}
				if (itemRenderer.getTextFormatForState(ToggleButtonState.DOWN(false)) == null) {
					itemRenderer.setTextFormatForState(ToggleButtonState.DOWN(false), theme.getActiveTextFormat());
				}

				itemRenderer.paddingTop = 4.0;
				itemRenderer.paddingRight = 10.0;
				itemRenderer.paddingBottom = 4.0;
				itemRenderer.paddingLeft = 10.0;
				itemRenderer.gap = 6.0;

				itemRenderer.horizontalAlign = LEFT;
			});
		}
	}
}

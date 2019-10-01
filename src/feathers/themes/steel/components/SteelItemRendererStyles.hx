/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.layout.HorizontalAlign;
import feathers.controls.ButtonState;
import feathers.skins.UnderlineSkin;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.style.Theme;
import feathers.themes.steel.SteelTheme;

/**
	Initialize "steel" styles for the `ItemRenderer` component.

	@since 1.0.0
**/
@:access(feathers.themes.steel.SteelTheme)
class SteelItemRendererStyles {
	public static function initialize():Void {
		var theme = Std.downcast(Theme.fallbackTheme, SteelTheme);
		if (theme != null && theme.styleProvider.getStyleFunction(ItemRenderer, null) == null) {
			theme.styleProvider.setStyleFunction(ItemRenderer, null, setStyles);
		}
	}

	private static function setStyles(itemRenderer:ItemRenderer):Void {
		var defaultTheme = Std.downcast(Theme.fallbackTheme, SteelTheme);
		if (defaultTheme == null) {
			return;
		}

		if (itemRenderer.backgroundSkin == null) {
			var skin = new UnderlineSkin();
			skin.fill = defaultTheme.getContainerFill();
			skin.border = defaultTheme.getDividerBorder();
			skin.setFillForState(ButtonState.DOWN, defaultTheme.getActiveThemeFill());
			skin.width = 44.0;
			skin.height = 44.0;
			skin.minWidth = 44.0;
			skin.minHeight = 44.0;
			itemRenderer.backgroundSkin = skin;
		}

		if (itemRenderer.textFormat == null) {
			itemRenderer.textFormat = defaultTheme.getTextFormat();
		}
		if (itemRenderer.disabledTextFormat == null) {
			itemRenderer.disabledTextFormat = defaultTheme.getDisabledTextFormat();
		}
		if (itemRenderer.getTextFormatForState(ButtonState.DOWN) == null) {
			itemRenderer.setTextFormatForState(ButtonState.DOWN, defaultTheme.getActiveTextFormat());
		}

		itemRenderer.paddingTop = 4.0;
		itemRenderer.paddingRight = 10.0;
		itemRenderer.paddingBottom = 4.0;
		itemRenderer.paddingLeft = 10.0;

		itemRenderer.horizontalAlign = HorizontalAlign.LEFT;
	}
}

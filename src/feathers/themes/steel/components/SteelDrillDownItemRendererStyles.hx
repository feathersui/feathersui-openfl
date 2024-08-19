/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.skins.MultiSkin;
import feathers.controls.ToggleButtonState;
import feathers.controls.dataRenderers.DrillDownItemRenderer;
import feathers.skins.UnderlineSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;
import feathers.utils.DeviceUtil;
import openfl.display.Shape;

/**
	Initialize "steel" styles for the `DrillDownItemRenderer` component.

	@since 1.4.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelDrillDownItemRendererStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(DrillDownItemRenderer, null) == null) {
			styleProvider.setStyleFunction(DrillDownItemRenderer, null, function(itemRenderer:DrillDownItemRenderer):Void {
				var isDesktop = DeviceUtil.isDesktop();

				if (itemRenderer.backgroundSkin == null) {
					var skin = new UnderlineSkin();
					skin.fill = theme.getContainerFill();
					skin.border = theme.getDividerBorder();
					skin.selectedFill = theme.getActiveThemeFill();
					skin.setFillForState(ToggleButtonState.DOWN(false), theme.getActiveThemeFill());
					if (isDesktop) {
						skin.width = 26.0;
						skin.height = 26.0;
						skin.minWidth = 26.0;
						skin.minHeight = 26.0;
					} else {
						skin.width = 44.0;
						skin.height = 44.0;
						skin.minWidth = 44.0;
						skin.minHeight = 44.0;
					}
					itemRenderer.backgroundSkin = skin;
				}

				if (itemRenderer.drillDownIcon == null) {
					var drillDownIcon = new MultiSkin();

					var defaultIcon = new Shape();
					drawDrillDownIcon(defaultIcon, theme.textColor, isDesktop);
					drillDownIcon.defaultView = defaultIcon;

					var disabledIcon = new Shape();
					drawDrillDownIcon(disabledIcon, theme.disabledTextColor, isDesktop);
					drillDownIcon.disabledView = disabledIcon;

					itemRenderer.drillDownIcon = drillDownIcon;
				}

				if (itemRenderer.textFormat == null) {
					itemRenderer.textFormat = theme.getTextFormat();
				}
				if (itemRenderer.disabledTextFormat == null) {
					itemRenderer.disabledTextFormat = theme.getDisabledTextFormat();
				}
				if (itemRenderer.secondaryTextFormat == null) {
					itemRenderer.secondaryTextFormat = theme.getSecondaryDetailTextFormat();
				}
				if (itemRenderer.disabledSecondaryTextFormat == null) {
					itemRenderer.disabledSecondaryTextFormat = theme.getDisabledDetailTextFormat();
				}

				itemRenderer.paddingTop = theme.smallPadding;
				itemRenderer.paddingRight = theme.largePadding;
				itemRenderer.paddingBottom = theme.smallPadding;
				itemRenderer.paddingLeft = theme.largePadding;
				itemRenderer.gap = theme.smallPadding;

				itemRenderer.horizontalAlign = LEFT;
			});
		}
	}

	private static function drawDrillDownIcon(icon:Shape, color:UInt, isDesktop:Bool):Void {
		icon.graphics.beginFill(0xff00ff, 0.0);
		if (isDesktop) {
			icon.graphics.drawRect(0.0, 0.0, 3.0, 6.0);
		} else {
			icon.graphics.drawRect(0.0, 0.0, 5.0, 8.0);
		}
		icon.graphics.endFill();
		icon.graphics.lineStyle(1.0, color, 1, false, NORMAL, SQUARE);
		if (isDesktop) {
			icon.graphics.moveTo(0.5, 0.5);
			icon.graphics.lineTo(2.5, 3.0);
			icon.graphics.lineTo(0.5, 5.5);
		} else {
			icon.graphics.moveTo(0.5, 0.5);
			icon.graphics.lineTo(4.5, 4.0);
			icon.graphics.lineTo(0.5, 7.5);
		}
		icon.graphics.endFill();
	}
}

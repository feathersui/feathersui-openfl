/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.ToggleButton;
import feathers.controls.ToggleButtonState;
import feathers.controls.dataRenderers.HierarchicalItemRenderer;
import feathers.skins.MultiSkin;
import feathers.skins.UnderlineSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;
import feathers.utils.DeviceUtil;
import openfl.display.Shape;

/**
	Initialize "steel" styles for the `HierarchicalItemRenderer` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelHierarchicalItemRendererStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(HierarchicalItemRenderer, null) == null) {
			styleProvider.setStyleFunction(HierarchicalItemRenderer, null, function(itemRenderer:HierarchicalItemRenderer):Void {
				var isDesktop = DeviceUtil.isDesktop();

				if (itemRenderer.backgroundSkin == null) {
					var skin = new UnderlineSkin();
					skin.fill = theme.getContainerFill();
					skin.border = theme.getDividerBorder();
					skin.selectedFill = theme.getActiveThemeFill();
					skin.setFillForState(ToggleButtonState.DOWN(false), theme.getActiveThemeFill());
					if (isDesktop) {
						skin.width = 32.0;
						skin.height = 32.0;
						skin.minWidth = 32.0;
						skin.minHeight = 32.0;
					} else {
						skin.width = 44.0;
						skin.height = 44.0;
						skin.minWidth = 44.0;
						skin.minHeight = 44.0;
					}
					itemRenderer.backgroundSkin = skin;
				}

				if (itemRenderer.textFormat == null) {
					itemRenderer.textFormat = theme.getTextFormat();
				}
				if (itemRenderer.disabledTextFormat == null) {
					itemRenderer.disabledTextFormat = theme.getDisabledTextFormat();
				}
				if (itemRenderer.secondaryTextFormat == null) {
					itemRenderer.secondaryTextFormat = theme.getDetailTextFormat();
				}
				if (itemRenderer.disabledSecondaryTextFormat == null) {
					itemRenderer.disabledSecondaryTextFormat = theme.getDisabledDetailTextFormat();
				}

				itemRenderer.paddingTop = theme.smallPadding;
				itemRenderer.paddingRight = theme.largePadding;
				itemRenderer.paddingBottom = theme.smallPadding;
				itemRenderer.paddingLeft = theme.largePadding;
				itemRenderer.gap = theme.smallPadding;

				itemRenderer.indentation = 20.0;

				itemRenderer.horizontalAlign = LEFT;
			});
		}
		if (styleProvider.getStyleFunction(ToggleButton, HierarchicalItemRenderer.CHILD_VARIANT_DISCLOSURE_BUTTON) == null) {
			styleProvider.setStyleFunction(ToggleButton, HierarchicalItemRenderer.CHILD_VARIANT_DISCLOSURE_BUTTON, function(button:ToggleButton):Void {
				if (button.icon == null) {
					var icon = new MultiSkin();
					button.icon = icon;

					var defaultIcon = new Shape();
					drawDisclosureClosedIcon(defaultIcon, theme.textColor);
					icon.defaultView = defaultIcon;

					var disabledIcon = new Shape();
					drawDisclosureClosedIcon(disabledIcon, theme.disabledTextColor);
					icon.disabledView = disabledIcon;

					var selectedIcon = new Shape();
					drawDisclosureOpenIcon(selectedIcon, theme.textColor);
					icon.selectedView = selectedIcon;

					var selectedDisabledIcon = new Shape();
					drawDisclosureOpenIcon(selectedDisabledIcon, theme.disabledTextColor);
					icon.setViewForState(DISABLED(true), selectedDisabledIcon);
				}
			});
		}
	}

	private static function drawDisclosureClosedIcon(icon:Shape, color:UInt):Void {
		icon.graphics.beginFill(0xff00ff, 0.0);
		icon.graphics.drawRect(0.0, 0.0, 20.0, 20.0);
		icon.graphics.endFill();
		icon.graphics.beginFill(color);
		icon.graphics.moveTo(4.0, 4.0);
		icon.graphics.lineTo(16.0, 10.0);
		icon.graphics.lineTo(4.0, 16.0);
		icon.graphics.lineTo(4.0, 4.0);
		icon.graphics.endFill();
	}

	private static function drawDisclosureOpenIcon(icon:Shape, color:UInt):Void {
		icon.graphics.beginFill(0xff00ff, 0.0);
		icon.graphics.drawRect(0.0, 0.0, 20.0, 20.0);
		icon.graphics.endFill();
		icon.graphics.beginFill(color);
		icon.graphics.moveTo(4.0, 4.0);
		icon.graphics.lineTo(16.0, 4.0);
		icon.graphics.lineTo(10.0, 16.0);
		icon.graphics.lineTo(4.0, 4.0);
		icon.graphics.endFill();
	}
}

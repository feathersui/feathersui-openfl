/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

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

				itemRenderer.paddingTop = 4.0;
				itemRenderer.paddingRight = 10.0;
				itemRenderer.paddingBottom = 4.0;
				itemRenderer.paddingLeft = 10.0;
				itemRenderer.gap = 4.0;

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
					defaultIcon.graphics.beginFill(0xff00ff, 0.0);
					defaultIcon.graphics.drawRect(0.0, 0.0, 20.0, 20.0);
					defaultIcon.graphics.endFill();
					defaultIcon.graphics.beginFill(theme.textColor);
					defaultIcon.graphics.moveTo(4.0, 4.0);
					defaultIcon.graphics.lineTo(16.0, 10.0);
					defaultIcon.graphics.lineTo(4.0, 16.0);
					defaultIcon.graphics.lineTo(4.0, 4.0);
					defaultIcon.graphics.endFill();
					icon.defaultView = defaultIcon;

					var disabledIcon = new Shape();
					disabledIcon.graphics.beginFill(0xff00ff, 0.0);
					disabledIcon.graphics.drawRect(0.0, 0.0, 20.0, 20.0);
					disabledIcon.graphics.endFill();
					disabledIcon.graphics.beginFill(theme.disabledTextColor);
					disabledIcon.graphics.moveTo(4.0, 4.0);
					disabledIcon.graphics.lineTo(16.0, 10.0);
					disabledIcon.graphics.lineTo(4.0, 16.0);
					disabledIcon.graphics.lineTo(4.0, 4.0);
					disabledIcon.graphics.endFill();
					icon.disabledView = disabledIcon;

					var selectedIcon = new Shape();
					selectedIcon.graphics.beginFill(0xff00ff, 0.0);
					selectedIcon.graphics.drawRect(0.0, 0.0, 20.0, 20.0);
					selectedIcon.graphics.endFill();
					selectedIcon.graphics.beginFill(theme.textColor);
					selectedIcon.graphics.moveTo(4.0, 4.0);
					selectedIcon.graphics.lineTo(16.0, 4.0);
					selectedIcon.graphics.lineTo(10.0, 16.0);
					selectedIcon.graphics.lineTo(4.0, 4.0);
					selectedIcon.graphics.endFill();
					icon.selectedView = selectedIcon;

					var selectedDisabledIcon = new Shape();
					selectedDisabledIcon.graphics.beginFill(0xff00ff, 0.0);
					selectedDisabledIcon.graphics.drawRect(0.0, 0.0, 20.0, 20.0);
					selectedDisabledIcon.graphics.endFill();
					selectedDisabledIcon.graphics.beginFill(theme.disabledTextColor);
					selectedDisabledIcon.graphics.moveTo(4.0, 4.0);
					selectedDisabledIcon.graphics.lineTo(16.0, 4.0);
					selectedDisabledIcon.graphics.lineTo(10.0, 16.0);
					selectedDisabledIcon.graphics.lineTo(4.0, 4.0);
					selectedDisabledIcon.graphics.endFill();
					icon.setViewForState(DISABLED(true), selectedDisabledIcon);
				}
			});
		}
	}
}

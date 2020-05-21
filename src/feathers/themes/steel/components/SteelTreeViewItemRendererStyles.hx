/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import openfl.display.Shape;
import feathers.skins.RectangleSkin;
import feathers.controls.ToggleButton;
import feathers.layout.HorizontalAlign;
import feathers.controls.ToggleButtonState;
import feathers.skins.UnderlineSkin;
import feathers.controls.dataRenderers.TreeViewItemRenderer;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

/**
	Initialize "steel" styles for the `TreeViewItemRenderer` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelTreeViewItemRendererStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(TreeViewItemRenderer, null) == null) {
			styleProvider.setStyleFunction(TreeViewItemRenderer, null, function(itemRenderer:TreeViewItemRenderer):Void {
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

				itemRenderer.indentation = 20.0;

				itemRenderer.horizontalAlign = LEFT;
			});
		}
		if (styleProvider.getStyleFunction(ToggleButton, TreeViewItemRenderer.CHILD_VARIANT_DISCLOSURE_BUTTON) == null) {
			styleProvider.setStyleFunction(ToggleButton, TreeViewItemRenderer.CHILD_VARIANT_DISCLOSURE_BUTTON, function(button:ToggleButton):Void {
				if (button.icon == null) {
					var icon = new Shape();
					icon.graphics.beginFill(0xff00ff, 0.0);
					icon.graphics.drawRect(0.0, 0.0, 20.0, 20.0);
					icon.graphics.endFill();
					icon.graphics.beginFill(theme.textColor);
					icon.graphics.moveTo(4.0, 4.0);
					icon.graphics.lineTo(16.0, 10.0);
					icon.graphics.lineTo(4.0, 16.0);
					icon.graphics.lineTo(4.0, 4.0);
					icon.graphics.endFill();
					button.icon = icon;
				}
				if (button.selectedIcon == null) {
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
					button.selectedIcon = selectedIcon;
				}
			});
		}
	}
}

/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.Check;
import feathers.controls.HRule;
import feathers.controls.Menu;
import feathers.controls.Radio;
import feathers.controls.ToggleButtonState;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.layout.VerticalListLayout;
import feathers.skins.CircleSkin;
import feathers.skins.HorizontalLineSkin;
import feathers.skins.MultiSkin;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;
import feathers.utils.DeviceUtil;
import openfl.display.DisplayObject;
import openfl.display.Shape;

/**
	Initialize "steel" styles for the `Menu` component.

	@since 1.4.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelMenuStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(Menu, null) == null) {
			styleProvider.setStyleFunction(Menu, null, function(menu:Menu):Void {
				var isDesktop = DeviceUtil.isDesktop();

				menu.autoHideScrollBars = !isDesktop;
				menu.fixedScrollBars = isDesktop;

				if (menu.layout == null) {
					var layout = new VerticalListLayout();
					layout.requestedMinRowCount = 1.0;
					layout.setPadding(theme.mediumPadding);
					menu.layout = layout;
				}

				if (menu.backgroundSkin == null) {
					var backgroundSkin = new RectangleSkin();
					backgroundSkin.fill = theme.getContainerFill();
					backgroundSkin.border = theme.getContainerBorder();
					backgroundSkin.width = 10.0;
					backgroundSkin.height = 10.0;
					backgroundSkin.cornerRadius = 4.0;
					menu.backgroundSkin = backgroundSkin;
				}

				if (menu.focusRectSkin == null) {
					var focusRectSkin = new RectangleSkin();
					focusRectSkin.fill = None;
					focusRectSkin.border = theme.getFocusBorder();
					menu.focusRectSkin = focusRectSkin;
				}

				menu.paddingTop = theme.borderThickness;
				menu.paddingRight = theme.borderThickness;
				menu.paddingBottom = theme.borderThickness;
				menu.paddingLeft = theme.borderThickness;
			});
		}
		if (styleProvider.getStyleFunction(ItemRenderer, Menu.CHILD_VARIANT_ITEM_RENDERER) == null) {
			styleProvider.setStyleFunction(ItemRenderer, Menu.CHILD_VARIANT_ITEM_RENDERER, function(itemRenderer:ItemRenderer):Void {
				var isDesktop = DeviceUtil.isDesktop();

				if (itemRenderer.backgroundSkin == null) {
					var skin = new RectangleSkin();
					skin.fill = SolidColor(0xff00ff, 0.0);
					skin.border = None;
					skin.selectedFill = theme.getActiveThemeFill();
					skin.setFillForState(ToggleButtonState.HOVER(false), theme.getActiveThemeFill());
					skin.setFillForState(ToggleButtonState.DOWN(false), theme.getActiveThemeFill());
					skin.cornerRadius = 3.0;
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

				var styleFunction = styleProvider.getStyleFunction(ItemRenderer, null);
				if (styleFunction != null) {
					styleFunction(itemRenderer);
				}

				itemRenderer.paddingLeft = theme.xlargePadding;
				itemRenderer.paddingRight = theme.xlargePadding;
			});
		}
		if (styleProvider.getStyleFunction(HRule, Menu.CHILD_VARIANT_ITEM_RENDERER) == null) {
			styleProvider.setStyleFunction(HRule, Menu.CHILD_VARIANT_ITEM_RENDERER, function(hRule:HRule):Void {
				if (hRule.backgroundSkin == null) {
					var backgroundSkin = new HorizontalLineSkin();
					backgroundSkin.fill = None;
					backgroundSkin.border = theme.getInsetBorder();
					backgroundSkin.disabledBorder = theme.getDisabledInsetBorder();
					backgroundSkin.verticalAlign = MIDDLE;
					backgroundSkin.width = 12.0;
					backgroundSkin.height = 6.0;
					hRule.backgroundSkin = backgroundSkin;
				}
			});
		}
		if (styleProvider.getStyleFunction(Check, Menu.CHILD_VARIANT_ITEM_RENDERER) == null) {
			styleProvider.setStyleFunction(Check, Menu.CHILD_VARIANT_ITEM_RENDERER, function(check:Check):Void {
				var isDesktop = DeviceUtil.isDesktop();

				if (check.backgroundSkin == null) {
					var skin = new RectangleSkin();
					skin.fill = SolidColor(0xff00ff, 0.0);
					skin.border = None;
					skin.selectedFill = theme.getActiveThemeFill();
					skin.setFillForState(ToggleButtonState.HOVER(false), theme.getActiveThemeFill());
					skin.setFillForState(ToggleButtonState.DOWN(false), theme.getActiveThemeFill());
					skin.cornerRadius = 3.0;
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
					check.backgroundSkin = skin;
				}

				var iconSize = isDesktop ? 12.0 : 16.0;
				if (check.icon == null) {
					var icon = new MultiSkin();
					check.icon = icon;

					var defaultIcon = new RectangleSkin(SolidColor(0xff00ff, 0.0));
					defaultIcon.width = iconSize;
					defaultIcon.height = iconSize;
					defaultIcon.minWidth = iconSize;
					defaultIcon.minHeight = iconSize;
					icon.defaultView = defaultIcon;

					var selectedIcon = new RectangleSkin(SolidColor(0xff00ff, 0.0));
					selectedIcon.width = iconSize;
					selectedIcon.height = iconSize;
					selectedIcon.minWidth = iconSize;
					selectedIcon.minHeight = iconSize;
					selectedIcon.addChild(createCheckMark(theme.textColor, isDesktop));
					icon.selectedView = selectedIcon;

					var disabledAndSelectedIcon = new RectangleSkin(SolidColor(0xff00ff, 0.0));
					disabledAndSelectedIcon.width = iconSize;
					disabledAndSelectedIcon.height = iconSize;
					disabledAndSelectedIcon.minWidth = iconSize;
					disabledAndSelectedIcon.minHeight = iconSize;
					disabledAndSelectedIcon.addChild(createCheckMark(theme.disabledTextColor, isDesktop));
					icon.setViewForState(DISABLED(true), disabledAndSelectedIcon);
				}

				if (check.textFormat == null) {
					check.textFormat = theme.getTextFormat();
				}
				if (check.disabledTextFormat == null) {
					check.disabledTextFormat = theme.getDisabledTextFormat();
				}

				check.paddingTop = theme.smallPadding;
				check.paddingRight = theme.xlargePadding;
				check.paddingBottom = theme.smallPadding;
				check.paddingLeft = theme.mediumPadding;
				check.gap = theme.smallPadding;
				check.horizontalAlign = LEFT;
			});
		}
		if (styleProvider.getStyleFunction(Radio, Menu.CHILD_VARIANT_ITEM_RENDERER) == null) {
			styleProvider.setStyleFunction(Radio, Menu.CHILD_VARIANT_ITEM_RENDERER, function(radio:Radio):Void {
				var isDesktop = DeviceUtil.isDesktop();

				if (radio.backgroundSkin == null) {
					var skin = new RectangleSkin();
					skin.fill = SolidColor(0xff00ff, 0.0);
					skin.border = None;
					skin.selectedFill = theme.getActiveThemeFill();
					skin.setFillForState(ToggleButtonState.HOVER(false), theme.getActiveThemeFill());
					skin.setFillForState(ToggleButtonState.DOWN(false), theme.getActiveThemeFill());
					skin.cornerRadius = 3.0;
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
					radio.backgroundSkin = skin;
				}

				var iconSize = isDesktop ? 12.0 : 16.0;
				if (radio.icon == null) {
					var icon = new MultiSkin();
					radio.icon = icon;

					var defaultIcon = new CircleSkin();
					defaultIcon.width = iconSize;
					defaultIcon.height = iconSize;
					defaultIcon.minWidth = iconSize;
					defaultIcon.minHeight = iconSize;
					defaultIcon.border = theme.getInsetBorder();
					defaultIcon.disabledBorder = theme.getDisabledInsetBorder();
					defaultIcon.setBorderForState(DOWN(false), theme.getSelectedInsetBorder());
					defaultIcon.fill = theme.getInsetFill();
					defaultIcon.disabledFill = theme.getDisabledInsetFill();
					icon.defaultView = defaultIcon;

					var selectedIcon = new CircleSkin();
					selectedIcon.width = iconSize;
					selectedIcon.height = iconSize;
					selectedIcon.minWidth = iconSize;
					selectedIcon.minHeight = iconSize;
					selectedIcon.border = theme.getSelectedInsetBorder();
					selectedIcon.disabledBorder = theme.getDisabledInsetBorder();
					selectedIcon.setBorderForState(DOWN(true), theme.getSelectedInsetBorder());
					selectedIcon.fill = theme.getReversedActiveThemeFill();
					selectedIcon.disabledFill = theme.getDisabledInsetFill();
					selectedIcon.addChild(createRadioFill(theme.textColor, isDesktop));
					icon.selectedView = selectedIcon;

					var disabledAndSelectedIcon = new CircleSkin();
					disabledAndSelectedIcon.width = iconSize;
					disabledAndSelectedIcon.height = iconSize;
					disabledAndSelectedIcon.minWidth = iconSize;
					disabledAndSelectedIcon.minHeight = iconSize;
					disabledAndSelectedIcon.border = theme.getDisabledInsetBorder();
					disabledAndSelectedIcon.fill = theme.getDisabledInsetFill();
					disabledAndSelectedIcon.addChild(createRadioFill(theme.disabledTextColor, isDesktop));
					icon.setViewForState(DISABLED(true), disabledAndSelectedIcon);
				}

				if (radio.textFormat == null) {
					radio.textFormat = theme.getTextFormat();
				}
				if (radio.disabledTextFormat == null) {
					radio.disabledTextFormat = theme.getDisabledTextFormat();
				}

				radio.paddingTop = theme.smallPadding;
				radio.paddingRight = theme.xlargePadding;
				radio.paddingBottom = theme.smallPadding;
				radio.paddingLeft = theme.mediumPadding;
				radio.gap = theme.smallPadding;
				radio.horizontalAlign = LEFT;
			});
		}
	}

	private static function createCheckMark(color:UInt, isDesktop:Bool):DisplayObject {
		var checkMark = new Shape();
		if (isDesktop) {
			checkMark.graphics.beginFill(color);
			checkMark.graphics.drawRect(-1.0, -8.0, 3.0, 11.0);
			checkMark.graphics.endFill();
			checkMark.graphics.beginFill(color);
			checkMark.graphics.drawRect(-4.0, 0.0, 5.0, 3.0);
			checkMark.graphics.endFill();
			checkMark.x = 5.0;
			checkMark.y = 7.0;
		} else {
			checkMark.graphics.beginFill(color);
			checkMark.graphics.drawRect(-1.0, -8.0, 3.0, 14.0);
			checkMark.graphics.endFill();
			checkMark.graphics.beginFill(color);
			checkMark.graphics.drawRect(-5.0, 3.0, 5.0, 3.0);
			checkMark.graphics.endFill();
			checkMark.x = 8.0;
			checkMark.y = 9.0;
		}
		checkMark.rotation = 45.0;
		return checkMark;
	}

	private static function createRadioFill(color:UInt, isDesktop:Bool):DisplayObject {
		var symbol = new Shape();
		symbol.graphics.beginFill(color);
		if (isDesktop) {
			symbol.graphics.drawCircle(6.0, 6.0, 2.0);
		} else {
			symbol.graphics.drawCircle(8.0, 8.0, 3.0);
		}
		symbol.graphics.endFill();
		return symbol;
	}
}

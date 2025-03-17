/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.skins.UnderlineSkin;
import feathers.controls.ToggleButtonState;
import feathers.controls.dataRenderers.TreeGridViewRowRenderer;
import feathers.controls.dataRenderers.HierarchicalItemRenderer;
import feathers.controls.Button;
import feathers.controls.ButtonState;
import feathers.controls.TreeGridView;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.layout.VerticalListLayout;
import feathers.skins.RectangleSkin;
import feathers.skins.VerticalLineSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;
import feathers.utils.DeviceUtil;

/**
	Initialize "steel" styles for the `TreeGridView` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelTreeGridViewStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		function styleGridViewWithBorderVariant(gridView:TreeGridView):Void {
			var isDesktop = DeviceUtil.isDesktop();

			gridView.autoHideScrollBars = !isDesktop;
			gridView.fixedScrollBars = isDesktop;

			if (gridView.layout == null) {
				var layout = new VerticalListLayout();
				layout.requestedRowCount = 5.0;
				gridView.layout = layout;
			}

			if (gridView.backgroundSkin == null) {
				var backgroundSkin = new RectangleSkin();
				backgroundSkin.fill = theme.getContainerFill();
				backgroundSkin.border = theme.getContainerBorder();
				backgroundSkin.width = 10.0;
				backgroundSkin.height = 10.0;
				gridView.backgroundSkin = backgroundSkin;
			}

			if (gridView.columnResizeSkin == null) {
				var columnResizeSkin = new RectangleSkin();
				columnResizeSkin.fill = theme.getThemeFill();
				columnResizeSkin.border = None;
				columnResizeSkin.width = 2.0;
				columnResizeSkin.height = 2.0;
				gridView.columnResizeSkin = columnResizeSkin;
			}

			if (gridView.headerCornerSkin == null) {
				var headerCornerSkin = new RectangleSkin();
				headerCornerSkin.fill = theme.getSubHeadingFill();
				headerCornerSkin.border = None;
				gridView.headerCornerSkin = headerCornerSkin;
			}

			if (gridView.focusRectSkin == null) {
				var focusRectSkin = new RectangleSkin();
				focusRectSkin.fill = None;
				focusRectSkin.border = theme.getFocusBorder();
				gridView.focusRectSkin = focusRectSkin;
			}

			gridView.showHeaderDividersOnlyWhenResizable = true;

			gridView.paddingTop = theme.borderThickness;
			gridView.paddingRight = theme.borderThickness;
			gridView.paddingBottom = theme.borderThickness;
			gridView.paddingLeft = theme.borderThickness;
		}

		function styleGridViewWithBorderlessVariant(gridView:TreeGridView):Void {
			var isDesktop = DeviceUtil.isDesktop();

			gridView.autoHideScrollBars = !isDesktop;
			gridView.fixedScrollBars = isDesktop;

			if (gridView.layout == null) {
				var layout = new VerticalListLayout();
				layout.requestedRowCount = 5.0;
				gridView.layout = layout;
			}

			if (gridView.backgroundSkin == null) {
				var backgroundSkin = new RectangleSkin();
				backgroundSkin.fill = theme.getContainerFill();
				backgroundSkin.border = None;
				backgroundSkin.width = 10.0;
				backgroundSkin.height = 10.0;
				gridView.backgroundSkin = backgroundSkin;
			}

			if (gridView.columnResizeSkin == null) {
				var columnResizeSkin = new RectangleSkin();
				columnResizeSkin.fill = theme.getThemeFill();
				columnResizeSkin.border = None;
				columnResizeSkin.width = 2.0;
				columnResizeSkin.height = 2.0;
				gridView.columnResizeSkin = columnResizeSkin;
			}

			if (gridView.headerCornerSkin == null) {
				var headerCornerSkin = new RectangleSkin();
				headerCornerSkin.fill = theme.getSubHeadingFill();
				headerCornerSkin.border = None;
				gridView.headerCornerSkin = headerCornerSkin;
			}

			if (gridView.focusRectSkin == null) {
				var skin = new RectangleSkin();
				skin.fill = None;
				skin.border = theme.getFocusBorder();
				gridView.focusRectSkin = skin;
			}

			gridView.showHeaderDividersOnlyWhenResizable = true;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(TreeGridView, null) == null) {
			styleProvider.setStyleFunction(TreeGridView, null, function(gridView:TreeGridView):Void {
				var isDesktop = DeviceUtil.isDesktop();
				if (isDesktop) {
					styleGridViewWithBorderVariant(gridView);
				} else {
					styleGridViewWithBorderlessVariant(gridView);
				}
			});
		}
		if (styleProvider.getStyleFunction(TreeGridView, TreeGridView.VARIANT_BORDER) == null) {
			styleProvider.setStyleFunction(TreeGridView, TreeGridView.VARIANT_BORDER, styleGridViewWithBorderVariant);
		}
		if (styleProvider.getStyleFunction(TreeGridView, TreeGridView.VARIANT_BORDERLESS) == null) {
			styleProvider.setStyleFunction(TreeGridView, TreeGridView.VARIANT_BORDERLESS, styleGridViewWithBorderlessVariant);
		}

		if (styleProvider.getStyleFunction(HierarchicalItemRenderer, TreeGridView.CHILD_VARIANT_CELL_RENDERER) == null) {
			styleProvider.setStyleFunction(HierarchicalItemRenderer, TreeGridView.CHILD_VARIANT_CELL_RENDERER,
				function(itemRenderer:HierarchicalItemRenderer):Void {
					var isDesktop = DeviceUtil.isDesktop();
					if (itemRenderer.backgroundSkin == null) {
						// a transparent background skin ensures that CELL_TRIGGER
						// gets dispatched
						var backgroundSkin = new RectangleSkin();
						backgroundSkin.fill = SolidColor(0xff00ff, 0.0);
						backgroundSkin.border = None;
						if (isDesktop) {
							backgroundSkin.width = 26.0;
							backgroundSkin.height = 26.0;
							backgroundSkin.minWidth = 26.0;
							backgroundSkin.minHeight = 26.0;
						} else {
							backgroundSkin.width = 44.0;
							backgroundSkin.height = 44.0;
							backgroundSkin.minWidth = 44.0;
							backgroundSkin.minHeight = 44.0;
						}
						itemRenderer.backgroundSkin = backgroundSkin;
					}
					// except for the background skin, use other default styles
					theme.styleProvider.getStyleFunction(HierarchicalItemRenderer, null)(itemRenderer);
				});
		}

		if (styleProvider.getStyleFunction(ItemRenderer, TreeGridView.CHILD_VARIANT_HEADER_RENDERER) == null) {
			styleProvider.setStyleFunction(ItemRenderer, TreeGridView.CHILD_VARIANT_HEADER_RENDERER, function(itemRenderer:ItemRenderer):Void {
				var isDesktop = DeviceUtil.isDesktop();

				if (itemRenderer.backgroundSkin == null) {
					var skin = new RectangleSkin();
					skin.fill = theme.getSubHeadingFill();
					skin.border = None;
					if (isDesktop) {
						skin.width = 22.0;
						skin.height = 22.0;
						skin.minWidth = 22.0;
						skin.minHeight = 22.0;
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

		if (styleProvider.getStyleFunction(Button, TreeGridView.CHILD_VARIANT_HEADER_DIVIDER) == null) {
			styleProvider.setStyleFunction(Button, TreeGridView.CHILD_VARIANT_HEADER_DIVIDER, function(headerDivider:Button):Void {
				var isDesktop = DeviceUtil.isDesktop();

				if (headerDivider.backgroundSkin == null) {
					var skin = new VerticalLineSkin();
					skin.fill = SolidColor(0xff00ff, 0.0);
					skin.border = theme.getSubHeadingDividerBorder();
					skin.setBorderForState(HOVER, theme.getThemeBorder());
					if (isDesktop) {
						skin.width = 6.0;
						skin.height = 1.0;
						skin.minWidth = 6.0;
						skin.minHeight = 1.0;
					} else {
						skin.width = 10.0;
						skin.height = 1.0;
						skin.minWidth = 10.0;
						skin.minHeight = 1.0;
					}
					headerDivider.backgroundSkin = skin;
				}
			});
		}

		if (styleProvider.getStyleFunction(TreeGridViewRowRenderer, null) == null) {
			styleProvider.setStyleFunction(TreeGridViewRowRenderer, null, function(rowRenderer:TreeGridViewRowRenderer):Void {
				var isDesktop = DeviceUtil.isDesktop();

				if (rowRenderer.backgroundSkin == null) {
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
					rowRenderer.backgroundSkin = skin;
				}
			});
		}
	}
}

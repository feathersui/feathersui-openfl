/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.Callout;
import feathers.layout.RelativePosition;
import feathers.skins.RectangleSkin;
import feathers.skins.TriangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

/**
	Initialize "steel" styles for the `Callout` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelCalloutStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(Callout, null) == null) {
			styleProvider.setStyleFunction(Callout, null, function(callout:Callout):Void {
				if (callout.backgroundSkin == null) {
					var backgroundSkin = new RectangleSkin();
					backgroundSkin.fill = theme.getContainerFill();
					backgroundSkin.border = theme.getContainerBorder();
					callout.backgroundSkin = backgroundSkin;
				}
				if (callout.topArrowSkin == null) {
					var topArrowSkin = new TriangleSkin();
					topArrowSkin.pointPosition = TOP;
					topArrowSkin.drawBaseBorder = false;
					topArrowSkin.fill = theme.getContainerFill();
					topArrowSkin.border = theme.getContainerBorder();
					topArrowSkin.width = 14.0;
					topArrowSkin.height = 8.0;
					callout.topArrowSkin = topArrowSkin;
				}
				if (callout.rightArrowSkin == null) {
					var rightArrowSkin = new TriangleSkin();
					rightArrowSkin.pointPosition = RIGHT;
					rightArrowSkin.drawBaseBorder = false;
					rightArrowSkin.fill = theme.getContainerFill();
					rightArrowSkin.border = theme.getContainerBorder();
					rightArrowSkin.width = 8.0;
					rightArrowSkin.height = 14.0;
					callout.rightArrowSkin = rightArrowSkin;
				}
				if (callout.bottomArrowSkin == null) {
					var bottomArrowSkin = new TriangleSkin();
					bottomArrowSkin.pointPosition = BOTTOM;
					bottomArrowSkin.drawBaseBorder = false;
					bottomArrowSkin.fill = theme.getContainerFill();
					bottomArrowSkin.border = theme.getContainerBorder();
					bottomArrowSkin.width = 14.0;
					bottomArrowSkin.height = 8.0;
					callout.bottomArrowSkin = bottomArrowSkin;
				}
				if (callout.leftArrowSkin == null) {
					var leftArrowSkin = new TriangleSkin();
					leftArrowSkin.pointPosition = LEFT;
					leftArrowSkin.drawBaseBorder = false;
					leftArrowSkin.fill = theme.getContainerFill();
					leftArrowSkin.border = theme.getContainerBorder();
					leftArrowSkin.width = 8.0;
					leftArrowSkin.height = 14.0;
					callout.leftArrowSkin = leftArrowSkin;
				}

				callout.topArrowGap = -theme.borderThickness;
				callout.rightArrowGap = -theme.borderThickness;
				callout.bottomArrowGap = -theme.borderThickness;
				callout.leftArrowGap = -theme.borderThickness;

				callout.paddingTop = theme.borderThickness;
				callout.paddingRight = theme.borderThickness;
				callout.paddingBottom = theme.borderThickness;
				callout.paddingLeft = theme.borderThickness;

				callout.marginTop = theme.xlargePadding;
				callout.marginRight = theme.xlargePadding;
				callout.marginBottom = theme.xlargePadding;
				callout.marginLeft = theme.xlargePadding;
			});
		}
	}
}

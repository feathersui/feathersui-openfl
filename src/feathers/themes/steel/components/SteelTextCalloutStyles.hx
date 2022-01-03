/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.TextCallout;
import feathers.skins.RectangleSkin;
import feathers.skins.TriangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

/**
	Initialize "steel" styles for the `TextCallout` component.

	@since 1.0.0
**/
@:dox(hide)
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelTextCalloutStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(TextCallout, null) == null) {
			styleProvider.setStyleFunction(TextCallout, null, function(callout:TextCallout):Void {
				if (callout.textFormat == null) {
					callout.textFormat = theme.getTextFormat();
				}
				if (callout.disabledTextFormat == null) {
					callout.disabledTextFormat = theme.getDisabledTextFormat();
				}
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
					topArrowSkin.width = 10.0;
					topArrowSkin.height = 6.0;
					callout.topArrowSkin = topArrowSkin;
				}
				if (callout.rightArrowSkin == null) {
					var rightArrowSkin = new TriangleSkin();
					rightArrowSkin.pointPosition = RIGHT;
					rightArrowSkin.drawBaseBorder = false;
					rightArrowSkin.fill = theme.getContainerFill();
					rightArrowSkin.border = theme.getContainerBorder();
					rightArrowSkin.width = 6.0;
					rightArrowSkin.height = 10.0;
					callout.rightArrowSkin = rightArrowSkin;
				}
				if (callout.bottomArrowSkin == null) {
					var bottomArrowSkin = new TriangleSkin();
					bottomArrowSkin.pointPosition = BOTTOM;
					bottomArrowSkin.drawBaseBorder = false;
					bottomArrowSkin.fill = theme.getContainerFill();
					bottomArrowSkin.border = theme.getContainerBorder();
					bottomArrowSkin.width = 10.0;
					bottomArrowSkin.height = 6.0;
					callout.bottomArrowSkin = bottomArrowSkin;
				}
				if (callout.leftArrowSkin == null) {
					var leftArrowSkin = new TriangleSkin();
					leftArrowSkin.pointPosition = LEFT;
					leftArrowSkin.drawBaseBorder = false;
					leftArrowSkin.fill = theme.getContainerFill();
					leftArrowSkin.border = theme.getContainerBorder();
					leftArrowSkin.width = 6.0;
					leftArrowSkin.height = 10.0;
					callout.leftArrowSkin = leftArrowSkin;
				}

				callout.topArrowGap = -1.0;
				callout.rightArrowGap = -1.0;
				callout.bottomArrowGap = -1.0;
				callout.leftArrowGap = -1.0;

				callout.paddingTop = 1.0;
				callout.paddingRight = 1.0;
				callout.paddingBottom = 1.0;
				callout.paddingLeft = 1.0;

				callout.marginTop = 10.0;
				callout.marginRight = 10.0;
				callout.marginBottom = 10.0;
				callout.marginLeft = 10.0;
			});
		}
		if (styleProvider.getStyleFunction(TextCallout, TextCallout.VARIANT_DANGER) == null) {
			styleProvider.setStyleFunction(TextCallout, TextCallout.VARIANT_DANGER, function(callout:TextCallout):Void {
				if (callout.textFormat == null) {
					callout.textFormat = theme.getTextFormat();
				}
				if (callout.disabledTextFormat == null) {
					callout.disabledTextFormat = theme.getDisabledTextFormat();
				}
				if (callout.backgroundSkin == null) {
					var backgroundSkin = new RectangleSkin();
					backgroundSkin.fill = theme.getDangerFill();
					backgroundSkin.border = theme.getDangerBorder();
					callout.backgroundSkin = backgroundSkin;
				}
				if (callout.topArrowSkin == null) {
					var topArrowSkin = new TriangleSkin();
					topArrowSkin.pointPosition = TOP;
					topArrowSkin.drawBaseBorder = false;
					topArrowSkin.fill = theme.getDangerFill();
					topArrowSkin.border = theme.getDangerBorder();
					topArrowSkin.width = 10.0;
					topArrowSkin.height = 6.0;
					callout.topArrowSkin = topArrowSkin;
				}
				if (callout.rightArrowSkin == null) {
					var rightArrowSkin = new TriangleSkin();
					rightArrowSkin.pointPosition = RIGHT;
					rightArrowSkin.drawBaseBorder = false;
					rightArrowSkin.fill = theme.getDangerFill();
					rightArrowSkin.border = theme.getDangerBorder();
					rightArrowSkin.width = 6.0;
					rightArrowSkin.height = 10.0;
					callout.rightArrowSkin = rightArrowSkin;
				}
				if (callout.bottomArrowSkin == null) {
					var bottomArrowSkin = new TriangleSkin();
					bottomArrowSkin.pointPosition = BOTTOM;
					bottomArrowSkin.drawBaseBorder = false;
					bottomArrowSkin.fill = theme.getDangerFill();
					bottomArrowSkin.border = theme.getDangerBorder();
					bottomArrowSkin.width = 10.0;
					bottomArrowSkin.height = 6.0;
					callout.bottomArrowSkin = bottomArrowSkin;
				}
				if (callout.leftArrowSkin == null) {
					var leftArrowSkin = new TriangleSkin();
					leftArrowSkin.pointPosition = LEFT;
					leftArrowSkin.drawBaseBorder = false;
					leftArrowSkin.fill = theme.getDangerFill();
					leftArrowSkin.border = theme.getDangerBorder();
					leftArrowSkin.width = 6.0;
					leftArrowSkin.height = 10.0;
					callout.leftArrowSkin = leftArrowSkin;
				}

				callout.topArrowGap = -1.0;
				callout.rightArrowGap = -1.0;
				callout.bottomArrowGap = -1.0;
				callout.leftArrowGap = -1.0;

				callout.paddingTop = 1.0;
				callout.paddingRight = 1.0;
				callout.paddingBottom = 1.0;
				callout.paddingLeft = 1.0;

				callout.marginTop = 10.0;
				callout.marginRight = 10.0;
				callout.marginBottom = 10.0;
				callout.marginLeft = 10.0;
			});
		}
	}
}

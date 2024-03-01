/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel;

import feathers.utils.DeviceUtil;
import feathers.events.StyleProviderEvent;
import feathers.graphics.FillStyle;
import feathers.graphics.LineStyle;
import feathers.style.ClassVariantStyleProvider;
import feathers.style.IDarkModeTheme;
import feathers.text.TextFormat;
import openfl.display.GradientType;
import openfl.text.TextFormatAlign;
#if html5
import js.Lib;
import js.html.MediaQueryList;
import js.html.MediaQueryListEvent;
import js.html.Window;
#end

/**
	Base class for the "Steel" theme.

	When using the `Application` component, add the following define to your
	OpenFL _project.xml_ file to use this theme's preferred background color
	for the stage's color.

	```xml
	<haxedef name="feathersui_theme_manage_stage_color"/>
	```

	You may prefer to set the stage color manually. Add one of the following
	options to your OpenFL _project.xml_ file to set the initial stage color.

	```xml
	<!-- light mode -->
	<window background="#F8F8F8"/>
	```

	```xml
	<!-- dark mode -->
	<window background="#383838"/>
	```

	@since 1.0.0
**/
@:dox(hide)
class BaseSteelTheme extends ClassVariantTheme implements IDarkModeTheme {
	private function new(?themeColor:Int, ?darkThemeColor:Int) {
		super();

		this.customThemeColor = themeColor;
		this.customDarkThemeColor = darkThemeColor;
		this.refreshColors();
		this.refreshFonts();
		this.refreshPaddings();
		this.styleProvider = new ClassVariantStyleProvider();
		// there are no calls to setStyleFunction() in the theme by default.
		// instead, component classes must call setStyleFunction() to keep
		// unused components from being included in the final compiled output.

		#if html5
		var htmlWindow = cast(Lib.global, Window);
		// watch for switching between desktop and mobile
		// which could happen when simulating mobile on desktop
		this.mediaQueryList = htmlWindow.matchMedia("(hover: hover) and (pointer: fine)");
		this.mediaQueryList.addListener(mediaQueryList_changeHandler);
		#end
	}

	#if html5
	var mediaQueryList:MediaQueryList;
	#end

	private var _darkMode:Bool = false;

	@:bindable("stylesChange")
	public var darkMode(get, set):Bool;

	private function get_darkMode():Bool {
		return this._darkMode;
	}

	private function set_darkMode(value:Bool):Bool {
		if (this._darkMode == value) {
			return this._darkMode;
		}
		this._darkMode = value;
		this.refreshColors();
		StyleProviderEvent.dispatch(this.styleProvider, StyleProviderEvent.STYLES_CHANGE);
		return this._darkMode;
	}

	private var customThemeColor:Null<Int>;
	private var customDarkThemeColor:Null<Int>;
	private var themeColor:Int;
	private var offsetThemeColor:Int;
	private var rootFillColor:Int;
	private var controlFillColor1:Int;
	private var controlFillColor2:Int;
	private var controlDisabledFillColor:Int;
	private var scrollBarThumbFillColor:Int;
	private var scrollBarThumbDisabledFillColor:Int;
	private var insetFillColor:Int;
	private var disabledInsetFillColor:Int;
	private var insetBorderColor:Int;
	private var disabledInsetBorderColor:Int;
	private var selectedInsetBorderColor:Int;
	private var activeFillBorderColor:Int;
	private var selectedBorderColor:Int;
	private var focusBorderColor:Int;
	private var containerFillColor:Int;
	private var headerFillColor:Int;
	private var overlayFillColor:Int;
	private var subHeadingFillColor:Int;
	private var borderColor:Int;
	private var dividerColor:Int;
	private var subHeadingDividerColor:Int;
	private var textColor:Int;
	private var secondaryTextColor:Int;
	private var disabledTextColor:Int;
	private var dangerTextColor:Int;
	private var dangerFillColor:Int;
	private var offsetDangerFillColor:Int;
	private var dangerBorderColor:Int;

	private var fontName:String;
	private var fontSize:Int;
	private var headerFontSize:Int;
	private var detailFontSize:Int;

	private var borderThickness:Float;
	private var xsmallPadding:Float;
	private var smallPadding:Float;
	private var mediumPadding:Float;
	private var largePadding:Float;
	private var xlargePadding:Float;

	#if html5
	@:dox(hide)
	override public function dispose():Void {
		if (this.mediaQueryList != null) {
			this.mediaQueryList.removeListener(mediaQueryList_changeHandler);
			this.mediaQueryList = null;
		}
		super.dispose();
	}
	#end

	private function refreshColors():Void {
		if (this._darkMode) {
			if (this.customDarkThemeColor != null) {
				this.themeColor = this.customDarkThemeColor;
			} else if (this.customThemeColor != null) {
				this.themeColor = this.customThemeColor;
			} else {
				this.themeColor = 0x4f6f9f;
			}
			this.offsetThemeColor = this.darken(this.themeColor, 0x0f0f0f);
			this.rootFillColor = 0x383838;
			this.controlFillColor1 = 0x5f5f5f;
			this.controlFillColor2 = 0x4c4c4c;
			this.controlDisabledFillColor = 0x303030;
			this.scrollBarThumbFillColor = 0x6f6f6f;
			this.scrollBarThumbDisabledFillColor = 0x3f3f3f;
			this.insetFillColor = 0x181818;
			this.disabledInsetFillColor = 0x282828;
			this.insetBorderColor = 0x484848;
			this.disabledInsetBorderColor = 0x383838;
			this.selectedInsetBorderColor = this.themeColor;
			this.activeFillBorderColor = this.darken(this.themeColor, 0x2f2f2f);
			this.selectedBorderColor = this.lighten(this.themeColor, 0x0f0f0f);
			this.focusBorderColor = this.lighten(this.themeColor, 0x0f0f0f);
			this.containerFillColor = 0x383838;
			this.headerFillColor = 0x3f3f3f;
			this.overlayFillColor = 0x6f6f6f;
			this.subHeadingFillColor = 0x2c2c2c;
			this.dangerFillColor = 0x9f4f4f;
			this.offsetDangerFillColor = this.darken(this.dangerFillColor, 0x0f0f0f);
			this.dangerBorderColor = this.darken(this.dangerFillColor, 0x2f2f2f);
			this.borderColor = 0x080808;
			this.dividerColor = 0x282828;
			this.subHeadingDividerColor = 0x0c0c0c;
			this.textColor = 0xf1f1f1;
			this.disabledTextColor = 0x8f8f8f;
			this.secondaryTextColor = 0xafafaf;
			this.dangerTextColor = 0xcc3f3f;
		} else // light
		{
			if (this.customThemeColor != null) {
				this.themeColor = this.customThemeColor;
			} else {
				this.themeColor = 0xa0c0f0;
			}
			this.offsetThemeColor = this.darken(this.themeColor, 0x0f0f0f);
			this.rootFillColor = 0xf8f8f8;
			this.controlFillColor1 = 0xffffff;
			this.controlFillColor2 = 0xe8e8e8;
			this.controlDisabledFillColor = 0xefefef;
			this.scrollBarThumbFillColor = 0x8f8f8f;
			this.scrollBarThumbDisabledFillColor = 0xcfcfcf;
			this.insetFillColor = 0xfcfcfc;
			this.disabledInsetFillColor = 0xf1f1f1;
			this.insetBorderColor = 0xacacac;
			this.disabledInsetBorderColor = 0xcccccc;
			this.selectedInsetBorderColor = this.darken(this.themeColor, 0x2f2f2f);
			this.activeFillBorderColor = this.darken(this.themeColor, 0x2f2f2f);
			this.selectedBorderColor = this.darken(this.themeColor, 0x2f2f2f);
			this.focusBorderColor = this.darken(this.themeColor, 0x2f2f2f);
			this.containerFillColor = 0xf8f8f8;
			this.headerFillColor = 0xececec;
			this.overlayFillColor = 0x8f8f8f;
			this.subHeadingFillColor = 0xdfdfdf;
			this.dangerFillColor = 0xf0a0a0;
			this.offsetDangerFillColor = this.darken(this.dangerFillColor, 0x0f0f0f);
			this.dangerBorderColor = this.darken(this.dangerFillColor, 0x2f2f2f);
			this.borderColor = 0xacacac;
			this.dividerColor = 0xdfdfdf;
			this.subHeadingDividerColor = 0xcfcfcf;
			this.textColor = 0x1f1f1f;
			this.disabledTextColor = 0x9f9f9f;
			this.secondaryTextColor = 0x6f6f6f;
			this.dangerTextColor = 0xcc3f3f;
		}
	}

	private function refreshFonts():Void {
		this.fontName = "_sans";
		this.refreshFontSizes();
	}

	private function refreshFontSizes():Void {
		if (DeviceUtil.isDesktop()) {
			this.fontSize = 13;
			this.headerFontSize = 14;
			this.detailFontSize = 11;
		} else {
			this.fontSize = 14;
			this.headerFontSize = 18;
			this.detailFontSize = 12;
		}
	}

	private function refreshPaddings():Void {
		if (DeviceUtil.isDesktop()) {
			this.borderThickness = 1.0;
			this.xsmallPadding = 1.0;
			this.smallPadding = 2.0;
			this.mediumPadding = 4.0;
			this.largePadding = 8.0;
			this.xlargePadding = 10.0;
		} else {
			this.borderThickness = 1.0;
			this.xsmallPadding = 2.0;
			this.smallPadding = 4.0;
			this.mediumPadding = 6.0;
			this.largePadding = 10.0;
			this.xlargePadding = 14.0;
		}
	}

	private function getThemeFill():FillStyle {
		return SolidColor(this.themeColor);
	}

	private function getControlFill():FillStyle {
		return SolidColor(this.controlFillColor2);
	}

	private function getControlDisabledFill():FillStyle {
		return SolidColor(this.controlDisabledFillColor, 0.7);
	}

	private function getButtonFill():FillStyle {
		return Gradient(GradientType.LINEAR, [this.controlFillColor1, this.controlFillColor2], [1.0, 1.0], [0, 0xff], Math.PI / 2.0);
	}

	private function getButtonDownFill():FillStyle {
		return Gradient(GradientType.LINEAR, [this.controlFillColor2, this.controlFillColor1], [1.0, 1.0], [0, 0xff], Math.PI / 2.0);
	}

	private function getButtonDisabledFill():FillStyle {
		return SolidColor(this.controlDisabledFillColor);
	}

	private function getScrollBarThumbFill():FillStyle {
		return SolidColor(this.scrollBarThumbFillColor);
	}

	private function getScrollBarThumbDisabledFill():FillStyle {
		return SolidColor(this.scrollBarThumbDisabledFillColor, 0.7);
	}

	private function getBorder(thickness:Float = 1.0):LineStyle {
		return SolidColor(thickness, this.borderColor);
	}

	private function getButtonBorder(thickness:Float = 1.0):LineStyle {
		return SolidColor(thickness, this.borderColor);
	}

	private function getButtonDisabledBorder(thickness:Float = 1.0):LineStyle {
		return SolidColor(thickness, this.disabledInsetBorderColor);
	}

	private function getInsetBorder(thickness:Float = 1.0):LineStyle {
		return SolidColor(thickness, this.insetBorderColor);
	}

	private function getDisabledInsetBorder(thickness:Float = 1.0):LineStyle {
		return SolidColor(thickness, this.disabledInsetBorderColor);
	}

	private function getSelectedInsetBorder(thickness:Float = 1.0):LineStyle {
		return SolidColor(thickness, this.selectedInsetBorderColor);
	}

	private function getThemeBorder(thickness:Float = 1.0):LineStyle {
		return SolidColor(thickness, this.themeColor);
	}

	private function getSelectedBorder(thickness:Float = 1.0):LineStyle {
		return SolidColor(thickness, this.selectedBorderColor);
	}

	private function getActiveFillBorder(thickness:Float = 1.0):LineStyle {
		return SolidColor(thickness, this.activeFillBorderColor);
	}

	private function getContainerBorder(thickness:Float = 1.0):LineStyle {
		return SolidColor(thickness, this.borderColor);
	}

	private function getDividerBorder(thickness:Float = 1.0):LineStyle {
		return SolidColor(thickness, this.dividerColor);
	}

	private function getDividerFill():FillStyle {
		return SolidColor(this.dividerColor);
	}

	private function getSubHeadingDividerBorder(thickness:Float = 1.0):LineStyle {
		return SolidColor(thickness, this.subHeadingDividerColor);
	}

	private function getSubHeadingDividerFill():FillStyle {
		return SolidColor(this.subHeadingDividerColor);
	}

	private function getFocusBorder(thickness:Float = 1.0):LineStyle {
		return SolidColor(thickness, this.focusBorderColor);
	}

	private function getInsetFill():FillStyle {
		return SolidColor(this.insetFillColor);
	}

	private function getDisabledInsetFill():FillStyle {
		return SolidColor(this.disabledInsetFillColor);
	}

	private function getActiveThemeFill():FillStyle {
		var colors = [this.themeColor, this.offsetThemeColor];
		return Gradient(GradientType.LINEAR, colors, [1.0, 1.0], [0, 0xff], Math.PI / 2.0);
	}

	private function getReversedActiveThemeFill():FillStyle {
		var colors = [this.offsetThemeColor, this.themeColor];
		return Gradient(GradientType.LINEAR, colors, [1.0, 1.0], [0, 0xff], Math.PI / 2.0);
	}

	private function getDangerFill():FillStyle {
		var colors = [this.dangerFillColor, this.offsetDangerFillColor];
		return Gradient(GradientType.LINEAR, colors, [1.0, 1.0], [0, 0xff], Math.PI / 2.0);
	}

	private function getReversedDangerFill():FillStyle {
		var colors = [this.offsetDangerFillColor, this.dangerFillColor];
		return Gradient(GradientType.LINEAR, colors, [1.0, 1.0], [0, 0xff], Math.PI / 2.0);
	}

	private function getDangerBorder(thickness:Float = 1.0):LineStyle {
		return SolidColor(thickness, this.dangerBorderColor);
	}

	private function getOverlayFill():FillStyle {
		return SolidColor(this.overlayFillColor, 0.8);
	}

	private function getRootFill():FillStyle {
		return SolidColor(this.rootFillColor);
	}

	private function getContainerFill():FillStyle {
		return SolidColor(this.containerFillColor);
	}

	private function getSubHeadingFill():FillStyle {
		return SolidColor(this.subHeadingFillColor);
	}

	private function getTextFormat(align:TextFormatAlign = LEFT):TextFormat {
		return new TextFormat(this.fontName, this.fontSize, this.textColor, false, false, false, null, null, align);
	}

	private function getDisabledTextFormat(align:TextFormatAlign = LEFT):TextFormat {
		return new TextFormat(this.fontName, this.fontSize, this.disabledTextColor, false, false, false, null, null, align);
	}

	private function getSecondaryTextFormat(align:TextFormatAlign = LEFT):TextFormat {
		return new TextFormat(this.fontName, this.fontSize, this.secondaryTextColor, false, false, false, null, null, align);
	}

	private function getDangerTextFormat(align:TextFormatAlign = LEFT):TextFormat {
		return new TextFormat(this.fontName, this.fontSize, this.dangerTextColor, false, false, false, null, null, align);
	}

	private function getHeaderTextFormat(align:TextFormatAlign = LEFT):TextFormat {
		return new TextFormat(this.fontName, this.headerFontSize, this.textColor, false, false, false, null, null, align);
	}

	private function getDisabledHeaderTextFormat(align:TextFormatAlign = LEFT):TextFormat {
		return new TextFormat(this.fontName, this.headerFontSize, this.disabledTextColor, false, false, false, null, null, align);
	}

	private function getDetailTextFormat(align:TextFormatAlign = LEFT):TextFormat {
		return new TextFormat(this.fontName, this.detailFontSize, this.textColor, false, false, false, null, null, align);
	}

	private function getDisabledDetailTextFormat(align:TextFormatAlign = LEFT):TextFormat {
		return new TextFormat(this.fontName, this.detailFontSize, this.disabledTextColor, false, false, false, null, null, align);
	}

	private function getSecondaryDetailTextFormat(align:TextFormatAlign = LEFT):TextFormat {
		return new TextFormat(this.fontName, this.detailFontSize, this.secondaryTextColor, false, false, false, null, null, align);
	}

	private function getHeaderFill():FillStyle {
		return SolidColor(this.headerFillColor);
	}

	private function lighten(color:Int, offset:Int):Int {
		var r1 = (color >> 16) & 0xff;
		var g1 = (color >> 8) & 0xff;
		var b1 = color & 0xff;

		var r2 = (offset >> 16) & 0xff;
		var g2 = (offset >> 8) & 0xff;
		var b2 = offset & 0xff;

		r1 += r2;
		if (r1 > 0xff) {
			r1 = 0xff;
		}
		g1 += g2;
		if (g1 > 0xff) {
			g1 = 0xff;
		}
		b1 += b2;
		if (b1 > 0xff) {
			b1 = 0xff;
		}
		return (r1 << 16) + (g1 << 8) + b1;
	}

	private function darken(color:Int, offset:Int):Int {
		var r1 = (color >> 16) & 0xff;
		var g1 = (color >> 8) & 0xff;
		var b1 = color & 0xff;

		var r2 = (offset >> 16) & 0xff;
		var g2 = (offset >> 8) & 0xff;
		var b2 = offset & 0xff;

		r1 -= r2;
		if (r1 < 0) {
			r1 = 0;
		}
		g1 -= g2;
		if (g1 < 0) {
			g1 = 0;
		}
		b1 -= b2;
		if (b1 < 0) {
			b1 = 0;
		}
		return (r1 << 16) + (g1 << 8) + b1;
	}

	#if html5
	private function mediaQueryList_changeHandler(event:MediaQueryListEvent):Void {
		this.refreshFontSizes();
		this.refreshPaddings();
		StyleProviderEvent.dispatch(this.styleProvider, StyleProviderEvent.STYLES_CHANGE);
	}
	#end
}

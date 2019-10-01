/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes;

import feathers.style.IStyleProvider;
import feathers.style.IStyleObject;
import openfl.display.GradientType;
import feathers.events.FeathersEvent;
import openfl.events.Event;
import feathers.style.ClassVariantStyleProvider;
import openfl.text.TextFormat;
import feathers.graphics.LineStyle;
import feathers.graphics.FillStyle;
import feathers.style.ITheme;

/**
	@since 1.0.0
**/
class DefaultTheme implements ITheme {
	public function new(?themeColor:Int, ?darkThemeColor:Int) {
		this.customThemeColor = themeColor;
		this.customDarkThemeColor = darkThemeColor;
		this.refreshColors();
		this.refreshFonts();
		this.styleProvider = new ClassVariantStyleProvider();
		// there are no calls to setStyleFunction() in the theme by default.
		// instead, component classes must call setStyleFunction() to keep
		// unused components from being included in the final compiled output.
	}

	private var styleProvider:ClassVariantStyleProvider;

	public var darkMode(default, set):Bool = false;

	private function set_darkMode(value:Bool):Bool {
		if (this.darkMode == value) {
			return this.darkMode;
		}
		this.darkMode = value;
		this.refreshColors();
		this.styleProvider.dispatchEvent(new Event(Event.CHANGE));
		return this.darkMode;
	}

	private var customThemeColor:Null<Int>;
	private var customDarkThemeColor:Null<Int>;
	private var themeColor:Int;
	private var offsetThemeColor:Int;
	private var rootFillColor:Int;
	private var controlFillColor1:Int;
	private var controlFillColor2:Int;
	private var controlDisabledFillColor:Int;
	private var insetFillColor:Int;
	private var disabledInsetFillColor:Int;
	private var insetBorderColor:Int;
	private var activeFillBorderColor:Int;
	private var containerFillColor:Int;
	private var headerFillColor:Int;
	private var borderColor:Int;
	private var dividerColor:Int;
	private var textColor:Int;
	private var activeTextColor:Int;
	private var disabledTextColor:Int;
	private var fontName:String;
	private var fontSize:Int;
	private var headerFontSize:Int;
	private var detailFontSize:Int;

	public function getStyleProvider(target:IStyleObject):IStyleProvider {
		// use the same style provider for all objects
		return this.styleProvider;
	}

	public function dispose():Void {
		FeathersEvent.dispatch(this.styleProvider, Event.CLEAR);
	}

	private function refreshColors():Void {
		if (this.darkMode) {
			if (this.customDarkThemeColor != null) {
				this.themeColor = this.customDarkThemeColor;
			} else if (this.customThemeColor != null) {
				this.themeColor = this.customThemeColor;
			} else {
				this.themeColor = 0x3f6fff;
			}
			this.offsetThemeColor = this.darken(this.themeColor, 0x282828);
			this.rootFillColor = 0x383838;
			this.controlFillColor1 = 0x5f5f5f;
			this.controlFillColor2 = 0x4c4c4c;
			this.controlDisabledFillColor = 0x101010;
			this.insetFillColor = 0x181818;
			this.disabledInsetFillColor = 0x383838;
			this.insetBorderColor = 0x484848;
			this.activeFillBorderColor = 0x080808;
			this.containerFillColor = 0x383838;
			this.headerFillColor = 0x3f3f3f;
			this.borderColor = 0x080808;
			this.dividerColor = 0x282828;
			this.textColor = 0xe8e8e8;
			this.activeTextColor = 0xe8e8e8;
			this.disabledTextColor = 0x8f8f8f;
		} else // light
		{
			if (this.customThemeColor != null) {
				this.themeColor = this.customThemeColor;
			} else {
				this.themeColor = 0x3f6fff;
			}
			this.offsetThemeColor = this.lighten(this.themeColor, 0x1f1f1f);
			this.rootFillColor = 0xf8f8f8;
			this.controlFillColor1 = 0xffffff;
			this.controlFillColor2 = 0xe8e8e8;
			this.controlDisabledFillColor = 0xefefef;
			this.insetFillColor = 0xfcfcfc;
			this.disabledInsetFillColor = 0xf8f8f8;
			this.insetBorderColor = 0xcccccc;
			this.activeFillBorderColor = this.darken(this.themeColor, 0x2f2f2f);
			this.containerFillColor = 0xf8f8f8;
			this.headerFillColor = 0xececec;
			this.borderColor = 0xacacac;
			this.dividerColor = 0xdfdfdf;
			this.textColor = 0x1f1f1f;
			this.activeTextColor = 0xefefef;
			this.disabledTextColor = 0x9f9f9f;
		}
	}

	private function refreshFonts():Void {
		this.fontName = "_sans";
		this.refreshFontSizes();
	}

	private function refreshFontSizes():Void {
		this.fontSize = 14;
		this.headerFontSize = 18;
		this.detailFontSize = 12;
	}

	private function getThemeFill():FillStyle {
		return FillStyle.SolidColor(this.themeColor);
	}

	private function getButtonFill():FillStyle {
		return FillStyle.Gradient(GradientType.LINEAR, [this.controlFillColor1, this.controlFillColor2], [1.0, 1.0], [0, 0xff], Math.PI / 2);
	}

	private function getButtonDownFill():FillStyle {
		return FillStyle.Gradient(GradientType.LINEAR, [this.controlFillColor2, this.controlFillColor1], [1.0, 1.0], [0, 0xff], Math.PI / 2);
	}

	private function getButtonDisabledFill():FillStyle {
		return FillStyle.SolidColor(this.controlDisabledFillColor, 0.7);
	}

	private function getBorder(thickness:Float = 1.0):LineStyle {
		return LineStyle.SolidColor(thickness, this.borderColor);
	}

	private function getButtonBorder(thickness:Float = 1.0):LineStyle {
		return LineStyle.SolidColor(thickness, this.borderColor);
	}

	private function getInsetBorder(thickness:Float = 1.0):LineStyle {
		return LineStyle.SolidColor(thickness, this.insetBorderColor);
	}

	private function getThemeBorder(thickness:Float = 1.0):LineStyle {
		return LineStyle.SolidColor(thickness, this.themeColor);
	}

	private function getActiveFillBorder(thickness:Float = 1.0):LineStyle {
		return LineStyle.SolidColor(thickness, this.activeFillBorderColor);
	}

	private function getContainerBorder(thickness:Float = 1.0):LineStyle {
		return LineStyle.SolidColor(thickness, this.borderColor);
	}

	private function getDividerBorder(thickness:Float = 1.0):LineStyle {
		return LineStyle.SolidColor(thickness, this.dividerColor);
	}

	private function getInsetFill():FillStyle {
		return FillStyle.SolidColor(this.insetFillColor);
	}

	private function getDisabledInsetFill():FillStyle {
		return FillStyle.SolidColor(this.disabledInsetFillColor);
	}

	private function getActiveThemeFill():FillStyle {
		var colors = [this.themeColor, this.offsetThemeColor];
		if (!this.darkMode) {
			colors.reverse();
		}
		return FillStyle.Gradient(GradientType.LINEAR, colors, [1.0, 1.0], [0, 0xff], Math.PI / 2);
	}

	private function getReversedActiveThemeFill():FillStyle {
		var colors = [this.themeColor, this.offsetThemeColor];
		if (this.darkMode) {
			colors.reverse();
		}
		return FillStyle.Gradient(GradientType.LINEAR, colors, [1.0, 1.0], [0, 0xff], Math.PI / 2);
	}

	private function getRootFill():FillStyle {
		return FillStyle.SolidColor(this.rootFillColor);
	}

	private function getContainerFill():FillStyle {
		return FillStyle.SolidColor(this.containerFillColor);
	}

	private function getTextFormat():TextFormat {
		return new TextFormat(this.fontName, this.fontSize, this.textColor);
	}

	private function getDisabledTextFormat():TextFormat {
		return new TextFormat(this.fontName, this.fontSize, this.disabledTextColor);
	}

	private function getActiveTextFormat():TextFormat {
		return new TextFormat(this.fontName, this.fontSize, this.activeTextColor);
	}

	private function getHeaderTextFormat():TextFormat {
		return new TextFormat(this.fontName, this.headerFontSize, this.textColor);
	}

	private function getDisabledHeaderTextFormat():TextFormat {
		return new TextFormat(this.fontName, this.headerFontSize, this.disabledTextColor);
	}

	private function getDetailTextFormat():TextFormat {
		return new TextFormat(this.fontName, this.detailFontSize, this.textColor);
	}

	private function getDisabledDetailTextFormat():TextFormat {
		return new TextFormat(this.fontName, this.detailFontSize, this.disabledTextColor);
	}

	private function getHeaderFill():FillStyle {
		return FillStyle.SolidColor(this.headerFillColor);
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
}

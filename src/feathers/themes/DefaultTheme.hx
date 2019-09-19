/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes;

import openfl.display.CapsStyle;
import openfl.display.LineScaleMode;
import feathers.controls.BasicToggleButton;
import feathers.controls.TextInputState;
import feathers.controls.Panel;
import feathers.layout.VerticalAlign;
import feathers.layout.HorizontalLayout;
import feathers.controls.ToggleSwitch;
import openfl.display.Shape;
import feathers.controls.HProgressBar;
import feathers.events.FeathersEvent;
import feathers.style.IStyleObject;
import feathers.style.IStyleProvider;
import feathers.controls.ToggleButtonState;
import feathers.controls.LayoutGroup;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalListFixedRowLayout;
import feathers.controls.dataRenderers.ListBoxItemRenderer;
import feathers.controls.ListBox;
import feathers.style.ClassVariantStyleProvider;
import feathers.controls.BasicButton;
import feathers.skins.CircleSkin;
import feathers.controls.HSlider;
import feathers.controls.VSlider;
import feathers.controls.TextInput;
import feathers.controls.Label;
import feathers.controls.ButtonState;
import feathers.skins.RectangleSkin;
import feathers.skins.UnderlineSkin;
import feathers.controls.Button;
import feathers.controls.ToggleButton;
import openfl.events.Event;
import openfl.text.TextFormat;
import openfl.display.GradientType;
import feathers.graphics.LineStyle;
import feathers.graphics.FillStyle;
import feathers.style.ITheme;
import feathers.controls.Check;
import feathers.controls.Radio;
import feathers.controls.Application;
import feathers.controls.PopUpList;
import feathers.layout.RelativePosition;

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
		this.styleProvider.setStyleFunction(Application, null, this.setApplicationStyles);
		this.styleProvider.setStyleFunction(Button, null, this.setButtonStyles);
		this.styleProvider.setStyleFunction(Button, PopUpList.CHILD_VARIANT_BUTTON, this.setPopUpListButtonStyles);
		this.styleProvider.setStyleFunction(Check, null, this.setCheckStyles);
		this.styleProvider.setStyleFunction(Label, null, this.setLabelStyles);
		this.styleProvider.setStyleFunction(Label, Label.VARIANT_HEADING, this.setHeadingLabelStyles);
		this.styleProvider.setStyleFunction(Label, Label.VARIANT_DETAIL, this.setDetailLabelStyles);
		this.styleProvider.setStyleFunction(LayoutGroup, LayoutGroup.VARIANT_TOOL_BAR, this.setToolBarLayoutGroupStyles);
		this.styleProvider.setStyleFunction(ListBox, null, this.setListBoxStyles);
		this.styleProvider.setStyleFunction(ListBoxItemRenderer, null, this.setListBoxItemRendererStyles);
		this.styleProvider.setStyleFunction(HProgressBar, null, this.setHProgressBarStyles);
		this.styleProvider.setStyleFunction(Panel, null, this.setPanelStyles);
		this.styleProvider.setStyleFunction(Radio, null, this.setRadioStyles);
		this.styleProvider.setStyleFunction(HSlider, null, this.setHSliderStyles);
		this.styleProvider.setStyleFunction(VSlider, null, this.setVSliderStyles);
		this.styleProvider.setStyleFunction(TextInput, null, this.setTextInputStyles);
		this.styleProvider.setStyleFunction(ToggleButton, null, this.setToggleButtonStyles);
		this.styleProvider.setStyleFunction(ToggleSwitch, null, this.setToggleSwitchStyles);
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

	private function setApplicationStyles(app:Application):Void {
		if (app.backgroundSkin == null) {
			var skin = new RectangleSkin();
			skin.fill = getRootFill();
			app.backgroundSkin = skin;
		}
	}

	private function setButtonStyles(button:Button):Void {
		if (button.backgroundSkin == null) {
			var skin = new RectangleSkin();
			skin.fill = getButtonFill();
			skin.setFillForState(ButtonState.DOWN, getReversedActiveThemeFill());
			skin.setFillForState(ButtonState.DISABLED, getButtonDisabledFill());
			skin.border = getButtonBorder();
			skin.setBorderForState(ButtonState.DOWN, getActiveFillBorder());
			skin.cornerRadius = 6.0;
			button.backgroundSkin = skin;
		}

		if (button.textFormat == null) {
			button.textFormat = getTextFormat();
		}
		if (button.disabledTextFormat == null) {
			button.disabledTextFormat = getDisabledTextFormat();
		}

		if (button.getTextFormatForState(ButtonState.DOWN) == null) {
			button.setTextFormatForState(ButtonState.DOWN, getActiveTextFormat());
		}

		button.paddingTop = 4.0;
		button.paddingRight = 10.0;
		button.paddingBottom = 4.0;
		button.paddingLeft = 10.0;
		button.gap = 6.0;
	}

	private function setCheckStyles(check:Check):Void {
		if (check.textFormat == null) {
			check.textFormat = getTextFormat();
		}
		if (check.disabledTextFormat == null) {
			check.disabledTextFormat = getDisabledTextFormat();
		}

		var icon = new RectangleSkin();
		icon.width = 24.0;
		icon.height = 24.0;
		icon.minWidth = 24.0;
		icon.minHeight = 24.0;
		icon.border = getInsetBorder(2.0);
		icon.setBorderForState(ToggleButtonState.DOWN(), this.getThemeBorder(2.0));
		icon.fill = getInsetFill();
		icon.disabledFill = this.getDisabledInsetFill();
		check.icon = icon;

		var selectedIcon = new RectangleSkin();
		selectedIcon.width = 24.0;
		selectedIcon.height = 24.0;
		selectedIcon.minWidth = 24.0;
		selectedIcon.minHeight = 24.0;
		selectedIcon.border = getInsetBorder(2.0);
		selectedIcon.setBorderForState(ToggleButtonState.DOWN(), this.getThemeBorder(2.0));
		selectedIcon.fill = getInsetFill();
		selectedIcon.disabledFill = this.getDisabledInsetFill();

		var checkMark = new Shape();
		checkMark.graphics.beginFill(this.themeColor);
		checkMark.graphics.drawRect(-0.0, -10.0, 4.0, 18.0);
		checkMark.graphics.drawRect(-6.0, 4.0, 6.0, 4.0);
		checkMark.graphics.endFill();
		checkMark.rotation = 45.0;
		checkMark.x = 12.0;
		checkMark.y = 12.0;
		selectedIcon.addChild(checkMark);

		check.selectedIcon = selectedIcon;

		var disabledAndSelectedIcon = new RectangleSkin();
		disabledAndSelectedIcon.width = 24.0;
		disabledAndSelectedIcon.height = 24.0;
		disabledAndSelectedIcon.minWidth = 24.0;
		disabledAndSelectedIcon.minHeight = 24.0;
		disabledAndSelectedIcon.border = getInsetBorder(2.0);
		disabledAndSelectedIcon.fill = getDisabledInsetFill();

		var disabledCheckMark = new Shape();
		disabledCheckMark.graphics.beginFill(this.disabledTextColor);
		disabledCheckMark.graphics.drawRect(-0.0, -10.0, 4.0, 18.0);
		disabledCheckMark.graphics.endFill();
		disabledCheckMark.graphics.beginFill(this.disabledTextColor);
		disabledCheckMark.graphics.drawRect(-6.0, 4.0, 6.0, 4.0);
		disabledCheckMark.graphics.endFill();
		disabledCheckMark.rotation = 45.0;
		disabledCheckMark.x = 12.0;
		disabledCheckMark.y = 12.0;
		disabledAndSelectedIcon.addChild(disabledCheckMark);

		check.setIconForState(ToggleButtonState.DISABLED(true), disabledAndSelectedIcon);

		if (check.gap == null) {
			check.gap = 6.0;
		}
	}

	private function setLabelStyles(label:Label):Void {
		if (label.textFormat == null) {
			label.textFormat = getTextFormat();
		}
		if (label.disabledTextFormat == null) {
			label.disabledTextFormat = getDisabledTextFormat();
		}
	}

	private function setHeadingLabelStyles(label:Label):Void {
		if (label.textFormat == null) {
			label.textFormat = getHeaderTextFormat();
		}
		if (label.disabledTextFormat == null) {
			label.disabledTextFormat = getDisabledHeaderTextFormat();
		}
	}

	private function setDetailLabelStyles(label:Label):Void {
		if (label.textFormat == null) {
			label.textFormat = getDetailTextFormat();
		}
		if (label.disabledTextFormat == null) {
			label.disabledTextFormat = getDisabledDetailTextFormat();
		}
	}

	private function setToolBarLayoutGroupStyles(group:LayoutGroup):Void {
		if (group.backgroundSkin == null) {
			var backgroundSkin = new RectangleSkin();
			backgroundSkin.fill = getHeaderFill();
			backgroundSkin.width = 44.0;
			backgroundSkin.height = 44.0;
			backgroundSkin.minHeight = 44.0;
			group.backgroundSkin = backgroundSkin;
		}
		if (group.layout == null) {
			var layout = new HorizontalLayout();
			layout.horizontalAlign = HorizontalAlign.LEFT;
			layout.verticalAlign = VerticalAlign.MIDDLE;
			layout.paddingTop = 4.0;
			layout.paddingRight = 10.0;
			layout.paddingBottom = 4.0;
			layout.paddingLeft = 10.0;
			layout.gap = 4.0;
			group.layout = layout;
		}
	}

	private function setListBoxStyles(listBox:ListBox):Void {
		if (listBox.layout == null) {
			listBox.layout = new VerticalListFixedRowLayout();
		}

		if (listBox.backgroundSkin == null) {
			var backgroundSkin = new RectangleSkin();
			backgroundSkin.fill = getContainerFill();
			// backgroundSkin.border = getContainerBorder();
			backgroundSkin.width = 160.0;
			backgroundSkin.height = 160.0;
			listBox.backgroundSkin = backgroundSkin;
		}
	}

	private function setListBoxItemRendererStyles(itemRenderer:ListBoxItemRenderer):Void {
		if (itemRenderer.backgroundSkin == null) {
			var skin = new UnderlineSkin();
			skin.fill = getContainerFill();
			skin.border = getDividerBorder();
			skin.setFillForState(ButtonState.DOWN, getActiveThemeFill());
			skin.width = 44.0;
			skin.height = 44.0;
			skin.minWidth = 44.0;
			skin.minHeight = 44.0;
			itemRenderer.backgroundSkin = skin;
		}

		if (itemRenderer.textFormat == null) {
			itemRenderer.textFormat = getTextFormat();
		}
		if (itemRenderer.disabledTextFormat == null) {
			itemRenderer.disabledTextFormat = getDisabledTextFormat();
		}
		if (itemRenderer.getTextFormatForState(ButtonState.DOWN) == null) {
			itemRenderer.setTextFormatForState(ButtonState.DOWN, getActiveTextFormat());
		}

		itemRenderer.paddingTop = 4.0;
		itemRenderer.paddingRight = 10.0;
		itemRenderer.paddingBottom = 4.0;
		itemRenderer.paddingLeft = 10.0;

		itemRenderer.horizontalAlign = HorizontalAlign.LEFT;
	}

	private function setHProgressBarStyles(progress:HProgressBar):Void {
		if (progress.fillSkin == null) {
			var fillSkin = new RectangleSkin();
			fillSkin.fill = getActiveThemeFill();
			// fillSkin.disabledFill = getButtonDisabledFill();
			fillSkin.border = getActiveFillBorder();
			fillSkin.cornerRadius = 6.0;
			fillSkin.width = 8.0;
			fillSkin.height = 8.0;
			progress.fillSkin = fillSkin;
		}

		if (progress.backgroundSkin == null) {
			var backgroundSkin = new RectangleSkin();
			backgroundSkin.fill = getInsetFill();
			backgroundSkin.border = getInsetBorder();
			backgroundSkin.cornerRadius = 6.0;
			backgroundSkin.width = 200.0;
			backgroundSkin.height = 8.0;
			progress.backgroundSkin = backgroundSkin;
		}
	}

	private function setPanelStyles(panel:Panel):Void {
		if (panel.backgroundSkin == null) {
			var backgroundSkin = new RectangleSkin();
			backgroundSkin.fill = getContainerFill();
			panel.backgroundSkin = backgroundSkin;
		}
	}

	private function setPopUpListButtonStyles(button:Button):Void {
		this.setButtonStyles(button);

		button.horizontalAlign = HorizontalAlign.LEFT;
		button.gap = Math.POSITIVE_INFINITY;

		var icon:Shape = new Shape();
		icon.graphics.beginFill(this.textColor);
		icon.graphics.moveTo(0.0, 0.0);
		icon.graphics.lineTo(4.0, 4.0);
		icon.graphics.lineTo(8.0, 0.0);
		button.icon = icon;

		var downIcon:Shape = new Shape();
		downIcon.graphics.beginFill(this.activeTextColor);
		downIcon.graphics.moveTo(0.0, 0.0);
		downIcon.graphics.lineTo(4.0, 4.0);
		downIcon.graphics.lineTo(8.0, 0.0);
		button.setIconForState(ButtonState.DOWN, downIcon);

		button.iconPosition = RelativePosition.RIGHT;
	}

	private function setRadioStyles(radio:Radio):Void {
		if (radio.textFormat == null) {
			radio.textFormat = getTextFormat();
		}
		if (radio.disabledTextFormat == null) {
			radio.disabledTextFormat = getDisabledTextFormat();
		}

		var icon = new CircleSkin();
		icon.width = 24.0;
		icon.height = 24.0;
		icon.minWidth = 24.0;
		icon.minHeight = 24.0;
		icon.border = getInsetBorder(2.0);
		icon.setBorderForState(ToggleButtonState.DOWN(), this.getThemeBorder(2.0));
		icon.fill = getInsetFill();
		icon.disabledFill = this.getDisabledInsetFill();
		radio.icon = icon;

		var selectedIcon = new CircleSkin();
		selectedIcon.width = 24.0;
		selectedIcon.height = 24.0;
		selectedIcon.minWidth = 24.0;
		selectedIcon.minHeight = 24.0;
		selectedIcon.border = getInsetBorder(2.0);
		selectedIcon.setBorderForState(ToggleButtonState.DOWN(true), this.getThemeBorder(2.0));
		selectedIcon.fill = getInsetFill();
		selectedIcon.disabledFill = this.getDisabledInsetFill();

		var symbol = new Shape();
		symbol.graphics.beginFill(this.themeColor);
		symbol.graphics.drawCircle(12.0, 12.0, 6.0);
		symbol.graphics.endFill();
		selectedIcon.addChild(symbol);

		radio.selectedIcon = selectedIcon;

		var disabledAndSelectedIcon = new CircleSkin();
		disabledAndSelectedIcon.width = 24.0;
		disabledAndSelectedIcon.height = 24.0;
		disabledAndSelectedIcon.minWidth = 24.0;
		disabledAndSelectedIcon.minHeight = 24.0;
		disabledAndSelectedIcon.border = getInsetBorder(2.0);
		disabledAndSelectedIcon.fill = getDisabledInsetFill();

		var disabledSymbol = new Shape();
		disabledSymbol.graphics.beginFill(this.disabledTextColor);
		disabledSymbol.graphics.drawCircle(12.0, 12.0, 6.0);
		disabledSymbol.graphics.endFill();
		disabledAndSelectedIcon.addChild(disabledSymbol);

		radio.setIconForState(ToggleButtonState.DISABLED(true), disabledAndSelectedIcon);

		if (radio.gap == null) {
			radio.gap = 6.0;
		}
	}

	private function setHSliderStyles(slider:HSlider):Void {
		if (slider.thumbSkin == null) {
			var thumbSkin = new CircleSkin();
			thumbSkin.fill = getButtonFill();
			thumbSkin.border = getButtonBorder();
			thumbSkin.setFillForState(ButtonState.DOWN, getButtonDownFill());
			thumbSkin.setFillForState(ButtonState.DISABLED, getButtonDisabledFill());
			thumbSkin.width = 24.0;
			thumbSkin.height = 24.0;
			var thumb:BasicButton = new BasicButton();
			thumb.keepDownStateOnRollOut = true;
			thumb.backgroundSkin = thumbSkin;
			slider.thumbSkin = thumb;
		}

		if (slider.trackSkin == null) {
			var trackSkin = new RectangleSkin();
			trackSkin.fill = getActiveThemeFill();
			trackSkin.border = getActiveFillBorder();
			trackSkin.cornerRadius = 6.0;
			trackSkin.width = 100.0;
			trackSkin.height = 8.0;
			slider.trackSkin = trackSkin;

			// if the track skin is already styled, don't style the secondary
			// track skin with its default either
			if (slider.secondaryTrackSkin == null) {
				var secondaryTrackSkin = new RectangleSkin();
				secondaryTrackSkin.fill = getInsetFill();
				secondaryTrackSkin.border = getInsetBorder();
				secondaryTrackSkin.cornerRadius = 6.0;
				secondaryTrackSkin.width = 100.0;
				secondaryTrackSkin.height = 8.0;
				slider.secondaryTrackSkin = secondaryTrackSkin;
			}
		}
	}

	private function setVSliderStyles(slider:VSlider):Void {
		if (slider.thumbSkin == null) {
			var thumbSkin = new CircleSkin();
			thumbSkin.fill = getButtonFill();
			thumbSkin.border = getButtonBorder();
			thumbSkin.setFillForState(ButtonState.DOWN, getButtonDownFill());
			thumbSkin.setFillForState(ButtonState.DISABLED, getButtonDisabledFill());
			thumbSkin.width = 24.0;
			thumbSkin.height = 24.0;
			var thumb:BasicButton = new BasicButton();
			thumb.keepDownStateOnRollOut = true;
			thumb.backgroundSkin = thumbSkin;
			slider.thumbSkin = thumb;
		}

		if (slider.trackSkin == null) {
			var trackSkin = new RectangleSkin();
			trackSkin.fill = getActiveThemeFill();
			trackSkin.border = getActiveFillBorder();
			trackSkin.cornerRadius = 6.0;
			trackSkin.width = 8.0;
			trackSkin.height = 100.0;
			slider.trackSkin = trackSkin;

			// if the track skin is already styled, don't style the secondary
			// track skin with its default either
			if (slider.secondaryTrackSkin == null) {
				var secondaryTrackSkin = new RectangleSkin();
				secondaryTrackSkin.fill = getInsetFill();
				secondaryTrackSkin.border = getInsetBorder();
				secondaryTrackSkin.cornerRadius = 6.0;
				secondaryTrackSkin.width = 8.0;
				secondaryTrackSkin.height = 100.0;
				slider.secondaryTrackSkin = secondaryTrackSkin;
			}
		}
	}

	private function setTextInputStyles(input:TextInput):Void {
		if (input.backgroundSkin == null) {
			var inputSkin = new RectangleSkin();
			inputSkin.cornerRadius = 6.0;
			inputSkin.width = 160.0;
			inputSkin.fill = getInsetFill();
			inputSkin.border = getInsetBorder();
			inputSkin.setBorderForState(TextInputState.FOCUSED, getThemeBorder());
			input.backgroundSkin = inputSkin;
		}

		if (input.textFormat == null) {
			input.textFormat = getTextFormat();
		}
		if (input.disabledTextFormat == null) {
			input.disabledTextFormat = getDisabledTextFormat();
		}

		input.paddingTop = 6.0;
		input.paddingRight = 10.0;
		input.paddingBottom = 6.0;
		input.paddingLeft = 10.0;
	}

	private function setToggleButtonStyles(button:ToggleButton):Void {
		if (button.backgroundSkin == null) {
			var skin = new RectangleSkin();
			skin.fill = getButtonFill();
			skin.selectedFill = getThemeFill();
			skin.setFillForState(ToggleButtonState.DOWN(), getReversedActiveThemeFill());
			skin.setFillForState(ToggleButtonState.DISABLED(), getButtonDisabledFill());
			skin.setFillForState(ToggleButtonState.DOWN(), getReversedActiveThemeFill());
			skin.border = getButtonBorder();
			skin.selectedBorder = getActiveFillBorder();
			skin.setBorderForState(ButtonState.DOWN, getActiveFillBorder());
			skin.cornerRadius = 6.0;
			button.backgroundSkin = skin;
		}

		if (button.textFormat == null) {
			button.textFormat = getTextFormat();
		}
		if (button.disabledTextFormat == null) {
			button.disabledTextFormat = getDisabledTextFormat();
		}
		if (button.selectedTextFormat == null) {
			button.selectedTextFormat = getActiveTextFormat();
		}

		if (button.getTextFormatForState(ToggleButtonState.DOWN()) == null) {
			button.setTextFormatForState(ToggleButtonState.DOWN(), getActiveTextFormat());
		}

		button.paddingTop = 4.0;
		button.paddingRight = 10.0;
		button.paddingBottom = 4.0;
		button.paddingLeft = 10.0;
		button.gap = 6.0;
	}

	private function setToggleSwitchStyles(toggle:ToggleSwitch):Void {
		if (toggle.trackSkin == null) {
			var trackSkin = new RectangleSkin();
			trackSkin.width = 64.0;
			trackSkin.height = 32.0;
			trackSkin.minWidth = 64.0;
			trackSkin.minHeight = 32.0;
			trackSkin.cornerRadius = 32.0;
			trackSkin.fill = getInsetFill();
			trackSkin.border = getInsetBorder();
			trackSkin.selectedFill = getReversedActiveThemeFill();
			trackSkin.selectedBorder = getActiveFillBorder();

			var track:BasicToggleButton = new BasicToggleButton();
			track.toggleable = false;
			track.keepDownStateOnRollOut = true;
			track.backgroundSkin = trackSkin;
			toggle.trackSkin = track;
		}
		if (toggle.thumbSkin == null) {
			var thumbSkin = new CircleSkin();
			thumbSkin.width = 32.0;
			thumbSkin.height = 32.0;
			thumbSkin.minWidth = 32.0;
			thumbSkin.minHeight = 32.0;
			thumbSkin.fill = getButtonFill();
			thumbSkin.border = getBorder();
			thumbSkin.selectedBorder = getActiveFillBorder();

			var thumb:BasicToggleButton = new BasicToggleButton();
			thumb.toggleable = false;
			thumb.keepDownStateOnRollOut = true;
			thumb.backgroundSkin = thumbSkin;
			toggle.thumbSkin = thumb;
		}
	}
}

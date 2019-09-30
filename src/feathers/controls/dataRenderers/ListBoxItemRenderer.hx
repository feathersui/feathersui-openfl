/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.dataRenderers;

import feathers.skins.UnderlineSkin;
import feathers.layout.HorizontalAlign;
import feathers.style.Theme;
import feathers.themes.DefaultTheme;
import feathers.core.InvalidationFlag;

@:access(feathers.themes.DefaultTheme)
@:styleContext
class ListBoxItemRenderer extends Button implements IListBoxItemRenderer {
	public function new() {
		var theme = Std.downcast(Theme.fallbackTheme, DefaultTheme);
		if (theme != null && theme.styleProvider.getStyleFunction(ListBoxItemRenderer, null) == null) {
			theme.styleProvider.setStyleFunction(ListBoxItemRenderer, null, setListBoxItemRendererStyles);
		}
		super();
	}

	public var data(default, set):Dynamic;

	private function set_data(value:Dynamic):Dynamic {
		if (this.data == value) {
			return this.data;
		}
		this.data = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this.data;
	}

	public var index(default, set):Int;

	private function set_index(value:Int):Int {
		if (this.index == value) {
			return this.index;
		}
		this.index = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this.index;
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);

		if (dataInvalid) {
			if (this.data == null) {
				this.text = null;
			} else {
				this.text = this.data.text;
			}
		}

		super.update();
	}

	private static function setListBoxItemRendererStyles(itemRenderer:ListBoxItemRenderer):Void {
		var defaultTheme:DefaultTheme = Std.downcast(Theme.fallbackTheme, DefaultTheme);
		if (defaultTheme == null) {
			return;
		}

		if (itemRenderer.backgroundSkin == null) {
			var skin = new UnderlineSkin();
			skin.fill = defaultTheme.getContainerFill();
			skin.border = defaultTheme.getDividerBorder();
			skin.setFillForState(ButtonState.DOWN, defaultTheme.getActiveThemeFill());
			skin.width = 44.0;
			skin.height = 44.0;
			skin.minWidth = 44.0;
			skin.minHeight = 44.0;
			itemRenderer.backgroundSkin = skin;
		}

		if (itemRenderer.textFormat == null) {
			itemRenderer.textFormat = defaultTheme.getTextFormat();
		}
		if (itemRenderer.disabledTextFormat == null) {
			itemRenderer.disabledTextFormat = defaultTheme.getDisabledTextFormat();
		}
		if (itemRenderer.getTextFormatForState(ButtonState.DOWN) == null) {
			itemRenderer.setTextFormatForState(ButtonState.DOWN, defaultTheme.getActiveTextFormat());
		}

		itemRenderer.paddingTop = 4.0;
		itemRenderer.paddingRight = 10.0;
		itemRenderer.paddingBottom = 4.0;
		itemRenderer.paddingLeft = 10.0;

		itemRenderer.horizontalAlign = HorizontalAlign.LEFT;
	}
}

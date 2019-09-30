/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import openfl.display.Shape;
import feathers.skins.CircleSkin;
import feathers.style.Theme;
import feathers.themes.DefaultTheme;
import openfl.events.Event;
import openfl.errors.IllegalOperationError;
import feathers.core.ToggleGroup;

/**
	@since 1.0.0
**/
@:access(feathers.themes.DefaultTheme)
@:styleContext
class Radio extends ToggleButton implements IGroupedToggle {
	public static final defaultRadioGroup:ToggleGroup = new ToggleGroup();

	public function new() {
		var theme = Std.downcast(Theme.fallbackTheme, DefaultTheme);
		if (theme != null && theme.styleProvider.getStyleFunction(Radio, null) == null) {
			theme.styleProvider.setStyleFunction(Radio, null, setRadioStyles);
		}
		super();
		super.toggleable = true;
		this.addEventListener(Event.ADDED_TO_STAGE, radio_addedToStageHandler);
	}

	override private function set_toggleable(value:Bool):Bool {
		throw new IllegalOperationError("Radio toggleable must always be true");
	}

	public var toggleGroup(default, set):ToggleGroup = null;

	private function set_toggleGroup(value:ToggleGroup):ToggleGroup {
		if (this.toggleGroup == value) {
			return this.toggleGroup;
		}
		// a null toggle group will automatically add it to
		// defaultRadioGroup. however, if toggleGroup is already
		// defaultRadioGroup, then we really want to use null because
		// otherwise we'd remove the radio from defaultRadioGroup and then
		// immediately add it back because ToggleGroup sets the toggleGroup
		// property to null when removing an item.
		if (value == null && this.toggleGroup != defaultRadioGroup && this.stage != null) {
			value = defaultRadioGroup;
		}
		if (this.toggleGroup != null && this.toggleGroup.hasItem(this)) {
			this.toggleGroup.removeItem(this);
		}
		this.toggleGroup = value;
		if (this.toggleGroup != null && !this.toggleGroup.hasItem(this)) {
			this.toggleGroup.addItem(this);
		}
		return this.toggleGroup;
	}

	private function radio_addedToStageHandler(event:Event):Void {
		if (this.toggleGroup == null) {
			this.toggleGroup = defaultRadioGroup;
		}
		this.addEventListener(Event.REMOVED_FROM_STAGE, radio_removedFromStageHandler);
	}

	private function radio_removedFromStageHandler(event:Event):Void {
		this.removeEventListener(Event.REMOVED_FROM_STAGE, radio_removedFromStageHandler);
		if (this.toggleGroup == defaultRadioGroup) {
			this.toggleGroup.removeItem(this);
		}
	}

	private static function setRadioStyles(radio:Radio):Void {
		var defaultTheme:DefaultTheme = Std.downcast(Theme.fallbackTheme, DefaultTheme);
		if (defaultTheme == null) {
			return;
		}

		if (radio.textFormat == null) {
			radio.textFormat = defaultTheme.getTextFormat();
		}
		if (radio.disabledTextFormat == null) {
			radio.disabledTextFormat = defaultTheme.getDisabledTextFormat();
		}

		var icon = new CircleSkin();
		icon.width = 24.0;
		icon.height = 24.0;
		icon.minWidth = 24.0;
		icon.minHeight = 24.0;
		icon.border = defaultTheme.getInsetBorder(2.0);
		icon.setBorderForState(ToggleButtonState.DOWN(false), defaultTheme.getThemeBorder(2.0));
		icon.fill = defaultTheme.getInsetFill();
		icon.disabledFill = defaultTheme.getDisabledInsetFill();
		radio.icon = icon;

		var selectedIcon = new CircleSkin();
		selectedIcon.width = 24.0;
		selectedIcon.height = 24.0;
		selectedIcon.minWidth = 24.0;
		selectedIcon.minHeight = 24.0;
		selectedIcon.border = defaultTheme.getInsetBorder(2.0);
		selectedIcon.setBorderForState(ToggleButtonState.DOWN(true), defaultTheme.getThemeBorder(2.0));
		selectedIcon.fill = defaultTheme.getInsetFill();
		selectedIcon.disabledFill = defaultTheme.getDisabledInsetFill();

		var symbol = new Shape();
		symbol.graphics.beginFill(defaultTheme.themeColor);
		symbol.graphics.drawCircle(12.0, 12.0, 6.0);
		symbol.graphics.endFill();
		selectedIcon.addChild(symbol);

		radio.selectedIcon = selectedIcon;

		var disabledAndSelectedIcon = new CircleSkin();
		disabledAndSelectedIcon.width = 24.0;
		disabledAndSelectedIcon.height = 24.0;
		disabledAndSelectedIcon.minWidth = 24.0;
		disabledAndSelectedIcon.minHeight = 24.0;
		disabledAndSelectedIcon.border = defaultTheme.getInsetBorder(2.0);
		disabledAndSelectedIcon.fill = defaultTheme.getDisabledInsetFill();

		var disabledSymbol = new Shape();
		disabledSymbol.graphics.beginFill(defaultTheme.disabledTextColor);
		disabledSymbol.graphics.drawCircle(12.0, 12.0, 6.0);
		disabledSymbol.graphics.endFill();
		disabledAndSelectedIcon.addChild(disabledSymbol);

		radio.setIconForState(ToggleButtonState.DISABLED(true), disabledAndSelectedIcon);

		if (radio.gap == null) {
			radio.gap = 6.0;
		}
	}
}

/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.themes.steel.components.SteelRadioStyles;
import openfl.events.Event;
import openfl.errors.IllegalOperationError;
import feathers.core.ToggleGroup;

/**
	@since 1.0.0
**/
@:styleContext
class Radio extends ToggleButton implements IGroupedToggle {
	public static final defaultRadioGroup:ToggleGroup = new ToggleGroup();

	public function new() {
		initializeRadioTheme();

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

	private function initializeRadioTheme():Void {
		SteelRadioStyles.initialize();
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
}

/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.dataRenderers;

import feathers.events.TriggerEvent;
import feathers.themes.steel.components.SteelItemRendererStyles;

/**
	A generic renderer for UI components that display data collections.

	@since 1.0.0
**/
@:styleContext
class ItemRenderer extends ToggleButton {
	/**
		Creates a new `ItemRenderer` object.

		@since 1.0.0
	**/
	public function new() {
		initializeItemRendererTheme();

		super();
	}

	private function initializeItemRendererTheme():Void {
		SteelItemRendererStyles.initialize();
	}

	override private function basicToggleButton_triggerHandler(event:TriggerEvent):Void {
		if (!this.enabled) {
			event.stopImmediatePropagation();
			return;
		}
		if (!this.toggleable || this.selected) {
			return;
		}
		this.selected = !this.selected;
	}
}

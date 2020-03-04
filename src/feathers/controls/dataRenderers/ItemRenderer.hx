/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.dataRenderers;

import feathers.events.TriggerEvent;

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
		super();
		// selection will be controlled by the owning data container
		this.toggleable = false;
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

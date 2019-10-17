/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.dataRenderers;

import openfl.events.Event;
import feathers.themes.steel.components.SteelItemRendererStyles;

@:styleContext
class ItemRenderer extends ToggleButton {
	public function new() {
		initializeItemRendererTheme();

		super();
	}

	private function initializeItemRendererTheme():Void {
		SteelItemRendererStyles.initialize();
	}

	override private function basicToggleButton_triggeredHandler(event:Event):Void {
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

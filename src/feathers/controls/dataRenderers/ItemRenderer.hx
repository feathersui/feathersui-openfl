/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.dataRenderers;

import feathers.layout.HorizontalAlign;
import feathers.themes.steel.components.SteelItemRendererStyles;
import feathers.core.InvalidationFlag;

@:styleContext
class ItemRenderer extends Button implements IDataRenderer {
	public function new() {
		initializeItemRendererTheme();

		super();
	}

	@:isVar
	public var data(get, set):Dynamic;

	private function get_data():Dynamic {
		return this.data;
	}

	private function set_data(value:Dynamic):Dynamic {
		if (this.data == value) {
			return this.data;
		}
		this.data = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this.data;
	}

	private function initializeItemRendererTheme():Void {
		SteelItemRendererStyles.initialize();
	}
}

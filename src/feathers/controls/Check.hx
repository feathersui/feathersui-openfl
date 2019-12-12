/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.themes.steel.components.SteelCheckStyles;

/**

	@see [Tutorial: How to use the Check component](https://feathersui.com/learn/haxe-openfl/check/)
	@see `feathers.controls.ToggleSwitch`

	@since 1.0.0
**/
@:styleContext
class Check extends ToggleButton {
	/**
		Creates a new `Check` object.

		@since 1.0.0
	**/
	public function new() {
		initializeCheckTheme();

		super();
	}

	private function initializeCheckTheme():Void {
		SteelCheckStyles.initialize();
	}
}

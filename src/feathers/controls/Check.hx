/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import openfl.events.Event;

/**
	A toggle control that contains a label and a box that may be checked (or
	unchecked) to indicate selection.

	In the following example, a check is created and selected, and a listener
	for `Event.CHANGE` is added:

	```haxe
	var check = new Check();
	check.text = "Pick Me!";
	check.selected = true;
	check.addEventListener(Event.CHANGE, check_changeHandler);
	this.addChild(check);
	```

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
	public function new(?text:String, selected:Bool = false, ?changeListener:(Event) -> Void) {
		initializeCheckTheme();

		super(text, selected, changeListener);
	}

	private function initializeCheckTheme():Void {
		#if !feathersui_disable_default_theme
		feathers.themes.steel.components.SteelCheckStyles.initialize();
		#end
	}
}

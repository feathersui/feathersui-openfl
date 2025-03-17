/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.skins;

import feathers.controls.ButtonState;
import openfl.display.DisplayObject;

/**
	A variation of `MultiSkin` that declares fields for the states defined in
	`feathers.controls.ButtonState`.

	@see `feathers.controls.Button`

	@since 1.3.0
**/
class ButtonMultiSkin extends MultiSkin {
	/**
		Creates a new `ButtonMultiSkin` object.

		@since 1.3.0
	**/
	public function new(defaultView:DisplayObject) {
		super(defaultView);
	}

	/**
		The view for `feathers.controls.ButtonState.UP`.

		@since 1.3.0
	**/
	public var upView(get, set):DisplayObject;

	private function get_upView():DisplayObject {
		return this.getViewForState(ButtonState.UP);
	}

	private function set_upView(value:DisplayObject):DisplayObject {
		this.setViewForState(ButtonState.UP, value);
		return value;
	}

	/**
		The view for `feathers.controls.ButtonState.HOVER`.

		@since 1.3.0
	**/
	public var hoverView(get, set):DisplayObject;

	private function get_hoverView():DisplayObject {
		return this.getViewForState(ButtonState.HOVER);
	}

	private function set_hoverView(value:DisplayObject):DisplayObject {
		this.setViewForState(ButtonState.HOVER, value);
		return value;
	}

	/**
		The view for `feathers.controls.ButtonState.DOWN`.

		@since 1.3.0
	**/
	public var downView(get, set):DisplayObject;

	private function get_downView():DisplayObject {
		return this.getViewForState(ButtonState.DOWN);
	}

	private function set_downView(value:DisplayObject):DisplayObject {
		this.setViewForState(ButtonState.DOWN, value);
		return value;
	}
}

/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.skins;

import feathers.controls.ToggleButtonState;
import openfl.display.DisplayObject;

/**
	A variation of `MultiSkin` that declares fields for the states defined in
	`feathers.controls.ToggleButtonState`.

	@see `feathers.controls.ToggleButton`
	@see `feathers.controls.dataRenderers.ItemRenderer`
**/
class ToggleButtonMultiSkin extends MultiSkin {
	/**
		Creates a new `ToggleButtonMultiSkin` object.

		@since 1.3.0
	**/
	public function new(defaultView:DisplayObject) {
		super(defaultView);
	}

	/**
		The view for `feathers.controls.ToggleButtonState.UP(false)`.

		@since 1.3.0
	**/
	public var upView(get, set):DisplayObject;

	private function get_upView():DisplayObject {
		return this.getViewForState(ToggleButtonState.UP(false));
	}

	private function set_upView(value:DisplayObject):DisplayObject {
		this.setViewForState(ToggleButtonState.UP(false), value);
		return value;
	}

	/**
		The view for `feathers.controls.ToggleButtonState.HOVER(false)`.

		@since 1.3.0
	**/
	public var hoverView(get, set):DisplayObject;

	private function get_hoverView():DisplayObject {
		return this.getViewForState(ToggleButtonState.HOVER(false));
	}

	private function set_hoverView(value:DisplayObject):DisplayObject {
		this.setViewForState(ToggleButtonState.HOVER(false), value);
		return value;
	}

	/**
		The view for `feathers.controls.ToggleButtonState.DOWN(false)`.

		@since 1.3.0
	**/
	public var downView(get, set):DisplayObject;

	private function get_downView():DisplayObject {
		return this.getViewForState(ToggleButtonState.DOWN(false));
	}

	private function set_downView(value:DisplayObject):DisplayObject {
		this.setViewForState(ToggleButtonState.DOWN(false), value);
		return value;
	}

	/**
		The view for `feathers.controls.ToggleButtonState.UP(true)`.

		@since 1.3.0
	**/
	public var selectedUpView(get, set):DisplayObject;

	private function get_selectedUpView():DisplayObject {
		return this.getViewForState(ToggleButtonState.UP(true));
	}

	private function set_selectedUpView(value:DisplayObject):DisplayObject {
		this.setViewForState(ToggleButtonState.UP(true), value);
		return value;
	}

	/**
		The view for `feathers.controls.ToggleButtonState.HOVER(true)`.

		@since 1.3.0
	**/
	public var selectedHoverView(get, set):DisplayObject;

	private function get_selectedHoverView():DisplayObject {
		return this.getViewForState(ToggleButtonState.HOVER(true));
	}

	private function set_selectedHoverView(value:DisplayObject):DisplayObject {
		this.setViewForState(ToggleButtonState.HOVER(true), value);
		return value;
	}

	/**
		The view for `feathers.controls.ToggleButtonState.DOWN(true)`.

		@since 1.3.0
	**/
	public var selectedDownView(get, set):DisplayObject;

	private function get_selectedDownView():DisplayObject {
		return this.getViewForState(ToggleButtonState.DOWN(true));
	}

	private function set_selectedDownView(value:DisplayObject):DisplayObject {
		this.setViewForState(ToggleButtonState.DOWN(true), value);
		return value;
	}

	/**
		The view for `feathers.controls.ToggleButtonState.DISABLED(true)`.

		@since 1.3.0
	**/
	public var selectedDisabledView(get, set):DisplayObject;

	private function get_selectedDisabledView():DisplayObject {
		return this.getViewForState(ToggleButtonState.DISABLED(true));
	}

	private function set_selectedDisabledView(value:DisplayObject):DisplayObject {
		this.setViewForState(ToggleButtonState.DISABLED(true), value);
		return value;
	}
}

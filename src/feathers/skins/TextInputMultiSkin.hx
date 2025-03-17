/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.skins;

import feathers.controls.TextInputState;
import openfl.display.DisplayObject;

/**
	A variation of `MultiSkin` that declares fields for the states defined in
	`feathers.controls.TextInputState`.

	@see `feathers.controls.TextArea`
	@see `feathers.controls.TextInput`

	@since 1.3.0
**/
class TextInputMultiSkin extends MultiSkin {
	/**
		Creates a new `TextInputMultiSkin` object.

		@since 1.3.0
	**/
	public function new(defaultView:DisplayObject) {
		super(defaultView);
	}

	/**
		The view for `feathers.controls.TextInputState.ENABLED`.

		@since 1.3.0
	**/
	public var enabledView(get, set):DisplayObject;

	private function get_enabledView():DisplayObject {
		return this.getViewForState(TextInputState.ENABLED);
	}

	private function set_enabledView(value:DisplayObject):DisplayObject {
		this.setViewForState(TextInputState.ENABLED, value);
		return value;
	}

	/**
		The view for `feathers.controls.TextInputState.FOCUSED`.

		@since 1.3.0
	**/
	public var focusedView(get, set):DisplayObject;

	private function get_focusedView():DisplayObject {
		return this.getViewForState(TextInputState.FOCUSED);
	}

	private function set_focusedView(value:DisplayObject):DisplayObject {
		this.setViewForState(TextInputState.FOCUSED, value);
		return value;
	}

	/**
		The view for `feathers.controls.TextInputState.ERROR`.

		@since 1.3.0
	**/
	public var errorView(get, set):DisplayObject;

	private function get_errorView():DisplayObject {
		return this.getViewForState(TextInputState.ERROR);
	}

	private function set_errorView(value:DisplayObject):DisplayObject {
		this.setViewForState(TextInputState.ERROR, value);
		return value;
	}
}

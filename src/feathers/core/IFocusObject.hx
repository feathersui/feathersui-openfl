/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

/**
	A component that may receive focus from a focus manager.

	@see `feathers.core.IFocusContainer`

	@since 1.0.0
**/
interface IFocusObject extends IFocusManagerAware extends IDisplayObject {
	/**
		Indicates if the object may receive focus or not.

		@since 1.0.0
	**/
	@:flash.property
	public var focusEnabled(get, set):Bool;

	/**
		Shows a focus indicator.

		@since 1.0.0
	**/
	public function showFocus(show:Bool):Void;
}

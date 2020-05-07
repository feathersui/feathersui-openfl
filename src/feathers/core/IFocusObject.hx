/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

/**
	A component that may receive focus from a focus manager.

	@see `feathers.core.IFocusContainer`

	@since 1.0.0
**/
interface IFocusObject extends IDisplayObject {
	/**
		The object's current focus manager. May be `null`.

		@since 1.0.0
	**/
	public var focusManager(get, set):IFocusManager;

	/**
		Indicates if the object may receive focus or not.

		@since 1.0.0
	**/
	public var focusEnabled(get, set):Bool;

	/**
		Shows a focus indicator.

		@since 1.0.0
	**/
	public function showFocus(show:Bool):Void;
}

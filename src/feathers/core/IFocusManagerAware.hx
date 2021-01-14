/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

/**
	A component that has access to a focus manager, but cannot necessarily
	receive focus.

	@see `feathers.core.IFocusObject`

	@since 1.0.0
**/
interface IFocusManagerAware {
	/**
		The object's current focus manager. May be `null`.

		@since 1.0.0
	**/
	@:flash.property
	public var focusManager(get, set):IFocusManager;
}

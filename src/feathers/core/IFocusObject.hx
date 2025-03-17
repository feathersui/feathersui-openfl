/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

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
	public var focusEnabled(get, set):Bool;

	/**
		Used for associating focusable display objects that are not direct
		children with an "owner" focusable display object, such as pop-ups. A
		focus manager may use this property to influence the tab order.

		@since 1.0.0
	**/
	public var focusOwner(get, set):IFocusObject;

	/**
		Shows a focus indicator.

		@since 1.0.0
	**/
	public function showFocus(show:Bool):Void;
}

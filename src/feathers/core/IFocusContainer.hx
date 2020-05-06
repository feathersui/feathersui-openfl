/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

/**
	A component that may receive focus that also has children that may receive
	focus.

	@since 1.0.0
**/
interface IFocusContainer extends IFocusObject {
	/**
		Indicates if the container's children may receive focus or not.

		@since 1.0.0
	**/
	public var childFocusEnabled(get, set):Bool;
}

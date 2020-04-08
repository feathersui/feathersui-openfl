/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

/**
	A UI component that may be opened or closed.

	Dispatches `Event.OPEN` and `Event.CLOSE` when the current state changes.

	@since 1.0.0
**/
interface IOpenCloseToggle extends IUIControl {
	/**
		@since 1.0.0
	**/
	public var opened(get, set):Bool;
}

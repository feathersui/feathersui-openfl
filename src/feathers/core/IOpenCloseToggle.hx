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
		Indicates if the toggle is opened or closed.

		Dispatches an event of type `openfl.events.Event.OPEN` when changed to
		`true`, and dispatches an event of type `openfl.events.Event.CLOSE` when
		changed to `false`.

		@since 1.0.0
	**/
	public var opened(get, set):Bool;
}

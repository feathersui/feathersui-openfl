/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

/**
	A UI component that may be opened or closed.

	@event openfl.events.Event.OPEN Dispatched when the `opened` property is
	changed to `true`.

	@event openfl.events.Event.CLOSE Dispatched when the `opened` property is
	changed to `false`.

	@since 1.0.0
**/
@:event(openfl.events.Event.OPEN)
@:event(openfl.events.Event.CLOSE)
interface IOpenCloseToggle extends IUIControl {
	/**
		Indicates if the toggle is opened or closed.

		Dispatches an event of type `openfl.events.Event.OPEN` when changed to
		`true`, and dispatches an event of type `openfl.events.Event.CLOSE` when
		changed to `false`.

		@since 1.0.0
	**/
	@:flash.property
	public var opened(get, set):Bool;
}

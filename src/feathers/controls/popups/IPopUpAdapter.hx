/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.popups;

import openfl.display.DisplayObject;
import openfl.events.IEventDispatcher;

/**
	Manages the layout and positioning of a pop-up displayed by a component like
	`ComboBox` or `PopUpListView`.

	@event openfl.events.Event.OPEN Dispatched when the pop-up adapter opens,
	and `IPopUpAdapter.active` changes to `true`.

	@event openfl.events.Event.CLOSE Dispatched when the pop-up adapter closes,
	and `IPopUpAdapter.active` changes to `false`.

	@see `feathers.core.PopUpManager`
	@see `feathers.controls.ComboBox`
	@see `feathers.controls.PopUpListView`

	@since 1.0.0
**/
@:event(openfl.events.Event.OPEN)
@:event(openfl.events.Event.CLOSE)
interface IPopUpAdapter extends IEventDispatcher {
	/**
		Indicates if the pop-up is currently active or not.

		@see [`openfl.events.Event.OPEN`](https://api.openfl.org/openfl/events/Event.html#OPEN)
		@see [`openfl.events.Event.CLOSE`](https://api.openfl.org/openfl/events/Event.html#CLOSE)

		@since 1.0.0
	**/
	var active(get, never):Bool;

	/**
		Indicates if the pop-up adapter should manage its own closing, or if it
		should allow the source to close the pop-up.

		@since 1.0.0
	**/
	var persistent(get, never):Bool;

	/**
		Displays the pop-up.

		When the adapter opens, it will dispatch an event of type `Event.OPEN`.

		@see [`openfl.events.Event.OPEN`](https://api.openfl.org/openfl/events/Event.html#OPEN)

		@since 1.0.0
	**/
	function open(content:DisplayObject, source:DisplayObject):Void;

	/**
		Hides the pop-up.

		When the callout closes, it will dispatch an event of type
		`Event.CLOSE`.

		@see [`openfl.events.Event.CLOSE`](https://api.openfl.org/openfl/events/Event.html#CLOSE)

		@since 1.0.0
	**/
	function close():Void;
}

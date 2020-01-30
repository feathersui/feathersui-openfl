/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.popups;

import openfl.events.IEventDispatcher;
import openfl.display.DisplayObject;

/**
	Manages the layout and positioning of a pop-up displayed by a component like
	`ComboBox` or `PopUpListView`.

	@see `feathers.core.PopUpManager`
	@see `feathers.controls.ComboBox`
	@see `feathers.controls.PopUpListView`

	@since 1.0.0
**/
interface IPopUpAdapter extends IEventDispatcher {
	/**
		Indicates if the pop-up is currently active or not.

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

		@since 1.0.0
	**/
	function open(content:DisplayObject, source:DisplayObject):Void;

	/**
		Hides the pop-up.

		@since 1.0.0
	**/
	function close():Void;
}

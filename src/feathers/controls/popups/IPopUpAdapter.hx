/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.popups;

import openfl.events.IEventDispatcher;
import openfl.display.DisplayObject;

/**
	@since 1.0.0
**/
interface IPopUpAdapter extends IEventDispatcher {
	/**
		@since 1.0.0
	**/
	var active(get, never):Bool;

	/**
		@since 1.0.0
	**/
	var persistent(get, never):Bool;

	/**
		@since 1.0.0
	**/
	function open(content:DisplayObject, source:DisplayObject):Void;

	/**
		@since 1.0.0
	**/
	function close():Void;
}

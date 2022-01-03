/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.events.IEventDispatcher;

/**
	Manages focus of UI components.

	@event openfl.events.Event.CLEAR Dispatched when the focus manager is disposed.

	@see `feathers.core.IFocusObject`

	@since 1.0.0
**/
@:event(openfl.events.Event.CLEAR)
interface IFocusManager extends IEventDispatcher {
	/**
		The root of the focus manager.

		@since 1.0.0
	**/
	public var root(get, never):DisplayObject;

	/**
		The object that currently has focus.

		@since 1.0.0
	**/
	@:flash.property
	public var focus(get, set):IFocusObject;

	/**
		A place for UI components to draw their focus indicators, if requested.

		@since 1.0.0
	**/
	@:flash.property
	public var focusPane(get, never):DisplayObjectContainer;

	/**
		Indicates if UI components should draw their focus indicators.

		@since 1.0.0
	**/
	@:flash.property
	public var showFocusIndicator(get, never):Bool;

	/**
		Specifies if this focus manager is enabled or disabled.

		@since 1.0.0
	**/
	@:flash.property
	public var enabled(get, set):Bool;

	/**
		Finds the next focus in the specified direction (forward or backward).

		@since 1.0.0
	**/
	public function findNextFocus(backward:Bool = false):IFocusObject;

	/**
		Disposes this focus manager. A focus manager should never be used again
		after calling `dispose()`. Must dispatch `Event.CLEAR` when called.

		@since 1.0.0
	**/
	public function dispose():Void;
}

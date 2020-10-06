/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;

/**
	Manages focus of UI components.

	@see `feathers.core.IFocusObject`

	@since 1.0.0
**/
interface IFocusManager {
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
		Specifies if this focus manager is enabled or disabled.

		@since 1.0.0
	**/
	@:flash.property
	public var enabled(get, set):Bool;
}

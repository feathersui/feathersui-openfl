/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import openfl.display.DisplayObject;

/**
	Manages tool tips for UI components.

	@see `feathers.core.IUIControl.toolTip`

	@since 1.0.0
**/
interface IToolTipManager {
	/**
		The root of the tool tip manager.

		@since 1.0.0
	**/
	public var root(get, never):DisplayObject;

	/**
		Disposes the tool tip manager.

		@since 1.0.0
	**/
	public function dispose():Void;
}

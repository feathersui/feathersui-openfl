/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import openfl.display.InteractiveObject;

/**
	Allows a different interactive display object to receive stage focus when
	this object receives focus from a focus manager.
**/
interface IStageFocusDelegate extends IFocusObject {
	/**
		The interactive display object to use for stage focus.

		@since 1.0.0
	**/
	public var stageFocusTarget(get, never):InteractiveObject;
}

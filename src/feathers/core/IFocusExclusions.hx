/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import openfl.display.DisplayObject;

/**
	A container that may exclude some children from receiving focus.

	@since 1.0.0
**/
interface IFocusExclusions extends IFocusManagerAware {
	/**
		Display object children that should be skipped by the focus manager.

		May return `null` if there are no excluded children.

		@since 1.0.0
	**/
	@:flash.property
	var focusExclusions(get, never):Array<DisplayObject>;
}

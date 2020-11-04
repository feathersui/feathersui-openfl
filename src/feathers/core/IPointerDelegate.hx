/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import openfl.display.InteractiveObject;

/**
	Used by components, like data renderers, to delegate pointer state to
	another interactive display object. For instnace, the cell renderers in a
	`GridView` component delegate pointer state to their parent row.

	@since 1.0.0
**/
interface IPointerDelegate {
	/**
		The interactive display object to use for pointer state.

		@since 1.0.0
	**/
	@:flash.property
	public var pointerTarget(get, set):InteractiveObject;
}

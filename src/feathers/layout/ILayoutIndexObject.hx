/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

/**
	An object that is aware of its position in a layout.

	@since 1.0.0
**/
interface ILayoutIndexObject {
	/**
		The zero-based position of the item in the layout.

		@since 1.0.0
	**/
	public var layoutIndex(get, set):Int;
}

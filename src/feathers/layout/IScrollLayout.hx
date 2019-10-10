/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

interface IScrollLayout extends ILayout {
	var scrollX(default, set):Float;
	var scrollY(default, set):Float;

	/**
		The primary direction that this layout is expected to scroll. Not all
		layouts will necessarily have a primary direction.

		@since 1.0.0
	**/
	var primaryDirection(get, never):Direction;
}

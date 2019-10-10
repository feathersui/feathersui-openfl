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

	/**
		Determines if the container calls `layout()` when the scroll position
		changes. Useful for transforming items as the view port scrolls. This
		alue should typically be `true` for layouts that implement the
		`IVirtualLayout` interface and the `useVirtualLayout` property is set to
		`true`. May also be used by layouts that toggle item visibility as the
		items scroll into and out of the view port.

		@since 1.0.0
	**/
	var requiresLayoutOnScroll(get, never):Bool;
}

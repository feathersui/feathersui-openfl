/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import openfl.geom.Point;

/**
	A layout that is affected by changes to scroll position.

	@since 1.0.0
**/
interface IScrollLayout extends ILayout {
	/**
		The horizontal scroll position of the container using this layout.

		@since 1.0.0
	**/
	var scrollX(default, set):Float;

	/**
		The vertical scroll position of the container using this layout.

		@since 1.0.0
	**/
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

	/**
		@since 1.0.0
	**/
	function getNearestScrollPositionForIndex(index:Int, itemCount:Int, width:Float, height:Float, ?result:Point):Point;
}

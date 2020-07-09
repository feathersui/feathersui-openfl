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
	@:flash.property
	var scrollX(get, set):Float;

	/**
		The vertical scroll position of the container using this layout.

		@since 1.0.0
	**/
	@:flash.property
	var scrollY(get, set):Float;

	/**
		Indicates if the top edge is elastic.

		@since 1.0.0
	**/
	@:flash.property
	var elasticTop(get, never):Bool;

	/**
		Indicates if the right edge is elastic.

		@since 1.0.0
	**/
	@:flash.property
	var elasticRight(get, never):Bool;

	/**
		Indicates if the bottom edge is elastic.

		@since 1.0.0
	**/
	@:flash.property
	var elasticBottom(get, never):Bool;

	/**
		Indicates if the left edge is elastic.

		@since 1.0.0
	**/
	@:flash.property
	var elasticLeft(get, never):Bool;

	/**
		Determines if the container calls `layout()` when the scroll position
		changes. Useful for transforming items as the view port scrolls. This
		alue should typically be `true` for layouts that implement the
		`IVirtualLayout` interface and the `useVirtualLayout` property is set to
		`true`. May also be used by layouts that toggle item visibility as the
		items scroll into and out of the view port.

		@since 1.0.0
	**/
	@:flash.property
	var requiresLayoutOnScroll(get, never):Bool;

	/**
		@since 1.0.0
	**/
	function getNearestScrollPositionForIndex(index:Int, itemCount:Int, width:Float, height:Float, ?result:Point):Point;
}

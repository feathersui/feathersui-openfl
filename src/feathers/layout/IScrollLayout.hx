/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

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
	var scrollX(get, set):Float;

	/**
		The vertical scroll position of the container using this layout.

		@since 1.0.0
	**/
	var scrollY(get, set):Float;

	/**
		Indicates if the top edge is elastic.

		@since 1.0.0
	**/
	var elasticTop(get, never):Bool;

	/**
		Indicates if the right edge is elastic.

		@since 1.0.0
	**/
	var elasticRight(get, never):Bool;

	/**
		Indicates if the bottom edge is elastic.

		@since 1.0.0
	**/
	var elasticBottom(get, never):Bool;

	/**
		Indicates if the left edge is elastic.

		@since 1.0.0
	**/
	var elasticLeft(get, never):Bool;

	/**
		@since 1.0.0
	**/
	function getNearestScrollPositionForIndex(index:Int, itemCount:Int, width:Float, height:Float, ?result:Point):Point;
}

/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

/**
	Calculated bounds for layout.

	@since 1.0.0
**/
class LayoutBoundsResult {
	/**
		Creates a new `LayoutBoundsResult` object.

		@since 1.0.0
	**/
	public function new() {}

	/**
		The starting position of the view port's content on the x axis.
		Usually, this value is `0.0`, but it may be negative, in some cases.

		@since 1.0.0
	**/
	public var contentX:Float = 0.0;

	/**
		The starting position of the view port's content on the y axis.
		Usually, this value is `0.0`, but it may be negative, in some cases.

		@since 1.0.0
	**/
	public var contentY:Float = 0.0;

	/**
		The visible width of the view port. The view port's content may be
		clipped.

		@since 1.0.0
	**/
	public var viewPortWidth:Float;

	/**
		The visible height of the view port. The view port's content may be
		clipped.

		@since 1.0.0
	**/
	public var viewPortHeight:Float;

	/**
		The width of the content. May be larger or smaller than the view port.

		@since 1.0.0
	**/
	public var contentWidth:Float;

	/**
		The height of the content. May be larger or smaller than the view port.

		@since 1.0.0
	**/
	public var contentHeight:Float;
}

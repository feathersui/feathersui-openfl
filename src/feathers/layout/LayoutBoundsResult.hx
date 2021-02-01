/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

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
	public function new() {
		this.reset();
	}

	/**
		The starting position of the view port's content on the x axis.
		Usually, this value is `0.0`, but it may be negative, in some cases.

		@since 1.0.0
	**/
	public var contentX:Float;

	/**
		The starting position of the view port's content on the y axis.
		Usually, this value is `0.0`, but it may be negative, in some cases.

		@since 1.0.0
	**/
	public var contentY:Float;

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

	/**
		The minimum width of the content. May be larger or smaller than the view port.

		@since 1.0.0
	**/
	public var contentMinWidth:Float;

	/**
		The minimum height of the content. May be larger or smaller than the view port.

		@since 1.0.0
	**/
	public var contentMinHeight:Float;

	/**
		The maximum width of the content. May be larger or smaller than the view port.

		@since 1.0.0
	**/
	public var contentMaxWidth:Float;

	/**
		The maximum height of the content. May be larger or smaller than the view port.

		@since 1.0.0
	**/
	public var contentMaxHeight:Float;

	/**
		Resets all of the result values to their defaults.

		@since 1.0.0
	**/
	public function reset():Void {
		this.contentX = 0.0;
		this.contentY = 0.0;
		this.contentWidth = 0.0;
		this.contentHeight = 0.0;
		this.contentMinWidth = 0.0;
		this.contentMinHeight = 0.0;
		this.contentMaxWidth = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround
		this.contentMaxHeight = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround
		this.viewPortWidth = 0.0;
		this.viewPortHeight = 0.0;
	}
}

/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.supportClasses;

import feathers.core.IMeasureObject;
import feathers.core.IUIControl;
import feathers.core.IValidating;

/**
	A view port for scrolling containers that extend `BaseScrollContainer`.

	@see `feathers.controls.supportClasses.BaseScrollContainer`

	@since 1.0.0
**/
interface IViewPort extends IUIControl extends IValidating extends IMeasureObject {
	/**
		The width of the view port. This value may be smaller than the width
		of the view port's content, which indicates that scrolling is required.

		To access the width of the view port's content, use the `width`
		property.

		@since 1.0.0
	**/
	public var visibleWidth(get, set):Null<Float>;

	/**
		The height of the view port. This value may be smaller than the height
		of the view port's content, which indicates that scrolling is required.

		To access the height of the view port's content, use the `height`
		property.

		@since 1.0.0
	**/
	public var visibleHeight(get, set):Null<Float>;

	/**
		The minimum width of the view port. This value may be different from the
		minimum width of the view port's content.

		To access the minimum width of the view port's content, use the
		`minWidth` property.

		@since 1.0.0
	**/
	public var minVisibleWidth(get, set):Null<Float>;

	/**
		The minimum height of the view port. This value may be different from the
		minimum height of the view port's content.

		To access the minimum height of the view port's content, use the
		`minHeight` property.

		@since 1.0.0
	**/
	public var minVisibleHeight(get, set):Null<Float>;

	/**
		The maximum width of the view port. This value may be different from the
		maximum width of the view port's content.

		To access the maximum width of the view port's content, use the
		`maxWidth` property.

		@since 1.0.0
	**/
	public var maxVisibleWidth(default, set):Null<Float>;

	/**
		The maximum height of the view port. This value may be different from
		the maximum height of the view port's content.

		To access the maximum height of the view port's content, use the
		`maxHeight` property.

		@since 1.0.0
	**/
	public var maxVisibleHeight(default, set):Null<Float>;

	/**
		The current horizontal scroll position (on the x-axis).

		@since 1.0.0
	**/
	public var scrollX(get, set):Float;

	/**
		The current vertical scroll position (on the y-axis).

		@since 1.0.0
	**/
	public var scrollY(get, set):Float;

	/**
		Indicates if the content of the view port must be re-measured when
		scrolling. Typically used by "virtualized" layouts.

		@since 1.0.0
	**/
	public var requiresMeasurementOnScroll(get, never):Bool;
}

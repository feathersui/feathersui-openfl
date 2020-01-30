/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

/**
	A display object with extra measurement properties, including minimum and
	maximum dimensions.

	@since 1.0.0
**/
interface IMeasureObject extends IDisplayObject {
	/**
		The object's explicit width value, or `null` if `width` is not set
		explicitly.

		@see `IMeasureObject.explicitHeight`

		@since 1.0.0
	**/
	public var explicitWidth(get, never):Null<Float>;

	/**
		The object's explicit height value, or `null` if `height` is not set
		explicitly.

		@see `IMeasureObject.explicitWidth`

		@since 1.0.0
	**/
	public var explicitHeight(get, never):Null<Float>;

	/**
		The object's explicit minimum width value, or `null` if `minWidth` is
		not set explicitly.

		@see `IMeasureObject.explicitMinHeight`

		@since 1.0.0
	**/
	public var explicitMinWidth(get, never):Null<Float>;

	/**
		The object's explicit minimum height value, or `null` if `minHeight` is
		not set explicitly.

		@see `IMeasureObject.explicitMinWidth`

		@since 1.0.0
	**/
	public var explicitMinHeight(get, never):Null<Float>;

	/**
		The object's explicit maximum width value, or `null` if `maxWidth` is
		not set explicitly.

		@see `IMeasureObject.explicitMaxWidth`

		@since 1.0.0
	**/
	public var explicitMaxWidth(get, never):Null<Float>;

	/**
		The object's explicit maximum height value, or `null` if `maxHeight` is
		not set explicitly.

		@see `IMeasureObject.explicitMaxWidth`

		@since 1.0.0
	**/
	public var explicitMaxHeight(get, never):Null<Float>;

	/**
		The object's minimum width value.

		@see `IMeasureObject.resetMinWidth`
		@see `IMeasureObject.minHeight`

		@since 1.0.0
	**/
	public var minWidth(get, set):Float;

	/**
		The object's minimum height value.

		@see `IMeasureObject.resetMinHeight`
		@see `IMeasureObject.minWidth`

		@since 1.0.0
	**/
	public var minHeight(get, set):Float;

	/**
		The object's maximum width value.

		@see `IMeasureObject.resetMaxWidth`
		@see `IMeasureObject.maxHeight`

		@since 1.0.0
	**/
	public var maxWidth(get, set):Float;

	/**
		The object's maximum height value.

		@see `IMeasureObject.resetMaxHeight`
		@see `IMeasureObject.maxWidth`

		@since 1.0.0
	**/
	public var maxHeight(get, set):Float;

	/**
		Resets the width so that it will be calculated automatically by
		the component.

		@see `IMeasureObject.explicitWidth`

		@since 1.0.0
	**/
	public function resetWidth():Void;

	/**
		Resets the height so that it will be calculated automatically by
		the component.

		@see `IMeasureObject.explicitHeight`

		@since 1.0.0
	**/
	public function resetHeight():Void;

	/**
		Resets the minimum width so that it will be calculated automatically by
		the component.

		@see `IMeasureObject.minWidth`
		@see `IMeasureObject.explicitMinWidth`

		@since 1.0.0
	**/
	public function resetMinWidth():Void;

	/**
		Resets the minimum height so that it will be calculated automatically by
		the component.

		@see `IMeasureObject.minHeight`
		@see `IMeasureObject.explicitMinHeight`

		@since 1.0.0
	**/
	public function resetMinHeight():Void;

	/**
		Resets the minimum width so that it will be calculated automatically by
		the component.

		@see `IMeasureObject.maxWidth`
		@see `IMeasureObject.explicitMaxWidth`

		@since 1.0.0
	**/
	public function resetMaxWidth():Void;

	/**
		Resets the maximum height so that it will be calculated automatically by
		the component.

		@see `IMeasureObject.maxHeight`
		@see `IMeasureObject.explicitMaxHeight`

		@since 1.0.0
	**/
	public function resetMaxHeight():Void;
}

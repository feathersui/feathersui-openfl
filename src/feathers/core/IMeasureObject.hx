/*
	Feathers
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

/**
	A display object with extra measurement properties, including minimum and
	maximum dimensions.

	@since 1.0.0
**/
interface IMeasureObject {
	/**
		The object's explicit width value, or `null` if `width` is not set
		explicitly.

		@see `width`
		@see `explicitHeight`

		@since 1.0.0
	**/
	public var explicitWidth(default, set):Null<Float>;

	/**
		The object's explicit height value, or `null` if `height` is not set
		explicitly.

		@see `height`
		@see `explicitWidth`

		@since 1.0.0
	**/
	public var explicitHeight(default, set):Null<Float>;

	/**
		The object's explicit minimum width value, or `null` if `minWidth` is
		not set explicitly.

		@see `explicitMinHeight`

		@since 1.0.0
	**/
	public var explicitMinWidth(default, set):Null<Float>;

	/**
		The object's explicit minimum height value, or `null` if `minHeight` is
		not set explicitly.

		@see `explicitMinWidth`

		@since 1.0.0
	**/
	public var explicitMinHeight(default, set):Null<Float>;

	/**
		The object's explicit maximum width value, or `null` if `maxWidth` is
		not set explicitly.

		@see `explicitMaxWidth`

		@since 1.0.0
	**/
	public var explicitMaxWidth(default, null):Null<Float>;

	/**
		The object's explicit maximum height value, or `null` if `maxHeight` is
		not set explicitly.

		@see `explicitMaxWidth`

		@since 1.0.0
	**/
	public var explicitMaxHeight(default, null):Null<Float>;

	/**
		The object's width value.

		@see `height`

		@since 1.0.0
	**/
	public var width(get, set):Float;

	/**
		The object's height value.

		@see `width`

		@since 1.0.0
	**/
	public var height(get, set):Float;

	/**
		The object's minimum width value.

		@see `minHeight`

		@since 1.0.0
	**/
	public var minWidth(default, set):Float;

	/**
		The object's minimum height value.

		@see `minWidth`

		@since 1.0.0
	**/
	public var minHeight(default, set):Float;

	/**
		The object's maximum width value.

		@see `maxHeight`

		@since 1.0.0
	**/
	public var maxWidth(default, set):Float;

	/**
		The object's maximum height value.

		@see `maxWidth`

		@since 1.0.0
	**/
	public var maxHeight(default, set):Float;
}

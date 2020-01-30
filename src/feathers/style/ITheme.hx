/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.style;

/**
	An interface for Feathers UI themes.

	@since 1.0.0
**/
interface ITheme {
	/**
		Returns the style provider for the specified component.

		@since 1.0.0
	**/
	public function getStyleProvider(target:IStyleObject):IStyleProvider;

	/**
		Disposes the theme. It must no longer be used to style components after
		calling `dispose()`.

		@since 1.0.0
	**/
	public function dispose():Void;
}

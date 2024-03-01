/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.style;

/**
	An interface for Feathers UI themes.

	@event openfl.events.Event.CLEAR Dispatched when the theme is disposed.

	@since 1.0.0
**/
@:event(openfl.events.Event.CLEAR)
interface ITheme {
	/**
		Returns the style provider for the specified component.

		@since 1.0.0
	**/
	public function getStyleProvider(target:IStyleObject):IStyleProvider;

	/**
		Disposes the theme. It must no longer be used to style components after
		calling `dispose()`. The theme will dispatch `Event.CLEAR` when it gets
		disposed.

		@since 1.0.0
	**/
	public function dispose():Void;
}

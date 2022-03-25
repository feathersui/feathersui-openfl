/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.style;

import openfl.events.IEventDispatcher;

/**
	Sets style properties on a target object. This is advanced interface that is
	mostly used internally by UI components to apply styles from a theme. Most
	developers will never instantiate a style provider directly, or create a
	custom implementation of the `IStyleProvider` interface.

	@event feathers.events.StyleProviderEvent.STYLES_CHANGE Dispatched when the
	styles have changed, and style objects should request for their styles to be
	re-applied.

	@see `feathers.style.ITheme`
**/
@:event(feathers.events.StyleProviderEvent.STYLES_CHANGE)
interface IStyleProvider extends IEventDispatcher {
	/**
		Applies styles to the target object.

		@since 1.0.0
	**/
	public function applyStyles<T>(target:IStyleObject):Void;
}

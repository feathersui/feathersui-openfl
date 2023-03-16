/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

/**
	Flags that are used internally with `FeathersControl.invalidate()`
	to track of which parts of the component need to be updated. These flags are
	merely suggestions, and custom components may support custom flags.

	Generally, invalidation flags are not considered part of the public API
	for any component. They're meant to be used internally. With that in mind,
	calling `invalidate()` with a flag from outside the component means that
	you're probably doing something wrong.

	@since 1.0.0
**/
enum InvalidationFlag {
	/**
		Indicate that the state has changed. Used when the `enabled` property of
		a Feathers UI component changes, but may be used for other component
		states too. For instance, a component that implements `IStateContext`
		may have multiple states.

		@see `FeathersControl.enabled`
		@see `feathers.core.IStateContext`

		@since 1.0.0
	**/
	STATE;

	/**
		Indicates that the dimensions of the UI control have changed.

		@since 1.0.0
	**/
	SIZE;

	/**
		Indicates that the styles or visual appearance of the UI control has changed.

		@since 1.0.0
	**/
	STYLES;

	/**
		Indicates that the skin of the UI control has changed.

		@since 1.0.0
	**/
	SKIN;

	/**
		Indicates that the layout of the UI control has changed.

		@since 1.0.0
	**/
	LAYOUT;

	/**
		Indicates that the primary data displayed by the UI control has changed.

		@since 1.0.0
	**/
	DATA;

	/**
		Indicate that the scroll position of the UI control has changed.

		@since 1.0.0
	**/
	SCROLL;

	/**
		Indicates that the selection of the UI control has changed.

		@since 1.0.0
	**/
	SELECTION;

	/**
		Indicate that the focused state of the UI control has changed.

		@since 1.0.0
	**/
	FOCUS;

	/**
		Indicate that the sort state of the UI control has changed.

		@since 1.0.0
	**/
	SORT;

	/**
		Add a custom flag based on a string value.

		@since 1.0.0
	**/
	CUSTOM(value:String);
}

/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.core.IUIControl;

/**
	An interface for a user interface component that may be selected.

	@since 1.0.0
**/
interface IToggle extends IUIControl {
	/**
		Indicates if the `IToggle` is selected or not.

		Dispatches `openfl.events.Event.CHANGE` when the value changes. The same
		event is dispatched whether this property is changed through user
		interaction or by passing in a new value programmatically.

		@since 1.0.0
	**/
	public var selected(get, set):Bool;
}

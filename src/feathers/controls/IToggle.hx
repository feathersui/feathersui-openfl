/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

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

		@since 1.0.0
	**/
	public var selected(get, set):Bool;
}

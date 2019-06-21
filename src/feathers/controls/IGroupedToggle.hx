/*
	Feathers
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.core.ToggleGroup;

/**
	A toggle associated with a specific group.

	@see `feathers.core.ToggleGroup`

	@since 1.0.0
**/
interface IGroupedToggle extends IToggle {
	/**

		@since 1.0.0
	**/
	public var toggleGroup(default, set):ToggleGroup;
}

/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.data;

import feathers.controls.PageIndicator;

/**
	Represents the current state of a `PageIndicator` toggle button.

	@see `feathers.controls.PageIndicator`
	@see `feathers.controls.PageIndicator.toggleButtonRecycler`

	@since 1.0.0
**/
class PageIndicatorItemState {
	/**
		Creates a new `PageIndicatorItemState` object with the given arguments.

		@since 1.0.0
	**/
	public function new(index:Int = -1, selected:Bool = false) {
		this.index = index;
		this.selected = false;
	}

	/**
		Returns a reference to the `PageIndicator` that contains this item.

		@since 1.0.0
	**/
	public var owner:PageIndicator;

	/**
		The page index.

		@since 1.0.0
	**/
	public var index:Int = -1;

	/**
		Returns whether the button is selected or not.

		@see `feathers.controls.PageIndicator.selectedIndex`

		@since 1.0.0
	**/
	public var selected:Bool = false;

	/**
		Returns whether the item is enabled or not.

		@see `feathers.core.IUIControl.enabled`

		@since 1.0.0
	**/
	public var enabled:Bool = true;
}

/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.data;

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
		The page index.

		@since 1.0.0
	**/
	public var index(default, null):Int;

	/**
		Returns whether the button is selected or not.

		@see `feathers.controls.PageIndicator.selectedIndex`

		@since 1.0.0
	**/
	public var selected(default, null):Bool;
}

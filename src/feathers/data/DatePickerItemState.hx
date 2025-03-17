/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.data;

import feathers.controls.DatePicker;

/**
	Represents the current state of a `DatePicker` item renderer.

	@see `feathers.controls.DatePicker`
	@see `feathers.controls.DatePicker.dateRendererRecycler`

	@since 1.0.0
**/
class DatePickerItemState {
	/**
		Creates a new `DatePickerItemState` object with the given arguments.

		@since 1.0.0
	**/
	public function new(date:Date = null, selected:Bool = false) {
		this.date = date;
		this.selected = false;
	}

	/**
		Returns a reference to the `DatePicker` that contains this item.

		@since 1.0.0
	**/
	public var owner:DatePicker;

	/**
		The date to display for the item.

		@since 1.0.0
	**/
	public var date:Date;

	/**
		Returns whether the item is selected or not.

		@see `feathers.controls.DatePicker.selectedDate`

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

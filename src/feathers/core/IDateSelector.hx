/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

/**
	Provides a selection from a range of dates.

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
interface IDateSelector {
	/**
		The currently selected date. Returns `null` if no date is selected.

		When the value of the `selectedDate` property changes, the component
		will dispatch an event of type `Event.CHANGE`.

		The following example selects a specific date:

		```hx
		control.selectedDate = Date.now();
		```

		The following example clears the currently selected date:

		```hx
		control.selectedDate = null;
		```

		The following example listens for when the selection of a calendar
		component changes, and it requests the new selected index:

		```hx
		var datePicker = new DatePicker();
		function changeHandler(event:Event):Void
		{
			var datePicker = cast(event.currentTarget, DatePicker);
			trace("selection change: " + datePicker.selectedDate);
		}
		datePicker.addEventListener(Event.CHANGE, changeHandler);
		```

		@default null

		@see [`openfl.events.Event.CHANGE`](https://api.openfl.org/openfl/events/Event.html#CHANGE)

		@since 1.0.0
	**/
	public var selectedDate(get, set):Date;
}

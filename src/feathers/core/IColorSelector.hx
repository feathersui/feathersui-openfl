/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

/**
	Provides a selection from a range of colors.

	@since 1.4.0
**/
@:event(openfl.events.Event.CHANGE)
interface IColorSelector {
	/**
		The currently selected color. Returns `null` if no color is selected.

		When the value of the `selectedColor` property changes, the component
		will dispatch an event of type `Event.CHANGE`.

		The following example selects a specific color:

		```haxe
		control.selectedColor = 0xff0000;
		```

		The following example clears the currently selected color:

		```haxe
		control.selectedDate = null;
		```

		@default null

		@see [`openfl.events.Event.CHANGE`](https://api.openfl.org/openfl/events/Event.html#CHANGE)

		@since 1.4.0
	**/
	public var selectedColor(get, set):Null<UInt>;
}

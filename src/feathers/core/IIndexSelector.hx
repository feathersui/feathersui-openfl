/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

/**
	Provides a selection from a range of integers.

	@since 1.0.0
**/
interface IIndexSelector {
	/**
		The currently selected index. Returns `-1` if no index is selected.

		When the value of the `selectedIndex` property changes, the component
		will dispatch an event of type `Event.CHANGE`.

		The following example selects a specific index:

		```hx
		control.selectedIndex = 2;
		```

		The following example clears the currently selected index:

		```hx
		control.selectedIndex = -1;
		```

		The following example listens for when the selection of a `ListView`
		component changes, and it requests the new selected index:

		```hx
		var listView = new ListView();
		function changeHandler(event:Event):Void
		{
			var listView = cast(event.currentTarget, ListView);
			trace("selection change: " + listView.selectedIndex);
		}
		listView.addEventListener(Event.CHANGE, changeHandler);
		```

		@default -1

		@see `IIndexSelector.maxSelectedIndex`
		@see `openfl.events.Event.CHANGE`

		@since 1.0.0
	**/
	public var selectedIndex(get, set):Int;

	/**
		The maximum index that may be selected. Returns `-1` if no range is available.

		@default -1

		@see `IIndexSelector.selectedIndex`

		@since 1.0.0
	**/
	public var maxSelectedIndex(get, never):Int;
}

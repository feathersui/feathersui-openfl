/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

/**
	Provides a selection from a collection of items.

	@since 1.0.0
**/
interface IDataSelector<T> {
	/**
		The index of the currently selected item in the item collection. Returns
		`-1` if no item is selected.

		The following example selects an item by passing its index to the
		`selectedIndex` property:

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

		@see `IDataSelector.selectedItem`

		@since 1.0.0
	**/
	public var selectedIndex(get, set):Int;

	/**
		The currently selected item. Returns `null` if no item is selected.

		The following example changes the selected item:

		```hx
		list.selectedItem = newItem;
		```

		Note: If the new item is not in the item collection, the selected item
		will be set to `null` instead.

		The following example clears the currently selected item:

		```hx
		control.selectedItem = null;
		```

		The following example listens for when the selection of a `ListView`
		component changes, and it requests the new selected index:

		```hx
		var listView = new ListView();
		function changeHandler(event:Event):Void
		{
			var listView = cast(event.currentTarget, ListView);
			var text = listView.itemToText(listView.selectedItem);
			trace("selection change: " + text);
		}
		listView.addEventListener(Event.CHANGE, changeHandler);
		```

		@default null

		@see `IDataSelector.selectedIndex`

		@since 1.0.0
	**/
	public var selectedItem(get, set):T;
}

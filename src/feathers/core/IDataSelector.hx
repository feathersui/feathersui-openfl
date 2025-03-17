/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

/**
	Provides a selection from a collection of items.

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
interface IDataSelector<T> {
	/**
		The currently selected item. Returns `null` if no item is selected.

		When the value of the `selectedItem` property changes, the component
		will dispatch an event of type `Event.CHANGE`.

		The following example changes the selected item:

		```haxe
		list.selectedItem = newItem;
		```

		Note: If the new item is not in the item collection, the selected item
		will be set to `null` instead.

		The following example clears the currently selected item:

		```haxe
		control.selectedItem = null;
		```

		The following example listens for when the selection of a `ListView`
		component changes, and it requests the new selected index:

		```haxe
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

		@see `IIndexSelector.selectedIndex`
		@see [`openfl.events.Event.CHANGE`](https://api.openfl.org/openfl/events/Event.html#CHANGE)

		@since 1.0.0
	**/
	public var selectedItem(get, set):#if flash Dynamic #else T #end;
}

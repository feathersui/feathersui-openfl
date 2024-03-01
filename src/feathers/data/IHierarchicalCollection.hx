/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.data;

import openfl.events.IEventDispatcher;

/**
	Interface for collections of hierarchical data, such as trees.

	@event openfl.events.Event.CHANGE Dispatched when the collection changes.

	@event feathers.events.HierarchicalCollectionEvent.ADD_ITEM Dispatched when
	an item is added to the collection.

	@event feathers.events.HierarchicalCollectionEvent.REMOVE_ITEM Dispatched
	when an item is removed from the collection.

	@event feathers.events.HierarchicalCollectionEvent.REPLACE_ITEM Dispatched
	when an item is replaced in the collection.

	@event feathers.events.HierarchicalCollectionEvent.REMOVE_ALL Dispatched
	when all items are removed from the collection.

	@event feathers.events.HierarchicalCollectionEvent.RESET Dispatched
	when the source of the collection is changed.

	@event feathers.events.HierarchicalCollectionEvent.UPDATE_ITEM Dispatched
	when `IHierarchicalCollection.updateItem()` is called.

	@event feathers.events.HierarchicalCollectionEvent.UPDATE_ALL Dispatched
	when `IHierarchicalCollection.updateAll()` is called.

	@event feathers.events.HierarchicalCollectionEvent.FILTER_CHANGE Dispatched
	when `IHierarchicalCollection.filterFunction` is changed.

	@event feathers.events.HierarchicalCollectionEvent.SORT_CHANGE Dispatched
	when `IHierarchicalCollection.sortCompareFunction` is changed.

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
@:event(feathers.events.HierarchicalCollectionEvent.ADD_ITEM)
@:event(feathers.events.HierarchicalCollectionEvent.REMOVE_ITEM)
@:event(feathers.events.HierarchicalCollectionEvent.REPLACE_ITEM)
@:event(feathers.events.HierarchicalCollectionEvent.REMOVE_ALL)
@:event(feathers.events.HierarchicalCollectionEvent.RESET)
@:event(feathers.events.HierarchicalCollectionEvent.UPDATE_ITEM)
@:event(feathers.events.HierarchicalCollectionEvent.UPDATE_ALL)
@:event(feathers.events.HierarchicalCollectionEvent.FILTER_CHANGE)
@:event(feathers.events.HierarchicalCollectionEvent.SORT_CHANGE)
interface IHierarchicalCollection<T> extends IEventDispatcher {
	/**
		A function to determine if each item in the collection should be
		included or excluded from visibility through APIs like `length` and
		`get()`.

		The following example filters a collection of strings by searching for
		a substring at the beginning:

		```haxe
		collection.filterFunction = (a:String) =>
		{
			return StringTools.startsWith(a.toLowerCase(), "john");
		};
		```

		@see `feathers.data.HierarchicalCollectionEvent.FILTER_CHANGE`

		@since 1.0.0
	**/
	public var filterFunction(get, set):(T) -> Bool;

	/**
		A function to compare each item in the collection to determine the order
		when sorted.

		The return value should be `-1` if the first item should appear before
		the second item when the collection is sorted. The return value should
		be `1` if the first item should appear after the second item when the
		collection is sorted. Finally, the return value should be `0` if both
		items have the same sort order.

		The following example sorts a collection of `Float` values:

		```haxe
		collection.sortCompareFunction = (a:Float, b:Float) =>
		{
			if (a > b) {
				return 1;
			} else if (a < b) {
				return -1;
			}
			return 0;
		};
		```

		@see `feathers.data.HierarchicalCollectionEvent.SORT_CHANGE`

		@since 1.0.0
	**/
	public var sortCompareFunction(get, set):(T, T) -> Int;

	/**
		Returns the item at the specified location within the collection.

		The following example gets an item from a specific location:

		```haxe
		var location = [2, 0];
		var item = collection.get(location);
		```

		The following example iterates over the items at the root of a
		collection:

		```haxe
		for(i in 0...collection.getLength()) {
			var location = [i];
			var item = collection.get(i);
		}
		```

		@since 1.0.0
	**/
	function get(location:Array<Int>):T;

	/**
		Replaces the item at the specified location in the collection with a new
		item.

		The following example replaces an item in a collection:

		```haxe
		var location = [2, 0];
		collection.set(location, object);
		```

		@see `feathers.data.HierarchicalCollectionEvent.REPLACE_ITEM`

		@since 1.0.0
	**/
	function set(location:Array<Int>, value:T):Void;

	/**
		The number of items at the specified location within the collection. If
		called without a location, returns the length of the root.

		The following example iterates over the items at the root of a
		collection:

		```haxe
		for(i in 0...collection.getLength()) {
			var location = [i];
			var item = collection.get(location);
		}
		```

		@since 1.0.0
	**/
	function getLength(?location:Array<Int>):Int;

	/**
		Returns the location of the specified item, or `null` if the item is not
		in the collection.

		The following example gets the location of an item in the collection:

		```haxe
		var item = { text: "New Item" };
		collection.addAt(item, [0]);

		var index = collection.locationOf(item); // [0]
		```

		@since 1.0.0
	**/
	function locationOf(item:T):Array<Int>;

	/**
		Determines if the collection contains the specified item.

		The following example checks if a collection contains an item:

		```haxe
		var item = { text: "New Item" };
		collection.addAt(item, [0]);

		var contained = collection.contains(item); // true
		```

		@since 1.0.0
	**/
	function contains(item:T):Bool;

	/**
		Determines if an item from the collection is a branch or not.

		The following example iterates over the items at the root of a
		collection and prints the locations of branches to the debug console:

		```haxe
		for(i in 0...collection.getLength()) {
			var location = [i];
			var item = collection.get(location);
			if(collection.isBranch(item)) {
				trace("branch: " + location);
			}
		}
		```

		@since 1.0.0
	**/
	function isBranch(item:T):Bool;

	/**
		Adds an item to the collection at the specified location, increasing the
		the length of the parent branch by one.

		```haxe
		var location = [2, 0];
		var item = { text: "New Item" };
		collection.addAt(item, location);
		```

		@see `feathers.data.HierarchicalCollectionEvent.ADD_ITEM`

		@since 1.0.0
	**/
	function addAt(itemToAdd:T, location:Array<Int>):Void;

	/**
		Removes an item from the collection.

		```haxe
		var location = [2, 0];
		var item = { text: "New Item" };
		collection.addAt(item, location);
		collection.remove(item);
		```

		@see `feathers.data.HierarchicalCollectionEvent.REMOVE_ITEM`

		@since 1.0.0
	**/
	function remove(item:T):Void;

	/**
		Removes an item from the collection at the specified location,
		decreasing the length of the parent branch by one.

		```haxe
		var location = [2, 0];
		var item = { text: "New Item" };
		collection.addAt(item, location);
		collection.removeAt(location);
		```

		@see `feathers.data.HierarchicalCollectionEvent.REMOVE_ITEM`

		@since 1.0.0
	**/
	function removeAt(location:Array<Int>):T;

	/**
		Removes all items from a branch, decreasing the branch's length to zero.
		If called without a location, returns removes all items from the
		root of collection, resulting in a completely empty location.

		The following example removes all items from a collection:

		```haxe
		collection.removeAll();
		```

		@see `feathers.data.HierarchicalCollectionEvent.REMOVE_ALL`

		@since 1.0.0
	**/
	function removeAll(?location:Array<Int>):Void;

	/**
		Notifies components using the collection that an item at the specified
		location has changed.

		The following example updates an item in the collection:

		```haxe
		var location = [2, 0];
		collection.updateAt(location);
		```

		@see `IHierarchicalCollection.updateAll`
		@see `feathers.data.HierarchicalCollectionEvent.UPDATE_ITEM`

		@since 1.0.0
	**/
	function updateAt(location:Array<Int>):Void;

	/**
		Notifies components using the collection that all items should be
		considered changed.

		The following example updates all items in the collection:

		```haxe
		collection.updateAll();
		```

		@see `IHierarchicalCollection.updateAt`
		@see `feathers.data.HierarchicalCollectionEvent.UPDATE_ALL`

		@since 1.0.0
	**/
	function updateAll():Void;
}

/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.data;

import openfl.events.IEventDispatcher;

/**
	Interface for collections of hierarchical data, such as trees.

	@since 1.0.0
**/
interface IHierarchicalCollection<T> extends IEventDispatcher {
	/**
		Returns the item at the specified location within the collection.

		The following example gets an item from a specific location:

		```hx
		var location = [2, 0];
		var item = collection.get(location);
		```

		The following example iterates over the items at the root of a
		collection:

		```hx
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

		```hx
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

		```hx
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

		```hx
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

		```hx
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

		```hx
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

		```hx
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

		```hx
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

		```hx
		var location = [2, 0];
		var item = { text: "New Item" };
		collection.addAt(item, location);
		collection.removeAt(location);
		```

		@see `feathers.data.HierarchicalCollectionEvent.REMOVE_ITEM`

		@since 1.0.0
	**/
	function removeAt(location:Array<Int>):Void;

	/**
		Removes all items from the collection, decreasing the length of the root
		to zero.

		The following example removes all items from a collection:

		```hx
		collection.removeAll();
		```

		@see `feathers.data.HierarchicalCollectionEvent.REMOVE_ALL`

		@since 1.0.0
	**/
	function removeAll():Void;

	/**
		Notifies components using the collection that an item at the specified
		location has changed.

		The following example updates an item in the collection:

		```hx
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

		```hx
		collection.updateAll();
		```

		@see `IHierarchicalCollection.updateAt`
		@see `feathers.data.HierarchicalCollectionEvent.UPDATE_ALL`

		@since 1.0.0
	**/
	function updateAll():Void;
}

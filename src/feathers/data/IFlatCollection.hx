/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.data;

import openfl.events.IEventDispatcher;

/**
	Interface for collections of flat data, such as arrays or other lists.

	@since 1.0.0
**/
interface IFlatCollection<T> extends IEventDispatcher {
	/**
		The number of items in the collection.

		The following example iterates over the items in a collection:

		```hx
		for(i in 0...collection.length) {
			var item = collection.get(i);
		}
		```

		@since 1.0.0
	**/
	public var length(get, never):Int;

	/**
		A function to determine if each item in the collection should be
		included or excluded from visibility through APIs like `length` and
		`get()`.

		The following example filters a collection of strings by searching for
		a substring at the beginning:

		```hx
		collection.filterFunction = (a:String) =>
		{
			return StringTools.startsWith(a.toLowerCase(), "john");
		};
		```

		@see `feathers.data.FlatCollectionEvent.FILTER_CHANGE`

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

		```hx
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

		@see `feathers.data.FlatCollectionEvent.SORT_CHANGE`

		@since 1.0.0
	**/
	public var sortCompareFunction(get, set):(T, T) -> Int;

	/**
		Returns the item at the specified index in the collection.

		The following example iterates over the items in a collection:

		```hx
		for(i in 0...collection.length) {
			var item = collection.get(i);
		}
		```

		@since 1.0.0
	**/
	public function get(index:Int):T;

	/**
		Replaces the item at the specified index in the collection with a new
		item.

		The following example replaces an item in a collection:

		```hx
		collection.set(0, object);
		```

		@see `feathers.data.FlatCollectionEvent.REPLACE_ITEM`

		@since 1.0.0
	**/
	public function set(index:Int, item:T):Void;

	/**
		Inserts an item at the end of the collection, increasing the `length` by
		one.

		The following example adds an item to a collection:

		```hx
		collection.add(object);
		```

		@see `feathers.data.FlatCollectionEvent.ADD_ITEM`

		@since 1.0.0
	**/
	public function add(item:T):Void;

	/**
		Inserts an item into the collection at the specified index, increasing
		the `length` by one.

		The following example adds an item to the start of a collection:

		```hx
		collection.addAt(object, 0);
		```

		@see `feathers.data.FlatCollectionEvent.ADD_ITEM`

		@since 1.0.0
	**/
	public function addAt(item:T, index:Int):Void;

	/**
		Adds all items from one collection to another collection.

		The following example adds a collection of items to another collection:

		```hx
		collection1.addAll(collection2);
		```

		@since 1.0.0
	**/
	public function addAll(collection:IFlatCollection<T>):Void;

	/**
		Adds all items from one collection to another collection.

		The following example adds a collection of items to another collection:

		```hx
		collection1.addAllAt(collection2, 0);
		```

		@since 1.0.0
	**/
	public function addAllAt(collection:IFlatCollection<T>, index:Int):Void;

	/**
		Removes all items from a collection and replaces it with the items from
		another collection.

		The following example resets a collection:

		```hx
		collection1.reset(collection2);
		```

		@see `feathers.data.FlatCollectionEvent.RESET`

		@since 1.0.0
	**/
	public function reset(collection:IFlatCollection<T> = null):Void;

	/**
		Removes a specific item from the collection, decreasing the `length` by
		one, if the item is in the collection.

		The following example removes an item from a collection:

		```hx
		var item = { text: "New Item" };
		collection.add(item);
		collection.remove(item);
		```

		@see `feathers.data.FlatCollectionEvent.REMOVE_ITEM`

		@since 1.0.0
	**/
	public function remove(item:T):Void;

	/**
		Removes an item from the collection at the specified index, decreasing
		the `length` by one.

		```hx
		var item = { text: "New Item" };
		collection.addAt(item, 0);
		collection.removeAt(0);
		```

		@see `feathers.data.FlatCollectionEvent.REMOVE_ITEM`

		@since 1.0.0
	**/
	public function removeAt(index:Int):T;

	/**
		Removes all items from the collection, decreasing its length to zero.

		The following example removes all items from a collection:

		```hx
		collection.removeAll();
		```

		@see `feathers.data.FlatCollectionEvent.REMOVE_ALL`

		@since 1.0.0
	**/
	public function removeAll():Void;

	/**
		Returns the index of the specified item, or `-1` if the item is not in
		the collection.

		The following example gets the index of an item in the collection:

		```hx
		var item = { text: "New Item" };
		collection.addAt(item, 0);

		var index = collection.indexOf(item); // 0
		```

		@since 1.0.0
	**/
	public function indexOf(item:T):Int;

	/**
		Determines if the collection contains the specified item.

		The following example checks if a collection contains an item:

		```hx
		var item = { text: "New Item" };
		collection.addAt(item, 0);

		var contained = collection.contains(item); // true
		```

		@since 1.0.0
	**/
	public function contains(item:T):Bool;

	/**
		Notifies components using the collection that an item at the specified
		index has changed.

		The following example updates an item in the collection:

		```hx
		collection.updateAt(0);
		```

		@see `IFlatCollection.updateAll`
		@see `feathers.data.FlatCollectionEvent.UPDATE_ITEM`

		@since 1.0.0
	**/
	public function updateAt(index:Int):Void;

	/**
		Notifies components using the collection that all items should be
		considered changed.

		The following example updates all items in the collection:

		```hx
		collection.updateAll();
		```

		@see `IFlatCollection.updateAt`
		@see `feathers.data.FlatCollectionEvent.UPDATE_ALL`

		@since 1.0.0
	**/
	public function updateAll():Void;

	/**
		Creates an iterator for the collection.

		@since 1.0.0
	**/
	public function iterator():Iterator<T>;

	/**
		Refreshes the collection using the `filterFunction` or
		`sortCompareFunction` without passing in a new values for these
		properties. Useful when either of these functions relies on external
		variables that have changed.

		The following example refreshes the collection:

		```hx
		var includeAll = true;
		collection.filterFunction = (item) =>
		{
			if(includeAll)
			{
				return true;
			}
			return false;

		};
		includeAll = false;
		collection.refresh();
		```

		@since 1.0.0
	**/
	public function refresh():Void;
}

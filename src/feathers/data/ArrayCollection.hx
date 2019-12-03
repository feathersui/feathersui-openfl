/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.data;

import openfl.errors.RangeError;
import openfl.events.Event;
import feathers.events.FlatCollectionEvent;
import feathers.events.FeathersEvent;
import openfl.events.EventDispatcher;

/**
	Wraps an `Array` in the common `IFlatCollection` API used for data
	collections by many Feathers UI controls, including `ListBox` and `TabBar`

	@since 1.0.0
**/
class ArrayCollection<T> extends EventDispatcher implements IFlatCollection<T> {
	/**
		Creates a new `ArrayCollection` object with the given arguments.

		@since 1.0.0
	**/
	public function new(?array:Array<T>) {
		super();
		if (array == null) {
			array = [];
		}
		this.array = array;
	}

	private var _filterAndSortData:Array<T> = null;

	/**
		The `Array` data source for this collection.

		The following example replaces the data source with a new array:

		```hx
		collection.data = [];
		```

		@since 1.0.0
	**/
	public var array(default, set):Array<T> = null;

	private function set_array(value:Array<T>):Array<T> {
		if (this.array == value) {
			return this.array;
		}
		if (value == null) {
			value = [];
		}
		this.array = value;
		FeathersEvent.dispatch(this, FlatCollectionEvent.RESET);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this.array;
	}

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

	private function get_length():Int {
		if (this._pendingRefresh) {
			this.refreshFilterAndSort();
		}
		if (this._filterAndSortData != null) {
			return this._filterAndSortData.length;
		}
		return this.array.length;
	}

	private var _pendingRefresh:Bool = false;

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

		@since 1.0.0
	**/
	@:isVar
	public var filterFunction(get, set):(T) -> Bool;

	private function get_filterFunction():(T) -> Bool {
		return this.filterFunction;
	}

	private function set_filterFunction(value:(T) -> Bool):(T) -> Bool {
		if (this.filterFunction == value) {
			return this.filterFunction;
		}
		this.filterFunction = value;
		this._pendingRefresh = true;
		FlatCollectionEvent.dispatch(this, FlatCollectionEvent.FILTER_CHANGE, -1);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this.filterFunction;
	}

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

		@since 1.0.0
	**/
	@:isVar
	public var sortCompareFunction(get, set):(T, T) -> Int;

	private function get_sortCompareFunction():(T, T) -> Int {
		return this.sortCompareFunction;
	}

	private function set_sortCompareFunction(value:(T, T) -> Int):(T, T) -> Int {
		if (this.sortCompareFunction == value) {
			return this.sortCompareFunction;
		}
		this.sortCompareFunction = value;
		this._pendingRefresh = true;
		FlatCollectionEvent.dispatch(this, FlatCollectionEvent.SORT_CHANGE, -1);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this.sortCompareFunction;
	}

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
	public function get(index:Int):T {
		if (this._pendingRefresh) {
			this.refreshFilterAndSort();
		}
		if (index < 0 || index >= this.length) {
			throw new RangeError('Failed to get item at index ${index}. Expected a value between 0 and ${this.length - 1}.');
		}
		if (this._filterAndSortData != null) {
			return this._filterAndSortData[index];
		}
		return this.array[index];
	}

	/**
		Replaces the item at the specified index in the collection with a new
		item.

		The following example replaces an item in a collection:

		```hx
		collection.set(0, object);
		```

		@since 1.0.0
	**/
	public function set(index:Int, item:T):Void {
		if (this._pendingRefresh) {
			this.refreshFilterAndSort();
		}
		if (index < 0 || index > this.length) {
			throw new RangeError('Failed to set item at index ${index}. Expected a value between 0 and ${this.length}.');
		}
		if (this._filterAndSortData != null) {
			var oldItem = this._filterAndSortData[index];
			var unfilteredIndex = this.array.indexOf(oldItem);
			this.array[unfilteredIndex] = item;
			if (this.filterFunction != null) {
				var includeItem = this.filterFunction(item);
				if (includeItem) {
					this._filterAndSortData[index] = item;
					FlatCollectionEvent.dispatch(this, FlatCollectionEvent.REPLACE_ITEM, index);
					FeathersEvent.dispatch(this, Event.CHANGE);
					return;
				} else {
					// if the item is excluded, the item at this index is
					// removed instead of being replaced by the new item
					this._filterAndSortData.remove(oldItem);
					FlatCollectionEvent.dispatch(this, FlatCollectionEvent.REMOVE_ITEM, index);
					FeathersEvent.dispatch(this, Event.CHANGE);
					return;
				}
			} else if (this.sortCompareFunction != null) {
				// remove the old item first!
				this._filterAndSortData.remove(oldItem);
				// then try to figure out where the new item goes when inserted
				var sortedIndex = this.getSortedInsertionIndex(item);
				this._filterAndSortData[sortedIndex] = item;
				FlatCollectionEvent.dispatch(this, FlatCollectionEvent.REPLACE_ITEM, index);
				FeathersEvent.dispatch(this, Event.CHANGE);
				return;
			}
		}
		// no filter or sort
		this.array[index] = item;
		FlatCollectionEvent.dispatch(this, FlatCollectionEvent.REPLACE_ITEM, index);
		FeathersEvent.dispatch(this, Event.CHANGE);
	}

	/**
		Inserts an item at the end of the collection, increasing the `length` by
		one.

		The following example adds an item to a collection:

		```hx
		collection.add(object);
		```

		@since 1.0.0
	**/
	public function add(item:T):Void {
		inline this.addAt(item, this.array.length);
	}

	/**
		Inserts an item into the collection at the specified index, increasing
		the `length` by one.

		The following example adds an item to the start of a collection:

		```hx
		collection.addAt(object, 0);
		```

		@since 1.0.0
	**/
	public function addAt(item:T, index:Int):Void {
		this.addAtInternal(item, index, true);
	}

	/**
		Adds all items from one collection to another collection.

		The following example adds a collection of items to another collection:

		```hx
		collection1.addAll(collection2);
		```

		@since 1.0.0
	**/
	public function addAll(collection:IFlatCollection<T>):Void {
		for (item in collection) {
			this.add(item);
		}
	}

	/**
		Adds all items from one collection to another collection.

		The following example adds a collection of items to another collection:

		```hx
		collection1.addAllAt(collection2, 0);
		```

		@since 1.0.0
	**/
	public function addAllAt(collection:IFlatCollection<T>, index:Int):Void {
		if (index < 0 || index > this.length) {
			throw new RangeError('Failed to add collection at index ${index}. Expected a value between 0 and ${this.length}.');
		}
		for (item in collection) {
			this.addAt(item, index);
			index++;
		}
	}

	/**
		Removes all items from a collection and replaces it with the items from
		another collection.

		The following example resets a collection:

		```hx
		collection1.reset(collection2);
		```

		@since 1.0.0
	**/
	public function reset(collection:IFlatCollection<T> = null):Void {
		if (this._pendingRefresh) {
			this.refreshFilterAndSort();
		}
		if (this._filterAndSortData != null) {
			this._filterAndSortData.resize(0);
		}
		this.array.resize(0);
		if (collection != null) {
			for (item in collection) {
				this.addAtInternal(item, this.length, false);
			}
		}
		FlatCollectionEvent.dispatch(this, FlatCollectionEvent.RESET, -1);
		FeathersEvent.dispatch(this, Event.CHANGE);
	}

	/**
		Removes a specific item from the collection, decreasing the `length` by
		one, if the item is in the collection.

		The following example removes an item from a collection:

		```hx
		var item = { text: "New Item" };
		collection.add(item);
		collection.remove(item);
		```

		@since 1.0.0
	**/
	public function remove(item:T):Void {
		if (this._pendingRefresh) {
			this.refreshFilterAndSort();
		}
		var index = this.indexOf(item);
		if (index == -1) {
			// the item is not in the collection
			return;
		}
		if (this._filterAndSortData != null) {
			this._filterAndSortData.remove(item);
		}
		this.array.remove(item);
		FlatCollectionEvent.dispatch(this, FlatCollectionEvent.REMOVE_ITEM, index);
		FeathersEvent.dispatch(this, Event.CHANGE);
	}

	/**
		Removes an item from the collection at the specified index, decreasing
		the `length` by one.

		The following example removes the first item from a collection:

		```hx
		var item = { text: "New Item" };
		collection.addAt(item, 0);
		collection.removeAt(0);
		```

		@since 1.0.0
	**/
	public function removeAt(index:Int):T {
		if (this._pendingRefresh) {
			this.refreshFilterAndSort();
		}
		if (index < 0 || index >= this.length) {
			throw new RangeError('Failed to remove item at index ${index}. Expected a value between 0 and ${this.length - 1}.');
		}
		var item:T = null;
		if (this._filterAndSortData != null) {
			item = this._filterAndSortData[index];
			this._filterAndSortData.remove(item);
			this.array.remove(item);
		} else {
			var item = this.array[index];
			this.array.remove(item);
		}
		FlatCollectionEvent.dispatch(this, FlatCollectionEvent.REMOVE_ITEM, index);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return item;
	}

	/**
		Removes all items from the collection, decreasing its length to zero.

		The following example removes all items from a collection:

		```hx
		collection.removeAll();
		```

		@since 1.0.0
	**/
	public function removeAll():Void {
		if (this._pendingRefresh) {
			this.refreshFilterAndSort();
		}
		if (this._filterAndSortData != null) {
			this._filterAndSortData.resize(0);
		}
		this.array.resize(0);
		FlatCollectionEvent.dispatch(this, FlatCollectionEvent.REMOVE_ALL, -1);
		FeathersEvent.dispatch(this, Event.CHANGE);
	}

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
	public function indexOf(item:T):Int {
		if (this._pendingRefresh) {
			this.refreshFilterAndSort();
		}
		if (this._filterAndSortData != null) {
			return this._filterAndSortData.indexOf(item);
		}
		return this.array.indexOf(item);
	}

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
	public function contains(item:T):Bool {
		return this.indexOf(item) != -1;
	}

	/**
		Creates an iterator for the collection.

		@since 1.0.0
	**/
	public function iterator():Iterator<T> {
		if (this._pendingRefresh) {
			this.refreshFilterAndSort();
		}
		if (this._filterAndSortData != null) {
			return this._filterAndSortData.iterator();
		}
		return this.array.iterator();
	}

	/**
		Notifies components using the collection that an item at the specified
		index has changed.

		The following example updates an item in the collection:

		```hx
		collection.updateAt(0);
		```

		@see `updateAll`
		@see `feathers.data.FlatCollectionEvent.UPDATE_ITEM`

		@since 1.0.0
	**/
	public function updateAt(index:Int):Void {
		if (index < 0 || index >= this.length) {
			throw new RangeError('Failed to update item at index ${index}. Expected a value between 0 and ${this.length - 1}.');
		}
		FlatCollectionEvent.dispatch(this, FlatCollectionEvent.UPDATE_ITEM, index);
	}

	/**
		Notifies components using the collection that all items should be
		considered changed.

		The following example updates all items in the collection:

		```hx
		collection.updateAll();
		```

		@see `updateAt`
		@see `feathers.data.FlatCollectionEvent.UPDATE_ALL`

		@since 1.0.0
	**/
	public function updateAll():Void {
		FlatCollectionEvent.dispatch(this, FlatCollectionEvent.UPDATE_ALL, -1);
	}

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
	public function refresh():Void {
		if (this.filterFunction == null && this.sortCompareFunction == null) {
			return;
		}
		this._pendingRefresh = true;
		if (this.filterFunction != null) {
			FlatCollectionEvent.dispatch(this, FlatCollectionEvent.FILTER_CHANGE, -1);
		}
		if (this.sortCompareFunction != null) {
			FlatCollectionEvent.dispatch(this, FlatCollectionEvent.SORT_CHANGE, -1);
		}
		FeathersEvent.dispatch(this, Event.CHANGE);
	}

	private function refreshFilterAndSort():Void {
		this._pendingRefresh = false;
		if (this.filterFunction != null) {
			var result = this._filterAndSortData;
			if (result != null) {
				// reuse the old array to avoid garbage collection
				result.resize(0);
			} else {
				result = [];
			}
			for (i in 0...this.array.length) {
				var item = this.array[i];
				if (this.filterFunction(item)) {
					result.push(item);
				}
			}
			this._filterAndSortData = result;
		} else if (this.sortCompareFunction != null) // no filter
		{
			var result = this._filterAndSortData;
			if (result != null) {
				result.resize(this.array.length);
				for (i in 0...this.array.length) {
					result[i] = this.array[i];
				}
			} else {
				// simply make a copy!
				result = this.array.slice(0);
			}
			this._filterAndSortData = result;
		} else // no filter or sort
		{
			this._filterAndSortData = null;
		}
		if (this.sortCompareFunction != null) {
			this._filterAndSortData.sort(this.sortCompareFunction);
		}
	}

	private function getSortedInsertionIndex(item:T):Int {
		if (this.sortCompareFunction == null) {
			return this._filterAndSortData.length;
		}
		for (i in 0...this._filterAndSortData.length) {
			var otherItem = this._filterAndSortData[i];
			var result = this.sortCompareFunction(item, otherItem);
			if (result < 1) {
				return i;
			}
		}
		return this._filterAndSortData.length;
	}

	private function addAtInternal(item:T, index:Int, dispatchEvents:Bool):Void {
		if (this._pendingRefresh) {
			this.refreshFilterAndSort();
		}
		if (index < 0 || index > this.length) {
			throw new RangeError('Failed to add item at index ${index}. Expected a value between 0 and ${this.length}.');
		}
		if (this._filterAndSortData != null) {
			// if the item is added at the end of the filtered data
			// then add it at the end of the unfiltered data
			var unfilteredIndex = this.array.length;
			if (index < this._filterAndSortData.length) {
				// find the item at the index in the filtered data, and use its
				// index from the unfiltered data
				var oldItem = this._filterAndSortData[index];
				unfilteredIndex = this.array.indexOf(oldItem);
			}
			// always add to the original data
			this.array.insert(unfilteredIndex, item);
			// but check if the item should be in the filtered data
			var includeItem = true;
			if (this.filterFunction != null) {
				includeItem = this.filterFunction(item);
			}
			if (includeItem) {
				var sortedIndex = index;
				if (this.sortCompareFunction != null) {
					sortedIndex = this.getSortedInsertionIndex(item);
				}
				this._filterAndSortData.insert(sortedIndex, item);
				if (dispatchEvents) {
					// don't dispatch these events if the item is filtered!
					FlatCollectionEvent.dispatch(this, FlatCollectionEvent.ADD_ITEM, index);
					FeathersEvent.dispatch(this, Event.CHANGE);
				}
			}
		} else {
			this.array.insert(index, item);
			if (dispatchEvents) {
				FlatCollectionEvent.dispatch(this, FlatCollectionEvent.ADD_ITEM, index);
				FeathersEvent.dispatch(this, Event.CHANGE);
			}
		}
	}
}

/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.data;

import feathers.events.FeathersEvent;
import feathers.events.FlatCollectionEvent;
import openfl.errors.RangeError;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.utils.IDataInput;
import openfl.utils.IDataOutput;
import openfl.utils.IExternalizable;

/**
	Wraps an `Array` in the common `IFlatCollection` API used for data
	collections by many Feathers UI controls, including `ListView` and `TabBar`.

	@event openfl.events.Event.CHANGE Dispatched when the collection changes.

	@event feathers.events.FlatCollectionEvent.ADD_ITEM Dispatched when
	an item is added to the collection.

	@event feathers.events.FlatCollectionEvent.REMOVE_ITEM Dispatched
	when an item is removed from the collection.

	@event feathers.events.FlatCollectionEvent.REPLACE_ITEM Dispatched
	when an item is replaced in the collection.

	@event feathers.events.FlatCollectionEvent.REMOVE_ALL Dispatched
	when all items are removed from the collection.

	@event feathers.events.FlatCollectionEvent.RESET Dispatched
	when the source of the collection is changed.

	@event feathers.events.FlatCollectionEvent.UPDATE_ITEM Dispatched
	when `IHierarchicalCollection.updateItem()` is called.

	@event feathers.events.FlatCollectionEvent.UPDATE_ALL Dispatched
	when `IHierarchicalCollection.updateAll()` is called.

	@event feathers.events.FlatCollectionEvent.FILTER_CHANGE Dispatched
	when `IFlatCollection.filterFunction` is changed.

	@event feathers.events.FlatCollectionEvent.SORT_CHANGE Dispatched
	when `IFlatCollection.sortCompareFunction` is changed.

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
@:event(feathers.events.FlatCollectionEvent.ADD_ITEM)
@:event(feathers.events.FlatCollectionEvent.REMOVE_ITEM)
@:event(feathers.events.FlatCollectionEvent.REPLACE_ITEM)
@:event(feathers.events.FlatCollectionEvent.REMOVE_ALL)
@:event(feathers.events.FlatCollectionEvent.RESET)
@:event(feathers.events.FlatCollectionEvent.UPDATE_ITEM)
@:event(feathers.events.FlatCollectionEvent.UPDATE_ALL)
@:event(feathers.events.FlatCollectionEvent.FILTER_CHANGE)
@:event(feathers.events.FlatCollectionEvent.SORT_CHANGE)
@defaultXmlProperty("array")
class ArrayCollection<T> extends EventDispatcher implements IFlatCollection<T> implements IExternalizable {
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

	private var _array:Array<T> = null;

	/**
		The `Array` data source for this collection.

		The following example replaces the data source with a new array:

		```haxe
		collection.array = [];
		```

		@since 1.0.0
	**/
	@:bindable("reset")
	public var array(get, set):Array<T>;

	private function get_array():Array<T> {
		return this._array;
	}

	private function set_array(value:Array<T>):Array<T> {
		if (this._array == value) {
			return this._array;
		}
		if (value == null) {
			value = [];
		}
		this._array = value;
		FlatCollectionEvent.dispatch(this, FlatCollectionEvent.RESET, -1);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._array;
	}

	/**
		@see `feathers.data.IFlatCollection.length`
	**/
	@:bindable("change")
	public var length(get, never):Int;

	private function get_length():Int {
		if (this._pendingRefresh) {
			this.refreshFilterAndSort();
		}
		if (this._filterAndSortData != null) {
			return this._filterAndSortData.length;
		}
		return this._array.length;
	}

	private var _pendingRefresh:Bool = false;

	private var _filterFunction:(T) -> Bool = null;

	/**
		@see `feathers.data.IFlatCollection.filterFunction`
	**/
	@:bindable("filterChange")
	public var filterFunction(get, set):(T) -> Bool;

	private function get_filterFunction():(T) -> Bool {
		return this._filterFunction;
	}

	private function set_filterFunction(value:(T) -> Bool):(T) -> Bool {
		if (this._filterFunction == value) {
			return this._filterFunction;
		}
		this._filterFunction = value;
		this._pendingRefresh = true;
		FlatCollectionEvent.dispatch(this, FlatCollectionEvent.FILTER_CHANGE, -1);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._filterFunction;
	}

	private var _sortCompareFunction:(T, T) -> Int = null;

	/**
		@see `feathers.data.IFlatCollection.sortCompareFunction`
	**/
	@:bindable("sortChange")
	public var sortCompareFunction(get, set):(T, T) -> Int;

	private function get_sortCompareFunction():(T, T) -> Int {
		return this._sortCompareFunction;
	}

	private function set_sortCompareFunction(value:(T, T) -> Int):(T, T) -> Int {
		if (this._sortCompareFunction == value) {
			return this._sortCompareFunction;
		}
		this._sortCompareFunction = value;
		this._pendingRefresh = true;
		FlatCollectionEvent.dispatch(this, FlatCollectionEvent.SORT_CHANGE, -1);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._sortCompareFunction;
	}

	/**
		@see `feathers.data.IFlatCollection.get`
	**/
	@:bindable("change")
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
		return this._array[index];
	}

	/**
		@see `feathers.data.IFlatCollection.set`
	**/
	public function set(index:Int, item:T):Void {
		if (this._pendingRefresh) {
			this.refreshFilterAndSort();
		}
		if (index < 0 || index > this.length) {
			throw new RangeError('Failed to set item at index ${index}. Expected a value between 0 and ${this.length}.');
		}
		if (this._filterAndSortData != null) {
			// fall back to placing the new item at the end of the array
			var unfilteredIndex = this._array.length;
			var oldItem = null;
			if (index < this._filterAndSortData.length) {
				oldItem = this._filterAndSortData[index];
				// to determine where the item is placed in the unfiltered array
				// find the unfiltered index of the item being replaced
				unfilteredIndex = this._array.indexOf(oldItem);
			}
			this._array[unfilteredIndex] = item;
			if (this._filterFunction != null) {
				var includeItem = this._filterFunction(item);
				if (index < this._filterAndSortData.length) {
					if (includeItem) {
						// replace the old item
						this._filterAndSortData[index] = item;
						FlatCollectionEvent.dispatch(this, FlatCollectionEvent.REPLACE_ITEM, index, item, oldItem);
						FeathersEvent.dispatch(this, Event.CHANGE);
					} else {
						// if the new item is excluded, the old item at this index
						// is removed instead of being replaced by the new item
						this._filterAndSortData.splice(index, 1);
						FlatCollectionEvent.dispatch(this, FlatCollectionEvent.REMOVE_ITEM, index, null, oldItem);
						FeathersEvent.dispatch(this, Event.CHANGE);
					}
				} else if (includeItem) {
					this._filterAndSortData[this._filterAndSortData.length] = item;
					FlatCollectionEvent.dispatch(this, FlatCollectionEvent.ADD_ITEM, index, item);
					FeathersEvent.dispatch(this, Event.CHANGE);
				}
				return;
			} else if (this._sortCompareFunction != null) {
				// remove the old item first!
				this._filterAndSortData.remove(oldItem);
				// then try to figure out where the new item goes when inserted
				var sortedIndex = this.getSortedInsertionIndex(item);
				this._filterAndSortData[sortedIndex] = item;
				FlatCollectionEvent.dispatch(this, FlatCollectionEvent.REPLACE_ITEM, index, item, oldItem);
				FeathersEvent.dispatch(this, Event.CHANGE);
				return;
			}
		}

		// no filter or sort
		if (index < this._array.length) {
			var oldItem = this._array[index];
			this._array[index] = item;
			FlatCollectionEvent.dispatch(this, FlatCollectionEvent.REPLACE_ITEM, index, item, oldItem);
		} else {
			this._array[index] = item;
			FlatCollectionEvent.dispatch(this, FlatCollectionEvent.ADD_ITEM, index, item);
		}
		FeathersEvent.dispatch(this, Event.CHANGE);
	}

	/**
		@see `feathers.data.IFlatCollection.add`
	**/
	public function add(item:T):Void {
		inline this.addAt(item, this.length);
	}

	/**
		@see `feathers.data.IFlatCollection.addAt`
	**/
	public function addAt(item:T, index:Int):Void {
		this.addAtInternal(item, index, true);
	}

	/**
		@see `feathers.data.IFlatCollection.addAll`
	**/
	public function addAll(collection:IFlatCollection<T>):Void {
		for (item in collection) {
			this.add(item);
		}
	}

	/**
		@see `feathers.data.IFlatCollection.addAllAt`
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
		@see `feathers.data.IFlatCollection.reset`
	**/
	public function reset(collection:IFlatCollection<T> = null):Void {
		if (this._pendingRefresh) {
			this.refreshFilterAndSort();
		}
		if (this._filterAndSortData != null) {
			#if hl
			this._filterAndSortData.splice(0, this._filterAndSortData.length);
			#else
			this._filterAndSortData.resize(0);
			#end
		}
		#if hl
		this._array.splice(0, this._array.length);
		#else
		this._array.resize(0);
		#end
		if (collection != null) {
			for (item in collection) {
				this.addAtInternal(item, this.length, false);
			}
		}
		FlatCollectionEvent.dispatch(this, FlatCollectionEvent.RESET, -1);
		FeathersEvent.dispatch(this, Event.CHANGE);
	}

	/**
		@see `feathers.data.IFlatCollection.remove`
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
		this._array.remove(item);
		FlatCollectionEvent.dispatch(this, FlatCollectionEvent.REMOVE_ITEM, index, null, item);
		FeathersEvent.dispatch(this, Event.CHANGE);
	}

	/**
		@see `feathers.data.IFlatCollection.removeAt`
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
			this._array.remove(item);
		} else {
			item = this._array[index];
			this._array.remove(item);
		}
		FlatCollectionEvent.dispatch(this, FlatCollectionEvent.REMOVE_ITEM, index, null, item);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return item;
	}

	/**
		@see `feathers.data.IFlatCollection.removeAll`
	**/
	public function removeAll():Void {
		if (this._pendingRefresh) {
			this.refreshFilterAndSort();
		}
		if (this._array.length == 0) {
			// nothing to remove
			return;
		}
		if (this._filterAndSortData != null) {
			#if hl
			this._filterAndSortData.splice(0, this._filterAndSortData.length);
			#else
			this._filterAndSortData.resize(0);
			#end
		}
		#if hl
		this._array.splice(0, this._array.length);
		#else
		this._array.resize(0);
		#end
		FlatCollectionEvent.dispatch(this, FlatCollectionEvent.REMOVE_ALL, -1);
		FeathersEvent.dispatch(this, Event.CHANGE);
	}

	/**
		@see `feathers.data.IFlatCollection.indexOf`
	**/
	public function indexOf(item:T):Int {
		if (this._pendingRefresh) {
			this.refreshFilterAndSort();
		}
		if (this._filterAndSortData != null) {
			return this._filterAndSortData.indexOf(item);
		}
		return this._array.indexOf(item);
	}

	/**
		@see `feathers.data.IFlatCollection.contains`
	**/
	public function contains(item:T):Bool {
		return this.indexOf(item) != -1;
	}

	/**
		@see `feathers.data.IFlatCollection.iterator`
	**/
	public function iterator():Iterator<T> {
		if (this._pendingRefresh) {
			this.refreshFilterAndSort();
		}
		if (this._filterAndSortData != null) {
			return this._filterAndSortData.iterator();
		}
		return this._array.iterator();
	}

	/**
		@see `feathers.data.IFlatCollection.updateAt`
	**/
	public function updateAt(index:Int):Void {
		if (index < 0 || index >= this.length) {
			throw new RangeError('Failed to update item at index ${index}. Expected a value between 0 and ${this.length - 1}.');
		}
		FlatCollectionEvent.dispatch(this, FlatCollectionEvent.UPDATE_ITEM, index);
		this.refresh();
	}

	/**
		@see `feathers.data.IFlatCollection.updateAll`
	**/
	public function updateAll():Void {
		FlatCollectionEvent.dispatch(this, FlatCollectionEvent.UPDATE_ALL, -1);
		this.refresh();
	}

	/**
		@see `feathers.data.IFlatCollection.refresh`
	**/
	public function refresh():Void {
		if (this._filterFunction == null && this._sortCompareFunction == null) {
			return;
		}
		this._pendingRefresh = true;
		if (this._filterFunction != null) {
			FlatCollectionEvent.dispatch(this, FlatCollectionEvent.FILTER_CHANGE, -1);
		}
		if (this._sortCompareFunction != null) {
			FlatCollectionEvent.dispatch(this, FlatCollectionEvent.SORT_CHANGE, -1);
		}
		FeathersEvent.dispatch(this, Event.CHANGE);
	}

	/**
		Using a callback that returns either `true` or `false`, returns the
		first item in the collection where the callback returns `true`.

		@since 1.0.0
	**/
	public function find(callback:(item:T, index:Int, collection:ArrayCollection<T>) -> Bool):T {
		for (i in 0...this.length) {
			var item = this.get(i);
			var result = callback(item, i, this);
			if (result) {
				return item;
			}
		}
		return null;
	}

	/**
		Using a callback that returns either `true` or `false`, returns the
		first item in the collection where the callback returns `true`.

		@since 1.0.0
	**/
	public function findIndex(callback:(item:T, index:Int, collection:ArrayCollection<T>) -> Bool):Int {
		for (i in 0...this.length) {
			var item = this.get(i);
			var result = callback(item, i, this);
			if (result) {
				return i;
			}
		}
		return -1;
	}

	/**
		Using a callback that returns either `true` or `false`, determines if
		at all items in the collection return `true`.

		@since 1.0.0
	**/
	public function some(callback:(item:T, index:Int, collection:ArrayCollection<T>) -> Bool):Bool {
		for (i in 0...this.length) {
			var item = this.get(i);
			var result = callback(item, i, this);
			if (result) {
				return true;
			}
		}
		return false;
	}

	/**
		Using a callback that returns either `true` or `false`, determines if
		at least one item in the collection returns `true`.

		@since 1.0.0
	**/
	public function every(callback:(item:T, index:Int, collection:ArrayCollection<T>) -> Bool):Bool {
		for (i in 0...this.length) {
			var item = this.get(i);
			var result = callback(item, i, this);
			if (!result) {
				return false;
			}
		}
		return true;
	}

	/**
		Iterates through every item in the collection and passes it to a
		callback.

		@since 1.0.0
	**/
	public function forEach(callback:(item:T, index:Int, collection:ArrayCollection<T>) -> Void):Void {
		for (i in 0...this.length) {
			var item = this.get(i);
			callback(item, i, this);
		}
	}

	/**
		Creates a new collection using a callback for each item in the existing
		collection.

		@since 1.0.0
	**/
	public function map<U>(callback:(item:T, index:Int, collection:ArrayCollection<T>) -> U):ArrayCollection<U> {
		var result:Array<U> = [];
		for (i in 0...this.length) {
			var item = this.get(i);
			result.push(callback(item, i, this));
		}
		return new ArrayCollection(result);
	}

	@:dox(hide)
	public function readExternal(input:IDataInput):Void {
		this.array = Std.downcast(input.readObject(), Array);
	}

	@:dox(hide)
	public function writeExternal(output:IDataOutput):Void {
		output.writeObject(this.array);
	}

	private function refreshFilterAndSort():Void {
		this._pendingRefresh = false;
		var oldFilterAndSortData = this._filterAndSortData;
		// set to null while applying filter so that locationOf() works properly
		this._filterAndSortData = null;
		if (this._filterFunction != null) {
			var result = oldFilterAndSortData;
			if (result != null) {
				// reuse the old array to avoid garbage collection
				#if hl
				result.splice(0, result.length);
				#else
				result.resize(0);
				#end
			} else {
				result = [];
			}
			for (i in 0...this._array.length) {
				var item = this._array[i];
				if (this._filterFunction(item)) {
					result.push(item);
				}
			}
			this._filterAndSortData = result;
		} else if (this._sortCompareFunction != null) // no filter
		{
			var result = oldFilterAndSortData;
			if (result != null) {
				result.resize(this._array.length);
				for (i in 0...this._array.length) {
					result[i] = this._array[i];
				}
			} else {
				// simply make a copy!
				result = this._array.slice(0);
			}
			this._filterAndSortData = result;
		}
		if (this._sortCompareFunction != null) {
			this._filterAndSortData.sort(this._sortCompareFunction);
		}
	}

	/**
		Returns a new array containing the items in the collection, honoring the
		current filter and sort, if any.

		@since 1.0.0
	**/
	public function toArray():Array<T> {
		if (this._filterAndSortData != null) {
			return this._filterAndSortData.copy();
		}
		return this._array.copy();
	}

	private function getSortedInsertionIndex(item:T):Int {
		if (this._sortCompareFunction == null) {
			return this._filterAndSortData.length;
		}
		for (i in 0...this._filterAndSortData.length) {
			var otherItem = this._filterAndSortData[i];
			var result = this._sortCompareFunction(item, otherItem);
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
			var unfilteredIndex = this._array.length;
			if (index < this._filterAndSortData.length) {
				// find the item at the index in the filtered data, and use its
				// index from the unfiltered data
				var oldItem = this._filterAndSortData[index];
				unfilteredIndex = this._array.indexOf(oldItem);
			}
			// always add to the original data
			this._array.insert(unfilteredIndex, item);
			// but check if the item should be in the filtered data
			var includeItem = true;
			if (this._filterFunction != null) {
				includeItem = this._filterFunction(item);
			}
			if (includeItem) {
				var sortedIndex = index;
				if (this._sortCompareFunction != null) {
					sortedIndex = this.getSortedInsertionIndex(item);
				}
				this._filterAndSortData.insert(sortedIndex, item);
				if (dispatchEvents) {
					// don't dispatch these events if the item is filtered!
					FlatCollectionEvent.dispatch(this, FlatCollectionEvent.ADD_ITEM, index, item);
					FeathersEvent.dispatch(this, Event.CHANGE);
				}
			}
		} else {
			this._array.insert(index, item);
			if (dispatchEvents) {
				FlatCollectionEvent.dispatch(this, FlatCollectionEvent.ADD_ITEM, index, item);
				FeathersEvent.dispatch(this, Event.CHANGE);
			}
		}
	}
}

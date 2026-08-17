/*
	Feathers UI
	Copyright 2026 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.data;

import feathers.events.FeathersEvent;
import feathers.events.FlatCollectionEvent;
import openfl.Vector;
import openfl.errors.RangeError;
import openfl.events.Event;
import openfl.events.EventDispatcher;

/**
	Wraps a `Vector` in the common `IFlatCollection` API used for data
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
	when `IHierarchicalCollection.updateAt()` is called.

	@event feathers.events.FlatCollectionEvent.UPDATE_ALL Dispatched
	when `IHierarchicalCollection.updateAll()` is called.

	@event feathers.events.FlatCollectionEvent.FILTER_CHANGE Dispatched
	when `IFlatCollection.filterFunction` is changed.

	@event feathers.events.FlatCollectionEvent.SORT_CHANGE Dispatched
	when `IFlatCollection.sortCompareFunction` is changed.

	@since 1.4.0
**/
#if flash
// needed to workaround the following error on the flash target when the
// constructor is called with zero arguments.
// > Cannot create Vector without knowing runtime type
@:generic
#end
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
@defaultXmlProperty("vector")
class VectorCollection<T> extends EventDispatcher implements IFlatCollection<T> {
	/**
		Creates a new `VectorCollection` object with the given arguments.

		@since 1.4.0
	**/
	public function new(?vector:Vector<T>) {
		super();
		if (vector == null) {
			vector = new Vector<T>();
		}
		this.vector = vector;
	}

	private var _filterAndSortData:Vector<T> = null;

	private var _vector:Vector<T> = null;

	/**
		The `Vector` data source for this collection.

		The following example replaces the data source with a new vector:

		```haxe
		collection.vector = new openfl.Vector<Float>();
		```

		@since 1.4.0
	**/
	@:bindable("reset")
	public var vector(get, set):Vector<T>;

	private function get_vector():Vector<T> {
		return this._vector;
	}

	private function set_vector(value:Vector<T>):Vector<T> {
		if (this._vector == value) {
			return this._vector;
		}
		if (value == null) {
			value = new Vector<T>();
		}
		this._vector = value;
		this._pendingRefresh = true;
		FlatCollectionEvent.dispatch(this, FlatCollectionEvent.RESET, -1);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._vector;
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
		return this._vector.length;
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
		return this._vector[index];
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
		var sourceIndex:Int = -1;
		var removedItem:Null<T> = null;
		if (this._filterAndSortData != null) {
			if (index < this._filterAndSortData.length) {
				removedItem = this._filterAndSortData[index];
				sourceIndex = this._vector.indexOf(removedItem);
			}
		} else {
			if (index < this._vector.length) {
				removedItem = this._vector[index];
				sourceIndex = index;
			}
		}
		if (sourceIndex >= 0) {
			this._vector[sourceIndex] = item;
		} else {
			this._vector.push(item);
		}
		var newIndex = index;
		if (this._filterAndSortData != null) {
			this.refreshFilterAndSort();
			newIndex = this._filterAndSortData.indexOf(item);
		}

		switch ([sourceIndex >= 0, newIndex >= 0]) {
			case [true, true]:
				if (index == newIndex) {
					FlatCollectionEvent.dispatch(this, FlatCollectionEvent.REPLACE_ITEM, index, item, removedItem);
				} else {
					FlatCollectionEvent.dispatch(this, FlatCollectionEvent.REMOVE_ITEM, index, item);
					FlatCollectionEvent.dispatch(this, FlatCollectionEvent.ADD_ITEM, newIndex, item);
				}
				FeathersEvent.dispatch(this, Event.CHANGE);
			case [false, true]:
				FlatCollectionEvent.dispatch(this, FlatCollectionEvent.ADD_ITEM, newIndex, item);
				FeathersEvent.dispatch(this, Event.CHANGE);
			case [true, false]:
				FlatCollectionEvent.dispatch(this, FlatCollectionEvent.REMOVE_ITEM, index, null, removedItem);
				FeathersEvent.dispatch(this, Event.CHANGE);
			case [false, false]:
				// display vector did not change
		}
	}

	/**
		@see `feathers.data.IFlatCollection.add`
	**/
	public function add(item:T):Void {
		this._vector.push(item);
		this._pendingRefresh = true;
		var newIndex:Int = this.indexOf(item);
		if (newIndex >= 0) {
			FlatCollectionEvent.dispatch(this, FlatCollectionEvent.ADD_ITEM, newIndex, item);
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
	}

	/**
		@see `feathers.data.IFlatCollection.addAt`
	**/
	public function addAt(item:T, index:Int):Void {
		if (this._pendingRefresh) {
			this.refreshFilterAndSort();
		}
		if (index < 0 || index > this.length) {
			throw new RangeError('Failed to add item at index ${index}. Expected a value between 0 and ${this.length}.');
		}
		this._vector.insertAt(findAddAtIndex(index), item);
		this._pendingRefresh = true;
		var newIndex:Int = this.indexOf(item);
		if (newIndex >= 0) {
			FlatCollectionEvent.dispatch(this, FlatCollectionEvent.ADD_ITEM, newIndex, item);
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
	}

	/**
		@see `feathers.data.IFlatCollection.addAll`
	**/
	public function addAll(collection:IFlatCollection<T>):Void {
		if (this._pendingRefresh) {
			this.refreshFilterAndSort();
		}
		inline addAllAt(collection, this.length);
	}

	/**
		@see `feathers.data.IFlatCollection.addAllAt`
	**/
	public function addAllAt(collection:IFlatCollection<T>, index:Int):Void {
		if (this._pendingRefresh) {
			this.refreshFilterAndSort();
		}
		if (index < 0 || index > this.length) {
			throw new RangeError('Failed to add collection at index ${index}. Expected a value between 0 and ${this.length}.');
		}
		index = findAddAtIndex(index);
		for (item in collection) {
			this._vector.insertAt(index, item);
			index++;
		}
		if (this._filterAndSortData != null) {
			this.refreshFilterAndSort();
			for (item in collection) {
				var newIndex:Int = this._filterAndSortData.indexOf(item);
				if (newIndex >= 0) {
					FlatCollectionEvent.dispatch(this, FlatCollectionEvent.ADD_ITEM, newIndex, item);
				}
			}
		} else {
			for (item in collection) {
				FlatCollectionEvent.dispatch(this, FlatCollectionEvent.ADD_ITEM, this._vector.indexOf(item), item);
			}
		}
		FeathersEvent.dispatch(this, Event.CHANGE);
	}

	/**
		@see `feathers.data.IFlatCollection.reset`
	**/
	public function reset(collection:IFlatCollection<T> = null):Void {
		if (this._filterAndSortData != null) {
			this._filterAndSortData.length = 0;
		}
		this._vector.length = 0;
		if (collection != null) {
			for (item in collection) {
				this._vector.push(item);
			}
		}
		this._pendingRefresh = true;
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
		var sortedIndex = -1;
		if (this._filterAndSortData != null) {
			sortedIndex = this._filterAndSortData.indexOf(item);
			if (sortedIndex == -1) {
				return;
			}
			this._filterAndSortData.removeAt(sortedIndex);
		}
		var unsortedIndex = this._vector.indexOf(item);
		if (unsortedIndex == -1) {
			// this should never happen
			return;
		}
		this._vector.removeAt(unsortedIndex);
		if (sortedIndex == -1) {
			sortedIndex = unsortedIndex;
		}
		FlatCollectionEvent.dispatch(this, FlatCollectionEvent.REMOVE_ITEM, sortedIndex, null, item);
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
		var item:Null<T> = null;
		if (this._filterAndSortData != null) {
			item = this._filterAndSortData[index];
			this._filterAndSortData.removeAt(index);
			var vectorIndex = this._vector.indexOf(item);
			this._vector.removeAt(vectorIndex);
		} else {
			item = this._vector[index];
			this._vector.removeAt(index);
		}
		FlatCollectionEvent.dispatch(this, FlatCollectionEvent.REMOVE_ITEM, index, null, item);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return item;
	}

	/**
		@see `feathers.data.IFlatCollection.removeAll`
	**/
	public function removeAll():Void {
		if (this._filterAndSortData != null) {
			this._filterAndSortData.length = 0;
		}
		if (this._vector.length == 0) {
			// nothing to remove
			return;
		}
		this._vector.length = 0;
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
		return this._vector.indexOf(item);
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
		return this._vector.iterator();
	}

	/**
		@see `feathers.data.IFlatCollection.updateAt`
	**/
	public function updateAt(index:Int):Void {
		if (index < 0 || index >= this.length) {
			throw new RangeError('Failed to update item at index ${index}. Expected a value between 0 and ${this.length - 1}.');
		}
		if (this._filterFunction != null || this._sortCompareFunction != null) {
			this._pendingRefresh = true;
		}
		FlatCollectionEvent.dispatch(this, FlatCollectionEvent.UPDATE_ITEM, index);
		FeathersEvent.dispatch(this, Event.CHANGE);
	}

	/**
		@see `feathers.data.IFlatCollection.updateAll`
	**/
	public function updateAll():Void {
		if (this._filterFunction != null || this._sortCompareFunction != null) {
			this._pendingRefresh = true;
		}
		FlatCollectionEvent.dispatch(this, FlatCollectionEvent.UPDATE_ALL, -1);
		FeathersEvent.dispatch(this, Event.CHANGE);
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

		@since 1.4.0
	**/
	public function find(callback:(item:T, index:Int, collection:VectorCollection<T>) -> Bool):Null<T> {
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
		index of the first item in the collection where the callback returns
		`true`.

		@since 1.4.0
	**/
	public function findIndex(callback:(item:T, index:Int, collection:VectorCollection<T>) -> Bool):Int {
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
		at least one item in the collection returns `true`.

		@since 1.4.0
	**/
	public function some(callback:(item:T, index:Int, collection:VectorCollection<T>) -> Bool):Bool {
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
		all items in the collection return `true`.

		@since 1.4.0
	**/
	public function every(callback:(item:T, index:Int, collection:VectorCollection<T>) -> Bool):Bool {
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

		@since 1.4.0
	**/
	public function forEach(callback:(item:T, index:Int, collection:VectorCollection<T>) -> Void):Void {
		for (i in 0...this.length) {
			var item = this.get(i);
			callback(item, i, this);
		}
	}

	/**
		Creates a new collection using a callback for each item in the existing
		collection.

		@since 1.4.0
	**/
	public function map<U>(callback:(item:T, index:Int, collection:VectorCollection<T>) -> U):VectorCollection<U> {
		var result:Vector<U> = new Vector<U>(this.length);
		for (i in 0...this.length) {
			var item = this.get(i);
			result[i] = callback(item, i, this);
		}
		return new VectorCollection(result);
	}

	private function refreshFilterAndSort():Void {
		this._pendingRefresh = false;
		if (this._filterFunction == null && this._sortCompareFunction == null) {
			this._filterAndSortData = null;
			return;
		}

		if (this._filterAndSortData == null) {
			this._filterAndSortData = this._vector.copy();
		} else {
			this._filterAndSortData.length = this._vector.length;
			for (i in 0...this._vector.length) {
				this._filterAndSortData[i] = this._vector[i];
			}
		}

		if (this._filterFunction != null) {
			var newLength:Int = 0;
			for (item in this._filterAndSortData) {
				if (this._filterFunction(item)) {
					this._filterAndSortData[newLength] = item;
					newLength++;
				}
			}
			this._filterAndSortData.length = newLength;
		}

		if (this._sortCompareFunction != null) {
			this._filterAndSortData.sort(this._sortCompareFunction);
		}
	}

	/**
		Returns a new array containing the items in the collection, honoring the
		current filter and sort, if any.

		@since 1.4.0
	**/
	public function toArray():Array<T> {
		if (this._filterAndSortData != null) {
			var result:Array<T> = [];
			for (i in 0...this._filterAndSortData.length) {
				result[i] = this._filterAndSortData[i];
			}
			return result;
		}
		var result:Array<T> = [];
		for (i in 0...this._vector.length) {
			result[i] = this._vector[i];
		}
		return result;
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
	
	/**
		Given a user-specified index, finds where an `addAt` function should
		insert values into `_vector`. This defaults to `_vector.length` and
		never returns -1.
	**/
	private function findAddAtIndex(index:Int):Int {
		if (this._filterAndSortData == null) {
			return index;
		} else if (index >= 0 && index < this._filterAndSortData.length) {
			var item:T = this._filterAndSortData[index];
			var result:Int = this._vector.indexOf(item);
			if (result >= 0) {
				return result;
			}
		}
		return this._vector.length;
	}
}

/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.data;

import feathers.events.FeathersEvent;
import feathers.events.HierarchicalCollectionEvent;
import openfl.errors.RangeError;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.utils.IDataInput;
import openfl.utils.IDataOutput;
import openfl.utils.IExternalizable;

/**
	Wraps an `Array` data source with a common API for use with UI controls that
	support hierarchical data, such as `TreeView`.

	@event openfl.events.Event.CHANGE

	@event feathers.events.HierarchicalCollectionEvent.ADD_ITEM

	@event feathers.events.HierarchicalCollectionEvent.REMOVE_ITEM

	@event feathers.events.HierarchicalCollectionEvent.REPLACE_ITEM

	@event feathers.events.HierarchicalCollectionEvent.REMOVE_ALL

	@event feathers.events.HierarchicalCollectionEvent.RESET

	@event feathers.events.HierarchicalCollectionEvent.UPDATE_ITEM

	@event feathers.events.HierarchicalCollectionEvent.UPDATE_ALL

	@event feathers.events.HierarchicalCollectionEvent.FILTER_CHANGE

	@event feathers.events.HierarchicalCollectionEvent.SORT_CHANGE

	@see `feathers.controls.TreeView`

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
@:meta(DefaultProperty("array"))
@defaultXmlProperty("array")
class ArrayHierarchicalCollection<T> extends EventDispatcher implements IHierarchicalCollection<T> implements IExternalizable {
	/**
		Creates a new `ArrayHierarchicalCollection` object with the given arguments.

		@since 1.0.0
	**/
	public function new(?array:Array<T>, ?itemToChildren:(T) -> Array<T>) {
		super();
		if (array == null) {
			array = [];
		}
		this.array = array;
		this.itemToChildren = itemToChildren;
	}

	private var _filterAndSortData:Array<FilterAndSortItem<T>> = null;

	private var _array:Array<T> = null;

	/**
		The `Array<T>` data source for this collection.

		The following example replaces the data source with a new array:

		```hx
		collection.array = [];
		```

		@since 1.0.0
	**/
	@:flash.property
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
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.RESET, null);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._array;
	}

	private var _itemToChildren:(T) -> Array<T>;

	/**
		A function that returns an item's children. If the item is not a branch,
		the function should return `null`. If the item is a branch, but it
		contains no children, the function should return an empty array.

		@since 1.0.0
	**/
	public var itemToChildren(get, set):(T) -> Array<T>;

	private function get_itemToChildren():(T) -> Array<T> {
		return this._itemToChildren;
	}

	private function set_itemToChildren(value:(T) -> Array<T>):(T) -> Array<T> {
		if (this._itemToChildren == value) {
			return this._itemToChildren;
		}
		this._itemToChildren = value;
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.RESET, null);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._itemToChildren;
	}

	private var _pendingRefresh:Bool = false;

	private var _filterFunction:(T) -> Bool = null;

	/**
		@see `feathers.data.IHierarchicalCollection.filterFunction`
	**/
	@:flash.property
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
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.FILTER_CHANGE, null);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._filterFunction;
	}

	private var _sortCompareFunction:(T, T) -> Int = null;

	/**
		@see `feathers.data.IHierarchicalCollection.sortCompareFunction`
	**/
	@:flash.property
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
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.SORT_CHANGE, null);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._sortCompareFunction;
	}

	/**
		@see `feathers.data.IHierarchicalCollection.getLength`
	**/
	public function getLength(?location:Array<Int>):Int {
		if (this._pendingRefresh) {
			this.refreshFilterAndSort();
		}
		var branchChildren:Array<Dynamic> = this._array;
		var itemToChildren:(Dynamic) -> Array<Dynamic> = this._itemToChildren;
		if (this._filterAndSortData != null) {
			branchChildren = this._filterAndSortData;
			itemToChildren = this.filterAndSortDataItemToChildren;
		}
		if (location != null && location.length > 0) {
			for (i in 0...location.length) {
				var index = location[i];
				if (index < 0 || index >= branchChildren.length) {
					throw new RangeError('Branch not found at location: ${location}');
				}
				var child = branchChildren[index];
				branchChildren = (itemToChildren != null) ? itemToChildren(child) : null;
				if (branchChildren == null) {
					throw new RangeError('Branch not found at location: ${location}');
				}
			}
		}
		return branchChildren.length;
	}

	/**
		@see `feathers.data.IHierarchicalCollection.get`
	**/
	public function get(location:Array<Int>):T {
		if (this._pendingRefresh) {
			this.refreshFilterAndSort();
		}
		if (location == null || location.length == 0) {
			throw new RangeError('Item not found at location: ${location}');
		}
		if (this._filterAndSortData != null) {
			var branchChildren = this.findBranchChildren(this._filterAndSortData, this.filterAndSortDataItemToChildren, location);
			var index = location[location.length - 1];
			if (index < 0 || index >= branchChildren.length) {
				throw new RangeError('Item not found at location: ${location}');
			}
			return branchChildren[index].item;
		}
		var branchChildren = this.findBranchChildren(this._array, this._itemToChildren, location);
		var index = location[location.length - 1];
		if (index < 0 || index >= branchChildren.length) {
			throw new RangeError('Item not found at location: ${location}');
		}
		return branchChildren[index];
	}

	/**
		@see `feathers.data.IHierarchicalCollection.set`
	**/
	public function set(location:Array<Int>, value:T):Void {
		if (this._pendingRefresh) {
			this.refreshFilterAndSort();
		}
		if (location == null || location.length == 0) {
			throw new RangeError('Item not found at location: ${location}');
		}
		if (this._filterAndSortData != null) {
			var lastLocationIndex = location[location.length - 1];
			var branchChildren = this.findBranchChildren(this._array, this._itemToChildren, location);
			var filteredOrSortedBranchChildren = this.findBranchChildren(this._filterAndSortData, this.filterAndSortDataItemToChildren, location);
			var oldItem:T = null;
			var unfilteredLastLocationIndex = branchChildren.length;
			if (lastLocationIndex < filteredOrSortedBranchChildren.length) {
				oldItem = filteredOrSortedBranchChildren[lastLocationIndex].item;
				unfilteredLastLocationIndex = branchChildren.indexOf(oldItem);
			}
			branchChildren[unfilteredLastLocationIndex] = value;
			if (this._filterFunction != null) {
				var includeItem = this._filterFunction(value);
				if (lastLocationIndex < filteredOrSortedBranchChildren.length) {
					if (includeItem) {
						// replace the old item
						filteredOrSortedBranchChildren[lastLocationIndex] = this.createFilterAndSortItem(value);
						HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.REPLACE_ITEM, location, value, oldItem);
						FeathersEvent.dispatch(this, Event.CHANGE);
					} else {
						// if the new item is excluded, the old item at this index
						// is removed instead of being replaced by the new item
						filteredOrSortedBranchChildren.splice(lastLocationIndex, 1);
						HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.REMOVE_ITEM, location, null, oldItem);
						FeathersEvent.dispatch(this, Event.CHANGE);
					}
				} else if (includeItem) {
					filteredOrSortedBranchChildren[filteredOrSortedBranchChildren.length] = this.createFilterAndSortItem(value);
					HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.ADD_ITEM, location, value);
					FeathersEvent.dispatch(this, Event.CHANGE);
				}
			} else if (this._sortCompareFunction != null) {
				// remove the old item first!
				filteredOrSortedBranchChildren.splice(lastLocationIndex, 1);
				// then try to figure out where the new item goes when inserted
				var wrappedItem = this.createFilterAndSortItem(value);
				var sortedIndex = this.getSortedInsertionIndex(filteredOrSortedBranchChildren, wrappedItem);
				filteredOrSortedBranchChildren[sortedIndex] = wrappedItem;
				HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.REPLACE_ITEM, location, value, oldItem);
				FeathersEvent.dispatch(this, Event.CHANGE);
				return;
			}
			return;
		}
		var branchChildren = this.findBranchChildren(this._array, this._itemToChildren, location);
		var index = location[location.length - 1];
		if (index < 0 || index > branchChildren.length) {
			throw new RangeError('Item not found at location: ${location}');
		}
		var oldValue = branchChildren[index];
		branchChildren[index] = value;
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.REPLACE_ITEM, location, value, oldValue);
		FeathersEvent.dispatch(this, Event.CHANGE);
	}

	/**
		@see `feathers.data.IHierarchicalCollection.isBranch`
	**/
	public function isBranch(item:T):Bool {
		if (item == null) {
			return false;
		}
		var children = (this._itemToChildren != null) ? this._itemToChildren(item) : null;
		return children != null;
	}

	/**
		@see `feathers.data.IHierarchicalCollection.locationOf`
	**/
	public function locationOf(item:T):Array<Int> {
		if (this._pendingRefresh) {
			this.refreshFilterAndSort();
		}
		var result:Array<Int> = [];
		var found = false;
		if (this._filterAndSortData != null) {
			found = this.findItemInFilteredOrSortedBranch(this._filterAndSortData, item, result);
		} else {
			found = this.findItemInBranch(this._array, item, result);
		}
		if (!found) {
			return null;
		}
		return result;
	}

	/**
		@see `feathers.data.IHierarchicalCollection.locationOf`
	**/
	public function contains(item:T):Bool {
		return this.locationOf(item) != null;
	}

	/**
		@see `feathers.data.IHierarchicalCollection.addAt`
	**/
	public function addAt(itemToAdd:T, location:Array<Int>):Void {
		if (this._pendingRefresh) {
			this.refreshFilterAndSort();
		}
		if (location == null || location.length == 0) {
			throw new RangeError('Item cannot be added at location: ${location}');
		}
		if (this._filterAndSortData != null) {
			var lastLocationIndex = location[location.length - 1];
			var branchChildren = this.findBranchChildren(this._array, this._itemToChildren, location);
			var filteredOrSortedBranchChildren = this.findBranchChildren(this._filterAndSortData, filterAndSortDataItemToChildren, location);
			var oldItem:T = null;
			var unfilteredLastLocationIndex = branchChildren.length;
			if (lastLocationIndex < filteredOrSortedBranchChildren.length) {
				oldItem = filteredOrSortedBranchChildren[lastLocationIndex].item;
				unfilteredLastLocationIndex = branchChildren.indexOf(oldItem);
			}
			// always add to the original data
			branchChildren.insert(unfilteredLastLocationIndex, itemToAdd);
			// but check if the item should be in the filtered data
			var includeItem = true;
			if (this._filterFunction != null) {
				includeItem = this._filterFunction(itemToAdd);
			}
			if (includeItem) {
				var sortedIndex = lastLocationIndex;
				var wrappedItem = this.createFilterAndSortItem(itemToAdd);
				if (this._sortCompareFunction != null) {
					sortedIndex = this.getSortedInsertionIndex(filteredOrSortedBranchChildren, wrappedItem);
				}
				filteredOrSortedBranchChildren.insert(sortedIndex, wrappedItem);
				// don't dispatch these events if the item is filtered!
				HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.ADD_ITEM, location, itemToAdd);
				FeathersEvent.dispatch(this, Event.CHANGE);
			}
			return;
		}
		var branchChildren = this.findBranchChildren(this._array, this._itemToChildren, location);
		var index = location[location.length - 1];
		if (index < 0 || index > branchChildren.length) {
			throw new RangeError('Item cannot be added at location: ${location}');
		}
		branchChildren.insert(index, itemToAdd);
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.ADD_ITEM, location, itemToAdd);
		FeathersEvent.dispatch(this, Event.CHANGE);
	}

	/**
		@see `feathers.data.IHierarchicalCollection.removeAt`
	**/
	public function removeAt(location:Array<Int>):T {
		if (this._pendingRefresh) {
			this.refreshFilterAndSort();
		}
		if (location == null || location.length == 0) {
			throw new RangeError('Item not found at location: ${location}');
		}
		if (this._filterAndSortData != null) {
			var lastLocationIndex = location[location.length - 1];
			var branchChildren = this.findBranchChildren(this._array, this._itemToChildren, location);
			var filteredOrSortedBranchChildren = this.findBranchChildren(this._filterAndSortData, filterAndSortDataItemToChildren, location);
			var removedItem = filteredOrSortedBranchChildren.splice(lastLocationIndex, 1)[0].item;
			branchChildren.remove(removedItem);
			HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.REMOVE_ITEM, location, null, removedItem);
			FeathersEvent.dispatch(this, Event.CHANGE);
			return removedItem;
		}
		var branchChildren = this.findBranchChildren(this._array, this._itemToChildren, location);
		var index = location[location.length - 1];
		if (index < 0 || index >= branchChildren.length) {
			throw new RangeError('Item not found at location: ${location}');
		}
		var removedItem = branchChildren[index];
		branchChildren.remove(removedItem);
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.REMOVE_ITEM, location, null, removedItem);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return removedItem;
	}

	/**
		@see `feathers.data.IHierarchicalCollection.remove`
	**/
	public function remove(item:T):Void {
		var location = this.locationOf(item);
		if (location == null) {
			// nothing to remove
			return;
		}
		this.removeAt(location);
	}

	/**
		@see `feathers.data.IHierarchicalCollection.removeAll`
	**/
	public function removeAll(?location:Array<Int>):Void {
		if (this._pendingRefresh) {
			this.refreshFilterAndSort();
		}
		if (this._array.length == 0) {
			// nothing to remove
			return;
		}
		if (location == null || location.length == 0) {
			if (this._filterAndSortData != null) {
				this._filterAndSortData.resize(0);
			}
			this._array.resize(0);
			HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.REMOVE_ALL, null);
			FeathersEvent.dispatch(this, Event.CHANGE);
			return;
		}
		if (this._filterAndSortData != null) {
			var firstChildLocation = location.copy();
			firstChildLocation.push(0);
			var branchChildren = this.findBranchChildren(this._array, this._itemToChildren, firstChildLocation);
			var filteredOrSortedBranchChildren = this.findBranchChildren(this._filterAndSortData, filterAndSortDataItemToChildren, firstChildLocation);
			filteredOrSortedBranchChildren.resize(0);
			branchChildren.resize(0);
			HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.REMOVE_ALL, location);
			FeathersEvent.dispatch(this, Event.CHANGE);
			return;
		}
		var firstChildLocation = location.copy();
		firstChildLocation.push(0);
		var branchChildren = this.findBranchChildren(this._array, this._itemToChildren, firstChildLocation);
		branchChildren.resize(0);
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.REMOVE_ALL, location);
		FeathersEvent.dispatch(this, Event.CHANGE);
	}

	/**
		@see `feathers.data.IHierarchicalCollection.updateAt`
	**/
	public function updateAt(location:Array<Int>):Void {
		if (this._pendingRefresh) {
			this.refreshFilterAndSort();
		}
		if (location == null || location.length == 0) {
			throw new RangeError('Item not found at location: ${location}');
		}
		var branchChildren:Array<Dynamic> = if (this._filterAndSortData != null) {
			this.findBranchChildren(this._filterAndSortData, filterAndSortDataItemToChildren, location);
		} else {
			this.findBranchChildren(this._array, this._itemToChildren, location);
		}
		var index = location[location.length - 1];
		if (index < 0 || index >= branchChildren.length) {
			throw new RangeError('Failed to update item at index ${index}. Expected a value between 0 and ${branchChildren.length - 1} at index ${location.length - 1}.');
		}
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.UPDATE_ITEM, location);
		this.refresh();
	}

	/**
		@see `feathers.data.IHierarchicalCollection.updateAll`
	**/
	public function updateAll():Void {
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.UPDATE_ALL, null);
		this.refresh();
	}

	/**
		@see `feathers.data.IHierarchicalCollection.refresh`
	**/
	public function refresh():Void {
		if (this._filterFunction == null && this._sortCompareFunction == null) {
			return;
		}
		this._pendingRefresh = true;
		if (this._filterFunction != null) {
			HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.FILTER_CHANGE, null);
		}
		if (this._sortCompareFunction != null) {
			HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.SORT_CHANGE, null);
		}
		FeathersEvent.dispatch(this, Event.CHANGE);
	}

	@:dox(hide)
	public function readExternal(input:IDataInput):Void {
		this.array = Std.downcast(input.readObject(), Array);
	}

	@:dox(hide)
	public function writeExternal(output:IDataOutput):Void {
		output.writeObject(this.array);
	}

	private function findItemInBranch(branchChildren:Array<T>, itemToFind:T, result:Array<Int>):Bool {
		for (i in 0...branchChildren.length) {
			var item = branchChildren[i];
			if (item == itemToFind) {
				result.push(i);
				return true;
			}
			if (!this.isBranch(item)) {
				continue;
			}
			var itemChildren = (this._itemToChildren != null) ? this._itemToChildren(item) : null;
			if (itemChildren != null) {
				result.push(i);
				var found = this.findItemInBranch(itemChildren, itemToFind, result);
				if (found) {
					return true;
				}
				result.pop();
			}
		}
		return false;
	}

	private function findItemInFilteredOrSortedBranch(branchChildren:Array<FilterAndSortItem<T>>, itemToFind:T, result:Array<Int>):Bool {
		for (i in 0...branchChildren.length) {
			var item = branchChildren[i];
			if (item.item == itemToFind) {
				result.push(i);
				return true;
			}
			var itemChildren = this.filterAndSortDataItemToChildren(item);
			if (itemChildren != null) {
				result.push(i);
				var found = this.findItemInFilteredOrSortedBranch(itemChildren, itemToFind, result);
				if (found) {
					return true;
				}
				result.pop();
			}
		}
		return false;
	}

	private function refreshFilterAndSort():Void {
		this._pendingRefresh = false;
		if (this._filterFunction != null || this._sortCompareFunction != null) {
			var result = this._filterAndSortData;
			if (result != null) {
				// reuse the old array to avoid garbage collection
				result.resize(0);
			} else {
				result = [];
			}
			this.refreshFilterAndSortInternal(this._array, result);
			this._filterAndSortData = result;
		} else // no filter or sort
		{
			this._filterAndSortData = null;
		}
		if (this._sortCompareFunction != null) {
			this.refreshSort(this._filterAndSortData);
		}
	}

	private function getSortedInsertionIndex(branchChildren:Array<FilterAndSortItem<T>>, item:FilterAndSortItem<T>):Int {
		if (this._sortCompareFunction == null) {
			return branchChildren.length;
		}
		for (i in 0...branchChildren.length) {
			var otherItem = branchChildren[i];
			var result = this.sortCompareFunctionInternal(item, otherItem);
			if (result < 1) {
				return i;
			}
		}
		return branchChildren.length;
	}

	private function refreshSort(array:Array<FilterAndSortItem<T>>):Void {
		array.sort(sortCompareFunctionInternal);
		for (item in array) {
			if (item.children == null) {
				continue;
			}
			this.refreshSort(item.children);
		}
	}

	private function refreshFilterAndSortInternal(items:Array<T>, result:Array<FilterAndSortItem<T>>):Void {
		for (i in 0...items.length) {
			var item = items[i];
			var filterAndSortItem = this.createFilterAndSortItem(item);
			if (filterAndSortItem != null) {
				result.push(filterAndSortItem);
			}
		}
	}

	private function createFilterAndSortItem(item:T):FilterAndSortItem<T> {
		var result:FilterAndSortItem<T> = null;
		if (this._filterFunction == null || this._filterFunction(item)) {
			result = new FilterAndSortItem(item);
		}
		if (result != null) {
			var children = (this._itemToChildren != null) ? this._itemToChildren(item) : null;
			if (children != null) {
				result.children = [];
				this.refreshFilterAndSortInternal(children, result.children);
			}
		}
		return result;
	}

	private function findBranchChildren<U>(source:Array<U>, itemToChildren:(U) -> Array<U>, location:Array<Int>):Array<U> {
		var branchChildren = source;
		for (i in 0...location.length - 1) {
			var index = location[i];
			if (index < 0 || index >= branchChildren.length) {
				throw new RangeError('Item not found at location: ${location}');
			}
			var child = branchChildren[index];
			branchChildren = (itemToChildren != null) ? itemToChildren(child) : null;
			if (branchChildren == null) {
				throw new RangeError('Item not found at location: ${location}');
			}
		}
		return branchChildren;
	}

	private function filterAndSortDataItemToChildren(item:FilterAndSortItem<T>):Array<FilterAndSortItem<T>> {
		return item.children;
	}

	private function sortCompareFunctionInternal(item1:FilterAndSortItem<T>, item2:FilterAndSortItem<T>):Int {
		return this._sortCompareFunction(item1.item, item2.item);
	}
}

private class FilterAndSortItem<T> {
	public function new(item:T, ?children:Array<FilterAndSortItem<T>>) {
		this.item = item;
		this.children = children;
	}

	public var item:T;
	public var children:Array<FilterAndSortItem<T>>;
}

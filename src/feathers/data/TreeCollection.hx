/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.data;

import openfl.errors.RangeError;
import openfl.events.Event;
import feathers.events.HierarchicalCollectionEvent;
import feathers.events.FeathersEvent;
import openfl.events.EventDispatcher;

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
class TreeCollection<T> extends EventDispatcher implements IHierarchicalCollection<TreeNode<T>> {
	/**
		Creates a new `TreeCollection` object with the given arguments.

		@since 1.0.0
	**/
	public function new(?array:Array<TreeNode<T>>) {
		super();
		if (array == null) {
			array = [];
		}
		this.array = array;
	}

	private var _filterAndSortData:Array<FilterAndSortItem<TreeNode<T>>> = null;

	private var _array:Array<TreeNode<T>> = null;

	/**
		The `Array<TreeNode>` data source for this collection.

		The following example replaces the data source with a new array:

		```hx
		collection.array = [];
		```

		@since 1.0.0
	**/
	@:flash.property
	public var array(get, set):Array<TreeNode<T>>;

	private function get_array():Array<TreeNode<T>> {
		return this._array;
	}

	private function set_array(value:Array<TreeNode<T>>):Array<TreeNode<T>> {
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

	private var _pendingRefresh:Bool = false;

	private var _filterFunction:(TreeNode<T>) -> Bool = null;

	/**
		@see `feathers.data.IHierarchicalCollection.filterFunction`
	**/
	@:flash.property
	public var filterFunction(get, set):(TreeNode<T>) -> Bool;

	private function get_filterFunction():(TreeNode<T>) -> Bool {
		return this._filterFunction;
	}

	private function set_filterFunction(value:(TreeNode<T>) -> Bool):(TreeNode<T>) -> Bool {
		if (this._filterFunction == value) {
			return this._filterFunction;
		}
		this._filterFunction = value;
		this._pendingRefresh = true;
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.FILTER_CHANGE, null);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._filterFunction;
	}

	/**
		@see `feathers.data.IHierarchicalCollection.getLength`
	**/
	public function getLength(?location:Array<Int>):Int {
		if (this._pendingRefresh) {
			this.refreshFilterAndSort();
		}
		if (this._filterAndSortData != null) {
			var branchChildren = this._filterAndSortData;
			if (location != null && location.length > 0) {
				for (i in 0...location.length) {
					var index = location[i];
					if (index < 0 || index >= branchChildren.length) {
						throw new RangeError('Branch not found at location: ${location}');
					}
					var child = branchChildren[index];
					branchChildren = child.children;
					if (branchChildren == null) {
						throw new RangeError('Branch not found at location: ${location}');
					}
				}
			}
			return branchChildren.length;
		}
		var branchChildren = this._array;
		if (location != null && location.length > 0) {
			for (i in 0...location.length) {
				var index = location[i];
				if (index < 0 || index >= branchChildren.length) {
					throw new RangeError('Branch not found at location: ${location}');
				}
				var child = branchChildren[index];
				branchChildren = child.children;
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
	public function get(location:Array<Int>):TreeNode<T> {
		if (this._pendingRefresh) {
			this.refreshFilterAndSort();
		}
		if (location == null || location.length == 0) {
			throw new RangeError('Item not found at location: ${location}');
		}
		if (this._filterAndSortData != null) {
			var branchChildren = this.findBranchChildren(this._filterAndSortData, location);
			var index = location[location.length - 1];
			if (index < 0 || index >= branchChildren.length) {
				throw new RangeError('Item not found at location: ${location}');
			}
			return branchChildren[index].item;
		}
		var branchChildren = this.findBranchChildren(this._array, location);
		var index = location[location.length - 1];
		if (index < 0 || index >= branchChildren.length) {
			throw new RangeError('Item not found at location: ${location}');
		}
		return branchChildren[index];
	}

	/**
		@see `feathers.data.IHierarchicalCollection.set`
	**/
	public function set(location:Array<Int>, value:TreeNode<T>):Void {
		if (this._pendingRefresh) {
			this.refreshFilterAndSort();
		}
		if (location == null || location.length == 0) {
			throw new RangeError('Item not found at location: ${location}');
		}
		if (this._filterAndSortData != null) {
			var lastLocationIndex = location[location.length - 1];
			var branchChildren = this.findBranchChildren(this._array, location);
			var filteredOrSortedBranchChildren = this.findBranchChildren(this._filterAndSortData, location);
			var oldItem:TreeNode<T> = null;
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
			}
			return;
		}
		var branchChildren = this.findBranchChildren(this._array, location);
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
	public function isBranch(item:TreeNode<T>):Bool {
		if (item == null) {
			return false;
		}
		return item.isBranch();
	}

	/**
		@see `feathers.data.IHierarchicalCollection.locationOf`
	**/
	public function locationOf(item:TreeNode<T>):Array<Int> {
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
	public function contains(item:TreeNode<T>):Bool {
		return this.locationOf(item) != null;
	}

	/**
		@see `feathers.data.IHierarchicalCollection.addAt`
	**/
	public function addAt(itemToAdd:TreeNode<T>, location:Array<Int>):Void {
		if (this._pendingRefresh) {
			this.refreshFilterAndSort();
		}
		if (location == null || location.length == 0) {
			throw new RangeError('Item cannot be added at location: ${location}');
		}
		if (this._filterAndSortData != null) {
			var lastLocationIndex = location[location.length - 1];
			var branchChildren = this.findBranchChildren(this._array, location);
			var filteredOrSortedBranchChildren = this.findBranchChildren(this._filterAndSortData, location);
			var oldItem:TreeNode<T> = null;
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
				branchChildren.insert(lastLocationIndex, itemToAdd);
				// don't dispatch these events if the item is filtered!
				HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.ADD_ITEM, location, itemToAdd);
				FeathersEvent.dispatch(this, Event.CHANGE);
			}
			return;
		}
		var branchChildren = this.findBranchChildren(this._array, location);
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
	public function removeAt(location:Array<Int>):TreeNode<T> {
		if (this._pendingRefresh) {
			this.refreshFilterAndSort();
		}
		if (location == null || location.length == 0) {
			throw new RangeError('Item not found at location: ${location}');
		}
		if (this._filterAndSortData != null) {
			var lastLocationIndex = location[location.length - 1];
			var branchChildren = this.findBranchChildren(this._array, location);
			var filteredOrSortedBranchChildren = this.findBranchChildren(this._filterAndSortData, location);
			var removedItem = filteredOrSortedBranchChildren.splice(lastLocationIndex, 1)[0].item;
			branchChildren.remove(removedItem);
			HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.REMOVE_ITEM, location, null, removedItem);
			FeathersEvent.dispatch(this, Event.CHANGE);
			return removedItem;
		}
		var branchChildren = this.findBranchChildren(this._array, location);
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
		@see `feathers.data.IHierarchicalCollection.removeAt`
	**/
	public function remove(item:TreeNode<T>):Void {
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
	public function removeAll():Void {
		if (this._pendingRefresh) {
			this.refreshFilterAndSort();
		}
		if (this._array.length == 0) {
			// nothing to remove
			return;
		}
		if (this._filterAndSortData != null) {
			this._filterAndSortData.resize(0);
		}
		this._array.resize(0);
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.REMOVE_ALL, null);
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
			this.findBranchChildren(this._filterAndSortData, location);
		} else {
			this.findBranchChildren(this._array, location);
		}
		var index = location[location.length - 1];
		if (index < 0 || index >= branchChildren.length) {
			throw new RangeError('Failed to update item at index ${index}. Expected a value between 0 and ${branchChildren.length - 1} at index ${location.length - 1}.');
		}
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.UPDATE_ITEM, location);
	}

	/**
		@see `feathers.data.IHierarchicalCollection.updateAll`
	**/
	public function updateAll():Void {
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.UPDATE_ALL, null);
	}

	/**
		@see `feathers.data.IHierarchicalCollection.refresh`
	**/
	public function refresh():Void {
		if (this._filterFunction == null) {
			return;
		}
		this._pendingRefresh = true;
		if (this._filterFunction != null) {
			HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.FILTER_CHANGE, null);
		}
		FeathersEvent.dispatch(this, Event.CHANGE);
	}

	private function findItemInBranch(branchChildren:Array<TreeNode<T>>, itemToFind:TreeNode<T>, result:Array<Int>):Bool {
		for (i in 0...branchChildren.length) {
			var item = branchChildren[i];
			if (item == itemToFind) {
				result.push(i);
				return true;
			}
			if (item.isBranch()) {
				result.push(i);
				var found = this.findItemInBranch(item.children, itemToFind, result);
				if (found) {
					return true;
				}
				result.pop();
			}
		}
		return false;
	}

	private function findItemInFilteredOrSortedBranch(branchChildren:Array<FilterAndSortItem<TreeNode<T>>>, itemToFind:TreeNode<T>, result:Array<Int>):Bool {
		for (i in 0...branchChildren.length) {
			var item = branchChildren[i];
			if (item.item == itemToFind) {
				result.push(i);
				return true;
			}
			var itemChildren = item.children;
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
		if (this._filterFunction != null) {
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
	}

	private function refreshFilterAndSortInternal(items:Array<TreeNode<T>>, result:Array<FilterAndSortItem<TreeNode<T>>>):Void {
		for (i in 0...items.length) {
			var item = items[i];
			var filterAndSortItem = this.createFilterAndSortItem(item);
			if (filterAndSortItem != null) {
				result.push(filterAndSortItem);
			}
		}
	}

	private function createFilterAndSortItem(item:TreeNode<T>):FilterAndSortItem<TreeNode<T>> {
		var result:FilterAndSortItem<TreeNode<T>> = null;
		if (this._filterFunction(item)) {
			result = new FilterAndSortItem(item);
		}
		if (result != null) {
			var children = item.children;
			if (children != null) {
				result.children = [];
				this.refreshFilterAndSortInternal(children, result.children);
			}
		}
		return result;
	}

	private function findBranchChildren<U:{children:Array<U>}>(source:Array<U>, location:Array<Int>):Array<U> {
		var branchChildren = source;
		for (i in 0...location.length - 1) {
			var index = location[i];
			if (index < 0 || index >= branchChildren.length) {
				throw new RangeError('Item not found at location: ${location}');
			}
			var child = branchChildren[index];
			branchChildren = child.children;
			if (branchChildren == null) {
				throw new RangeError('Item not found at location: ${location}');
			}
		}
		return branchChildren;
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

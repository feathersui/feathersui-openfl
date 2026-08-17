/*
	Feathers UI
	Copyright 2026 Bowler Hat LLC. All Rights Reserved.

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
	support hierarchical data, such as `TreeView` or `TreeGridView`.

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
	when `IHierarchicalCollection.updateAt()` is called.

	@event feathers.events.HierarchicalCollectionEvent.UPDATE_ALL Dispatched
	when `IHierarchicalCollection.updateAll()` is called.

	@event feathers.events.HierarchicalCollectionEvent.FILTER_CHANGE Dispatched
	when `IHierarchicalCollection.filterFunction` is changed.

	@event feathers.events.HierarchicalCollectionEvent.SORT_CHANGE Dispatched
	when `IHierarchicalCollection.sortCompareFunction` is changed.

	@see `feathers.controls.TreeView`
	@see `feathers.controls.TreeGridView`

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

	private var _array:Array<T> = null;

	/**
		The `Array<T>` data source for this collection.

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
		this._pendingRefresh = true;
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
		this._pendingRefresh = true;
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.RESET, null);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._itemToChildren;
	}

	private var _root:Branch<T> = null;

	private var _branchPool:Array<Branch<T>> = [];

	private var _pendingRefresh:Bool = false;

	private var _filterFunction:(T) -> Bool = null;

	/**
		@see `feathers.data.IHierarchicalCollection.filterFunction`
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
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.FILTER_CHANGE, null);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._filterFunction;
	}

	private var _sortCompareFunction:(T, T) -> Int = null;

	/**
		@see `feathers.data.IHierarchicalCollection.sortCompareFunction`
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
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.SORT_CHANGE, null);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._sortCompareFunction;
	}

	/**
		@see `feathers.data.IHierarchicalCollection.getLength`
	**/
	@:bindable("change")
	public function getLength(?location:Array<Int>):Int {
		if (location != null && location.length > 0) {
			var branch = this.getBranchAt(location);
			return branch.length;
		} else {
			if (this._pendingRefresh) {
				this.refreshFilterAndSort();
			}
			return this._root.length;
		}
	}

	/**
		@see `feathers.data.IHierarchicalCollection.get`
	**/
	@:bindable("change")
	public function get(location:Array<Int>):T {
		var branch = this.getBranchContaining(location);
		return branch.get(location[location.length - 1]);
	}

	/**
		@see `feathers.data.IHierarchicalCollection.set`
	**/
	public function set(location:Array<Int>, item:T):Void {
		var branch = this.getBranchContaining(location);
		var index = location[location.length - 1];
		if (index < 0) {
			throw new RangeError('Could not set item at location $location');
		}
		var removedItem:Null<T> = index < branch.length ? branch.get(index) : null;
		var newIndex = branch.set(index, item, this._itemToChildren);
		switch ([removedItem != null, newIndex >= 0]) {
			case [true, true]:
				if (index == newIndex) {
					HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.REPLACE_ITEM, location, item, removedItem);
				} else {
					HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.REMOVE_ITEM, location, null, removedItem);
					var newLocation = location.splice(0, location.length - 1);
					newLocation.push(newIndex);
					HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.ADD_ITEM, newLocation, item);
				}
				FeathersEvent.dispatch(this, Event.CHANGE);
			case [false, true]:
				location.pop();
				location.push(newIndex);
				HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.ADD_ITEM, location, item);
				FeathersEvent.dispatch(this, Event.CHANGE);
			case [true, false]:
				HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.REMOVE_ITEM, location, null, removedItem);
				FeathersEvent.dispatch(this, Event.CHANGE);
			case [false, false]:
				// displayed items did not change
		}
	}

	/**
		@see `feathers.data.IHierarchicalCollection.isBranch`
	**/
	public function isBranch(item:T):Bool {
		if (item == null || this._itemToChildren == null) {
			return false;
		}
		return this._itemToChildren(item) != null;
	}

	/**
		@see `feathers.data.IHierarchicalCollection.locationOf`
	**/
	public function locationOf(item:T):Array<Int> {
		if (this._pendingRefresh) {
			this.refreshFilterAndSort();
		}
		var result:Array<Int> = [];
		if (this._root.find(item, result)) {
			return result;
		}
		return null;
	}

	/**
		@see `feathers.data.IHierarchicalCollection.contains`
	**/
	public function contains(item:T):Bool {
		if (this._pendingRefresh) {
			this.refreshFilterAndSort();
		}
		return this._root.contains(item);
	}

	/**
		@see `feathers.data.IHierarchicalCollection.addAt`
	**/
	public function addAt(itemToAdd:T, location:Array<Int>):Void {
		var branch = this.getBranchContaining(location);
		var index:Int = location[location.length - 1];
		if (index < 0 || index > branch.length) {
			throw new RangeError('Item cannot be added at location: ${location}');
		}
		index = branch.addAt(index, itemToAdd);
		if (index >= 0) {
			location[location.length - 1] = index;
			HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.ADD_ITEM, location, itemToAdd);
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
	}

	/**
		@see `feathers.data.IHierarchicalCollection.removeAt`
	**/
	public function removeAt(location:Array<Int>):T {
		var branch = this.getBranchContaining(location);
		var removedItem = branch.removeAt(location[location.length - 1]);
		if (removedItem == null) {
			throw new RangeError('Item not found at location: ${location}');
		}
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
		var branch:Branch<T> = this._root;
		if (location != null) {
			branch = this.getBranchAt(location);
		} else if (branch == null) {
			this._root = branch = new Branch<T>(this._array, this);
		}
		if (branch.removeAll()) {
			HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.REMOVE_ALL, location);
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
	}

	/**
		@see `feathers.data.IHierarchicalCollection.updateAt`
	**/
	public function updateAt(location:Array<Int>):Void {
		var branch = this.getBranchContaining(location);
		var index = location[location.length - 1];
		if (index < 0 || index >= branch.length) {
			throw new RangeError('Failed to update item at index ${index}. Expected a value between 0 and ${branch.length - 1} at location ${location.slice(0, location.length - 1)}.');
		}
		this.refreshFilterAndSort(branch);
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.UPDATE_ITEM, location);
		FeathersEvent.dispatch(this, Event.CHANGE);
	}

	/**
		@see `feathers.data.IHierarchicalCollection.updateAll`
	**/
	public function updateAll():Void {
		this._pendingRefresh = true;
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.UPDATE_ALL, null);
		FeathersEvent.dispatch(this, Event.CHANGE);
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

	@:access(feathers.data.Branch._sourceItems)
	private function refreshFilterAndSort(?branch:Branch<T>):Void {
		// only clear `_pendingRefresh` if refreshing all
		if (branch == null || branch == this._root) {
			this._pendingRefresh = false;
			if (this._root == null) {
				this._root = new Branch<T>(this._array, this);
			} else {
				this._root._sourceItems = this._array;
			}
			branch = this._root;
		}

		branch.refreshFilterAndSort();
	}

	/**
		Returns the branch at `location`, if it's a branch. Throws an error if
		it can't be found, meaning this never returns null. Refreshes filter and
		sort if necessary.
	**/
	private function getBranchAt(location:Array<Int>):Branch<T> {
		if (location == null) {
			throw new RangeError('Item not found at location: ${location}');
		}
		if (this._pendingRefresh) {
			this.refreshFilterAndSort();
		}
		var branch = this._root;
		for (i in 0...location.length) {
			branch = branch.getChildren(location[i]);
			if (branch == null) {
				throw new RangeError('Item not found at location: ${location.slice(0, i + 1)}');
			}
		}
		return branch;
	}

	/**
		Returns the branch containing the item at `location`, which is the
		parent of the branch returned by `getBranchAt(location)`. Throws an
		error if it can't be found, meaning this never returns null. Refreshes
		filter and sort if necessary.
	**/
	private function getBranchContaining(location:Array<Int>):Branch<T> {
		if (location == null || location.length == 0) {
			throw new RangeError('Item not found at location: ${location}');
		}
		if (this._pendingRefresh) {
			this.refreshFilterAndSort();
		}
		var branch = this._root;
		for (i in 0...location.length - 1) {
			branch = branch.getChildren(location[i]);
			if (branch == null) {
				throw new RangeError('Item not found at location: ${location.slice(0, i + 2)}');
			}
		}
		return branch;
	}

	private static inline function resizeArray<T>(array:Array<T>, length:Int):Void {
		#if (hl && haxe_ver < 4.3)
		if (length == 0) {
			array.splice(0, array.length);
		} else {
			array.resize(length);
		}
		#else
		array.resize(length);
		#end
	}
}

@:access(feathers.data.ArrayHierarchicalCollection._branchPool)
private class Branch<T> {
	/**
		Child branches, in the same order as `displayItems`. Contains `null` for
		items that aren't branches.
	**/
	private var _children:Array<Branch<T>>;

	private var _collection:ArrayHierarchicalCollection<T>;

	/**
		The items in this branch, after filtering and sorting. Will be defined
		even if `_sourceItems` is null.
	**/
	private var _displayItems:Array<T>;

	public var length(get, never):Int;

	private inline function get_length():Int {
		return this._displayItems.length;
	}

	/**
		The items in this branch, before filtering and sorting.
	**/
	private var _sourceItems:Array<T>;

	public inline function new(items:Array<T>, collection:ArrayHierarchicalCollection<T>) {
		this._sourceItems = items;
		this._collection = collection;
		this._displayItems = [];
		this._children = [];
	}

	public function addAt(index:Int, item:T):Int {
		var sourceIndex:Int = getSourceIndex(index);
		var oldLength:Int = this._sourceItems.length;
		if (sourceIndex >= 0 && sourceIndex <= oldLength) {
			this._sourceItems.insert(sourceIndex, item);
			this.refreshDisplayItems();
			var newIndex:Int = this._displayItems.indexOf(item);
			if (newIndex < 0) {
				// no change to children
			} else {
				// everything after the insertion index shifted
				this.refreshChildren(newIndex);
			}
			return newIndex;
		} else {
			throw new RangeError('Index $sourceIndex is out of range 0...${this._sourceItems.length}');
		}
	}

	public function contains(item:T):Bool {
		if (this._displayItems.indexOf(item) >= 0) {
			return true;
		}
		for (child in this._children) {
			if (child != null && child.contains(item)) {
				return true;
			}
		}
		return false;
	}

	public function dispose():Void {
		if (this._sourceItems != null) {
			this._sourceItems = null;
			resizeArray(this._displayItems, 0);
			for (child in this._children) {
				if (child != null) {
					child.dispose();
				}
			}
			resizeArray(this._children, 0);
			this._collection._branchPool.push(this);
		}
	}

	public function find(item:T, result:Array<Int>):Bool {
		var index:Int = this._displayItems.indexOf(item);
		if (index >= 0) {
			result.push(index);
			return true;
		}

		for (index in 0...this._children.length) {
			var child = this._children[index];
			if (child != null) {
				result.push(index);
				if (child.find(item, result)) {
					return true;
				}
				result.pop();
			}
		}

		return false;
	}

	public function get(index:Int):T {
		if (index >= 0 && index < this._displayItems.length) {
			return this._displayItems[index];
		} else {
			throw new RangeError('Index $index is out of range 0...${this._displayItems.length}');
		}
	}

	public function getChildren(index:Int):Branch<T> {
		if (index >= 0 && index < this._children.length) {
			return this._children[index];
		} else {
			return null;
		}
	}
	
	private inline function getSourceIndex(index:Int):Int {
		var sourceIndex:Int = -1;
		if (index == this._displayItems.length) {
			sourceIndex = this._sourceItems.length;
		} else if (index >= 0 && index < this._displayItems.length) {
			sourceIndex = this._sourceItems.indexOf(this._displayItems[index]);
		}
		return sourceIndex;
	}

	public inline function isBranch():Bool {
		return this._sourceItems != null;
	}

	public function set(index:Int, item:T, itemToChildren:(T) -> Array<T>):Int {
		var sourceIndex:Int = getSourceIndex(index);
		var oldLength:Int = this._sourceItems.length;
		if (sourceIndex >= 0 && sourceIndex <= oldLength) {
			this._sourceItems[sourceIndex] = item;
			this.refreshDisplayItems();
			var newIndex:Int = this._displayItems.indexOf(item);
			if (newIndex < 0) {
				// everything after the removed index shifted
				this.refreshChildren(index);
			} else if (sourceIndex == oldLength) {
				// everything after (and including) the added index shifted
				this.refreshChildren(newIndex);
			} else {
				// everything between (and including) the two indices shifted
				var startIndex:Int = index < newIndex ? index : newIndex;
				var endIndex:Int = index >= newIndex ? index : newIndex;
				this.refreshChildren(startIndex, endIndex);
			}
			return newIndex;
		} else {
			throw new RangeError('Index $sourceIndex is out of range 0...${this._sourceItems.length}');
		}
	}

	public function removeAll():Bool {
		if (this._sourceItems.length == 0) {
			this.refreshFilterAndSort();
			return false;
		}
		resizeArray(this._sourceItems, 0);
		this.refreshFilterAndSort();
		return true;
	}

	public function removeAt(index:Int):Null<T> {
		if (index < 0 || index >= this._displayItems.length) {
			return null;
		}
		var removedItem:T = this._displayItems[index];
		this._displayItems.splice(index, 1);
		var child:Branch<T> = this._children[index];
		if (child != null) {
			child.dispose();
		}
		this._children.splice(index, 1);
		this._sourceItems.remove(removedItem);
		return removedItem;
	}

	public function refreshFilterAndSort():Void {
		if (!this.isBranch()) {
			return;
		}

		inline refreshDisplayItems();
		refreshChildren();
	}

	/**
		Resets `_displayItems` to match `_sourceItems`, then filters and sorts.

		Does not update `_children`. For that, also call `refreshChildren()`.
	**/
	private function refreshDisplayItems():Void {
		resizeArray(this._displayItems, this._sourceItems.length);
		for (i in 0...this._sourceItems.length) {
			this._displayItems[i] = this._sourceItems[i];
		}

		var filterFunction = this._collection.filterFunction;
		if (filterFunction != null) {
			var newLength:Int = 0;
			for (i in 0...this._sourceItems.length) {
				if (filterFunction(this._sourceItems[i])) {
					this._displayItems[newLength] = this._sourceItems[i];
					newLength++;
				}
			}
			resizeArray(this._displayItems, newLength);
		}
		var sortCompareFunction = this._collection.sortCompareFunction;
		if (sortCompareFunction != null) {
			this._displayItems.sort(sortCompareFunction);
		}
	}

	/**
		Populates and refreshs `_children` to match `_displayItems`.

		If `startIndex` and `endIndex` are defined, only refreshes the children
		from `startIndex...endIndex+1` (i.e., up to and including `endIndex`).
	**/
	private function refreshChildren(startIndex:Int = 0, endIndex:Int = -1):Void {
		var itemToChildren = this._collection.itemToChildren;
		if (itemToChildren == null) {
			resizeArray(this._children, 0);
			return;
		}

		if (startIndex < 0) {
			startIndex = 0;
		}
		if (endIndex < 0 || endIndex >= this._displayItems.length) {
			endIndex = this._displayItems.length;
		} else {
			endIndex++;
		}

		for (i in startIndex...endIndex) {
			var sourceItems:Array<T> = itemToChildren(this._displayItems[i]);
			var child:Branch<T> = i < this._children.length ? this._children[i] : null;
			if (sourceItems == null) {
				if (child != null) {
					child.dispose();
				}
				this._children[i] = null;
				continue;
			}
			if (child == null) {
				child = this._collection._branchPool.pop();
				if (child == null) {
					child = new Branch<T>(null, this._collection);
				}
			}
			this._children[i] = child;
			child._sourceItems = sourceItems;
			child.refreshFilterAndSort();
		}
		while (this._children.length > this._displayItems.length) {
			var child:Branch<T> = this._children.pop();
			if (child != null) {
				child.dispose();
			}
		}
	}

	private static inline function resizeArray<T>(array:Array<T>, length:Int):Void {
		#if (hl && haxe_ver < 4.3)
		if (length == 0) {
			array.splice(0, array.length);
		} else {
			array.resize(length);
		}
		#else
		array.resize(length);
		#end
	}
}

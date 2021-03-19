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
class ArrayHierarchicalCollection<T> extends EventDispatcher implements IHierarchicalCollection<T> {
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

	/**
		@see `feathers.data.IHierarchicalCollection.getLength`
	**/
	public function getLength(?location:Array<Int>):Int {
		var branchChildren = this._array;
		if (location != null && location.length > 0) {
			for (i in 0...location.length) {
				var index = location[i];
				if (index < 0 || index >= branchChildren.length) {
					throw new RangeError('Branch not found at location: ${location}');
				}
				var child = branchChildren[index];
				branchChildren = (this._itemToChildren != null) ? this._itemToChildren(child) : null;
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
		if (location == null || location.length == 0) {
			throw new RangeError('Item not found at location: ${location}');
		}
		var branchChildren = this._array;
		for (i in 0...location.length - 1) {
			var index = location[i];
			if (index < 0 || index >= branchChildren.length) {
				throw new RangeError('Item not found at location: ${location}');
			}
			var child = branchChildren[index];
			branchChildren = (this._itemToChildren != null) ? this._itemToChildren(child) : null;
			if (branchChildren == null) {
				throw new RangeError('Item not found at location: ${location}');
			}
		}
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
		if (location == null || location.length == 0) {
			throw new RangeError('Item not found at location: ${location}');
		}
		var branchChildren = this._array;
		for (i in 0...location.length - 1) {
			var index = location[i];
			if (index < 0 || index >= branchChildren.length) {
				throw new RangeError('Item not found at location: ${location}');
			}
			var child = branchChildren[index];
			branchChildren = (this._itemToChildren != null) ? this._itemToChildren(child) : null;
			if (branchChildren == null) {
				throw new RangeError('Item not found at location: ${location}');
			}
		}
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
		var result:Array<Int> = [];
		var found = this.findItemInBranch(this._array, item, result);
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
		if (location == null || location.length == 0) {
			throw new RangeError('Item cannot be added at location: ${location}');
		}
		var branchChildren = this._array;
		for (i in 0...location.length - 1) {
			var index = location[i];
			if (index < 0 || index >= branchChildren.length) {
				throw new RangeError('Item cannot be added at location: ${location}');
			}
			var child = branchChildren[index];
			branchChildren = (this._itemToChildren != null) ? this._itemToChildren(child) : null;
			if (branchChildren == null) {
				throw new RangeError('Item cannot be added at location: ${location}');
			}
		}
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
	public function removeAt(location:Array<Int>):Void {
		if (location == null || location.length == 0) {
			throw new RangeError('Item not found at location: ${location}');
		}
		var branchChildren = this._array;
		for (i in 0...location.length - 1) {
			var index = location[i];
			if (index < 0 || index >= branchChildren.length) {
				throw new RangeError('Item not found at location: ${location}');
			}
			var child = branchChildren[index];
			branchChildren = (this._itemToChildren != null) ? this._itemToChildren(child) : null;
			if (branchChildren == null) {
				throw new RangeError('Item not found at location: ${location}');
			}
		}
		var index = location[location.length - 1];
		if (index < 0 || index >= branchChildren.length) {
			throw new RangeError('Item not found at location: ${location}');
		}
		var removedItem = branchChildren[index];
		branchChildren.remove(removedItem);
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.REMOVE_ITEM, location, null, removedItem);
		FeathersEvent.dispatch(this, Event.CHANGE);
	}

	/**
		@see `feathers.data.IHierarchicalCollection.removeAt`
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
	public function removeAll():Void {
		if (this._array.length == 0) {
			// nothing to remove
			return;
		}
		this._array.resize(0);
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.REMOVE_ALL, null);
		FeathersEvent.dispatch(this, Event.CHANGE);
	}

	/**
		@see `feathers.data.IHierarchicalCollection.updateAt`
	**/
	public function updateAt(location:Array<Int>):Void {
		if (location == null || location.length == 0) {
			throw new RangeError('Item not found at location: ${location}');
		}
		var branchChildren = this._array;
		for (i in 0...location.length - 1) {
			var index = location[i];
			if (index < 0 || index >= branchChildren.length) {
				throw new RangeError('Failed to update item at location ${location}. Expected a value between 0 and ${branchChildren.length - 1} at index ${i}.');
			}
			var child = branchChildren[index];
			branchChildren = (this._itemToChildren != null) ? this._itemToChildren(child) : null;
			if (branchChildren == null) {
				throw new RangeError('Failed to update item at location ${location}. Expected branch.');
			}
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

	private function findItemInBranch(branchChildren:Array<T>, itemToFind:T, result:Array<Int>):Bool {
		for (i in 0...branchChildren.length) {
			var item = branchChildren[i];
			if (item == itemToFind) {
				result.push(i);
				return true;
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
}

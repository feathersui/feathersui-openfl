/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

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

	@see `feathers.controls.TreeView`

	@since 1.0.0
**/
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

	/**
		The `Array<TreeNode>` data source for this collection.

		The following example replaces the data source with a new array:

		```hx
		collection.data = [];
		```

		@since 1.0.0
	**/
	public var array(default, set):Array<TreeNode<T>> = null;

	private function set_array(value:Array<TreeNode<T>>):Array<TreeNode<T>> {
		if (this.array == value) {
			return this.array;
		}
		if (value == null) {
			value = [];
		}
		this.array = value;
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.RESET, null);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this.array;
	}

	/**
		@see `feathers.data.IHierarchicalCollection.getLength`
	**/
	public function getLength(?location:Array<Int>):Int {
		var branchChildren = this.array;
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
		if (location == null || location.length == 0) {
			throw new RangeError('Item not found at location: ${location}');
		}
		var branchChildren = this.array;
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
		if (location == null || location.length == 0) {
			throw new RangeError('Item not found at location: ${location}');
		}
		var branchChildren = this.array;
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
		var index = location[location.length - 1];
		if (index < 0 || index >= branchChildren.length) {
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
		var result:Array<Int> = [];
		var found = this.findItemInBranch(this.array, item, result);
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
		if (location == null || location.length == 0) {
			throw new RangeError('Item not found at location: ${location}');
		}
		var branchChildren = this.array;
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
		var index = location[location.length - 1];
		if (index < 0 || index >= branchChildren.length) {
			throw new RangeError('Item not found at location: ${location}');
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
		var branchChildren = this.array;
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
		if (this.array.length == 0) {
			// nothing to remove
			return;
		}
		this.array.resize(0);
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
		var branchChildren = this.array;
		for (i in 0...location.length - 1) {
			var index = location[i];
			if (index < 0 || index >= branchChildren.length) {
				throw new RangeError('Failed to update item at location ${location}. Expected a value between 0 and ${branchChildren.length - 1} at index ${i}.');
			}
			var child = branchChildren[index];
			branchChildren = child.children;
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
}

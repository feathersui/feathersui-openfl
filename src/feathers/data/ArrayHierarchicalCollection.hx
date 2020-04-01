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
	Wraps an `Array` in the common `IHierarchicalCollection` API used for data
	collections by hierarchical Feathers UI controls, including `TreeView`.

	@since 1.0.0
**/
@defaultXmlProperty("array")
class ArrayHierarchicalCollection<T, U:T & {children:Array<T>}> extends EventDispatcher implements IHierarchicalCollection<T> {
	/**
		Creates a new `ArrayHierarchicalCollection` object with the given arguments.

		@since 1.0.0
	**/
	public function new(?array:Array<T>) {
		super();
		if (array == null) {
			array = [];
		}
		this.array = array;
	}

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
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.RESET, null);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this.array;
	}

	/**
		@see `feathers.data.IHierarchicalCollection.getLength`
	**/
	public function getLength(?location:Array<Int>):Int {
		var branch = this.array;
		if (location != null && location.length > 0) {
			for (i in 0...location.length - 1) {
				var child = branch[i];
				branch = this.itemToChildren(child);
				if (branch == null) {
					throw new RangeError('Branch not found at location: ${location}');
				}
			}
		}
		return branch.length;
	}

	/**
		@see `feathers.data.IHierarchicalCollection.get`
	**/
	public function get(location:Array<Int>):T {
		if (location == null || location.length == 0) {
			return null;
		}
		var branch = this.array;
		for (i in 0...location.length - 1) {
			var child = branch[i];
			branch = this.itemToChildren(child);
			if (branch == null) {
				throw new RangeError('Branch not found at location: ${location}');
			}
		}
		var index = location[location.length - 1];
		return branch[index];
	}

	/**
		@see `feathers.data.IHierarchicalCollection.set`
	**/
	public function set(location:Array<Int>, value:T):Void {
		if (location == null || location.length == 0) {
			throw new RangeError('Branch not found at location: ${location}');
		}
		var branch = this.array;
		for (i in 0...location.length - 1) {
			var child = branch[i];
			branch = this.itemToChildren(child);
			if (branch == null) {
				throw new RangeError('Branch not found at location: ${location}');
			}
		}
		var index = location[location.length - 1];
		var oldValue = branch[index];
		branch[index] = value;
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.REPLACE_ITEM, location, value, oldValue);
		FeathersEvent.dispatch(this, Event.CHANGE);
	}

	/**
		@see `feathers.data.IHierarchicalCollection.isItemBranch`
	**/
	public dynamic function isItemBranch(item:T):Bool {
		return this.itemToChildren(item) != null;
	}

	/**
		@see `feathers.data.IHierarchicalCollection.isLocationBranch`
	**/
	public function isLocationBranch(location:Array<Int>):Bool {
		var item = this.get(location);
		return this.isItemBranch(item);
	}

	/**
		@see `feathers.data.IHierarchicalCollection.locationOf`
	**/
	public function locationOf(item:T):Array<Int> {
		var result:Array<Int> = [];
		var found = this.findItemInBranch(this.array, item, result);
		if (!found) {
			return null;
		}
		return result;
	}

	private function itemToChildren(item:T):Array<T> {
		var type = Type.getClass(item);
		if (type == null) {
			if (!Reflect.hasField(item, "children")) {
				return null;
			}
		} else if (Type.getInstanceFields(type).indexOf("children") == -1) {
			return null;
		}
		var branch:U = cast(item);
		return branch.children;
	}

	private function findItemInBranch(branch:Array<T>, itemToFind:T, result:Array<Int>):Bool {
		for (i in 0...branch.length) {
			var item = branch[i];
			if (item == itemToFind) {
				result.push(i);
				return true;
			}
			if (this.isItemBranch(item)) {
				result.push(i);
				var children = this.itemToChildren(item);
				var found = this.findItemInBranch(children, itemToFind, result);
				if (found) {
					return true;
				}
				result.pop();
			}
		}
		return false;
	}
}

/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.data;

import feathers.events.FeathersEvent;
import feathers.events.HierarchicalCollectionEvent;
import openfl.errors.IllegalOperationError;
import openfl.errors.RangeError;
import openfl.events.Event;
import openfl.events.EventDispatcher;

/**
	Wraps another `IHierarchicalCollection` data source to expose the children
	of a single branch from that collection as the root items in this
	collection.

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
	when `IHierarchicalCollection.updateItem()` is called.

	@event feathers.events.HierarchicalCollectionEvent.UPDATE_ALL Dispatched
	when `IHierarchicalCollection.updateAll()` is called.

	@event feathers.events.HierarchicalCollectionEvent.FILTER_CHANGE Dispatched
	when `IHierarchicalCollection.filterFunction` is changed.

	@event feathers.events.HierarchicalCollectionEvent.SORT_CHANGE Dispatched
	when `IHierarchicalCollection.sortCompareFunction` is changed.

	@since 1.4.0
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
class HierarchicalSubCollection<T> extends EventDispatcher implements IHierarchicalCollection<T> {
	private var parentCollection:IHierarchicalCollection<T>;
	private var rootContainsChildrenOf:Array<Int>;

	/**
		Creates a new `HierarchicalSubCollection` object with the given arguments.

		@since 1.4.0
	**/
	public function new(parentCollection:IHierarchicalCollection<T>, rootContainsChildrenOf:Array<Int>) {
		super();
		this.parentCollection = parentCollection;
		this.rootContainsChildrenOf = rootContainsChildrenOf;
		parentCollection.addEventListener(Event.CHANGE, hierarchicalSubCollection_parentCollection_changeHandler);
		parentCollection.addEventListener(HierarchicalCollectionEvent.ADD_ITEM, hierarchicalSubCollection_parentCollection_addItemHandler);
		parentCollection.addEventListener(HierarchicalCollectionEvent.REMOVE_ITEM, hierarchicalSubCollection_parentCollection_removeItemHandler);
		parentCollection.addEventListener(HierarchicalCollectionEvent.REPLACE_ITEM, hierarchicalSubCollection_parentCollection_replaceItemHandler);
		parentCollection.addEventListener(HierarchicalCollectionEvent.RESET, hierarchicalSubCollection_parentCollection_resetHandler);
		parentCollection.addEventListener(HierarchicalCollectionEvent.REMOVE_ALL, hierarchicalSubCollection_parentCollection_removeAllHandler);
		parentCollection.addEventListener(HierarchicalCollectionEvent.UPDATE_ITEM, hierarchicalSubCollection_parentCollection_updateItemHandler);
		parentCollection.addEventListener(HierarchicalCollectionEvent.UPDATE_ALL, hierarchicalSubCollection_parentCollection_updateAllHandler);
	}

	private var _itemToChildren:(T) -> Array<T>;

	/**
		A function that returns an item's children. If the item is not a branch,
		the function should return `null`. If the item is a branch, but it
		contains no children, the function should return an empty array.

		@since 1.4.0
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
		if (value != null) {
			throw new IllegalOperationError("HierarchicalSubCollection: filterFunction not supported");
		}
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
		if (value != null) {
			throw new IllegalOperationError("HierarchicalSubCollection: sortCompareFunction not supported");
		}
		return this._sortCompareFunction;
	}

	/**
		@see `feathers.data.IHierarchicalCollection.getLength`
	**/
	@:bindable("change")
	public function getLength(?location:Array<Int>):Int {
		if (location == null) {
			return parentCollection.getLength(rootContainsChildrenOf);
		}
		return parentCollection.getLength(rootContainsChildrenOf.concat(location));
	}

	/**
		@see `feathers.data.IHierarchicalCollection.get`
	**/
	@:bindable("change")
	public function get(location:Array<Int>):T {
		if (location == null || location.length == 0) {
			throw new RangeError('Item not found at location: ${location}');
		}
		return parentCollection.get(rootContainsChildrenOf.concat(location));
	}

	/**
		@see `feathers.data.IHierarchicalCollection.set`
	**/
	public function set(location:Array<Int>, value:T):Void {
		if (location == null || location.length == 0) {
			throw new RangeError('Item not found at location: ${location}');
		}
		parentCollection.set(rootContainsChildrenOf.concat(location), value);
	}

	/**
		@see `feathers.data.IHierarchicalCollection.isBranch`
	**/
	public function isBranch(item:T):Bool {
		return parentCollection.isBranch(item);
	}

	/**
		@see `feathers.data.IHierarchicalCollection.locationOf`
	**/
	public function locationOf(item:T):Array<Int> {
		var location = parentCollection.locationOf(item);
		if (location == null) {
			return null;
		}
		// the item may be in the parent collection, but in a different branch
		// than the sub-collection, so check if the start matches
		if (location.length <= rootContainsChildrenOf.length) {
			return null;
		}
		for (i in 0...rootContainsChildrenOf.length) {
			if (rootContainsChildrenOf[i] != location[i]) {
				return null;
			}
		}
		return location.slice(rootContainsChildrenOf.length);
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
		parentCollection.addAt(itemToAdd, rootContainsChildrenOf.concat(location));
	}

	/**
		@see `feathers.data.IHierarchicalCollection.removeAt`
	**/
	public function removeAt(location:Array<Int>):T {
		if (location == null || location.length == 0) {
			throw new RangeError('Item not found at location: ${location}');
		}
		return parentCollection.removeAt(rootContainsChildrenOf.concat(location));
	}

	/**
		@see `feathers.data.IHierarchicalCollection.remove`
	**/
	public function remove(item:T):Void {
		parentCollection.remove(item);
	}

	/**
		@see `feathers.data.IHierarchicalCollection.removeAll`
	**/
	public function removeAll(?location:Array<Int>):Void {
		if (location == null) {
			parentCollection.removeAll(rootContainsChildrenOf);
			return;
		}
		return parentCollection.removeAll(rootContainsChildrenOf.concat(location));
	}

	/**
		@see `feathers.data.IHierarchicalCollection.updateAt`
	**/
	public function updateAt(location:Array<Int>):Void {
		if (location == null || location.length == 0) {
			throw new RangeError('Item not found at location: ${location}');
		}
		return parentCollection.updateAt(rootContainsChildrenOf.concat(location));
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
	public function refresh():Void {}

	private function hierarchicalSubCollection_parentCollection_changeHandler(event:Event):Void {
		FeathersEvent.dispatch(this, Event.CHANGE);
	}

	private function hierarchicalSubCollection_parentCollection_addItemHandler(event:HierarchicalCollectionEvent):Void {
		var location = event.location;
		if (location.length < rootContainsChildrenOf.length) {
			return;
		}
		for (i in 0...rootContainsChildrenOf.length) {
			if (rootContainsChildrenOf[i] != location[i]) {
				return;
			}
		}
		location = location.slice(rootContainsChildrenOf.length);
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.ADD_ITEM, location, event.addedItem, event.removedItem);
	}

	private function hierarchicalSubCollection_parentCollection_removeItemHandler(event:HierarchicalCollectionEvent):Void {
		var location = event.location;
		if (location.length < rootContainsChildrenOf.length) {
			return;
		}
		for (i in 0...rootContainsChildrenOf.length) {
			if (rootContainsChildrenOf[i] != location[i]) {
				return;
			}
		}
		location = location.slice(rootContainsChildrenOf.length);
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.REMOVE_ITEM, location, event.addedItem, event.removedItem);
	}

	private function hierarchicalSubCollection_parentCollection_replaceItemHandler(event:HierarchicalCollectionEvent):Void {
		var location = event.location;
		if (location.length < rootContainsChildrenOf.length) {
			return;
		}
		for (i in 0...rootContainsChildrenOf.length) {
			if (rootContainsChildrenOf[i] != location[i]) {
				return;
			}
		}
		location = location.slice(rootContainsChildrenOf.length);
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.REPLACE_ITEM, location, event.addedItem, event.removedItem);
	}

	private function hierarchicalSubCollection_parentCollection_removeAllHandler(event:HierarchicalCollectionEvent):Void {
		var location = event.location;
		if (location != null) {
			if (location.length < rootContainsChildrenOf.length) {
				return;
			}
			for (i in 0...rootContainsChildrenOf.length) {
				if (rootContainsChildrenOf[i] != location[i]) {
					return;
				}
			}
			if (location.length == rootContainsChildrenOf.length) {
				location = null;
			} else {
				location = location.slice(rootContainsChildrenOf.length);
			}
		}
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.REMOVE_ALL, location);
	}

	private function hierarchicalSubCollection_parentCollection_updateItemHandler(event:HierarchicalCollectionEvent):Void {
		var location = event.location;
		if (location.length < rootContainsChildrenOf.length) {
			return;
		}
		for (i in 0...rootContainsChildrenOf.length) {
			if (rootContainsChildrenOf[i] != location[i]) {
				return;
			}
		}
		location = location.slice(rootContainsChildrenOf.length);
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.UPDATE_ITEM, location, event.addedItem, event.removedItem);
	}

	private function hierarchicalSubCollection_parentCollection_updateAllHandler(event:HierarchicalCollectionEvent):Void {
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.UPDATE_ALL, null);
	}

	private function hierarchicalSubCollection_parentCollection_resetHandler(event:HierarchicalCollectionEvent):Void {
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.RESET, null);
	}
}

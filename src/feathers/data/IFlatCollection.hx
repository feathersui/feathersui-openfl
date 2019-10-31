/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.data;

import openfl.events.IEventDispatcher;

/**
	Interface for collections of flat data, such as arrays or other lists.

	@since 1.0.0
**/
interface IFlatCollection<T> extends IEventDispatcher {
	/**
		The number of items in the collection.

		@since 1.0.0
	**/
	public var length(get, never):Int;

	/**
		A function to determine if each item in the collection should be
		included or excluded from visibility through APIs like `length` and
		`get()`.

		@since 1.0.0
	**/
	public var filterFunction(get, set):(T) -> Bool;

	/**
		A function to compare each item in the collection to determine the order
		when sorted.

		The return value should be `-1` if the first item should appear before
		the second item when the collection is sorted. The return value should
		be `1` if the first item should appear after the second item when the
		collection is sorted. Finally, the return value should be `0` if both
		items have the same sort order.

		@since 1.0.0
	**/
	public var sortCompareFunction(get, set):(T, T) -> Int;

	/**
		Returns the item at the specified index in the collection.

		@since 1.0.0
	**/
	public function get(index:Int):T;

	/**
		Replaces the item at the specified index in the collection with a new
		item.

		@since 1.0.0
	**/
	public function set(index:Int, item:T):Void;

	/**
		Inserts an item at the end of the collection, increasing the `length` by
		one.

		@since 1.0.0
	**/
	public function add(item:T):Void;

	/**
		Inserts an item into the collection at the specified index, increasing
		the `length` by one.

		@since 1.0.0
	**/
	public function addAt(item:T, index:Int):Void;

	/**
		@since 1.0.0
	**/
	public function addAll(collection:IFlatCollection<T>):Void;

	/**
		@since 1.0.0
	**/
	public function addAllAt(collection:IFlatCollection<T>, index:Int):Void;

	/**
		@since 1.0.0
	**/
	public function reset(collection:IFlatCollection<T> = null):Void;

	/**
		Removes a specific item from the collection, decreasing the `length` by
		one, if the item is in the collection.

		@since 1.0.0
	**/
	public function remove(item:T):Void;

	/**
		Removes an item from the collection at the specified index, decreasing
		the `length` by one.

		@since 1.0.0
	**/
	public function removeAt(index:Int):T;

	/**
		Removes all items from the collection, decreasing its length to zero.

		@since 1.0.0
	**/
	public function removeAll():Void;

	/**
		Returns the index of the specified item, or `-1` if the item is not in
		the collection.

		@since 1.0.0
	**/
	public function indexOf(item:T):Int;

	/**
		Determines if the collection contains the specified item.

		@since 1.0.0
	**/
	public function contains(item:T):Bool;

	/**
		Notifies components using the collection that an item at the specified
		index has changed.

		@see `updateAll`
		@see `feathers.data.FlatCollectionEvent.UPDATE_ITEM`

		@since 1.0.0
	**/
	public function updateAt(index:Int):Void;

	/**
		Notifies components using the collection that all items should be
		considered changed.

		@see `updateAt`
		@see `feathers.data.FlatCollectionEvent.UPDATE_ALL`

		@since 1.0.0
	**/
	public function updateAll():Void;

	/**
		@since 1.0.0
	**/
	public function iterator():Iterator<T>;

	/**
		Refreshes the collection using the `filterFunction` or
		`sortCompareFunction` without passing in a new values for these
		properties. Useful when either of these functions relies on external
		variables that have changed.

		@since 1.0.0
	**/
	public function refresh():Void;
}

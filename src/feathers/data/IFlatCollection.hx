/*
	Feathers
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
	public var length(get, null):Int;

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
	public function set(item:T, index:Int):Void;

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
}

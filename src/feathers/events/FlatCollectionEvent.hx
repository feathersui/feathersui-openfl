/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.events;

import openfl._internal.utils.ObjectPool;
import openfl.events.EventType;
import openfl.events.Event;
import openfl.events.IEventDispatcher;

/**
	Events dispatched by flat collections.

	@see `feathers.data.IFlatCollection`

	@since 1.0.0
**/
class FlatCollectionEvent extends Event {
	/**
		The `FlatCollectionEvent.ADD_ITEM` event type is dispatched when an item is
		added to a collection.

		@see `feathers.data.IFlatCollection.add()`
		@see `feathers.data.IFlatCollection.addAt()`

		@since 1.0.0
	**/
	public static inline var ADD_ITEM:EventType<FlatCollectionEvent> = "addItem";

	/**
		The `FlatCollectionEvent.REMOVE_ITEM` event type is dispatched when an item
		is removed from a collection.

		@see `feathers.data.IFlatCollection.remove()`
		@see `feathers.data.IFlatCollection.removeAt()`

		@since 1.0.0
	**/
	public static inline var REMOVE_ITEM:EventType<FlatCollectionEvent> = "removeItem";

	/**
		The `FlatCollectionEvent.REPLACE_ITEM` event type is dispatched when an item
		is replaced in a collection.

		@see `feathers.data.IFlatCollection.set()`

		@since 1.0.0
	**/
	public static inline var REPLACE_ITEM:EventType<FlatCollectionEvent> = "replaceItem";

	/**
		The `FlatCollectionEvent.UPDATE_ITEM` event type is dispatched when the
		`updateAt()` method is called on the collection.

		@see `feathers.data.IFlatCollection.updateItem()`

		@since 1.0.0
	**/
	public static inline var UPDATE_ITEM:EventType<FlatCollectionEvent> = "updateItem";

	/**
		The `FlatCollectionEvent.UPDATE_ALL` event type is dispatched when the
		`updateAll()` method is called on the collection.

		@see `feathers.data.IFlatCollection.updateAll()`

		@since 1.0.0
	**/
	public static inline var UPDATE_ALL:EventType<FlatCollectionEvent> = "updateAll";

	/**
		The `FlatCollectionEvent.RESET` event type is dispatched when the entire
		underlying data structure is replaced.

		@since 1.0.0
	**/
	public static inline var RESET:EventType<FlatCollectionEvent> = "reset";

	/**
		The `FlatCollectionEvent.REMOVE_ALL` event type is dispatched when all
		items are removed from the collection simulatanously by calling
		`removeAll()` on the collection.

		@see `feathers.data.IFlatCollection.removeAll()`

		@since 1.0.0
	**/
	public static inline var REMOVE_ALL:EventType<FlatCollectionEvent> = "removeAll";

	/**
		The `FlatCollectionEvent.FILTER_CHANGE` event type is dispatched when a
		filter function has been applied to or removed from a collection.

		@see `feathers.data.IFlatCollection.filterFunction`

		@since 1.0.0
	**/
	public static inline var FILTER_CHANGE:EventType<FlatCollectionEvent> = "filterChange";

	/**
		The `FlatCollectionEvent.SORT_CHANGE` event type is dispatched when a
		sort compare function has been applied to or removed from a collection.

		@see `feathers.data.IFlatCollection.sortCompareFunction`

		@since 1.0.0
	**/
	public static inline var SORT_CHANGE:EventType<FlatCollectionEvent> = "sortChange";

	#if !flash
	private static var _pool = new ObjectPool<FlatCollectionEvent>(() -> return new FlatCollectionEvent(null, -1, false, false), (event) -> {
		event.__preventDefault = false;
		event.__isCanceled = false;
		event.__isCanceledNow = false;
	});
	#end

	/**
		Dispatches a pooled event with the specified properties.

		```hx
		FlatCollectionEvent.dispatch(component, Event.ADD_ITEM, 0, item);
		```

		@since 1.0.0
	**/
	public static function dispatch(dispatcher:IEventDispatcher, type:String, index:Int, addedItem:Dynamic = null, removedItem:Dynamic = null,
			bubbles:Bool = false, cancelable:Bool = false):Bool {
		#if flash
		var event = new FlatCollectionEvent(type, index, bubbles, cancelable);
		return dispatcher.dispatchEvent(event);
		#else
		var event = _pool.get();
		event.type = type;
		event.index = index;
		event.addedItem = addedItem;
		event.removedItem = removedItem;
		event.bubbles = bubbles;
		event.cancelable = cancelable;
		var result = dispatcher.dispatchEvent(event);
		_pool.release(event);
		return result;
		#end
	}

	/**
		Creates a new `FlatCollectionEvent` object with the given arguments.

		@see `FlatCollectionEvent.dispatch`

		@since 1.0.0
	**/
	public function new(type:String, index:Int, addedItem:Dynamic = null, removedItem:Dynamic = null, bubbles:Bool = false, cancelable:Bool = false) {
		super(type, bubbles, cancelable);
		this.index = index;
		this.addedItem = addedItem;
		this.removedItem = removedItem;
	}

	public var index:Int;
	public var addedItem:Dynamic;
	public var removedItem:Dynamic;

	override public function clone():Event {
		return new FlatCollectionEvent(this.type, this.index, this.addedItem, this.removedItem, this.bubbles, this.cancelable);
	}
}

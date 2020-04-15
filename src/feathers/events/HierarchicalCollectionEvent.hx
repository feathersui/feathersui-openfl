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
	Events dispatched by hierarchical collections.

	@see `feathers.data.IHierarhicalCollection`

	@since 1.0.0
**/
class HierarchicalCollectionEvent extends Event {
	/**
		The `HierarchicalCollectionEvent.ADD_ITEM` event type is dispatched when
		an item is added to a collection.

		@see `feathers.data.IHierarchicalCollection.addAt()`

		@since 1.0.0
	**/
	public static inline var ADD_ITEM:EventType<HierarchicalCollectionEvent> = "addItem";

	/**
		The `HierarchicalCollectionEvent.REMOVE_ITEM` event type is dispatched
		when an item is removed from a collection.

		@see `feathers.data.IHierarchicalCollection.remove()`
		@see `feathers.data.IHierarchicalCollection.removeAt()`

		@since 1.0.0
	**/
	public static inline var REMOVE_ITEM:EventType<HierarchicalCollectionEvent> = "removeItem";

	/**
		The `HierarchicalCollectionEvent.REPLACE_ITEM` event type is dispatched
		when an item is replaced in a collection.

		@see `feathers.data.IHierarchicalCollection.set()`

		@since 1.0.0
	**/
	public static inline var REPLACE_ITEM:EventType<HierarchicalCollectionEvent> = "replaceItem";

	/**
		The `HierarchicalCollectionEvent.UPDATE_ITEM` event type is dispatched
		when the `updateAt()` method is called on the collection.

		@see `feathers.data.IHierarchicalCollection.updateItem()`

		@since 1.0.0
	**/
	public static inline var UPDATE_ITEM:EventType<HierarchicalCollectionEvent> = "updateItem";

	/**
		The `HierarchicalCollectionEvent.UPDATE_ALL` event type is dispatched
		when the `updateAll()` method is called on the collection.

		@see `feathers.data.IHierarchicalCollection.updateAll()`

		@since 1.0.0
	**/
	public static inline var UPDATE_ALL:EventType<HierarchicalCollectionEvent> = "updateAll";

	/**
		The `HierarchicalCollectionEvent.RESET` event type is dispatched when
		the entire underlying data structure is replaced.

		@since 1.0.0
	**/
	public static inline var RESET:EventType<HierarchicalCollectionEvent> = "reset";

	/**
		The `HierarchicalCollectionEvent.REMOVE_ALL` event type is dispatched
		when all items are removed from the collection simulatanously by calling
		`removeAll()` on the collection.

		@see `feathers.data.IHierarchicalCollection.removeAll()`

		@since 1.0.0
	**/
	public static inline var REMOVE_ALL:EventType<HierarchicalCollectionEvent> = "removeAll";

	#if !flash
	private static var _pool = new ObjectPool<HierarchicalCollectionEvent>(() -> return new HierarchicalCollectionEvent(null, null, false, false), (event) -> {
		event.__preventDefault = false;
		event.__isCanceled = false;
		event.__isCanceledNow = false;
	});
	#end

	/**
		Dispatches a pooled event with the specified properties.

		```hx
		HierarchicalCollectionEvent.dispatch(component, Event.ADD_ITEM, 0, item);
		```

		@since 1.0.0
	**/
	public static function dispatch(dispatcher:IEventDispatcher, type:String, location:Array<Int>, addedItem:Dynamic = null, removedItem:Dynamic = null,
			bubbles:Bool = false, cancelable:Bool = false):Bool {
		#if flash
		var event = new HierarchicalCollectionEvent(type, location, bubbles, cancelable);
		return dispatcher.dispatchEvent(event);
		#else
		var event = _pool.get();
		event.type = type;
		event.location = location;
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
		Creates a new `HierarchicalCollectionEvent` object with the given arguments.

		@see `HierarchicalCollectionEvent.dispatch`

		@since 1.0.0
	**/
	public function new(type:String, location:Array<Int>, addedItem:Dynamic = null, removedItem:Dynamic = null, bubbles:Bool = false,
			cancelable:Bool = false) {
		super(type, bubbles, cancelable);
		this.location = location;
		this.addedItem = addedItem;
		this.removedItem = removedItem;
	}

	public var location:Array<Int>;
	public var addedItem:Dynamic;
	public var removedItem:Dynamic;

	override public function clone():Event {
		return new HierarchicalCollectionEvent(this.type, this.location, this.addedItem, this.removedItem, this.bubbles, this.cancelable);
	}
}

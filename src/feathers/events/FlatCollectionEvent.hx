/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.events;

import lime.utils.ObjectPool;
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

		@since 1.0.0
	**/
	public static inline var ADD_ITEM:EventType<FlatCollectionEvent> = "addItem";

	/**
		The `FlatCollectionEvent.REMOVE_ITEM` event type is dispatched when an item
		is removed from a collection.

		@since 1.0.0
	**/
	public static inline var REMOVE_ITEM:EventType<FlatCollectionEvent> = "addItem";

	/**
		The `FlatCollectionEvent.REMOVE_ITEM` event type is dispatched when an item
		is replaced in a collection.

		@since 1.0.0
	**/
	public static inline var REPLACE_ITEM:EventType<FlatCollectionEvent> = "replaceItem";

	/**
		The `FlatCollectionEvent.UPDATE_ITEM` event type is dispatched when the
		`updateAt()` method is called on the collection.

		@since 1.0.0
	**/
	public static inline var UPDATE_ITEM:EventType<FlatCollectionEvent> = "updateItem";

	/**
		The `FlatCollectionEvent.UPDATE_ALL` event type is dispatched when the
		`updateAll()` method is called on the collection.

		@since 1.0.0
	**/
	public static inline var UPDATE_ALL:EventType<FlatCollectionEvent> = "updateAll";

	/**
		The `FlatCollectionEvent.RESET` event type is dispatched when the entire
		underlying data structure is replaced.

		@since 1.0.0
	**/
	public static inline var RESET:EventType<FlatCollectionEvent> = "reset";

	private static var _pool = new ObjectPool<FlatCollectionEvent>(() -> return new FlatCollectionEvent(null, -1, false, false));

	/**
		Dispatches a pooled event with the specified properties.

		@since 1.0.0
	**/
	public static function dispatch(dispatcher:IEventDispatcher, type:String, location:Int, bubbles:Bool = false, cancelable:Bool = false):Bool {
		#if flash
		var event = new FlatCollectionEvent(type, location, bubbles, cancelable);
		return dispatcher.dispatchEvent(event);
		#else
		var event = _pool.get();
		event.type = type;
		event.location = location;
		event.bubbles = bubbles;
		event.cancelable = cancelable;
		var result = dispatcher.dispatchEvent(event);
		_pool.release(event);
		return result;
		#end
	}

	public function new(type:String, location:Int, bubbles:Bool = false, cancelable:Bool = false) {
		super(type, bubbles, cancelable);
		this.location = location;
	}

	public var location:Int;
}

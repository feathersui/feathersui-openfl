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
	Events dispatched by Feathers collections.

	@since 1.0.0
**/
class CollectionEvent extends Event {
	/**
		The `CollectionEvent.ADD_ITEM` event type is dispatched when an item is
		added to a collection.

		@since 1.0.0
	**/
	public static inline var ADD_ITEM:EventType<CollectionEvent> = "addItem";

	/**
		The `CollectionEvent.REMOVE_ITEM` event type is dispatched when an item
		is removed from a collection.

		@since 1.0.0
	**/
	public static inline var REMOVE_ITEM:EventType<CollectionEvent> = "addItem";

	/**
		The `CollectionEvent.REMOVE_ITEM` event type is dispatched when an item
		is replaced in a collection.

		@since 1.0.0
	**/
	public static inline var REPLACE_ITEM:EventType<CollectionEvent> = "replaceItem";

	private static var _pool = new ObjectPool<CollectionEvent>(() -> return new CollectionEvent(null, null, false, false));

	/**
		Dispatches a pooled event with the specified properties.

		@since 1.0.0
	**/
	public static function dispatch(dispatcher:IEventDispatcher, type:String, location:Dynamic, bubbles:Bool = false, cancelable:Bool = false):Bool {
		#if flash
		var event = new CollectionEvent(type, location bubbles, cancelable);
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

	public function new(type:String, location:Dynamic, bubbles:Bool = false, cancelable:Bool = false) {
		super(type, bubbles, cancelable);
		this.location = location;
	}

	public var location:Dynamic;
}

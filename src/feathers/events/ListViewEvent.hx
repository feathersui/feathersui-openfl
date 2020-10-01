/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.events;

import openfl.events.IEventDispatcher;
import feathers.data.ListViewItemState;
import openfl.events.EventType;
import openfl.events.Event;
#if !flash
import openfl._internal.utils.ObjectPool;
#end

/**
	Events dispatched by the `ListView` component.

	@see `feathers.controls.ListView`

	@since 1.0.0
**/
class ListViewEvent extends Event {
	/**
		The `ListViewEvent.ITEM_TRIGGER` event type is dispatched when an item
		renderer is clicked or tapped.

		@since 1.0.0
	**/
	public static inline var ITEM_TRIGGER:EventType<ListViewEvent> = "itemTrigger";

	#if !flash
	private static var _pool = new ObjectPool<ListViewEvent>(() -> return new ListViewEvent(null, null), (event) -> {
		event.target = null;
		event.currentTarget = null;
		event.__preventDefault = false;
		event.__isCanceled = false;
		event.__isCanceledNow = false;
		event.state = null;
	});
	#end

	/**
		Dispatches a pooled event with the specified properties.

		```hx
		ListViewEvent.dispatch(component, ListViewEvent.ITEM_TRIGGER, state);
		```

		@since 1.0.0
	**/
	public static function dispatch(dispatcher:IEventDispatcher, type:String, state:ListViewItemState):Bool {
		#if flash
		var event = new ListViewEvent(type, state);
		return dispatcher.dispatchEvent(event);
		#else
		var event = _pool.get();
		event.type = type;
		event.state = state;
		var result = dispatcher.dispatchEvent(event);
		_pool.release(event);
		return result;
		#end
	}

	public function new(type:String, state:ListViewItemState) {
		super(type, false, false);
		this.state = state;
	}

	public var state:ListViewItemState;
}

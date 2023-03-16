/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.events;

import feathers.data.ListViewItemState;
import openfl.events.Event;
import openfl.events.EventType;
import openfl.events.IEventDispatcher;
#if !flash
#if (openfl >= "9.1.0")
import openfl.utils.ObjectPool;
#else
import openfl._internal.utils.ObjectPool;
#end
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

		```haxe
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

	/**
		Creates a new `ListViewEvent` object with the given arguments.

		@see `ListViewEvent.dispatch`

		@since 1.0.0
	**/
	public function new(type:String, state:ListViewItemState) {
		super(type, false, false);
		this.state = state;
	}

	/**
		The current state of the item associated with this event.

		@since 1.0.0
	**/
	public var state:ListViewItemState;

	override public function clone():Event {
		return new ListViewEvent(this.type, this.state);
	}
}

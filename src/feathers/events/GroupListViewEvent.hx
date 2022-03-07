/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.events;

import openfl.events.IEventDispatcher;
import feathers.data.GroupListViewItemState;
import openfl.events.EventType;
import openfl.events.Event;
#if !flash
#if (openfl >= "9.1.0")
import openfl.utils.ObjectPool;
#else
import openfl._internal.utils.ObjectPool;
#end
#end

/**
	Events dispatched by the `GroupListView` component.

	@see `feathers.controls.GroupListView`

	@since 1.0.0
**/
class GroupListViewEvent extends Event {
	/**
		The `GroupListViewEvent.ITEM_TRIGGER` event type is dispatched when an item
		renderer is clicked or tapped.

		@since 1.0.0
	**/
	public static inline var ITEM_TRIGGER:EventType<GroupListViewEvent> = "itemTrigger";

	#if !flash
	private static var _pool = new ObjectPool<GroupListViewEvent>(() -> return new GroupListViewEvent(null, null), (event) -> {
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
		GroupListViewEvent.dispatch(component, GroupListViewEvent.ITEM_TRIGGER, state);
		```

		@since 1.0.0
	**/
	public static function dispatch(dispatcher:IEventDispatcher, type:String, state:GroupListViewItemState):Bool {
		#if flash
		var event = new GroupListViewEvent(type, state);
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
		Creates a new `GroupListViewEvent` object with the given arguments.

		@see `GroupListViewEvent.dispatch`

		@since 1.0.0
	**/
	public function new(type:String, state:GroupListViewItemState) {
		super(type, false, false);
		this.state = state;
	}

	/**
		The current state of the item associated with this event.

		@since 1.0.0
	**/
	public var state:GroupListViewItemState;

	override public function clone():Event {
		return new GroupListViewEvent(this.type, this.state);
	}
}

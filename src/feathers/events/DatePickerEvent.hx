/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.events;

import feathers.data.DatePickerItemState;
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
	Events dispatched by the `DatePicker` component.

	@see `feathers.controls.DatePicker`

	@since 1.0.0
**/
class DatePickerEvent extends Event {
	/**
		The `DatePickerEvent.ITEM_TRIGGER` event type is dispatched when an item
		renderer is clicked or tapped.

		@since 1.0.0
	**/
	public static inline var ITEM_TRIGGER:EventType<DatePickerEvent> = "itemTrigger";

	#if !flash
	private static var _pool = new ObjectPool<DatePickerEvent>(() -> return new DatePickerEvent(null, null), (event) -> {
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
		DatePickerEvent.dispatch(component, DatePickerEvent.ITEM_TRIGGER, state);
		```

		@since 1.0.0
	**/
	public static function dispatch(dispatcher:IEventDispatcher, type:String, state:DatePickerItemState):Bool {
		#if flash
		var event = new DatePickerEvent(type, state);
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
		Creates a new `DatePickerEvent` object with the given arguments.

		@see `DatePickerEvent.dispatch`

		@since 1.0.0
	**/
	public function new(type:String, state:DatePickerItemState) {
		super(type, false, false);
		this.state = state;
	}

	/**
		The current state of the item associated with this event.

		@since 1.0.0
	**/
	public var state:DatePickerItemState;

	override public function clone():Event {
		return new DatePickerEvent(this.type, this.state);
	}
}

/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.events;

import openfl.events.IEventDispatcher;
import feathers.data.ButtonBarItemState;
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
	Events dispatched by the `ButtonBar` component.

	@see `feathers.controls.ButtonBar`

	@since 1.0.0
**/
class ButtonBarEvent extends Event {
	/**
		The `ButtonBarEvent.ITEM_TRIGGER` event type is dispatched when an item
		renderer is clicked or tapped.

		@since 1.0.0
	**/
	public static inline var ITEM_TRIGGER:EventType<ButtonBarEvent> = "itemTrigger";

	#if !flash
	private static var _pool = new ObjectPool<ButtonBarEvent>(() -> return new ButtonBarEvent(null, null), (event) -> {
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
		ButtonBarEvent.dispatch(component, ButtonBarEvent.ITEM_TRIGGER, state);
		```

		@since 1.0.0
	**/
	public static function dispatch(dispatcher:IEventDispatcher, type:String, state:ButtonBarItemState):Bool {
		#if flash
		var event = new ButtonBarEvent(type, state);
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
		Creates a new `ButtonBarEvent` object with the given arguments.

		@see `ButtonBarEvent.dispatch`

		@since 1.0.0
	**/
	public function new(type:String, state:ButtonBarItemState) {
		super(type, false, false);
		this.state = state;
	}

	/**
		The current state of the item associated with this event.

		@since 1.0.0
	**/
	public var state:ButtonBarItemState;

	override public function clone():Event {
		return new ButtonBarEvent(this.type, this.state);
	}
}

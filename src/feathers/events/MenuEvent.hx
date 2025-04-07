/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.events;

import feathers.data.MenuItemState;
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
	Events dispatched by the `MenuBar` and `Menu` components.

	@see `feathers.controls.MenuBar`
	@see `feathers.controls.Menu`

	@since 1.4.0
**/
class MenuEvent extends Event {
	/**
		The `MenuEvent.ITEM_TRIGGER` event type is dispatched when an item
		renderer is clicked or tapped.

		@since 1.4.0
	**/
	public static inline var ITEM_TRIGGER:EventType<MenuEvent> = "itemTrigger";

	/**
		The `MenuEvent.ITEM_ROLL_OVER` event type is dispatched when an item
		renderer is rolled over with a mouse.

		@since 1.4.0
	**/
	public static inline var ITEM_ROLL_OVER:EventType<MenuEvent> = "itemRollOver";

	/**
		The `MenuEvent.MENU_OPEN` event type is dispatched when a menu in a
		`MenuBar` is opened.

		@since 1.4.0
	**/
	public static inline var MENU_OPEN:EventType<MenuEvent> = "menuOpen";

	/**
		The `MenuEvent.MENU_CLOSE` event type is dispatched when a menu in a
		`MenuBar` is opened.

		@since 1.4.0
	**/
	public static inline var MENU_CLOSE:EventType<MenuEvent> = "menuClose";

	#if !flash
	private static var _pool = new ObjectPool<MenuEvent>(() -> return new MenuEvent(null, null), (event) -> {
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
		MenuEvent.dispatch(component, MenuEvent.ITEM_TRIGGER, state);
		```

		@since 1.4.0
	**/
	public static function dispatch(dispatcher:IEventDispatcher, type:String, state:MenuItemState):Bool {
		#if flash
		var event = new MenuEvent(type, state);
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
		Creates a new `MenuEvent` object with the given arguments.

		@see `MenuEvent.dispatch`

		@since 1.4.0
	**/
	public function new(type:String, state:MenuItemState) {
		super(type, false, false);
		this.state = state;
	}

	/**
		The current state of the item associated with this event.

		@since 1.4.0
	**/
	public var state:MenuItemState;

	override public function clone():Event {
		return new MenuEvent(this.type, this.state);
	}
}

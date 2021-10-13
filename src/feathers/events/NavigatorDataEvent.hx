/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.events;

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
	Events dispatched by navigator components to save and restore data.

	@see `feathers.controls.navigators.StackNavigator`
	@see `feathers.controls.navigators.RouterNavigator`

	@since 1.0.0
**/
class NavigatorDataEvent extends Event {
	/**
		The `NavigatorDataEvent.SAVE_NAVIGATOR_DATA` event type is dispatched
		to a navigator's active view before it navigates to a different view.

		@since 1.0.0
	**/
	public static inline var SAVE_NAVIGATOR_DATA:EventType<NavigatorDataEvent> = "saveNavigatorData";

	/**
		The `NavigatorDataEvent.RESTORE_NAVIGATOR_DATA` event type is dispatched
		to a navigator's new active view before it navigates away from the
		previous active view.

		@since 1.0.0
	**/
	public static inline var RESTORE_NAVIGATOR_DATA:EventType<NavigatorDataEvent> = "restoreNavigatorData";

	#if !flash
	private static var _pool = new ObjectPool<NavigatorDataEvent>(() -> return new NavigatorDataEvent(null), (event) -> {
		event.target = null;
		event.currentTarget = null;
		event.__preventDefault = false;
		event.__isCanceled = false;
		event.__isCanceledNow = false;
	});
	#end

	/**
		Dispatches a pooled event with the specified properties.

		```hx
		NavigatorDataEvent.dispatch(component, NavigatorDataEvent.SAVE_NAVIGATOR_DATA);
		```

		@since 1.0.0
	**/
	public static function dispatch(dispatcher:IEventDispatcher, type:String, ?data:Dynamic):Bool {
		#if flash
		var event = new NavigatorDataEvent(type, data);
		return dispatcher.dispatchEvent(event);
		#else
		var event = _pool.get();
		event.type = type;
		event.data = data;
		var result = dispatcher.dispatchEvent(event);
		_pool.release(event);
		return result;
		#end
	}

	public function new(type:String, ?data:Dynamic) {
		super(type, false, false);
		this.data = data;
	}

	public var data:Dynamic;

	override public function clone():Event {
		return new NavigatorDataEvent(this.type, this.data);
	}
}

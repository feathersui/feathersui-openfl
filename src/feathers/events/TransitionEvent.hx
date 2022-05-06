/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.events;

import openfl.display.DisplayObject;
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
	Events dispatched by Feathers UI navigators with animated transitions.

	@since 1.0.0
**/
class TransitionEvent extends Event {
	/**
		The `TransitionEvent.TRANSITION_START` event type is dispatched when a
		navigator start transitioning between items.

		@see `feathers.controls.navigators.StackNavigator`

		@since 1.0.0
	**/
	public static inline var TRANSITION_START:EventType<TransitionEvent> = "transitionStart";

	/**
		The `TransitionEvent.TRANSITION_COMPLETE` event type is dispatched when
		a navigator completes transitioning between items.

		@see `feathers.controls.navigators.StackNavigator`

		@since 1.0.0
	**/
	public static inline var TRANSITION_COMPLETE:EventType<TransitionEvent> = "transitionComplete";

	/**
		The `TransitionEvent.TRANSITION_CANCEL` event type is dispatched when a
		navigator cancels a transition between items and has restored the
		previous item.

		@see `feathers.controls.navigators.StackNavigator`

		@since 1.0.0
	**/
	public static inline var TRANSITION_CANCEL:EventType<TransitionEvent> = "transitionCancel";

	#if !flash
	private static var _pool = new ObjectPool<TransitionEvent>(() -> return new TransitionEvent(null, null, null, null, null), (event) -> {
		event.previousViewID = null;
		event.previousView = null;
		event.nextViewID = null;
		event.nextView = null;
		event.target = null;
		event.currentTarget = null;
		event.__preventDefault = false;
		event.__isCanceled = false;
		event.__isCanceledNow = false;
	});
	#end

	/**
		Dispatches a pooled event with the specified properties.

		```haxe
		TransitionEvent.dispatch(component, Event.CHANGE, "prev-view", "next-view");
		```

		@since 1.0.0
	**/
	public static function dispatch(dispatcher:IEventDispatcher, type:String, previousViewID:String, previousView:DisplayObject, nextViewID:String,
			nextView:DisplayObject):Bool {
		#if flash
		var event = new TransitionEvent(type, previousViewID, previousView, nextViewID, nextView);
		return dispatcher.dispatchEvent(event);
		#else
		var event = _pool.get();
		event.type = type;
		event.bubbles = false;
		event.cancelable = false;
		event.previousViewID = previousViewID;
		event.previousView = previousView;
		event.nextViewID = nextViewID;
		event.nextView = nextView;
		var result = dispatcher.dispatchEvent(event);
		_pool.release(event);
		return result;
		#end
	}

	/**
		Creates a new `TransitionEvent` object with the given arguments.

		@see `TransitionEvent.dispatch`

		@since 1.0.0
	**/
	public function new(type:String, previousViewID:String, previousView:DisplayObject, nextViewID:String, nextView:DisplayObject) {
		super(type, false, false);
		this.previousViewID = previousViewID;
		this.previousView = previousView;
		this.nextViewID = nextViewID;
		this.nextView = nextView;
	}

	/**
		The previous view displayed by the navigator.

		@since 1.0.0
	**/
	public var previousView:DisplayObject;

	/**
		The ID of the previous view displayed by the navigator.

		@since 1.0.0
	**/
	public var previousViewID:String;

	/**
		The previous view displayed by the navigator.

		@since 1.0.0
	**/
	public var nextView:DisplayObject;

	/**
		The ID of the next view displayed by the navigator.

		@since 1.0.0
	**/
	public var nextViewID:String;

	override public function clone():Event {
		return new TransitionEvent(this.type, this.previousViewID, this.previousView, this.nextViewID, this.nextView);
	}
}

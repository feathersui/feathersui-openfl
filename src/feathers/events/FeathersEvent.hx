/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.events;

import openfl._internal.utils.ObjectPool;
import openfl.events.Event;
import openfl.events.EventType;
import openfl.events.IEventDispatcher;

/**
	Events dispatched by Feathers UI components.

	@since 1.0.0
**/
class FeathersEvent extends Event {
	/**
		The `FeathersEvent.INITIALIZE` event type is dispatched when a Feathers
		component has finished running its `initialize()` function.

		@see `FeathersControl.initialized`
		@see `FeathersControl.initializeNow()`

		@since 1.0.0
	**/
	public static inline var INITIALIZE:EventType<FeathersEvent> = "initialize";

	/**
		The `FeathersEvent.CREATION_COMPLETE` event type is dispatched when a
		Feathers UI component has finished validating for the first time. A
		well-designed component will have created all of its children and it
		will be completely ready for user interaction.

		@see `FeathersControl.created`

		@since 1.0.0
	**/
	public static inline var CREATION_COMPLETE:EventType<FeathersEvent> = "creationComplete";

	/**
		The `FeathersEvent.LAYOUT_DATA_CHANGE` event type is dispatched when a
		change to a Feathers UI component affects the layout of its parent
		container. For example, this event is dispatchedn when the
		`includeInLayout` or `layoutData` properties change.

		@see `FeathersControl.includeInLayout`
		@see `FeathersControl.layoutData`

		@since 1.0.0
	**/
	public static inline var LAYOUT_DATA_CHANGE:EventType<FeathersEvent> = "layoutDataChange";

	/**
		The `FeathersEvent.STATE_CHANGE` event type is dispatched by classes
		that implement the `IStateContext` interface when their current state
		changes.

		@see `feathers.core.IStateContext`
		@see `feathers.core.IStateObserver`

		@since 1.0.0
	**/
	public static inline var STATE_CHANGE:EventType<FeathersEvent> = "stateChange";

	/**
		The `FeathersEvent.TRANSITION_START` event type is dispatched when a
		navigator start transitioning between items.

		@see `feathers.controls.navigators.StackNavigator`

		@since 1.0.0
	**/
	public static inline var TRANSITION_START:EventType<FeathersEvent> = "transitionStart";

	/**
		The `FeathersEvent.TRANSITION_COMPLETE` event type is dispatched when a
		navigator completes transitioning between items.

		@see `feathers.controls.navigators.StackNavigator`

		@since 1.0.0
	**/
	public static inline var TRANSITION_COMPLETE:EventType<FeathersEvent> = "transitionComplete";

	/**
		The `FeathersEvent.TRANSITION_CANCEL` event type is dispatched when a
		navigator cancels a transition between items and has restored the
		previous item.

		@see `feathers.controls.navigators.StackNavigator`

		@since 1.0.0
	**/
	public static inline var TRANSITION_CANCEL:EventType<FeathersEvent> = "transitionCancel";

	#if !flash
	private static var _pool = new ObjectPool<FeathersEvent>(() -> return new FeathersEvent(null, false, false), (event) -> {
		event.__preventDefault = false;
		event.__isCanceled = false;
		event.__isCanceledNow = false;
	});
	#end

	/**
		Dispatches a pooled event with the specified properties.

		```hx
		FeathersEvent.dispatch(component, Event.CHANGE);
		```

		@since 1.0.0
	**/
	public static function dispatch(dispatcher:IEventDispatcher, type:String, bubbles:Bool = false, cancelable:Bool = false):Bool {
		#if flash
		var event = new FeathersEvent(type, bubbles, cancelable);
		return dispatcher.dispatchEvent(event);
		#else
		var event = _pool.get();
		event.type = type;
		event.bubbles = bubbles;
		event.cancelable = cancelable;
		var result = dispatcher.dispatchEvent(event);
		_pool.release(event);
		return result;
		#end
	}

	/**
		Creates a new `FeathersEvent` object with the given arguments.

		@see `FeathersEvent.dispatch`

		@since 1.0.0
	**/
	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false) {
		super(type, bubbles, cancelable);
	}

	override public function clone():Event {
		return new FeathersEvent(this.type, this.bubbles, this.cancelable);
	}
}

/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

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
	Events dispatched by scrolling containers.

	@see `feathers.utils.Scroller`

	@since 1.0.0
**/
class ScrollEvent extends Event {
	/**
		The `ScrollEvent.SCROLL_START` event type is dispatched when a
		scrolling container starts scrolling.

		@since 1.0.0
	**/
	public static inline var SCROLL_START:EventType<ScrollEvent> = "scrollStart";

	/**
		The `ScrollEvent.SCROLL_COMPLETE` event type is dispatched when a
		scrolling container completes scrolling.

		@since 1.0.0
	**/
	public static inline var SCROLL_COMPLETE:EventType<ScrollEvent> = "scrollComplete";

	/**
		The `ScrollEvent.SCROLL` event type is dispatched when the scroll
		position of a container changes. This is basically alias for
		`openfl.events.Event.SCROLL`.
	**/
	public static inline var SCROLL:EventType<ScrollEvent> = "scroll";

	#if !flash
	private static var _pool = new ObjectPool<ScrollEvent>(() -> return new ScrollEvent(null, false, false), (event) -> {
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
		ScrollEvent.dispatch(component, ScrollEvent.SCROLL);
		```

		@since 1.0.0
	**/
	public static function dispatch(dispatcher:IEventDispatcher, type:String, bubbles:Bool = false, cancelable:Bool = false, x:Float = 0.0,
			y:Float = 0.0):Bool {
		#if flash
		var event = new ScrollEvent(type, bubbles, cancelable, x, y);
		return dispatcher.dispatchEvent(event);
		#else
		var event = _pool.get();
		event.type = type;
		event.bubbles = bubbles;
		event.cancelable = cancelable;
		event.x = x;
		event.y = y;
		var result = dispatcher.dispatchEvent(event);
		_pool.release(event);
		return result;
		#end
	}

	/**
		Creates a new `ScrollEvent` object with the given arguments.

		@see `ScrollEvent.dispatch`

		@since 1.0.0
	**/
	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false, x:Float = 0.0, y:Float = 0.0) {
		super(type, bubbles, cancelable);
		this.x = x;
		this.y = y;
	}

	/**
		The current x position when the event was dispatched.

		@since 1.2.0
	**/
	public var x:Float;

	/**
		The current y position when the event was dispatched.

		@since 1.2.0
	**/
	public var y:Float;

	override public function clone():Event {
		return new ScrollEvent(this.type, this.bubbles, this.cancelable, this.x, this.y);
	}
}

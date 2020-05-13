/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.events;

import feathers.style.IStyleObject;
import openfl._internal.utils.ObjectPool;
import openfl.events.Event;
import openfl.events.EventType;
import openfl.events.IEventDispatcher;

/**
	Events dispatched by style provider implementations.

	@see `feathers.style.IStyleProvider`

	@since 1.0.0
**/
class StyleProviderEvent extends Event {
	/**
		The `StyleProviderEvent.STYLES_CHANGE` event type is dispatched when the
		styles of a style provider are changed.

		@since 1.0.0
	**/
	public static inline var STYLES_CHANGE:EventType<StyleProviderEvent> = "stylesChange";

	#if !flash
	private static var _pool = new ObjectPool<StyleProviderEvent>(() -> return new StyleProviderEvent(null, null), (event) -> {
		event.__preventDefault = false;
		event.__isCanceled = false;
		event.__isCanceledNow = false;
	});
	#end

	/**
		Dispatches a pooled event with the specified properties.

		```hx
		StyleProviderEvent.dispatch(component, StyleProviderEvent.STYLES_CHANGE);
		```

		@since 1.0.0
	**/
	public static function dispatch(dispatcher:IEventDispatcher, type:String, ?affectsTarget:(IStyleObject) -> Bool):Bool {
		#if flash
		var event = new StyleProviderEvent(type, affectsTarget);
		return dispatcher.dispatchEvent(event);
		#else
		var event = _pool.get();
		event.type = type;
		event.affectsTarget = affectsTarget != null ? affectsTarget : defaultAffectsTarget;
		var result = dispatcher.dispatchEvent(event);
		_pool.release(event);
		return result;
		#end
	}

	private function new(type:String, ?affectsTarget:(IStyleObject) -> Bool) {
		super(type);
		this.affectsTarget = affectsTarget != null ? affectsTarget : defaultAffectsTarget;
	}

	/**
		Determines if the event affects the specified style object.

		@since 1.0.0
	**/
	public var affectsTarget:(value:IStyleObject) -> Bool;

	override public function clone():Event {
		return new StyleProviderEvent(this.type, this.affectsTarget);
	}

	private static function defaultAffectsTarget(value:IStyleObject):Bool {
		return true;
	}
}

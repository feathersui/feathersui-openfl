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
		event.affectsTarget = affectsTarget;
		var result = dispatcher.dispatchEvent(event);
		_pool.release(event);
		return result;
		#end
	}

	public function new(type:String, ?affectsTarget:(IStyleObject) -> Bool) {
		super(type);
		if (affectsTarget != null) {
			this.affectsTarget = affectsTarget;
		}
	}

	public dynamic function affectsTarget(value:IStyleObject):Bool {
		return true;
	}

	override public function clone():Event {
		return new StyleProviderEvent(this.type, this.affectsTarget);
	}
}

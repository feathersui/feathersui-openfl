/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

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
	Events dispatched by the `Form` component.

	@see `feathers.controls.Form`

	@since 1.0.0
**/
class FormEvent extends Event {
	/**
		The `FormEvent.SUBMIT` event type is dispatched when a form is
		submitted, either by clicking the submit button or pressing the enter
		key when a control in the form has focus.

		@since 1.0.0
	**/
	public static inline var SUBMIT:EventType<FormEvent> = "submit";

	#if !flash
	private static var _pool = new ObjectPool<FormEvent>(() -> return new FormEvent(null), (event) -> {
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
		FormEvent.dispatch(component, FormEvent.SUBMIT);
		```

		@since 1.0.0
	**/
	public static function dispatch(dispatcher:IEventDispatcher, type:String):Bool {
		#if flash
		var event = new FormEvent(type);
		return dispatcher.dispatchEvent(event);
		#else
		var event = _pool.get();
		event.type = type;
		var result = dispatcher.dispatchEvent(event);
		_pool.release(event);
		return result;
		#end
	}

	public function new(type:String) {
		super(type, false, false);
	}

	override public function clone():Event {
		return new FormEvent(this.type);
	}
}

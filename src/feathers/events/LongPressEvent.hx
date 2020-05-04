/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.events;

import openfl._internal.utils.ObjectPool;
import openfl.display.InteractiveObject;
import openfl.errors.ArgumentError;
import openfl.events.Event;
import openfl.events.EventType;
import openfl.events.IEventDispatcher;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;

/**
	Dispatched with a short delay after `MouseEvent.MOUSE_DOWN` or
	`TouchEvent.TOUCH_BEGIN`.

	@since 1.0.0
**/
class LongPressEvent extends Event {
	/**
		The `LongPressEvent.LONG_PRESS` event type is dispatched when a button
		is long pressed. If dispatched, the button will not dispatch
		`TriggerEvent.TRIGGER`.

		@since 1.0.0
	**/
	public static inline var LONG_PRESS:EventType<LongPressEvent> = "longPress";

	#if !flash
	private static var _pool = new ObjectPool<LongPressEvent>(() -> return new LongPressEvent(null), (event) -> {
		event.__preventDefault = false;
		event.__isCanceled = false;
		event.__isCanceledNow = false;
	});
	#end

	/**
		Dispatches a pooled event with the specified properties.

		```hx
		LongPressEvent.dispatchFromMouseEvent(component, event);
		```

		@since 1.0.0
	**/
	public static function dispatchFromMouseEvent(dispatcher:IEventDispatcher, mouseEvent:MouseEvent):Bool {
		#if flash
		var event = fromMouseEvent(mouseEvent);
		return dispatcher.dispatchEvent(event);
		#else
		var event = _pool.get();
		event = fromMouseEvent(mouseEvent, event);
		var result = dispatcher.dispatchEvent(event);
		_pool.release(event);
		return result;
		#end
	}

	/**
		Dispatches a pooled event with the specified properties.

		```hx
		LongPressEvent.dispatchFromTouchEvent(component, event);
		```

		@since 1.0.0
	**/
	public static function dispatchFromTouchEvent(dispatcher:IEventDispatcher, touchEvent:TouchEvent):Bool {
		#if flash
		var event = fromTouchEvent(touchEvent);
		return dispatcher.dispatchEvent(event);
		#else
		var event = _pool.get();
		event = fromTouchEvent(touchEvent, event);
		var result = dispatcher.dispatchEvent(event);
		_pool.release(event);
		return result;
		#end
	}

	/**
		Creates a new `LongPressEvent` object from an existing `MouseEvent`
		object of type `MouseEvent.MOUSE_DOWN`.
	**/
	public static function fromMouseEvent(event:MouseEvent, ?existing:LongPressEvent):LongPressEvent {
		if (event.type != MouseEvent.MOUSE_DOWN) {
			throw new ArgumentError("LongPressEvent.fromMouseEvent() requires MouseEvent.MOUSE_DOWN");
		}
		#if !flash
		if (existing != null) {
			existing.type = LongPressEvent.LONG_PRESS;
			existing.bubbles = false; // Feathers UI events don't bubble
			existing.cancelable = event.cancelable;
			existing.touchPointID = -1;
			existing.isPrimaryTouchPoint = false;
			existing.localX = event.localX;
			existing.localY = event.localY;
			existing.stageX = event.stageX;
			existing.stageY = event.stageY;
			existing.sizeX = 0.0;
			existing.sizeY = 0.0;
			existing.pressure = 1.0;
			existing.relatedObject = event.relatedObject;
			existing.ctrlKey = event.ctrlKey;
			existing.altKey = event.altKey;
			existing.shiftKey = event.shiftKey;
			existing.commandKey = event.commandKey;
			return existing;
		}
		#end
		var result = new LongPressEvent(LongPressEvent.LONG_PRESS, event.bubbles, event.cancelable, -1, false, event.localX, event.localY, 0.0, 0.0, 1.0,
			event.relatedObject, event.ctrlKey, event.altKey, event.shiftKey, Reflect.hasField(event, "commandKey") ? event.commandKey : false);
		result.stageX = event.stageX;
		result.stageY = event.stageY;
		return result;
	}

	/**
		Creates a new `LongPressEvent` object from an existing `TouchEvent`
		object of type `TouchEvent.TOUCH_BEGIN`.
	**/
	public static function fromTouchEvent(event:TouchEvent, ?existing:LongPressEvent):LongPressEvent {
		if (event.type != TouchEvent.TOUCH_BEGIN) {
			throw new ArgumentError("LongPressEvent.fromTouchEvent() requires TouchEvent.TOUCH_BEGIN");
		}
		#if !flash
		if (existing != null) {
			existing.type = LongPressEvent.LONG_PRESS;
			existing.bubbles = false; // Feathers UI events don't bubble
			existing.cancelable = event.cancelable;
			existing.touchPointID = event.touchPointID;
			existing.isPrimaryTouchPoint = event.isPrimaryTouchPoint;
			existing.localX = event.localX;
			existing.localY = event.localY;
			existing.stageX = event.stageX;
			existing.stageY = event.stageY;
			existing.sizeX = event.sizeX;
			existing.sizeY = event.sizeY;
			existing.pressure = event.pressure;
			existing.relatedObject = event.relatedObject;
			existing.ctrlKey = event.ctrlKey;
			existing.altKey = event.altKey;
			existing.shiftKey = event.shiftKey;
			existing.commandKey = event.commandKey;
			return existing;
		}
		#end
		var result = new LongPressEvent(LongPressEvent.LONG_PRESS, event.bubbles, event.cancelable, event.touchPointID, event.isPrimaryTouchPoint,
			event.localX, event.localY, event.sizeX, event.sizeY, event.pressure, event.relatedObject, event.ctrlKey, event.altKey, event.shiftKey,
			event.commandKey);
		result.stageX = event.stageX;
		result.stageY = event.stageY;
		return result;
	}

	private function new(type:String, bubbles:Bool = false, cancelable:Bool = false, touchPointID:Int = 0, isPrimaryTouchPoint:Bool = false,
			localX:Float = 0.0, localY:Float = 0.0, sizeX:Float = 0.0, sizeY:Float = 0.0, pressure:Float = 1.0, ?relatedObject:InteractiveObject,
			ctrlKey:Bool = false, altKey:Bool = false, shiftKey:Bool = false, commandKey:Bool = false) {
		super(type, bubbles, cancelable);
		this.touchPointID = touchPointID;
		this.isPrimaryTouchPoint = isPrimaryTouchPoint;
		this.localX = localX;
		this.localY = localY;
		this.stageX = Math.NaN;
		this.stageY = Math.NaN;
		this.sizeX = sizeX;
		this.sizeY = sizeY;
		this.pressure = pressure;
		this.relatedObject = relatedObject;
		this.ctrlKey = ctrlKey;
		this.altKey = altKey;
		this.shiftKey = shiftKey;
		this.commandKey = commandKey;
	}

	/**
		@see `openfl.events.TouchEvent.touchPointID`

		@since 1.0.0
	**/
	public var touchPointID:Int;

	/**
		@see `openfl.events.TouchEvent.isPrimaryTouchPoint`

		@since 1.0.0
	**/
	public var isPrimaryTouchPoint:Bool;

	/**
		@see `openfl.events.MouseEvent.altKey`
		@see `openfl.events.TouchEvent.altKey`

		@since 1.0.0
	**/
	public var altKey:Bool;

	/**
		@see `openfl.events.MouseEvent.commandKey`
		@see `openfl.events.TouchEvent.commandKey`

		@since 1.0.0
	**/
	public var commandKey:Bool;

	/**
		@see `openfl.events.MouseEvent.ctrlKey`
		@see `openfl.events.TouchEvent.ctrlKey`

		@since 1.0.0
	**/
	public var ctrlKey:Bool;

	/**
		@see `openfl.events.MouseEvent.controlKey`
		@see `openfl.events.TouchEvent.controlKey`

		@since 1.0.0
	**/
	public var controlKey:Bool;

	/**
		@see `openfl.events.MouseEvent.shiftKey`
		@see `openfl.events.TouchEvent.shiftKey`

		@since 1.0.0
	**/
	public var shiftKey:Bool;

	/**
		@see `openfl.events.MouseEvent.localX`
		@see `openfl.events.TouchEvent.localX`

		@since 1.0.0
	**/
	public var localX:Float;

	/**
		@see `openfl.events.MouseEvent.localY`
		@see `openfl.events.TouchEvent.localY`

		@since 1.0.0
	**/
	public var localY:Float;

	/**
		@see `openfl.events.TouchEvent.sizeX`

		@since 1.0.0
	**/
	public var sizeX:Float;

	/**
		@see `openfl.events.TouchEvent.sizeY`

		@since 1.0.0
	**/
	public var sizeY:Float;

	/**
		@see `openfl.events.TouchEvent.pressure`

		@since 1.0.0
	**/
	public var pressure:Float;

	/**
		@see `openfl.events.MouseEvent.stageX`
		@see `openfl.events.TouchEvent.stageX`

		@since 1.0.0
	**/
	public var stageX:Float;

	/**
		@see `openfl.events.MouseEvent.stageY`
		@see `openfl.events.TouchEvent.stageY`

		@since 1.0.0
	**/
	public var stageY:Float;

	/**
		@see `openfl.events.MouseEvent.relatedObject`
		@see `openfl.events.TouchEvent.relatedObject`

		@since 1.0.0
	**/
	public var relatedObject:InteractiveObject;

	override public function clone():Event {
		var result = new LongPressEvent(this.type, this.bubbles, this.cancelable, this.touchPointID, this.isPrimaryTouchPoint, this.localX, this.localY,
			this.sizeX, this.sizeY, this.pressure, this.relatedObject, this.ctrlKey, this.altKey, this.shiftKey, this.commandKey);
		result.stageX = this.stageX;
		result.stageY = this.stageY;
		return result;
	}
}

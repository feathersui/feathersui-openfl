/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.motion.effects;

import openfl.events.Event;
import openfl.events.IEventDispatcher;

/**
	Sets the position on another effect context when a specific event is
	dispatched. The position is calculated by a custom callback.

	@since 1.0.0
**/
class EventToPositionEffectContext extends BaseDelegateEffectContext {
	/**
		Creates a new `EventToPositionEffectContext` object from the given arguments.

		@since 1.0.0
	**/
	public function new(context:IEffectContext, dispatcher:IEventDispatcher, eventType:String, callback:(Event) -> Float) {
		super(context);
		this.callback = callback;
		this.eventType = eventType;
		this.dispatcher = dispatcher;
	}

	private var _dispatcher:IEventDispatcher;

	/**
		The object that dispatches `eventType`.
	**/
	@:flash.property
	public var dispatcher(get, set):IEventDispatcher;

	private function get_dispatcher():IEventDispatcher {
		return this._dispatcher;
	}

	private function set_dispatcher(value:IEventDispatcher):IEventDispatcher {
		if (this._dispatcher == value) {
			return this._dispatcher;
		}
		this.clearEvent();
		this._dispatcher = value;
		this.updateEvent();
		return this.dispatcher;
	}

	private var _eventType:String;

	/**
		Listens for this event on from the `dispatcher`.

		@since 1.0.0
	**/
	@:flash.property
	public var eventType(get, set):String;

	private function get_eventType():String {
		return this._eventType;
	}

	private function set_eventType(value:String):String {
		if (this._eventType == value) {
			return this._eventType;
		}
		this.clearEvent();
		this._eventType = value;
		this.updateEvent();
		return this._eventType;
	}

	private var _callback:(Event) -> Float;

	/**
		The function called when the event is dispatched. Returns a new value
		for the effect context's `position` property (in the range from `0.0` to
		`1.0`).

		@since 1.0.0
	**/
	@:flash.property
	public var callback(get, set):(Event) -> Float;

	private function get_callback():(Event) -> Float {
		return this._callback;
	}

	private function set_callback(value:(Event) -> Float):(Event) -> Float {
		if (this._callback == value) {
			return this._callback;
		}
		this._callback = value;
		return this._callback;
	}

	private var _paused:Bool = true;

	override public function play():Void {
		this._paused = false;
		// does not play or pause the target effect context
	}

	override public function playReverse():Void {
		this._paused = false;
		// does not play or pause the target effect context
	}

	override public function pause():Void {
		this._paused = true;
		// does not play or pause the target effect context
	}

	private function clearEvent():Void {
		if (this._dispatcher == null || this._eventType == null) {
			return;
		}
		this._dispatcher.removeEventListener(this._eventType, eventToPositionEffectContext_dispatcher_eventHandler);
	}

	private function updateEvent():Void {
		if (this._dispatcher == null || this._eventType == null) {
			return;
		}
		this._dispatcher.addEventListener(this._eventType, eventToPositionEffectContext_dispatcher_eventHandler, false, 0, true);
	}

	private function eventToPositionEffectContext_dispatcher_eventHandler(event:Event):Void {
		if (this._paused) {
			return;
		}
		this.position = this._callback(event);
	}
}

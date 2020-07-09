/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.utils;

import feathers.events.TriggerEvent;
import openfl.display.InteractiveObject;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
#if air
import openfl.ui.Multitouch;
#end

/**
	Dispatches `TriggerEvent.TRIGGER` (or a custom event type) when the target
	is clicked or tapped.

	@see `feathers.controls.Button`
	@see `feathers.events.TriggerEvent.TRIGGER`

	@since 1.0.0
**/
class PointerTrigger {
	/**
		Creates a new `PointerTrigger` object with the given arguments.

		@since 1.0.0
	**/
	public function new(target:InteractiveObject = null, ?eventFactory:() -> Event) {
		this.target = target;
		this.eventFactory = eventFactory;
	}

	private var _target:InteractiveObject = null;

	/**
		The target component that should dispatch the event.

		@since 1.0.0
	**/
	@:flash.property
	public var target(get, set):InteractiveObject;

	private function get_target():InteractiveObject {
		return this._target;
	}

	private function set_target(value:InteractiveObject):InteractiveObject {
		if (this._target == value) {
			return this._target;
		}
		if (this._target != null) {
			this._target.removeEventListener(MouseEvent.CLICK, target_clickHandler);
			this._target.removeEventListener(TouchEvent.TOUCH_TAP, target_touchTapHandler);
		}
		this._target = value;
		if (this._target != null) {
			this._target.addEventListener(MouseEvent.CLICK, target_clickHandler);
			// TODO: temporarily disabled until isPrimaryTouchPoint bug is fixed
			// See commit: 43d659b6afa822873ded523395e2a2a1a4567a50
			// this._target.addEventListener(TouchEvent.TOUCH_TAP, target_touchTapHandler);
		}
		return this._target;
	}

	private var _eventFactory:() -> Event = null;

	/**
		The event type to dispatch on trigger. If `null`, dispatches an instance
		of `TriggerEvent`.

		@since 1.0.0
	**/
	@:flash.property
	public var eventFactory(get, set):() -> Event;

	private function get_eventFactory():() -> Event {
		return this._eventFactory;
	}

	private function set_eventFactory(value:() -> Event):() -> Event {
		if (this._eventFactory == value) {
			return this._eventFactory;
		}
		this._eventFactory = value;
		return this._eventFactory;
	}

	private var _enabled:Bool = true;

	/**
		May be set to `false` to disable the trigger event temporarily until set
		back to `true`.

		@default true

		@since 1.0.0
	**/
	@:flash.property
	public var enabled(get, set):Bool;

	private function get_enabled():Bool {
		return this._enabled;
	}

	private function set_enabled(value:Bool):Bool {
		this._enabled = value;
		return this._enabled;
	}

	private var _customHitTest:(stageX:Float, stageY:Float) -> Bool;

	/**
		In addition to the normal hit testing for mouse/touch events, a custom
		function may impose additional rules that determine if the target
		should be triggered.

		The function should return `true` if the target should be triggered, and
		`false` if it should not be triggered.

		@default null

		@since 1.0.0
	**/
	@:flash.property
	public var customHitTest(get, set):(stageX:Float, stageY:Float) -> Bool;

	private function get_customHitTest():(stageX:Float, stageY:Float) -> Bool {
		return this._customHitTest;
	}

	private function set_customHitTest(value:(stageX:Float, stageY:Float) -> Bool):(stageX:Float, stageY:Float) -> Bool {
		this._customHitTest = value;
		return this._customHitTest;
	}

	private function target_clickHandler(event:MouseEvent):Void {
		if (!this._enabled) {
			return;
		}
		if (this._customHitTest != null && !this._customHitTest(event.stageX, event.stageY)) {
			return;
		}
		if (this._eventFactory != null) {
			this._target.dispatchEvent(this._eventFactory());
			return;
		}
		TriggerEvent.dispatchFromMouseEvent(this._target, event);
	}

	private function target_touchTapHandler(event:TouchEvent):Void {
		if (!this._enabled) {
			return;
		}
		if (event.isPrimaryTouchPoint #if air && Multitouch.mapTouchToMouse #end) {
			// ignore the primary one because MouseEvent.CLICK will catch it
			return;
		}
		if (this._customHitTest != null && !this._customHitTest(event.stageX, event.stageY)) {
			return;
		}
		if (this._eventFactory != null) {
			this._target.dispatchEvent(this._eventFactory());
			return;
		}
		TriggerEvent.dispatchFromTouchEvent(this._target, event);
	}
}

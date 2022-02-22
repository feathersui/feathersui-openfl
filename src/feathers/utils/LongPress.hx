/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.utils;

import feathers.events.TriggerEvent;
import openfl.Lib;
import feathers.events.LongPressEvent;
import openfl.display.Stage;
import openfl.display.InteractiveObject;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
#if air
import openfl.ui.Multitouch;
#end

/**
	Dispatches `LongPressEvent.LONG_PRESS` (or a custom event type) on mouse
	down or touch begin after a short delay.

	@see `feathers.controls.Button`
	@see `feathers.events.LongPressEvent.LONG_PRESS`

	@since 1.0.0
**/
class LongPress {
	/**
		Creates a new `LongPress` object with the given arguments.

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
	public var target(get, set):InteractiveObject;

	private function get_target():InteractiveObject {
		return this._target;
	}

	private function set_target(value:InteractiveObject):InteractiveObject {
		if (this._target == value) {
			return this._target;
		}
		if (this._target != null) {
			this.cleanupMouseEvents();
			this.cleanupTouchEvents();
			this._target.removeEventListener(Event.REMOVED_FROM_STAGE, longPress_target_removedFromStageHandler);
			this._target.removeEventListener(MouseEvent.MOUSE_DOWN, longPress_target_mouseDownHandler);
			this._target.removeEventListener(TouchEvent.TOUCH_BEGIN, longPress_target_touchBeginHandler);
			this._target.removeEventListener(TriggerEvent.TRIGGER, longPress_target_triggerHandler);
		}
		this._target = value;
		if (this._target != null) {
			this._target.addEventListener(Event.REMOVED_FROM_STAGE, longPress_target_removedFromStageHandler, false, 0, true);
			this._target.addEventListener(MouseEvent.MOUSE_DOWN, longPress_target_mouseDownHandler, false, 0, true);
			this._target.addEventListener(TouchEvent.TOUCH_BEGIN, longPress_target_touchBeginHandler, false, 0, true);
			this._target.addEventListener(TriggerEvent.TRIGGER, longPress_target_triggerHandler, false, 10, true);
		}
		return this._target;
	}

	/**
		The duration, measured in seconds, of a long press.

		The following example changes the long press duration to one second:

		```hx
		longPress.duration = 1.0;
		```

		@since 1.0.0
	**/
	public var duration:Float = 0.5;

	private var _eventFactory:() -> Event = null;

	/**
		The event type to dispatch on long press. If `null`, dispatches an
		instance of `LongPressEvent`.

		@since 1.0.0
	**/
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
		May be set to `false` to disable the long press event temporarily until
		set back to `true`.

		@default true

		@since 1.0.0
	**/
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
	public var customHitTest(get, set):(stageX:Float, stageY:Float) -> Bool;

	private function get_customHitTest():(stageX:Float, stageY:Float) -> Bool {
		return this._customHitTest;
	}

	private function set_customHitTest(value:(stageX:Float, stageY:Float) -> Bool):(stageX:Float, stageY:Float) -> Bool {
		this._customHitTest = value;
		return this._customHitTest;
	}

	private var _savedMouseEvent:MouseEvent;
	private var _savedTouchEvent:TouchEvent;
	private var _startTime:Float;
	private var _stopNextTrigger:Bool = false;

	private function cleanupMouseEvents():Void {
		if (this._target == null) {
			return;
		}
		var stage:Stage = this._target.stage;
		if (stage != null) {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, longPress_target_stage_mouseMoveHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, longPress_target_stage_mouseUpHandler);
		}
		this._target.removeEventListener(Event.ENTER_FRAME, longPress_target_enterFrameHandler);
		this._savedMouseEvent = null;
	}

	private function cleanupTouchEvents():Void {
		if (this._target == null) {
			return;
		}
		var stage:Stage = this._target.stage;
		if (stage != null) {
			stage.removeEventListener(TouchEvent.TOUCH_MOVE, longPress_target_stage_touchMoveHandler);
			stage.removeEventListener(TouchEvent.TOUCH_END, longPress_target_stage_touchEndHandler);
		}
		this._target.removeEventListener(Event.ENTER_FRAME, longPress_target_enterFrameHandler);
		this._savedTouchEvent = null;
	}

	private function longPress_target_removedFromStageHandler(event:Event):Void {
		this.cleanupMouseEvents();
		this.cleanupTouchEvents();
	}

	private function longPress_target_mouseDownHandler(event:MouseEvent):Void {
		if (!this._enabled) {
			return;
		}
		if (this._customHitTest != null && !this._customHitTest(event.stageX, event.stageY)) {
			return;
		}
		this._startTime = Lib.getTimer();
		this._stopNextTrigger = false;
		this._savedMouseEvent = event.clone();
		var stage:Stage = this._target.stage;
		stage.addEventListener(MouseEvent.MOUSE_MOVE, longPress_target_stage_mouseMoveHandler, false, 0, true);
		stage.addEventListener(MouseEvent.MOUSE_UP, longPress_target_stage_mouseUpHandler, false, 0, true);
		this._target.addEventListener(Event.ENTER_FRAME, longPress_target_enterFrameHandler);
	}

	private function longPress_target_touchBeginHandler(event:TouchEvent):Void {
		if (!this._enabled) {
			return;
		}
		if (event.isPrimaryTouchPoint #if air && Multitouch.mapTouchToMouse #end) {
			// ignore the primary one because MouseEvent.MOUSE_DOWN will catch it
			return;
		}
		if (this._customHitTest != null && !this._customHitTest(event.stageX, event.stageY)) {
			return;
		}
		this._startTime = Lib.getTimer();
		this._stopNextTrigger = false;
		this._savedTouchEvent = event.clone();
		var stage:Stage = this._target.stage;
		stage.addEventListener(TouchEvent.TOUCH_MOVE, longPress_target_stage_touchMoveHandler, false, 0, true);
		stage.addEventListener(TouchEvent.TOUCH_END, longPress_target_stage_touchEndHandler, false, 0, true);
		this._target.addEventListener(Event.ENTER_FRAME, longPress_target_enterFrameHandler);
	}

	private function longPress_target_stage_mouseMoveHandler(event:MouseEvent):Void {
		this._savedMouseEvent.localX = event.localX;
		this._savedMouseEvent.localY = event.localY;
		this._savedMouseEvent.stageX = event.stageX;
		this._savedMouseEvent.stageY = event.stageY;
		this._savedMouseEvent.altKey = event.altKey;
		this._savedMouseEvent.ctrlKey = event.ctrlKey;
		#if flash
		if (Reflect.hasField(this._savedMouseEvent, "commandKey")) {
			Reflect.setField(this._savedMouseEvent, "commandKey", Reflect.field(event, "commandKey"));
		}
		#else
		this._savedMouseEvent.commandKey = event.commandKey;
		#end
		this._savedMouseEvent.shiftKey = event.shiftKey;
	}

	private function longPress_target_stage_touchMoveHandler(event:TouchEvent):Void {
		if (this._savedTouchEvent.touchPointID != event.touchPointID) {
			return;
		}
		this._savedTouchEvent.localX = event.localX;
		this._savedTouchEvent.localY = event.localY;
		this._savedTouchEvent.stageX = event.stageX;
		this._savedTouchEvent.stageY = event.stageY;
		this._savedTouchEvent.altKey = event.altKey;
		this._savedTouchEvent.ctrlKey = event.ctrlKey;
		#if flash
		if (Reflect.hasField(this._savedTouchEvent, "commandKey")) {
			Reflect.setField(this._savedTouchEvent, "commandKey", Reflect.field(event, "commandKey"));
		}
		#else
		this._savedTouchEvent.commandKey = event.commandKey;
		#end
		this._savedTouchEvent.shiftKey = event.shiftKey;
	}

	private function longPress_target_stage_mouseUpHandler(event:MouseEvent):Void {
		this.cleanupMouseEvents();
	}

	private function longPress_target_stage_touchEndHandler(event:TouchEvent):Void {
		if (this._savedTouchEvent.touchPointID != event.touchPointID) {
			return;
		}
		this.cleanupTouchEvents();
	}

	private function longPress_target_triggerHandler(event:TriggerEvent):Void {
		if (!this._stopNextTrigger) {
			return;
		}
		this._stopNextTrigger = false;
		event.stopImmediatePropagation();
	}

	private function longPress_target_enterFrameHandler(event:Event):Void {
		var accumulatedTime = (Lib.getTimer() - this._startTime) / 1000.0;
		if (accumulatedTime < this.duration) {
			return;
		}
		this._stopNextTrigger = true;
		if (this._savedMouseEvent != null) {
			var mouseEvent = this._savedMouseEvent;
			this.cleanupMouseEvents();
			if (this._eventFactory != null) {
				this._target.dispatchEvent(this._eventFactory());
				return;
			}
			LongPressEvent.dispatchFromMouseEvent(this._target, mouseEvent);
			return;
		}
		var touchEvent = this._savedTouchEvent;
		this.cleanupTouchEvents();
		if (this._eventFactory != null) {
			this._target.dispatchEvent(this._eventFactory());
			return;
		}
		LongPressEvent.dispatchFromTouchEvent(this._target, touchEvent);
	}
}

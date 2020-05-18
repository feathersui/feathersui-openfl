/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

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

	/**
		The target component that should dispatch the event.

		@since 1.0.0
	**/
	public var target(default, set):InteractiveObject = null;

	private function set_target(value:InteractiveObject):InteractiveObject {
		if (this.target == value) {
			return this.target;
		}
		if (this.target != null) {
			this.cleanupMouseEvents();
			this.cleanupTouchEvents();
			this.target.removeEventListener(MouseEvent.MOUSE_DOWN, target_mouseDownHandler);
			this.target.removeEventListener(TouchEvent.TOUCH_BEGIN, target_touchBeginHandler);
			this.target.removeEventListener(TriggerEvent.TRIGGER, target_triggerHandler);
		}
		this.target = value;
		if (this.target != null) {
			this.target.addEventListener(MouseEvent.MOUSE_DOWN, target_mouseDownHandler);
			this.target.addEventListener(TouchEvent.TOUCH_BEGIN, target_touchBeginHandler);
			this.target.addEventListener(TriggerEvent.TRIGGER, target_triggerHandler, false, 10);
		}
		return this.target;
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

	/**
		The event type to dispatch on long press. If `null`, dispatches an
		instance of `LongPressEvent`.

		@since 1.0.0
	**/
	public var eventFactory(default, set):() -> Event = null;

	private function set_eventFactory(value:() -> Event):() -> Event {
		if (this.eventFactory == value) {
			return this.eventFactory;
		}
		this.eventFactory = value;
		return eventFactory;
	}

	/**
		May be set to `false` to disable the long press event temporarily until
		set back to `true`.

		@default true

		@since 1.0.0
	**/
	public var enabled(default, default):Bool = true;

	/**
		In addition to the normal hit testing for mouse/touch events, a custom
		function may impose additional rules that determine if the target
		should be triggered.

		The function should return `true` if the target should be triggered, and
		`false` if it should not be triggered.

		@default null

		@since 1.0.0
	**/
	public var customHitTest(default, default):(stageX:Float, stageY:Float) -> Bool;

	private var _savedMouseEvent:MouseEvent;
	private var _savedTouchEvent:TouchEvent;
	private var _startTime:Float;
	private var _stopNextTrigger:Bool = false;

	private function target_mouseDownHandler(event:MouseEvent):Void {
		if (!this.enabled) {
			return;
		}
		if (this.customHitTest != null && !this.customHitTest(event.stageX, event.stageY)) {
			return;
		}
		this._startTime = Lib.getTimer();
		this._stopNextTrigger = false;
		this._savedMouseEvent = event.clone();
		var stage:Stage = this.target.stage;
		stage.addEventListener(MouseEvent.MOUSE_MOVE, target_stage_mouseMoveHandler, false, 0, true);
		stage.addEventListener(MouseEvent.MOUSE_UP, target_stage_mouseUpHandler, false, 0, true);
		this.target.addEventListener(Event.ENTER_FRAME, target_enterFrameHandler);
	}

	private function target_touchBeginHandler(event:TouchEvent):Void {
		if (!this.enabled) {
			return;
		}
		if (event.isPrimaryTouchPoint #if air && Multitouch.mapTouchToMouse #end) {
			// ignore the primary one because MouseEvent.MOUSE_DOWN will catch it
			return;
		}
		if (this.customHitTest != null && !this.customHitTest(event.stageX, event.stageY)) {
			return;
		}
		this._startTime = Lib.getTimer();
		this._stopNextTrigger = false;
		this._savedTouchEvent = event.clone();
		var stage:Stage = this.target.stage;
		stage.addEventListener(TouchEvent.TOUCH_MOVE, target_stage_touchMoveHandler, false, 0, true);
		stage.addEventListener(TouchEvent.TOUCH_END, target_stage_touchEndHandler, false, 0, true);
		this.target.addEventListener(Event.ENTER_FRAME, target_enterFrameHandler);
	}

	private function target_stage_mouseMoveHandler(event:MouseEvent):Void {
		this._savedMouseEvent.localX = event.localX;
		this._savedMouseEvent.localY = event.localY;
		this._savedMouseEvent.stageX = event.stageX;
		this._savedMouseEvent.stageY = event.stageY;
		this._savedMouseEvent.altKey = event.altKey;
		this._savedMouseEvent.ctrlKey = event.ctrlKey;
		this._savedMouseEvent.commandKey = event.commandKey;
		this._savedMouseEvent.shiftKey = event.shiftKey;
	}

	private function target_stage_touchMoveHandler(event:TouchEvent):Void {
		if (this._savedTouchEvent.touchPointID != event.touchPointID) {
			return;
		}
		this._savedTouchEvent.localX = event.localX;
		this._savedTouchEvent.localY = event.localY;
		this._savedTouchEvent.stageX = event.stageX;
		this._savedTouchEvent.stageY = event.stageY;
		this._savedMouseEvent.altKey = event.altKey;
		this._savedMouseEvent.ctrlKey = event.ctrlKey;
		this._savedMouseEvent.commandKey = event.commandKey;
		this._savedMouseEvent.shiftKey = event.shiftKey;
	}

	private function target_stage_mouseUpHandler(event:MouseEvent):Void {
		this.cleanupMouseEvents();
	}

	private function target_stage_touchEndHandler(event:TouchEvent):Void {
		if (this._savedTouchEvent.touchPointID != event.touchPointID) {
			return;
		}
		this.cleanupTouchEvents();
	}

	private function target_triggerHandler(event:TriggerEvent):Void {
		if (!this._stopNextTrigger) {
			return;
		}
		this._stopNextTrigger = false;
		event.stopImmediatePropagation();
	}

	private function cleanupMouseEvents():Void {
		var stage:Stage = this.target.stage;
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, target_stage_mouseMoveHandler);
		stage.removeEventListener(MouseEvent.MOUSE_UP, target_stage_mouseUpHandler);
		this.target.removeEventListener(Event.ENTER_FRAME, target_enterFrameHandler);
		this._savedMouseEvent = null;
	}

	private function cleanupTouchEvents():Void {
		var stage:Stage = this.target.stage;
		stage.removeEventListener(TouchEvent.TOUCH_MOVE, target_stage_touchMoveHandler);
		stage.removeEventListener(TouchEvent.TOUCH_END, target_stage_touchEndHandler);
		this.target.removeEventListener(Event.ENTER_FRAME, target_enterFrameHandler);
		this._savedTouchEvent = null;
	}

	private function target_enterFrameHandler(event:Event):Void {
		var accumulatedTime = (Lib.getTimer() - this._startTime) / 1000.0;
		if (accumulatedTime < this.duration) {
			return;
		}
		this._stopNextTrigger = true;
		if (this._savedMouseEvent != null) {
			this.cleanupMouseEvents();
			if (this.eventFactory != null) {
				this.target.dispatchEvent(this.eventFactory());
				return;
			}
			LongPressEvent.dispatchFromMouseEvent(this.target, this._savedMouseEvent);
			return;
		}
		this.cleanupTouchEvents();
		if (this.eventFactory != null) {
			this.target.dispatchEvent(this.eventFactory());
			return;
		}
		LongPressEvent.dispatchFromTouchEvent(this.target, this._savedTouchEvent);
	}
}

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
			this.target.removeEventListener(MouseEvent.CLICK, target_clickHandler);
			this.target.removeEventListener(TouchEvent.TOUCH_TAP, target_touchTapHandler);
		}
		this.target = value;
		if (this.target != null) {
			this.target.addEventListener(MouseEvent.CLICK, target_clickHandler);
			// TODO: temporarily disabled until isPrimaryTouchPoint bug is fixed
			// See commit: 43d659b6afa822873ded523395e2a2a1a4567a50
			// this.target.addEventListener(TouchEvent.TOUCH_TAP, target_touchTapHandler);
		}
		return this.target;
	}

	/**
		The event type to dispatch on trigger. If `null`, dispatches an instance
		of `TriggerEvent`.

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
		May be set to `false` to disable the trigger event temporarily until set
		back to `true`.

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

	private function target_clickHandler(event:MouseEvent):Void {
		if (!this.enabled) {
			return;
		}
		if (this.customHitTest != null && !this.customHitTest(event.stageX, event.stageY)) {
			return;
		}
		if (this.eventFactory != null) {
			this.target.dispatchEvent(this.eventFactory());
			return;
		}
		TriggerEvent.dispatchFromMouseEvent(this.target, event);
	}

	private function target_touchTapHandler(event:TouchEvent):Void {
		if (!this.enabled) {
			return;
		}
		if (event.isPrimaryTouchPoint #if air && Multitouch.mapTouchToMouse #end) {
			// ignore the primary one because MouseEvent.CLICK will catch it
			return;
		}
		if (this.customHitTest != null && !this.customHitTest(event.stageX, event.stageY)) {
			return;
		}
		if (this.eventFactory != null) {
			this.target.dispatchEvent(this.eventFactory());
			return;
		}
		TriggerEvent.dispatchFromTouchEvent(this.target, event);
	}
}

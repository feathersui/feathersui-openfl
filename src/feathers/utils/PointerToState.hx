/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.utils;

import feathers.core.IStateContext;
import openfl.display.InteractiveObject;
import openfl.events.Event;
import openfl.events.MouseEvent;

/**
	Changes a target's state based on pointer events (`MouseEvent` and
	`TouchEvent`), like a button.

	@see `feathers.controls.Button`
	@see `feathers.utils.KeyToState`

	@since 1.0.0
**/
class PointerToState<T> {
	/**
		Creates a new `PointerToState` object with the given arguments.

		@since 1.0.0
	**/
	public function new(target:InteractiveObject = null, callback:(T) -> Void = null, upState:T, downState:T, hoverState:T) {
		this.target = target;
		if (upState != null) {
			this.upState = upState;
		}
		if (downState != null) {
			this.downState = downState;
		}
		if (hoverState != null) {
			this.hoverState = hoverState;
		}
		this.currentState = this.upState;
		this.callback = callback;
	}

	/**
		The target component that should change state based on pointer (mouse or
		touch) events.

		@since 1.0.0
	**/
	public var target(default, set):InteractiveObject = null;

	private function set_target(value:InteractiveObject):InteractiveObject {
		if (this.target == value) {
			return this.target;
		}
		if (this.target != null) {
			this.target.removeEventListener(Event.REMOVED_FROM_STAGE, target_removedFromStageHandler);
			this.target.removeEventListener(MouseEvent.ROLL_OVER, target_rollOverHandler);
			this.target.removeEventListener(MouseEvent.ROLL_OUT, target_rollOutHandler);
			this.target.removeEventListener(MouseEvent.MOUSE_DOWN, target_mouseDownHandler);
		}
		this.target = value;
		if (this.target != null) {
			this.currentState = this.upState;
			this.target.addEventListener(Event.REMOVED_FROM_STAGE, target_removedFromStageHandler);
			this.target.addEventListener(MouseEvent.ROLL_OVER, target_rollOverHandler);
			this.target.addEventListener(MouseEvent.ROLL_OUT, target_rollOutHandler);
			this.target.addEventListener(MouseEvent.MOUSE_DOWN, target_mouseDownHandler);
		}
		return this.target;
	}

	/**
		The function to call when the state is changed.

		The callback is expected to have the following signature:

		```hx
		String -> Void
		```

		@since 1.0.0
	**/
	public var callback(default, set):(T) -> Void = null;

	private function set_callback(value:(T) -> Void):(T) -> Void {
		if (this.callback == value) {
			return this.callback;
		}
		this.callback = value;
		if (this.callback != null) {
			this.callback(this.currentState);
		}
		return callback;
	}

	/**
		The current state of the utility. May be different than the state of the
		target.

		@since 1.0.0
	**/
	public var currentState(default, null):T;

	/**
		The value for the "up" state.

		@since 1.0.0
	**/
	public var upState(default, default):T = null;

	/**
		The value for the "down" state.

		@since 1.0.0
	**/
	public var downState(default, default):T = null;

	/**
		The value for the "hover" state.

		@since 1.0.0
	**/
	public var hoverState(default, default):T = null;

	/**
		May be set to `false` to disable the state changes temporarily until set
		back to `true`.

		@default true

		@since 1.0.0
	**/
	public var enabled(default, default):Bool = true;

	/**
		If `true`, the current state will remain as `downState` until
		`MouseEvent.MOUSE_UP` is dispatched. If `false`, and the pointer leaves
		the bounds of the target after `MouseEvent.MOUSE_DOWN`, the current
		state will change to `upState`.

		@default false

		@since 1.0.0
	**/
	public var keepDownStateOnRollOut(default, default):Bool = false;

	/**
		In addition to the normal hit testing for mouse/touch events, a custom
		function may impose additional rules that determine if the target
		should change state.

		The function should return `true` if the target should change state, and
		`false` if it should not change state.

		@default null

		@since 1.0.0
	**/
	public var customHitTest(default, default):(stageX:Float, stageY:Float) -> Bool;

	private var _hoverBeforeDown:Bool = false;
	private var _down:Bool = false;

	private function changeState(value:T):Void {
		var oldState = this.currentState;
		if (Std.is(this.target, IStateContext)) {
			oldState = cast(this.target, IStateContext<Dynamic>).currentState;
		}
		this.currentState = value;
		if (oldState == value) {
			return;
		}
		if (this.callback != null) {
			this.callback(value);
		}
	}

	private function resetTouchState():Void {
		this._hoverBeforeDown = false;
		this.changeState(this.upState);
	}

	private function target_removedFromStageHandler(event:Event):Void {
		this.target.stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
		this.resetTouchState();
	}

	private function target_rollOverHandler(event:MouseEvent):Void {
		if (!this.enabled) {
			return;
		}
		if (this.customHitTest != null && !this.customHitTest(event.stageX, event.stageY)) {
			return;
		}
		this._hoverBeforeDown = true;
		if (this._down) {
			this.changeState(this.downState);
		} else {
			this.changeState(this.hoverState);
		}
	}

	private function target_rollOutHandler(event:MouseEvent):Void {
		if (!this.enabled) {
			return;
		}
		this._hoverBeforeDown = false;
		if (this.keepDownStateOnRollOut && this._down) {
			this.changeState(this.downState);
			return;
		}
		this.changeState(this.upState);
	}

	private function target_mouseDownHandler(event:MouseEvent):Void {
		if (!this.enabled) {
			return;
		}
		if (this.customHitTest != null && !this.customHitTest(event.stageX, event.stageY)) {
			return;
		}
		this._down = true;
		this.target.stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler, false, 0, true);
		this.changeState(this.downState);
	}

	private function stage_mouseUpHandler(event:MouseEvent):Void {
		this._down = false;
		this.target.stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
		if (this._hoverBeforeDown && this.target.hitTestPoint(event.stageX, event.stageY)) {
			this.changeState(this.hoverState);
		} else {
			this.resetTouchState();
		}
	}
}

/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.utils;

import openfl.display.Stage;
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
		this._currentState = this._upState;
		this.callback = callback;
	}

	private var _target:InteractiveObject = null;

	/**
		The target component that should change state based on pointer (mouse or
		touch) events.

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
			this._target.removeEventListener(Event.REMOVED_FROM_STAGE, pointerToState_target_removedFromStageHandler);
			this._target.removeEventListener(MouseEvent.ROLL_OVER, pointerToState_target_rollOverHandler);
			this._target.removeEventListener(MouseEvent.ROLL_OUT, pointerToState_target_rollOutHandler);
			this._target.removeEventListener(MouseEvent.MOUSE_DOWN, pointerToState_target_mouseDownHandler);
		}
		this._target = value;
		if (this._target != null) {
			this._currentState = this._upState;
			this._target.addEventListener(Event.REMOVED_FROM_STAGE, pointerToState_target_removedFromStageHandler);
			this._target.addEventListener(MouseEvent.ROLL_OVER, pointerToState_target_rollOverHandler);
			this._target.addEventListener(MouseEvent.ROLL_OUT, pointerToState_target_rollOutHandler);
			this._target.addEventListener(MouseEvent.MOUSE_DOWN, pointerToState_target_mouseDownHandler);
		}
		return this._target;
	}

	private var _stateContext:IStateContext<T> = null;

	/**
		An optional `IStateContext` that may be used instead of `target`.

		@since 1.0.0
	**/
	@:flash.property
	public var stateContext(get, set):IStateContext<T>;

	private function get_stateContext():IStateContext<T> {
		return this._stateContext;
	}

	private function set_stateContext(value:IStateContext<T>):IStateContext<T> {
		if (this._stateContext == value) {
			return this._stateContext;
		}
		this._stateContext = value;
		return this._stateContext;
	}

	private var _callback:(T) -> Void = null;

	/**
		The function to call when the state is changed.

		The callback is expected to have the following signature:

		```hx
		String -> Void
		```

		@since 1.0.0
	**/
	@:flash.property
	public var callback(get, set):(T) -> Void;

	private function get_callback():(T) -> Void {
		return this._callback;
	}

	private function set_callback(value:(T) -> Void):(T) -> Void {
		if (this._callback == value) {
			return this._callback;
		}
		this._callback = value;
		if (this._callback != null) {
			this._callback(this._currentState);
		}
		return this._callback;
	}

	private var _currentState:T;

	/**
		The current state of the utility. May be different than the state of the
		target.

		@since 1.0.0
	**/
	@:flash.property
	public var currentState(get, never):T;

	private function get_currentState():T {
		return this._currentState;
	}

	private var _upState:T = null;

	/**
		The value for the "up" state.

		@since 1.0.0
	**/
	@:flash.property
	public var upState(get, set):T;

	private function get_upState():T {
		return this._upState;
	}

	private function set_upState(value:T):T {
		this._upState = value;
		return this._upState;
	}

	private var _downState:T = null;

	/**
		The value for the "down" state.

		@since 1.0.0
	**/
	@:flash.property
	public var downState(get, set):T;

	private function get_downState():T {
		return this._downState;
	}

	private function set_downState(value:T):T {
		this._downState = value;
		return this._downState;
	}

	private var _hoverState:T = null;

	/**
		The value for the "hover" state.

		@since 1.0.0
	**/
	@:flash.property
	public var hoverState(get, set):T;

	private function get_hoverState():T {
		return this._hoverState;
	}

	private function set_hoverState(value:T):T {
		this._hoverState = value;
		return this._hoverState;
	}

	private var _enabled:Bool = true;

	/**
		May be set to `false` to disable the state changes temporarily until set
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

	private var _keepDownStateOnRollOut:Bool = false;

	/**
		If `true`, the current state will remain as `downState` until
		`MouseEvent.MOUSE_UP` is dispatched. If `false`, and the pointer leaves
		the bounds of the target after `MouseEvent.MOUSE_DOWN`, the current
		state will change to `upState`.

		@default false

		@since 1.0.0
	**/
	@:flash.property
	public var keepDownStateOnRollOut(get, set):Bool;

	private function get_keepDownStateOnRollOut():Bool {
		return this._keepDownStateOnRollOut;
	}

	private function set_keepDownStateOnRollOut(value:Bool):Bool {
		this._keepDownStateOnRollOut = value;
		return this._keepDownStateOnRollOut;
	}

	private var _customHitTest:(stageX:Float, stageY:Float) -> Bool;

	/**
		In addition to the normal hit testing for mouse/touch events, a custom
		function may impose additional rules that determine if the target
		should change state.

		The function should return `true` if the target should change state, and
		`false` if it should not change state.

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

	private var _hoverBeforeDown:Bool = false;

	private var _down:Bool = false;

	private function changeState(value:T):Void {
		var oldState = this._currentState;
		var targetStateContext:IStateContext<T> = this._stateContext;
		if (targetStateContext == null && (this._target is IStateContext)) {
			targetStateContext = cast this._target;
		}
		if (targetStateContext != null) {
			oldState = targetStateContext.currentState;
		}
		this._currentState = value;
		if (oldState == value) {
			return;
		}
		if (this._callback != null) {
			this._callback(value);
		}
	}

	private function resetTouchState():Void {
		this._hoverBeforeDown = false;
		this.changeState(this._upState);
	}

	private function pointerToState_target_removedFromStageHandler(event:Event):Void {
		// sometimes, OpenFL can dispatch this event multiple times, and stage
		// will be null the second time
		if (this._target.stage != null) {
			this._target.stage.removeEventListener(MouseEvent.MOUSE_UP, pointerToState_stage_mouseUpHandler);
		}
		this.resetTouchState();
	}

	private function pointerToState_target_rollOverHandler(event:MouseEvent):Void {
		if (!this._enabled) {
			return;
		}
		if (this._customHitTest != null && !this._customHitTest(event.stageX, event.stageY)) {
			return;
		}
		this._hoverBeforeDown = true;
		if (this._down) {
			this.changeState(this._downState);
		} else {
			this.changeState(this._hoverState);
		}
	}

	private function pointerToState_target_rollOutHandler(event:MouseEvent):Void {
		if (!this._enabled) {
			return;
		}
		this._hoverBeforeDown = false;
		if (this._keepDownStateOnRollOut && this._down) {
			this.changeState(this._downState);
			return;
		}
		this.changeState(this._upState);
	}

	private function pointerToState_target_mouseDownHandler(event:MouseEvent):Void {
		if (!this._enabled || this._target.stage == null) {
			return;
		}
		if (this._customHitTest != null && !this._customHitTest(event.stageX, event.stageY)) {
			return;
		}
		this._down = true;
		this._target.stage.addEventListener(MouseEvent.MOUSE_UP, pointerToState_stage_mouseUpHandler, false, 0, true);
		this.changeState(this._downState);
	}

	private function pointerToState_stage_mouseUpHandler(event:MouseEvent):Void {
		var stage = cast(event.currentTarget, Stage);
		this._down = false;
		stage.removeEventListener(MouseEvent.MOUSE_UP, pointerToState_stage_mouseUpHandler);
		if (this._hoverBeforeDown && this._target.hitTestPoint(event.stageX, event.stageY)) {
			this.changeState(this._hoverState);
		} else {
			this.resetTouchState();
		}
	}
}

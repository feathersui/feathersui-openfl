/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.utils;

import feathers.core.IFocusObject;
import feathers.core.IStateContext;
import openfl.display.InteractiveObject;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;

/**
	Changes a target's state based on keyboard events, like a button.

	@see `feathers.controls.Button`
	@see `feathers.utils.PointToState`

	@since 1.0.0
**/
class KeyToState<T> {
	/**
		Creates a new `KeyToState` object with the given arguments.

		@since 1.0.0
	**/
	public function new(target:InteractiveObject = null, callback:(T) -> Void = null, upState:T, downState:T) {
		this.target = target;
		if (upState != null) {
			this._upState = upState;
		}
		if (downState != null) {
			this.downState = downState;
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
			this._target.removeEventListener(Event.REMOVED_FROM_STAGE, keyToState_target_removedFromStageHandler);
			this._target.removeEventListener(FocusEvent.FOCUS_OUT, keyToState_target_focusOutHandler);
			this._target.removeEventListener(KeyboardEvent.KEY_DOWN, keyToState_target_keyDownHandler);
			this._target.removeEventListener(KeyboardEvent.KEY_UP, keyToState_target_keyUpHandler);
		}
		this._target = value;
		if (this._target != null) {
			this._currentState = this._upState;
			this._target.addEventListener(Event.REMOVED_FROM_STAGE, keyToState_target_removedFromStageHandler);
			this._target.addEventListener(FocusEvent.FOCUS_OUT, keyToState_target_focusOutHandler);
			this._target.addEventListener(KeyboardEvent.KEY_DOWN, keyToState_target_keyDownHandler);
			this._target.addEventListener(KeyboardEvent.KEY_UP, keyToState_target_keyUpHandler);
		}
		return this._target;
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
		if (this._enabled == value) {
			return this._enabled;
		}
		this._enabled = value;
		if (!this._enabled) {
			this.resetKeyState();
		}
		return this._enabled;
	}

	private var _downKeyCode:Null<Int> = null;

	private function changeState(value:T):Void {
		var oldState = this._currentState;
		if ((this._target is IStateContext)) {
			oldState = cast(this._target, IStateContext<Dynamic>).currentState;
		}
		this._currentState = value;
		if (oldState == value) {
			return;
		}
		if (this._callback != null) {
			this._callback(value);
		}
	}

	private function resetKeyState():Void {
		if (this._downKeyCode == null) {
			// not down, don't do anything
			return;
		}
		this._downKeyCode = null;
		this.changeState(this._upState);
	}

	private function keyToState_target_removedFromStageHandler(event:Event):Void {
		this.resetKeyState();
	}

	private function keyToState_target_focusOutHandler(event:FocusEvent):Void {
		this.resetKeyState();
	}

	private function keyToState_target_keyDownHandler(event:KeyboardEvent):Void {
		if ((this._target is IFocusObject)) {
			var focusObject = cast(this._target, IFocusObject);
			var focusManager = focusObject.focusManager;
			if (focusManager != null && focusManager.focus != focusObject) {
				return;
			}
		}
		if (!this._enabled || this._downKeyCode != null || (event.keyCode != Keyboard.SPACE && event.keyCode != Keyboard.ENTER)) {
			return;
		}
		this._downKeyCode = event.keyCode;
		this.changeState(this._downState);
	}

	private function keyToState_target_keyUpHandler(event:KeyboardEvent):Void {
		if (event.keyCode != this._downKeyCode) {
			return;
		}
		this.resetKeyState();
	}
}

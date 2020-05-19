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
			this.upState = upState;
		}
		if (downState != null) {
			this.downState = downState;
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
			this.target.removeEventListener(FocusEvent.FOCUS_OUT, target_focusOutHandler);
			this.target.removeEventListener(KeyboardEvent.KEY_DOWN, target_keyDownHandler);
			this.target.removeEventListener(KeyboardEvent.KEY_UP, target_keyUpHandler);
		}
		this.target = value;
		if (this.target != null) {
			this.currentState = this.upState;
			this.target.addEventListener(Event.REMOVED_FROM_STAGE, target_removedFromStageHandler);
			this.target.addEventListener(FocusEvent.FOCUS_OUT, target_focusOutHandler);
			this.target.addEventListener(KeyboardEvent.KEY_DOWN, target_keyDownHandler);
			this.target.addEventListener(KeyboardEvent.KEY_UP, target_keyUpHandler);
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
		May be set to `false` to disable the state changes temporarily until set
		back to `true`.

		@default true

		@since 1.0.0
	**/
	public var enabled(default, default):Bool = true;

	private var _downKeyCode:Null<Int> = null;

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

	private function resetKeyState():Void {
		this._downKeyCode = null;
		this.changeState(this.upState);
	}

	private function target_removedFromStageHandler(event:Event):Void {
		this.resetKeyState();
	}

	private function target_focusOutHandler(event:FocusEvent):Void {
		this.resetKeyState();
	}

	private function target_keyDownHandler(event:KeyboardEvent):Void {
		if (!this.enabled || this._downKeyCode != null || (event.keyCode != Keyboard.SPACE && event.keyCode != Keyboard.ENTER)) {
			return;
		}
		this._downKeyCode = event.keyCode;
		this.changeState(this.downState);
	}

	private function target_keyUpHandler(event:KeyboardEvent):Void {
		if (this._downKeyCode == null || event.keyCode != this._downKeyCode) {
			return;
		}
		this.resetKeyState();
	}
}

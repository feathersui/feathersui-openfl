/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.events.FormEvent;
import feathers.events.TriggerEvent;
import feathers.themes.steel.components.SteelFormStyles;
import openfl.display.DisplayObject;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;

/**
	Displays a collection of form controls.

	@event feathers.events.FormEvent.SUBMIT Dispatched when the form is
	submitted. This event may be dispatched when the `Form.submitButton` is
	triggered, or when `Keyboard.ENTER` is pressed while a UI control inside the
	form has focus.

	@see `feathers.controls.FormItem`

	@since 1.0.0
**/
@:event(feathers.events.FormEvent.SUBMIT)
@:styleContext
class Form extends LayoutGroup {
	/**
		Creates a new `Form` object.

		@since 1.0.0
	**/
	public function new() {
		initializeFormTheme();
		super();
		this.addEventListener(KeyboardEvent.KEY_DOWN, form_keyDownHandler);
	}

	private var _submitButton:Button;

	/**
		An optional button that submits the form when triggered.

		@since 1.0.0
	**/
	@:flash.property
	public var submitButton(get, set):Button;

	private function get_submitButton():Button {
		return this._submitButton;
	}

	private function set_submitButton(value:Button):Button {
		if (this._submitButton == value) {
			return this._submitButton;
		}
		if (this._submitButton != null) {
			this._submitButton.removeEventListener(TriggerEvent.TRIGGER, form_submitButton_triggerHandler);
		}
		this._submitButton = value;
		if (this._submitButton != null) {
			this._submitButton.addEventListener(TriggerEvent.TRIGGER, form_submitButton_triggerHandler, false, 0, true);
		}
		return this._submitButton;
	}

	/**
		Manually forces `FormEvent.SUBMIT` to be dispatched.

		@since 1.0.0
	**/
	public function submit():Void {
		FormEvent.dispatch(this, FormEvent.SUBMIT);
	}

	private function initializeFormTheme():Void {
		SteelFormStyles.initialize();
	}

	private function form_keyDownHandler(event:KeyboardEvent):Void {
		if (!this._enabled) {
			return;
		}
		if (event.keyCode != Keyboard.ENTER) {
			return;
		}
		if (event.isDefaultPrevented()) {
			return;
		}
		var current = cast(event.target, DisplayObject);
		while (current != this && current != null) {
			if ((current is FormItem)) {
				var formItem = cast(current, FormItem);
				if (!formItem.submitOnEnterEnabled) {
					return;
				}
			}
			current = current.parent;
		}
		event.preventDefault();
		this.submit();
	}

	private function form_submitButton_triggerHandler(event:TriggerEvent):Void {
		this.submit();
	}
}

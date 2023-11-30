/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import openfl.Lib;
import utest.Assert;
import utest.Test;

@:keep
class PopUpDatePickerTest extends Test {
	private var _popUpDatePicker:PopUpDatePicker;

	public function new() {
		super();
	}

	public function setup():Void {
		this._popUpDatePicker = new PopUpDatePicker();
		Lib.current.addChild(this._popUpDatePicker);
	}

	public function teardown():Void {
		if (this._popUpDatePicker.parent != null) {
			this._popUpDatePicker.parent.removeChild(this._popUpDatePicker);
		}
		this._popUpDatePicker = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testNoExceptionOnDoubleDispose():Void {
		this._popUpDatePicker.validateNow();
		this._popUpDatePicker.dispose();
		this._popUpDatePicker.dispose();
		Assert.pass();
	}

	public function testButtonDefaultVariant():Void {
		var button:Button = null;
		this._popUpDatePicker.buttonFactory = () -> {
			button = new Button();
			return button;
		}
		this._popUpDatePicker.validateNow();
		Assert.notNull(button);
		Assert.equals(PopUpDatePicker.CHILD_VARIANT_BUTTON, button.variant);
	}

	public function testButtonCustomVariant1():Void {
		final customVariant = "custom";
		this._popUpDatePicker.customButtonVariant = customVariant;
		var button:Button = null;
		this._popUpDatePicker.buttonFactory = () -> {
			button = new Button();
			return button;
		}
		this._popUpDatePicker.validateNow();
		Assert.notNull(button);
		Assert.equals(customVariant, button.variant);
	}

	public function testButtonCustomVariant2():Void {
		final customVariant = "custom";
		var button:Button = null;
		this._popUpDatePicker.buttonFactory = () -> {
			button = new Button();
			button.variant = customVariant;
			return button;
		}
		this._popUpDatePicker.validateNow();
		Assert.notNull(button);
		Assert.equals(customVariant, button.variant);
	}

	public function testButtonCustomVariant3():Void {
		final customVariant1 = "custom1";
		final customVariant2 = "custom2";
		this._popUpDatePicker.customButtonVariant = customVariant1;
		var button:Button = null;
		this._popUpDatePicker.buttonFactory = () -> {
			button = new Button();
			button.variant = customVariant2;
			return button;
		}
		this._popUpDatePicker.validateNow();
		Assert.notNull(button);
		Assert.equals(customVariant2, button.variant);
	}

	public function testTextInputDefaultVariant():Void {
		var textInput:TextInput = null;
		this._popUpDatePicker.textInputFactory = () -> {
			textInput = new TextInput();
			return textInput;
		}
		this._popUpDatePicker.validateNow();
		Assert.notNull(textInput);
		Assert.equals(PopUpDatePicker.CHILD_VARIANT_TEXT_INPUT, textInput.variant);
	}

	public function testTextInputCustomVariant1():Void {
		final customVariant = "custom";
		this._popUpDatePicker.customTextInputVariant = customVariant;
		var textInput:TextInput = null;
		this._popUpDatePicker.textInputFactory = () -> {
			textInput = new TextInput();
			return textInput;
		}
		this._popUpDatePicker.validateNow();
		Assert.notNull(textInput);
		Assert.equals(customVariant, textInput.variant);
	}

	public function testTextInputCustomVariant2():Void {
		final customVariant = "custom";
		var textInput:TextInput = null;
		this._popUpDatePicker.textInputFactory = () -> {
			textInput = new TextInput();
			textInput.variant = customVariant;
			return textInput;
		}
		this._popUpDatePicker.validateNow();
		Assert.notNull(textInput);
		Assert.equals(customVariant, textInput.variant);
	}

	public function testTextInputCustomVariant3():Void {
		final customVariant1 = "custom1";
		final customVariant2 = "custom2";
		this._popUpDatePicker.customTextInputVariant = customVariant1;
		var textInput:TextInput = null;
		this._popUpDatePicker.textInputFactory = () -> {
			textInput = new TextInput();
			textInput.variant = customVariant2;
			return textInput;
		}
		this._popUpDatePicker.validateNow();
		Assert.notNull(textInput);
		Assert.equals(customVariant2, textInput.variant);
	}
}

/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import openfl.Lib;
import openfl.events.Event;
import utest.Assert;
import utest.Test;

@:keep
class NumericStepperTest extends Test {
	private var _stepper:NumericStepper;

	public function new() {
		super();
	}

	public function setup():Void {
		this._stepper = new NumericStepper();
		Lib.current.addChild(this._stepper);
	}

	public function teardown():Void {
		if (this._stepper.parent != null) {
			this._stepper.parent.removeChild(this._stepper);
		}
		this._stepper = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testNoExceptionOnDoubleDispose():Void {
		this._stepper.validateNow();
		this._stepper.dispose();
		this._stepper.dispose();
		Assert.pass();
	}

	public function testDispatchChangeEventOnSetValue():Void {
		this._stepper.value = 0.5;
		var changed = false;
		this._stepper.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.equals(0.5, this._stepper.value);
		Assert.isFalse(changed);
		this._stepper.value = 1.0;
		Assert.isTrue(changed);
		Assert.equals(1.0, this._stepper.value);
	}

	public function testSnapInterval():Void {
		this._stepper.minimum = -1.0;
		this._stepper.maximum = 1.0;
		this._stepper.snapInterval = 0.3;

		// round up
		this._stepper.value = 0.2;
		this._stepper.applyValueRestrictions();
		Assert.equals(0.3, this._stepper.value);
		// round down
		this._stepper.value = 0.7;
		this._stepper.applyValueRestrictions();
		Assert.equals(0.6, this._stepper.value);

		// allow maximum, even if not on interval
		this._stepper.value = 1.0;
		this._stepper.applyValueRestrictions();
		Assert.equals(1.0, this._stepper.value);
		// allow minimum, even if not on interval
		this._stepper.value = -1.0;
		this._stepper.applyValueRestrictions();
		Assert.equals(-1.0, this._stepper.value);
	}

	public function testTextInputDefaultVariant():Void {
		var textInput:TextInput = null;
		this._stepper.textInputFactory = () -> {
			textInput = new TextInput();
			return textInput;
		}
		this._stepper.validateNow();
		Assert.notNull(textInput);
		Assert.equals(NumericStepper.CHILD_VARIANT_TEXT_INPUT, textInput.variant);
	}

	public function testTextInputCustomVariant1():Void {
		final customVariant = "custom";
		this._stepper.customTextInputVariant = customVariant;
		var textInput:TextInput = null;
		this._stepper.textInputFactory = () -> {
			textInput = new TextInput();
			return textInput;
		}
		this._stepper.validateNow();
		Assert.notNull(textInput);
		Assert.equals(customVariant, textInput.variant);
	}

	public function testTextInputCustomVariant2():Void {
		final customVariant = "custom";
		var textInput:TextInput = null;
		this._stepper.textInputFactory = () -> {
			textInput = new TextInput();
			textInput.variant = customVariant;
			return textInput;
		}
		this._stepper.validateNow();
		Assert.notNull(textInput);
		Assert.equals(customVariant, textInput.variant);
	}

	public function testTextInputCustomVariant3():Void {
		final customVariant1 = "custom1";
		final customVariant2 = "custom2";
		this._stepper.customTextInputVariant = customVariant1;
		var textInput:TextInput = null;
		this._stepper.textInputFactory = () -> {
			textInput = new TextInput();
			textInput.variant = customVariant2;
			return textInput;
		}
		this._stepper.validateNow();
		Assert.notNull(textInput);
		Assert.equals(customVariant2, textInput.variant);
	}

	public function testDecrementButtonDefaultVariant():Void {
		var decrementButton:Button = null;
		this._stepper.decrementButtonFactory = () -> {
			decrementButton = new Button();
			return decrementButton;
		}
		this._stepper.validateNow();
		Assert.notNull(decrementButton);
		Assert.equals(NumericStepper.CHILD_VARIANT_DECREMENT_BUTTON, decrementButton.variant);
	}

	public function testDecrementButtonCustomVariant1():Void {
		final customVariant = "custom";
		this._stepper.customDecrementButtonVariant = customVariant;
		var decrementButton:Button = null;
		this._stepper.decrementButtonFactory = () -> {
			decrementButton = new Button();
			return decrementButton;
		}
		this._stepper.validateNow();
		Assert.notNull(decrementButton);
		Assert.equals(customVariant, decrementButton.variant);
	}

	public function testDecrementButtonCustomVariant2():Void {
		final customVariant = "custom";
		var decrementButton:Button = null;
		this._stepper.decrementButtonFactory = () -> {
			decrementButton = new Button();
			decrementButton.variant = customVariant;
			return decrementButton;
		}
		this._stepper.validateNow();
		Assert.notNull(decrementButton);
		Assert.equals(customVariant, decrementButton.variant);
	}

	public function testDecrementButtonCustomVariant3():Void {
		final customVariant1 = "custom1";
		final customVariant2 = "custom2";
		this._stepper.customDecrementButtonVariant = customVariant1;
		var decrementButton:Button = null;
		this._stepper.decrementButtonFactory = () -> {
			decrementButton = new Button();
			decrementButton.variant = customVariant2;
			return decrementButton;
		}
		this._stepper.validateNow();
		Assert.notNull(decrementButton);
		Assert.equals(customVariant2, decrementButton.variant);
	}

	public function testIncrementButtonDefaultVariant():Void {
		var incrementButton:Button = null;
		this._stepper.incrementButtonFactory = () -> {
			incrementButton = new Button();
			return incrementButton;
		}
		this._stepper.validateNow();
		Assert.notNull(incrementButton);
		Assert.equals(NumericStepper.CHILD_VARIANT_INCREMENT_BUTTON, incrementButton.variant);
	}

	public function testIncrementButtonCustomVariant1():Void {
		final customVariant = "custom";
		this._stepper.customIncrementButtonVariant = customVariant;
		var incrementButton:Button = null;
		this._stepper.incrementButtonFactory = () -> {
			incrementButton = new Button();
			return incrementButton;
		}
		this._stepper.validateNow();
		Assert.notNull(incrementButton);
		Assert.equals(customVariant, incrementButton.variant);
	}

	public function testIncrementButtonCustomVariant2():Void {
		final customVariant = "custom";
		var incrementButton:Button = null;
		this._stepper.incrementButtonFactory = () -> {
			incrementButton = new Button();
			incrementButton.variant = customVariant;
			return incrementButton;
		}
		this._stepper.validateNow();
		Assert.notNull(incrementButton);
		Assert.equals(customVariant, incrementButton.variant);
	}

	public function testIncrementButtonCustomVariant3():Void {
		final customVariant1 = "custom1";
		final customVariant2 = "custom2";
		this._stepper.customIncrementButtonVariant = customVariant1;
		var incrementButton:Button = null;
		this._stepper.incrementButtonFactory = () -> {
			incrementButton = new Button();
			incrementButton.variant = customVariant2;
			return incrementButton;
		}
		this._stepper.validateNow();
		Assert.notNull(incrementButton);
		Assert.equals(customVariant2, incrementButton.variant);
	}
}

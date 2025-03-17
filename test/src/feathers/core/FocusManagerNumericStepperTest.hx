/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import feathers.controls.NumericStepper;
import openfl.Lib;
import openfl.events.FocusEvent;
import openfl.text.TextField;
import utest.Assert;
import utest.Test;

@:keep
class FocusManagerNumericStepperTest extends Test {
	private var _numericStepper:NumericStepper;

	public function new() {
		super();
	}

	public function setup():Void {
		this._numericStepper = new NumericStepper();
		Lib.current.addChild(this._numericStepper);
	}

	public function teardown():Void {
		if (this._numericStepper != null) {
			if (this._numericStepper.parent != null) {
				this._numericStepper.parent.removeChild(this._numericStepper);
			}
			this._numericStepper = null;
		}
		FocusManager.dispose();
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
		Assert.equals(1, Lib.current.stage.numChildren, "Test cleanup failed to remove all children from the stage");
	}

	public function testSetFocusManagerFocus():Void {
		var focusManager = FocusManager.addRoot(Lib.current.stage);
		this._numericStepper.validateNow();
		var focusInCount = 0;
		this._numericStepper.addEventListener(FocusEvent.FOCUS_IN, event -> {
			focusInCount++;
		});
		focusManager.focus = this._numericStepper;
		Assert.isTrue((Lib.current.stage.focus is TextField),
			'Setting stage focus without focus manager set focus to ${Lib.current.stage.focus} instead of TextField');
		Assert.equals(1, focusInCount, "FocusEvent.FOCUS_IN must be dispatched once");
	}

	public function testSetStageFocusWithFocusManager():Void {
		var focusManager = FocusManager.addRoot(Lib.current.stage);
		this._numericStepper.validateNow();
		var focusInCount = 0;
		this._numericStepper.addEventListener(FocusEvent.FOCUS_IN, event -> {
			focusInCount++;
		});
		Lib.current.stage.focus = this._numericStepper;
		Assert.isTrue((Lib.current.stage.focus is TextField),
			'Setting stage focus without focus manager set focus to ${Lib.current.stage.focus} instead of TextField');
		Assert.equals(1, focusInCount, "FocusEvent.FOCUS_IN must be dispatched once");
	}

	public function testSetStageFocusWithoutFocusManager():Void {
		this._numericStepper.validateNow();
		var focusInCount = 0;
		this._numericStepper.addEventListener(FocusEvent.FOCUS_IN, event -> {
			focusInCount++;
		});
		Lib.current.stage.focus = this._numericStepper;
		Assert.isTrue((Lib.current.stage.focus is TextField),
			'Setting stage focus without focus manager set focus to ${Lib.current.stage.focus} instead of TextField');
		Assert.equals(1, focusInCount, "FocusEvent.FOCUS_IN must be dispatched once");
	}
}

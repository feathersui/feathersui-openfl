/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

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
}

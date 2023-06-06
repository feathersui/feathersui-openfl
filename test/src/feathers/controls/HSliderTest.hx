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
class HSliderTest extends Test {
	private var _slider:HSlider;

	public function new() {
		super();
	}

	public function setup():Void {
		this._slider = new HSlider();
		Lib.current.addChild(this._slider);
	}

	public function teardown():Void {
		if (this._slider.parent != null) {
			this._slider.parent.removeChild(this._slider);
		}
		this._slider = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testNoExceptionOnDoubleDispose():Void {
		this._slider.validateNow();
		this._slider.dispose();
		this._slider.dispose();
		Assert.pass();
	}

	public function testDispatchChangeEventOnSetValue():Void {
		this._slider.value = 0.5;
		var changed = false;
		this._slider.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.equals(0.5, this._slider.value);
		Assert.isFalse(changed);
		this._slider.value = 1.0;
		Assert.isTrue(changed);
		Assert.equals(1.0, this._slider.value);
	}

	public function testSnapInterval():Void {
		this._slider.minimum = -1.0;
		this._slider.maximum = 1.0;
		this._slider.snapInterval = 0.3;

		// round up
		this._slider.value = 0.2;
		this._slider.applyValueRestrictions();
		Assert.equals(0.3, this._slider.value);
		// round down
		this._slider.value = 0.7;
		this._slider.applyValueRestrictions();
		Assert.equals(0.6, this._slider.value);

		// allow maximum, even if not on interval
		this._slider.value = 1.0;
		this._slider.applyValueRestrictions();
		Assert.equals(1.0, this._slider.value);
		// allow minimum, even if not on interval
		this._slider.value = -1.0;
		this._slider.applyValueRestrictions();
		Assert.equals(-1.0, this._slider.value);
	}
}

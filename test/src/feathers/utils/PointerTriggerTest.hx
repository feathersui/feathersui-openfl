/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.utils;

import feathers.controls.LayoutGroup;
import feathers.events.TriggerEvent;
import openfl.Lib;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
import utest.Assert;
import utest.Test;

@:keep
class PointerTriggerTest extends Test {
	private var _control:LayoutGroup;
	private var _pointerTrigger:PointerTrigger;

	public function new() {
		super();
	}

	public function setup():Void {
		this._control = new LayoutGroup();
		Lib.current.addChild(this._control);
		this._pointerTrigger = new PointerTrigger(this._control);
	}

	public function teardown():Void {
		if (this._control.parent != null) {
			this._control.parent.removeChild(this._control);
		}
		this._control = null;
		this._pointerTrigger = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testPointerTriggerFromMouseEvent():Void {
		var triggered = false;
		this._control.addEventListener(TriggerEvent.TRIGGER, function(event:TriggerEvent):Void {
			triggered = true;
		});
		Assert.isFalse(triggered);
		this._control.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		Assert.isTrue(triggered);
	}

	#if (openfl >= "9.0.0")
	public function testPointerTriggerFromTouchEvent():Void {
		var triggered = false;
		this._control.addEventListener(TriggerEvent.TRIGGER, function(event:TriggerEvent):Void {
			triggered = true;
		});
		Assert.isFalse(triggered);
		this._control.dispatchEvent(new TouchEvent(TouchEvent.TOUCH_TAP));
		Assert.isTrue(triggered);
	}
	#end
}

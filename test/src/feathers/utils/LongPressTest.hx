/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.utils;

import openfl.events.TouchEvent;
import haxe.Timer;
import feathers.controls.LayoutGroup;
import feathers.events.LongPressEvent;
import openfl.Lib;
import openfl.events.MouseEvent;
import utest.Assert;
import utest.Async;
import utest.Test;

@:keep
class LongPressTest extends Test {
	private var _control:LayoutGroup;
	private var _longPress:LongPress;

	public function new() {
		super();
	}

	public function setup():Void {
		this._control = new LayoutGroup();
		Lib.current.addChild(this._control);
		this._longPress = new LongPress(this._control);
	}

	public function teardown():Void {
		if (this._control.parent != null) {
			this._control.parent.removeChild(this._control);
		}
		this._control = null;
		this._longPress = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	@:timeout(1000)
	public function testLongPressEventFromMouseDown(async:Async):Void {
		var longPressed = false;
		this._control.addEventListener(LongPressEvent.LONG_PRESS, function(event:LongPressEvent):Void {
			longPressed = true;
		});
		this._control.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
		Assert.isFalse(longPressed);
		Timer.delay(() -> {
			if (async.timedOut) {
				return;
			}
			Assert.isTrue(longPressed);
			async.done();
		}, 750);
	}

	@:timeout(1000)
	public function testMouseUpBeforeLongPressEventFromMouseDown(async:Async):Void {
		var longPressed = false;
		this._control.addEventListener(LongPressEvent.LONG_PRESS, function(event:LongPressEvent):Void {
			longPressed = true;
		});
		this._control.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
		this._control.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
		Assert.isFalse(longPressed);
		Timer.delay(() -> {
			if (async.timedOut) {
				return;
			}
			Assert.isFalse(longPressed);
			async.done();
		}, 750);
	}

	@:timeout(1000)
	public function testLongPressEventFromTouchBegin(async:Async):Void {
		var longPressed = false;
		this._control.addEventListener(LongPressEvent.LONG_PRESS, function(event:LongPressEvent):Void {
			longPressed = true;
		});
		this._control.dispatchEvent(new TouchEvent(TouchEvent.TOUCH_BEGIN));
		Assert.isFalse(longPressed);
		Timer.delay(() -> {
			if (async.timedOut) {
				return;
			}
			Assert.isTrue(longPressed);
			async.done();
		}, 750);
	}

	@:timeout(1000)
	public function testTouchEndBeforeLongPressEventFromTouchBegin(async:Async):Void {
		var longPressed = false;
		this._control.addEventListener(LongPressEvent.LONG_PRESS, function(event:LongPressEvent):Void {
			longPressed = true;
		});
		this._control.dispatchEvent(new TouchEvent(TouchEvent.TOUCH_BEGIN));
		this._control.dispatchEvent(new TouchEvent(TouchEvent.TOUCH_END));
		Assert.isFalse(longPressed);
		Timer.delay(() -> {
			if (async.timedOut) {
				return;
			}
			Assert.isFalse(longPressed);
			async.done();
		}, 750);
	}
}

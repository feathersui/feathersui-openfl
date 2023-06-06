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
class VScrollBarTest extends Test {
	private var _scrollBar:VScrollBar;

	public function new() {
		super();
	}

	public function setup():Void {
		this._scrollBar = new VScrollBar();
		Lib.current.addChild(this._scrollBar);
	}

	public function teardown():Void {
		if (this._scrollBar.parent != null) {
			this._scrollBar.parent.removeChild(this._scrollBar);
		}
		this._scrollBar = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testNoExceptionOnDoubleDispose():Void {
		this._scrollBar.validateNow();
		this._scrollBar.dispose();
		this._scrollBar.dispose();
		Assert.pass();
	}

	public function testDispatchChangeEventOnSetValue():Void {
		this._scrollBar.value = 0.5;
		var changed = false;
		this._scrollBar.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.equals(0.5, this._scrollBar.value);
		Assert.isFalse(changed);
		this._scrollBar.value = 1.0;
		Assert.isTrue(changed);
		Assert.equals(1.0, this._scrollBar.value);
	}

	public function testSnapInterval():Void {
		this._scrollBar.minimum = -1.0;
		this._scrollBar.maximum = 1.0;
		this._scrollBar.snapInterval = 0.3;

		// round up
		this._scrollBar.value = 0.2;
		this._scrollBar.applyValueRestrictions();
		Assert.equals(0.3, this._scrollBar.value);
		// round down
		this._scrollBar.value = 0.7;
		this._scrollBar.applyValueRestrictions();
		Assert.equals(0.6, this._scrollBar.value);

		// allow maximum, even if not on interval
		this._scrollBar.value = 1.0;
		this._scrollBar.applyValueRestrictions();
		Assert.equals(1.0, this._scrollBar.value);
		// allow minimum, even if not on interval
		this._scrollBar.value = -1.0;
		this._scrollBar.applyValueRestrictions();
		Assert.equals(-1.0, this._scrollBar.value);
	}
}

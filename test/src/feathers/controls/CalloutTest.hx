/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.data.ArrayCollection;
import openfl.Lib;
import openfl.events.Event;
import utest.Assert;
import utest.Test;

@:keep
class CalloutTest extends Test {
	private var _callout:Callout;

	public function new() {
		super();
	}

	public function setup():Void {
		this._callout = new Callout();
		Lib.current.addChild(this._callout);
	}

	public function teardown():Void {
		if (this._callout.parent != null) {
			this._callout.parent.removeChild(this._callout);
		}
		this._callout = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testValidateWithNoContentOrOrigin():Void {
		this._callout.validateNow();
		Assert.pass();
	}

	public function testNoExceptionOnDoubleDispose():Void {
		this._callout.validateNow();
		this._callout.dispose();
		this._callout.dispose();
		Assert.pass();
	}
}

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
class HeaderTest extends Test {
	private var _header:Header;

	public function new() {
		super();
	}

	public function setup():Void {
		this._header = new Header();
		Lib.current.addChild(this._header);
	}

	public function teardown():Void {
		if (this._header.parent != null) {
			this._header.parent.removeChild(this._header);
		}
		this._header = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testNoExceptionOnDoubleDispose():Void {
		this._header.validateNow();
		this._header.dispose();
		this._header.dispose();
		Assert.pass();
	}
}

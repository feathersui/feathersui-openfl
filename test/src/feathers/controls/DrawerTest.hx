/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

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
class DrawerTest extends Test {
	private var _drawer:Drawer;

	public function new() {
		super();
	}

	public function setup():Void {
		this._drawer = new Drawer();
		Lib.current.addChild(this._drawer);
	}

	public function teardown():Void {
		if (this._drawer.parent != null) {
			this._drawer.parent.removeChild(this._drawer);
		}
		this._drawer = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testNoExceptionOnDoubleDispose():Void {
		this._drawer.validateNow();
		this._drawer.dispose();
		this._drawer.dispose();
		Assert.pass();
	}
}

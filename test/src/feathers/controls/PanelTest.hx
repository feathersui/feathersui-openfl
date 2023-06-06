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
class PanelTest extends Test {
	private var _panel:Panel;

	public function new() {
		super();
	}

	public function setup():Void {
		this._panel = new Panel();
		Lib.current.addChild(this._panel);
	}

	public function teardown():Void {
		if (this._panel.parent != null) {
			this._panel.parent.removeChild(this._panel);
		}
		this._panel = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testNoExceptionOnDoubleDispose():Void {
		this._panel.validateNow();
		this._panel.dispose();
		this._panel.dispose();
		Assert.pass();
	}
}

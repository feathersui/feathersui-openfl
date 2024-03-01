/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes;

import feathers.controls.Button;
import utest.Assert;
import utest.Test;

@:keep
class DefaultThemeTest extends Test {
	private var _control:Button;

	public function new() {
		super();
	}

	public function setup():Void {
		this._control = new Button();
	}

	public function teardown():Void {
		this._control = null;
	}

	public function testDefaultThemeStyles():Void {
		this._control.validateNow();
		Assert.notNull(this._control.backgroundSkin, "Must have a default style");
	}
}

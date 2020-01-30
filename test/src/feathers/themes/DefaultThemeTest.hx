/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes;

import massive.munit.Assert;
import feathers.controls.Button;

@:keep
class DefaultThemeTest {
	private var _control:Button;

	@Before
	public function prepare():Void {
		this._control = new Button();
	}

	@After
	public function cleanup():Void {
		this._control = null;
	}

	@Test
	public function testDefaultThemeStyles():Void {
		this._control.validateNow();
		Assert.isNotNull(this._control.backgroundSkin, "Must have a default style");
	}
}

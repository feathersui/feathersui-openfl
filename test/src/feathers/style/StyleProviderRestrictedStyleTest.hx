/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.style;

import massive.munit.Assert;
import openfl.display.Shape;
import feathers.controls.Button;

@:keep
class StyleProviderRestrictedStyleTest {
	private var _styleProvider:FunctionStyleProvider;
	private var _control:Button;
	private var _skin:Shape;

	@Before
	public function prepare():Void {
		this._skin = new Shape();
		this._styleProvider = new FunctionStyleProvider(function(target:Button):Void {
			target.backgroundSkin = this._skin;
		});
		this._control = new Button();
	}

	@After
	public function cleanup():Void {
		this._control = null;
		this._skin = null;
		this._styleProvider = null;
	}

	@Test
	public function testNoStyleProvider():Void {
		this._control.validateNow();
		Assert.areNotEqual(this._skin, this._control.backgroundSkin, "Style provider must not set style when not used");
		Assert.isNotNull(this._control.backgroundSkin, "Must have a default style");
	}

	@Test
	public function testStyleProvider():Void {
		this._control.styleProvider = this._styleProvider;
		this._control.validateNow();
		Assert.areEqual(this._skin, this._control.backgroundSkin, "Style provider must set style when unrestricted");
	}

	@Test
	public function testStyleProviderWithRestrictedProperty():Void {
		this._control.backgroundSkin = new Shape();
		this._control.styleProvider = this._styleProvider;
		this._control.validateNow();
		Assert.areNotEqual(this._skin, this._control.backgroundSkin, "Style provider must not set restricted style");
	}
}

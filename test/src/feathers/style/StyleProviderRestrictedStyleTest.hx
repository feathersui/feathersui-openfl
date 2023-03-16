/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.style;

import feathers.controls.Button;
import openfl.Lib;
import openfl.display.Shape;
import utest.Assert;
import utest.Test;

@:keep
class StyleProviderRestrictedStyleTest extends Test {
	private var _styleProvider:FunctionStyleProvider;
	private var _control:Button;
	private var _skin:Shape;

	public function new() {
		super();
	}

	public function setup():Void {
		this._skin = new Shape();
		this._styleProvider = new FunctionStyleProvider(function(target:Button):Void {
			target.backgroundSkin = this._skin;
		});
		this._control = new Button();
	}

	public function teardown():Void {
		this._control = null;
		this._skin = null;
		this._styleProvider = null;
	}

	public function testNoStyleProvider():Void {
		this._control.validateNow();
		Assert.notEquals(this._skin, this._control.backgroundSkin, "Style provider must not set style when not used");
		Assert.notNull(this._control.backgroundSkin, "Must have a default style");
	}

	public function testStyleProvider():Void {
		this._control.styleProvider = this._styleProvider;
		this._control.validateNow();
		Assert.equals(this._skin, this._control.backgroundSkin, "Style provider must set style when unrestricted");
	}

	public function testStyleProviderWithRestrictedProperty():Void {
		this._control.backgroundSkin = new Shape();
		this._control.styleProvider = this._styleProvider;
		this._control.validateNow();
		Assert.notEquals(this._skin, this._control.backgroundSkin, "Style provider must not set restricted style");
	}
}

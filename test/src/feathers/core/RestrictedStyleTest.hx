/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import feathers.controls.BasicButton;
import feathers.controls.ButtonState;
import openfl.Lib;
import openfl.display.Sprite;
import utest.Assert;
import utest.Test;

@:keep
@:access(feathers.core.FeathersControl)
class RestrictedStyleTest extends Test {
	private var _control:BasicButton;

	public function new() {
		super();
	}

	public function setup():Void {
		this._control = new BasicButton();
	}

	public function teardown():Void {
		this._control = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testStyleNotRestrictedAfterConstructor():Void {
		Assert.isFalse(this._control.isStyleRestricted("backgroundSkin"), "Style property must not be restricted after constructor.");
	}

	public function testStyleNotRestrictedAfterInitialize():Void {
		this._control.initializeNow();
		Assert.isFalse(this._control.isStyleRestricted("backgroundSkin"), "Style property must not be restricted after initialize.");
	}

	public function testStyleNotRestrictedAfterValidate():Void {
		this._control.validateNow();
		Assert.isFalse(this._control.isStyleRestricted("backgroundSkin"), "Style property must not be restricted after validate.");
	}

	public function testRestrictedStyle():Void {
		this._control.backgroundSkin = new Sprite();
		Assert.isTrue(this._control.isStyleRestricted("backgroundSkin"), "Setting style property must restrict it.");
		Assert.isFalse(this._control.isStyleRestricted("textFormat"), "Setting style property must not restrict a different style.");
	}

	public function testStyleWithStateNotRestrictedAfterConstructor():Void {
		Assert.isFalse(this._control.isStyleRestricted("setSkinForState", ButtonState.DOWN), "Style with state must not be restricted after constructor.");
	}

	public function testStyleWithStateNotRestrictedAfterInitialize():Void {
		this._control.initializeNow();
		Assert.isFalse(this._control.isStyleRestricted("setSkinForState", ButtonState.DOWN), "Style with state must not be restricted after initialize.");
	}

	public function testStyleWithStateNotRestrictedAfterValidate():Void {
		this._control.validateNow();
		Assert.isFalse(this._control.isStyleRestricted("setSkinForState", ButtonState.DOWN), "Style with state must not be restricted after validate.");
	}

	public function testRestrictedStyleWithState():Void {
		this._control.setSkinForState(ButtonState.DOWN, new Sprite());
		Assert.isTrue(this._control.isStyleRestricted("setSkinForState", ButtonState.DOWN), "Calling style for state function must restrict it.");
		Assert.isFalse(this._control.isStyleRestricted("setSkinForState", ButtonState.HOVER),
			"Calling style for state function must not restrict a different state.");
	}
}

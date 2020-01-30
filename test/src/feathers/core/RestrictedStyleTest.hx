/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import feathers.controls.ButtonState;
import openfl.display.Sprite;
import feathers.controls.BasicButton;
import massive.munit.Assert;

@:keep
@:access(feathers.core.FeathersControl)
class RestrictedStyleTest {
	private var _control:BasicButton;

	@Before
	public function prepare():Void {
		this._control = new BasicButton();
	}

	@After
	public function cleanup():Void {
		this._control = null;
		Assert.areEqual(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
	}

	@Test
	public function testStyleNotRestrictedAfterConstructor():Void {
		Assert.isFalse(this._control.isStyleRestricted("backgroundSkin"), "Style property must not be restricted after constructor.");
	}

	@Test
	public function testStyleNotRestrictedAfterInitialize():Void {
		this._control.initializeNow();
		Assert.isFalse(this._control.isStyleRestricted("backgroundSkin"), "Style property must not be restricted after initialize.");
	}

	@Test
	public function testStyleNotRestrictedAfterValidate():Void {
		this._control.validateNow();
		Assert.isFalse(this._control.isStyleRestricted("backgroundSkin"), "Style property must not be restricted after validate.");
	}

	@Test
	public function testRestrictedStyle():Void {
		this._control.backgroundSkin = new Sprite();
		Assert.isTrue(this._control.isStyleRestricted("backgroundSkin"), "Setting style property must restrict it.");
		Assert.isFalse(this._control.isStyleRestricted("textFormat"), "Setting style property must not restrict a different style.");
	}

	@Test
	public function testStyleWithStateNotRestrictedAfterConstructor():Void {
		Assert.isFalse(this._control.isStyleRestricted("setSkinForState", ButtonState.DOWN), "Style with state must not be restricted after constructor.");
	}

	@Test
	public function testStyleWithStateNotRestrictedAfterInitialize():Void {
		this._control.initializeNow();
		Assert.isFalse(this._control.isStyleRestricted("setSkinForState", ButtonState.DOWN), "Style with state must not be restricted after initialize.");
	}

	@Test
	public function testStyleWithStateNotRestrictedAfterValidate():Void {
		this._control.validateNow();
		Assert.isFalse(this._control.isStyleRestricted("setSkinForState", ButtonState.DOWN), "Style with state must not be restricted after validate.");
	}

	@Test
	public function testRestrictedStyleWithState():Void {
		this._control.setSkinForState(ButtonState.DOWN, new Sprite());
		Assert.isTrue(this._control.isStyleRestricted("setSkinForState", ButtonState.DOWN), "Calling style for state function must restrict it.");
		Assert.isFalse(this._control.isStyleRestricted("setSkinForState", ButtonState.HOVER),
			"Calling style for state function must not restrict a different state.");
	}
}

/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import openfl.display.Shape;
import massive.munit.Assert;

@:keep
@:access(feathers.controls.Button)
class ButtonTest {
	private var _button:Button;

	@Before
	public function prepare():Void {
		this._button = new Button();
		TestMain.openfl_root.addChild(this._button);
	}

	@After
	public function cleanup():Void {
		if (this._button.parent != null) {
			this._button.parent.removeChild(this._button);
		}
		this._button = null;
		Assert.areEqual(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
	}

	@Test
	public function testRemoveIconAfterSetToNewValue():Void {
		var icon1 = new Shape();
		var icon2 = new Shape();
		Assert.isNull(icon1.parent);
		Assert.isNull(icon2.parent);
		this._button.icon = icon1;
		this._button.validateNow();
		Assert.areEqual(this._button, icon1.parent);
		Assert.isNull(icon2.parent);
		this._button.icon = icon2;
		this._button.validateNow();
		Assert.isNull(icon1.parent);
		Assert.areEqual(this._button, icon2.parent);
	}

	@Test
	public function testRemoveIconAfterSetToNull():Void {
		var icon = new Shape();
		Assert.isNull(icon.parent);
		this._button.icon = icon;
		this._button.validateNow();
		Assert.areEqual(this._button, icon.parent);
		this._button.icon = null;
		this._button.validateNow();
		Assert.isNull(icon.parent);
	}

	@Test
	public function testRemoveIconAfterDisable():Void {
		var icon1 = new Shape();
		var icon2 = new Shape();
		Assert.isNull(icon1.parent);
		Assert.isNull(icon2.parent);
		this._button.icon = icon1;
		this._button.setIconForState(ButtonState.DISABLED, icon2);
		this._button.validateNow();
		Assert.areEqual(this._button, icon1.parent);
		Assert.isNull(icon2.parent);
		this._button.enabled = false;
		this._button.validateNow();
		Assert.isNull(icon1.parent);
		Assert.areEqual(this._button, icon2.parent);
	}

	@Test
	public function testRemoveIconAfterChangeState():Void {
		var icon1 = new Shape();
		var icon2 = new Shape();
		Assert.isNull(icon1.parent);
		Assert.isNull(icon2.parent);
		this._button.icon = icon1;
		this._button.setIconForState(ButtonState.DOWN, icon2);
		this._button.validateNow();
		Assert.areEqual(this._button, icon1.parent);
		Assert.isNull(icon2.parent);
		this._button.changeState(ButtonState.DOWN);
		this._button.validateNow();
		Assert.isNull(icon1.parent);
		Assert.areEqual(this._button, icon2.parent);
	}
}

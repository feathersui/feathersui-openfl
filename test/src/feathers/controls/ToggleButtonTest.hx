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
@:access(feathers.controls.ToggleButton)
class ToggleButtonTest {
	private var _button:ToggleButton;

	@Before
	public function prepare():Void {
		this._button = new ToggleButton();
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
		this._button.setIconForState(ToggleButtonState.DISABLED(false), icon2);
		this._button.validateNow();
		Assert.areEqual(this._button, icon1.parent);
		Assert.isNull(icon2.parent);
		this._button.enabled = false;
		this._button.validateNow();
		Assert.isNull(icon1.parent);
		Assert.areEqual(this._button, icon2.parent);
	}

	@Test
	public function testRemoveIconAfterSelect():Void {
		var icon1 = new Shape();
		var icon2 = new Shape();
		Assert.isNull(icon1.parent);
		Assert.isNull(icon2.parent);
		this._button.icon = icon1;
		this._button.selectedIcon = icon2;
		this._button.validateNow();
		Assert.areEqual(this._button, icon1.parent);
		Assert.isNull(icon2.parent);
		this._button.selected = true;
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
		this._button.setIconForState(ToggleButtonState.DOWN(false), icon2);
		this._button.validateNow();
		Assert.areEqual(this._button, icon1.parent);
		Assert.isNull(icon2.parent);
		this._button.changeState(ToggleButtonState.DOWN(false));
		this._button.validateNow();
		Assert.isNull(icon1.parent);
		Assert.areEqual(this._button, icon2.parent);
	}
}

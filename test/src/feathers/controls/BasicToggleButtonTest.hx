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
@:access(feathers.controls.BasicToggleButton)
class BasicToggleButtonTest {
	private var _button:BasicToggleButton;

	@Before
	public function prepare():Void {
		this._button = new BasicToggleButton();
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
	public function testRemoveSkinAfterSetToNewValue():Void {
		var skin1 = new Shape();
		var skin2 = new Shape();
		Assert.isNull(skin1.parent);
		Assert.isNull(skin2.parent);
		this._button.backgroundSkin = skin1;
		this._button.validateNow();
		Assert.areEqual(this._button, skin1.parent);
		Assert.isNull(skin2.parent);
		this._button.backgroundSkin = skin2;
		this._button.validateNow();
		Assert.isNull(skin1.parent);
		Assert.areEqual(this._button, skin2.parent);
	}

	@Test
	public function testRemoveSkinAfterSetToNull():Void {
		var skin = new Shape();
		Assert.isNull(skin.parent);
		this._button.backgroundSkin = skin;
		this._button.validateNow();
		Assert.areEqual(this._button, skin.parent);
		this._button.backgroundSkin = null;
		this._button.validateNow();
		Assert.isNull(skin.parent);
	}

	@Test
	public function testRemoveSkinAfterDisable():Void {
		var skin1 = new Shape();
		var skin2 = new Shape();
		Assert.isNull(skin1.parent);
		Assert.isNull(skin2.parent);
		this._button.backgroundSkin = skin1;
		this._button.setSkinForState(ToggleButtonState.DISABLED(false), skin2);
		this._button.validateNow();
		Assert.areEqual(this._button, skin1.parent);
		Assert.isNull(skin2.parent);
		this._button.enabled = false;
		this._button.validateNow();
		Assert.isNull(skin1.parent);
		Assert.areEqual(this._button, skin2.parent);
	}

	@Test
	public function testRemoveSkinAfterSelect():Void {
		var skin1 = new Shape();
		var skin2 = new Shape();
		Assert.isNull(skin1.parent);
		Assert.isNull(skin2.parent);
		this._button.backgroundSkin = skin1;
		this._button.selectedBackgroundSkin = skin2;
		this._button.validateNow();
		Assert.areEqual(this._button, skin1.parent);
		Assert.isNull(skin2.parent);
		this._button.selected = true;
		this._button.validateNow();
		Assert.isNull(skin1.parent);
		Assert.areEqual(this._button, skin2.parent);
	}

	@Test
	public function testRemoveSkinAfterChangeState():Void {
		var skin1 = new Shape();
		var skin2 = new Shape();
		Assert.isNull(skin1.parent);
		Assert.isNull(skin2.parent);
		this._button.backgroundSkin = skin1;
		this._button.setSkinForState(ToggleButtonState.DOWN(false), skin2);
		this._button.validateNow();
		Assert.areEqual(this._button, skin1.parent);
		Assert.isNull(skin2.parent);
		this._button.changeState(ToggleButtonState.DOWN(false));
		this._button.validateNow();
		Assert.isNull(skin1.parent);
		Assert.areEqual(this._button, skin2.parent);
	}
}

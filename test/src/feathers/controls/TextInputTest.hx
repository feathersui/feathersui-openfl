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
@:access(feathers.controls.TextInput)
class TextInputTest {
	private var _input:TextInput;

	@Before
	public function prepare():Void {
		this._input = new TextInput();
		TestMain.openfl_root.addChild(this._input);
	}

	@After
	public function cleanup():Void {
		if (this._input.parent != null) {
			this._input.parent.removeChild(this._input);
		}
		this._input = null;
		Assert.areEqual(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
	}

	@Test
	public function testRemoveSkinAfterSetToNewValue():Void {
		var skin1 = new Shape();
		var skin2 = new Shape();
		Assert.isNull(skin1.parent);
		Assert.isNull(skin2.parent);
		this._input.backgroundSkin = skin1;
		this._input.validateNow();
		Assert.areEqual(this._input, skin1.parent);
		Assert.isNull(skin2.parent);
		this._input.backgroundSkin = skin2;
		this._input.validateNow();
		Assert.isNull(skin1.parent);
		Assert.areEqual(this._input, skin2.parent);
	}

	@Test
	public function testRemoveSkinAfterSetToNull():Void {
		var skin = new Shape();
		Assert.isNull(skin.parent);
		this._input.backgroundSkin = skin;
		this._input.validateNow();
		Assert.areEqual(this._input, skin.parent);
		this._input.backgroundSkin = null;
		this._input.validateNow();
		Assert.isNull(skin.parent);
	}

	@Test
	public function testRemoveSkinAfterDisable():Void {
		var skin1 = new Shape();
		var skin2 = new Shape();
		Assert.isNull(skin1.parent);
		Assert.isNull(skin2.parent);
		this._input.backgroundSkin = skin1;
		this._input.setSkinForState(TextInputState.DISABLED, skin2);
		this._input.validateNow();
		Assert.areEqual(this._input, skin1.parent);
		Assert.isNull(skin2.parent);
		this._input.enabled = false;
		this._input.validateNow();
		Assert.isNull(skin1.parent);
		Assert.areEqual(this._input, skin2.parent);
	}

	@Test
	public function testRemoveSkinAfterChangeState():Void {
		var skin1 = new Shape();
		var skin2 = new Shape();
		Assert.isNull(skin1.parent);
		Assert.isNull(skin2.parent);
		this._input.backgroundSkin = skin1;
		this._input.setSkinForState(TextInputState.ERROR, skin2);
		this._input.validateNow();
		Assert.areEqual(this._input, skin1.parent);
		Assert.isNull(skin2.parent);
		this._input.changeState(ERROR);
		this._input.validateNow();
		Assert.isNull(skin1.parent);
		Assert.areEqual(this._input, skin2.parent);
	}
}

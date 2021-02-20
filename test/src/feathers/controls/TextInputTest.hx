/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import openfl.display.Shape;
import utest.Assert;
import utest.Test;

@:keep
@:access(feathers.controls.TextInput)
class TextInputTest extends Test {
	private var _input:TextInput;

	public function new() {
		super();
	}

	public function setup():Void {
		this._input = new TextInput();
		TestMain.openfl_root.addChild(this._input);
	}

	public function teardown():Void {
		if (this._input.parent != null) {
			this._input.parent.removeChild(this._input);
		}
		this._input = null;
		Assert.equals(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testRemoveSkinAfterSetToNewValue():Void {
		var skin1 = new Shape();
		var skin2 = new Shape();
		Assert.isNull(skin1.parent);
		Assert.isNull(skin2.parent);
		this._input.backgroundSkin = skin1;
		this._input.validateNow();
		Assert.equals(this._input, skin1.parent);
		Assert.isNull(skin2.parent);
		this._input.backgroundSkin = skin2;
		this._input.validateNow();
		Assert.isNull(skin1.parent);
		Assert.equals(this._input, skin2.parent);
	}

	public function testRemoveSkinAfterSetToNull():Void {
		var skin = new Shape();
		Assert.isNull(skin.parent);
		this._input.backgroundSkin = skin;
		this._input.validateNow();
		Assert.equals(this._input, skin.parent);
		this._input.backgroundSkin = null;
		this._input.validateNow();
		Assert.isNull(skin.parent);
	}

	public function testRemoveSkinAfterDisable():Void {
		var skin1 = new Shape();
		var skin2 = new Shape();
		Assert.isNull(skin1.parent);
		Assert.isNull(skin2.parent);
		this._input.backgroundSkin = skin1;
		this._input.setSkinForState(TextInputState.DISABLED, skin2);
		this._input.validateNow();
		Assert.equals(this._input, skin1.parent);
		Assert.isNull(skin2.parent);
		this._input.enabled = false;
		this._input.validateNow();
		Assert.isNull(skin1.parent);
		Assert.equals(this._input, skin2.parent);
	}

	public function testRemoveSkinAfterChangeState():Void {
		var skin1 = new Shape();
		var skin2 = new Shape();
		Assert.isNull(skin1.parent);
		Assert.isNull(skin2.parent);
		this._input.backgroundSkin = skin1;
		this._input.setSkinForState(TextInputState.ERROR, skin2);
		this._input.validateNow();
		Assert.equals(this._input, skin1.parent);
		Assert.isNull(skin2.parent);
		this._input.changeState(ERROR);
		this._input.validateNow();
		Assert.isNull(skin1.parent);
		Assert.equals(this._input, skin2.parent);
	}
}

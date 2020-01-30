/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import massive.munit.Assert;
import openfl.display.Shape;

@:keep
class LabelTest {
	private var _label:Label;

	@Before
	public function prepare():Void {
		this._label = new Label();
		TestMain.openfl_root.addChild(this._label);
	}

	@After
	public function cleanup():Void {
		if (this._label.parent != null) {
			this._label.parent.removeChild(this._label);
		}
		this._label = null;
		Assert.areEqual(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
	}

	@Test
	public function testRemoveSkinAfterSetToNewValue():Void {
		var skin1 = new Shape();
		var skin2 = new Shape();
		Assert.isNull(skin1.parent);
		Assert.isNull(skin2.parent);
		this._label.backgroundSkin = skin1;
		this._label.validateNow();
		Assert.areEqual(this._label, skin1.parent);
		Assert.isNull(skin2.parent);
		this._label.backgroundSkin = skin2;
		this._label.validateNow();
		Assert.isNull(skin1.parent);
		Assert.areEqual(this._label, skin2.parent);
	}

	@Test
	public function testRemoveSkinAfterSetToNull():Void {
		var skin = new Shape();
		Assert.isNull(skin.parent);
		this._label.backgroundSkin = skin;
		this._label.validateNow();
		Assert.areEqual(this._label, skin.parent);
		this._label.backgroundSkin = null;
		this._label.validateNow();
		Assert.isNull(skin.parent);
	}

	@Test
	public function testRemoveSkinAfterDisable():Void {
		var skin1 = new Shape();
		var skin2 = new Shape();
		Assert.isNull(skin1.parent);
		Assert.isNull(skin2.parent);
		this._label.backgroundSkin = skin1;
		this._label.disabledBackgroundSkin = skin2;
		this._label.validateNow();
		Assert.areEqual(this._label, skin1.parent);
		Assert.isNull(skin2.parent);
		this._label.enabled = false;
		this._label.validateNow();
		Assert.isNull(skin1.parent);
		Assert.areEqual(this._label, skin2.parent);
	}
}

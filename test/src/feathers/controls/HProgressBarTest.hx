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
class HProgressBarTest {
	private var _progress:HProgressBar;

	@Before
	public function prepare():Void {
		this._progress = new HProgressBar();
		TestMain.openfl_root.addChild(this._progress);
	}

	@After
	public function cleanup():Void {
		if (this._progress.parent != null) {
			this._progress.parent.removeChild(this._progress);
		}
		this._progress = null;
		Assert.areEqual(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
	}

	@Test
	public function testRemoveBackgroundSkinAfterSetToNewValue():Void {
		var skin1 = new Shape();
		var skin2 = new Shape();
		Assert.isNull(skin1.parent);
		Assert.isNull(skin2.parent);
		this._progress.backgroundSkin = skin1;
		this._progress.validateNow();
		Assert.areEqual(this._progress, skin1.parent);
		Assert.isNull(skin2.parent);
		this._progress.backgroundSkin = skin2;
		this._progress.validateNow();
		Assert.isNull(skin1.parent);
		Assert.areEqual(this._progress, skin2.parent);
	}

	@Test
	public function testRemoveBackgroundSkinAfterSetToNull():Void {
		var skin = new Shape();
		Assert.isNull(skin.parent);
		this._progress.backgroundSkin = skin;
		this._progress.validateNow();
		Assert.areEqual(this._progress, skin.parent);
		this._progress.backgroundSkin = null;
		this._progress.validateNow();
		Assert.isNull(skin.parent);
	}

	@Test
	public function testRemoveBackgroundSkinAfterDisable():Void {
		var skin1 = new Shape();
		var skin2 = new Shape();
		Assert.isNull(skin1.parent);
		Assert.isNull(skin2.parent);
		this._progress.backgroundSkin = skin1;
		this._progress.disabledBackgroundSkin = skin2;
		this._progress.validateNow();
		Assert.areEqual(this._progress, skin1.parent);
		Assert.isNull(skin2.parent);
		this._progress.enabled = false;
		this._progress.validateNow();
		Assert.isNull(skin1.parent);
		Assert.areEqual(this._progress, skin2.parent);
	}

	@Test
	public function testRemoveFillSkinAfterSetToNewValue():Void {
		var skin1 = new Shape();
		var skin2 = new Shape();
		Assert.isNull(skin1.parent);
		Assert.isNull(skin2.parent);
		this._progress.fillSkin = skin1;
		this._progress.validateNow();
		Assert.areEqual(this._progress, skin1.parent);
		Assert.isNull(skin2.parent);
		this._progress.fillSkin = skin2;
		this._progress.validateNow();
		Assert.isNull(skin1.parent);
		Assert.areEqual(this._progress, skin2.parent);
	}

	@Test
	public function testRemoveFillSkinAfterSetToNull():Void {
		var skin = new Shape();
		Assert.isNull(skin.parent);
		this._progress.fillSkin = skin;
		this._progress.validateNow();
		Assert.areEqual(this._progress, skin.parent);
		this._progress.fillSkin = null;
		this._progress.validateNow();
		Assert.isNull(skin.parent);
	}

	@Test
	public function testRemoveFillSkinAfterDisable():Void {
		var skin1 = new Shape();
		var skin2 = new Shape();
		Assert.isNull(skin1.parent);
		Assert.isNull(skin2.parent);
		this._progress.fillSkin = skin1;
		this._progress.disabledFillSkin = skin2;
		this._progress.validateNow();
		Assert.areEqual(this._progress, skin1.parent);
		Assert.isNull(skin2.parent);
		this._progress.enabled = false;
		this._progress.validateNow();
		Assert.isNull(skin1.parent);
		Assert.areEqual(this._progress, skin2.parent);
	}
}

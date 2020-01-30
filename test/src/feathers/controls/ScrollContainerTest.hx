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
class ScrollContainerTest {
	private var _container:ScrollContainer;

	@Before
	public function prepare():Void {
		this._container = new ScrollContainer();
		TestMain.openfl_root.addChild(this._container);
	}

	@After
	public function cleanup():Void {
		if (this._container.parent != null) {
			this._container.parent.removeChild(this._container);
		}
		this._container = null;
		Assert.areEqual(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
	}

	@Test
	public function testRemoveSkinAfterSetToNewValue():Void {
		var skin1 = new Shape();
		var skin2 = new Shape();
		Assert.isNull(skin1.parent);
		Assert.isNull(skin2.parent);
		this._container.backgroundSkin = skin1;
		this._container.validateNow();
		Assert.areEqual(this._container, skin1.parent);
		Assert.isNull(skin2.parent);
		this._container.backgroundSkin = skin2;
		this._container.validateNow();
		Assert.isNull(skin1.parent);
		Assert.areEqual(this._container, skin2.parent);
	}

	@Test
	public function testRemoveSkinAfterSetToNull():Void {
		var skin = new Shape();
		Assert.isNull(skin.parent);
		this._container.backgroundSkin = skin;
		this._container.validateNow();
		Assert.areEqual(this._container, skin.parent);
		this._container.backgroundSkin = null;
		this._container.validateNow();
		Assert.isNull(skin.parent);
	}

	@Test
	public function testRemoveSkinAfterDisable():Void {
		var skin1 = new Shape();
		var skin2 = new Shape();
		Assert.isNull(skin1.parent);
		Assert.isNull(skin2.parent);
		this._container.backgroundSkin = skin1;
		this._container.disabledBackgroundSkin = skin2;
		this._container.validateNow();
		Assert.areEqual(this._container, skin1.parent);
		Assert.isNull(skin2.parent);
		this._container.enabled = false;
		this._container.validateNow();
		Assert.isNull(skin1.parent);
		Assert.areEqual(this._container, skin2.parent);
	}
}

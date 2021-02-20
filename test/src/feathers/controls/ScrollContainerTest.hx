/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import utest.Assert;
import utest.Test;
import openfl.display.Shape;

@:keep
class ScrollContainerTest extends Test {
	private var _container:ScrollContainer;

	public function new() {
		super();
	}

	public function setup():Void {
		this._container = new ScrollContainer();
		TestMain.openfl_root.addChild(this._container);
	}

	public function teardown():Void {
		if (this._container.parent != null) {
			this._container.parent.removeChild(this._container);
		}
		this._container = null;
		Assert.equals(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testRemoveSkinAfterSetToNewValue():Void {
		var skin1 = new Shape();
		var skin2 = new Shape();
		Assert.isNull(skin1.parent);
		Assert.isNull(skin2.parent);
		this._container.backgroundSkin = skin1;
		this._container.validateNow();
		Assert.equals(this._container, skin1.parent);
		Assert.isNull(skin2.parent);
		this._container.backgroundSkin = skin2;
		this._container.validateNow();
		Assert.isNull(skin1.parent);
		Assert.equals(this._container, skin2.parent);
	}

	public function testRemoveSkinAfterSetToNull():Void {
		var skin = new Shape();
		Assert.isNull(skin.parent);
		this._container.backgroundSkin = skin;
		this._container.validateNow();
		Assert.equals(this._container, skin.parent);
		this._container.backgroundSkin = null;
		this._container.validateNow();
		Assert.isNull(skin.parent);
	}

	public function testRemoveSkinAfterDisable():Void {
		var skin1 = new Shape();
		var skin2 = new Shape();
		Assert.isNull(skin1.parent);
		Assert.isNull(skin2.parent);
		this._container.backgroundSkin = skin1;
		this._container.disabledBackgroundSkin = skin2;
		this._container.validateNow();
		Assert.equals(this._container, skin1.parent);
		Assert.isNull(skin2.parent);
		this._container.enabled = false;
		this._container.validateNow();
		Assert.isNull(skin1.parent);
		Assert.equals(this._container, skin2.parent);
	}
}

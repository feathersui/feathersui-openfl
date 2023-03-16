/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.dataRenderers;

import openfl.Lib;
import openfl.display.Shape;
import utest.Assert;
import utest.Test;

@:keep
class ItemRendererTest extends Test {
	private var _itemRenderer:ItemRenderer;

	public function new() {
		super();
	}

	public function setup():Void {
		this._itemRenderer = new ItemRenderer();
		Lib.current.addChild(this._itemRenderer);
	}

	public function teardown():Void {
		if (this._itemRenderer.parent != null) {
			this._itemRenderer.parent.removeChild(this._itemRenderer);
		}
		this._itemRenderer = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testRemoveAccessoryAfterSetToNewValue():Void {
		var accessory1 = new Shape();
		var accessory2 = new Shape();
		Assert.isNull(accessory1.parent);
		Assert.isNull(accessory2.parent);
		this._itemRenderer.accessoryView = accessory1;
		this._itemRenderer.validateNow();
		Assert.equals(this._itemRenderer, accessory1.parent);
		Assert.isNull(accessory2.parent);
		this._itemRenderer.accessoryView = accessory2;
		this._itemRenderer.validateNow();
		Assert.isNull(accessory1.parent);
		Assert.equals(this._itemRenderer, accessory2.parent);
	}

	public function testRemoveAccessoryAfterSetToNull():Void {
		var accessory = new Shape();
		Assert.isNull(accessory.parent);
		this._itemRenderer.accessoryView = accessory;
		this._itemRenderer.validateNow();
		Assert.equals(this._itemRenderer, accessory.parent);
		this._itemRenderer.accessoryView = null;
		this._itemRenderer.validateNow();
		Assert.isNull(accessory.parent);
	}

	public function testResizeAfterAccessoryResize():Void {
		var accessory = new LayoutGroup();
		accessory.width = 100.0;
		accessory.height = 100.0;
		this._itemRenderer.accessoryView = accessory;
		this._itemRenderer.validateNow();
		var originalWidth = this._itemRenderer.width;
		var originalHeight = this._itemRenderer.height;
		accessory.width = 200.0;
		accessory.height = 150.0;
		this._itemRenderer.validateNow();
		Assert.notEquals(originalWidth, this._itemRenderer.width);
		Assert.notEquals(originalHeight, this._itemRenderer.height);
	}
}

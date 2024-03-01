/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.dataRenderers;

import openfl.Lib;
import openfl.display.Shape;
import utest.Assert;
import utest.Test;

@:keep
class HierarchicalItemRendererTest extends Test {
	private var _itemRenderer:HierarchicalItemRenderer;

	public function new() {
		super();
	}

	public function setup():Void {
		this._itemRenderer = new HierarchicalItemRenderer();
		Lib.current.addChild(this._itemRenderer);
	}

	public function teardown():Void {
		if (this._itemRenderer.parent != null) {
			this._itemRenderer.parent.removeChild(this._itemRenderer);
		}
		this._itemRenderer = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testValidateWithNoData():Void {
		this._itemRenderer.validateNow();
		Assert.pass();
	}

	public function testNoExceptionOnDoubleDispose():Void {
		this._itemRenderer.validateNow();
		this._itemRenderer.dispose();
		this._itemRenderer.dispose();
		Assert.pass();
	}
}

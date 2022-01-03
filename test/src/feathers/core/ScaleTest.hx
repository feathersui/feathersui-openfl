/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import openfl.display.Shape;
import feathers.controls.LayoutGroup;
import utest.Assert;
import utest.Test;

@:keep
class ScaleTest extends Test {
	private static final BASE_WIDTH = 100.0;
	private static final BASE_HEIGHT = 140.0;
	private static final LARGER_WIDTH = 280.0;
	private static final LARGER_HEIGHT = 300.0;
	private static final LARGER_MIN_WIDTH = 270.0;
	private static final LARGER_MIN_HEIGHT = 290.0;
	private static final LARGER_SCALEX = 2.0;
	private static final SMALLER_SCALEY = 0.25;
	private static final SMALLER_SCALE = 0.5;

	private var _control:LayoutGroup;

	public function new() {
		super();
	}

	public function setup():Void {
		var child = new Shape();
		child.graphics.beginFill(0xff00ff);
		child.graphics.drawRect(0, 0, BASE_WIDTH, BASE_HEIGHT);
		child.graphics.endFill();

		this._control = new LayoutGroup();
		this._control.addChild(child);
		TestMain.openfl_root.addChild(this._control);
	}

	public function teardown():Void {
		if (this._control.parent != null) {
			this._control.parent.removeChild(this._control);
		}
		this._control = null;
		Assert.equals(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testInitialDimensions():Void {
		this._control.validateNow();
		Assert.equals(BASE_WIDTH, this._control.width, "Component initial width incorrect.");
		Assert.equals(BASE_HEIGHT, this._control.height, "Component initial height incorrect.");
		Assert.equals(BASE_WIDTH, this._control.minWidth, "Component initial minWidth incorrect.");
		Assert.equals(BASE_HEIGHT, this._control.minHeight, "Component initial minHeight incorrect.");
		Assert.equals(Math.POSITIVE_INFINITY, this._control.maxWidth, "Component initial maxWidth incorrect.");
		Assert.equals(Math.POSITIVE_INFINITY, this._control.maxHeight, "Component initial maxHeight incorrect.");
	}

	public function testSetScaleXAndScaleY():Void {
		this._control.scaleX = LARGER_SCALEX;
		this._control.scaleY = SMALLER_SCALEY;
		this._control.validateNow();
		Assert.equals(BASE_WIDTH * LARGER_SCALEX, this._control.width, "Component calculated width incorrect after setting scaleX.");
		Assert.equals(BASE_HEIGHT * SMALLER_SCALEY, this._control.height, "Component calculated height incorrect after setting scaleY.");
		Assert.equals(BASE_WIDTH * LARGER_SCALEX, this._control.minWidth, "Component calculated minWidth incorrect after setting scaleX.");
		Assert.equals(BASE_HEIGHT * SMALLER_SCALEY, this._control.minHeight, "Component calculated minHeight incorrect after setting scaleY.");
	}

	public function testSetScaleXAndScaleYThenWidthAndHeight():Void {
		this._control.scaleX = LARGER_SCALEX;
		this._control.scaleY = SMALLER_SCALEY;
		this._control.width = LARGER_WIDTH;
		this._control.height = LARGER_HEIGHT;
		this._control.minWidth = LARGER_MIN_WIDTH;
		this._control.minHeight = LARGER_MIN_HEIGHT;
		this._control.validateNow();
		Assert.equals(LARGER_WIDTH, this._control.width, "Component width incorrect after setting scaleX then width.");
		Assert.equals(LARGER_HEIGHT, this._control.height, "Component height incorrect after setting scaleY then height.");
		Assert.equals(LARGER_MIN_WIDTH, this._control.minWidth, "Component minWidth incorrect after setting scaleX then minWidth.");
		Assert.equals(LARGER_MIN_HEIGHT, this._control.minHeight, "Component minHeight incorrect after setting scaleY then minHeight.");
	}

	public function testSetWidthAndHeightThenScaleXAndScaleY():Void {
		this._control.width = LARGER_WIDTH;
		this._control.height = LARGER_HEIGHT;
		this._control.minWidth = LARGER_MIN_WIDTH;
		this._control.minHeight = LARGER_MIN_HEIGHT;
		this._control.scaleX = LARGER_SCALEX;
		this._control.scaleY = SMALLER_SCALEY;
		this._control.validateNow();
		Assert.equals(LARGER_WIDTH * LARGER_SCALEX, this._control.width, "Component width incorrect after setting width then scaleX.");
		Assert.equals(LARGER_HEIGHT * SMALLER_SCALEY, this._control.height, "Component height incorrect after setting height then scaleY.");
		Assert.equals(LARGER_MIN_WIDTH * LARGER_SCALEX, this._control.minWidth, "Component minWidth incorrect after setting minWidth then scaleX.");
		Assert.equals(LARGER_MIN_HEIGHT * SMALLER_SCALEY, this._control.minHeight, "Component minHeight incorrect after setting minHeight then scaleY.");
	}

	public function testSetWidthAndHeightThenScaleXAndScaleYThenWidthAndHeightBackToOriginal():Void {
		this._control.width = LARGER_WIDTH;
		this._control.height = LARGER_HEIGHT;
		this._control.minWidth = LARGER_MIN_WIDTH;
		this._control.minHeight = LARGER_MIN_HEIGHT;
		this._control.scaleX = LARGER_SCALEX;
		this._control.scaleY = SMALLER_SCALEY;
		this._control.width = LARGER_WIDTH;
		this._control.height = LARGER_HEIGHT;
		this._control.minWidth = LARGER_MIN_WIDTH;
		this._control.minHeight = LARGER_MIN_HEIGHT;
		this._control.validateNow();
		Assert.equals(LARGER_WIDTH, this._control.width, "Component width incorrect after setting width then scaleX then width back to original.");
		Assert.equals(LARGER_HEIGHT, this._control.height, "Component height incorrect after setting height then scaleY then height back to original.");
		Assert.equals(LARGER_MIN_WIDTH, this._control.minWidth,
			"Component minWidth incorrect after setting minWidth then scaleX then minWidth back to original.");
		Assert.equals(LARGER_MIN_HEIGHT, this._control.minHeight,
			"Component minHeight incorrect after setting minHeight then scaleY then minHeight back to original.");
	}
}

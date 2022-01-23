/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import feathers.controls.LayoutGroup;
import feathers.layout.Measurements;
import openfl.Lib;
import openfl.display.Shape;
import utest.Assert;
import utest.Test;

@:keep
class VerticalListFixedRowLayoutTest extends Test {
	private static final PADDING_TOP = 6.0;
	private static final PADDING_RIGHT = 8.0;
	private static final PADDING_BOTTOM = 2.0;
	private static final PADDING_LEFT = 10.0;
	private static final GAP = 5.0;
	private static final CHILD1_WIDTH = 200.0;
	private static final CHILD1_HEIGHT = 100.0;
	private static final CHILD2_WIDTH = 150.0;
	private static final CHILD2_HEIGHT = 75.0;
	private static final CHILD3_WIDTH = 75.0;
	private static final CHILD3_HEIGHT = 50.0;
	private static final CHILD4_WIDTH = 10.0;
	private static final CHILD4_HEIGHT = 20.0;

	private var _measurements:Measurements;
	private var _layout:VerticalListLayout;
	private var _child1:Shape;
	private var _child2:Shape;
	private var _control1:LayoutGroup;
	private var _control2:LayoutGroup;

	public function new() {
		super();
	}

	public function setup():Void {
		this._layout = new VerticalListLayout();
		this._measurements = new Measurements();

		this._child1 = new Shape();
		this._child1.graphics.beginFill();
		this._child1.graphics.drawRect(0, 0, CHILD1_WIDTH, CHILD1_HEIGHT);
		this._child1.graphics.endFill();

		this._child2 = new Shape();
		this._child2.graphics.beginFill();
		this._child2.graphics.drawRect(0, 0, CHILD2_WIDTH, CHILD2_HEIGHT);
		this._child2.graphics.endFill();

		this._control1 = new LayoutGroup();

		this._control2 = new LayoutGroup();
	}

	public function teardown():Void {
		this._measurements = null;
		this._layout = null;
		this._child1 = null;
		this._child1 = null;
		this._control1 = null;
		this._control2 = null;
	}

	public function testExplicitViewPortWidthLargerThanItemWidth():Void {
		var explicitWidth = CHILD1_WIDTH / 2.0;
		this._measurements.width = explicitWidth;
		var result = this._layout.layout([this._child1], this._measurements);
		Assert.equals(explicitWidth, result.viewPortWidth);
		Assert.equals(explicitWidth, result.contentWidth);
	}

	public function testExplicitViewPortMaxWidthLargerThanItemWidth():Void {
		var maxWidth = CHILD1_WIDTH / 2.0;
		this._measurements.maxWidth = maxWidth;
		var result = this._layout.layout([this._child1], this._measurements);
		Assert.equals(maxWidth, result.viewPortWidth);
		Assert.equals(maxWidth, result.contentWidth);
	}
}

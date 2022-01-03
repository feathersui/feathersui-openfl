/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import feathers.controls.LayoutGroup;
import openfl.display.Shape;
import feathers.layout.Measurements;
import utest.Assert;
import utest.Test;

@:keep
class AnchorLayoutTest extends Test {
	private static final PADDING_TOP = 6.0;
	private static final PADDING_RIGHT = 8.0;
	private static final PADDING_BOTTOM = 2.0;
	private static final PADDING_LEFT = 10.0;
	private static final GAP = 5.0;
	private static final CHILD1_X = 15.0;
	private static final CHILD1_Y = 18.0;
	private static final CHILD1_WIDTH = 200.0;
	private static final CHILD1_HEIGHT = 100.0;
	private static final CHILD2_X = 120.0;
	private static final CHILD2_Y = 15.0;
	private static final CHILD2_WIDTH = 150.0;
	private static final CHILD2_HEIGHT = 75.0;

	private var _measurements:Measurements;
	private var _layout:AnchorLayout;
	private var _child1:Shape;
	private var _child2:Shape;

	public function new() {
		super();
	}

	public function setup():Void {
		this._layout = new AnchorLayout();
		this._measurements = new Measurements();

		this._child1 = new Shape();
		this._child1.graphics.beginFill();
		this._child1.graphics.drawRect(0, 0, CHILD1_WIDTH, CHILD1_HEIGHT);
		this._child1.graphics.endFill();

		this._child2 = new Shape();
		this._child2.graphics.beginFill();
		this._child2.graphics.drawRect(0, 0, CHILD2_WIDTH, CHILD2_HEIGHT);
		this._child2.graphics.endFill();
	}

	public function teardown():Void {
		this._measurements = null;
		this._layout = null;
		this._child1 = null;
		this._child1 = null;
	}

	public function testZeroItemsWithNullMeasurements():Void {
		var result = this._layout.layout([], this._measurements);
		Assert.equals(0.0, result.viewPortWidth);
		Assert.equals(0.0, result.viewPortHeight);
		Assert.equals(0.0, result.contentWidth);
		Assert.equals(0.0, result.contentHeight);
		Assert.equals(0.0, result.contentX);
		Assert.equals(0.0, result.contentY);
	}

	public function testOneItemWithNullMeasurements():Void {
		var result = this._layout.layout([this._child1], this._measurements);
		Assert.equals(CHILD1_WIDTH, result.viewPortWidth);
		Assert.equals(CHILD1_HEIGHT, result.viewPortHeight);
		Assert.equals(CHILD1_WIDTH, result.contentWidth);
		Assert.equals(CHILD1_HEIGHT, result.contentHeight);
		Assert.equals(0.0, result.contentX);
		Assert.equals(0.0, result.contentY);
	}

	public function testOneItemWithXYAndNullMeasurements():Void {
		this._child1.x = CHILD1_X;
		this._child1.y = CHILD1_Y;
		var result = this._layout.layout([this._child1], this._measurements);
		Assert.equals(CHILD1_X + CHILD1_WIDTH, result.viewPortWidth);
		Assert.equals(CHILD1_Y + CHILD1_HEIGHT, result.viewPortHeight);
		Assert.equals(CHILD1_X + CHILD1_WIDTH, result.contentWidth);
		Assert.equals(CHILD1_Y + CHILD1_HEIGHT, result.contentHeight);
		Assert.equals(0.0, result.contentX);
		Assert.equals(0.0, result.contentY);
	}

	public function testTwoItemsWithNullMeasurements():Void {
		var result = this._layout.layout([this._child1, this._child2], this._measurements);
		Assert.equals(Math.max(CHILD1_WIDTH, CHILD2_WIDTH), result.viewPortWidth);
		Assert.equals(Math.max(CHILD1_HEIGHT, CHILD2_HEIGHT), result.viewPortHeight);
		Assert.equals(Math.max(CHILD1_WIDTH, CHILD2_WIDTH), result.contentWidth);
		Assert.equals(Math.max(CHILD1_HEIGHT, CHILD2_HEIGHT), result.contentHeight);
		Assert.equals(0.0, result.contentX);
		Assert.equals(0.0, result.contentY);
	}

	public function testTwoItemsWithXYAndNullMeasurements():Void {
		this._child1.x = CHILD1_X;
		this._child1.y = CHILD1_Y;
		this._child2.x = CHILD2_X;
		this._child2.y = CHILD2_Y;
		var result = this._layout.layout([this._child1, this._child2], this._measurements);
		Assert.equals(Math.max(CHILD1_X + CHILD1_WIDTH, CHILD2_X + CHILD2_WIDTH), result.viewPortWidth);
		Assert.equals(Math.max(CHILD1_Y + CHILD1_HEIGHT, CHILD2_Y + CHILD2_HEIGHT), result.viewPortHeight);
		Assert.equals(Math.max(CHILD1_X + CHILD1_WIDTH, CHILD2_X + CHILD2_WIDTH), result.contentWidth);
		Assert.equals(Math.max(CHILD1_Y + CHILD1_HEIGHT, CHILD2_Y + CHILD2_HEIGHT), result.contentHeight);
		Assert.equals(0.0, result.contentX);
		Assert.equals(0.0, result.contentY);
	}

	public function testLeftAndNullMeasurements():Void {
		var item1 = new LayoutGroup();
		item1.width = CHILD1_WIDTH;
		var layoutData1 = new AnchorLayoutData();
		layoutData1.left = PADDING_LEFT;
		item1.layoutData = layoutData1;
		var result = this._layout.layout([item1], this._measurements);
		Assert.equals(CHILD1_WIDTH + PADDING_LEFT, result.viewPortWidth);
		Assert.equals(CHILD1_WIDTH + PADDING_LEFT, result.contentWidth);
	}

	public function testRightAndNullMeasurements():Void {
		var item1 = new LayoutGroup();
		item1.width = CHILD1_WIDTH;
		var layoutData1 = new AnchorLayoutData();
		layoutData1.right = PADDING_RIGHT;
		item1.layoutData = layoutData1;
		var result = this._layout.layout([item1], this._measurements);
		Assert.equals(CHILD1_WIDTH + PADDING_RIGHT, result.viewPortWidth);
		Assert.equals(CHILD1_WIDTH + PADDING_RIGHT, result.contentWidth);
	}

	public function testTopAndNullMeasurements():Void {
		var item1 = new LayoutGroup();
		item1.height = CHILD1_HEIGHT;
		var layoutData1 = new AnchorLayoutData();
		layoutData1.top = PADDING_TOP;
		item1.layoutData = layoutData1;
		var result = this._layout.layout([item1], this._measurements);
		Assert.equals(CHILD1_HEIGHT + PADDING_TOP, result.viewPortHeight);
		Assert.equals(CHILD1_HEIGHT + PADDING_TOP, result.contentHeight);
	}

	public function testBottomAndNullMeasurements():Void {
		var item1 = new LayoutGroup();
		item1.height = CHILD1_HEIGHT;
		var layoutData1 = new AnchorLayoutData();
		layoutData1.bottom = PADDING_BOTTOM;
		item1.layoutData = layoutData1;
		var result = this._layout.layout([item1], this._measurements);
		Assert.equals(CHILD1_HEIGHT + PADDING_BOTTOM, result.viewPortHeight);
		Assert.equals(CHILD1_HEIGHT + PADDING_BOTTOM, result.contentHeight);
	}

	public function testLeftAndRightAndNullMeasurements():Void {
		var item1 = new LayoutGroup();
		item1.width = CHILD1_WIDTH;
		var layoutData1 = new AnchorLayoutData();
		layoutData1.left = PADDING_LEFT;
		layoutData1.right = PADDING_RIGHT;
		item1.layoutData = layoutData1;
		var result = this._layout.layout([item1], this._measurements);
		Assert.equals(CHILD1_WIDTH + PADDING_LEFT + PADDING_RIGHT, result.viewPortWidth);
		Assert.equals(CHILD1_WIDTH + PADDING_LEFT + PADDING_RIGHT, result.contentWidth);
	}

	public function testTopAndBottomAndNullMeasurements():Void {
		var item1 = new LayoutGroup();
		item1.height = CHILD1_HEIGHT;
		var layoutData1 = new AnchorLayoutData();
		layoutData1.top = PADDING_TOP;
		layoutData1.bottom = PADDING_BOTTOM;
		item1.layoutData = layoutData1;
		var result = this._layout.layout([item1], this._measurements);
		Assert.equals(CHILD1_HEIGHT + PADDING_TOP + PADDING_BOTTOM, result.viewPortHeight);
		Assert.equals(CHILD1_HEIGHT + PADDING_TOP + PADDING_BOTTOM, result.contentHeight);
	}

	public function testXAndRightAndNullMeasurements():Void {
		var item1 = new LayoutGroup();
		// make sure that x is ignored if right is set
		item1.x = 2000.0;
		item1.width = CHILD1_WIDTH;
		var layoutData1 = new AnchorLayoutData();
		layoutData1.right = PADDING_RIGHT;
		item1.layoutData = layoutData1;
		var result = this._layout.layout([item1], this._measurements);
		Assert.equals(CHILD1_WIDTH + PADDING_RIGHT, result.viewPortWidth);
		Assert.equals(CHILD1_WIDTH + PADDING_RIGHT, result.contentWidth);
	}

	public function testYAndBottomAndNullMeasurements():Void {
		var item1 = new LayoutGroup();
		// make sure that y is ignored if bottom is set
		item1.y = 2000.0;
		item1.height = CHILD1_HEIGHT;
		var layoutData1 = new AnchorLayoutData();
		layoutData1.bottom = PADDING_BOTTOM;
		item1.layoutData = layoutData1;
		var result = this._layout.layout([item1], this._measurements);
		Assert.equals(CHILD1_HEIGHT + PADDING_BOTTOM, result.viewPortHeight);
		Assert.equals(CHILD1_HEIGHT + PADDING_BOTTOM, result.contentHeight);
	}
}

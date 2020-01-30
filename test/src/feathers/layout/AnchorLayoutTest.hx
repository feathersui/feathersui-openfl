/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import openfl.display.Shape;
import feathers.layout.Measurements;
import massive.munit.Assert;

@:keep
class AnchorLayoutTest {
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

	@Before
	public function prepare():Void {
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

	@After
	public function cleanup():Void {
		this._measurements = null;
		this._layout = null;
		this._child1 = null;
		this._child1 = null;
	}

	@Test
	public function testZeroItemsWithNullMeasurements():Void {
		var result = this._layout.layout([], this._measurements);
		Assert.areEqual(0.0, result.viewPortWidth);
		Assert.areEqual(0.0, result.viewPortHeight);
		Assert.areEqual(0.0, result.contentWidth);
		Assert.areEqual(0.0, result.contentHeight);
		Assert.areEqual(0.0, result.contentX);
		Assert.areEqual(0.0, result.contentY);
	}

	@Test
	public function testOneItemWithNullMeasurements():Void {
		var result = this._layout.layout([this._child1], this._measurements);
		Assert.areEqual(CHILD1_WIDTH, result.viewPortWidth);
		Assert.areEqual(CHILD1_HEIGHT, result.viewPortHeight);
		Assert.areEqual(CHILD1_WIDTH, result.contentWidth);
		Assert.areEqual(CHILD1_HEIGHT, result.contentHeight);
		Assert.areEqual(0.0, result.contentX);
		Assert.areEqual(0.0, result.contentY);
	}

	@Test
	public function testOneItemWithXYAndNullMeasurements():Void {
		this._child1.x = CHILD1_X;
		this._child1.y = CHILD1_Y;
		var result = this._layout.layout([this._child1], this._measurements);
		Assert.areEqual(CHILD1_X + CHILD1_WIDTH, result.viewPortWidth);
		Assert.areEqual(CHILD1_Y + CHILD1_HEIGHT, result.viewPortHeight);
		Assert.areEqual(CHILD1_X + CHILD1_WIDTH, result.contentWidth);
		Assert.areEqual(CHILD1_Y + CHILD1_HEIGHT, result.contentHeight);
		Assert.areEqual(0.0, result.contentX);
		Assert.areEqual(0.0, result.contentY);
	}

	@Test
	public function testTwoItemsWithNullMeasurements():Void {
		var result = this._layout.layout([this._child1, this._child2], this._measurements);
		Assert.areEqual(Math.max(CHILD1_WIDTH, CHILD2_WIDTH), result.viewPortWidth);
		Assert.areEqual(Math.max(CHILD1_HEIGHT, CHILD2_HEIGHT), result.viewPortHeight);
		Assert.areEqual(Math.max(CHILD1_WIDTH, CHILD2_WIDTH), result.contentWidth);
		Assert.areEqual(Math.max(CHILD1_HEIGHT, CHILD2_HEIGHT), result.contentHeight);
		Assert.areEqual(0.0, result.contentX);
		Assert.areEqual(0.0, result.contentY);
	}

	@Test
	public function testTwoItemsWithXYAndNullMeasurements():Void {
		this._child1.x = CHILD1_X;
		this._child1.y = CHILD1_Y;
		this._child2.x = CHILD2_X;
		this._child2.y = CHILD2_Y;
		var result = this._layout.layout([this._child1, this._child2], this._measurements);
		Assert.areEqual(Math.max(CHILD1_X + CHILD1_WIDTH, CHILD2_X + CHILD2_WIDTH), result.viewPortWidth);
		Assert.areEqual(Math.max(CHILD1_Y + CHILD1_HEIGHT, CHILD2_Y + CHILD2_HEIGHT), result.viewPortHeight);
		Assert.areEqual(Math.max(CHILD1_X + CHILD1_WIDTH, CHILD2_X + CHILD2_WIDTH), result.contentWidth);
		Assert.areEqual(Math.max(CHILD1_Y + CHILD1_HEIGHT, CHILD2_Y + CHILD2_HEIGHT), result.contentHeight);
		Assert.areEqual(0.0, result.contentX);
		Assert.areEqual(0.0, result.contentY);
	}
}

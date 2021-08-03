/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import feathers.controls.LayoutGroup;
import openfl.events.Event;
import openfl.display.Shape;
import feathers.layout.Measurements;
import utest.Assert;
import utest.Test;

@:keep
class PagedTiledRowsListLayoutTest extends Test {
	private static final PADDING_TOP = 6.0;
	private static final PADDING_RIGHT = 8.0;
	private static final PADDING_BOTTOM = 2.0;
	private static final PADDING_LEFT = 10.0;
	private static final HORIZONTAL_GAP = 5.0;
	private static final VERTICAL_GAP = 7.0;
	private static final CHILD1_WIDTH = 200.0;
	private static final CHILD1_HEIGHT = 100.0;
	private static final CHILD2_WIDTH = 150.0;
	private static final CHILD2_HEIGHT = 75.0;
	private static final CHILD3_WIDTH = 75.0;
	private static final CHILD3_HEIGHT = 50.0;
	private static final CHILD4_WIDTH = 10.0;
	private static final CHILD4_HEIGHT = 20.0;

	private var _measurements:Measurements;
	private var _layout:PagedTiledRowsListLayout;
	private var _child1:Shape;
	private var _child2:Shape;
	private var _control1:LayoutGroup;
	private var _control2:LayoutGroup;

	public function new() {
		super();
	}

	public function setup():Void {
		this._layout = new PagedTiledRowsListLayout();
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

	public function testHorizontalRequestedRowCountWithZeroItems():Void {
		this._layout.pageDirection = HORIZONTAL;
		this._layout.requestedRowCount = 3;
		var result = this._layout.layout([], this._measurements);
		Assert.equals(0.0, result.viewPortWidth);
		Assert.equals(0.0, result.contentWidth);
		Assert.equals(0.0, result.viewPortHeight);
		Assert.equals(0.0, result.contentHeight);
	}

	public function testHorizontalRequestedRowCountWithFewerItems():Void {
		this._layout.pageDirection = HORIZONTAL;
		this._layout.requestedRowCount = 2;
		var result = this._layout.layout([this._child1], this._measurements);
		Assert.equals(CHILD1_WIDTH, result.viewPortWidth);
		Assert.equals(CHILD1_WIDTH, result.contentWidth);
		Assert.equals(2.0 * CHILD1_HEIGHT, result.viewPortHeight);
		Assert.equals(2.0 * CHILD1_HEIGHT, result.contentHeight);
	}

	public function testHorizontalRequestedRowCountWithMoreItems():Void {
		this._layout.pageDirection = HORIZONTAL;
		this._measurements.width = CHILD1_WIDTH;
		this._layout.requestedRowCount = 1;
		var result = this._layout.layout([this._child1, this._child2], this._measurements);
		Assert.equals(CHILD1_WIDTH, result.viewPortWidth);
		Assert.equals(2.0 * CHILD1_WIDTH, result.contentWidth);
		Assert.equals(CHILD1_HEIGHT, result.viewPortHeight);
		Assert.equals(CHILD1_HEIGHT, result.contentHeight);
	}

	public function testHorizontalRequestedMinRowCountWithZeroItems():Void {
		this._layout.pageDirection = HORIZONTAL;
		this._layout.requestedMinRowCount = 3;
		var result = this._layout.layout([], this._measurements);
		Assert.equals(0.0, result.viewPortWidth);
		Assert.equals(0.0, result.contentWidth);
		Assert.equals(0.0, result.viewPortHeight);
		Assert.equals(0.0, result.contentHeight);
	}

	public function testHorizontalRequestedMinRowCountWithFewerItems():Void {
		this._layout.pageDirection = HORIZONTAL;
		this._measurements.width = 100.0;
		this._layout.requestedMinRowCount = 3;
		this._control1.setSize(100.0, 60.0);
		this._control2.setSize(100.0, 60.0);
		var result = this._layout.layout([this._control1, this._control2], this._measurements);
		Assert.equals(100.0, result.viewPortWidth);
		Assert.equals(100.0, result.contentWidth);
		Assert.equals(180.0, result.viewPortHeight);
		Assert.equals(180.0, result.contentHeight);
	}

	public function testHorizontalRequestedMinRowCountWithMoreItems():Void {
		this._layout.pageDirection = HORIZONTAL;
		this._measurements.width = 100.0;
		this._layout.requestedMinRowCount = 1;
		this._control1.setSize(100.0, 60.0);
		this._control2.setSize(100.0, 60.0);
		var result = this._layout.layout([this._control1, this._control2], this._measurements);
		Assert.equals(100.0, result.viewPortWidth);
		Assert.equals(100.0, result.contentWidth);
		Assert.equals(120.0, result.viewPortHeight);
		Assert.equals(120.0, result.contentHeight);
	}

	public function testHorizontalRequestedMaxRowCountWithZeroItems():Void {
		this._layout.pageDirection = HORIZONTAL;
		this._layout.requestedMinRowCount = 3;
		var result = this._layout.layout([], this._measurements);
		Assert.equals(0.0, result.viewPortWidth);
		Assert.equals(0.0, result.contentWidth);
		Assert.equals(0.0, result.viewPortHeight);
		Assert.equals(0.0, result.contentHeight);
	}

	public function testHorizontalRequestedMaxRowCountWithFewerItems():Void {
		this._layout.pageDirection = HORIZONTAL;
		this._measurements.width = 100.0;
		this._layout.requestedMaxRowCount = 3;
		this._control1.setSize(100.0, 60.0);
		this._control2.setSize(100.0, 60.0);
		var result = this._layout.layout([this._control1, this._control2], this._measurements);
		Assert.equals(100.0, result.viewPortWidth);
		Assert.equals(100.0, result.contentWidth);
		Assert.equals(120.0, result.viewPortHeight);
		Assert.equals(120.0, result.contentHeight);
	}

	public function testHorizontalRequestedMaxRowCountWithMoreItems():Void {
		this._layout.pageDirection = HORIZONTAL;
		this._measurements.width = 100.0;
		this._layout.requestedMaxRowCount = 1;
		this._control1.setSize(100.0, 60.0);
		this._control2.setSize(100.0, 60.0);
		var result = this._layout.layout([this._control1, this._control2], this._measurements);
		Assert.equals(100.0, result.viewPortWidth);
		Assert.equals(200.0, result.contentWidth);
		Assert.equals(60.0, result.viewPortHeight);
		Assert.equals(60.0, result.contentHeight);
	}

	public function testHorizontalRequestedColumnCountWithZeroItems():Void {
		this._layout.pageDirection = HORIZONTAL;
		this._layout.requestedColumnCount = 3;
		var result = this._layout.layout([], this._measurements);
		Assert.equals(0.0, result.viewPortWidth);
		Assert.equals(0.0, result.contentWidth);
		Assert.equals(0.0, result.viewPortHeight);
		Assert.equals(0.0, result.contentHeight);
	}

	public function testHorizontalRequestedColumnCountWithFewerItems():Void {
		this._layout.pageDirection = HORIZONTAL;
		this._layout.requestedColumnCount = 3;
		this._control1.setSize(100.0, 60.0);
		this._control2.setSize(100.0, 60.0);
		var result = this._layout.layout([this._control1, this._control2], this._measurements);
		Assert.equals(300.0, result.viewPortWidth);
		Assert.equals(300.0, result.contentWidth);
		Assert.equals(60.0, result.viewPortHeight);
		Assert.equals(60.0, result.contentHeight);
	}

	public function testHorizontalRequestedColumnCountWithMoreItems():Void {
		this._layout.pageDirection = HORIZONTAL;
		this._layout.requestedColumnCount = 1;
		this._control1.setSize(100.0, 60.0);
		this._control2.setSize(100.0, 60.0);
		var result = this._layout.layout([this._control1, this._control2], this._measurements);
		Assert.equals(100.0, result.viewPortWidth);
		Assert.equals(100.0, result.contentWidth);
		Assert.equals(120.0, result.viewPortHeight);
		Assert.equals(120.0, result.contentHeight);
	}

	public function testHorizontalRequestedMinColumnCountWithZeroItems():Void {
		this._layout.pageDirection = HORIZONTAL;
		this._layout.requestedMinColumnCount = 3;
		var result = this._layout.layout([], this._measurements);
		Assert.equals(0.0, result.viewPortWidth);
		Assert.equals(0.0, result.contentWidth);
		Assert.equals(0.0, result.viewPortHeight);
		Assert.equals(0.0, result.contentHeight);
	}

	public function testHorizontalRequestedMinColumnCountWithFewerItems():Void {
		this._layout.pageDirection = HORIZONTAL;
		this._layout.requestedMinColumnCount = 3;
		this._control1.setSize(100.0, 60.0);
		this._control2.setSize(100.0, 60.0);
		var result = this._layout.layout([this._control1, this._control2], this._measurements);
		Assert.equals(300.0, result.viewPortWidth);
		Assert.equals(300.0, result.contentWidth);
		Assert.equals(60.0, result.viewPortHeight);
		Assert.equals(60.0, result.contentHeight);
	}

	public function testHorizontalRequestedMinColumnCountWithMoreItems():Void {
		this._layout.pageDirection = HORIZONTAL;
		this._layout.requestedMinColumnCount = 1;
		this._control1.setSize(100.0, 60.0);
		this._control2.setSize(100.0, 60.0);
		var result = this._layout.layout([this._control1, this._control2], this._measurements);
		Assert.equals(200.0, result.viewPortWidth);
		Assert.equals(200.0, result.contentWidth);
		Assert.equals(60.0, result.viewPortHeight);
		Assert.equals(60.0, result.contentHeight);
	}

	public function testHorizontalRequestedMaxColumnCountWithZeroItems():Void {
		this._layout.pageDirection = HORIZONTAL;
		this._layout.requestedMaxColumnCount = 3;
		var result = this._layout.layout([], this._measurements);
		Assert.equals(0.0, result.viewPortWidth);
		Assert.equals(0.0, result.contentWidth);
		Assert.equals(0.0, result.viewPortHeight);
		Assert.equals(0.0, result.contentHeight);
	}

	public function testHorizontalRequestedMaxColumnCountWithFewerItems():Void {
		this._layout.pageDirection = HORIZONTAL;
		this._layout.requestedMaxColumnCount = 3;
		this._control1.setSize(100.0, 60.0);
		this._control2.setSize(100.0, 60.0);
		var result = this._layout.layout([this._control1, this._control2], this._measurements);
		Assert.equals(200.0, result.viewPortWidth);
		Assert.equals(200.0, result.contentWidth);
		Assert.equals(60.0, result.viewPortHeight);
		Assert.equals(60.0, result.contentHeight);
	}

	public function testHorizontalRequestedMaxColumnCountWithMoreItems():Void {
		this._layout.pageDirection = HORIZONTAL;
		this._layout.requestedMaxColumnCount = 1;
		this._control1.setSize(100.0, 60.0);
		this._control2.setSize(100.0, 60.0);
		var result = this._layout.layout([this._control1, this._control2], this._measurements);
		Assert.equals(100.0, result.viewPortWidth);
		Assert.equals(100.0, result.contentWidth);
		Assert.equals(120.0, result.viewPortHeight);
		Assert.equals(120.0, result.contentHeight);
	}

	public function testVerticalRequestedRowCountWithZeroItems():Void {
		this._layout.pageDirection = VERTICAL;
		this._layout.requestedRowCount = 3;
		var result = this._layout.layout([], this._measurements);
		Assert.equals(0.0, result.viewPortWidth);
		Assert.equals(0.0, result.contentWidth);
		Assert.equals(0.0, result.viewPortHeight);
		Assert.equals(0.0, result.contentHeight);
	}

	public function testVerticalRequestedRowCountWithFewerItems():Void {
		this._layout.pageDirection = VERTICAL;
		this._layout.requestedRowCount = 2;
		var result = this._layout.layout([this._child1], this._measurements);
		Assert.equals(CHILD1_WIDTH, result.viewPortWidth);
		Assert.equals(CHILD1_WIDTH, result.contentWidth);
		Assert.equals(2.0 * CHILD1_HEIGHT, result.viewPortHeight);
		Assert.equals(2.0 * CHILD1_HEIGHT, result.contentHeight);
	}

	public function testVerticalRequestedRowCountWithMoreItems():Void {
		this._layout.pageDirection = VERTICAL;
		this._measurements.width = CHILD1_WIDTH;
		this._layout.requestedRowCount = 1;
		var result = this._layout.layout([this._child1, this._child2], this._measurements);
		Assert.equals(CHILD1_WIDTH, result.viewPortWidth);
		Assert.equals(CHILD1_WIDTH, result.contentWidth);
		Assert.equals(CHILD1_HEIGHT, result.viewPortHeight);
		Assert.equals(2.0 * CHILD1_HEIGHT, result.contentHeight);
	}

	public function testVerticalRequestedMinRowCountWithZeroItems():Void {
		this._layout.pageDirection = VERTICAL;
		this._layout.requestedMinRowCount = 3;
		var result = this._layout.layout([], this._measurements);
		Assert.equals(0.0, result.viewPortWidth);
		Assert.equals(0.0, result.contentWidth);
		Assert.equals(0.0, result.viewPortHeight);
		Assert.equals(0.0, result.contentHeight);
	}

	public function testVerticalRequestedMinRowCountWithFewerItems():Void {
		this._layout.pageDirection = VERTICAL;
		this._measurements.width = 100.0;
		this._layout.requestedMinRowCount = 3;
		this._control1.setSize(100.0, 60.0);
		this._control2.setSize(100.0, 60.0);
		var result = this._layout.layout([this._control1, this._control2], this._measurements);
		Assert.equals(100.0, result.viewPortWidth);
		Assert.equals(100.0, result.contentWidth);
		Assert.equals(180.0, result.viewPortHeight);
		Assert.equals(180.0, result.contentHeight);
	}

	public function testVerticalRequestedMinRowCountWithMoreItems():Void {
		this._layout.pageDirection = VERTICAL;
		this._measurements.width = 100.0;
		this._layout.requestedMinRowCount = 1;
		this._control1.setSize(100.0, 60.0);
		this._control2.setSize(100.0, 60.0);
		var result = this._layout.layout([this._control1, this._control2], this._measurements);
		Assert.equals(100.0, result.viewPortWidth);
		Assert.equals(100.0, result.contentWidth);
		Assert.equals(120.0, result.viewPortHeight);
		Assert.equals(120.0, result.contentHeight);
	}

	public function testVerticalRequestedMaxRowCountWithZeroItems():Void {
		this._layout.pageDirection = VERTICAL;
		this._layout.requestedMinRowCount = 3;
		var result = this._layout.layout([], this._measurements);
		Assert.equals(0.0, result.viewPortWidth);
		Assert.equals(0.0, result.contentWidth);
		Assert.equals(0.0, result.viewPortHeight);
		Assert.equals(0.0, result.contentHeight);
	}

	public function testVerticalRequestedMaxRowCountWithFewerItems():Void {
		this._layout.pageDirection = VERTICAL;
		this._measurements.width = 100.0;
		this._layout.requestedMaxRowCount = 3;
		this._control1.setSize(100.0, 60.0);
		this._control2.setSize(100.0, 60.0);
		var result = this._layout.layout([this._control1, this._control2], this._measurements);
		Assert.equals(100.0, result.viewPortWidth);
		Assert.equals(100.0, result.contentWidth);
		Assert.equals(120.0, result.viewPortHeight);
		Assert.equals(120.0, result.contentHeight);
	}

	public function testVerticalRequestedMaxRowCountWithMoreItems():Void {
		this._layout.pageDirection = VERTICAL;
		this._measurements.width = 100.0;
		this._layout.requestedMaxRowCount = 1;
		this._control1.setSize(100.0, 60.0);
		this._control2.setSize(100.0, 60.0);
		var result = this._layout.layout([this._control1, this._control2], this._measurements);
		Assert.equals(100.0, result.viewPortWidth);
		Assert.equals(100.0, result.contentWidth);
		Assert.equals(60.0, result.viewPortHeight);
		Assert.equals(120.0, result.contentHeight);
	}

	public function testVerticalRequestedColumnCountWithZeroItems():Void {
		this._layout.pageDirection = VERTICAL;
		this._layout.requestedColumnCount = 3;
		var result = this._layout.layout([], this._measurements);
		Assert.equals(0.0, result.viewPortWidth);
		Assert.equals(0.0, result.contentWidth);
		Assert.equals(0.0, result.viewPortHeight);
		Assert.equals(0.0, result.contentHeight);
	}

	public function testVerticalRequestedColumnCountWithFewerItems():Void {
		this._layout.pageDirection = VERTICAL;
		this._layout.requestedColumnCount = 3;
		this._control1.setSize(100.0, 60.0);
		this._control2.setSize(100.0, 60.0);
		var result = this._layout.layout([this._control1, this._control2], this._measurements);
		Assert.equals(300.0, result.viewPortWidth);
		Assert.equals(300.0, result.contentWidth);
		Assert.equals(60.0, result.viewPortHeight);
		Assert.equals(60.0, result.contentHeight);
	}

	public function testVerticalRequestedColumnCountWithMoreItems():Void {
		this._layout.pageDirection = VERTICAL;
		this._layout.requestedColumnCount = 1;
		this._control1.setSize(100.0, 60.0);
		this._control2.setSize(100.0, 60.0);
		var result = this._layout.layout([this._control1, this._control2], this._measurements);
		Assert.equals(100.0, result.viewPortWidth);
		Assert.equals(100.0, result.contentWidth);
		Assert.equals(120.0, result.viewPortHeight);
		Assert.equals(120.0, result.contentHeight);
	}

	public function testVerticalRequestedMinColumnCountWithZeroItems():Void {
		this._layout.pageDirection = VERTICAL;
		this._layout.requestedMinColumnCount = 3;
		var result = this._layout.layout([], this._measurements);
		Assert.equals(0.0, result.viewPortWidth);
		Assert.equals(0.0, result.contentWidth);
		Assert.equals(0.0, result.viewPortHeight);
		Assert.equals(0.0, result.contentHeight);
	}

	public function testVerticalRequestedMinColumnCountWithFewerItems():Void {
		this._layout.pageDirection = VERTICAL;
		this._layout.requestedMinColumnCount = 3;
		this._control1.setSize(100.0, 60.0);
		this._control2.setSize(100.0, 60.0);
		var result = this._layout.layout([this._control1, this._control2], this._measurements);
		Assert.equals(300.0, result.viewPortWidth);
		Assert.equals(300.0, result.contentWidth);
		Assert.equals(60.0, result.viewPortHeight);
		Assert.equals(60.0, result.contentHeight);
	}

	public function testVerticalRequestedMinColumnCountWithMoreItems():Void {
		this._layout.pageDirection = VERTICAL;
		this._layout.requestedMinColumnCount = 1;
		this._control1.setSize(100.0, 60.0);
		this._control2.setSize(100.0, 60.0);
		var result = this._layout.layout([this._control1, this._control2], this._measurements);
		Assert.equals(200.0, result.viewPortWidth);
		Assert.equals(200.0, result.contentWidth);
		Assert.equals(60.0, result.viewPortHeight);
		Assert.equals(60.0, result.contentHeight);
	}

	public function testVerticalRequestedMaxColumnCountWithZeroItems():Void {
		this._layout.pageDirection = VERTICAL;
		this._layout.requestedMaxColumnCount = 3;
		var result = this._layout.layout([], this._measurements);
		Assert.equals(0.0, result.viewPortWidth);
		Assert.equals(0.0, result.contentWidth);
		Assert.equals(0.0, result.viewPortHeight);
		Assert.equals(0.0, result.contentHeight);
	}

	public function testVerticalRequestedMaxColumnCountWithFewerItems():Void {
		this._layout.pageDirection = VERTICAL;
		this._layout.requestedMaxColumnCount = 3;
		this._control1.setSize(100.0, 60.0);
		this._control2.setSize(100.0, 60.0);
		var result = this._layout.layout([this._control1, this._control2], this._measurements);
		Assert.equals(200.0, result.viewPortWidth);
		Assert.equals(200.0, result.contentWidth);
		Assert.equals(60.0, result.viewPortHeight);
		Assert.equals(60.0, result.contentHeight);
	}

	public function testVerticalRequestedMaxColumnCountWithMoreItems():Void {
		this._layout.pageDirection = VERTICAL;
		this._layout.requestedMaxColumnCount = 1;
		this._control1.setSize(100.0, 60.0);
		this._control2.setSize(100.0, 60.0);
		var result = this._layout.layout([this._control1, this._control2], this._measurements);
		Assert.equals(100.0, result.viewPortWidth);
		Assert.equals(100.0, result.contentWidth);
		Assert.equals(120.0, result.viewPortHeight);
		Assert.equals(120.0, result.contentHeight);
	}
}

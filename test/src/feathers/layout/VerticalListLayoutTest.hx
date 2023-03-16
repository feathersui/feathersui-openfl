/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import feathers.controls.LayoutGroup;
import feathers.layout.Measurements;
import openfl.Lib;
import openfl.display.Shape;
import openfl.events.Event;
import utest.Assert;
import utest.Test;

@:keep
class VerticalListLayoutTest extends Test {
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

	public function testPaddingTopChangeEvent():Void {
		var changed = false;
		this._layout.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._layout.paddingTop = PADDING_TOP;
		Assert.isTrue(changed);
	}

	public function testPaddingRightChangeEvent():Void {
		var changed = false;
		this._layout.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._layout.paddingRight = PADDING_RIGHT;
		Assert.isTrue(changed);
	}

	public function testPaddingBottomChangeEvent():Void {
		var changed = false;
		this._layout.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._layout.paddingBottom = PADDING_BOTTOM;
		Assert.isTrue(changed);
	}

	public function testPaddingLeftChangeEvent():Void {
		var changed = false;
		this._layout.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._layout.paddingLeft = PADDING_LEFT;
		Assert.isTrue(changed);
	}

	public function testGapChangeEvent():Void {
		var changed = false;
		this._layout.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._layout.gap = GAP;
		Assert.isTrue(changed);
	}

	public function testVerticalAlignChangeEvent():Void {
		var changed = false;
		this._layout.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._layout.verticalAlign = BOTTOM;
		Assert.isTrue(changed);
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

	public function testZeroItemsWithPaddingAndNullMeasurements():Void {
		this._layout.paddingTop = PADDING_TOP;
		this._layout.paddingRight = PADDING_RIGHT;
		this._layout.paddingBottom = PADDING_BOTTOM;
		this._layout.paddingLeft = PADDING_LEFT;
		var result = this._layout.layout([], this._measurements);
		Assert.equals(PADDING_LEFT + PADDING_RIGHT, result.viewPortWidth);
		Assert.equals(PADDING_TOP + PADDING_BOTTOM, result.viewPortHeight);
		Assert.equals(PADDING_LEFT + PADDING_RIGHT, result.contentWidth);
		Assert.equals(PADDING_TOP + PADDING_BOTTOM, result.contentHeight);
		Assert.equals(0.0, result.contentX);
		Assert.equals(0.0, result.contentY);
	}

	public function testZeroItemsWithGapAndNullMeasurements():Void {
		this._layout.gap = GAP;
		var result = this._layout.layout([], this._measurements);
		Assert.equals(0.0, result.viewPortWidth);
		Assert.equals(0.0, result.viewPortHeight);
		Assert.equals(0.0, result.contentWidth);
		Assert.equals(0.0, result.contentHeight);
		Assert.equals(0.0, result.contentX);
		Assert.equals(0.0, result.contentY);
	}

	public function testZeroItemsWithPaddingGapAndNullMeasurements():Void {
		this._layout.paddingTop = PADDING_TOP;
		this._layout.paddingRight = PADDING_RIGHT;
		this._layout.paddingBottom = PADDING_BOTTOM;
		this._layout.paddingLeft = PADDING_LEFT;
		this._layout.gap = GAP;
		var result = this._layout.layout([], this._measurements);
		Assert.equals(PADDING_LEFT + PADDING_RIGHT, result.viewPortWidth);
		Assert.equals(PADDING_TOP + PADDING_BOTTOM, result.viewPortHeight);
		Assert.equals(PADDING_LEFT + PADDING_RIGHT, result.contentWidth);
		Assert.equals(PADDING_TOP + PADDING_BOTTOM, result.contentHeight);
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

	public function testOneItemWithGapAndNullMeasurements():Void {
		this._layout.gap = GAP;
		var result = this._layout.layout([this._child1], this._measurements);
		Assert.equals(CHILD1_WIDTH, result.viewPortWidth);
		Assert.equals(CHILD1_HEIGHT, result.viewPortHeight);
		Assert.equals(CHILD1_WIDTH, result.contentWidth);
		Assert.equals(CHILD1_HEIGHT, result.contentHeight);
		Assert.equals(0.0, result.contentX);
		Assert.equals(0.0, result.contentY);
	}

	public function testOneItemWithPaddingGapAndNullMeasurements():Void {
		this._layout.paddingTop = PADDING_TOP;
		this._layout.paddingRight = PADDING_RIGHT;
		this._layout.paddingBottom = PADDING_BOTTOM;
		this._layout.paddingLeft = PADDING_LEFT;
		this._layout.gap = GAP;
		var result = this._layout.layout([this._child1], this._measurements);
		Assert.equals(PADDING_LEFT + PADDING_RIGHT + CHILD1_WIDTH, result.viewPortWidth);
		Assert.equals(PADDING_TOP + PADDING_BOTTOM + CHILD1_HEIGHT, result.viewPortHeight);
		Assert.equals(PADDING_LEFT + PADDING_RIGHT + CHILD1_WIDTH, result.contentWidth);
		Assert.equals(PADDING_TOP + PADDING_BOTTOM + CHILD1_HEIGHT, result.contentHeight);
		Assert.equals(0.0, result.contentX);
		Assert.equals(0.0, result.contentY);
	}

	public function testOneItemWithPaddingAndNullMeasurements():Void {
		this._layout.paddingTop = PADDING_TOP;
		this._layout.paddingRight = PADDING_RIGHT;
		this._layout.paddingBottom = PADDING_BOTTOM;
		this._layout.paddingLeft = PADDING_LEFT;
		var result = this._layout.layout([this._child1], this._measurements);
		Assert.equals(PADDING_LEFT + PADDING_RIGHT + CHILD1_WIDTH, result.viewPortWidth);
		Assert.equals(PADDING_TOP + PADDING_BOTTOM + CHILD1_HEIGHT, result.viewPortHeight);
		Assert.equals(PADDING_LEFT + PADDING_RIGHT + CHILD1_WIDTH, result.contentWidth);
		Assert.equals(PADDING_TOP + PADDING_BOTTOM + CHILD1_HEIGHT, result.contentHeight);
		Assert.equals(0.0, result.contentX);
		Assert.equals(0.0, result.contentY);
	}

	public function testTwoItemsWithNullMeasurements():Void {
		var result = this._layout.layout([this._child1, this._child2], this._measurements);
		Assert.equals(Math.max(CHILD1_WIDTH, CHILD2_WIDTH), result.viewPortWidth);
		Assert.equals(CHILD1_HEIGHT + CHILD2_HEIGHT, result.viewPortHeight);
		Assert.equals(Math.max(CHILD1_WIDTH, CHILD2_WIDTH), result.contentWidth);
		Assert.equals(CHILD1_HEIGHT + CHILD2_HEIGHT, result.contentHeight);
		Assert.equals(0.0, result.contentX);
		Assert.equals(0.0, result.contentY);
	}

	public function testTwoItemsWithGapAndNullMeasurements():Void {
		this._layout.gap = GAP;
		var result = this._layout.layout([this._child1, this._child2], this._measurements);
		Assert.equals(Math.max(CHILD1_WIDTH, CHILD2_WIDTH), result.viewPortWidth);
		Assert.equals(CHILD1_HEIGHT + CHILD2_HEIGHT + GAP, result.viewPortHeight);
		Assert.equals(Math.max(CHILD1_WIDTH, CHILD2_WIDTH), result.contentWidth);
		Assert.equals(CHILD1_HEIGHT + CHILD2_HEIGHT + GAP, result.contentHeight);
		Assert.equals(0.0, result.contentX);
		Assert.equals(0.0, result.contentY);
	}

	public function testTwoItemsWithPaddingAndNullMeasurements():Void {
		this._layout.paddingTop = PADDING_TOP;
		this._layout.paddingRight = PADDING_RIGHT;
		this._layout.paddingBottom = PADDING_BOTTOM;
		this._layout.paddingLeft = PADDING_LEFT;
		var result = this._layout.layout([this._child1, this._child2], this._measurements);
		Assert.equals(PADDING_LEFT + PADDING_RIGHT + Math.max(CHILD1_WIDTH, CHILD2_WIDTH), result.viewPortWidth);
		Assert.equals(PADDING_TOP + PADDING_BOTTOM + CHILD1_HEIGHT + CHILD2_HEIGHT, result.viewPortHeight);
		Assert.equals(PADDING_LEFT + PADDING_RIGHT + Math.max(CHILD1_WIDTH, CHILD2_WIDTH), result.contentWidth);
		Assert.equals(PADDING_TOP + PADDING_BOTTOM + CHILD1_HEIGHT + CHILD2_HEIGHT, result.contentHeight);
		Assert.equals(0.0, result.contentX);
		Assert.equals(0.0, result.contentY);
	}

	public function testTwoItemsWithPaddingGapAndNullMeasurements():Void {
		this._layout.paddingTop = PADDING_TOP;
		this._layout.paddingRight = PADDING_RIGHT;
		this._layout.paddingBottom = PADDING_BOTTOM;
		this._layout.paddingLeft = PADDING_LEFT;
		this._layout.gap = GAP;
		var result = this._layout.layout([this._child1, this._child2], this._measurements);
		Assert.equals(PADDING_LEFT + PADDING_RIGHT + Math.max(CHILD1_WIDTH, CHILD2_WIDTH), result.viewPortWidth);
		Assert.equals(PADDING_TOP + PADDING_BOTTOM + CHILD1_HEIGHT + CHILD2_HEIGHT + GAP, result.viewPortHeight);
		Assert.equals(PADDING_LEFT + PADDING_RIGHT + Math.max(CHILD1_WIDTH, CHILD2_WIDTH), result.contentWidth);
		Assert.equals(PADDING_TOP + PADDING_BOTTOM + CHILD1_HEIGHT + CHILD2_HEIGHT + GAP, result.contentHeight);
		Assert.equals(0.0, result.contentX);
		Assert.equals(0.0, result.contentY);
	}

	public function testRequestedRowCountWithZeroItemsAndNullMeasurements():Void {
		this._layout.requestedRowCount = 3;
		var result = this._layout.layout([], this._measurements);
		Assert.equals(0.0, result.viewPortWidth);
		Assert.equals(0.0, result.viewPortHeight);
		Assert.equals(0.0, result.contentWidth);
		Assert.equals(0.0, result.contentHeight);
		Assert.equals(0.0, result.contentMinWidth);
		Assert.equals(0.0, result.contentMinHeight);
	}

	public function testRequestedRowCountWithZeroItemsPaddingNullMeasurements():Void {
		this._layout.requestedRowCount = 3;
		this._layout.paddingTop = PADDING_TOP;
		this._layout.paddingRight = PADDING_RIGHT;
		this._layout.paddingBottom = PADDING_BOTTOM;
		this._layout.paddingLeft = PADDING_LEFT;
		var result = this._layout.layout([], this._measurements);
		Assert.equals(PADDING_LEFT + PADDING_RIGHT, result.viewPortWidth);
		Assert.equals(PADDING_TOP + PADDING_BOTTOM, result.viewPortHeight);
		Assert.equals(PADDING_LEFT + PADDING_RIGHT, result.contentWidth);
		Assert.equals(PADDING_TOP + PADDING_BOTTOM, result.contentHeight);
		Assert.equals(0.0, result.contentMinWidth);
		Assert.equals(0.0, result.contentMinHeight);
	}

	public function testRequestedRowCountWithZeroItemsGapAndNullMeasurements():Void {
		this._layout.requestedRowCount = 3;
		this._layout.gap = GAP;
		var result = this._layout.layout([], this._measurements);
		Assert.equals(0.0, result.viewPortWidth);
		// view port height needs to include the gap with requested row count
		Assert.equals(GAP + GAP, result.viewPortHeight);
		Assert.equals(0.0, result.contentWidth);
		// but the content is empty, so no gap here
		Assert.equals(0.0, result.contentHeight);
		Assert.equals(0.0, result.contentMinWidth);
		Assert.equals(0.0, result.contentMinHeight);
	}

	public function testRequestedRowCountWithZeroItemsPaddingGapAndNullMeasurements():Void {
		this._layout.requestedRowCount = 3;
		this._layout.paddingTop = PADDING_TOP;
		this._layout.paddingRight = PADDING_RIGHT;
		this._layout.paddingBottom = PADDING_BOTTOM;
		this._layout.paddingLeft = PADDING_LEFT;
		this._layout.gap = GAP;
		var result = this._layout.layout([], this._measurements);
		Assert.equals(PADDING_LEFT + PADDING_RIGHT, result.viewPortWidth);
		// view port height needs to include the gap with requested row count
		Assert.equals(PADDING_TOP + GAP + GAP + PADDING_BOTTOM, result.viewPortHeight);
		Assert.equals(PADDING_LEFT + PADDING_RIGHT, result.contentWidth);
		// but the content is empty, so no gap here
		Assert.equals(PADDING_TOP + PADDING_BOTTOM, result.contentHeight);
		Assert.equals(0.0, result.contentMinWidth);
		Assert.equals(0.0, result.contentMinHeight);
	}

	public function testRequestedRowCountWithFewerItems():Void {
		this._layout.widthResetEnabled = false;
		this._layout.requestedRowCount = 3;
		this._control1.setSize(100.0, 60.0);
		this._control2.setSize(100.0, 60.0);
		var result = this._layout.layout([this._control1, this._control2], this._measurements);
		Assert.equals(100.0, result.viewPortWidth);
		Assert.equals(180.0, result.viewPortHeight);
		Assert.equals(100.0, result.contentWidth);
		Assert.equals(120.0, result.contentHeight);
		Assert.equals(0.0, result.contentMinWidth);
		Assert.equals(0.0, result.contentMinHeight);
	}

	public function testRequestedRowCountWithMoreItems():Void {
		this._layout.widthResetEnabled = false;
		this._layout.requestedRowCount = 1;
		this._control1.setSize(100.0, 60.0);
		this._control2.setSize(100.0, 60.0);
		var result = this._layout.layout([this._control1, this._control2], this._measurements);
		Assert.equals(100.0, result.viewPortWidth);
		Assert.equals(60.0, result.viewPortHeight);
		Assert.equals(100.0, result.contentWidth);
		Assert.equals(120.0, result.contentHeight);
		Assert.equals(0.0, result.contentMinWidth);
		Assert.equals(0.0, result.contentMinHeight);
	}

	public function testRequestedMinRowCountWithZeroItemsAndNullMeasurements():Void {
		this._layout.requestedMinRowCount = 3;
		var result = this._layout.layout([], this._measurements);
		Assert.equals(0.0, result.viewPortWidth);
		Assert.equals(0.0, result.viewPortHeight);
		Assert.equals(0.0, result.contentWidth);
		Assert.equals(0.0, result.contentHeight);
		Assert.equals(0.0, result.contentMinWidth);
		Assert.equals(0.0, result.contentMinHeight);
	}

	public function testRequestedMinRowCountWithZeroItemsPaddingAndNullMeasurements():Void {
		this._layout.requestedMinRowCount = 3;
		this._layout.paddingTop = PADDING_TOP;
		this._layout.paddingRight = PADDING_RIGHT;
		this._layout.paddingBottom = PADDING_BOTTOM;
		this._layout.paddingLeft = PADDING_LEFT;
		var result = this._layout.layout([], this._measurements);
		Assert.equals(PADDING_LEFT + PADDING_RIGHT, result.viewPortWidth);
		Assert.equals(PADDING_TOP + PADDING_BOTTOM, result.viewPortHeight);
		Assert.equals(PADDING_LEFT + PADDING_RIGHT, result.contentWidth);
		Assert.equals(PADDING_TOP + PADDING_BOTTOM, result.contentHeight);
		Assert.equals(0.0, result.contentMinWidth);
		Assert.equals(PADDING_TOP + PADDING_BOTTOM, result.contentMinHeight);
	}

	public function testRequestedMinRowCountWithZeroItemsGapAndNullMeasurements():Void {
		this._layout.requestedMinRowCount = 3;
		this._layout.gap = GAP;
		var result = this._layout.layout([], this._measurements);
		Assert.equals(0.0, result.viewPortWidth);
		// view port height needs to include the gap with requested row count
		Assert.equals(GAP + GAP, result.viewPortHeight);
		Assert.equals(0.0, result.contentWidth);
		// but the content is empty, so no gap here
		Assert.equals(0.0, result.contentHeight);
		Assert.equals(0.0, result.contentMinWidth);
		Assert.equals(GAP + GAP, result.contentMinHeight);
	}

	public function testRequestedMinRowCountWithZeroItemsPaddingGapAndNullMeasurements():Void {
		this._layout.requestedMinRowCount = 3;
		this._layout.paddingTop = PADDING_TOP;
		this._layout.paddingRight = PADDING_RIGHT;
		this._layout.paddingBottom = PADDING_BOTTOM;
		this._layout.paddingLeft = PADDING_LEFT;
		this._layout.gap = GAP;
		var result = this._layout.layout([], this._measurements);
		Assert.equals(PADDING_LEFT + PADDING_RIGHT, result.viewPortWidth);
		// view port height needs to include the gap with requested row count
		Assert.equals(PADDING_TOP + GAP + GAP + PADDING_BOTTOM, result.viewPortHeight);
		Assert.equals(PADDING_LEFT + PADDING_RIGHT, result.contentWidth);
		// but the content is empty, so no gap here
		Assert.equals(PADDING_TOP + PADDING_BOTTOM, result.contentHeight);
		Assert.equals(0.0, result.contentMinWidth);
		Assert.equals(PADDING_TOP + GAP + GAP + PADDING_BOTTOM, result.contentMinHeight);
	}

	public function testRequestedMinRowCountWithFewerItems():Void {
		this._layout.widthResetEnabled = false;
		this._layout.requestedMinRowCount = 3;
		this._control1.setSize(100.0, 60.0);
		this._control2.setSize(100.0, 60.0);
		var result = this._layout.layout([this._control1, this._control2], this._measurements);
		Assert.equals(100.0, result.viewPortWidth);
		Assert.equals(180.0, result.viewPortHeight);
		Assert.equals(100.0, result.contentWidth);
		Assert.equals(120.0, result.contentHeight);
		Assert.equals(0.0, result.contentMinWidth);
		Assert.equals(180.0, result.contentMinHeight);
	}

	public function testRequestedMinRowCountWithMoreItems():Void {
		this._layout.widthResetEnabled = false;
		this._layout.requestedMinRowCount = 1;
		this._control1.setSize(100.0, 60.0);
		this._control2.setSize(100.0, 60.0);
		var result = this._layout.layout([this._control1, this._control2], this._measurements);
		Assert.equals(100.0, result.viewPortWidth);
		Assert.equals(120.0, result.viewPortHeight);
		Assert.equals(100.0, result.contentWidth);
		Assert.equals(120.0, result.contentHeight);
		Assert.equals(0.0, result.contentMinWidth);
		Assert.equals(60.0, result.contentMinHeight);
	}

	public function testRequestedMaxRowCountWithZeroItems():Void {
		this._layout.requestedMaxRowCount = 3;
		var result = this._layout.layout([], this._measurements);
		Assert.equals(0.0, result.viewPortWidth);
		Assert.equals(0.0, result.viewPortHeight);
		Assert.equals(0.0, result.contentWidth);
		Assert.equals(0.0, result.contentHeight);
		Assert.equals(0.0, result.contentMinWidth);
		Assert.equals(0.0, result.contentMinHeight);
	}

	public function testRequestedMaxRowCountWithFewerItems():Void {
		this._layout.widthResetEnabled = false;
		this._layout.requestedMaxRowCount = 3;
		this._control1.setSize(100.0, 60.0);
		this._control2.setSize(100.0, 60.0);
		var result = this._layout.layout([this._control1, this._control2], this._measurements);
		Assert.equals(100.0, result.viewPortWidth);
		Assert.equals(120.0, result.viewPortHeight);
		Assert.equals(100.0, result.contentWidth);
		Assert.equals(120.0, result.contentHeight);
		Assert.equals(0.0, result.contentMinWidth);
		Assert.equals(0.0, result.contentMinHeight);
	}

	public function testRequestedMaxRowCountWithMoreItems():Void {
		this._layout.widthResetEnabled = false;
		this._layout.requestedMaxRowCount = 1;
		this._control1.setSize(100.0, 60.0);
		this._control2.setSize(100.0, 60.0);
		var result = this._layout.layout([this._control1, this._control2], this._measurements);
		Assert.equals(100.0, result.viewPortWidth);
		Assert.equals(60.0, result.viewPortHeight);
		Assert.equals(100.0, result.contentWidth);
		Assert.equals(120.0, result.contentHeight);
		Assert.equals(0.0, result.contentMinWidth);
		Assert.equals(0.0, result.contentMinHeight);
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

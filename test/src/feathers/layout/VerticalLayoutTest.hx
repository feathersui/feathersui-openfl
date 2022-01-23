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
import openfl.events.Event;
import utest.Assert;
import utest.Test;

@:keep
class VerticalLayoutTest extends Test {
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
	private var _layout:VerticalLayout;
	private var _child1:Shape;
	private var _child2:Shape;
	private var _control1:LayoutGroup;
	private var _control2:LayoutGroup;

	public function new() {
		super();
	}

	public function setup():Void {
		this._layout = new VerticalLayout();
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

	public function testHorizontalAlignChangeEvent():Void {
		var changed = false;
		this._layout.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._layout.horizontalAlign = RIGHT;
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

	public function testPercentWidth():Void {
		this._measurements.width = 640.0;
		this._control1.layoutData = new VerticalLayoutData(50.0);
		var result = this._layout.layout([this._control1], this._measurements);
		Assert.equals(this._measurements.width, result.viewPortWidth);
		Assert.equals(this._measurements.width, result.contentWidth);
		Assert.equals(this._measurements.width / 2.0, this._control1.width);
	}

	public function testPercentWidthGreaterThan100():Void {
		this._measurements.width = 640.0;
		this._control1.layoutData = new VerticalLayoutData(150.0);
		var result = this._layout.layout([this._control1], this._measurements);
		Assert.equals(this._measurements.width, result.viewPortWidth);
		Assert.equals(this._measurements.width, result.contentWidth);
		Assert.equals(this._measurements.width, this._control1.width);
	}

	public function testPercentWidthLessThan0():Void {
		this._measurements.width = 640.0;
		this._control1.layoutData = new VerticalLayoutData(-50.0);
		var result = this._layout.layout([this._control1], this._measurements);
		Assert.equals(this._measurements.width, result.viewPortWidth);
		Assert.equals(this._measurements.width, result.contentWidth);
		Assert.equals(0.0, this._control1.width);
	}

	public function testPercentWidthWithExplicitMinWidth():Void {
		this._measurements.width = 640.0;
		this._control1.minWidth = 400.0;
		this._control1.layoutData = new VerticalLayoutData(50.0);
		var result = this._layout.layout([this._control1], this._measurements);
		Assert.equals(this._measurements.width, result.viewPortWidth);
		Assert.equals(this._measurements.width, result.contentWidth);
		Assert.equals(400.0, this._control1.width);
	}

	public function testPercentWidthWithExplicitMaxWidth():Void {
		this._measurements.width = 640.0;
		this._control1.maxWidth = 250.0;
		this._control1.layoutData = new VerticalLayoutData(50.0);
		var result = this._layout.layout([this._control1], this._measurements);
		Assert.equals(this._measurements.width, result.viewPortWidth);
		Assert.equals(this._measurements.width, result.contentWidth);
		Assert.equals(250.0, this._control1.width);
	}

	public function testPercentWidthWithCalculatedMinWidthAndNoExplicitWidth():Void {
		var child = new Shape();
		child.graphics.beginFill(0xff00ff);
		child.graphics.drawRect(0, 0, 150.0, 200.0);
		this._control1.addChild(child);
		this._control1.layoutData = new VerticalLayoutData(100.0, 100.0);
		var result = this._layout.layout([this._control1], this._measurements);
		Assert.equals(150.0, result.viewPortWidth);
		Assert.equals(150.0, result.contentWidth);
	}

	public function testPercentWidthWithViewPortMinWidth():Void {
		this._measurements.minWidth = 50.0;
		this._control1.layoutData = new VerticalLayoutData(100.0);
		var result = this._layout.layout([this._control1], this._measurements);
		Assert.equals(this._measurements.minWidth, result.viewPortWidth);
		Assert.equals(this._measurements.minWidth, result.contentWidth);
		Assert.equals(this._measurements.minWidth, this._control1.width);
	}

	public function testPercentWidthWithExplicitMinWidthAndSmallerViewPortMaxWidth():Void {
		this._measurements.maxWidth = 50.0;
		this._control1.minWidth = 150.0;
		this._control1.layoutData = new VerticalLayoutData(100.0);
		var result = this._layout.layout([this._control1], this._measurements);
		Assert.equals(this._measurements.maxWidth, result.viewPortWidth);
		// Assert.equals(this._measurements.maxWidth, result.contentWidth);
		Assert.equals(this._measurements.maxWidth, this._control1.width);
	}

	public function testPercentHeightWithOneItem():Void {
		this._measurements.height = 640.0;
		this._control1.layoutData = new VerticalLayoutData(null, 50.0);
		var result = this._layout.layout([this._control1], this._measurements);
		Assert.equals(this._measurements.height, result.viewPortHeight);
		Assert.equals(this._measurements.height, result.contentHeight);
		Assert.equals(this._measurements.height / 2.0, this._control1.height);
	}

	public function testPercentHeightGreaterThan100WithOneItem():Void {
		this._measurements.height = 640.0;
		this._control1.layoutData = new VerticalLayoutData(null, 150.0);
		var result = this._layout.layout([this._control1], this._measurements);
		Assert.equals(this._measurements.height, result.viewPortHeight);
		Assert.equals(this._measurements.height, result.contentHeight);
		Assert.equals(this._measurements.height, this._control1.height);
	}

	public function testPercentHeightLessThan0WithOneItem():Void {
		this._measurements.height = 640.0;
		this._control1.layoutData = new VerticalLayoutData(null, -50.0);
		var result = this._layout.layout([this._control1], this._measurements);
		Assert.equals(this._measurements.height, result.viewPortHeight);
		Assert.equals(this._measurements.height, result.contentHeight);
		Assert.equals(0.0, this._control1.height);
	}

	public function testPercentHeightWithTwoItems():Void {
		this._measurements.height = 640.0;
		this._control1.layoutData = new VerticalLayoutData(null, 50.0);
		this._control2.layoutData = new VerticalLayoutData(null, 25.0);
		var result = this._layout.layout([this._control1, this._control2], this._measurements);
		Assert.equals(this._measurements.height, result.viewPortHeight);
		Assert.equals(this._measurements.height, result.contentHeight);
		Assert.equals(this._measurements.height / 2.0, this._control1.height);
		Assert.equals(this._measurements.height / 4.0, this._control2.height);
	}

	public function testPercentHeightGreaterThan100WithTwoItems():Void {
		this._measurements.height = 640.0;
		this._control1.layoutData = new VerticalLayoutData(null, 100.0);
		this._control2.layoutData = new VerticalLayoutData(null, 150.0);
		var result = this._layout.layout([this._control1, this._control2], this._measurements);
		Assert.equals(this._measurements.height, result.viewPortHeight);
		Assert.equals(this._measurements.height, result.contentHeight);
		Assert.equals(this._measurements.height / (250.0 / 100.0), this._control1.height);
		Assert.equals(this._measurements.height / (250.0 / 150.0), this._control2.height);
	}

	public function testPercentHeightWithExplicitMinHeight():Void {
		this._measurements.height = 640.0;
		this._control1.minHeight = 400.0;
		this._control1.layoutData = new VerticalLayoutData(null, 50.0);
		var result = this._layout.layout([this._control1], this._measurements);
		Assert.equals(this._measurements.height, result.viewPortHeight);
		Assert.equals(this._measurements.height, result.contentHeight);
		Assert.equals(400.0, this._control1.height);
	}

	public function testPercentHeightWithCalculatedMinHeightAndNoExplicitHeight():Void {
		var child = new Shape();
		child.graphics.beginFill(0xff00ff);
		child.graphics.drawRect(0, 0, 150.0, 200.0);
		this._control1.addChild(child);
		this._control1.layoutData = new VerticalLayoutData(100.0, 100.0);
		var result = this._layout.layout([this._control1], this._measurements);
		Assert.equals(200.0, result.viewPortHeight);
		Assert.equals(200.0, result.contentHeight);
	}

	public function testPercentHeightWithExplicitMinHeightAndSmallerViewPortMaxHeight():Void {
		this._measurements.maxHeight = 50.0;
		this._control1.minHeight = 150.0;
		this._control1.layoutData = new VerticalLayoutData(null, 100.0);
		var result = this._layout.layout([this._control1], this._measurements);
		Assert.equals(this._measurements.maxHeight, result.viewPortHeight);
		Assert.equals(this._measurements.maxHeight, result.contentHeight);
		Assert.equals(this._measurements.maxHeight, this._control1.height);
	}

	public function testHorizontalAlignLeftAndItemWidthLargerThanViewPortWidth():Void {
		this._layout.horizontalAlign = LEFT;
		this._measurements.width = 50.0;
		this._control1.width = 150.0;
		var result = this._layout.layout([this._control1], this._measurements);
		Assert.equals(this._control1.x, 0.0);
	}

	public function testHorizontalAlignRightAndItemWidthLargerThanViewPortWidth():Void {
		this._layout.horizontalAlign = RIGHT;
		this._measurements.width = 50.0;
		this._control1.width = 150.0;
		var result = this._layout.layout([this._control1], this._measurements);
		Assert.equals(this._control1.x, 0.0);
	}

	public function testHorizontalAlignCenterAndItemWidthLargerThanViewPortWidth():Void {
		this._layout.horizontalAlign = CENTER;
		this._measurements.width = 50.0;
		this._control1.width = 150.0;
		var result = this._layout.layout([this._control1], this._measurements);
		Assert.equals(this._control1.x, 0.0);
	}

	public function testVerticalAlignTopAndItemHeightLargerThanViewPortHeight():Void {
		this._layout.verticalAlign = TOP;
		this._measurements.height = 50.0;
		this._control1.height = 150.0;
		var result = this._layout.layout([this._control1], this._measurements);
		Assert.equals(this._control1.y, 0.0);
	}

	public function testVerticalAlignBottomAndItemHeightLargerThanViewPortHeight():Void {
		this._layout.verticalAlign = BOTTOM;
		this._measurements.height = 50.0;
		this._control1.height = 150.0;
		var result = this._layout.layout([this._control1], this._measurements);
		Assert.equals(this._control1.y, 0.0);
	}

	public function testVerticalAlignMiddleAndItemHeightLargerThanViewPortHeight():Void {
		this._layout.verticalAlign = MIDDLE;
		this._measurements.height = 50.0;
		this._control1.height = 150.0;
		var result = this._layout.layout([this._control1], this._measurements);
		Assert.equals(this._control1.y, 0.0);
	}

	public function testHorizontalAlignJustifyAndExplicitViewPortWidthLargerThanItemWidth():Void {
		var explicitWidth = CHILD1_WIDTH / 2.0;
		this._layout.horizontalAlign = JUSTIFY;
		this._measurements.width = explicitWidth;
		var result = this._layout.layout([this._child1], this._measurements);
		Assert.equals(explicitWidth, result.viewPortWidth);
		Assert.equals(explicitWidth, result.contentWidth);
	}

	public function testHorizontalAlignJustifyAndExplicitViewPortMaxWidthLargerThanItemWidth():Void {
		var maxWidth = CHILD1_WIDTH / 2.0;
		this._layout.horizontalAlign = JUSTIFY;
		this._measurements.maxWidth = maxWidth;
		var result = this._layout.layout([this._child1], this._measurements);
		Assert.equals(maxWidth, result.viewPortWidth);
		Assert.equals(maxWidth, result.contentWidth);
	}
}

/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import feathers.controls.LayoutGroup;
import openfl.events.Event;
import openfl.display.Shape;
import feathers.layout.Measurements;
import massive.munit.Assert;

@:keep
class HorizontalLayoutTest {
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
	private var _layout:HorizontalLayout;
	private var _child1:Shape;
	private var _child2:Shape;
	private var _control1:LayoutGroup;
	private var _control2:LayoutGroup;

	@Before
	public function prepare():Void {
		this._layout = new HorizontalLayout();
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

	@After
	public function cleanup():Void {
		this._measurements = null;
		this._layout = null;
		this._child1 = null;
		this._child1 = null;
		this._control1 = null;
		this._control2 = null;
	}

	@Test
	public function testPaddingTopChangeEvent():Void {
		var changed = false;
		this._layout.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._layout.paddingTop = PADDING_TOP;
		Assert.isTrue(changed);
	}

	@Test
	public function testPaddingRightChangeEvent():Void {
		var changed = false;
		this._layout.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._layout.paddingRight = PADDING_RIGHT;
		Assert.isTrue(changed);
	}

	@Test
	public function testPaddingBottomChangeEvent():Void {
		var changed = false;
		this._layout.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._layout.paddingBottom = PADDING_BOTTOM;
		Assert.isTrue(changed);
	}

	@Test
	public function testPaddingLeftChangeEvent():Void {
		var changed = false;
		this._layout.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._layout.paddingLeft = PADDING_LEFT;
		Assert.isTrue(changed);
	}

	@Test
	public function testGapChangeEvent():Void {
		var changed = false;
		this._layout.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._layout.gap = GAP;
		Assert.isTrue(changed);
	}

	@Test
	public function testHorizontalAlignChangeEvent():Void {
		var changed = false;
		this._layout.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._layout.horizontalAlign = RIGHT;
		Assert.isTrue(changed);
	}

	@Test
	public function testVerticalAlignChangeEvent():Void {
		var changed = false;
		this._layout.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._layout.verticalAlign = BOTTOM;
		Assert.isTrue(changed);
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
	public function testZeroItemsWithPaddingAndNullMeasurements():Void {
		this._layout.paddingTop = PADDING_TOP;
		this._layout.paddingRight = PADDING_RIGHT;
		this._layout.paddingBottom = PADDING_BOTTOM;
		this._layout.paddingLeft = PADDING_LEFT;
		var result = this._layout.layout([], this._measurements);
		Assert.areEqual(PADDING_LEFT + PADDING_RIGHT, result.viewPortWidth);
		Assert.areEqual(PADDING_TOP + PADDING_BOTTOM, result.viewPortHeight);
		Assert.areEqual(PADDING_LEFT + PADDING_RIGHT, result.contentWidth);
		Assert.areEqual(PADDING_TOP + PADDING_BOTTOM, result.contentHeight);
		Assert.areEqual(0.0, result.contentX);
		Assert.areEqual(0.0, result.contentY);
	}

	@Test
	public function testZeroItemsWithGapAndNullMeasurements():Void {
		this._layout.gap = GAP;
		var result = this._layout.layout([], this._measurements);
		Assert.areEqual(0.0, result.viewPortWidth);
		Assert.areEqual(0.0, result.viewPortHeight);
		Assert.areEqual(0.0, result.contentWidth);
		Assert.areEqual(0.0, result.contentHeight);
		Assert.areEqual(0.0, result.contentX);
		Assert.areEqual(0.0, result.contentY);
	}

	@Test
	public function testZeroItemsWithPaddingGapAndNullMeasurements():Void {
		this._layout.paddingTop = PADDING_TOP;
		this._layout.paddingRight = PADDING_RIGHT;
		this._layout.paddingBottom = PADDING_BOTTOM;
		this._layout.paddingLeft = PADDING_LEFT;
		this._layout.gap = GAP;
		var result = this._layout.layout([], this._measurements);
		Assert.areEqual(PADDING_LEFT + PADDING_RIGHT, result.viewPortWidth);
		Assert.areEqual(PADDING_TOP + PADDING_BOTTOM, result.viewPortHeight);
		Assert.areEqual(PADDING_LEFT + PADDING_RIGHT, result.contentWidth);
		Assert.areEqual(PADDING_TOP + PADDING_BOTTOM, result.contentHeight);
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
	public function testOneItemWithGapAndNullMeasurements():Void {
		this._layout.gap = GAP;
		var result = this._layout.layout([this._child1], this._measurements);
		Assert.areEqual(CHILD1_WIDTH, result.viewPortWidth);
		Assert.areEqual(CHILD1_HEIGHT, result.viewPortHeight);
		Assert.areEqual(CHILD1_WIDTH, result.contentWidth);
		Assert.areEqual(CHILD1_HEIGHT, result.contentHeight);
		Assert.areEqual(0.0, result.contentX);
		Assert.areEqual(0.0, result.contentY);
	}

	@Test
	public function testOneItemWithPaddingGapAndNullMeasurements():Void {
		this._layout.paddingTop = PADDING_TOP;
		this._layout.paddingRight = PADDING_RIGHT;
		this._layout.paddingBottom = PADDING_BOTTOM;
		this._layout.paddingLeft = PADDING_LEFT;
		this._layout.gap = GAP;
		var result = this._layout.layout([this._child1], this._measurements);
		Assert.areEqual(PADDING_LEFT + PADDING_RIGHT + CHILD1_WIDTH, result.viewPortWidth);
		Assert.areEqual(PADDING_TOP + PADDING_BOTTOM + CHILD1_HEIGHT, result.viewPortHeight);
		Assert.areEqual(PADDING_LEFT + PADDING_RIGHT + CHILD1_WIDTH, result.contentWidth);
		Assert.areEqual(PADDING_TOP + PADDING_BOTTOM + CHILD1_HEIGHT, result.contentHeight);
		Assert.areEqual(0.0, result.contentX);
		Assert.areEqual(0.0, result.contentY);
	}

	@Test
	public function testOneItemWithPaddingAndNullMeasurements():Void {
		this._layout.paddingTop = PADDING_TOP;
		this._layout.paddingRight = PADDING_RIGHT;
		this._layout.paddingBottom = PADDING_BOTTOM;
		this._layout.paddingLeft = PADDING_LEFT;
		var result = this._layout.layout([this._child1], this._measurements);
		Assert.areEqual(PADDING_LEFT + PADDING_RIGHT + CHILD1_WIDTH, result.viewPortWidth);
		Assert.areEqual(PADDING_TOP + PADDING_BOTTOM + CHILD1_HEIGHT, result.viewPortHeight);
		Assert.areEqual(PADDING_LEFT + PADDING_RIGHT + CHILD1_WIDTH, result.contentWidth);
		Assert.areEqual(PADDING_TOP + PADDING_BOTTOM + CHILD1_HEIGHT, result.contentHeight);
		Assert.areEqual(0.0, result.contentX);
		Assert.areEqual(0.0, result.contentY);
	}

	@Test
	public function testTwoItemsWithNullMeasurements():Void {
		var result = this._layout.layout([this._child1, this._child2], this._measurements);
		Assert.areEqual(CHILD1_WIDTH + CHILD2_WIDTH, result.viewPortWidth);
		Assert.areEqual(Math.max(CHILD1_HEIGHT, CHILD2_HEIGHT), result.viewPortHeight);
		Assert.areEqual(CHILD1_WIDTH + CHILD2_WIDTH, result.contentWidth);
		Assert.areEqual(Math.max(CHILD1_HEIGHT, CHILD2_HEIGHT), result.contentHeight);
		Assert.areEqual(0.0, result.contentX);
		Assert.areEqual(0.0, result.contentY);
	}

	@Test
	public function testTwoItemsWithGapAndNullMeasurements():Void {
		this._layout.gap = GAP;
		var result = this._layout.layout([this._child1, this._child2], this._measurements);
		Assert.areEqual(CHILD1_WIDTH + CHILD2_WIDTH + GAP, result.viewPortWidth);
		Assert.areEqual(Math.max(CHILD1_HEIGHT, CHILD2_HEIGHT), result.viewPortHeight);
		Assert.areEqual(CHILD1_WIDTH + CHILD2_WIDTH + GAP, result.contentWidth);
		Assert.areEqual(Math.max(CHILD1_HEIGHT, CHILD2_HEIGHT), result.contentHeight);
		Assert.areEqual(0.0, result.contentX);
		Assert.areEqual(0.0, result.contentY);
	}

	@Test
	public function testTwoItemsWithPaddingAndNullMeasurements():Void {
		this._layout.paddingTop = PADDING_TOP;
		this._layout.paddingRight = PADDING_RIGHT;
		this._layout.paddingBottom = PADDING_BOTTOM;
		this._layout.paddingLeft = PADDING_LEFT;
		var result = this._layout.layout([this._child1, this._child2], this._measurements);
		Assert.areEqual(PADDING_LEFT + PADDING_RIGHT + CHILD1_WIDTH + CHILD2_WIDTH, result.viewPortWidth);
		Assert.areEqual(PADDING_TOP + PADDING_BOTTOM + Math.max(CHILD1_HEIGHT, CHILD2_HEIGHT), result.viewPortHeight);
		Assert.areEqual(PADDING_LEFT + PADDING_RIGHT + CHILD1_WIDTH + CHILD2_WIDTH, result.contentWidth);
		Assert.areEqual(PADDING_TOP + PADDING_BOTTOM + Math.max(CHILD1_HEIGHT, CHILD2_HEIGHT), result.contentHeight);
		Assert.areEqual(0.0, result.contentX);
		Assert.areEqual(0.0, result.contentY);
	}

	@Test
	public function testTwoItemsWithPaddingGapAndNullMeasurements():Void {
		this._layout.paddingTop = PADDING_TOP;
		this._layout.paddingRight = PADDING_RIGHT;
		this._layout.paddingBottom = PADDING_BOTTOM;
		this._layout.paddingLeft = PADDING_LEFT;
		this._layout.gap = GAP;
		var result = this._layout.layout([this._child1, this._child2], this._measurements);
		Assert.areEqual(PADDING_LEFT + PADDING_RIGHT + CHILD1_WIDTH + CHILD2_WIDTH + GAP, result.viewPortWidth);
		Assert.areEqual(PADDING_TOP + PADDING_BOTTOM + Math.max(CHILD1_HEIGHT, CHILD2_HEIGHT), result.viewPortHeight);
		Assert.areEqual(PADDING_LEFT + PADDING_RIGHT + CHILD1_WIDTH + CHILD2_WIDTH + GAP, result.contentWidth);
		Assert.areEqual(PADDING_TOP + PADDING_BOTTOM + Math.max(CHILD1_HEIGHT, CHILD2_HEIGHT), result.contentHeight);
		Assert.areEqual(0.0, result.contentX);
		Assert.areEqual(0.0, result.contentY);
	}

	@Test
	public function testPercentHeight():Void {
		this._measurements.height = 640.0;
		this._control1.layoutData = new HorizontalLayoutData(null, 50.0);
		var result = this._layout.layout([this._control1], this._measurements);
		Assert.areEqual(this._measurements.height, result.viewPortHeight);
		Assert.areEqual(this._measurements.height, result.contentHeight);
		Assert.areEqual(this._measurements.height / 2.0, this._control1.height);
	}

	@Test
	public function testPercentHeightGreaterThan100():Void {
		this._measurements.height = 640.0;
		this._control1.layoutData = new HorizontalLayoutData(null, 150.0);
		var result = this._layout.layout([this._control1], this._measurements);
		Assert.areEqual(this._measurements.height, result.viewPortHeight);
		Assert.areEqual(this._measurements.height, result.contentHeight);
		Assert.areEqual(this._measurements.height, this._control1.height);
	}

	@Test
	public function testPercentHeightLessThan0():Void {
		this._measurements.height = 640.0;
		this._control1.layoutData = new HorizontalLayoutData(null, -50.0);
		var result = this._layout.layout([this._control1], this._measurements);
		Assert.areEqual(this._measurements.height, result.viewPortHeight);
		Assert.areEqual(this._measurements.height, result.contentHeight);
		Assert.areEqual(0.0, this._control1.height);
	}

	@Test
	public function testPercentHeightWithExplicitMinHeight():Void {
		this._measurements.height = 640.0;
		this._control1.minHeight = 400.0;
		this._control1.layoutData = new HorizontalLayoutData(null, 50.0);
		var result = this._layout.layout([this._control1], this._measurements);
		Assert.areEqual(this._measurements.height, result.viewPortHeight);
		Assert.areEqual(this._measurements.height, result.contentHeight);
		Assert.areEqual(400.0, this._control1.height);
	}

	@Test
	public function testPercentHeightWithExplicitMaxHeight():Void {
		this._measurements.height = 640.0;
		this._control1.maxHeight = 250.0;
		this._control1.layoutData = new HorizontalLayoutData(null, 50.0);
		var result = this._layout.layout([this._control1], this._measurements);
		Assert.areEqual(this._measurements.height, result.viewPortHeight);
		Assert.areEqual(this._measurements.height, result.contentHeight);
		Assert.areEqual(250.0, this._control1.height);
	}

	@Test
	public function testPercentHeightWithCalculatedMinHeightAndNoExplicitHeight():Void {
		var child = new Shape();
		child.graphics.beginFill(0xff00ff);
		child.graphics.drawRect(0, 0, 150.0, 200.0);
		this._control1.addChild(child);
		this._control1.layoutData = new HorizontalLayoutData(100.0, 100.0);
		var result = this._layout.layout([this._control1], this._measurements);
		Assert.areEqual(200.0, result.viewPortHeight);
		Assert.areEqual(200.0, result.contentHeight);
	}

	@Test
	public function testPercentHeightWithExplicitMinHeightAndSmallerViewPortMaxHeight():Void {
		this._measurements.maxHeight = 50.0;
		this._control1.minHeight = 150.0;
		this._control1.layoutData = new HorizontalLayoutData(null, 100.0);
		var result = this._layout.layout([this._control1], this._measurements);
		Assert.areEqual(this._measurements.maxHeight, result.viewPortHeight);
		// Assert.areEqual(this._measurements.maxHeight, result.contentHeight);
		Assert.areEqual(this._measurements.maxHeight, this._control1.height);
	}

	@Test
	public function testPercentWidthWithOneItem():Void {
		this._measurements.width = 640.0;
		this._control1.layoutData = new HorizontalLayoutData(50.0);
		var result = this._layout.layout([this._control1], this._measurements);
		Assert.areEqual(this._measurements.width, result.viewPortWidth);
		Assert.areEqual(this._measurements.width, result.contentWidth);
		Assert.areEqual(this._measurements.width / 2.0, this._control1.width);
	}

	@Test
	public function testPercentWidthGreaterThan100WithOneItem():Void {
		this._measurements.width = 640.0;
		this._control1.layoutData = new HorizontalLayoutData(150.0);
		var result = this._layout.layout([this._control1], this._measurements);
		Assert.areEqual(this._measurements.width, result.viewPortWidth);
		Assert.areEqual(this._measurements.width, result.contentWidth);
		Assert.areEqual(this._measurements.width, this._control1.width);
	}

	@Test
	public function testPercentWidthLessThan0WithOneItem():Void {
		this._measurements.width = 640.0;
		this._control1.layoutData = new HorizontalLayoutData(-50.0);
		var result = this._layout.layout([this._control1], this._measurements);
		Assert.areEqual(this._measurements.width, result.viewPortWidth);
		Assert.areEqual(this._measurements.width, result.contentWidth);
		Assert.areEqual(0.0, this._control1.width);
	}

	@Test
	public function testPercentWidthWithTwoItems():Void {
		this._measurements.width = 640.0;
		this._control1.layoutData = new HorizontalLayoutData(50.0);
		this._control2.layoutData = new HorizontalLayoutData(25.0);
		var result = this._layout.layout([this._control1, this._control2], this._measurements);
		Assert.areEqual(this._measurements.width, result.viewPortWidth);
		Assert.areEqual(this._measurements.width, result.contentWidth);
		Assert.areEqual(this._measurements.width / 2.0, this._control1.width);
		Assert.areEqual(this._measurements.width / 4.0, this._control2.width);
	}

	@Test
	public function testPercentWidthGreaterThan100WithTwoItems():Void {
		this._measurements.width = 640.0;
		this._control1.layoutData = new HorizontalLayoutData(100.0);
		this._control2.layoutData = new HorizontalLayoutData(150.0);
		var result = this._layout.layout([this._control1, this._control2], this._measurements);
		Assert.areEqual(this._measurements.width, result.viewPortWidth);
		Assert.areEqual(this._measurements.width, result.contentWidth);
		Assert.areEqual(this._measurements.width / (250.0 / 100.0), this._control1.width);
		Assert.areEqual(this._measurements.width / (250.0 / 150.0), this._control2.width);
	}

	@Test
	public function testPercentWidthWithExplicitMinWidth():Void {
		this._measurements.width = 640.0;
		this._control1.minWidth = 400.0;
		this._control1.layoutData = new HorizontalLayoutData(50.0);
		var result = this._layout.layout([this._control1], this._measurements);
		Assert.areEqual(this._measurements.width, result.viewPortWidth);
		Assert.areEqual(this._measurements.width, result.contentWidth);
		Assert.areEqual(400.0, this._control1.width);
	}

	@Test
	public function testPercentWidthWithCalculatedMinWidthAndNoExplicitWidth():Void {
		var child = new Shape();
		child.graphics.beginFill(0xff00ff);
		child.graphics.drawRect(0, 0, 150.0, 200.0);
		this._control1.addChild(child);
		this._control1.layoutData = new HorizontalLayoutData(100.0, 100.0);
		var result = this._layout.layout([this._control1], this._measurements);
		Assert.areEqual(150.0, result.viewPortWidth);
		Assert.areEqual(150.0, result.contentWidth);
	}

	@Test
	public function testPercentWidthWithViewPortMinWidth():Void {
		this._measurements.minWidth = 50.0;
		this._control1.layoutData = new HorizontalLayoutData(100.0);
		var result = this._layout.layout([this._control1], this._measurements);
		Assert.areEqual(this._measurements.minWidth, result.viewPortWidth);
		Assert.areEqual(this._measurements.minWidth, result.contentWidth);
		Assert.areEqual(this._measurements.minWidth, this._control1.width);
	}

	@Test
	public function testPercentWidthWithExplicitMinWidthAndSmallerViewPortMaxWidth():Void {
		this._measurements.maxWidth = 50.0;
		this._control1.minWidth = 150.0;
		this._control1.layoutData = new HorizontalLayoutData(100.0);
		var result = this._layout.layout([this._control1], this._measurements);
		Assert.areEqual(this._measurements.maxWidth, result.viewPortWidth);
		Assert.areEqual(this._measurements.maxWidth, result.contentWidth);
		Assert.areEqual(this._measurements.maxWidth, this._control1.width);
	}

	@Test
	public function testHorizontalAlignLeftAndItemWidthLargerThanViewPortWidth():Void {
		this._layout.horizontalAlign = LEFT;
		this._measurements.width = 50.0;
		this._control1.width = 150.0;
		var result = this._layout.layout([this._control1], this._measurements);
		Assert.areEqual(this._control1.x, 0.0);
	}

	@Test
	public function testHorizontalAlignRightAndItemWidthLargerThanViewPortWidth():Void {
		this._layout.horizontalAlign = RIGHT;
		this._measurements.width = 50.0;
		this._control1.width = 150.0;
		var result = this._layout.layout([this._control1], this._measurements);
		Assert.areEqual(this._control1.x, 0.0);
	}

	@Test
	public function testHorizontalAlignCenterAndItemWidthLargerThanViewPortWidth():Void {
		this._layout.horizontalAlign = CENTER;
		this._measurements.width = 50.0;
		this._control1.width = 150.0;
		var result = this._layout.layout([this._control1], this._measurements);
		Assert.areEqual(this._control1.x, 0.0);
	}

	@Test
	public function testVerticalAlignTopAndItemHeightLargerThanViewPortHeight():Void {
		this._layout.verticalAlign = TOP;
		this._measurements.height = 50.0;
		this._control1.height = 150.0;
		var result = this._layout.layout([this._control1], this._measurements);
		Assert.areEqual(this._control1.y, 0.0);
	}

	@Test
	public function testVerticalAlignBottomAndItemHeightLargerThanViewPortHeight():Void {
		this._layout.verticalAlign = BOTTOM;
		this._measurements.height = 50.0;
		this._control1.height = 150.0;
		var result = this._layout.layout([this._control1], this._measurements);
		Assert.areEqual(this._control1.y, 0.0);
	}

	@Test
	public function testVerticalAlignMiddleAndItemHeightLargerThanViewPortHeight():Void {
		this._layout.verticalAlign = MIDDLE;
		this._measurements.height = 50.0;
		this._control1.height = 150.0;
		var result = this._layout.layout([this._control1], this._measurements);
		Assert.areEqual(this._control1.y, 0.0);
	}
}

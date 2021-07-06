/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.layout;

import openfl.display.Shape;
import openfl.events.Event;
import feathers.controls.LayoutGroup;
import feathers.layout.Measurements;
import openfl.display.DisplayObject;
import utest.Assert;
import utest.Test;

@:keep
class HorizontalDistributedLayoutTest extends Test {
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
	private var _layout:HorizontalDistributedLayout;
	private var _child1:Shape;
	private var _child2:Shape;
	private var _control1:LayoutGroup;
	private var _control2:LayoutGroup;
	private var _control3:LayoutGroup;

	public function new() {
		super();
	}

	public function setup():Void {
		this._layout = new HorizontalDistributedLayout();
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
		this._control3 = new LayoutGroup();
	}

	public function teardown():Void {
		this._measurements = null;
		this._layout = null;
		this._child1 = null;
		this._child2 = null;
		this._control1 = null;
		this._control2 = null;
		this._control3 = null;
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
		Assert.equals(2.0 * Math.max(CHILD1_WIDTH, CHILD2_WIDTH), result.viewPortWidth);
		Assert.equals(Math.max(CHILD1_HEIGHT, CHILD2_HEIGHT), result.viewPortHeight);
		Assert.equals(2.0 * Math.max(CHILD1_WIDTH, CHILD2_WIDTH), result.contentWidth);
		Assert.equals(Math.max(CHILD1_HEIGHT, CHILD2_HEIGHT), result.contentHeight);
		Assert.equals(0.0, result.contentX);
		Assert.equals(0.0, result.contentY);
	}

	public function testTwoItemsWithGapAndNullMeasurements():Void {
		this._layout.gap = GAP;
		var result = this._layout.layout([this._child1, this._child2], this._measurements);
		Assert.equals(2.0 * Math.max(CHILD1_WIDTH, CHILD2_WIDTH) + GAP, result.viewPortWidth);
		Assert.equals(Math.max(CHILD1_HEIGHT, CHILD2_HEIGHT), result.viewPortHeight);
		Assert.equals(2.0 * Math.max(CHILD1_WIDTH, CHILD2_WIDTH) + GAP, result.contentWidth);
		Assert.equals(Math.max(CHILD1_HEIGHT, CHILD2_HEIGHT), result.contentHeight);
		Assert.equals(0.0, result.contentX);
		Assert.equals(0.0, result.contentY);
	}

	public function testTwoItemsWithPaddingAndNullMeasurements():Void {
		this._layout.paddingTop = PADDING_TOP;
		this._layout.paddingRight = PADDING_RIGHT;
		this._layout.paddingBottom = PADDING_BOTTOM;
		this._layout.paddingLeft = PADDING_LEFT;
		var result = this._layout.layout([this._child1, this._child2], this._measurements);
		Assert.equals(PADDING_LEFT + PADDING_RIGHT + 2.0 * Math.max(CHILD1_WIDTH, CHILD2_WIDTH), result.viewPortWidth);
		Assert.equals(PADDING_TOP + PADDING_BOTTOM + Math.max(CHILD1_HEIGHT, CHILD2_HEIGHT), result.viewPortHeight);
		Assert.equals(PADDING_LEFT + PADDING_RIGHT + 2.0 * Math.max(CHILD1_WIDTH, CHILD2_WIDTH), result.contentWidth);
		Assert.equals(PADDING_TOP + PADDING_BOTTOM + Math.max(CHILD1_HEIGHT, CHILD2_HEIGHT), result.contentHeight);
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
		Assert.equals(PADDING_LEFT + PADDING_RIGHT + 2.0 * Math.max(CHILD1_WIDTH, CHILD2_WIDTH) + GAP, result.viewPortWidth);
		Assert.equals(PADDING_TOP + PADDING_BOTTOM + Math.max(CHILD1_HEIGHT, CHILD2_HEIGHT), result.viewPortHeight);
		Assert.equals(PADDING_LEFT + PADDING_RIGHT + 2.0 * Math.max(CHILD1_WIDTH, CHILD2_WIDTH) + GAP, result.contentWidth);
		Assert.equals(PADDING_TOP + PADDING_BOTTOM + Math.max(CHILD1_HEIGHT, CHILD2_HEIGHT), result.contentHeight);
		Assert.equals(0.0, result.contentX);
		Assert.equals(0.0, result.contentY);
	}

	public function testTwoItemsWithExplicitWidth():Void {
		var viewPortWidth = 640.0;
		this._measurements.width = viewPortWidth;
		this._layout.layout([this._child1, this._child2], this._measurements);
		var itemWidth = viewPortWidth / 2.0;
		Assert.equals(itemWidth, this._child1.width);
		Assert.equals(itemWidth, this._child2.width);
	}

	public function testTwoItemsWithExplicitWidthWithLargerItemWidths():Void {
		var viewPortWidth = 640.0;
		this._child1.width = 720.0;
		this._child2.width = 800.0;
		this._measurements.width = viewPortWidth;
		this._layout.layout([this._child1, this._child2], this._measurements);
		var itemWidth = viewPortWidth / 2.0;
		Assert.equals(itemWidth, this._child1.width);
		Assert.equals(itemWidth, this._child2.width);
	}

	public function testThreeItemsWithIncludeInLayoutFalse():Void {
		var viewPortWidth = 640.0;
		this._control2.includeInLayout = false;
		var items:Array<DisplayObject> = [this._control1, this._control2, this._control3];
		this._measurements.width = viewPortWidth;
		this._layout.layout(items, this._measurements);
		var itemWidth = viewPortWidth / (items.length - 1);
		Assert.equals(itemWidth, this._control1.width);
		Assert.equals(0.0, this._control2.width);
		Assert.equals(itemWidth, this._control3.width);
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
}

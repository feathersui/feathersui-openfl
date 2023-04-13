/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.controls.HScrollBar;
import feathers.controls.LayoutGroup;
import feathers.controls.VScrollBar;
import feathers.core.FeathersControl;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.ILayout;
import feathers.layout.LayoutBoundsResult;
import feathers.layout.Measurements;
import feathers.layout.VerticalLayout;
import feathers.layout.VerticalLayoutData;
import flash.events.EventDispatcher;
import openfl.Lib;
import openfl.display.DisplayObject;
import openfl.errors.IllegalOperationError;
import openfl.events.Event;
import utest.Assert;
import utest.Test;

@:keep
class ScrollContainerFixedScrollBarsTest extends Test {
	private var _container:ScrollContainer;
	private var _scrollBarX:HScrollBar;
	private var _scrollBarY:VScrollBar;

	public function setup():Void {
		this._container = new ScrollContainer();
		this._container.backgroundSkin = null;
		this._container.setPadding(0.0);
		this._container.fixedScrollBars = true;
		this._container.scrollBarXFactory = () -> {
			this._scrollBarX = new HScrollBar();
			return this._scrollBarX;
		}
		this._container.scrollBarYFactory = () -> {
			this._scrollBarY = new VScrollBar();
			return this._scrollBarY;
		}
		Lib.current.addChild(this._container);
	}

	public function teardown():Void {
		if (this._container.parent != null) {
			this._container.parent.removeChild(this._container);
		}
		this._container = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testEmptyContainer():Void {
		this._container.validateNow();
		Assert.equals(0.0, this._container.width);
		Assert.equals(0.0, this._container.height);
		Assert.isFalse(this._scrollBarX.visible);
		Assert.isFalse(this._scrollBarY.visible);
		Assert.equals(0.0, this._container.minScrollX);
		Assert.equals(0.0, this._container.maxScrollX);
		Assert.equals(0.0, this._container.minScrollY);
		Assert.equals(0.0, this._container.maxScrollY);
	}

	public function testEmptyContainerFixedWidthAndHeight():Void {
		this._container.width = 90.0;
		this._container.height = 60.0;
		this._container.validateNow();
		Assert.equals(90.0, this._container.width);
		Assert.equals(60.0, this._container.height);
		Assert.isFalse(this._scrollBarX.visible);
		Assert.isFalse(this._scrollBarY.visible);
		Assert.equals(0.0, this._container.minScrollX);
		Assert.equals(0.0, this._container.maxScrollX);
		Assert.equals(0.0, this._container.minScrollY);
		Assert.equals(0.0, this._container.maxScrollY);
	}

	public function testAutoMeasureContainer():Void {
		var child = new LayoutGroup();
		child.width = 100.0;
		child.height = 75.0;
		this._container.addChild(child);
		this._container.validateNow();
		Assert.equals(100.0, this._container.width);
		Assert.equals(75.0, this._container.height);
		Assert.isFalse(this._scrollBarX.visible);
		Assert.isFalse(this._scrollBarY.visible);
		Assert.equals(0.0, this._container.minScrollX);
		Assert.equals(0.0, this._container.maxScrollX);
		Assert.equals(0.0, this._container.minScrollY);
		Assert.equals(0.0, this._container.maxScrollY);
	}

	public function testLargerContainerWidthAndHeight():Void {
		var child = new LayoutGroup();
		child.width = 100.0;
		child.height = 75.0;
		this._container.addChild(child);
		this._container.width = 110.0;
		this._container.height = 90.0;
		this._container.validateNow();
		Assert.equals(110.0, this._container.width);
		Assert.equals(90.0, this._container.height);
		Assert.isFalse(this._scrollBarX.visible);
		Assert.isFalse(this._scrollBarY.visible);
		Assert.equals(0.0, this._container.minScrollX);
		Assert.equals(0.0, this._container.maxScrollX);
		Assert.equals(0.0, this._container.minScrollY);
		Assert.equals(0.0, this._container.maxScrollY);
	}

	public function testSmallerContainerWidth():Void {
		var child = new LayoutGroup();
		child.width = 100.0;
		child.height = 75.0;
		this._container.width = 90.0;
		this._container.addChild(child);
		this._container.validateNow();
		Assert.equals(90.0, this._container.width);
		Assert.equals(75.0 + this._scrollBarX.height, this._container.height);
		Assert.isTrue(this._scrollBarX.visible);
		Assert.isFalse(this._scrollBarY.visible);
		Assert.equals(0.0, this._container.minScrollX);
		Assert.equals(10.0, this._container.maxScrollX);
		Assert.equals(0.0, this._container.minScrollY);
		Assert.equals(0.0, this._container.maxScrollY);
	}

	public function testSmallerContainerWidthAndHideScrollBars():Void {
		var child = new LayoutGroup();
		child.width = 100.0;
		child.height = 75.0;
		this._container.width = 90.0;
		this._container.showScrollBars = false;
		this._container.addChild(child);
		this._container.validateNow();
		Assert.equals(90.0, this._container.width);
		Assert.equals(75.0, this._container.height);
		Assert.isFalse(this._scrollBarX.visible);
		Assert.isFalse(this._scrollBarY.visible);
		Assert.equals(0.0, this._container.minScrollX);
		Assert.equals(10.0, this._container.maxScrollX);
		Assert.equals(0.0, this._container.minScrollY);
		Assert.equals(0.0, this._container.maxScrollY);
	}

	public function testSmallerContainerWidthAndScrollPolicyOff():Void {
		var child = new LayoutGroup();
		child.width = 100.0;
		child.height = 75.0;
		this._container.width = 90.0;
		this._container.scrollPolicyX = OFF;
		this._container.addChild(child);
		this._container.validateNow();
		Assert.equals(90.0, this._container.width);
		Assert.equals(75.0, this._container.height);
		Assert.isFalse(this._scrollBarX.visible);
		Assert.isFalse(this._scrollBarY.visible);
		Assert.equals(0.0, this._container.minScrollX);
		Assert.equals(10.0, this._container.maxScrollX);
		Assert.equals(0.0, this._container.minScrollY);
		Assert.equals(0.0, this._container.maxScrollY);
	}

	public function testSmallerContainerHeight():Void {
		var child = new LayoutGroup();
		child.width = 100.0;
		child.height = 75.0;
		this._container.height = 60.0;
		this._container.addChild(child);
		this._container.validateNow();
		Assert.equals(100.0 + this._scrollBarY.width, this._container.width);
		Assert.equals(60.0, this._container.height);
		Assert.isFalse(this._scrollBarX.visible);
		Assert.isTrue(this._scrollBarY.visible);
		Assert.equals(0.0, this._container.minScrollX);
		Assert.equals(0.0, this._container.maxScrollX);
		Assert.equals(0.0, this._container.minScrollY);
		Assert.equals(15.0, this._container.maxScrollY);
	}

	public function testSmallerContainerHeightAndHideScrollBars():Void {
		var child = new LayoutGroup();
		child.width = 100.0;
		child.height = 75.0;
		this._container.height = 60.0;
		this._container.showScrollBars = false;
		this._container.addChild(child);
		this._container.validateNow();
		Assert.equals(100.0, this._container.width);
		Assert.equals(60.0, this._container.height);
		Assert.isFalse(this._scrollBarX.visible);
		Assert.isFalse(this._scrollBarY.visible);
		Assert.equals(0.0, this._container.minScrollX);
		Assert.equals(0.0, this._container.maxScrollX);
		Assert.equals(0.0, this._container.minScrollY);
		Assert.equals(15.0, this._container.maxScrollY);
	}

	public function testSmallerContainerHeightAndScrollPolicyOff():Void {
		var child = new LayoutGroup();
		child.width = 100.0;
		child.height = 75.0;
		this._container.height = 60.0;
		this._container.scrollPolicyY = OFF;
		this._container.addChild(child);
		this._container.validateNow();
		Assert.equals(100.0, this._container.width);
		Assert.equals(60.0, this._container.height);
		Assert.isFalse(this._scrollBarX.visible);
		Assert.isFalse(this._scrollBarY.visible);
		Assert.equals(0.0, this._container.minScrollX);
		Assert.equals(0.0, this._container.maxScrollX);
		Assert.equals(0.0, this._container.minScrollY);
		Assert.equals(15.0, this._container.maxScrollY);
	}

	public function testSmallerContainerWidthAndHeight():Void {
		var child = new LayoutGroup();
		child.width = 100.0;
		child.height = 75.0;
		this._container.width = 90.0;
		this._container.height = 60.0;
		this._container.addChild(child);
		this._container.validateNow();
		Assert.equals(90.0, this._container.width);
		Assert.equals(60.0, this._container.height);
		Assert.isTrue(this._scrollBarX.visible);
		Assert.isTrue(this._scrollBarY.visible);
		Assert.equals(0.0, this._container.minScrollX);
		Assert.equals(10.0 + this._scrollBarY.width, this._container.maxScrollX);
		Assert.equals(0.0, this._container.minScrollY);
		Assert.equals(15.0 + this._scrollBarX.height, this._container.maxScrollY);
	}

	public function testSmallerContainerWidthAndHeightAndHideScrollBars():Void {
		var child = new LayoutGroup();
		child.width = 100.0;
		child.height = 75.0;
		this._container.width = 90.0;
		this._container.height = 60.0;
		this._container.showScrollBars = false;
		this._container.addChild(child);
		this._container.validateNow();
		Assert.equals(90.0, this._container.width);
		Assert.equals(60.0, this._container.height);
		Assert.isFalse(this._scrollBarX.visible);
		Assert.isFalse(this._scrollBarY.visible);
		Assert.equals(0.0, this._container.minScrollX);
		Assert.equals(10.0, this._container.maxScrollX);
		Assert.equals(0.0, this._container.minScrollY);
		Assert.equals(15.0, this._container.maxScrollY);
	}

	public function testSmallerContainerWidthAndHeightAndScrollPolicyOff():Void {
		var child = new LayoutGroup();
		child.width = 100.0;
		child.height = 75.0;
		this._container.width = 90.0;
		this._container.height = 60.0;
		this._container.scrollPolicyX = OFF;
		this._container.scrollPolicyY = OFF;
		this._container.addChild(child);
		this._container.validateNow();
		Assert.equals(90.0, this._container.width);
		Assert.equals(60.0, this._container.height);
		Assert.isFalse(this._scrollBarX.visible);
		Assert.isFalse(this._scrollBarY.visible);
		Assert.equals(0.0, this._container.minScrollX);
		Assert.equals(10.0, this._container.maxScrollX);
		Assert.equals(0.0, this._container.minScrollY);
		Assert.equals(15.0, this._container.maxScrollY);
	}

	public function testSmallerContainerWidthAndHeightAndScrollPolicyXOff():Void {
		var child = new LayoutGroup();
		child.width = 100.0;
		child.height = 75.0;
		this._container.width = 90.0;
		this._container.height = 60.0;
		this._container.scrollPolicyX = OFF;
		this._container.addChild(child);
		this._container.validateNow();
		Assert.equals(90.0, this._container.width);
		Assert.equals(60.0, this._container.height);
		Assert.isFalse(this._scrollBarX.visible);
		Assert.isTrue(this._scrollBarY.visible);
		Assert.equals(0.0, this._container.minScrollX);
		Assert.equals(10.0 + this._scrollBarY.width, this._container.maxScrollX);
		Assert.equals(0.0, this._container.minScrollY);
		Assert.equals(15.0, this._container.maxScrollY);
	}

	public function testSmallerContainerWidthAndHeightAndScrollPolicyYOff():Void {
		var child = new LayoutGroup();
		child.width = 100.0;
		child.height = 75.0;
		this._container.width = 90.0;
		this._container.height = 60.0;
		this._container.scrollPolicyY = OFF;
		this._container.addChild(child);
		this._container.validateNow();
		Assert.equals(90.0, this._container.width);
		Assert.equals(60.0, this._container.height);
		Assert.isTrue(this._scrollBarX.visible);
		Assert.isFalse(this._scrollBarY.visible);
		Assert.equals(0.0, this._container.minScrollX);
		Assert.equals(10.0, this._container.maxScrollX);
		Assert.equals(0.0, this._container.minScrollY);
		Assert.equals(15.0 + this._scrollBarX.height, this._container.maxScrollY);
	}

	public function testLargerContainerWidthThenSetSmallerContainerWidth():Void {
		var child = new LayoutGroup();
		child.width = 100.0;
		child.height = 75.0;
		this._container.addChild(child);
		this._container.width = 110.0;
		this._container.validateNow();
		Assert.equals(110.0, this._container.width);
		Assert.equals(75.0, this._container.height);
		Assert.isFalse(this._scrollBarX.visible);
		Assert.isFalse(this._scrollBarY.visible);
		Assert.equals(0.0, this._container.minScrollX);
		Assert.equals(0.0, this._container.maxScrollX);
		Assert.equals(0.0, this._container.minScrollY);
		Assert.equals(0.0, this._container.maxScrollY);
		this._container.width = 90.0;
		this._container.validateNow();
		Assert.equals(90.0, this._container.width);
		Assert.equals(75.0 + this._scrollBarX.height, this._container.height);
		Assert.isTrue(this._scrollBarX.visible);
		Assert.isFalse(this._scrollBarY.visible);
		Assert.equals(0.0, this._container.minScrollX);
		Assert.equals(10.0, this._container.maxScrollX);
		Assert.equals(0.0, this._container.minScrollY);
		Assert.equals(0.0, this._container.maxScrollY);
	}

	public function testLargerContainerHeightThenSetSmallerContainerHeight():Void {
		var child = new LayoutGroup();
		child.width = 100.0;
		child.height = 75.0;
		this._container.addChild(child);
		this._container.height = 90.0;
		this._container.validateNow();
		Assert.equals(100.0, this._container.width);
		Assert.equals(90.0, this._container.height);
		Assert.isFalse(this._scrollBarX.visible);
		Assert.isFalse(this._scrollBarY.visible);
		Assert.equals(0.0, this._container.minScrollX);
		Assert.equals(0.0, this._container.maxScrollX);
		Assert.equals(0.0, this._container.minScrollY);
		Assert.equals(0.0, this._container.maxScrollY);
		this._container.height = 60.0;
		this._container.validateNow();
		Assert.equals(100.0 + this._scrollBarY.width, this._container.width);
		Assert.equals(60.0, this._container.height);
		Assert.isFalse(this._scrollBarX.visible);
		Assert.isTrue(this._scrollBarY.visible);
		Assert.equals(0.0, this._container.minScrollX);
		Assert.equals(0.0, this._container.maxScrollX);
		Assert.equals(0.0, this._container.minScrollY);
		Assert.equals(15.0, this._container.maxScrollY);
	}

	public function testLargerContainerWidthAndHeightThenSetSmallerContainerWidthAndHeight():Void {
		var child = new LayoutGroup();
		child.width = 100.0;
		child.height = 75.0;
		this._container.addChild(child);
		this._container.width = 110.0;
		this._container.height = 90.0;
		this._container.validateNow();
		Assert.equals(110.0, this._container.width);
		Assert.equals(90.0, this._container.height);
		Assert.isFalse(this._scrollBarX.visible);
		Assert.isFalse(this._scrollBarY.visible);
		Assert.equals(0.0, this._container.minScrollX);
		Assert.equals(0.0, this._container.maxScrollX);
		Assert.equals(0.0, this._container.minScrollY);
		Assert.equals(0.0, this._container.maxScrollY);
		this._container.width = 90.0;
		this._container.height = 60.0;
		this._container.validateNow();
		Assert.equals(90.0, this._container.width);
		Assert.equals(60.0, this._container.height);
		Assert.isTrue(this._scrollBarX.visible);
		Assert.isTrue(this._scrollBarY.visible);
		Assert.equals(0.0, this._container.minScrollX);
		Assert.equals(10.0 + this._scrollBarY.width, this._container.maxScrollX);
		Assert.equals(0.0, this._container.minScrollY);
		Assert.equals(15.0 + this._scrollBarX.height, this._container.maxScrollY);
	}

	public function testSmallerContainerWidthThenSetLargerContainerWidth():Void {
		var child = new LayoutGroup();
		child.width = 100.0;
		child.height = 75.0;
		this._container.addChild(child);
		this._container.width = 90.0;
		this._container.validateNow();
		Assert.equals(90.0, this._container.width);
		Assert.equals(75.0 + this._scrollBarX.height, this._container.height);
		Assert.isTrue(this._scrollBarX.visible);
		Assert.isFalse(this._scrollBarY.visible);
		Assert.equals(0.0, this._container.minScrollX);
		Assert.equals(10.0, this._container.maxScrollX);
		Assert.equals(0.0, this._container.minScrollY);
		Assert.equals(0.0, this._container.maxScrollY);
		this._container.width = 110.0;
		this._container.validateNow();
		Assert.equals(110.0, this._container.width);
		Assert.equals(75.0, this._container.height);
		Assert.isFalse(this._scrollBarX.visible);
		Assert.isFalse(this._scrollBarY.visible);
		Assert.equals(0.0, this._container.minScrollX);
		Assert.equals(0.0, this._container.maxScrollX);
		Assert.equals(0.0, this._container.minScrollY);
		Assert.equals(0.0, this._container.maxScrollY);
	}

	public function testSmallerContainerHeightThenSetLargerContainerHeight():Void {
		var child = new LayoutGroup();
		child.width = 100.0;
		child.height = 75.0;
		this._container.addChild(child);
		this._container.height = 60.0;
		this._container.validateNow();
		Assert.equals(100.0 + this._scrollBarY.width, this._container.width);
		Assert.equals(60.0, this._container.height);
		Assert.isFalse(this._scrollBarX.visible);
		Assert.isTrue(this._scrollBarY.visible);
		Assert.equals(0.0, this._container.minScrollX);
		Assert.equals(0.0, this._container.maxScrollX);
		Assert.equals(0.0, this._container.minScrollY);
		Assert.equals(15.0, this._container.maxScrollY);
		this._container.height = 90.0;
		this._container.validateNow();
		Assert.equals(100.0, this._container.width);
		Assert.equals(90.0, this._container.height);
		Assert.isFalse(this._scrollBarX.visible);
		Assert.isFalse(this._scrollBarY.visible);
		Assert.equals(0.0, this._container.minScrollX);
		Assert.equals(0.0, this._container.maxScrollX);
		Assert.equals(0.0, this._container.minScrollY);
		Assert.equals(0.0, this._container.maxScrollY);
	}

	public function testSmallerContainerWidthAndHeightThenSetLargerContainerWidthAndHeight():Void {
		var child = new LayoutGroup();
		child.width = 100.0;
		child.height = 75.0;
		this._container.addChild(child);
		this._container.width = 90.0;
		this._container.height = 60.0;
		this._container.validateNow();
		Assert.equals(90.0, this._container.width);
		Assert.equals(60.0, this._container.height);
		Assert.isTrue(this._scrollBarX.visible);
		Assert.isTrue(this._scrollBarY.visible);
		Assert.equals(0.0, this._container.minScrollX);
		Assert.equals(10.0 + this._scrollBarY.width, this._container.maxScrollX);
		Assert.equals(0.0, this._container.minScrollY);
		Assert.equals(15.0 + this._scrollBarX.height, this._container.maxScrollY);
		this._container.width = 110.0;
		this._container.height = 90.0;
		this._container.validateNow();
		Assert.equals(110.0, this._container.width);
		Assert.equals(90.0, this._container.height);
		Assert.isFalse(this._scrollBarX.visible);
		Assert.isFalse(this._scrollBarY.visible);
		Assert.equals(0.0, this._container.minScrollX);
		Assert.equals(0.0, this._container.maxScrollX);
		Assert.equals(0.0, this._container.minScrollY);
		Assert.equals(0.0, this._container.maxScrollY);
	}

	public function testSetSmallerChildWidthIncreasesChildHeight():Void {
		var child = new ResizingHeightBox();
		child.layoutData = HorizontalLayoutData.fillHorizontal();
		this._container.width = 200.0;
		this._container.layout = new HorizontalLayout();
		this._container.addChild(child);
		this._container.validateNow();
		Assert.equals(200.0, child.width);
		Assert.equals(150.0, child.height);
		Assert.equals(200.0, this._container.width);
		Assert.equals(150.0, this._container.height);
		Assert.isFalse(this._scrollBarX.visible);
		Assert.isFalse(this._scrollBarY.visible);
		Assert.equals(0.0, this._container.minScrollX);
		Assert.equals(0.0, this._container.maxScrollX);
		Assert.equals(0.0, this._container.minScrollY);
		Assert.equals(0.0, this._container.maxScrollY);
		this._container.height = 100.0;
		this._container.validateNow();
		Assert.equals(200.0 - this._scrollBarY.width, child.width);
		Assert.equals(1000.0, child.height);
		Assert.equals(200.0, this._container.width);
		Assert.equals(100.0, this._container.height);
		Assert.isFalse(this._scrollBarX.visible);
		Assert.isTrue(this._scrollBarY.visible);
		Assert.equals(0.0, this._container.minScrollX);
		Assert.equals(0.0, this._container.maxScrollX);
		Assert.equals(0.0, this._container.minScrollY);
		Assert.equals(900.0, this._container.maxScrollY);
	}

	public function testSetLargerChildWidthDecreasesChildHeight():Void {
		var child = new ResizingHeightBox();
		child.layoutData = HorizontalLayoutData.fillHorizontal();
		this._container.width = 200.0;
		this._container.height = 100.0;
		this._container.layout = new HorizontalLayout();
		this._container.addChild(child);
		this._container.validateNow();
		Assert.equals(200.0 - this._scrollBarY.width, child.width);
		Assert.equals(1000.0, child.height);
		Assert.equals(200.0, this._container.width);
		Assert.equals(100.0, this._container.height);
		Assert.isFalse(this._scrollBarX.visible);
		Assert.isTrue(this._scrollBarY.visible);
		Assert.equals(0.0, this._container.minScrollX);
		Assert.equals(0.0, this._container.maxScrollX);
		Assert.equals(0.0, this._container.minScrollY);
		Assert.equals(900.0, this._container.maxScrollY);
		this._container.resetHeight();
		this._container.validateNow();
		Assert.equals(200.0, child.width);
		Assert.equals(150.0, child.height);
		Assert.equals(200.0, this._container.width);
		Assert.equals(150.0, this._container.height);
		Assert.isFalse(this._scrollBarX.visible);
		Assert.isFalse(this._scrollBarY.visible);
		Assert.equals(0.0, this._container.minScrollX);
		Assert.equals(0.0, this._container.maxScrollX);
		Assert.equals(0.0, this._container.minScrollY);
		Assert.equals(0.0, this._container.maxScrollY);
	}

	public function testSetSmallerChildHeightIncreasesChildWidth():Void {
		var child = new ResizingWidthBox();
		child.layoutData = VerticalLayoutData.fillVertical();
		this._container.height = 200.0;
		this._container.layout = new VerticalLayout();
		this._container.addChild(child);
		this._container.validateNow();
		Assert.equals(150.0, child.width);
		Assert.equals(200.0, child.height);
		Assert.equals(150.0, this._container.width);
		Assert.equals(200.0, this._container.height);
		Assert.isFalse(this._scrollBarX.visible);
		Assert.isFalse(this._scrollBarY.visible);
		Assert.equals(0.0, this._container.minScrollX);
		Assert.equals(0.0, this._container.maxScrollX);
		Assert.equals(0.0, this._container.minScrollY);
		Assert.equals(0.0, this._container.maxScrollY);
		this._container.width = 100.0;
		this._container.validateNow();
		Assert.equals(1000.0, child.width);
		Assert.equals(200.0 - this._scrollBarX.height, child.height);
		Assert.equals(100.0, this._container.width);
		Assert.equals(200.0, this._container.height);
		Assert.isTrue(this._scrollBarX.visible);
		Assert.isFalse(this._scrollBarY.visible);
		Assert.equals(0.0, this._container.minScrollX);
		Assert.equals(900.0, this._container.maxScrollX);
		Assert.equals(0.0, this._container.minScrollY);
		Assert.equals(0.0, this._container.maxScrollY);
	}

	public function testSetLargerChildHeightDecreasesChildWidth():Void {
		var child = new ResizingWidthBox();
		child.layoutData = VerticalLayoutData.fillVertical();
		this._container.width = 100.0;
		this._container.height = 200.0;
		this._container.layout = new VerticalLayout();
		this._container.addChild(child);
		this._container.validateNow();
		Assert.equals(1000.0, child.width);
		Assert.equals(200.0 - this._scrollBarX.height, child.height);
		Assert.equals(100.0, this._container.width);
		Assert.equals(200.0, this._container.height);
		Assert.isTrue(this._scrollBarX.visible);
		Assert.isFalse(this._scrollBarY.visible);
		Assert.equals(0.0, this._container.minScrollX);
		Assert.equals(900.0, this._container.maxScrollX);
		Assert.equals(0.0, this._container.minScrollY);
		Assert.equals(0.0, this._container.maxScrollY);
		this._container.resetWidth();
		this._container.validateNow();
		Assert.equals(150.0, child.width);
		Assert.equals(200.0, child.height);
		Assert.equals(150.0, this._container.width);
		Assert.equals(200.0, this._container.height);
		Assert.isFalse(this._scrollBarX.visible);
		Assert.isFalse(this._scrollBarY.visible);
		Assert.equals(0.0, this._container.minScrollX);
		Assert.equals(0.0, this._container.maxScrollX);
		Assert.equals(0.0, this._container.minScrollY);
		Assert.equals(0.0, this._container.maxScrollY);
	}

	public function testLayoutDispatchingChangeTooOften():Void {
		this._container.width = 100.0;
		this._container.height = 100.0;
		this._container.layout = new LayoutThatDispatchesChangeTooOften();
		Assert.raises(() -> {
			this._container.validateNow();
		}, IllegalOperationError);
	}
}

private class ResizingHeightBox extends FeathersControl {
	public function new() {
		super();
	}

	override private function update():Void {
		super.update();
		var w = this.explicitWidth;
		if (w == null) {
			w = 200.0;
		}
		var h = 150.0;
		if (w != 200.0) {
			h = 1000.0;
		}
		this.saveMeasurements(w, h);
	}
}

private class ResizingWidthBox extends FeathersControl {
	public function new() {
		super();
	}

	override private function update():Void {
		super.update();
		var h = this.explicitHeight;
		if (h == null) {
			h = 200.0;
		}
		var w = 150.0;
		if (h != 200.0) {
			w = 1000.0;
		}
		this.saveMeasurements(w, h);
	}
}

class LayoutThatDispatchesChangeTooOften extends EventDispatcher implements ILayout {
	public function layout(items:Array<DisplayObject>, measurements:Measurements, ?result:LayoutBoundsResult):LayoutBoundsResult {
		if (result == null) {
			result = new LayoutBoundsResult();
		}
		this.dispatchEvent(new Event(Event.CHANGE));
		result.viewPortWidth = measurements.width;
		result.viewPortHeight = measurements.height;
		result.contentX = 0.0;
		result.contentY = 0.0;
		result.contentWidth = measurements.width;
		result.contentHeight = measurements.height;
		result.contentMinWidth = 0.0;
		result.contentMinHeight = 0.0;
		result.contentMaxWidth = Math.POSITIVE_INFINITY;
		result.contentMaxHeight = Math.POSITIVE_INFINITY;
		return result;
	}
}

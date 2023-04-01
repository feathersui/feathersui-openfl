/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.layout.VerticalLayoutData;
import feathers.layout.VerticalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.HorizontalLayout;
import feathers.core.FeathersControl;
import feathers.controls.VScrollBar;
import feathers.controls.HScrollBar;
import feathers.controls.LayoutGroup;
import openfl.Lib;
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
}

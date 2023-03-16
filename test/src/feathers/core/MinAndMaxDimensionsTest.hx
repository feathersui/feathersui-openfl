/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import feathers.controls.LayoutGroup;
import openfl.Lib;
import openfl.display.Shape;
import utest.Assert;
import utest.Test;

@:keep
class MinAndMaxDimensionsTest extends Test {
	private static final MIN_SIZE = 100.0;
	private static final EXPLICIT_SIZE_SMALLER_THAN_MIN_SIZE = 50.0;
	private static final MAX_SIZE = 150.0;
	private static final EXPLICIT_SIZE_LARGER_THAN_MAX_SIZE = 200.0;

	private var _control:LayoutGroup;

	public function new() {
		super();
	}

	public function setup():Void {
		this._control = new LayoutGroup();
		Lib.current.addChild(this._control);
	}

	public function teardown():Void {
		if (this._control.parent != null) {
			this._control.parent.removeChild(this._control);
		}
		this._control = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testMinWidth():Void {
		this._control.minWidth = MIN_SIZE;
		this._control.validateNow();
		Assert.equals(MIN_SIZE, this._control.width, "The calculated width of the component must not be smaller than the minWidth");
	}

	public function testExplicitWidthAndMinWidth():Void {
		this._control.minWidth = MIN_SIZE;
		this._control.width = EXPLICIT_SIZE_SMALLER_THAN_MIN_SIZE;
		this._control.validateNow();
		Assert.equals(EXPLICIT_SIZE_SMALLER_THAN_MIN_SIZE, this._control.width, "The minWidth of a component must be ignored if the width is set explicitly");
	}

	public function testMinHeight():Void {
		this._control.minHeight = MIN_SIZE;
		this._control.validateNow();
		Assert.equals(MIN_SIZE, this._control.height, "The calculated height of the component must not be smaller than the minHeight");
	}

	public function testExplicitHeightAndMinHeight():Void {
		this._control.minHeight = MIN_SIZE;
		this._control.height = EXPLICIT_SIZE_SMALLER_THAN_MIN_SIZE;
		this._control.validateNow();
		Assert.equals(EXPLICIT_SIZE_SMALLER_THAN_MIN_SIZE, this._control.height,
			"The minHeight of a component must be ignored if the height is set explicitly");
	}

	public function testMaxWidth():Void {
		var child = new Shape();
		child.graphics.beginFill(0xff00ff);
		child.graphics.drawRect(0, 0, EXPLICIT_SIZE_LARGER_THAN_MAX_SIZE, EXPLICIT_SIZE_LARGER_THAN_MAX_SIZE);
		child.graphics.endFill();
		this._control.addChild(child);

		this._control.maxWidth = MAX_SIZE;
		this._control.validateNow();
		Assert.equals(MAX_SIZE, this._control.width, "The calculated width of the component must not be larger than the maxWidth");
	}

	public function testExplicitWidthAndMaxWidth():Void {
		this._control.maxWidth = MAX_SIZE;
		this._control.width = EXPLICIT_SIZE_LARGER_THAN_MAX_SIZE;
		this._control.validateNow();
		Assert.equals(EXPLICIT_SIZE_LARGER_THAN_MAX_SIZE, this._control.width, "The maxWidth of a component must be ignored if the width is set explicitly");
	}

	public function testMaxHeight():Void {
		var child = new Shape();
		child.graphics.beginFill(0xff00ff);
		child.graphics.drawRect(0, 0, EXPLICIT_SIZE_LARGER_THAN_MAX_SIZE, EXPLICIT_SIZE_LARGER_THAN_MAX_SIZE);
		child.graphics.endFill();
		this._control.addChild(child);

		this._control.maxHeight = MAX_SIZE;
		this._control.validateNow();
		Assert.equals(MAX_SIZE, this._control.height, "The calculated height of the component must not be larger than the maxHeight");
	}

	public function testExplicitHeightAndMaxHeight():Void {
		this._control.maxHeight = MAX_SIZE;
		this._control.height = EXPLICIT_SIZE_LARGER_THAN_MAX_SIZE;
		this._control.validateNow();
		Assert.equals(EXPLICIT_SIZE_LARGER_THAN_MAX_SIZE, this._control.height,
			"The maxHeight of a component must be ignored if the height is set explicitly");
	}

	public function testNoInvalidationWhenSettingMinWidthWithExplicitWidth():Void {
		this._control.width = EXPLICIT_SIZE_SMALLER_THAN_MIN_SIZE;
		this._control.validateNow();
		this._control.minWidth = MIN_SIZE;
		Assert.isFalse(this._control.isInvalid(), "The component incorrectly invalidated when setting minWidth, but component has explicitWidth");
	}

	public function testNoInvalidationWhenSettingMinHeightWithExplicitHeight():Void {
		this._control.height = EXPLICIT_SIZE_SMALLER_THAN_MIN_SIZE;
		this._control.validateNow();
		this._control.minHeight = MIN_SIZE;
		Assert.isFalse(this._control.isInvalid(), "The component incorrectly invalidated when setting minHeight, but component has explicitHeight");
	}

	public function testNoInvalidationWhenSettingMinWidthWithLargerActualWidth():Void {
		var child = new Shape();
		child.graphics.beginFill(0xff00ff);
		child.graphics.drawRect(0, 0, EXPLICIT_SIZE_LARGER_THAN_MAX_SIZE, EXPLICIT_SIZE_LARGER_THAN_MAX_SIZE);
		child.graphics.endFill();
		this._control.addChild(child);
		this._control.validateNow();
		this._control.minWidth = MIN_SIZE;
		Assert.isFalse(this._control.isInvalid(),
			"The component incorrectly invalidated when setting minWidth, but component actualWidth is currently larger");
	}

	public function testNoInvalidationWhenSettingMinHeightWithLargerActualHeight():Void {
		var child = new Shape();
		child.graphics.beginFill(0xff00ff);
		child.graphics.drawRect(0, 0, EXPLICIT_SIZE_LARGER_THAN_MAX_SIZE, EXPLICIT_SIZE_LARGER_THAN_MAX_SIZE);
		child.graphics.endFill();
		this._control.addChild(child);
		this._control.validateNow();
		this._control.minHeight = MIN_SIZE;
		Assert.isFalse(this._control.isInvalid(),
			"The component incorrectly invalidated when setting minHeight, but component actualHeight is currently larger");
	}

	public function testNoInvalidationWhenSettingMinWidthEqualToActualWidth():Void {
		var child = new Shape();
		child.graphics.beginFill(0xff00ff);
		child.graphics.drawRect(0, 0, MIN_SIZE, MIN_SIZE);
		child.graphics.endFill();
		this._control.addChild(child);
		this._control.validateNow();
		this._control.minWidth = MIN_SIZE;
		Assert.isFalse(this._control.isInvalid(), "The component incorrectly invalidated when setting minWidth, but component actualWidth is equal");
	}

	public function testNoInvalidationWhenSettingMinHeightEqualToActualHeight():Void {
		var child = new Shape();
		child.graphics.beginFill(0xff00ff);
		child.graphics.drawRect(0, 0, MIN_SIZE, MIN_SIZE);
		child.graphics.endFill();
		this._control.addChild(child);
		this._control.validateNow();
		this._control.minHeight = MIN_SIZE;
		Assert.isFalse(this._control.isInvalid(), "The component incorrectly invalidated when setting minHeight, but component actualHeight is equal");
	}

	public function testNoInvalidationWhenSettingMaxWidthWithExplicitWidth():Void {
		this._control.width = EXPLICIT_SIZE_LARGER_THAN_MAX_SIZE;
		this._control.validateNow();
		this._control.maxWidth = MAX_SIZE;
		Assert.isFalse(this._control.isInvalid(), "The component incorrectly invalidated when setting maxWidth, but component has explicitWidth");
	}

	public function testNoInvalidationWhenSettingMaxHeightWithExplicitHeight():Void {
		this._control.height = EXPLICIT_SIZE_LARGER_THAN_MAX_SIZE;
		this._control.validateNow();
		this._control.maxHeight = MAX_SIZE;
		Assert.isFalse(this._control.isInvalid(), "The component incorrectly invalidated when setting maxHeight, but component has explicitHeight");
	}

	public function testNoInvalidationWhenSettingMaxWidthWithSmallerActualWidth():Void {
		var child = new Shape();
		child.graphics.beginFill(0xff00ff);
		child.graphics.drawRect(0, 0, EXPLICIT_SIZE_SMALLER_THAN_MIN_SIZE, EXPLICIT_SIZE_SMALLER_THAN_MIN_SIZE);
		child.graphics.endFill();
		this._control.addChild(child);
		this._control.validateNow();
		this._control.maxWidth = MAX_SIZE;
		Assert.isFalse(this._control.isInvalid(),
			"The component incorrectly invalidated when setting maxWidth, but component actualWidth is currently smaller");
	}

	public function testNoInvalidationWhenSettingMaxHeightWithSmallerActualHeight():Void {
		var child = new Shape();
		child.graphics.beginFill(0xff00ff);
		child.graphics.drawRect(0, 0, EXPLICIT_SIZE_SMALLER_THAN_MIN_SIZE, EXPLICIT_SIZE_SMALLER_THAN_MIN_SIZE);
		child.graphics.endFill();
		this._control.addChild(child);
		this._control.validateNow();
		this._control.maxHeight = MAX_SIZE;
		Assert.isFalse(this._control.isInvalid(),
			"The component incorrectly invalidated when setting maxHeight, but component actualHeight is currently smaller");
	}

	public function testNoInvalidationWhenSettingMaxWidthEqualToActualWidth():Void {
		var child = new Shape();
		child.graphics.beginFill(0xff00ff);
		child.graphics.drawRect(0, 0, MAX_SIZE, MAX_SIZE);
		child.graphics.endFill();
		this._control.addChild(child);
		this._control.validateNow();
		this._control.maxWidth = MAX_SIZE;
		Assert.isFalse(this._control.isInvalid(), "The component incorrectly invalidated when setting maxWidth, but component actualWidth is equal");
	}

	public function testNoInvalidationWhenSettingMaxHeightEqualToActualHeight():Void {
		var child = new Shape();
		child.graphics.beginFill(0xff00ff);
		child.graphics.drawRect(0, 0, MAX_SIZE, MAX_SIZE);
		child.graphics.endFill();
		this._control.addChild(child);
		this._control.validateNow();
		this._control.maxHeight = MAX_SIZE;
		Assert.isFalse(this._control.isInvalid(), "The component incorrectly invalidated when setting maxHeight, but component actualHeight is equal");
	}

	public function testInvalidAfterSettingMinWidthLargerThanActualWidth():Void {
		var child = new Shape();
		child.graphics.beginFill(0xff00ff);
		child.graphics.drawRect(0, 0, 40, 50);
		child.graphics.endFill();
		this._control.addChild(child);
		this._control.validateNow();
		this._control.minWidth = 183;
		Assert.isTrue(this._control.isInvalid(), "The component failed to set invalidate flag after setting minWidth larger than actualWidth");
	}

	public function testInvalidAfterSettingMinHeightLargerThanActualHeight():Void {
		var child = new Shape();
		child.graphics.beginFill(0xff00ff);
		child.graphics.drawRect(0, 0, 40, 50);
		child.graphics.endFill();
		this._control.addChild(child);
		this._control.validateNow();
		this._control.minHeight = 183;
		Assert.isTrue(this._control.isInvalid(), "The component failed to set invalidate flag after setting minHeight larger than actualHeight");
	}

	public function testInvalidAfterSettingMaxWidthSmallerThanActualWidth():Void {
		var child = new Shape();
		child.graphics.beginFill(0xff00ff);
		child.graphics.drawRect(0, 0, 40, 50);
		child.graphics.endFill();
		this._control.addChild(child);
		this._control.validateNow();
		this._control.maxWidth = 30;
		Assert.isTrue(this._control.isInvalid(), "The component failed to set invalidate flag after setting maxWidth smaller than actualWidth");
	}

	public function testInvalidAfterSettingMaxHeightSmallerThanActualHeight():Void {
		var child = new Shape();
		child.graphics.beginFill(0xff00ff);
		child.graphics.drawRect(0, 0, 40, 50);
		child.graphics.endFill();
		this._control.addChild(child);
		this._control.validateNow();
		this._control.maxHeight = 45;
		Assert.isTrue(this._control.isInvalid(), "The component failed to set invalidate flag after setting maxHeight smaller than actualHeight");
	}
}

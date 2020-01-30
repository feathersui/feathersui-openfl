/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import openfl.display.Shape;
import feathers.controls.LayoutGroup;
import massive.munit.Assert;

@:keep
class MinAndMaxDimensionsTest {
	private static final MIN_SIZE = 100.0;
	private static final EXPLICIT_SIZE_SMALLER_THAN_MIN_SIZE = 50.0;
	private static final MAX_SIZE = 150.0;
	private static final EXPLICIT_SIZE_LARGER_THAN_MAX_SIZE = 200.0;

	private var _control:LayoutGroup;

	@Before
	public function prepare():Void {
		this._control = new LayoutGroup();
		TestMain.openfl_root.addChild(this._control);
	}

	@After
	public function cleanup():Void {
		if (this._control.parent != null) {
			this._control.parent.removeChild(this._control);
		}
		this._control = null;
		Assert.areEqual(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
	}

	@Test
	public function testMinWidth():Void {
		this._control.minWidth = MIN_SIZE;
		this._control.validateNow();
		Assert.areEqual(MIN_SIZE, this._control.width, "The calculated width of the component must not be smaller than the minWidth");
	}

	@Test
	public function testExplicitWidthAndMinWidth():Void {
		this._control.minWidth = MIN_SIZE;
		this._control.width = EXPLICIT_SIZE_SMALLER_THAN_MIN_SIZE;
		this._control.validateNow();
		Assert.areEqual(EXPLICIT_SIZE_SMALLER_THAN_MIN_SIZE, this._control.width,
			"The minWidth of a component must be ignored if the width is set explicitly");
	}

	@Test
	public function testMinHeight():Void {
		this._control.minHeight = MIN_SIZE;
		this._control.validateNow();
		Assert.areEqual(MIN_SIZE, this._control.height, "The calculated height of the component must not be smaller than the minHeight");
	}

	@Test
	public function testExplicitHeightAndMinHeight():Void {
		this._control.minHeight = MIN_SIZE;
		this._control.height = EXPLICIT_SIZE_SMALLER_THAN_MIN_SIZE;
		this._control.validateNow();
		Assert.areEqual(EXPLICIT_SIZE_SMALLER_THAN_MIN_SIZE, this._control.height,
			"The minHeight of a component must be ignored if the height is set explicitly");
	}

	@Test
	public function testMaxWidth():Void {
		var child = new Shape();
		child.graphics.beginFill(0xff00ff);
		child.graphics.drawRect(0, 0, EXPLICIT_SIZE_LARGER_THAN_MAX_SIZE, EXPLICIT_SIZE_LARGER_THAN_MAX_SIZE);
		child.graphics.endFill();
		this._control.addChild(child);

		this._control.maxWidth = MAX_SIZE;
		this._control.validateNow();
		Assert.areEqual(MAX_SIZE, this._control.width, "The calculated width of the component must not be larger than the maxWidth");
	}

	@Test
	public function testExplicitWidthAndMaxWidth():Void {
		this._control.maxWidth = MAX_SIZE;
		this._control.width = EXPLICIT_SIZE_LARGER_THAN_MAX_SIZE;
		this._control.validateNow();
		Assert.areEqual(EXPLICIT_SIZE_LARGER_THAN_MAX_SIZE, this._control.width, "The maxWidth of a component must be ignored if the width is set explicitly");
	}

	@Test
	public function testMaxHeight():Void {
		var child = new Shape();
		child.graphics.beginFill(0xff00ff);
		child.graphics.drawRect(0, 0, EXPLICIT_SIZE_LARGER_THAN_MAX_SIZE, EXPLICIT_SIZE_LARGER_THAN_MAX_SIZE);
		child.graphics.endFill();
		this._control.addChild(child);

		this._control.maxHeight = MAX_SIZE;
		this._control.validateNow();
		Assert.areEqual(MAX_SIZE, this._control.height, "The calculated height of the component must not be larger than the maxHeight");
	}

	@Test
	public function testExplicitHeightAndMaxHeight():Void {
		this._control.maxHeight = MAX_SIZE;
		this._control.height = EXPLICIT_SIZE_LARGER_THAN_MAX_SIZE;
		this._control.validateNow();
		Assert.areEqual(EXPLICIT_SIZE_LARGER_THAN_MAX_SIZE, this._control.height,
			"The maxHeight of a component must be ignored if the height is set explicitly");
	}

	@Test
	public function testNoInvalidationWhenSettingMinWidthWithExplicitWidth():Void {
		this._control.width = EXPLICIT_SIZE_SMALLER_THAN_MIN_SIZE;
		this._control.validateNow();
		this._control.minWidth = MIN_SIZE;
		Assert.isFalse(this._control.isInvalid(), "The component incorrectly invalidated when setting minWidth, but component has explicitWidth");
	}

	@Test
	public function testNoInvalidationWhenSettingMinHeightWithExplicitHeight():Void {
		this._control.height = EXPLICIT_SIZE_SMALLER_THAN_MIN_SIZE;
		this._control.validateNow();
		this._control.minHeight = MIN_SIZE;
		Assert.isFalse(this._control.isInvalid(), "The component incorrectly invalidated when setting minHeight, but component has explicitHeight");
	}

	@Test
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

	@Test
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

	@Test
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

	@Test
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

	@Test
	public function testNoInvalidationWhenSettingMaxWidthWithExplicitWidth():Void {
		this._control.width = EXPLICIT_SIZE_LARGER_THAN_MAX_SIZE;
		this._control.validateNow();
		this._control.maxWidth = MAX_SIZE;
		Assert.isFalse(this._control.isInvalid(), "The component incorrectly invalidated when setting maxWidth, but component has explicitWidth");
	}

	@Test
	public function testNoInvalidationWhenSettingMaxHeightWithExplicitHeight():Void {
		this._control.height = EXPLICIT_SIZE_LARGER_THAN_MAX_SIZE;
		this._control.validateNow();
		this._control.maxHeight = MAX_SIZE;
		Assert.isFalse(this._control.isInvalid(), "The component incorrectly invalidated when setting maxHeight, but component has explicitHeight");
	}

	@Test
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

	@Test
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

	@Test
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

	@Test
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

	@Test
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

	@Test
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

	@Test
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

	@Test
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

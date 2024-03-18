/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import openfl.Lib;
import utest.Assert;
import utest.Test;

@:keep
class VDividedBoxTest extends Test {
	private static final CHILD1_WIDTH = 200.0;
	private static final CHILD1_HEIGHT = 100.0;
	private static final CHILD2_WIDTH = 150.0;
	private static final CHILD2_HEIGHT = 75.0;
	private static final CHILD3_WIDTH = 75.0;
	private static final CHILD3_HEIGHT = 50.0;
	private static final DIVIDER_SIZE = 10.0;

	private var _dividedBox:VDividedBox;

	private var _control1:LayoutGroup;
	private var _control2:LayoutGroup;
	private var _control3:LayoutGroup;

	public function new() {
		super();
	}

	public function setup():Void {
		this._dividedBox = new VDividedBox();
		this._dividedBox.dividerFactory = () -> {
			var divider = new LayoutGroup();
			divider.width = DIVIDER_SIZE;
			divider.height = DIVIDER_SIZE;
			return divider;
		}
		Lib.current.addChild(this._dividedBox);

		this._control1 = new LayoutGroup();
		this._control2 = new LayoutGroup();
		this._control3 = new LayoutGroup();
	}

	public function teardown():Void {
		if (this._dividedBox.parent != null) {
			this._dividedBox.parent.removeChild(this._dividedBox);
		}
		this._dividedBox = null;
		this._control1 = null;
		this._control2 = null;
		this._control3 = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testValidateWithNoChildren():Void {
		this._dividedBox.validateNow();
		Assert.pass();
	}

	public function testNoExceptionOnDoubleDispose():Void {
		this._dividedBox.validateNow();
		this._dividedBox.dispose();
		this._dividedBox.dispose();
		Assert.pass();
	}

	public function testOneChild():Void {
		this._control1.width = CHILD1_WIDTH;
		this._control1.height = CHILD1_HEIGHT;
		this._dividedBox.addChild(this._control1);
		this._dividedBox.validateNow();
		Assert.equals(CHILD1_WIDTH, this._dividedBox.width);
		Assert.equals(CHILD1_HEIGHT, this._dividedBox.height);
	}

	public function testTwoChildren():Void {
		this._control1.width = CHILD1_WIDTH;
		this._control1.height = CHILD1_HEIGHT;
		this._dividedBox.addChild(this._control1);
		this._control2.width = CHILD2_WIDTH;
		this._control2.height = CHILD2_HEIGHT;
		this._dividedBox.addChild(this._control2);
		this._dividedBox.validateNow();
		Assert.equals(Math.max(CHILD1_WIDTH, CHILD2_WIDTH), this._dividedBox.width);
		Assert.equals(CHILD1_HEIGHT + DIVIDER_SIZE + CHILD2_HEIGHT, this._dividedBox.height);
	}

	public function testThreeChildren():Void {
		this._control1.width = CHILD1_WIDTH;
		this._control1.height = CHILD1_HEIGHT;
		this._dividedBox.addChild(this._control1);
		this._control2.width = CHILD2_WIDTH;
		this._control2.height = CHILD2_HEIGHT;
		this._dividedBox.addChild(this._control2);
		this._control3.width = CHILD3_WIDTH;
		this._control3.height = CHILD3_HEIGHT;
		this._dividedBox.addChild(this._control3);
		this._dividedBox.validateNow();
		Assert.equals(Math.max(Math.max(CHILD1_WIDTH, CHILD2_WIDTH), CHILD3_WIDTH), this._dividedBox.width);
		Assert.equals(CHILD1_HEIGHT + DIVIDER_SIZE + CHILD2_HEIGHT + DIVIDER_SIZE + CHILD3_HEIGHT, this._dividedBox.height);
	}

	public function testThreeChildrenIncludeInLayoutFalseOnFirstChild():Void {
		this._control1.width = CHILD1_WIDTH;
		this._control1.height = CHILD1_HEIGHT;
		this._control1.includeInLayout = false;
		this._dividedBox.addChild(this._control1);
		this._control2.width = CHILD2_WIDTH;
		this._control2.height = CHILD2_HEIGHT;
		this._dividedBox.addChild(this._control2);
		this._control3.width = CHILD3_WIDTH;
		this._control3.height = CHILD3_HEIGHT;
		this._dividedBox.addChild(this._control3);
		this._dividedBox.validateNow();
		Assert.equals(Math.max(CHILD2_WIDTH, CHILD3_WIDTH), this._dividedBox.width);
		Assert.equals(CHILD2_HEIGHT + DIVIDER_SIZE + CHILD3_HEIGHT, this._dividedBox.height);
	}

	public function testThreeChildrenIncludeInLayoutFalseOnMiddleChild():Void {
		this._control1.width = CHILD1_WIDTH;
		this._control1.height = CHILD1_HEIGHT;
		this._dividedBox.addChild(this._control1);
		this._control2.width = CHILD2_WIDTH;
		this._control2.height = CHILD2_HEIGHT;
		this._control2.includeInLayout = false;
		this._dividedBox.addChild(this._control2);
		this._control3.width = CHILD3_WIDTH;
		this._control3.height = CHILD3_HEIGHT;
		this._dividedBox.addChild(this._control3);
		this._dividedBox.validateNow();
		Assert.equals(Math.max(CHILD1_WIDTH, CHILD3_WIDTH), this._dividedBox.width);
		Assert.equals(CHILD1_HEIGHT + DIVIDER_SIZE + CHILD3_HEIGHT, this._dividedBox.height);
	}

	public function testThreeChildrenIncludeInLayoutFalseOnLastChild():Void {
		this._control1.width = CHILD1_WIDTH;
		this._control1.height = CHILD1_HEIGHT;
		this._dividedBox.addChild(this._control1);
		this._control2.width = CHILD2_WIDTH;
		this._control2.height = CHILD2_HEIGHT;
		this._dividedBox.addChild(this._control2);
		this._control3.width = CHILD3_WIDTH;
		this._control3.height = CHILD3_HEIGHT;
		this._control3.includeInLayout = false;
		this._dividedBox.addChild(this._control3);
		this._dividedBox.validateNow();
		Assert.equals(Math.max(CHILD1_WIDTH, CHILD2_WIDTH), this._dividedBox.width);
		Assert.equals(CHILD1_HEIGHT + DIVIDER_SIZE + CHILD2_HEIGHT, this._dividedBox.height);
	}

	public function testThreeChildrenIncludeInLayoutFalseOnFirstChildAfterValidate():Void {
		this._control1.width = CHILD1_WIDTH;
		this._control1.height = CHILD1_HEIGHT;
		this._dividedBox.addChild(this._control1);
		this._control2.width = CHILD2_WIDTH;
		this._control2.height = CHILD2_HEIGHT;
		this._dividedBox.addChild(this._control2);
		this._control3.width = CHILD3_WIDTH;
		this._control3.height = CHILD3_HEIGHT;
		this._dividedBox.addChild(this._control3);
		this._dividedBox.validateNow();
		this._control1.includeInLayout = false;
		this._dividedBox.validateNow();
		// width will not get reset on other children after removing the
		// largest child, if the largest child was included at least once.
		// this is not a bug. just a limitation of how layouts work.
		Assert.equals(Math.max(Math.max(CHILD1_WIDTH, CHILD2_WIDTH), CHILD3_WIDTH), this._dividedBox.width);
		Assert.equals(CHILD2_HEIGHT + DIVIDER_SIZE + CHILD3_HEIGHT, this._dividedBox.height);
	}

	public function testThreeChildrenIncludeInLayoutFalseOnMiddleChildAfterValidate():Void {
		this._control1.width = CHILD1_WIDTH;
		this._control1.height = CHILD1_HEIGHT;
		this._dividedBox.addChild(this._control1);
		this._control2.width = CHILD2_WIDTH;
		this._control2.height = CHILD2_HEIGHT;
		this._dividedBox.addChild(this._control2);
		this._control3.width = CHILD3_WIDTH;
		this._control3.height = CHILD3_HEIGHT;
		this._dividedBox.addChild(this._control3);
		this._dividedBox.validateNow();
		this._control2.includeInLayout = false;
		this._dividedBox.validateNow();
		// width will not get reset on other children after removing the
		// largest child, if the largest child was included at least once.
		// this is not a bug. just a limitation of how layouts work.
		Assert.equals(Math.max(Math.max(CHILD1_WIDTH, CHILD2_WIDTH), CHILD3_WIDTH), this._dividedBox.width);
		Assert.equals(CHILD1_HEIGHT + DIVIDER_SIZE + CHILD3_HEIGHT, this._dividedBox.height);
	}

	public function testThreeChildrenIncludeInLayoutFalseOnLastChildAfterValidate():Void {
		this._control1.width = CHILD1_WIDTH;
		this._control1.height = CHILD1_HEIGHT;
		this._dividedBox.addChild(this._control1);
		this._control2.width = CHILD2_WIDTH;
		this._control2.height = CHILD2_HEIGHT;
		this._dividedBox.addChild(this._control2);
		this._control3.width = CHILD3_WIDTH;
		this._control3.height = CHILD3_HEIGHT;
		this._dividedBox.addChild(this._control3);
		this._dividedBox.validateNow();
		this._control3.includeInLayout = false;
		this._dividedBox.validateNow();
		// width will not get reset on other children after removing the
		// largest child, if the largest child was included at least once.
		// this is not a bug. just a limitation of how layouts work.
		Assert.equals(Math.max(Math.max(CHILD1_WIDTH, CHILD2_WIDTH), CHILD3_WIDTH), this._dividedBox.width);
		Assert.equals(CHILD1_HEIGHT + DIVIDER_SIZE + CHILD2_HEIGHT, this._dividedBox.height);
	}
}

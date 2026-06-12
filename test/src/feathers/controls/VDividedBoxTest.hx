/*
	Feathers UI
	Copyright 2026 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import openfl.Lib;
import openfl.display.InteractiveObject;
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
		this._dividedBox.dividerFactory = function():InteractiveObject {
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
		Assert.equals(1, this._dividedBox.numChildren);
		Assert.equals(this._control1, this._dividedBox.getChildAt(0));
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
		Assert.equals(2, this._dividedBox.numChildren);
		Assert.equals(this._control1, this._dividedBox.getChildAt(0));
		Assert.equals(this._control2, this._dividedBox.getChildAt(1));
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
		Assert.equals(3, this._dividedBox.numChildren);
		Assert.equals(this._control1, this._dividedBox.getChildAt(0));
		Assert.equals(this._control2, this._dividedBox.getChildAt(1));
		Assert.equals(this._control3, this._dividedBox.getChildAt(2));
	}

	public function testRemoveChild():Void {
		this._dividedBox.addChild(this._control1);
		this._dividedBox.addChild(this._control2);
		this._dividedBox.addChild(this._control3);
		Assert.equals(this._control1, this._dividedBox.getChildAt(0));
		Assert.equals(this._control2, this._dividedBox.getChildAt(1));
		Assert.equals(this._control3, this._dividedBox.getChildAt(2));
		this._dividedBox.removeChild(this._control2);
		Assert.equals(2, this._dividedBox.numChildren);
		Assert.equals(this._control1, this._dividedBox.getChildAt(0));
		Assert.equals(this._control3, this._dividedBox.getChildAt(1));
		this._dividedBox.removeChild(this._control1);
		Assert.equals(1, this._dividedBox.numChildren);
		Assert.equals(this._control3, this._dividedBox.getChildAt(0));
		this._dividedBox.removeChild(this._control3);
		Assert.equals(0, this._dividedBox.numChildren);
	}

	public function testRemoveChildAt():Void {
		this._dividedBox.addChild(this._control1);
		this._dividedBox.addChild(this._control2);
		this._dividedBox.addChild(this._control3);
		Assert.equals(this._control1, this._dividedBox.getChildAt(0));
		Assert.equals(this._control2, this._dividedBox.getChildAt(1));
		Assert.equals(this._control3, this._dividedBox.getChildAt(2));
		this._dividedBox.removeChildAt(1);
		Assert.equals(2, this._dividedBox.numChildren);
		Assert.equals(this._control1, this._dividedBox.getChildAt(0));
		Assert.equals(this._control3, this._dividedBox.getChildAt(1));
		this._dividedBox.removeChildAt(0);
		Assert.equals(1, this._dividedBox.numChildren);
		Assert.equals(this._control3, this._dividedBox.getChildAt(0));
		this._dividedBox.removeChildAt(0);
		Assert.equals(0, this._dividedBox.numChildren);
	}

	public function testRemoveChildren():Void {
		this._dividedBox.addChild(this._control1);
		this._dividedBox.addChild(this._control2);
		this._dividedBox.addChild(this._control3);
		Assert.equals(this._control1, this._dividedBox.getChildAt(0));
		Assert.equals(this._control2, this._dividedBox.getChildAt(1));
		Assert.equals(this._control3, this._dividedBox.getChildAt(2));
		this._dividedBox.removeChildren();
		Assert.equals(0, this._dividedBox.numChildren);
		this._dividedBox.addChild(this._control1);
		this._dividedBox.addChild(this._control2);
		this._dividedBox.addChild(this._control3);
		this._dividedBox.removeChildren(0, 1);
		Assert.equals(1, this._dividedBox.numChildren);
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

	// children may sometimes be removed without calling our overrides of
	// removeChild() or removeChildAt(), so this test ensures that we have
	// properly detected the automatic removal by listening for Event.REMOVED
	// and updating the container's internal state
	public function testAddChildToADifferentParent():Void {
		var child1 = new LayoutGroup();
		this._dividedBox.addChild(child1);
		Assert.equals(this._dividedBox, child1.parent);
		Assert.equals(1, this._dividedBox.numChildren);
		Assert.equals(0, this._dividedBox.getChildIndex(child1));
		var otherContainer = new VDividedBox();
		Lib.current.addChild(otherContainer);
		otherContainer.addChild(child1);
		Assert.equals(otherContainer, child1.parent);
		Assert.equals(0, this._dividedBox.numChildren);
		Assert.equals(-1, this._dividedBox.getChildIndex(child1));
		Lib.current.removeChild(otherContainer);
	}
}

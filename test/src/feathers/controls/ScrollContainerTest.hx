/*
	Feathers UI
	Copyright 2026 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.skins.RectangleSkin;
import openfl.Lib;
import openfl.display.Shape;
import openfl.display.Sprite;
import utest.Assert;
import utest.Test;

@:keep
class ScrollContainerTest extends Test {
	private static final CHILD1_WIDTH = 200.0;
	private static final CHILD1_HEIGHT = 75.0;
	private static final CHILD2_WIDTH = 150.0;
	private static final CHILD2_HEIGHT = 100.0;
	private static final CHILD3_WIDTH = 75.0;
	private static final CHILD3_HEIGHT = 50.0;

	private var _container:ScrollContainer;

	private var _control1:LayoutGroup;
	private var _control2:LayoutGroup;
	private var _control3:LayoutGroup;

	public function new() {
		super();
	}

	public function setup():Void {
		this._container = new ScrollContainer();
		Lib.current.addChild(this._container);

		this._control1 = new LayoutGroup();
		this._control2 = new LayoutGroup();
		this._control3 = new LayoutGroup();
	}

	public function teardown():Void {
		if (this._container.parent != null) {
			this._container.parent.removeChild(this._container);
		}
		this._container = null;
		this._control1 = null;
		this._control2 = null;
		this._control3 = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testNoExceptionOnDoubleDispose():Void {
		this._container.validateNow();
		this._container.dispose();
		this._container.dispose();
		Assert.pass();
	}

	public function testRemoveSkinAfterSetToNewValue():Void {
		var skin1 = new Shape();
		var skin2 = new Shape();
		Assert.isNull(skin1.parent);
		Assert.isNull(skin2.parent);
		this._container.backgroundSkin = skin1;
		this._container.validateNow();
		Assert.equals(this._container, skin1.parent);
		Assert.isNull(skin2.parent);
		this._container.backgroundSkin = skin2;
		this._container.validateNow();
		Assert.isNull(skin1.parent);
		Assert.equals(this._container, skin2.parent);
	}

	public function testRemoveSkinAfterSetToNull():Void {
		var skin = new Shape();
		Assert.isNull(skin.parent);
		this._container.backgroundSkin = skin;
		this._container.validateNow();
		Assert.equals(this._container, skin.parent);
		this._container.backgroundSkin = null;
		this._container.validateNow();
		Assert.isNull(skin.parent);
	}

	public function testRemoveSkinAfterDisable():Void {
		var skin1 = new Shape();
		var skin2 = new Shape();
		Assert.isNull(skin1.parent);
		Assert.isNull(skin2.parent);
		this._container.backgroundSkin = skin1;
		this._container.disabledBackgroundSkin = skin2;
		this._container.validateNow();
		Assert.equals(this._container, skin1.parent);
		Assert.isNull(skin2.parent);
		this._container.enabled = false;
		this._container.validateNow();
		Assert.isNull(skin1.parent);
		Assert.equals(this._container, skin2.parent);
	}

	public function testOneChild():Void {
		this._control1.width = CHILD1_WIDTH;
		this._control1.height = CHILD1_HEIGHT;
		this._container.addChild(this._control1);
		this._container.validateNow();
		Assert.equals(CHILD1_WIDTH, this._container.width);
		Assert.equals(CHILD1_HEIGHT, this._container.height);
		Assert.equals(1, this._container.numChildren);
		Assert.equals(this._control1, this._container.getChildAt(0));
	}

	public function testTwoChildren():Void {
		this._control1.width = CHILD1_WIDTH;
		this._control1.height = CHILD1_HEIGHT;
		this._container.addChild(this._control1);
		this._control2.width = CHILD2_WIDTH;
		this._control2.height = CHILD2_HEIGHT;
		this._container.addChild(this._control2);
		this._container.validateNow();
		Assert.equals(Math.max(CHILD1_WIDTH, CHILD2_WIDTH), this._container.width);
		Assert.equals(Math.max(CHILD1_HEIGHT, CHILD2_HEIGHT), this._container.height);
		Assert.equals(2, this._container.numChildren);
		Assert.equals(this._control1, this._container.getChildAt(0));
		Assert.equals(this._control2, this._container.getChildAt(1));
	}

	public function testAddChildAt():Void {
		this._control1.width = CHILD1_WIDTH;
		this._control1.height = CHILD1_HEIGHT;
		this._container.addChild(this._control1);
		this._control2.width = CHILD2_WIDTH;
		this._control2.height = CHILD2_HEIGHT;
		this._container.addChildAt(this._control2, 0);
		this._container.validateNow();
		Assert.equals(Math.max(CHILD1_WIDTH, CHILD2_WIDTH), this._container.width);
		Assert.equals(Math.max(CHILD1_HEIGHT, CHILD2_HEIGHT), this._container.height);
		Assert.equals(2, this._container.numChildren);
		Assert.equals(this._control2, this._container.getChildAt(0));
		Assert.equals(this._control1, this._container.getChildAt(1));
	}

	public function testRemoveChild():Void {
		this._container.addChild(this._control1);
		this._container.addChild(this._control2);
		this._container.addChild(this._control3);
		Assert.equals(this._control1, this._container.getChildAt(0));
		Assert.equals(this._control2, this._container.getChildAt(1));
		Assert.equals(this._control3, this._container.getChildAt(2));
		this._container.removeChild(this._control2);
		Assert.equals(2, this._container.numChildren);
		Assert.equals(this._control1, this._container.getChildAt(0));
		Assert.equals(this._control3, this._container.getChildAt(1));
		this._container.removeChild(this._control1);
		Assert.equals(1, this._container.numChildren);
		Assert.equals(this._control3, this._container.getChildAt(0));
		this._container.removeChild(this._control3);
		Assert.equals(0, this._container.numChildren);
	}

	public function testRemoveChildAt():Void {
		this._container.addChild(this._control1);
		this._container.addChild(this._control2);
		this._container.addChild(this._control3);
		Assert.equals(this._control1, this._container.getChildAt(0));
		Assert.equals(this._control2, this._container.getChildAt(1));
		Assert.equals(this._control3, this._container.getChildAt(2));
		this._container.removeChildAt(1);
		Assert.equals(2, this._container.numChildren);
		Assert.equals(this._control1, this._container.getChildAt(0));
		Assert.equals(this._control3, this._container.getChildAt(1));
		this._container.removeChildAt(0);
		Assert.equals(1, this._container.numChildren);
		Assert.equals(this._control3, this._container.getChildAt(0));
		this._container.removeChildAt(0);
		Assert.equals(0, this._container.numChildren);
	}

	public function testRemoveChildren():Void {
		this._container.addChild(this._control1);
		this._container.addChild(this._control2);
		this._container.addChild(this._control3);
		Assert.equals(this._control1, this._container.getChildAt(0));
		Assert.equals(this._control2, this._container.getChildAt(1));
		Assert.equals(this._control3, this._container.getChildAt(2));
		this._container.removeChildren();
		Assert.equals(0, this._container.numChildren);
		this._container.addChild(this._control1);
		this._container.addChild(this._control2);
		this._container.addChild(this._control3);
		this._container.removeChildren(0, 1);
		Assert.equals(1, this._container.numChildren);
	}

	public function testScrollBarsCornerSkinHiddenWhenNoScrollingRequired():Void {
		var child = new LayoutGroup();
		child.width = 150.0;
		child.height = 200.0;
		this._container.addChild(child);
		var scrollBarsCornerSkin = new RectangleSkin();
		scrollBarsCornerSkin.width = 10;
		scrollBarsCornerSkin.height = 10;
		this._container.scrollBarsCornerSkin = scrollBarsCornerSkin;
		this._container.fixedScrollBars = true;
		this._container.validateNow();
		// exactly how the skin is hidden is an implementation detail,
		// but one of these cases should be true. alpha is not included because
		// the alpha value should be allowed to be customized in themes.
		Assert.isTrue(scrollBarsCornerSkin.parent == null || !scrollBarsCornerSkin.visible);
		Assert.equals(0.0, this._container.minScrollX);
		Assert.equals(0.0, this._container.maxScrollX);
		Assert.equals(0.0, this._container.minScrollY);
		Assert.equals(0.0, this._container.maxScrollY);
	}

	public function testScrollBarsCornerSkinHiddenWhenOnlyHorizontalScrollingRequired():Void {
		var child = new LayoutGroup();
		child.width = 150.0;
		child.height = 200.0;
		this._container.addChild(child);
		this._container.width = 100.0;
		var scrollBarsCornerSkin = new RectangleSkin();
		scrollBarsCornerSkin.width = 10;
		scrollBarsCornerSkin.height = 10;
		this._container.scrollBarsCornerSkin = scrollBarsCornerSkin;
		this._container.fixedScrollBars = true;
		this._container.validateNow();
		// exactly how the skin is hidden is an implementation detail,
		// but one of these cases should be true. alpha is not included because
		// the alpha value should be allowed to be customized in themes.
		Assert.isTrue(scrollBarsCornerSkin.parent == null || !scrollBarsCornerSkin.visible);
		Assert.equals(0.0, this._container.minScrollX);
		Assert.isTrue(this._container.maxScrollX > 0.0);
		Assert.equals(0.0, this._container.minScrollY);
		Assert.equals(0.0, this._container.maxScrollY);
	}

	public function testScrollBarsCornerSkinHiddenWhenOnlyVerticalScrollingRequired():Void {
		var child = new LayoutGroup();
		child.width = 150.0;
		child.height = 200.0;
		this._container.addChild(child);
		this._container.height = 100.0;
		var scrollBarsCornerSkin = new RectangleSkin();
		scrollBarsCornerSkin.width = 10;
		scrollBarsCornerSkin.height = 10;
		this._container.scrollBarsCornerSkin = scrollBarsCornerSkin;
		this._container.fixedScrollBars = true;
		this._container.validateNow();
		// exactly how the skin is hidden is an implementation detail,
		// but one of these cases should be true. alpha is not included because
		// the alpha value should be allowed to be customized in themes.
		Assert.isTrue(scrollBarsCornerSkin.parent == null || !scrollBarsCornerSkin.visible);
		Assert.equals(0.0, this._container.minScrollX);
		Assert.equals(0.0, this._container.maxScrollX);
		Assert.equals(0.0, this._container.minScrollY);
		Assert.isTrue(this._container.maxScrollY > 0.0);
	}

	public function testScrollBarsCornerSkinVisibleWhenScrollingInBothDirectionsRequired():Void {
		var child = new LayoutGroup();
		child.width = 150.0;
		child.height = 200.0;
		this._container.addChild(child);
		this._container.width = 100.0;
		this._container.height = 100.0;
		var scrollBarsCornerSkin = new RectangleSkin();
		scrollBarsCornerSkin.width = 10;
		scrollBarsCornerSkin.height = 10;
		this._container.scrollBarsCornerSkin = scrollBarsCornerSkin;
		this._container.fixedScrollBars = true;
		this._container.validateNow();
		Assert.notNull(scrollBarsCornerSkin.parent);
		Assert.isTrue(scrollBarsCornerSkin.visible);
		Assert.equals(0.0, this._container.minScrollX);
		Assert.isTrue(this._container.maxScrollX > 0.0);
		Assert.equals(0.0, this._container.minScrollY);
		Assert.isTrue(this._container.maxScrollY > 0.0);
	}

	public function testScrollBarsCornerSkinVisibleWhenScrollingInBothDirectionsRequiredAndScrollBarsNotFixed():Void {
		var child = new LayoutGroup();
		child.width = 150.0;
		child.height = 200.0;
		this._container.addChild(child);
		this._container.width = 100.0;
		this._container.height = 100.0;
		var scrollBarsCornerSkin = new RectangleSkin();
		scrollBarsCornerSkin.width = 10;
		scrollBarsCornerSkin.height = 10;
		this._container.scrollBarsCornerSkin = scrollBarsCornerSkin;
		this._container.fixedScrollBars = false;
		this._container.validateNow();
		// exactly how the skin is hidden is an implementation detail,
		// but one of these cases should be true. alpha is not included because
		// the alpha value should be allowed to be customized in themes.
		Assert.isTrue(scrollBarsCornerSkin.parent == null || !scrollBarsCornerSkin.visible);
		Assert.equals(0.0, this._container.minScrollX);
		Assert.isTrue(this._container.maxScrollX > 0.0);
		Assert.equals(0.0, this._container.minScrollY);
		Assert.isTrue(this._container.maxScrollY > 0.0);
	}

	public function testReadjustLayout():Void {
		var child = new Shape();
		child.graphics.beginFill(0xff00ff);
		child.graphics.drawRect(0.0, 0.0, 150.0, 100.0);
		child.graphics.endFill();
		this._container.addChild(child);
		this._container.validateNow();
		var originalWidth = child.width;
		var originalHeight = child.height;
		Assert.equals(originalWidth, this._container.width);
		Assert.equals(originalHeight, this._container.height);
		child.graphics.clear();
		child.graphics.beginFill(0xff00ff);
		child.graphics.drawRect(0.0, 0.0, 200.0, 250.0);
		child.graphics.endFill();
		Assert.equals(originalWidth, this._container.width);
		Assert.equals(originalHeight, this._container.height);
		this._container.readjustLayout();
		Assert.equals(originalWidth, this._container.width);
		Assert.equals(originalHeight, this._container.height);
		this._container.validateNow();
		Assert.equals(child.width, this._container.width);
		Assert.equals(child.height, this._container.height);
	}

	// children may sometimes be removed without calling our overrides of
	// removeChild() or removeChildAt(), so this test ensures that we have
	// properly detected the automatic removal by listening for Event.REMOVED
	// and updating the container's internal state
	public function testAddChildToADifferentParent():Void {
		var child1 = new Sprite();
		this._container.addChild(child1);
		Assert.equals(this._container, child1.parent.parent);
		Assert.equals(1, this._container.numChildren);
		Assert.equals(0, this._container.getChildIndex(child1));
		var otherContainer = new ScrollContainer();
		Lib.current.addChild(otherContainer);
		otherContainer.addChild(child1);
		Assert.equals(otherContainer, child1.parent.parent);
		Assert.equals(0, this._container.numChildren);
		Assert.equals(-1, this._container.getChildIndex(child1));
		Lib.current.removeChild(otherContainer);
	}
}

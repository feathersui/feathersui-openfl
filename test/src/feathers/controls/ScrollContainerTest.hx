/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

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
	private var _container:ScrollContainer;

	public function new() {
		super();
	}

	public function setup():Void {
		this._container = new ScrollContainer();
		Lib.current.addChild(this._container);
	}

	public function teardown():Void {
		if (this._container.parent != null) {
			this._container.parent.removeChild(this._container);
		}
		this._container = null;
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

/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.layout.VerticalLayout;
import feathers.skins.RectangleSkin;
import openfl.Lib;
import openfl.display.DisplayObject;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.events.Event;
import utest.Assert;
import utest.Test;

@:keep
class LayoutGroupTest extends Test {
	private var _group:LayoutGroup;

	public function new() {
		super();
	}

	public function setup():Void {
		this._group = new LayoutGroup();
		Lib.current.addChild(this._group);
	}

	public function teardown():Void {
		if (this._group.parent != null) {
			this._group.parent.removeChild(this._group);
		}
		this._group = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testNoExceptionOnDoubleDispose():Void {
		this._group.validateNow();
		this._group.dispose();
		this._group.dispose();
		Assert.pass();
	}

	public function testMeasureSkinWidthAndHeight():Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.width = 100.0;
		backgroundSkin.height = 150.0;
		this._group.backgroundSkin = backgroundSkin;
		this._group.validateNow();
		Assert.equals(backgroundSkin.width, this._group.width);
		Assert.equals(backgroundSkin.height, this._group.height);
	}

	public function testMeasureSkinMinWidthAndMinHeight():Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.minWidth = 100.0;
		backgroundSkin.minHeight = 150.0;
		this._group.backgroundSkin = backgroundSkin;
		this._group.validateNow();
		Assert.equals(backgroundSkin.minWidth, this._group.width);
		Assert.equals(backgroundSkin.minHeight, this._group.height);
	}

	public function testRemoveSkinAfterSetToNewValue():Void {
		var skin1 = new Shape();
		var skin2 = new Shape();
		Assert.isNull(skin1.parent);
		Assert.isNull(skin2.parent);
		this._group.backgroundSkin = skin1;
		this._group.validateNow();
		Assert.equals(this._group, skin1.parent);
		Assert.isNull(skin2.parent);
		this._group.backgroundSkin = skin2;
		this._group.validateNow();
		Assert.isNull(skin1.parent);
		Assert.equals(this._group, skin2.parent);
	}

	public function testRemoveSkinAfterSetToNull():Void {
		var skin = new Shape();
		Assert.isNull(skin.parent);
		this._group.backgroundSkin = skin;
		this._group.validateNow();
		Assert.equals(this._group, skin.parent);
		this._group.backgroundSkin = null;
		this._group.validateNow();
		Assert.isNull(skin.parent);
	}

	public function testRemoveSkinAfterDisable():Void {
		var skin1 = new Shape();
		var skin2 = new Shape();
		Assert.isNull(skin1.parent);
		Assert.isNull(skin2.parent);
		this._group.backgroundSkin = skin1;
		this._group.disabledBackgroundSkin = skin2;
		this._group.validateNow();
		Assert.equals(this._group, skin1.parent);
		Assert.isNull(skin2.parent);
		this._group.enabled = false;
		this._group.validateNow();
		Assert.isNull(skin1.parent);
		Assert.equals(this._group, skin2.parent);
	}

	public function testInvalidateAfterLayoutChange():Void {
		var layout = new VerticalLayout();
		this._group.layout = layout;
		this._group.validateNow();
		Assert.isFalse(this._group.isInvalid());
		layout.gap = 1234.5;
		Assert.isTrue(this._group.isInvalid());
	}

	// this test ensures that the new child index is calculated correctly
	public function testPassBottomChildToAddChild():Void {
		var child1 = new Sprite();
		var child2 = new Sprite();
		var child3 = new Sprite();
		this._group.addChild(child1);
		this._group.addChild(child2);
		this._group.addChild(child3);
		Assert.equals(0, this._group.getChildIndex(child1));
		Assert.equals(1, this._group.getChildIndex(child2));
		Assert.equals(2, this._group.getChildIndex(child3));
		this._group.addChild(child1);
		Assert.equals(2, this._group.getChildIndex(child1));
		Assert.equals(0, this._group.getChildIndex(child2));
		Assert.equals(1, this._group.getChildIndex(child3));
	}

	public function testGetChildIndexInAddedListener():Void {
		var child1 = new Sprite();
		this._group.addChild(child1);
		var child2 = new Sprite();
		this._group.addEventListener(Event.ADDED, event -> {
			var target = cast(event.target, DisplayObject);
			var index = this._group.getChildIndex(target);
			Assert.equals(1, index);
		});
		this._group.addChild(child2);
	}

	public function testGetChildIndexInRemovedListener():Void {
		var child1 = new Sprite();
		this._group.addChild(child1);
		var child2 = new Sprite();
		this._group.addChild(child2);
		this._group.addEventListener(Event.REMOVED, event -> {
			var target = cast(event.target, DisplayObject);
			var index = this._group.getChildIndex(target);
			Assert.equals(-1, index);
		});
		this._group.removeChild(child2);
	}

	public function testReadjustLayout():Void {
		var child = new Shape();
		child.graphics.beginFill(0xff00ff);
		child.graphics.drawRect(0.0, 0.0, 150.0, 100.0);
		child.graphics.endFill();
		this._group.addChild(child);
		this._group.validateNow();
		var originalWidth = child.width;
		var originalHeight = child.height;
		Assert.equals(originalWidth, this._group.width);
		Assert.equals(originalHeight, this._group.height);
		child.graphics.clear();
		child.graphics.beginFill(0xff00ff);
		child.graphics.drawRect(0.0, 0.0, 200.0, 250.0);
		child.graphics.endFill();
		Assert.equals(originalWidth, this._group.width);
		Assert.equals(originalHeight, this._group.height);
		this._group.readjustLayout();
		Assert.equals(originalWidth, this._group.width);
		Assert.equals(originalHeight, this._group.height);
		this._group.validateNow();
		Assert.equals(child.width, this._group.width);
		Assert.equals(child.height, this._group.height);
	}

	// children may sometimes be removed without calling our overrides of
	// removeChild() or removeChildAt(), so this test ensures that we have
	// properly detected the automatic removal by listening for Event.REMOVED
	// and updating the container's internal state
	public function testAddChildToADifferentParent():Void {
		var child1 = new Sprite();
		this._group.addChild(child1);
		Assert.equals(this._group, child1.parent);
		Assert.equals(1, this._group.numChildren);
		Assert.equals(0, this._group.getChildIndex(child1));
		var otherGroup = new LayoutGroup();
		Lib.current.addChild(otherGroup);
		otherGroup.addChild(child1);
		Assert.equals(otherGroup, child1.parent);
		Assert.equals(0, this._group.numChildren);
		Assert.equals(-1, this._group.getChildIndex(child1));
		Lib.current.removeChild(otherGroup);
	}
}

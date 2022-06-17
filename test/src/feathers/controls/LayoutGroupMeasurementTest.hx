/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import openfl.display.DisplayObject;
import feathers.skins.RectangleSkin;
import openfl.Lib;
import openfl.display.Shape;
import utest.Assert;
import utest.Test;

@:keep
class LayoutGroupMeasurementTest extends Test {
	private static final SMALL_BACKGROUND_WIDTH = 200.0;
	private static final SMALL_BACKGROUND_HEIGHT = 250.0;
	private static final SMALL_BACKGROUND_MIN_WIDTH = 20.0;
	private static final SMALL_BACKGROUND_MIN_HEIGHT = 25.0;

	private static final LARGE_BACKGROUND_WIDTH = 340.0;
	private static final LARGE_BACKGROUND_HEIGHT = 350.0;
	private static final LARGE_BACKGROUND_MIN_WIDTH = 280.0;
	private static final LARGE_BACKGROUND_MIN_HEIGHT = 290.0;

	// note: the small item width is purposefully smaller than the small background width
	private static final SMALL_ITEM_WIDTH = 120.0;
	// note: the large item width is purposefully larger than the small background width
	private static final LARGE_ITEM_WIDTH = 210.0;
	// note: the small item height is purposefully smaller than the small background height
	private static final SMALL_ITEM_HEIGHT = 160.0;
	// note: the large item height is purposefully larger than the small background height
	private static final LARGE_ITEM_HEIGHT = 270.0;

	private static final ITEM_X = 120.0;
	private static final ITEM_Y = 130.0;

	private var _container:LayoutGroup;
	private var _container2:LayoutGroup;

	public function new() {
		super();
	}

	public function setup():Void {
		this._container = new LayoutGroup();
		this._container.themeEnabled = false;
		Lib.current.addChild(this._container);
	}

	public function teardown():Void {
		if (this._container.parent != null) {
			this._container.parent.removeChild(this._container);
		}
		this._container = null;
		if (this._container2 != null && this._container2.parent != null) {
			this._container2.parent.removeChild(this._container2);
		}
		this._container2 = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	private function addSimpleBackgroundSkin(?width:Float, ?height:Float):Void {
		if (width == null) {
			width = SMALL_BACKGROUND_WIDTH;
		}
		if (height == null) {
			height = SMALL_BACKGROUND_HEIGHT;
		}
		var backgroundSkin = new Shape();
		backgroundSkin.graphics.beginFill();
		backgroundSkin.graphics.drawRect(0.0, 0.0, width, height);
		backgroundSkin.graphics.endFill();
		this._container.backgroundSkin = backgroundSkin;
	}

	private function addComplexBackgroundSkin(?width:Float, ?height:Float, ?minWidth:Float, ?minHeight:Float):Void {
		if (width == null) {
			width = SMALL_BACKGROUND_WIDTH;
		}
		if (height == null) {
			height = SMALL_BACKGROUND_HEIGHT;
		}
		if (minWidth == null) {
			minWidth = SMALL_BACKGROUND_MIN_WIDTH;
		}
		if (minHeight == null) {
			minHeight = SMALL_BACKGROUND_MIN_HEIGHT;
		}
		var backgroundSkin = new LayoutGroup();
		backgroundSkin.width = width;
		backgroundSkin.height = height;
		backgroundSkin.minWidth = minWidth;
		backgroundSkin.minHeight = minHeight;
		this._container.backgroundSkin = backgroundSkin;
	}

	private function addSimpleChild(?width:Float, ?height:Float):Void {
		if (width == null) {
			width = SMALL_ITEM_WIDTH;
		}
		if (height == null) {
			height = SMALL_ITEM_HEIGHT;
		}
		var child = new Shape();
		child.graphics.beginFill();
		child.graphics.drawRect(0.0, 0.0, width, height);
		child.graphics.endFill();
		this._container.addChild(child);
	}

	public function testAutoSizeModeStage():Void {
		this._container.autoSizeMode = STAGE;
		this._container.validateNow();

		Assert.equals(this._container.stage.stageWidth, this._container.width);
		Assert.equals(this._container.stage.stageHeight, this._container.height);
		Assert.equals(this._container.stage.stageWidth, this._container.minWidth);
		Assert.equals(this._container.stage.stageHeight, this._container.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._container.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._container.maxHeight);
	}

	public function testAutoSizeModeStageWithoutParent():Void {
		this._container2 = new LayoutGroup();
		this._container2.autoSizeMode = STAGE;
		this._container2.validateNow();
		Assert.equals(0.0, this._container2.width);
		Assert.equals(0.0, this._container2.height);
		Assert.equals(0.0, this._container2.minWidth);
		Assert.equals(0.0, this._container2.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._container2.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._container2.maxHeight);
	}

	public function testAutoSizeModeStageWithValidateBeforeAdd():Void {
		this._container2 = new LayoutGroup();
		this._container2.autoSizeMode = STAGE;
		this._container2.validateNow();
		Lib.current.addChild(this._container2);
		this._container2.validateNow();
		Assert.equals(this._container2.stage.stageWidth, this._container2.width);
		Assert.equals(this._container2.stage.stageHeight, this._container2.height);
		Assert.equals(this._container2.stage.stageWidth, this._container2.minWidth);
		Assert.equals(this._container2.stage.stageHeight, this._container2.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._container2.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._container2.maxHeight);
	}

	public function testAutoSizeWithNoChildren():Void {
		this._container.validateNow();
		Assert.equals(0.0, this._container.width);
		Assert.equals(0.0, this._container.height);
		Assert.equals(0.0, this._container.minWidth);
		Assert.equals(0.0, this._container.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._container.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._container.maxHeight);
	}

	public function testAutoSizeWithSimpleBackgroundSkinAndNoChildren():Void {
		this.addSimpleBackgroundSkin();
		this._container.validateNow();

		Assert.equals(SMALL_BACKGROUND_WIDTH, this._container.width);
		Assert.equals(SMALL_BACKGROUND_HEIGHT, this._container.height);
		Assert.equals(SMALL_BACKGROUND_WIDTH, this._container.minWidth);
		Assert.equals(SMALL_BACKGROUND_HEIGHT, this._container.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._container.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._container.maxHeight);
	}

	public function testAutoSizeWithComplexBackgroundSkinAndNoChildren():Void {
		this.addComplexBackgroundSkin();
		this._container.validateNow();

		Assert.equals(SMALL_BACKGROUND_WIDTH, this._container.width);
		Assert.equals(SMALL_BACKGROUND_HEIGHT, this._container.height);
		Assert.equals(SMALL_BACKGROUND_WIDTH, this._container.minWidth);
		Assert.equals(SMALL_BACKGROUND_HEIGHT, this._container.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._container.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._container.maxHeight);
	}

	public function testAutoSizeWithSimpleChildAtOrigin():Void {
		this.addSimpleChild();
		this._container.validateNow();
		Assert.equals(SMALL_ITEM_WIDTH, this._container.width);
		Assert.equals(SMALL_ITEM_HEIGHT, this._container.height);
		Assert.equals(SMALL_ITEM_WIDTH, this._container.minWidth);
		Assert.equals(SMALL_ITEM_HEIGHT, this._container.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._container.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._container.maxHeight);
	}

	public function testAutoSizeWithSimpleChildAtPositiveXAndY():Void {
		this.addSimpleChild();
		var child = this._container.getChildAt(0);
		child.x = ITEM_X;
		child.y = ITEM_Y;
		this._container.validateNow();
		Assert.equals(ITEM_X + SMALL_ITEM_WIDTH, this._container.width);
		Assert.equals(ITEM_Y + SMALL_ITEM_HEIGHT, this._container.height);
		Assert.equals(ITEM_X + SMALL_ITEM_WIDTH, this._container.minWidth);
		Assert.equals(ITEM_Y + SMALL_ITEM_HEIGHT, this._container.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._container.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._container.maxHeight);
	}

	public function testAutoSizeWithMultipleSimpleChildren():Void {
		this.addSimpleChild();
		var child1 = this._container.getChildAt(0);
		child1.x = 0.0;
		child1.y = ITEM_Y;
		this.addSimpleChild();
		var child2 = this._container.getChildAt(1);
		child2.x = ITEM_X;
		child2.y = 0.0;
		this._container.validateNow();
		Assert.equals(ITEM_X + SMALL_ITEM_WIDTH, this._container.width);
		Assert.equals(ITEM_Y + SMALL_ITEM_HEIGHT, this._container.height);
		Assert.equals(ITEM_X + SMALL_ITEM_WIDTH, this._container.minWidth);
		Assert.equals(ITEM_Y + SMALL_ITEM_HEIGHT, this._container.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._container.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._container.maxHeight);
	}

	public function testAutoSizeWithWideSimpleChildAndBackgroundSkin():Void {
		// item has larger width, background has larger height
		this.addSimpleChild(LARGE_ITEM_WIDTH, SMALL_ITEM_HEIGHT);
		this.addComplexBackgroundSkin();
		this._container.validateNow();
		Assert.equals(LARGE_ITEM_WIDTH, this._container.width);
		Assert.equals(SMALL_BACKGROUND_HEIGHT, this._container.height);
		Assert.equals(LARGE_ITEM_WIDTH, this._container.minWidth);
		Assert.equals(SMALL_BACKGROUND_HEIGHT, this._container.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._container.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._container.maxHeight);
	}

	public function testAutoSizeWithTallSimpleChildAndBackgroundSkin():Void {
		// item has larger height, background has larger width
		this.addSimpleChild(SMALL_ITEM_WIDTH, LARGE_ITEM_HEIGHT);
		this.addComplexBackgroundSkin();
		this._container.validateNow();
		Assert.equals(SMALL_BACKGROUND_WIDTH, this._container.width);
		Assert.equals(LARGE_ITEM_HEIGHT, this._container.height);
		Assert.equals(SMALL_BACKGROUND_WIDTH, this._container.minWidth);
		Assert.equals(LARGE_ITEM_HEIGHT, this._container.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._container.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._container.maxHeight);
	}
}

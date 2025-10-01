/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.data.ArrayCollection;
import feathers.layout.HorizontalLayout;
import feathers.skins.RectangleSkin;
import feathers.utils.DisplayObjectRecycler;
import openfl.Lib;
import openfl.display.DisplayObject;
import openfl.display.Shape;
import utest.Assert;
import utest.Test;

@:keep
class ButtonBarMeasurementTest extends Test {
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

	private static final PADDING_LEFT = 120.0;
	private static final PADDING_TOP = 130.0;

	private var _buttonBar:ButtonBar;

	public function new() {
		super();
	}

	public function setup():Void {
		this._buttonBar = new ButtonBar();
		this._buttonBar.themeEnabled = false;
		this._buttonBar.layout = new HorizontalLayout();
		this._buttonBar.dataProvider = new ArrayCollection([]);
		this._buttonBar.itemToText = (item:Dynamic) -> null;
		this._buttonBar.buttonRecycler = DisplayObjectRecycler.withFunction(() -> {
			var button = new Button();
			button.width = SMALL_ITEM_WIDTH;
			button.height = SMALL_ITEM_HEIGHT;
			return button;
		});
		Lib.current.addChild(this._buttonBar);
	}

	public function teardown():Void {
		if (this._buttonBar.parent != null) {
			this._buttonBar.parent.removeChild(this._buttonBar);
		}
		this._buttonBar = null;
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
		this._buttonBar.backgroundSkin = backgroundSkin;
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
		this._buttonBar.backgroundSkin = backgroundSkin;
	}

	private function addSingleChild(?width:Float, ?height:Float):Void {
		if (width == null) {
			width = SMALL_ITEM_WIDTH;
		}
		if (height == null) {
			height = SMALL_ITEM_HEIGHT;
		}
		this._buttonBar.dataProvider.add({});
		this._buttonBar.buttonRecycler = DisplayObjectRecycler.withFunction(() -> {
			var button = new Button();
			button.width = width;
			button.height = height;
			return button;
		});
	}

	private function addMultipleChildren(count:Int = 1):Void {
		for (i in 0...count) {
			this._buttonBar.dataProvider.add({});
		}
	}

	public function testAutoSizeWithNoChildren():Void {
		this._buttonBar.validateNow();
		Assert.equals(0.0, this._buttonBar.width);
		Assert.equals(0.0, this._buttonBar.height);
		Assert.equals(0.0, this._buttonBar.minWidth);
		Assert.equals(0.0, this._buttonBar.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._buttonBar.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._buttonBar.maxHeight);
	}

	public function testAutoSizeWithSimpleBackgroundSkinAndNoChildren():Void {
		this.addSimpleBackgroundSkin();
		this._buttonBar.validateNow();
		Assert.equals(SMALL_BACKGROUND_WIDTH, this._buttonBar.width);
		Assert.equals(SMALL_BACKGROUND_HEIGHT, this._buttonBar.height);
		Assert.equals(SMALL_BACKGROUND_WIDTH, this._buttonBar.minWidth);
		Assert.equals(SMALL_BACKGROUND_HEIGHT, this._buttonBar.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._buttonBar.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._buttonBar.maxHeight);
	}

	public function testAutoSizeWithComplexBackgroundSkinAndNoChildren():Void {
		this.addComplexBackgroundSkin();
		this._buttonBar.validateNow();
		Assert.equals(SMALL_BACKGROUND_WIDTH, this._buttonBar.width);
		Assert.equals(SMALL_BACKGROUND_HEIGHT, this._buttonBar.height);
		Assert.equals(SMALL_BACKGROUND_WIDTH, this._buttonBar.minWidth);
		Assert.equals(SMALL_BACKGROUND_HEIGHT, this._buttonBar.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._buttonBar.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._buttonBar.maxHeight);
	}

	public function testAutoSizeWithOneChildAndNoBackground():Void {
		this.addSingleChild();
		this._buttonBar.validateNow();
		Assert.equals(SMALL_ITEM_WIDTH, this._buttonBar.width);
		Assert.equals(SMALL_ITEM_HEIGHT, this._buttonBar.height);
		Assert.equals(SMALL_ITEM_WIDTH, this._buttonBar.minWidth);
		Assert.equals(SMALL_ITEM_HEIGHT, this._buttonBar.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._buttonBar.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._buttonBar.maxHeight);
	}

	public function testAutoSizeWithChildAndPadding():Void {
		this.addSingleChild();
		var layout = new HorizontalLayout();
		layout.paddingLeft = PADDING_LEFT;
		layout.paddingTop = PADDING_TOP;
		this._buttonBar.layout = layout;
		this._buttonBar.validateNow();
		Assert.equals(PADDING_LEFT + SMALL_ITEM_WIDTH, this._buttonBar.width);
		Assert.equals(PADDING_TOP + SMALL_ITEM_HEIGHT, this._buttonBar.height);
		Assert.equals(PADDING_LEFT + SMALL_ITEM_WIDTH, this._buttonBar.minWidth);
		Assert.equals(PADDING_TOP + SMALL_ITEM_HEIGHT, this._buttonBar.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._buttonBar.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._buttonBar.maxHeight);
	}

	public function testAutoSizeWithMultipleChildren():Void {
		this.addMultipleChildren(2);
		var layout = new HorizontalLayout();
		layout.paddingLeft = PADDING_LEFT;
		layout.paddingTop = PADDING_TOP;
		this._buttonBar.layout = layout;
		this._buttonBar.validateNow();
		Assert.equals(PADDING_LEFT + 2.0 * SMALL_ITEM_WIDTH, this._buttonBar.width);
		Assert.equals(PADDING_TOP + SMALL_ITEM_HEIGHT, this._buttonBar.height);
		Assert.equals(PADDING_LEFT + 2.0 * SMALL_ITEM_WIDTH, this._buttonBar.minWidth);
		Assert.equals(PADDING_TOP + SMALL_ITEM_HEIGHT, this._buttonBar.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._buttonBar.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._buttonBar.maxHeight);
	}

	public function testAutoSizeWithWideChildAndBackgroundSkin():Void {
		// item has larger width, background has larger height
		this.addSingleChild(LARGE_ITEM_WIDTH, SMALL_ITEM_HEIGHT);
		this.addComplexBackgroundSkin();
		this._buttonBar.validateNow();
		Assert.equals(LARGE_ITEM_WIDTH, this._buttonBar.width);
		Assert.equals(SMALL_BACKGROUND_HEIGHT, this._buttonBar.height);
		Assert.equals(LARGE_ITEM_WIDTH, this._buttonBar.minWidth);
		Assert.equals(SMALL_BACKGROUND_HEIGHT, this._buttonBar.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._buttonBar.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._buttonBar.maxHeight);
	}

	public function testAutoSizeWithTallChildAndBackgroundSkin():Void {
		// item has larger height, background has larger width
		this.addSingleChild(SMALL_ITEM_WIDTH, LARGE_ITEM_HEIGHT);
		this.addComplexBackgroundSkin();
		this._buttonBar.validateNow();
		Assert.equals(SMALL_BACKGROUND_WIDTH, this._buttonBar.width);
		Assert.equals(LARGE_ITEM_HEIGHT, this._buttonBar.height);
		Assert.equals(SMALL_BACKGROUND_WIDTH, this._buttonBar.minWidth);
		Assert.equals(LARGE_ITEM_HEIGHT, this._buttonBar.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._buttonBar.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._buttonBar.maxHeight);
	}
}

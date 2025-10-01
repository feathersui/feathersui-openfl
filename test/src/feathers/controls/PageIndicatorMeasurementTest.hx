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
class PageIndicatorMeasurementTest extends Test {
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

	private var _pageIndicator:PageIndicator;

	public function new() {
		super();
	}

	public function setup():Void {
		this._pageIndicator = new PageIndicator();
		this._pageIndicator.themeEnabled = false;
		this._pageIndicator.layout = new HorizontalLayout();
		this._pageIndicator.maxSelectedIndex = 0;
		this._pageIndicator.toggleButtonRecycler = DisplayObjectRecycler.withFunction(() -> {
			var button = new ToggleButton();
			button.width = SMALL_ITEM_WIDTH;
			button.height = SMALL_ITEM_HEIGHT;
			return button;
		});
		Lib.current.addChild(this._pageIndicator);
	}

	public function teardown():Void {
		if (this._pageIndicator.parent != null) {
			this._pageIndicator.parent.removeChild(this._pageIndicator);
		}
		this._pageIndicator = null;
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
		this._pageIndicator.backgroundSkin = backgroundSkin;
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
		this._pageIndicator.backgroundSkin = backgroundSkin;
	}

	private function addSingleChild(?width:Float, ?height:Float):Void {
		if (width == null) {
			width = SMALL_ITEM_WIDTH;
		}
		if (height == null) {
			height = SMALL_ITEM_HEIGHT;
		}
		this._pageIndicator.maxSelectedIndex = 0;
		this._pageIndicator.toggleButtonRecycler = DisplayObjectRecycler.withFunction(() -> {
			var button = new ToggleButton();
			button.width = width;
			button.height = height;
			return button;
		});
	}

	public function testAutoSizeWithNoChildren():Void {
		this._pageIndicator.maxSelectedIndex = -1;
		this._pageIndicator.validateNow();
		Assert.equals(0.0, this._pageIndicator.width);
		Assert.equals(0.0, this._pageIndicator.height);
		Assert.equals(0.0, this._pageIndicator.minWidth);
		Assert.equals(0.0, this._pageIndicator.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._pageIndicator.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._pageIndicator.maxHeight);
	}

	public function testAutoSizeWithSimpleBackgroundSkinAndNoChildren():Void {
		this.addSimpleBackgroundSkin();
		this._pageIndicator.validateNow();
		Assert.equals(SMALL_BACKGROUND_WIDTH, this._pageIndicator.width);
		Assert.equals(SMALL_BACKGROUND_HEIGHT, this._pageIndicator.height);
		Assert.equals(SMALL_BACKGROUND_WIDTH, this._pageIndicator.minWidth);
		Assert.equals(SMALL_BACKGROUND_HEIGHT, this._pageIndicator.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._pageIndicator.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._pageIndicator.maxHeight);
	}

	public function testAutoSizeWithComplexBackgroundSkinAndNoChildren():Void {
		this.addComplexBackgroundSkin();
		this._pageIndicator.validateNow();
		Assert.equals(SMALL_BACKGROUND_WIDTH, this._pageIndicator.width);
		Assert.equals(SMALL_BACKGROUND_HEIGHT, this._pageIndicator.height);
		Assert.equals(SMALL_BACKGROUND_WIDTH, this._pageIndicator.minWidth);
		Assert.equals(SMALL_BACKGROUND_HEIGHT, this._pageIndicator.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._pageIndicator.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._pageIndicator.maxHeight);
	}

	public function testAutoSizeWithOneChildAndNoBackground():Void {
		this.addSingleChild();
		this._pageIndicator.validateNow();
		Assert.equals(SMALL_ITEM_WIDTH, this._pageIndicator.width);
		Assert.equals(SMALL_ITEM_HEIGHT, this._pageIndicator.height);
		Assert.equals(SMALL_ITEM_WIDTH, this._pageIndicator.minWidth);
		Assert.equals(SMALL_ITEM_HEIGHT, this._pageIndicator.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._pageIndicator.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._pageIndicator.maxHeight);
	}

	public function testAutoSizeWithChildAndPadding():Void {
		this.addSingleChild();
		var layout = new HorizontalLayout();
		layout.paddingLeft = PADDING_LEFT;
		layout.paddingTop = PADDING_TOP;
		this._pageIndicator.layout = layout;
		this._pageIndicator.validateNow();
		Assert.equals(PADDING_LEFT + SMALL_ITEM_WIDTH, this._pageIndicator.width);
		Assert.equals(PADDING_TOP + SMALL_ITEM_HEIGHT, this._pageIndicator.height);
		Assert.equals(PADDING_LEFT + SMALL_ITEM_WIDTH, this._pageIndicator.minWidth);
		Assert.equals(PADDING_TOP + SMALL_ITEM_HEIGHT, this._pageIndicator.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._pageIndicator.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._pageIndicator.maxHeight);
	}

	public function testAutoSizeWithMultipleChildren():Void {
		this._pageIndicator.maxSelectedIndex = 1;
		var layout = new HorizontalLayout();
		layout.paddingLeft = PADDING_LEFT;
		layout.paddingTop = PADDING_TOP;
		this._pageIndicator.layout = layout;
		this._pageIndicator.validateNow();
		Assert.equals(PADDING_LEFT + 2.0 * SMALL_ITEM_WIDTH, this._pageIndicator.width);
		Assert.equals(PADDING_TOP + SMALL_ITEM_HEIGHT, this._pageIndicator.height);
		Assert.equals(PADDING_LEFT + 2.0 * SMALL_ITEM_WIDTH, this._pageIndicator.minWidth);
		Assert.equals(PADDING_TOP + SMALL_ITEM_HEIGHT, this._pageIndicator.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._pageIndicator.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._pageIndicator.maxHeight);
	}

	public function testAutoSizeWithWideChildAndBackgroundSkin():Void {
		// item has larger width, background has larger height
		this.addSingleChild(LARGE_ITEM_WIDTH, SMALL_ITEM_HEIGHT);
		this.addComplexBackgroundSkin();
		this._pageIndicator.validateNow();
		Assert.equals(LARGE_ITEM_WIDTH, this._pageIndicator.width);
		Assert.equals(SMALL_BACKGROUND_HEIGHT, this._pageIndicator.height);
		Assert.equals(LARGE_ITEM_WIDTH, this._pageIndicator.minWidth);
		Assert.equals(SMALL_BACKGROUND_HEIGHT, this._pageIndicator.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._pageIndicator.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._pageIndicator.maxHeight);
	}

	public function testAutoSizeWithTallChildAndBackgroundSkin():Void {
		// item has larger height, background has larger width
		this.addSingleChild(SMALL_ITEM_WIDTH, LARGE_ITEM_HEIGHT);
		this.addComplexBackgroundSkin();
		this._pageIndicator.validateNow();
		Assert.equals(SMALL_BACKGROUND_WIDTH, this._pageIndicator.width);
		Assert.equals(LARGE_ITEM_HEIGHT, this._pageIndicator.height);
		Assert.equals(SMALL_BACKGROUND_WIDTH, this._pageIndicator.minWidth);
		Assert.equals(LARGE_ITEM_HEIGHT, this._pageIndicator.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._pageIndicator.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._pageIndicator.maxHeight);
	}
}

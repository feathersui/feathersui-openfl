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
class TabBarMeasurementTest extends Test {
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

	private var _tabBar:TabBar;

	public function new() {
		super();
	}

	public function setup():Void {
		this._tabBar = new TabBar();
		this._tabBar.themeEnabled = false;
		this._tabBar.layout = new HorizontalLayout();
		this._tabBar.dataProvider = new ArrayCollection([]);
		this._tabBar.itemToText = (item:Dynamic) -> null;
		this._tabBar.tabRecycler = DisplayObjectRecycler.withFunction(() -> {
			var tab = new ToggleButton();
			tab.width = SMALL_ITEM_WIDTH;
			tab.height = SMALL_ITEM_HEIGHT;
			return tab;
		});
		Lib.current.addChild(this._tabBar);
	}

	public function teardown():Void {
		if (this._tabBar.parent != null) {
			this._tabBar.parent.removeChild(this._tabBar);
		}
		this._tabBar = null;
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
		this._tabBar.backgroundSkin = backgroundSkin;
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
		this._tabBar.backgroundSkin = backgroundSkin;
	}

	private function addSingleChild(?width:Float, ?height:Float):Void {
		if (width == null) {
			width = SMALL_ITEM_WIDTH;
		}
		if (height == null) {
			height = SMALL_ITEM_HEIGHT;
		}
		this._tabBar.dataProvider.add({});
		this._tabBar.tabRecycler = DisplayObjectRecycler.withFunction(() -> {
			var tab = new ToggleButton();
			tab.width = width;
			tab.height = height;
			return tab;
		});
	}

	private function addMultipleChildren(count:Int = 1):Void {
		for (i in 0...count) {
			this._tabBar.dataProvider.add({});
		}
	}

	public function testAutoSizeWithNoChildren():Void {
		this._tabBar.validateNow();
		Assert.equals(0.0, this._tabBar.width);
		Assert.equals(0.0, this._tabBar.height);
		Assert.equals(0.0, this._tabBar.minWidth);
		Assert.equals(0.0, this._tabBar.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._tabBar.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._tabBar.maxHeight);
	}

	public function testAutoSizeWithSimpleBackgroundSkinAndNoChildren():Void {
		this.addSimpleBackgroundSkin();
		this._tabBar.validateNow();
		Assert.equals(SMALL_BACKGROUND_WIDTH, this._tabBar.width);
		Assert.equals(SMALL_BACKGROUND_HEIGHT, this._tabBar.height);
		Assert.equals(SMALL_BACKGROUND_WIDTH, this._tabBar.minWidth);
		Assert.equals(SMALL_BACKGROUND_HEIGHT, this._tabBar.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._tabBar.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._tabBar.maxHeight);
	}

	public function testAutoSizeWithComplexBackgroundSkinAndNoChildren():Void {
		this.addComplexBackgroundSkin();
		this._tabBar.validateNow();
		Assert.equals(SMALL_BACKGROUND_WIDTH, this._tabBar.width);
		Assert.equals(SMALL_BACKGROUND_HEIGHT, this._tabBar.height);
		Assert.equals(SMALL_BACKGROUND_WIDTH, this._tabBar.minWidth);
		Assert.equals(SMALL_BACKGROUND_HEIGHT, this._tabBar.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._tabBar.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._tabBar.maxHeight);
	}

	public function testAutoSizeWithOneChildAndNoBackground():Void {
		this.addSingleChild();
		this._tabBar.validateNow();
		Assert.equals(SMALL_ITEM_WIDTH, this._tabBar.width);
		Assert.equals(SMALL_ITEM_HEIGHT, this._tabBar.height);
		Assert.equals(SMALL_ITEM_WIDTH, this._tabBar.minWidth);
		Assert.equals(SMALL_ITEM_HEIGHT, this._tabBar.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._tabBar.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._tabBar.maxHeight);
	}

	public function testAutoSizeWithChildAndPadding():Void {
		this.addSingleChild();
		var layout = new HorizontalLayout();
		layout.paddingLeft = PADDING_LEFT;
		layout.paddingTop = PADDING_TOP;
		this._tabBar.layout = layout;
		this._tabBar.validateNow();
		Assert.equals(PADDING_LEFT + SMALL_ITEM_WIDTH, this._tabBar.width);
		Assert.equals(PADDING_TOP + SMALL_ITEM_HEIGHT, this._tabBar.height);
		Assert.equals(PADDING_LEFT + SMALL_ITEM_WIDTH, this._tabBar.minWidth);
		Assert.equals(PADDING_TOP + SMALL_ITEM_HEIGHT, this._tabBar.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._tabBar.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._tabBar.maxHeight);
	}

	public function testAutoSizeWithMultipleChildren():Void {
		this.addMultipleChildren(2);
		var layout = new HorizontalLayout();
		layout.paddingLeft = PADDING_LEFT;
		layout.paddingTop = PADDING_TOP;
		this._tabBar.layout = layout;
		this._tabBar.validateNow();
		Assert.equals(PADDING_LEFT + 2.0 * SMALL_ITEM_WIDTH, this._tabBar.width);
		Assert.equals(PADDING_TOP + SMALL_ITEM_HEIGHT, this._tabBar.height);
		Assert.equals(PADDING_LEFT + 2.0 * SMALL_ITEM_WIDTH, this._tabBar.minWidth);
		Assert.equals(PADDING_TOP + SMALL_ITEM_HEIGHT, this._tabBar.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._tabBar.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._tabBar.maxHeight);
	}

	public function testAutoSizeWithWideChildAndBackgroundSkin():Void {
		// item has larger width, background has larger height
		this.addSingleChild(LARGE_ITEM_WIDTH, SMALL_ITEM_HEIGHT);
		this.addComplexBackgroundSkin();
		this._tabBar.validateNow();
		Assert.equals(LARGE_ITEM_WIDTH, this._tabBar.width);
		Assert.equals(SMALL_BACKGROUND_HEIGHT, this._tabBar.height);
		Assert.equals(LARGE_ITEM_WIDTH, this._tabBar.minWidth);
		Assert.equals(SMALL_BACKGROUND_HEIGHT, this._tabBar.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._tabBar.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._tabBar.maxHeight);
	}

	public function testAutoSizeWithTallChildAndBackgroundSkin():Void {
		// item has larger height, background has larger width
		this.addSingleChild(SMALL_ITEM_WIDTH, LARGE_ITEM_HEIGHT);
		this.addComplexBackgroundSkin();
		this._tabBar.validateNow();
		Assert.equals(SMALL_BACKGROUND_WIDTH, this._tabBar.width);
		Assert.equals(LARGE_ITEM_HEIGHT, this._tabBar.height);
		Assert.equals(SMALL_BACKGROUND_WIDTH, this._tabBar.minWidth);
		Assert.equals(LARGE_ITEM_HEIGHT, this._tabBar.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._tabBar.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._tabBar.maxHeight);
	}
}

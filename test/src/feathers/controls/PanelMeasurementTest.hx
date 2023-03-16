/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.skins.RectangleSkin;
import openfl.Lib;
import openfl.display.Shape;
import utest.Assert;
import utest.Test;

@:keep
class PanelMeasurementTest extends Test {
	private static final SMALL_BACKGROUND_WIDTH = 200.0;
	private static final SMALL_BACKGROUND_HEIGHT = 250.0;
	private static final SMALL_BACKGROUND_MIN_WIDTH = 20.0;
	private static final SMALL_BACKGROUND_MIN_HEIGHT = 25.0;

	private static final LARGE_BACKGROUND_WIDTH = 340.0;
	private static final LARGE_BACKGROUND_HEIGHT = 350.0;
	private static final LARGE_BACKGROUND_MIN_WIDTH = 280.0;
	private static final LARGE_BACKGROUND_MIN_HEIGHT = 290.0;

	private static final HEADER_WIDTH = 150.0;
	private static final HEADER_HEIGHT = 40.0;
	private static final LARGE_HEADER_WIDTH = 550.0;

	private static final FOOTER_WIDTH = 160.0;
	private static final FOOTER_HEIGHT = 30.0;

	private static final PADDING_TOP = 40.0;
	private static final PADDING_RIGHT = 64.0;
	private static final PADDING_BOTTOM = 69.0;
	private static final PADDING_LEFT = 50.0;

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

	private var _panel:Panel;
	private var _panel2:Panel;

	public function new() {
		super();
	}

	public function setup():Void {
		this._panel = new Panel();
		this._panel.themeEnabled = false;
		Lib.current.addChild(this._panel);
	}

	public function teardown():Void {
		if (this._panel.parent != null) {
			this._panel.parent.removeChild(this._panel);
		}
		this._panel = null;
		if (this._panel2 != null && this._panel2.parent != null) {
			this._panel2.parent.removeChild(this._panel2);
		}
		this._panel2 = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	private function addHeader():Void {
		var header = new LayoutGroup();
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.width = HEADER_WIDTH;
		backgroundSkin.height = HEADER_HEIGHT;
		header.backgroundSkin = backgroundSkin;
		this._panel.header = header;
	}

	private function addFooter():Void {
		var footer = new LayoutGroup();
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.width = FOOTER_WIDTH;
		backgroundSkin.height = FOOTER_HEIGHT;
		footer.backgroundSkin = backgroundSkin;
		this._panel.footer = footer;
	}

	private function addPadding():Void {
		this._panel.paddingTop = PADDING_TOP;
		this._panel.paddingRight = PADDING_RIGHT;
		this._panel.paddingBottom = PADDING_BOTTOM;
		this._panel.paddingLeft = PADDING_LEFT;
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
		this._panel.backgroundSkin = backgroundSkin;
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
		this._panel.backgroundSkin = backgroundSkin;
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
		this._panel.addChild(child);
	}

	public function testAutoSizeModeStage():Void {
		this._panel.autoSizeMode = STAGE;
		this._panel.validateNow();

		Assert.equals(this._panel.stage.stageWidth, this._panel.width);
		Assert.equals(this._panel.stage.stageHeight, this._panel.height);
		Assert.equals(this._panel.stage.stageWidth, this._panel.minWidth);
		Assert.equals(this._panel.stage.stageHeight, this._panel.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel.maxHeight);
	}

	public function testAutoSizeModeStageWithoutParent():Void {
		this._panel2 = new Panel();
		this._panel2.autoSizeMode = STAGE;
		this._panel2.validateNow();
		Assert.equals(0.0, this._panel2.width);
		Assert.equals(0.0, this._panel2.height);
		Assert.equals(0.0, this._panel2.minWidth);
		Assert.equals(0.0, this._panel2.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel2.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel2.maxHeight);
	}

	public function testAutoSizeModeStageWithValidateBeforeAdd():Void {
		this._panel2 = new Panel();
		this._panel2.autoSizeMode = STAGE;
		this._panel2.validateNow();
		Lib.current.addChild(this._panel2);
		this._panel2.validateNow();
		Assert.equals(this._panel2.stage.stageWidth, this._panel2.width);
		Assert.equals(this._panel2.stage.stageHeight, this._panel2.height);
		Assert.equals(this._panel2.stage.stageWidth, this._panel2.minWidth);
		Assert.equals(this._panel2.stage.stageHeight, this._panel2.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel2.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel2.maxHeight);
	}

	public function testAutoSizeWithNoChildren():Void {
		this._panel.validateNow();
		Assert.equals(0.0, this._panel.width);
		Assert.equals(0.0, this._panel.height);
		Assert.equals(0.0, this._panel.minWidth);
		Assert.equals(0.0, this._panel.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel.maxHeight);
	}

	public function testAutoSizeWithPaddingAndNoChildren():Void {
		this.addPadding();
		this._panel.validateNow();
		Assert.equals(PADDING_LEFT + PADDING_RIGHT, this._panel.width);
		Assert.equals(PADDING_TOP + PADDING_BOTTOM, this._panel.height);
		Assert.equals(PADDING_LEFT + PADDING_RIGHT, this._panel.minWidth);
		Assert.equals(PADDING_TOP + PADDING_BOTTOM, this._panel.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel.maxHeight);
	}

	public function testAutoSizeWithSimpleBackgroundSkinAndNoChildren():Void {
		this.addSimpleBackgroundSkin();
		this._panel.validateNow();

		Assert.equals(SMALL_BACKGROUND_WIDTH, this._panel.width);
		Assert.equals(SMALL_BACKGROUND_HEIGHT, this._panel.height);
		Assert.equals(SMALL_BACKGROUND_WIDTH, this._panel.minWidth);
		Assert.equals(SMALL_BACKGROUND_HEIGHT, this._panel.minHeight);
		Assert.equals(SMALL_BACKGROUND_WIDTH, this._panel.maxWidth);
		Assert.equals(SMALL_BACKGROUND_HEIGHT, this._panel.maxHeight);
	}

	public function testAutoSizeWithComplexBackgroundSkinAndNoChildren():Void {
		this.addComplexBackgroundSkin(LARGE_BACKGROUND_WIDTH, LARGE_BACKGROUND_HEIGHT, LARGE_BACKGROUND_MIN_WIDTH, LARGE_BACKGROUND_MIN_HEIGHT);
		this._panel.validateNow();

		Assert.equals(LARGE_BACKGROUND_WIDTH, this._panel.width);
		Assert.equals(LARGE_BACKGROUND_HEIGHT, this._panel.height);
		Assert.equals(LARGE_BACKGROUND_MIN_WIDTH, this._panel.minWidth);
		Assert.equals(LARGE_BACKGROUND_MIN_HEIGHT, this._panel.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel.maxHeight);
	}

	public function testAutoSizeWithHeader():Void {
		this.addHeader();
		this._panel.validateNow();
		Assert.equals(HEADER_WIDTH, this._panel.width);
		Assert.equals(HEADER_HEIGHT, this._panel.height);
		Assert.equals(HEADER_WIDTH, this._panel.minWidth);
		Assert.equals(HEADER_HEIGHT, this._panel.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel.maxHeight);
	}

	public function testAutoSizeWithHeaderAndPadding():Void {
		this.addHeader();
		this.addPadding();
		this._panel.validateNow();
		Assert.equals(HEADER_WIDTH + PADDING_LEFT + PADDING_RIGHT, this._panel.width);
		Assert.equals(HEADER_HEIGHT + PADDING_TOP + PADDING_BOTTOM, this._panel.height);
		Assert.equals(HEADER_WIDTH + PADDING_LEFT + PADDING_RIGHT, this._panel.minWidth);
		Assert.equals(HEADER_HEIGHT + PADDING_TOP + PADDING_BOTTOM, this._panel.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel.maxHeight);
	}

	public function testAutoSizeWithHeaderAndSimpleBackgroundSkin():Void {
		this.addHeader();
		this.addSimpleBackgroundSkin();
		this._panel.validateNow();

		Assert.equals(SMALL_BACKGROUND_WIDTH, this._panel.width);
		Assert.equals(SMALL_BACKGROUND_HEIGHT, this._panel.height);
		Assert.equals(SMALL_BACKGROUND_WIDTH, this._panel.minWidth);
		Assert.equals(SMALL_BACKGROUND_HEIGHT, this._panel.minHeight);
		Assert.equals(SMALL_BACKGROUND_WIDTH, this._panel.maxWidth);
		Assert.equals(SMALL_BACKGROUND_HEIGHT, this._panel.maxHeight);
	}

	public function testAutoSizeWithHeaderAndComplexBackgroundSkin():Void {
		this.addHeader();
		this.addComplexBackgroundSkin(LARGE_BACKGROUND_WIDTH, LARGE_BACKGROUND_HEIGHT, LARGE_BACKGROUND_MIN_WIDTH, LARGE_BACKGROUND_MIN_HEIGHT);
		this._panel.validateNow();

		Assert.equals(LARGE_BACKGROUND_WIDTH, this._panel.width);
		Assert.equals(LARGE_BACKGROUND_HEIGHT, this._panel.height);
		Assert.equals(LARGE_BACKGROUND_MIN_WIDTH, this._panel.minWidth);
		Assert.equals(LARGE_BACKGROUND_MIN_HEIGHT, this._panel.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel.maxHeight);
	}

	public function testAutoSizeWithFooter():Void {
		this.addFooter();
		this._panel.validateNow();
		Assert.equals(FOOTER_WIDTH, this._panel.width);
		Assert.equals(FOOTER_HEIGHT, this._panel.height);
		Assert.equals(FOOTER_WIDTH, this._panel.minWidth);
		Assert.equals(FOOTER_HEIGHT, this._panel.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel.maxHeight);
	}

	public function testAutoSizeWithFooterAndPadding():Void {
		this.addFooter();
		this.addPadding();
		this._panel.validateNow();
		Assert.equals(FOOTER_WIDTH + PADDING_LEFT + PADDING_RIGHT, this._panel.width);
		Assert.equals(FOOTER_HEIGHT + PADDING_TOP + PADDING_BOTTOM, this._panel.height);
		Assert.equals(FOOTER_WIDTH + PADDING_LEFT + PADDING_RIGHT, this._panel.minWidth);
		Assert.equals(FOOTER_HEIGHT + PADDING_TOP + PADDING_BOTTOM, this._panel.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel.maxHeight);
	}

	public function testAutoSizeWithFooterAndSimpleBackgroundSkin():Void {
		this.addFooter();
		this.addSimpleBackgroundSkin();
		this._panel.validateNow();

		Assert.equals(SMALL_BACKGROUND_WIDTH, this._panel.width);
		Assert.equals(SMALL_BACKGROUND_HEIGHT, this._panel.height);
		Assert.equals(SMALL_BACKGROUND_WIDTH, this._panel.minWidth);
		Assert.equals(SMALL_BACKGROUND_HEIGHT, this._panel.minHeight);
		Assert.equals(SMALL_BACKGROUND_WIDTH, this._panel.maxWidth);
		Assert.equals(SMALL_BACKGROUND_HEIGHT, this._panel.maxHeight);
	}

	public function testAutoSizeWithFooterAndComplexBackgroundSkin():Void {
		this.addFooter();
		this.addComplexBackgroundSkin(LARGE_BACKGROUND_WIDTH, LARGE_BACKGROUND_HEIGHT, LARGE_BACKGROUND_MIN_WIDTH, LARGE_BACKGROUND_MIN_HEIGHT);
		this._panel.validateNow();

		Assert.equals(LARGE_BACKGROUND_WIDTH, this._panel.width);
		Assert.equals(LARGE_BACKGROUND_HEIGHT, this._panel.height);
		Assert.equals(LARGE_BACKGROUND_MIN_WIDTH, this._panel.minWidth);
		Assert.equals(LARGE_BACKGROUND_MIN_HEIGHT, this._panel.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel.maxHeight);
	}

	public function testAutoSizeWithHeaderAndFooter():Void {
		this.addHeader();
		this.addFooter();
		this._panel.validateNow();
		Assert.equals(Math.max(HEADER_WIDTH, FOOTER_WIDTH), this._panel.width);
		Assert.equals(HEADER_HEIGHT + FOOTER_HEIGHT, this._panel.height);
		Assert.equals(Math.max(HEADER_WIDTH, FOOTER_WIDTH), this._panel.minWidth);
		Assert.equals(HEADER_HEIGHT + FOOTER_HEIGHT, this._panel.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel.maxHeight);
	}

	public function testAutoSizeWithHeaderAndFooterAndPadding():Void {
		this.addHeader();
		this.addFooter();
		this.addPadding();
		this._panel.validateNow();
		Assert.equals(Math.max(HEADER_WIDTH, FOOTER_WIDTH) + PADDING_LEFT + PADDING_RIGHT, this._panel.width);
		Assert.equals(HEADER_HEIGHT + FOOTER_HEIGHT + PADDING_TOP + PADDING_BOTTOM, this._panel.height);
		Assert.equals(Math.max(HEADER_WIDTH, FOOTER_WIDTH) + PADDING_LEFT + PADDING_RIGHT, this._panel.minWidth);
		Assert.equals(HEADER_HEIGHT + FOOTER_HEIGHT + PADDING_TOP + PADDING_BOTTOM, this._panel.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel.maxHeight);
	}

	public function testAutoSizeWithSimpleChildAtOrigin():Void {
		this.addSimpleChild();
		this._panel.validateNow();
		Assert.equals(SMALL_ITEM_WIDTH, this._panel.width);
		Assert.equals(SMALL_ITEM_HEIGHT, this._panel.height);
		Assert.equals(0.0, this._panel.minWidth);
		Assert.equals(0.0, this._panel.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel.maxHeight);
	}

	public function testAutoSizeWithSimpleChildAtPositiveXAndY():Void {
		this.addSimpleChild();
		var child = this._panel.getChildAt(0);
		child.x = ITEM_X;
		child.y = ITEM_Y;
		this._panel.validateNow();
		Assert.equals(ITEM_X + SMALL_ITEM_WIDTH, this._panel.width);
		Assert.equals(ITEM_Y + SMALL_ITEM_HEIGHT, this._panel.height);
		Assert.equals(0.0, this._panel.minWidth);
		Assert.equals(0.0, this._panel.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel.maxHeight);
	}

	public function testAutoSizeWithMultipleSimpleChildren():Void {
		this.addSimpleChild();
		var child1 = this._panel.getChildAt(0);
		child1.x = 0.0;
		child1.y = ITEM_Y;
		this.addSimpleChild();
		var child2 = this._panel.getChildAt(1);
		child2.x = ITEM_X;
		child2.y = 0.0;
		this._panel.validateNow();
		Assert.equals(ITEM_X + SMALL_ITEM_WIDTH, this._panel.width);
		Assert.equals(ITEM_Y + SMALL_ITEM_HEIGHT, this._panel.height);
		Assert.equals(0.0, this._panel.minWidth);
		Assert.equals(0.0, this._panel.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel.maxHeight);
	}

	public function testAutoSizeWithWideSimpleChildAndBackgroundSkin():Void {
		// item has larger width, background has larger height
		this.addSimpleChild(LARGE_ITEM_WIDTH, SMALL_ITEM_HEIGHT);
		this.addComplexBackgroundSkin();
		this._panel.validateNow();
		Assert.equals(LARGE_ITEM_WIDTH, this._panel.width);
		Assert.equals(SMALL_BACKGROUND_HEIGHT, this._panel.height);
		Assert.equals(SMALL_BACKGROUND_MIN_WIDTH, this._panel.minWidth);
		Assert.equals(SMALL_BACKGROUND_MIN_HEIGHT, this._panel.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel.maxHeight);
	}

	public function testAutoSizeWithTallSimpleChildAndBackgroundSkin():Void {
		// item has larger height, background has larger width
		this.addSimpleChild(SMALL_ITEM_WIDTH, LARGE_ITEM_HEIGHT);
		this.addComplexBackgroundSkin();
		this._panel.validateNow();
		Assert.equals(SMALL_BACKGROUND_WIDTH, this._panel.width);
		Assert.equals(LARGE_ITEM_HEIGHT, this._panel.height);
		Assert.equals(SMALL_BACKGROUND_MIN_WIDTH, this._panel.minWidth);
		Assert.equals(SMALL_BACKGROUND_MIN_HEIGHT, this._panel.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel.maxHeight);
	}

	public function testAutoSizeWithHeaderAndWideSimpleChild():Void {
		// item has larger width than header
		this.addHeader();
		this.addSimpleChild(LARGE_ITEM_WIDTH, SMALL_ITEM_HEIGHT);
		this._panel.validateNow();
		Assert.equals(LARGE_ITEM_WIDTH, this._panel.width);
		Assert.equals(HEADER_HEIGHT + SMALL_ITEM_HEIGHT, this._panel.height);
		Assert.equals(HEADER_WIDTH, this._panel.minWidth);
		Assert.equals(HEADER_HEIGHT, this._panel.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel.maxHeight);
	}

	public function testAutoSizeWithHeaderAndNarrowSimpleChild():Void {
		// item has smaller width than header
		this.addHeader();
		this.addSimpleChild();
		this._panel.validateNow();
		Assert.equals(HEADER_WIDTH, this._panel.width);
		Assert.equals(HEADER_HEIGHT + SMALL_ITEM_HEIGHT, this._panel.height);
		Assert.equals(HEADER_WIDTH, this._panel.minWidth);
		Assert.equals(HEADER_HEIGHT, this._panel.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel.maxHeight);
	}

	public function testAutoSizeWithFooterAndWideSimpleChild():Void {
		// item has larger width than footer
		this.addFooter();
		this.addSimpleChild(LARGE_ITEM_WIDTH, SMALL_ITEM_HEIGHT);
		this._panel.validateNow();
		Assert.equals(LARGE_ITEM_WIDTH, this._panel.width);
		Assert.equals(FOOTER_HEIGHT + SMALL_ITEM_HEIGHT, this._panel.height);
		Assert.equals(FOOTER_WIDTH, this._panel.minWidth);
		Assert.equals(FOOTER_HEIGHT, this._panel.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel.maxHeight);
	}

	public function testAutoSizeWithFooterAndNarrowSimpleChild():Void {
		// item has smaller width than footer
		this.addFooter();
		this.addSimpleChild();
		this._panel.validateNow();
		Assert.equals(FOOTER_WIDTH, this._panel.width);
		Assert.equals(FOOTER_HEIGHT + SMALL_ITEM_HEIGHT, this._panel.height);
		Assert.equals(FOOTER_WIDTH, this._panel.minWidth);
		Assert.equals(FOOTER_HEIGHT, this._panel.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._panel.maxHeight);
	}
}

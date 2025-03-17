/*
	Feathers UI
	Copyright 2025 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls.dataRenderers;

import openfl.text.TextField;
import feathers.skins.RectangleSkin;
import openfl.Lib;
import utest.Assert;
import utest.Test;

@:keep
@:access(feathers.controls.dataRenderers.ItemRenderer)
class ItemRendererMeasurementTest extends Test {
	private static final BACKGROUND_WIDTH = 30.0;
	private static final BACKGROUND_HEIGHT = 32.0;
	private static final BACKGROUND_MIN_WIDTH = 20.0;
	private static final BACKGROUND_MIN_HEIGHT = 18.0;
	private static final BACKGROUND_MAX_WIDTH = 50.0;
	private static final BACKGROUND_MAX_HEIGHT = 45.0;

	private var _itemRenderer:ItemRenderer;
	private var _measureTextField:TextField;

	public function new() {
		super();
	}

	public function setup():Void {
		this._itemRenderer = new ItemRenderer();
		this._itemRenderer.themeEnabled = false;
		Lib.current.addChild(this._itemRenderer);
	}

	public function teardown():Void {
		if (this._itemRenderer.parent != null) {
			this._itemRenderer.parent.removeChild(this._itemRenderer);
		}
		this._itemRenderer = null;
		if (this._measureTextField != null && this._measureTextField.parent != null) {
			this._measureTextField.parent.removeChild(this._measureTextField);
		}
		this._measureTextField = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	private function addRectangleSkinBackground():Void {
		var skin = new RectangleSkin();
		skin.width = BACKGROUND_WIDTH;
		skin.height = BACKGROUND_HEIGHT;
		skin.minWidth = BACKGROUND_MIN_WIDTH;
		skin.minHeight = BACKGROUND_MIN_HEIGHT;
		skin.maxWidth = BACKGROUND_MAX_WIDTH;
		skin.maxHeight = BACKGROUND_MAX_HEIGHT;
		this._itemRenderer.backgroundSkin = skin;
	}

	public function testMeasurementsWithNoBackgroundSkinAndNoContent():Void {
		this._itemRenderer.validateNow();

		Assert.equals(0.0, this._itemRenderer.width);
		Assert.equals(0.0, this._itemRenderer.height);
		Assert.equals(0.0, this._itemRenderer.minWidth);
		Assert.equals(0.0, this._itemRenderer.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._itemRenderer.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._itemRenderer.maxHeight);
		Assert.equals(0.0, this._itemRenderer.baseline);
	}

	public function testMeasurementsWithRectangleSkinBackgroundSkinAndNoContent():Void {
		this._measureTextField = new TextField();
		this._measureTextField.autoSize = LEFT;
		this._measureTextField.text = "\u200b";
		// swf requires both on stage or both off stage for equal measurement
		Lib.current.addChild(this._measureTextField);

		this.addRectangleSkinBackground();
		this._itemRenderer.validateNow();

		Assert.equals(BACKGROUND_WIDTH, this._itemRenderer.width);
		Assert.equals(BACKGROUND_HEIGHT, this._itemRenderer.height);
		Assert.equals(BACKGROUND_MIN_WIDTH, this._itemRenderer.minWidth);
		Assert.equals(BACKGROUND_MIN_HEIGHT, this._itemRenderer.minHeight);
		Assert.equals(BACKGROUND_MAX_WIDTH, this._itemRenderer.maxWidth);
		Assert.equals(BACKGROUND_MAX_HEIGHT, this._itemRenderer.maxHeight);
		Assert.equals(((BACKGROUND_HEIGHT - this._measureTextField.height) / 2.0) + this._measureTextField.getLineMetrics(0).ascent,
			this._itemRenderer.baseline);
	}

	public function testMeasurementsWithText():Void {
		var text = "Hello World";
		this._measureTextField = new TextField();
		this._measureTextField.autoSize = LEFT;
		this._measureTextField.text = text;
		// swf requires both on stage or both off stage for equal measurement
		Lib.current.addChild(this._measureTextField);

		this._itemRenderer.text = text;
		this._itemRenderer.validateNow();

		Assert.isTrue(this._itemRenderer.width > 0.0);
		Assert.isTrue(this._itemRenderer.height > 0.0);
		Assert.equals(this._measureTextField.width, this._itemRenderer.width);
		Assert.equals(this._measureTextField.height, this._itemRenderer.height);
		Assert.equals(this._measureTextField.width, this._itemRenderer.minWidth);
		Assert.equals(this._measureTextField.height, this._itemRenderer.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._itemRenderer.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._itemRenderer.maxHeight);
		Assert.equals(this._measureTextField.getLineMetrics(0).ascent, this._itemRenderer.baseline);
	}

	public function testMeasurementsWithHtmlText():Void {
		var htmlText = "<b>Hello</b> <i>World</i>";
		this._measureTextField = new TextField();
		this._measureTextField.autoSize = LEFT;
		this._measureTextField.htmlText = htmlText;
		// swf requires both on stage or both off stage for equal measurement
		Lib.current.addChild(this._measureTextField);

		this._itemRenderer.htmlText = htmlText;
		this._itemRenderer.validateNow();

		Assert.isTrue(this._itemRenderer.width > 0.0);
		Assert.isTrue(this._itemRenderer.height > 0.0);
		Assert.equals(this._measureTextField.width, this._itemRenderer.width);
		Assert.equals(this._measureTextField.height, this._itemRenderer.height);
		Assert.equals(this._measureTextField.width, this._itemRenderer.minWidth);
		Assert.equals(this._measureTextField.height, this._itemRenderer.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._itemRenderer.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._itemRenderer.maxHeight);
		Assert.equals(this._measureTextField.getLineMetrics(0).ascent, this._itemRenderer.baseline);
	}

	public function testMeasurementsWithTextAndShowTextFalse():Void {
		this._itemRenderer.text = "Hello World";
		this._itemRenderer.showText = false;
		this._itemRenderer.validateNow();

		Assert.equals(0.0, this._itemRenderer.width);
		Assert.equals(0.0, this._itemRenderer.height);
		Assert.equals(0.0, this._itemRenderer.minWidth);
		Assert.equals(0.0, this._itemRenderer.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._itemRenderer.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._itemRenderer.maxHeight);
		Assert.equals(0.0, this._itemRenderer.baseline);
	}

	public function testMeasurementsWithHtmlTextAndShowTextFalse():Void {
		this._itemRenderer.htmlText = "<b>Hello</b> <i>World</i>";
		this._itemRenderer.showText = false;
		this._itemRenderer.validateNow();

		Assert.equals(0.0, this._itemRenderer.width);
		Assert.equals(0.0, this._itemRenderer.height);
		Assert.equals(0.0, this._itemRenderer.minWidth);
		Assert.equals(0.0, this._itemRenderer.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._itemRenderer.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._itemRenderer.maxHeight);
		Assert.equals(0.0, this._itemRenderer.baseline);
	}

	public function testMeasurementsWithSecondaryText():Void {
		var text = "Hello World";
		this._measureTextField = new TextField();
		this._measureTextField.autoSize = LEFT;
		this._measureTextField.text = text;
		// swf requires both on stage or both off stage for equal measurement
		Lib.current.addChild(this._measureTextField);

		this._itemRenderer.secondaryText = text;
		this._itemRenderer.validateNow();

		Assert.isTrue(this._itemRenderer.width > 0.0);
		Assert.isTrue(this._itemRenderer.height > 0.0);
		Assert.equals(this._measureTextField.width, this._itemRenderer.width);
		Assert.equals(this._measureTextField.height, this._itemRenderer.height);
		Assert.equals(this._measureTextField.width, this._itemRenderer.minWidth);
		Assert.equals(this._measureTextField.height, this._itemRenderer.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._itemRenderer.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._itemRenderer.maxHeight);
		// it probably isn't best to ignore secondary text baseline
		Assert.equals(0.0, this._itemRenderer.baseline);
	}

	public function testMeasurementsWithSecondaryHtmlText():Void {
		var htmlText = "<b>Hello</b> <i>World</i>";
		this._measureTextField = new TextField();
		this._measureTextField.autoSize = LEFT;
		this._measureTextField.htmlText = htmlText;
		// swf requires both on stage or both off stage for equal measurement
		Lib.current.addChild(this._measureTextField);

		this._itemRenderer.secondaryHtmlText = htmlText;
		this._itemRenderer.validateNow();

		Assert.isTrue(this._itemRenderer.width > 0.0);
		Assert.isTrue(this._itemRenderer.height > 0.0);
		Assert.equals(this._measureTextField.width, this._itemRenderer.width);
		Assert.equals(this._measureTextField.height, this._itemRenderer.height);
		Assert.equals(this._measureTextField.width, this._itemRenderer.minWidth);
		Assert.equals(this._measureTextField.height, this._itemRenderer.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._itemRenderer.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._itemRenderer.maxHeight);
		// it probably isn't best to ignore secondary text baseline
		Assert.equals(0.0, this._itemRenderer.baseline);
	}

	public function testMeasurementsWithSecondaryTextAndShowSecondaryTextFalse():Void {
		this._itemRenderer.secondaryText = "Hello World";
		this._itemRenderer.showSecondaryText = false;
		this._itemRenderer.validateNow();

		Assert.equals(0.0, this._itemRenderer.width);
		Assert.equals(0.0, this._itemRenderer.height);
		Assert.equals(0.0, this._itemRenderer.minWidth);
		Assert.equals(0.0, this._itemRenderer.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._itemRenderer.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._itemRenderer.maxHeight);
		Assert.equals(0.0, this._itemRenderer.baseline);
	}

	public function testMeasurementsWithSecondaryHtmlTextAndShowSecondaryTextFalse():Void {
		this._itemRenderer.secondaryHtmlText = "<b>Hello</b> <i>World</i>";
		this._itemRenderer.showSecondaryText = false;
		this._itemRenderer.validateNow();

		Assert.equals(0.0, this._itemRenderer.width);
		Assert.equals(0.0, this._itemRenderer.height);
		Assert.equals(0.0, this._itemRenderer.minWidth);
		Assert.equals(0.0, this._itemRenderer.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._itemRenderer.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._itemRenderer.maxHeight);
		Assert.equals(0.0, this._itemRenderer.baseline);
	}

	public function testMeasurementsWithTextAndIconAndShowTextFalse():Void {
		var text = "Hello World";
		this._measureTextField = new TextField();
		this._measureTextField.autoSize = LEFT;
		this._measureTextField.text = text;
		// swf requires both on stage or both off stage for equal measurement
		Lib.current.addChild(this._measureTextField);

		var icon = new RectangleSkin();
		icon.width = 20.0;
		icon.height = 20.0;
		this._itemRenderer.icon = icon;
		this._itemRenderer.text = text;
		this._itemRenderer.showText = false;
		this._itemRenderer.validateNow();

		Assert.equals(20.0, this._itemRenderer.width);
		Assert.equals(20.0, this._itemRenderer.height);
		Assert.equals(20.0, this._itemRenderer.minWidth);
		Assert.equals(20.0, this._itemRenderer.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._itemRenderer.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._itemRenderer.maxHeight);
		Assert.equals(((icon.height - this._measureTextField.height) / 2.0) + this._measureTextField.getLineMetrics(0).ascent, this._itemRenderer.baseline);
	}
}

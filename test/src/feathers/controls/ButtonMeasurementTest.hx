/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.skins.RectangleSkin;
import openfl.Lib;
import openfl.text.TextField;
import utest.Assert;
import utest.Test;

@:keep
@:access(feathers.controls.Button)
class ButtonMeasurementTest extends Test {
	private static final BACKGROUND_WIDTH = 30.0;
	private static final BACKGROUND_HEIGHT = 32.0;
	private static final BACKGROUND_MIN_WIDTH = 20.0;
	private static final BACKGROUND_MIN_HEIGHT = 18.0;
	private static final BACKGROUND_MAX_WIDTH = 50.0;
	private static final BACKGROUND_MAX_HEIGHT = 45.0;

	private var _button:Button;

	public function new() {
		super();
	}

	public function setup():Void {
		this._button = new Button();
		this._button.themeEnabled = false;
		Lib.current.addChild(this._button);
	}

	public function teardown():Void {
		if (this._button.parent != null) {
			this._button.parent.removeChild(this._button);
		}
		this._button = null;
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
		this._button.backgroundSkin = skin;
	}

	public function testMeasurementsWithNoBackgroundSkinAndNoContent():Void {
		this._button.validateNow();

		Assert.equals(0.0, this._button.width);
		Assert.equals(0.0, this._button.height);
		Assert.equals(0.0, this._button.minWidth);
		Assert.equals(0.0, this._button.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._button.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._button.maxHeight);
	}

	public function testMeasurementsWithRectangleSkinBackgroundSkinAndNoContent():Void {
		this.addRectangleSkinBackground();
		this._button.validateNow();

		Assert.equals(BACKGROUND_WIDTH, this._button.width);
		Assert.equals(BACKGROUND_HEIGHT, this._button.height);
		Assert.equals(BACKGROUND_MIN_WIDTH, this._button.minWidth);
		Assert.equals(BACKGROUND_MIN_HEIGHT, this._button.minHeight);
		Assert.equals(BACKGROUND_MAX_WIDTH, this._button.maxWidth);
		Assert.equals(BACKGROUND_MAX_HEIGHT, this._button.maxHeight);
	}

	public function testMeasurementsWithText():Void {
		var text = "Hello World";
		var textField = new TextField();
		textField.autoSize = LEFT;
		textField.text = text;

		this._button.text = text;
		this._button.validateNow();

		Assert.isTrue(this._button.width > 0.0);
		Assert.isTrue(this._button.height > 0.0);
		Assert.equals(textField.width, this._button.width);
		Assert.equals(textField.height, this._button.height);
		Assert.equals(textField.width, this._button.minWidth);
		Assert.equals(textField.height, this._button.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._button.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._button.maxHeight);
	}

	public function testMeasurementsWithHtmlText():Void {
		var htmlText = "<b>Hello</b> <i>World</i>";
		var textField = new TextField();
		textField.autoSize = LEFT;
		textField.htmlText = htmlText;

		this._button.htmlText = htmlText;
		this._button.validateNow();

		Assert.isTrue(this._button.width > 0.0);
		Assert.isTrue(this._button.height > 0.0);
		Assert.equals(textField.width, this._button.width);
		Assert.equals(textField.height, this._button.height);
		Assert.equals(textField.width, this._button.minWidth);
		Assert.equals(textField.height, this._button.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._button.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._button.maxHeight);
	}

	public function testMeasurementsWithTextAndShowTextFalse():Void {
		this._button.text = "Hello World";
		this._button.showText = false;
		this._button.validateNow();

		Assert.equals(0.0, this._button.width);
		Assert.equals(0.0, this._button.height);
		Assert.equals(0.0, this._button.minWidth);
		Assert.equals(0.0, this._button.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._button.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._button.maxHeight);
	}

	public function testMeasurementsWithHtmlTextAndShowTextFalse():Void {
		this._button.htmlText = "<b>Hello</b> <i>World</i>";
		this._button.showText = false;
		this._button.validateNow();

		Assert.equals(0.0, this._button.width);
		Assert.equals(0.0, this._button.height);
		Assert.equals(0.0, this._button.minWidth);
		Assert.equals(0.0, this._button.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._button.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._button.maxHeight);
	}
}

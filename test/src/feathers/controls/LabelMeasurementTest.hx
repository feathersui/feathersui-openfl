/*
	Feathers UI
	Copyright 2022 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import openfl.Lib;
import openfl.text.TextField;
import utest.Assert;
import utest.Test;

@:keep
@:access(feathers.controls.Label)
class LabelMeasurementTest extends Test {
	private static final BACKGROUND_WIDTH = 30.0;
	private static final BACKGROUND_HEIGHT = 32.0;
	private static final BACKGROUND_MIN_WIDTH = 20.0;
	private static final BACKGROUND_MIN_HEIGHT = 18.0;
	private static final BACKGROUND_MAX_WIDTH = 50.0;
	private static final BACKGROUND_MAX_HEIGHT = 45.0;

	private var _label:Label;

	public function new() {
		super();
	}

	public function setup():Void {
		this._label = new Label();
		this._label.themeEnabled = false;
		Lib.current.addChild(this._label);
	}

	public function teardown():Void {
		if (this._label.parent != null) {
			this._label.parent.removeChild(this._label);
		}
		this._label = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testMeasurementsWithNoText():Void {
		var textField = new TextField();
		textField.autoSize = LEFT;
		textField.text = "\u200b";

		this._label.validateNow();

		Assert.equals(4.0, this._label.width);
		Assert.equals(textField.height, this._label.height);
		Assert.equals(4.0, this._label.minWidth);
		Assert.equals(textField.height, this._label.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._label.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._label.maxHeight);
		Assert.equals(textField.getLineMetrics(0).ascent, this._label.baseline);
	}

	public function testMeasurementsWithText():Void {
		var text = "Hello World";
		var textField = new TextField();
		textField.autoSize = LEFT;
		textField.text = text;

		this._label.text = text;
		this._label.validateNow();

		Assert.isTrue(this._label.width > 0.0);
		Assert.isTrue(this._label.height > 0.0);
		Assert.equals(textField.width, this._label.width);
		Assert.equals(textField.height, this._label.height);
		Assert.equals(textField.width, this._label.minWidth);
		Assert.equals(textField.height, this._label.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._label.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._label.maxHeight);
		Assert.equals(textField.getLineMetrics(0).ascent, this._label.baseline);
	}

	public function testMeasurementsWithHtmlText():Void {
		var htmlText = "<b>Hello</b> <i>World</i>";
		var textField = new TextField();
		textField.autoSize = LEFT;
		textField.htmlText = htmlText;

		this._label.htmlText = htmlText;
		this._label.validateNow();

		Assert.isTrue(this._label.width > 0.0);
		Assert.isTrue(this._label.height > 0.0);
		Assert.equals(textField.width, this._label.width);
		Assert.equals(textField.height, this._label.height);
		Assert.equals(textField.width, this._label.minWidth);
		Assert.equals(textField.height, this._label.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._label.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._label.maxHeight);
		Assert.equals(textField.getLineMetrics(0).ascent, this._label.baseline);
	}
}

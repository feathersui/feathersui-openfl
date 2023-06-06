/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

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
	private var _measureTextField:TextField;

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
		if (this._measureTextField != null && this._measureTextField.parent != null) {
			this._measureTextField.parent.removeChild(this._measureTextField);
		}
		this._measureTextField = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testMeasurementsWithNoText():Void {
		this._measureTextField = new TextField();
		this._measureTextField.autoSize = LEFT;
		this._measureTextField.text = "\u200b";
		// swf requires both on stage or both off stage for equal measurement
		Lib.current.addChild(this._measureTextField);

		this._label.validateNow();

		Assert.isTrue(this._label.width > 0.0);
		Assert.isTrue(this._label.height > 0.0);
		Assert.equals(this._measureTextField.width, this._label.width);
		Assert.equals(this._measureTextField.height, this._label.height);
		Assert.equals(this._measureTextField.width, this._label.minWidth);
		Assert.equals(this._measureTextField.height, this._label.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._label.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._label.maxHeight);
		Assert.equals(this._measureTextField.getLineMetrics(0).ascent, this._label.baseline);
	}

	public function testMeasurementsWithText():Void {
		var text = "Hello World";
		this._measureTextField = new TextField();
		this._measureTextField.autoSize = LEFT;
		this._measureTextField.text = text;
		// swf requires both on stage or both off stage for equal measurement
		Lib.current.addChild(this._measureTextField);

		this._label.text = text;
		this._label.validateNow();

		Assert.isTrue(this._label.width > 0.0);
		Assert.isTrue(this._label.height > 0.0);
		Assert.equals(this._measureTextField.width, this._label.width);
		Assert.equals(this._measureTextField.height, this._label.height);
		Assert.equals(this._measureTextField.width, this._label.minWidth);
		Assert.equals(this._measureTextField.height, this._label.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._label.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._label.maxHeight);
		Assert.equals(this._measureTextField.getLineMetrics(0).ascent, this._label.baseline);
	}

	public function testMeasurementsWithHtmlText():Void {
		var htmlText = "<b>Hello</b> <i>World</i>";
		this._measureTextField = new TextField();
		this._measureTextField.autoSize = LEFT;
		this._measureTextField.htmlText = htmlText;
		// swf requires both on stage or both off stage for equal measurement
		Lib.current.addChild(this._measureTextField);

		this._label.htmlText = htmlText;
		this._label.validateNow();

		Assert.isTrue(this._label.width > 0.0);
		Assert.isTrue(this._label.height > 0.0);
		Assert.equals(this._measureTextField.width, this._label.width);
		Assert.equals(this._measureTextField.height, this._label.height);
		Assert.equals(this._measureTextField.width, this._label.minWidth);
		Assert.equals(this._measureTextField.height, this._label.minHeight);
		Assert.equals(Math.POSITIVE_INFINITY, this._label.maxWidth);
		Assert.equals(Math.POSITIVE_INFINITY, this._label.maxHeight);
		Assert.equals(this._measureTextField.getLineMetrics(0).ascent, this._label.baseline);
	}

	public function testIncreasedHeightAfterSettingWordWrapAndWidth():Void {
		this._label.text = "I am the very model of a modern major general";
		this._label.wordWrap = true;
		this._label.validateNow();

		Assert.isTrue(this._label.width > 0.0);
		Assert.isTrue(this._label.height > 0.0);

		var oldHeight = this._label.height;
		this._label.width = 50.0;
		this._label.validateNow();

		Assert.isTrue(this._label.height > oldHeight);
	}
}

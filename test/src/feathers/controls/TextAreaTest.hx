/*
	Feathers UI
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import openfl.display.Shape;
import utest.Assert;
import utest.Test;

@:keep
@:access(feathers.controls.TextArea)
class TextAreaTest extends Test {
	private var _textArea:TextArea;

	public function new() {
		super();
	}

	public function setup():Void {
		this._textArea = new TextArea();
		TestMain.openfl_root.addChild(this._textArea);
	}

	public function teardown():Void {
		if (this._textArea.parent != null) {
			this._textArea.parent.removeChild(this._textArea);
		}
		this._textArea = null;
		Assert.equals(0, TestMain.openfl_root.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testRemoveSkinAfterChangeState():Void {
		var skin1 = new Shape();
		var skin2 = new Shape();
		Assert.isNull(skin1.parent);
		Assert.isNull(skin2.parent);
		this._textArea.backgroundSkin = skin1;
		this._textArea.setSkinForState(TextInputState.ERROR, skin2);
		this._textArea.validateNow();
		Assert.equals(this._textArea, skin1.parent);
		Assert.isNull(skin2.parent);
		this._textArea.changeState(ERROR);
		this._textArea.validateNow();
		Assert.isNull(skin1.parent);
		Assert.equals(this._textArea, skin2.parent);
	}

	public function testErrorStringCalloutOpenAndCloseOnFocusChange():Void {
		Assert.isFalse(this._textArea.errorStringCalloutOpen);
		this._textArea.errorString = "Something is wrong";
		this._textArea.validateNow();
		Assert.isFalse(this._textArea.errorStringCalloutOpen);
		TestMain.openfl_root.stage.focus = this._textArea;
		this._textArea.validateNow();
		Assert.isTrue(this._textArea.errorStringCalloutOpen);
		TestMain.openfl_root.stage.focus = TestMain.openfl_root.stage;
		this._textArea.validateNow();
		Assert.isFalse(this._textArea.errorStringCalloutOpen);
	}
}

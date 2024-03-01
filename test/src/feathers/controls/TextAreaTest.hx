/*
	Feathers UI
	Copyright 2024 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import openfl.Lib;
import openfl.display.Shape;
import openfl.events.Event;
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
		Lib.current.addChild(this._textArea);
	}

	public function teardown():Void {
		if (this._textArea.parent != null) {
			this._textArea.parent.removeChild(this._textArea);
		}
		this._textArea = null;
		Assert.equals(1, Lib.current.numChildren, "Test cleanup failed to remove all children from the root");
	}

	public function testNoExceptionOnDoubleDispose():Void {
		this._textArea.validateNow();
		this._textArea.dispose();
		this._textArea.dispose();
		Assert.pass();
	}

	public function testDispatchChangeEventOnSetTextProgramatically():Void {
		this._textArea.validateNow();
		var changed = false;
		this._textArea.addEventListener(Event.CHANGE, function(event:Event):Void {
			changed = true;
		});
		Assert.isFalse(changed);
		this._textArea.text = "Hello";
		Assert.isTrue(changed);
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
		Lib.current.stage.focus = this._textArea;
		this._textArea.validateNow();
		Assert.isTrue(this._textArea.errorStringCalloutOpen);
		Lib.current.stage.focus = Lib.current.stage;
		this._textArea.validateNow();
		Assert.isFalse(this._textArea.errorStringCalloutOpen);
	}
}
